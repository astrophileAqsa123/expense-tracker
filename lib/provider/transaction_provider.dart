import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error;

  StreamSubscription? _balanceSub;

  double totalBalance = 0;
  double monthlyIncome = 0;
  double monthlyExpense = 0;

  TransactionProvider() {
    _listenUserBalance();
  }

  void _listenUserBalance() {
    final user = _auth.currentUser;
    if (user == null) return;

    _balanceSub?.cancel();
    _balanceSub = _db.collection("users").doc(user.uid).snapshots().listen((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final balance = data["balance"] as Map<String, dynamic>? ?? {};

      totalBalance = (balance["totalBalance"] as num?)?.toDouble() ?? 0.0;
      monthlyIncome = (balance["monthlyIncome"] as num?)?.toDouble() ?? 0.0;
      monthlyExpense = (balance["monthlyExpense"] as num?)?.toDouble() ?? 0.0;

      notifyListeners();
    });
  }

  /// ✅ Add Income (also updates users/{uid}.income for Budget screen)
  Future<void> addIncome({
    required double amount,
    required String category,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;
    final userDoc = _db.collection("users").doc(uid);

    loading = true;
    error = null;
    notifyListeners();

    try {
      // Ensure balance exists
      final snap = await userDoc.get();
      if (!snap.exists) {
        await userDoc.set({
          "balance": {
            "totalBalance": 0.0,
            "monthlyIncome": 0.0,
            "monthlyExpense": 0.0,
          },
          "income": 0.0,
        }, SetOptions(merge: true));
      } else {
        final data = snap.data() as Map<String, dynamic>? ?? {};
        if (!data.containsKey("balance")) {
          await userDoc.set({
            "balance": {
              "totalBalance": 0.0,
              "monthlyIncome": 0.0,
              "monthlyExpense": 0.0,
            }
          }, SetOptions(merge: true));
        }
      }

      // Save income entry (optional collection)
      await userDoc.collection("incomes").add({
        "amount": amount,
        "category": category,
        "description": description,
        "date": FieldValue.serverTimestamp(),
      });

      // Save transaction entry (main collection used by dashboard/analytics)
      await userDoc.collection("transactions").add({
        "amount": amount,
        "type": "income",
        "category": category,
        "description": description,
        "date": FieldValue.serverTimestamp(),
      });

      // Update balances + store income for Budget screen
      await userDoc.set({
        "income": FieldValue.increment(amount), // ✅ for Budget screen auto
        "balance": {
          "totalBalance": FieldValue.increment(amount),
          "monthlyIncome": FieldValue.increment(amount),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ✅ Add Expense + Overspend Alert
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final uid = user.uid;
    final userDoc = _db.collection("users").doc(uid);

    loading = true;
    error = null;
    notifyListeners();

    try {
      // Ensure balance exists
      final snap = await userDoc.get();
      if (!snap.exists) {
        await userDoc.set({
          "balance": {
            "totalBalance": 0.0,
            "monthlyIncome": 0.0,
            "monthlyExpense": 0.0,
          }
        }, SetOptions(merge: true));
      }

      // Save expense entry (optional collection)
      await userDoc.collection("expenses").add({
        "amount": amount,
        "category": category,
        "description": title,
        "notes": notes,
        "date": FieldValue.serverTimestamp(),
      });

      // Save transaction (main)
      await userDoc.collection("transactions").add({
        "amount": amount,
        "type": "expense",
        "category": category,
        "description": title,
        "notes": notes,
        "date": FieldValue.serverTimestamp(),
      });

      // Update balance
      await userDoc.set({
        "balance": {
          "totalBalance": FieldValue.increment(-amount),
          "monthlyExpense": FieldValue.increment(amount),
        }
      }, SetOptions(merge: true));

      // ✅ check overspend after saving
      await _checkOverspendAndCreateAlert(uid: uid, category: category);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ✅ Budget overspend check (this month) and create alert doc
  Future<void> _checkOverspendAndCreateAlert({
    required String uid,
    required String category,
  }) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    // 1) load current budget
    final budgetDoc = await _db
        .collection("users")
        .doc(uid)
        .collection("budget")
        .doc("current_month")
        .get();

    if (!budgetDoc.exists) return;

    final bData = budgetDoc.data() as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> catBudgetRaw =
        (bData["categoryBudget"] as Map<String, dynamic>?) ?? {};

    // Note: your categories sometimes use "Other" vs "Others"
    double? recommended = (catBudgetRaw[category] as num?)?.toDouble();
    recommended ??= (catBudgetRaw["Other"] as num?)?.toDouble();

    if (recommended == null || recommended <= 0) return;

    // 2) compute spent in this category this month
    final txSnap = await _db
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .where("type", isEqualTo: "expense")
        .where("category", isEqualTo: category)
        .get();

    double spent = 0.0;

    for (final d in txSnap.docs) {
      final m = d.data();

      final ts = m["date"];
      DateTime? dt;

      if (ts is Timestamp) dt = ts.toDate();
      if (dt == null) continue;

      if (dt.isBefore(startOfMonth) || !dt.isBefore(endOfMonth)) continue;

      spent += (m["amount"] as num?)?.toDouble() ?? 0.0;
    }

    if (spent <= recommended) return;

    final overBy = spent - recommended;
    final monthKey = "${now.year}-${now.month.toString().padLeft(2, "0")}";

    // 3) avoid duplicate spam: only create 1 unresolved per category per month
    final existing = await _db
        .collection("users")
        .doc(uid)
        .collection("alerts")
        .where("type", isEqualTo: "overspend")
        .where("category", isEqualTo: category)
        .where("monthKey", isEqualTo: monthKey)
        .where("resolved", isEqualTo: false)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _db.collection("users").doc(uid).collection("alerts").add({
      "type": "overspend",
      "category": category,
      "spent": spent,
      "recommended": recommended,
      "overBy": overBy,
      "createdAt": FieldValue.serverTimestamp(),
      "resolved": false,
      "monthKey": monthKey,
      "title": "Budget exceeded",
      "message":
          "You exceeded $category budget by Rs ${overBy.toStringAsFixed(0)} (Spent: Rs ${spent.toStringAsFixed(0)}, Budget: Rs ${recommended.toStringAsFixed(0)})",
      "read": false,
    });
  }

  @override
  void dispose() {
    _balanceSub?.cancel();
    super.dispose();
  }
}

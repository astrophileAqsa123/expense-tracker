import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TransactionModel> _transactions = [];
  double _totalBalance = 0;
  double _monthlyExpense = 0;
  double _monthlyIncome = 0;

  bool loading = true;

  List<TransactionModel> get transactions => _transactions;
  double get totalBalance => _totalBalance;
  double get monthlyExpense => _monthlyExpense;
  double get monthlyIncome => _monthlyIncome;

  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Listen to transactions
    _db.collection('users').doc(uid).collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap(doc.id, data);
      }).toList();

      _calculateBalance();
      notifyListeners();
    });
  }

  void _calculateBalance() {
    _totalBalance = 0;
    _monthlyExpense = 0;
    _monthlyIncome = 0;

    final now = DateTime.now();
    for (var tx in _transactions) {
      if (tx.type == 'income') {
        _totalBalance += tx.amount;
        if (tx.date.month == now.month && tx.date.year == now.year) {
          _monthlyIncome += tx.amount;
        }
      } else {
        _totalBalance -= tx.amount;
        if (tx.date.month == now.month && tx.date.year == now.year) {
          _monthlyExpense += tx.amount;
        }
      }
    }
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    String notes = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final userDoc = _db.collection('users').doc(uid);
    final now = DateTime.now();

    final batch = _db.batch();

    final txRef = userDoc.collection('transactions').doc();
    batch.set(txRef, {
      "title": title,
      "amount": amount,
      "type": "expense",
      "category": category,
      "notes": notes,
      "date": now,
    });

    batch.update(userDoc, {
      "balance.totalBalance": FieldValue.increment(-amount),
      "balance.monthlyExpense": FieldValue.increment(amount),
    });

    await batch.commit();
  }
}

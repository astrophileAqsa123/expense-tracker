<<<<<<< HEAD
import 'dart:async';
=======
>>>>>>> 0f10098 (Your commit message)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class AnalyticProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TransactionModel> _transactions = [];
  bool loading = true;
<<<<<<< HEAD
  String? errorMessage;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  StreamSubscription<User?>? _authSub;

  AnalyticProvider() {
    _listenAuthAndLoad();
=======

  AnalyticProvider() {
    _init();
>>>>>>> 0f10098 (Your commit message)
  }

  List<TransactionModel> get transactions => _transactions;

<<<<<<< HEAD
  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, tx) => sum + tx.amount);

  Map<String, double> get categoryTotals {
    final Map<String, double> map = {};
    for (final tx in _transactions) {
      if (tx.type == 'expense') {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
=======
  double get totalIncome =>
      _transactions.where((tx) => tx.type == 'income').fold(0, (sum, tx) => sum + tx.amount);

  double get totalExpense =>
      _transactions.where((tx) => tx.type == 'expense').fold(0, (sum, tx) => sum + tx.amount);

  Map<String, double> get categoryTotals {
    final Map<String, double> map = {};
    for (var tx in _transactions) {
      if (tx.type == 'expense') {
        map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
>>>>>>> 0f10098 (Your commit message)
      }
    }
    return map;
  }

  Map<int, double> get dailyTotals {
    final Map<int, double> map = {};
    final now = DateTime.now();
<<<<<<< HEAD
    for (final tx in _transactions) {
      if (tx.type == 'expense' && tx.date.month == now.month && tx.date.year == now.year) {
        map[tx.date.day] = (map[tx.date.day] ?? 0.0) + tx.amount;
=======
    for (var tx in _transactions) {
      if (tx.type == 'expense' &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        map[tx.date.day] = (map[tx.date.day] ?? 0) + tx.amount;
>>>>>>> 0f10098 (Your commit message)
      }
    }
    return map;
  }

<<<<<<< HEAD
  void _listenAuthAndLoad() {
    _authSub = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _transactions = [];
        loading = false;
        errorMessage = "User not logged in";
        _sub?.cancel();
        _sub = null;
        notifyListeners();
      } else {
        _startTransactionsListener(user.uid);
      }
    });

    final current = _auth.currentUser;
    if (current != null) {
      _startTransactionsListener(current.uid);
    }
  }

  void _startTransactionsListener(String uid) {
    _sub?.cancel();

    loading = true;
    errorMessage = null;
    notifyListeners();

    final query = _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true);

    // Safety: if nothing comes back (or callback crashes), show message
    Timer(const Duration(seconds: 8), () {
      if (loading && errorMessage == null) {
        loading = false;
        errorMessage = "Analytics timed out. Check Firestore rules or bad transaction data (date field).";
        notifyListeners();
      }
    });

    _sub = query.snapshots().listen(
      (snapshot) {
        try {
          final list = <TransactionModel>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();

            // Optional guard: ensure 'date' exists
            if (data['date'] == null) {
              throw Exception("Transaction ${doc.id} has missing 'date' field.");
            }

            list.add(TransactionModel.fromMap(doc.id, data));
          }

          _transactions = list;
          loading = false;
          errorMessage = null;
          notifyListeners();
        } catch (e) {
          // ✅ IMPORTANT: catch parsing errors so loading doesn't stay forever
          loading = false;
          errorMessage = "Bad transaction data: $e";
          notifyListeners();
        }
      },
      onError: (e) {
        loading = false;
        errorMessage = e.toString(); // permission-denied will show here
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
=======
  Future<void> _init() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap(doc.id, data);
      }).toList();

      loading = false;
      notifyListeners();
    });
>>>>>>> 0f10098 (Your commit message)
  }
}

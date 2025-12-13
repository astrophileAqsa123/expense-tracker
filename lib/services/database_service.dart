import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db;
  final String uid;

  DatabaseService({
    required this.uid,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  /// User document reference
  DocumentReference<Map<String, dynamic>> get userDoc =>
      _db.collection('users').doc(uid);

  /// Transactions collection reference
  CollectionReference<Map<String, dynamic>> get txCol =>
      userDoc.collection('transactions');

  // ---------------- USER ----------------

  /// Save or update user profile (MERGE to avoid overwriting)
  Future<void> saveUser(UserModel user) {
    return userDoc.set(user.toMap(), SetOptions(merge: true));
  }

  /// Fetch user profile
  Future<UserModel?> getUserProfile() async {
    final snap = await userDoc.get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromMap(snap.id, snap.data()!);
  }

  // ---------------- BUDGET ----------------

  /// Update budget
  Future<void> updateBudget(BudgetModel budget) {
    return userDoc.update({'budget': budget.toMap()});
  }

  // ---------------- TRANSACTIONS ----------------

  /// Add transaction
  Future<void> addTransaction(TransactionModel tx) {
    return txCol.add(tx.toMap());
  }

  /// Update transaction
  Future<void> editTransaction(String id, TransactionModel tx) {
    return txCol.doc(id).update(tx.toMap());
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) {
    return txCol.doc(id).delete();
  }

  /// 🔥 Stream all transactions (REAL-TIME, FAST)
  Stream<List<TransactionModel>> streamTransactions() {
    return txCol
        .orderBy('date', descending: true)
        .snapshots()
        .map(_mapTxSnapshot);
  }

  /// 🔥 Stream by category
  Stream<List<TransactionModel>> streamTransactionsByCategory(
      String category) {
    return txCol
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map(_mapTxSnapshot);
  }

  /// 🔥 One-time fetch by date range (reports)
  Future<List<TransactionModel>> fetchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snap = await txCol
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snap.docs.map(_mapTxDoc).toList();
  }

  /// ❌ OLD: Looping client-side totals (slow)
  /// ✅ NEW: Use cached stream or cloud function later
  Future<double> totalByType(String type) async {
    final snap = await txCol.where('type', isEqualTo: type).get();

    return snap.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc.data()['amount'] as num? ?? 0).toDouble(),
    );
  }

  // ---------------- HELPERS ----------------

  List<TransactionModel> _mapTxSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map(_mapTxDoc).toList();
  }

  TransactionModel _mapTxDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return TransactionModel.fromMap(doc.id, doc.data());
  }
}

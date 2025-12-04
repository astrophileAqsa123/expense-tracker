import "package:expense_tracker/models/budget_model.dart";
import 'package:expense_tracker/models/transaction_model.dart'; 
import 'package:expense_tracker/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  DatabaseService(this.uid);

  /// Reference to the user's document
  DocumentReference get userDoc => _db.collection('users').doc(uid);

  /// Reference to the user's transactions collection
  CollectionReference get txCol => userDoc.collection('transactions');

  /// Save or update user profile
  Future<void> saveUser(UserModel user) async {
    await userDoc.set(user.toMap());
  }

  /// Update budget inside user profile
  Future<void> updateBudget(BudgetModel budget) async {
    await userDoc.update({'budget': budget.toMap()});
  }

  /// Add a transaction (expense or income)
  Future<void> addTransaction(TransactionModel tx) async {
    await txCol.add(tx.toMap());
  }

  /// Edit a transaction by document ID
  Future<void> editTransaction(String id, TransactionModel tx) async {
    await txCol.doc(id).update(tx.toMap());
  }

  /// Delete a transaction by document ID
  Future<void> deleteTransaction(String id) async {
    await txCol.doc(id).delete();
  }

  /// Stream all transactions as TransactionModel list
  Stream<List<TransactionModel>> get transactions {
    return txCol.orderBy('date', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              return TransactionModel.fromMap(doc.id, data);
            })
            .toList();
      },
    );
  }

  /// Get transactions filtered by category
  Stream<List<TransactionModel>> transactionsByCategory(String category) {
    return txCol
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              return TransactionModel.fromMap(doc.id, data);
            })
            .toList());
  }

  /// Get transactions filtered by date range
  Future<List<TransactionModel>> transactionsByDateRange(
      DateTime start, DateTime end) async {
    final snapshot = await txCol
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return TransactionModel.fromMap(doc.id, data);
    }).toList();
  }

  /// Calculate total amount for a type (income/expense)
  Future<double> totalByType(String type) async {
    final snapshot = await txCol.where('type', isEqualTo: type).get();
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data()! as Map<String, dynamic>;
      total += (data['amount'] ?? 0).toDouble();
    }
    return total;
  }

  /// Get user profile as UserModel
  Future<UserModel> getUserProfile() async {
    final docSnap = await userDoc.get();
    final data = docSnap.data()! as Map<String, dynamic>;
    return UserModel.fromMap(docSnap.id, data);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String uid;
  final String name;
  final String email;
  final double income;
  final String currency;
  final String budgetModel;
  final Map<String, dynamic>? budget;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.income,
    required this.currency,
    required this.budgetModel,
    required this.budget,
    required this.createdAt,
  });

  // from Firestore
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      uid: id,
      name: data['name'],
      email: data['email'],
      income: (data['income'] ?? 0).toDouble(),
      currency: data['currency'],
      budgetModel: data['budgetModel'] ?? '50/30/20',
      budget: data['budget'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'income': income,
      'currency': currency,
      'budgetModel': budgetModel,
      'budget': budget,
      'createdAt': createdAt,
    };
  }
}

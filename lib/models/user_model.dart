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
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      income: (data['income'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'PKR',
      budgetModel: data['budgetModel'] ?? '50/30/20',
      budget: data['budget'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this UserModel but with the given fields replaced with the new values.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    double? income,
    String? currency,
    String? budgetModel,
    Map<String, dynamic>? budget,
    DateTime? createdAt,
  }) {
    return UserModel(
      // Use the parameter value if provided, otherwise use the existing field value.
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      income: income ?? this.income,
      currency: currency ?? this.currency,
      budgetModel: budgetModel ?? this.budgetModel,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
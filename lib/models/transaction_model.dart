import 'package:cloud_firestore/cloud_firestore.dart';
class TransactionModel {
  final String id;
  final double amount;
  final String type; // "income" or "expense"
  final String category;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'],
      category: data['category'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
      'date': date,
    };
  }
}

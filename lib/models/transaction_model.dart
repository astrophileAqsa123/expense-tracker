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
    final rawAmount = data['amount'];
    final rawType = data['type'];
    final rawCategory = data['category'];
    final rawDescription = data['description'];
    final rawDate = data['date'];

    // ✅ SAFE amount parsing
    final amount = (rawAmount is num) ? rawAmount.toDouble() : 0.0;

    // ✅ SAFE date parsing (Timestamp / DateTime / String / null)
    DateTime parsedDate = DateTime.now();
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      // null or unknown -> fallback
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: id,
      type: (rawType ?? 'expense').toString(),
      category: (rawCategory ?? 'Other').toString(),
      description: (rawDescription ?? 'Transaction').toString(),
      amount: amount,
      date: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
      // ✅ store as Timestamp for Firestore consistency
      'date': Timestamp.fromDate(date),
    };
  }
}

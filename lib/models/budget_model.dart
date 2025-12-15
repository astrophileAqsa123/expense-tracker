class BudgetModel {
  final String? docId; // Added docId field, made nullable in constructor
  final String periodType;
  final int? periodDays; // Made nullable since monthly/daily might not use it
  final String periodKey;
  final Map<String, double> categoryBudget;

  BudgetModel({
    this.docId, // Include in constructor
    required this.periodType,
    this.periodDays,
    required this.periodKey,
    required this.categoryBudget,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return BudgetModel(
      docId: docId, // Pass docId to constructor
      periodType: map['periodType'] ?? 'monthly',
      periodDays: map['periodDays'] as int?,
      periodKey: map['periodKey'] ?? '',
      categoryBudget:
          Map<String, double>.from(
            (map['categoryBudget'] as Map? ?? {}) // Handle null map
                .map((k, v) => MapEntry(k, (v as num).toDouble())),
          ),
    );
  }

  // ✅ FIX: Define the copyWith method
  BudgetModel copyWith({
    String? docId,
    String? periodType,
    int? periodDays,
    String? periodKey,
    Map<String, double>? categoryBudget,
  }) {
    return BudgetModel(
      docId: docId ?? this.docId,
      periodType: periodType ?? this.periodType,
      periodDays: periodDays ?? this.periodDays,
      periodKey: periodKey ?? this.periodKey,
      categoryBudget: categoryBudget ?? this.categoryBudget,
    );
  }
}
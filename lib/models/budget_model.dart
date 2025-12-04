class BudgetModel {
  final double needs;
  final double wants;
  final double savings;

  BudgetModel({required this.needs, required this.wants, required this.savings});

  factory BudgetModel.fromMap(Map<String, dynamic> data) {
    return BudgetModel(
      needs: (data['needs'] ?? 50).toDouble(),
      wants: (data['wants'] ?? 30).toDouble(),
      savings: (data['savings'] ?? 20).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'needs': needs,
      'wants': wants,
      'savings': savings,
    };
  }
}

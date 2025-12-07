import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  bool loading = true;

  double predictedMonthlyBudget = 0;
  double recommendedSavings = 0;

  Map<String, double> categoryBudget = {};

  // Priority order
  final Map<String, String> categoryPriority = {
    "Rent": "High",
    "Food": "High",
    "Transport": "High",
    "Bills": "High",

    "Health": "Medium",
    "Education": "Medium",

    "Shopping": "Low",
    "Entertainment": "Low",
    "Others": "Low",
  };

  @override
  void initState() {
    super.initState();
    _predictBudget();
  }

  Future<void> _predictBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Fetch last 60 days
    DateTime twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .where("date", isGreaterThan: twoMonthsAgo)
        .get();

    Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data["type"] != "expense") continue;

      double amount = (data["amount"] ?? 0).toDouble();
      String category = data["category"] ?? "Others";

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      totalExpense += amount;
    }

    // Average monthly spend (last 60 days -> convert to 30-day estimate)
    predictedMonthlyBudget = totalExpense / 60 * 30;

    // Auto recommended savings = 20% of total budget
    recommendedSavings = predictedMonthlyBudget * 0.20;

    // Budget to divide across categories
    double spendingBudget = predictedMonthlyBudget - recommendedSavings;

    // Total category weight
    double sum = categoryTotals.values.fold(0, (a, b) => a + b);

    categoryBudget.clear();

    // Divide automatically based on past usage
    categoryTotals.forEach((category, value) {
      double weight = value / sum;
      categoryBudget[category] = spendingBudget * weight;
    });

    // Add missing categories
    for (var cat in categoryPriority.keys) {
      categoryBudget[cat] = categoryBudget[cat] ?? (spendingBudget * 0.05);
    }

    setState(() => loading = false);
  }

  Future<void> _saveBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("budget")
        .doc("current_month")
        .set({
      "predictedBudget": predictedMonthlyBudget,
      "recommendedSavings": recommendedSavings,
      "categoryBudget": categoryBudget,
      "updatedAt": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Budget saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Budget Setup"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildPredictedBudgetCard(),

                const SizedBox(height: 20),

                _buildSavingsCard(),

                const SizedBox(height: 20),

                const Text(
                  "Category-wise Recommended Budget",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...categoryBudget.entries.map((e) => _buildCategoryTile(e.key, e.value)),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveBudget,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text("Save Budget", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // PREDICTED BUDGET CARD
  Widget _buildPredictedBudgetCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Predicted Monthly Budget",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "₹${predictedMonthlyBudget.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // SAVINGS CARD
  Widget _buildSavingsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recommended Savings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "₹${recommendedSavings.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // CATEGORY BUDGET TILE
  Widget _buildCategoryTile(String category, double amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(category),
        subtitle: Text("Priority: ${categoryPriority[category] ?? "Low"}"),
        trailing: Text(
          "Rs${amount.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

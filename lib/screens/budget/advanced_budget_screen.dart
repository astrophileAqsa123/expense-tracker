import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdvancedBudgetScreen extends StatefulWidget {
  const AdvancedBudgetScreen({super.key});

  @override
  State<AdvancedBudgetScreen> createState() => _AdvancedBudgetScreenState();
}

class _AdvancedBudgetScreenState extends State<AdvancedBudgetScreen> {
  bool loading = true;

  Map<String, double> categoryBudget = {};
  Map<String, double> categorySpent = {};
  List<double> monthlyTrend = [];

  double totalBudget = 0;
  double totalSavingsRecommended = 0;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final budgetDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("budget")
        .doc("current_month")
        .get();

    if (!budgetDoc.exists) return;

    categoryBudget =
        Map<String, double>.from(budgetDoc["categoryBudget"] ?? {});

    totalBudget = budgetDoc["predictedBudget"] ?? 0;
    totalSavingsRecommended = budgetDoc["recommendedSavings"] ?? 0;

    await _loadSpendingData();
    await _loadTrendData();

    setState(() => loading = false);
  }

  Future<void> _loadSpendingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .where("type", isEqualTo: "expense")
        .get();

    categorySpent = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String category = data["category"] ?? "Others";
      double amount = (data["amount"] ?? 0).toDouble();

      categorySpent[category] = (categorySpent[category] ?? 0) + amount;
    }
  }

  Future<void> _loadTrendData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final now = DateTime.now();

    monthlyTrend = List.filled(6, 0);

    for (int i = 0; i < 6; i++) {
      DateTime start = DateTime(now.year, now.month - i, 1);
      DateTime end = DateTime(now.year, now.month - i + 1, 1);

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .where("type", isEqualTo: "expense")
          .where("date", isGreaterThanOrEqualTo: start)
          .where("date", isLessThan: end)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()["amount"] ?? 0).toDouble();
      }

      monthlyTrend[5 - i] = total; // oldest to newest
    }
  }

  double _percentUsed(String category) {
    if (!categorySpent.containsKey(category)) return 0;
    if (!categoryBudget.containsKey(category)) return 0;

    return (categorySpent[category]! / categoryBudget[category]!) * 100;
  }

  String _generateRecommendation() {
    double totalSpent =
        categorySpent.values.fold(0, (a, b) => a + b);

    double savingRate = totalSavingsRecommended / totalBudget * 100;

    // Overspending categories
    List<String> overspent = [];
    categoryBudget.forEach((cat, budget) {
      if ((categorySpent[cat] ?? 0) > budget) {
        overspent.add(cat);
      }
    });

    if (overspent.isNotEmpty) {
      return "You overspent in: ${overspent.join(", ")}.\n"
          "Reduce these next month or increase budget for higher priority categories.";
    }

    if (savingRate < 15) {
      return "Your savings rate is low (${savingRate.toStringAsFixed(1)}%). Try saving at least 20%.";
    }

    if (totalSpent < totalBudget * 0.7) {
      return "Great job! You are spending less than expected this month.";
    }

    return "Budget seems stable. Keep tracking your expenses!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Advanced Budget Insights"),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildOverviewCard(),
                const SizedBox(height: 20),
                _buildTrendChart(),
                const SizedBox(height: 20),
                _buildCategoryBars(),
                const SizedBox(height: 20),
                _buildRecommendationCard(),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Monthly Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Total Budget: ₹${totalBudget.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            Text("Recommended Savings: ₹${totalSavingsRecommended.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: monthlyTrend.reduce((a, b) => a > b ? a : b) + 500,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    List<String> months = ["-5", "-4", "-3", "-2", "-1", "Now"];
                    return Text(months[value.toInt()]);
                  },
                )),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(
                    monthlyTrend.length,
                    (i) => FlSpot(i.toDouble(), monthlyTrend[i]),
                  ),
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryBudget.keys.map((category) {
        double percent = _percentUsed(category);
        bool warn = percent > 80;

        return Card(
          child: ListTile(
            title: Text(category),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: percent.clamp(0, 100) / 100,
                  color: percent >= 100
                      ? Colors.red
                      : percent > 80
                          ? Colors.orange
                          : Colors.deepPurple,
                ),
                const SizedBox(height: 5),
                Text(
                  "Used: ₹${categorySpent[category]?.toStringAsFixed(2) ?? "0"} / "
                  "₹${categoryBudget[category]!.toStringAsFixed(2)} "
                  "(${percent.toStringAsFixed(1)}%)",
                  style: TextStyle(
                    color: warn ? Colors.red : Colors.black,
                    fontWeight: warn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _generateRecommendation(),
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}

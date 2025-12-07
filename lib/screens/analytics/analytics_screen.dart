import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ------- Theme Colors -------
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kIncomeColor = Color(0xFF4CAF50);
const Color kExpenseColor = Color(0xFFE53935);
const Color kCardColor = Colors.white;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool loading = true;
  List<QueryDocumentSnapshot> transactions = [];

  double totalIncome = 0;
  double totalExpense = 0;
  Map<String, double> categoryTotals = {};
  Map<int, double> dailyTotals = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .orderBy("date", descending: false)
        .get();

    transactions = snapshot.docs;

    totalIncome = 0;
    totalExpense = 0;
    categoryTotals = {};
    dailyTotals = {};

    for (var doc in transactions) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data["amount"] ?? 0).toDouble();
      final type = data["type"];
      final category = data["category"];
      final date = (data["date"] as Timestamp).toDate();
      final day = date.day;

      // Calculate totals
      if (type == "income") {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }

      // Category totals
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;

      // Daily totals (for chart)
      dailyTotals[day] = (dailyTotals[day] ?? 0) + (type == "expense" ? amount : 0);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Analytics", style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCards(),

                const SizedBox(height: 20),

                _buildSectionTitle("Expense by Category"),
                _buildCategoryPieChart(),

                const SizedBox(height: 30),

                _buildSectionTitle("Daily Expense Chart"),
                _buildDailyBarChart(),
              ],
            ),
    );
  }

  // SUMMARY CARDS ---------------------------------
  Widget _buildSummaryCards() {
    final savings = totalIncome - totalExpense;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard("Income", totalIncome, kIncomeColor),
        _summaryCard("Expense", totalExpense, kExpenseColor),
        _summaryCard("Savings", savings, kPrimaryColor),
      ],
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)
          ],
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, color: kTextColor)),
            const SizedBox(height: 6),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE ---------------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kTextColor,
        ),
      ),
    );
  }

  // CATEGORY PIE CHART -----------------------------
  Widget _buildCategoryPieChart() {
    if (categoryTotals.isEmpty) {
      return const Center(child: Text("No expense data."));
    }

    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 60,
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 30,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  // DAILY BAR CHART --------------------------------
  Widget _buildDailyBarChart() {
    if (dailyTotals.isEmpty) {
      return const Center(child: Text("No expense data."));
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: dailyTotals.entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 14,
                  color: kExpenseColor,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) => Text("${v.toInt()}",
                    style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

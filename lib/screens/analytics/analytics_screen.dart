import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../provider/analytic_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticProvider>(
      builder: (context, txProvider, _) {
        if (txProvider.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (txProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Analytics")),
            body: Center(child: Text(txProvider.errorMessage!)),
          );
        }

        final totalIncome = txProvider.totalIncome;
        final totalExpense = txProvider.totalExpense;
        final savings = totalIncome - totalExpense;
        final categoryTotals = txProvider.categoryTotals;
        final dailyTotals = txProvider.dailyTotals;

        return Scaffold(
          appBar: AppBar(title: const Text("Analytics")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCards(totalIncome, totalExpense, savings),
              const SizedBox(height: 20),
              _buildSectionTitle("Expense by Category"),
              _buildCategoryPieChart(categoryTotals),
              const SizedBox(height: 30),
              _buildSectionTitle("Daily Expense Chart"),
              _buildDailyBarChart(dailyTotals),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(double income, double expense, double savings) {
    return Row(
      children: [
        _summaryCard("Income", income, Colors.green),
        _summaryCard("Expense", expense, Colors.red),
        _summaryCard("Savings", savings, Colors.blue),
      ],
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 6),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> data) {
    if (data.isEmpty) return const Center(child: Text("No expense data."));

    final sections = data.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 60,
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 30,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildDailyBarChart(Map<int, double> data) {
    if (data.isEmpty) return const Center(child: Text("No expense data."));

    return Container(
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(toY: e.value, width: 14, color: Colors.red),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) =>
                    Text("${v.toInt()}", style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../provider/analytic_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: do NOT create provider here if it's already in main.dart
    // So remove ChangeNotifierProvider wrapper.
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

              _buildSectionTitle("Daily Expense (Line Chart)"),
              _buildDailyLineChart(dailyTotals),
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
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
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
      decoration: BoxDecoration(
        color: Colors.white,
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

  // ✅ LINE CHART FOR DAILY EXPENSES
  Widget _buildDailyLineChart(Map<int, double> data) {
    if (data.isEmpty) return const Center(child: Text("No expense data."));

    // Sort by day
    final sortedDays = data.keys.toList()..sort();

    // Convert to FlSpots: x=day, y=amount
    final spots = sortedDays.map((day) {
      return FlSpot(day.toDouble(), data[day]!.toDouble());
    }).toList();

    final maxY = data.values.isEmpty
        ? 0.0
        : data.values.reduce((a, b) => a > b ? a : b);
    final maxX = sortedDays.isEmpty ? 30.0 : sortedDays.last.toDouble();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: maxX,
          minY: 0,
          maxY: (maxY <= 0) ? 100 : maxY + (maxY * 0.2),

          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, meta) {
                  return Text(
                    v.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2, // show every 2 days
                getTitlesWidget: (v, meta) {
                  final day = v.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      day.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true), // fill under line
            ),
          ],
        ),
      ),
    );
  }
}

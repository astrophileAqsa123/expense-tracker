import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../provider/analytic_provider.dart';

<<<<<<< HEAD
import '../../provider/analytic_provider.dart';
import '../../l10n/app_localizations.dart';

// --- THEME COLOR DEFINITIONS ---
const Color kStormyTeal = Color(0xFF156064);
const Color kMintLeaf = Color(0xFF00C49A);
const Color kCoralGlow = Color(0xFFFB8F67);
const Color _kAccentColor = kStormyTeal;
const Color _kSuccessColor = kMintLeaf;
const Color _kDangerColor = kCoralGlow;
const Color _kTextPrimary = Color(0xFF2D3748);
// -------------------------------

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  final List<Color> pieChartColors = const [
    _kDangerColor, // Expense focus
    _kAccentColor,
    Color(0xFF36A2EB),
    Color(0xFFFFCE56),
    Color(0xFF9E9E9E),
    Color(0xFF4CAF50),
  ];

  String _categoryLabel(AppLocalizations t, String rawCategory) {
    final c = rawCategory.trim().toLowerCase();

    // Support variations (e.g., "Food & Drinks", "Transport (Taxi)")
    if (c.contains('food')) return t.food;
    if (c.contains('transport')) return t.transport;
    if (c.contains('shopping')) return t.shopping;
    if (c.contains('bill')) return t.bills;
    if (c.contains('entertain')) return t.entertainment;
    if (c.contains('health')) return t.health;
    if (c.contains('education')) return t.education;

    return t.other;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Consumer<AnalyticProvider>(
      builder: (context, txProvider, _) {
        if (txProvider.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: _kAccentColor),
            ),
          );
        }

        if (txProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(t.analytics),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: _kAccentColor),
              foregroundColor: _kTextPrimary,
            ),
            body: Center(
              child: Text(
                txProvider.errorMessage!,
                style: const TextStyle(color: _kDangerColor),
              ),
            ),
          );
        }

        final totalIncome = txProvider.totalIncome;
        final totalExpense = txProvider.totalExpense;
        final savings = totalIncome - totalExpense;
        final categoryTotals = txProvider.categoryTotals; // Map<String,double>
        final dailyTotals = txProvider.dailyTotals; // Map<int,double>

        return Scaffold(
          appBar: AppBar(
            title: Text(t.analytics, style: const TextStyle(color: _kTextPrimary)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: _kAccentColor),
          ),
          backgroundColor: const Color(0xFFF5F7FA),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCards(context, totalIncome, totalExpense, savings),
              const SizedBox(height: 24),

              _buildSectionTitle(t.expenseByCategory),
              _buildCategoryPieChart(context, categoryTotals),

              const SizedBox(height: 30),

              _buildSectionTitle(t.dailyExpenseTrend),
              _buildDailyLineChart(context, dailyTotals),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    double income,
    double expense,
    double savings,
  ) {
    final t = AppLocalizations.of(context)!;

=======
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticProvider(),
      child: Consumer<AnalyticProvider>(
        builder: (context, txProvider, _) {
          if (txProvider.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
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
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense, double savings) {
>>>>>>> 0f10098 (Your commit message)
    return Row(
      children: [
<<<<<<< HEAD
        _summaryCard(t.income, income, _kSuccessColor, Icons.trending_up),
        _summaryCard(t.expenses, expense, _kDangerColor, Icons.trending_down),
        _summaryCard(t.netSavings, savings, _kAccentColor,
            Icons.account_balance_wallet_outlined),
=======
        _summaryCard("Income", income, Colors.green),
        _summaryCard("Expense", expense, Colors.red),
        _summaryCard("Savings", savings, Colors.blue),
>>>>>>> 0f10098 (Your commit message)
      ],
    );
  }

  Widget _summaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
<<<<<<< HEAD
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
=======
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
>>>>>>> 0f10098 (Your commit message)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            Icon(icon, color: color.withOpacity(0.8), size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              amount.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
=======
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black)),
            const SizedBox(height: 6),
            Text(amount.toStringAsFixed(2),
                style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
>>>>>>> 0f10098 (Your commit message)
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
<<<<<<< HEAD
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _kTextPrimary,
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(
    BuildContext context,
    Map<String, double> data,
  ) {
    final t = AppLocalizations.of(context)!;

    if (data.isEmpty) {
      return Center(child: Text(t.noExpenseDataAvailable));
    }

    final entries = data.entries.toList();

    final sections = entries.asMap().entries.map((item) {
      final index = item.key;
      final entry = item.value;
      final color = pieChartColors[index % pieChartColors.length];

      final label = _categoryLabel(t, entry.key);

=======
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> data) {
    if (data.isEmpty) return const Center(child: Text("No expense data."));
    final sections = data.entries.map((entry) {
>>>>>>> 0f10098 (Your commit message)
      return PieChartSectionData(
        value: entry.value,
        title: label,
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: Text(
          entry.value.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();

    return Container(
<<<<<<< HEAD
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 3,
                borderData: FlBorderData(show: false),
=======
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 30, sectionsSpace: 2)),
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
              barRods: [BarChartRodData(toY: e.value, width: 14, color: Colors.red)],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) => Text("${v.toInt()}", style: const TextStyle(fontSize: 10)),
>>>>>>> 0f10098 (Your commit message)
              ),
            ),
          ),

          // Legend
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.asMap().entries.map((item) {
              final index = item.key;
              final entry = item.value;
              final color = pieChartColors[index % pieChartColors.length];

              final label = _categoryLabel(t, entry.key);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLineChart(
    BuildContext context,
    Map<int, double> data,
  ) {
    final t = AppLocalizations.of(context)!;

    if (data.isEmpty) {
      return Center(child: Text(t.noDailyExpenseData));
    }

    final sortedDays = data.keys.toList()..sort();
    final spots = sortedDays.map((day) {
      return FlSpot(day.toDouble(), data[day]!.toDouble());
    }).toList();

    final maxY = data.values.isEmpty ? 0.0 : data.values.reduce((a, b) => a > b ? a : b);
    final maxX = sortedDays.isEmpty ? 30.0 : sortedDays.last.toDouble();

    return Container(
      height: 300,
      padding: const EdgeInsets.only(top: 12, right: 12, bottom: 6, left: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: maxX,
          minY: 0,
          maxY: (maxY <= 0) ? 100 : maxY + (maxY * 0.2),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY / 4) < 100 ? 100 : maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                t.amount,
                style: const TextStyle(fontSize: 12, color: _kAccentColor),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, meta) {
                  return Text(
                    v.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: _kTextPrimary),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                t.dayOfMonth,
                style: const TextStyle(fontSize: 12, color: _kAccentColor),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxX / 10) < 1 ? 1 : 3,
                getTitlesWidget: (v, meta) {
                  final day = v.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      day.toString(),
                      style: const TextStyle(fontSize: 10, color: _kTextPrimary),
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
              color: _kDangerColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: _kAccentColor,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: _kDangerColor.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

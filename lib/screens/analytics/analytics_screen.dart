import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../provider/analytic_provider.dart';

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
  _kDangerColor, // Coral Glow (Expense focus)
  _kAccentColor, // Stormy Teal
  Color(0xFF36A2EB), // Standard Blue
  Color(0xFFFFCE56), // Yellow
  Color(0xFF9E9E9E), // Grey
  Color(0xFF4CAF50), // Green backup
 ];

 @override
 Widget build(BuildContext context) {
  return Consumer<AnalyticProvider>(
   builder: (context, txProvider, _) {
    if (txProvider.loading) {
     return Scaffold(
      body: Center(child: CircularProgressIndicator(color: _kAccentColor)),
     );
    }

    if (txProvider.errorMessage != null) {
     return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: Center(child: Text(txProvider.errorMessage!, style: const TextStyle(color: _kDangerColor))),
     );
    }

    final totalIncome = txProvider.totalIncome;
    final totalExpense = txProvider.totalExpense;
    final savings = totalIncome - totalExpense;
    final categoryTotals = txProvider.categoryTotals;
    final dailyTotals = txProvider.dailyTotals;

    return Scaffold(
     // THEMED APP BAR
     appBar: AppBar(
      title: const Text("Analytics", style: TextStyle(color: _kTextPrimary)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kAccentColor),
     ),
     backgroundColor: const Color(0xFFF5F7FA), // Light background
     body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
       _buildSummaryCards(totalIncome, totalExpense, savings),
       const SizedBox(height: 24),

       _buildSectionTitle("Expense by Category"),
       _buildCategoryPieChart(categoryTotals),

       const SizedBox(height: 30),

       _buildSectionTitle("Daily Expense Trend"),
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
    _summaryCard("Income", income, _kSuccessColor, Icons.trending_up),
    _summaryCard("Expense", expense, _kDangerColor, Icons.trending_down),
    _summaryCard("Net Savings", savings, _kAccentColor, Icons.account_balance_wallet_outlined),
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
     borderRadius: BorderRadius.circular(16),
     boxShadow: [
      BoxShadow(
       color: Colors.black.withOpacity(0.06), 
       blurRadius: 8, 
       offset: const Offset(0, 3),
      ),
     ],
    ),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      Icon(icon, color: color.withOpacity(0.8), size: 20),
      const SizedBox(height: 4),
      Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      const SizedBox(height: 4),
      Text(
       amount.toStringAsFixed(0),
       style: TextStyle(
        fontSize: 18,
        color: color,
        fontWeight: FontWeight.w800,
       ),
      ),
     ],
    ),
   ),
  );
 }

 Widget _buildSectionTitle(String title) {
  return Padding(
   padding: const EdgeInsets.only(bottom: 12, top: 8),
   child: Text(
    title,
    style: const TextStyle(
     fontSize: 18, 
     fontWeight: FontWeight.bold, 
     color: _kTextPrimary
    ),
   ),
  );
 }

 Widget _buildCategoryPieChart(Map<String, double> data) {
  if (data.isEmpty) return const Center(child: Text("No expense data."));

  final sections = data.entries.toList().asMap().entries.map((item) {
   final index = item.key;
   final entry = item.value;
   final color = pieChartColors[index % pieChartColors.length];
   
   return PieChartSectionData(
    value: entry.value,
    title: entry.key,
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
       ),
      ),
     ),
          // Legend for Pie Chart
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.toList().asMap().entries.map((item) {
                final index = item.key;
                final entry = item.value;
                final color = pieChartColors[index % pieChartColors.length];
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                        children: [
                            Container(width: 10, height: 10, color: color),
                            const SizedBox(width: 6),
                            Text(
                                entry.key,
                                style: TextStyle(color: _kTextPrimary, fontSize: 12),
                            ),
                        ],
                    ),
                );
            }).toList(),
          )
    ],
   ),
  );
 }

 Widget _buildDailyLineChart(Map<int, double> data) {
  if (data.isEmpty) return const Center(child: Text("No daily expense data."));

  final sortedDays = data.keys.toList()..sort();
  final spots = sortedDays.map((day) {
   return FlSpot(day.toDouble(), data[day]!.toDouble());
  }).toList();

  final maxY = data.values.isEmpty
    ? 0.0
    : data.values.reduce((a, b) => a > b ? a : b);
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
       axisNameWidget: const Text('Amount', style: TextStyle(fontSize: 12, color: _kAccentColor)),
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
       axisNameWidget: const Text('Day of Month', style: TextStyle(fontSize: 12, color: _kAccentColor)),
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
       // Using modern FlDotData syntax
       dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
         return FlDotCirclePainter(
          radius: 4,
          color: _kAccentColor, // Stormy Teal dot color
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
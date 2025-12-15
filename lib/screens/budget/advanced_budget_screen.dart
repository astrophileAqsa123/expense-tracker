import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../models/budget_model.dart';

// ---------- THEME COLORS ----------
const Color kAccentColor = Color(0xFF156064);
const Color kSuccessColor = Color(0xFF00C49A);
const Color kDangerColor = Color(0xFFFB8F67);
// ----------------------------------

class AdvancedBudgetScreen extends StatefulWidget {
  const AdvancedBudgetScreen({super.key});

  @override
  State<AdvancedBudgetScreen> createState() => _AdvancedBudgetScreenState();
}

enum BudgetType { need, want, saving }

class _AdvancedBudgetScreenState extends State<AdvancedBudgetScreen> {
  bool _loading = true;
  bool _predicting = false; // State to show prediction loading

  UserModel? _user;
  final Map<String, TextEditingController> _controllers = {};

  // --- 50/30/20 Structure ---
  final Map<String, BudgetType> _budgetStructure = {
    'Food': BudgetType.need,
    'Transport': BudgetType.need,
    'Bills': BudgetType.need,
    'Health': BudgetType.need,
    'Education': BudgetType.need,
    'Shopping': BudgetType.want,
    'Entertain': BudgetType.want,
    'Other': BudgetType.want,
  };

  List<String> get _categories => _budgetStructure.keys.toList();

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final uid = user.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    _user = UserModel.fromMap(
      userDoc.id,
      userDoc.data()!,
    );

    if (_user!.income == 0) {
      _user = _user!.copyWith(income: 2000.0);
    }

    // Initialise all controllers
    for (final category in _categories) {
      _controllers[category] = TextEditingController(text: '0');
    }

    // Default to 50/30/20 initially
    _generate503020BudgetControllers();

    setState(() => _loading = false);
  }

  // ---------------- 50/30/20 BUDGET LOGIC ----------------
  void _generate503020BudgetControllers() {
    final double income = _user!.income;
    final double needsPool = income * 0.50;
    final double wantsPool = income * 0.30;

    final List<String> needCategories = _budgetStructure.keys
        .where((cat) => _budgetStructure[cat] == BudgetType.need)
        .toList();
    final List<String> wantCategories = _budgetStructure.keys
        .where((cat) => _budgetStructure[cat] == BudgetType.want)
        .toList();

    if (needCategories.isNotEmpty) {
      final double needAllocation = needsPool / needCategories.length;
      for (final category in needCategories) {
        _controllers[category]!.text = needAllocation.toStringAsFixed(0);
      }
    }

    if (wantCategories.isNotEmpty) {
      final double wantAllocation = wantsPool / wantCategories.length;
      for (final category in wantCategories) {
        _controllers[category]!.text = wantAllocation.toStringAsFixed(0);
      }
    }
  }

  // ---------------- PREDICTION LOGIC ----------------
  Future<void> _predictBasedOnHistory() async {
    setState(() => _predicting = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // 1. Fetch last 6 budgets to get an average
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .orderBy('createdAt', descending: true)
          .limit(6)
          .get();

      // 2. CHECK: If not enough data
      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough past data to predict!'),
            backgroundColor: Colors.grey,
          ),
        );
        setState(() => _predicting = false);
        return;
      }

      // 3. Calculate Averages
      Map<String, List<double>> historyValues = {};
      
      // Initialize lists
      for (var cat in _categories) {
        historyValues[cat] = [];
      }

      // Collect data
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final catBudget = data['categoryBudget'] as Map<String, dynamic>?;

        if (catBudget != null) {
          for (var cat in _categories) {
            if (catBudget.containsKey(cat)) {
              // Handle safely whether Firestore returns int or double
              num val = catBudget[cat] ?? 0;
              historyValues[cat]?.add(val.toDouble());
            }
          }
        }
      }

      // Apply averages to controllers
      historyValues.forEach((category, values) {
        if (values.isNotEmpty) {
          double average = values.reduce((a, b) => a + b) / values.length;
          _controllers[category]?.text = average.toStringAsFixed(0);
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Predicted based on last ${snapshot.docs.length} records!'),
          backgroundColor: kSuccessColor,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error predicting: $e'), backgroundColor: kDangerColor),
      );
    } finally {
      setState(() => _predicting = false);
    }
  }

  // ---------------- DYNAMIC GETTERS ----------------
  double get _actualNeedsTotal {
    return _budgetStructure.entries.fold(0.0, (sum, entry) {
      if (entry.value == BudgetType.need) {
        return sum + (double.tryParse(_controllers[entry.key]?.text ?? '0') ?? 0);
      }
      return sum;
    });
  }

  double get _actualWantsTotal {
    return _budgetStructure.entries.fold(0.0, (sum, entry) {
      if (entry.value == BudgetType.want) {
        return sum + (double.tryParse(_controllers[entry.key]?.text ?? '0') ?? 0);
      }
      return sum;
    });
  }

  double get _totalBudgetedSpending => _actualNeedsTotal + _actualWantsTotal;

  double get _flexibleSavings {
    return _user!.income - _totalBudgetedSpending;
  }

  // ---------------- SAVE ----------------
  Future<void> _saveBudget() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final Map<String, double> categoryBudget = {};
    for (final entry in _controllers.entries) {
      categoryBudget[entry.key] = double.tryParse(entry.value.text) ?? 0;
    }

    categoryBudget['Savings'] = _flexibleSavings.clamp(0.0, double.infinity);

    final model = BudgetModel(
      periodType: 'monthly',
      periodKey: '${DateTime.now().year}-${DateTime.now().month}',
      categoryBudget: categoryBudget,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .add({
      'periodType': model.periodType,
      'periodKey': model.periodKey,
      'categoryBudget': model.categoryBudget,
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flexible Budget saved successfully!'),
        backgroundColor: kSuccessColor,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flexible 50/30/20 Budget'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // PREDICT BUTTON
          if (_predicting)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20, height: 20, 
                child: CircularProgressIndicator(strokeWidth: 2)
              ),
            )
          else
            IconButton(
              onPressed: _predictBasedOnHistory,
              icon: const Icon(Icons.auto_fix_high, color: kAccentColor),
              tooltip: 'Predict from History',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExplanationCard(),
          const SizedBox(height: 15),
          _buildSummaryCard(),
          const SizedBox(height: 25),
          ..._categories.map(_buildCategoryField),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _flexibleSavings < 0 ? null : _saveBudget,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _flexibleSavings < 0
                  ? kDangerColor.withOpacity(0.5)
                  : kAccentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              _flexibleSavings < 0
                  ? ' Over Budget! Reduce Spending'
                  : 'Apply & Save Flexible Budget',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      color: kAccentColor.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Tap the magic wand icon (top right) to predict budget from past data, or adjust manually below.',
          style: const TextStyle(color: kAccentColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final double income = _user!.income;
    final double targetSavings = income * 0.20;
    final double actualNeeds = _actualNeedsTotal;
    final double actualWants = _actualWantsTotal;
    final double flexibleSavings = _flexibleSavings;
    final double totalBudgeted = actualNeeds + actualWants;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Income: ${_user!.currency} ${income.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            'Actual Needs (Target: ${income * 0.50})',
            actualNeeds,
            color: actualNeeds > income * 0.50 ? kDangerColor : kAccentColor,
            bold: true,
          ),
          _buildSummaryRow(
            'Actual Wants (Target: ${income * 0.30})',
            actualWants,
            color: kDangerColor,
            bold: true,
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            '**Flexible Savings (20% Target: ${targetSavings.toStringAsFixed(0)})**',
            flexibleSavings,
            color: flexibleSavings >= targetSavings
                ? kSuccessColor
                : (flexibleSavings < 0 ? kDangerColor : Colors.orange),
            bold: true,
          ),
          const Divider(height: 16),
          Text(
            'Total Budgeted: ${_user!.currency} ${totalBudgeted.toStringAsFixed(0)}',
            style: const TextStyle(
              color: kAccentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {Color? color, bool bold = false}) {
    final String cleanLabel = label.contains('Target:')
        ? label.substring(0, label.indexOf('(')).trim()
        : label.replaceAll('**', '');
    final String subLabel =
        label.contains('Target:') ? label.substring(label.indexOf('(')) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cleanLabel,
                style: TextStyle(
                  color: color ?? Colors.black87,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (subLabel.isNotEmpty)
                Text(
                  subLabel,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          Text(
            '${_user!.currency} ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField(String category) {
    final type = _budgetStructure[category];
    final typeColor = type == BudgetType.need ? kAccentColor : kDangerColor;
    final typeIcon = type == BudgetType.need ? Icons.check_circle : Icons.star;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[category],
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: '$category (${type.toString().split('.').last.toUpperCase()})',
          prefixIcon: Icon(typeIcon, color: typeColor),
          suffixText: _user!.currency,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: typeColor, width: 2),
          ),
        ),
      ),
    );
  }
}
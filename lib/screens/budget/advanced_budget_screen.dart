import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../models/budget_model.dart';
import '../../l10n/app_localizations.dart';

const Color kAccentColor = Color(0xFF156064);
const Color kSuccessColor = Color(0xFF00C49A);
const Color kDangerColor = Color(0xFFFB8F67);

class AdvancedBudgetScreen extends StatefulWidget {
  const AdvancedBudgetScreen({super.key});

  @override
  State<AdvancedBudgetScreen> createState() => _AdvancedBudgetScreenState();
}

enum BudgetType { need, want, saving }

class _AdvancedBudgetScreenState extends State<AdvancedBudgetScreen> {
  bool _loading = true;
  bool _predicting = false;

  UserModel? _user;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  final Map<String, TextEditingController> _controllers = {};

  bool _dynamicBudgets = true;

  double _totalBalance = 0.0;
  double? _lastTotalBalance;

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

  final Map<String, double> _needWeights = {
    'Bills': 0.35,
    'Food': 0.28,
    'Transport': 0.15,
    'Health': 0.12,
    'Education': 0.10,
  };

  final Map<String, double> _wantWeights = {
    'Shopping': 0.50,
    'Entertain': 0.30,
    'Other': 0.20,
  };

  List<String> get _categories => _budgetStructure.keys.toList();

  String _fixed0(num? v) => ((v ?? 0).toDouble()).toStringAsFixed(0);

  String _categoryLabel(AppLocalizations t, String rawCategory) {
    final c = rawCategory.trim().toLowerCase();
    switch (c) {
      case 'food':
        return t.food;
      case 'transport':
        return t.transport;
      case 'shopping':
        return t.shopping;
      case 'bills':
        return t.bills;
      case 'entertain':
      case 'entertainment':
        return t.entertainment;
      case 'health':
        return t.health;
      case 'education':
        return t.education;
      case 'other':
      default:
        return t.other;
    }
  }

  String _typeLabel(AppLocalizations t, BudgetType type) {
    switch (type) {
      case BudgetType.need:
        return t.need;
      case BudgetType.want:
        return t.want;
      case BudgetType.saving:
        return t.saving;
    }
  }

  @override
  void initState() {
    super.initState();
    _listenToDashboardBalance();
  }

  void _listenToDashboardBalance() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() => _loading = false);
      return;
    }
    final uid = firebaseUser.uid;

    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) {
            if (!doc.exists || doc.data() == null) {
              if (mounted) setState(() => _loading = false);
              return;
            }

            final data = doc.data()!;
            _user = UserModel.fromMap(doc.id, data);

            final Map<String, dynamic>? balanceMap =
                data['balance'] as Map<String, dynamic>?;
            final double totalBalance =
                (balanceMap?['totalBalance'] as num?)?.toDouble() ?? 0.0;

            _totalBalance = totalBalance;

            if (_controllers.isEmpty) {
              for (final category in _categories) {
                _controllers[category] = TextEditingController(text: '0');
              }
            }

            _applyBalanceRules();

            if (mounted) setState(() => _loading = false);
          },
          onError: (e) {
            if (mounted) {
              setState(() => _loading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading balance: $e'),
                  backgroundColor: kDangerColor,
                ),
              );
            }
          },
        );
  }

  void _applyBalanceRules() {
    final balanceNow = _totalBalance;

    if (balanceNow <= 0) {
      _lastTotalBalance = balanceNow;
      return;
    }

    if (_lastTotalBalance == null) {
      _apply503020WithRecommendations(balanceNow);
      _lastTotalBalance = balanceNow;
      return;
    }

    final changed = _lastTotalBalance != balanceNow;

    if (_dynamicBudgets && changed) {
      _apply503020WithRecommendations(balanceNow);
      _lastTotalBalance = balanceNow;
    } else {
      _lastTotalBalance = balanceNow;
    }
  }

  void _apply503020WithRecommendations(double balance) {
    final needsPool = balance * 0.50;
    final wantsPool = balance * 0.30;

    final needCats = _budgetStructure.keys
        .where((c) => _budgetStructure[c] == BudgetType.need)
        .toList();

    final wantCats = _budgetStructure.keys
        .where((c) => _budgetStructure[c] == BudgetType.want)
        .toList();

    final totalNeedWeight = needCats.fold<double>(
      0.0,
      (s, c) => s + (_needWeights[c] ?? 0.0),
    );
    final totalWantWeight = wantCats.fold<double>(
      0.0,
      (s, c) => s + (_wantWeights[c] ?? 0.0),
    );

    for (final c in needCats) {
      final w = _needWeights[c] ?? 0.0;
      final amount = (totalNeedWeight > 0)
          ? (needsPool * (w / totalNeedWeight))
          : (needsPool / needCats.length);
      _controllers[c]!.text = _fixed0(amount);
    }

    for (final c in wantCats) {
      final w = _wantWeights[c] ?? 0.0;
      final amount = (totalWantWeight > 0)
          ? (wantsPool * (w / totalWantWeight))
          : (wantsPool / wantCats.length);
      _controllers[c]!.text = _fixed0(amount);
    }
  }

  Future<void> _predictBasedOnHistory() async {
    final t = AppLocalizations.of(context)!;

    setState(() => _predicting = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .orderBy('createdAt', descending: true)
          .limit(6)
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.notEnoughPastData),
            backgroundColor: Colors.grey,
          ),
        );
        setState(() => _predicting = false);
        return;
      }

      final Map<String, List<double>> historyValues = {
        for (final cat in _categories) cat: <double>[],
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final catBudget = data['categoryBudget'] as Map<String, dynamic>?;
        if (catBudget == null) continue;

        for (final cat in _categories) {
          if (!catBudget.containsKey(cat)) continue;
          final dynamic raw = catBudget[cat];
          final double val = raw is num
              ? raw.toDouble()
              : double.tryParse(raw?.toString() ?? '0') ?? 0.0;
          historyValues[cat]!.add(val);
        }
      }

      historyValues.forEach((cat, values) {
        if (values.isEmpty) return;
        final avg = values.reduce((a, b) => a + b) / values.length;
        _controllers[cat]!.text = _fixed0(avg);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.predictedUsing(snapshot.docs.length.toString())),
          backgroundColor: kSuccessColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.errorPredicting}: $e'),
          backgroundColor: kDangerColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _predicting = false);
    }
  }

  double get _actualNeedsTotal {
    return _budgetStructure.entries.fold(0.0, (sum, entry) {
      if (entry.value == BudgetType.need) {
        return sum +
            (double.tryParse(_controllers[entry.key]?.text ?? '0') ?? 0);
      }
      return sum;
    });
  }

  double get _actualWantsTotal {
    return _budgetStructure.entries.fold(0.0, (sum, entry) {
      if (entry.value == BudgetType.want) {
        return sum +
            (double.tryParse(_controllers[entry.key]?.text ?? '0') ?? 0);
      }
      return sum;
    });
  }

  double get _totalBudgeted => _actualNeedsTotal + _actualWantsTotal;

  double get _flexibleSavings => _totalBalance - _totalBudgeted;

  Future<void> _saveBudget() async {
    final t = AppLocalizations.of(context)!;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final Map<String, double> categoryBudget = {};
    for (final entry in _controllers.entries) {
      categoryBudget[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
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
          'dashboardTotalBalance': _totalBalance,
        });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.budgetSavedSuccessfully),
        backgroundColor: kSuccessColor,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _userSub?.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_loading || _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.dynamicBudgetsTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Row(
            children: [
              Text(
                t.auto,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Switch(
                value: _dynamicBudgets,
                activeColor: kAccentColor,
                onChanged: (v) => setState(() => _dynamicBudgets = v),
              ),
            ],
          ),
          if (_predicting)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _predictBasedOnHistory,
              icon: const Icon(Icons.auto_fix_high, color: kAccentColor),
              tooltip: t.predictFromHistory,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExplanationCard(t),
          const SizedBox(height: 15),
          _buildSummaryCard(t),
          const SizedBox(height: 25),
          ..._categories.map((c) => _buildCategoryField(t, c)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _flexibleSavings < 0 ? null : _saveBudget,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _flexibleSavings < 0
                  ? kDangerColor.withOpacity(0.5)
                  : kAccentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _flexibleSavings < 0 ? t.overBudgetReduce : t.applyAndSaveBudget,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(AppLocalizations t) {
    return Card(
      color: kAccentColor.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          (_totalBalance <= 0
                  ? t.balanceIsZeroHint
                  : t.usingDashboardBalanceHint)
              .toString(),
          style: const TextStyle(
            color: kAccentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations t) {
    final balance = _totalBalance;
    final targetNeeds = balance * 0.50;
    final targetWants = balance * 0.30;
    final targetSavings = balance * 0.20;

    final actualNeeds = _actualNeedsTotal;
    final actualWants = _actualWantsTotal;
    final savings = _flexibleSavings;

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
            '${t.totalBalanceDashboard}: ${_user!.currency} ${_fixed0(balance)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            '${t.needsTarget(_fixed0(targetNeeds))}',
            actualNeeds,
            color: actualNeeds > targetNeeds ? kDangerColor : kAccentColor,
            bold: true,
          ),
          _buildSummaryRow(
            '${t.wantsTarget(_fixed0(targetWants))}',
            actualWants,
            color: actualWants > targetWants ? kDangerColor : kAccentColor,
            bold: true,
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            '${t.savingsTarget(_fixed0(targetSavings))}',
            savings,
            color: savings >= targetSavings ? kSuccessColor : Colors.orange,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_user!.currency} ${_fixed0(amount)}',
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField(AppLocalizations t, String category) {
    final type = _budgetStructure[category]!;
    final typeColor = type == BudgetType.need ? kAccentColor : kDangerColor;
    final typeIcon = type == BudgetType.need ? Icons.check_circle : Icons.star;

    final label = _categoryLabel(t, category);
    final typeText = _typeLabel(t, type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[category],
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: '$label (${typeText.toUpperCase()})',
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

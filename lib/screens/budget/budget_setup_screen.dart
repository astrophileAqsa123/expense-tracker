import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'your_budget_screen.dart';

// --- THEME COLOR DEFINITIONS ---
const Color kStormyTeal = Color(0xFF156064);
const Color kCoralGlow = Color(0xFFFB8F67);
const Color _kAccentColor = kStormyTeal;
const Color _kDangerColor = kCoralGlow;
// -------------------------------

enum BudgetPeriodType {
  monthly,
  daily,
  custom,
}

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  bool loading = false;
  bool isEditMode = false;

  BudgetPeriodType selectedPeriod = BudgetPeriodType.monthly;
  int customDays = 7;
  String? editingBudgetKey;

  final Map<String, TextEditingController> categoryControllers = {};
  final Map<String, double> categoryBudget = {};

  // NOTE: Internal raw keys (do NOT translate these)
  final List<String> categories = [
    "Rent",
    "Food",
    "Transport",
    "Bills",
    "Health",
    "Education",
    "Shopping",
    "Entertainment",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    for (final cat in categories) {
      categoryControllers[cat] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------- PERIOD KEY ----------------
  String _generatePeriodKey(DateTime now) {
    switch (selectedPeriod) {
      case BudgetPeriodType.monthly:
        return "${now.year}-${now.month.toString().padLeft(2, '0')}";
      case BudgetPeriodType.daily:
        return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      case BudgetPeriodType.custom:
        return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${customDays}days";
    }
  }

  // ---------------- LOAD EXISTING ----------------
  Future<void> _loadExistingBudget(String docId) async {
    final t = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("budgets")
        .doc(docId)
        .get();

    if (!doc.exists || doc.data() == null) {
      _toast(t.budgetDocNotFound);
      return;
    }

    final data = doc.data()!;

    for (final c in categoryControllers.values) {
      c.text = "";
    }

    final Map<String, dynamic> map =
        Map<String, dynamic>.from(data['categoryBudget'] ?? {});

    for (final cat in categories) {
      final amount = map[cat];
      if (amount != null) {
        categoryControllers[cat]!.text = amount.toString();
      } else {
        categoryControllers[cat]!.text = "";
      }
    }

    BudgetPeriodType loadedPeriodType;
    switch (data['periodType']) {
      case 'monthly':
        loadedPeriodType = BudgetPeriodType.monthly;
        break;
      case 'daily':
        loadedPeriodType = BudgetPeriodType.daily;
        break;
      case 'custom':
        loadedPeriodType = BudgetPeriodType.custom;
        break;
      default:
        loadedPeriodType = BudgetPeriodType.monthly;
    }

    setState(() {
      isEditMode = true;
      editingBudgetKey = docId;
      selectedPeriod = loadedPeriodType;
      customDays = data['periodDays'] ?? 7;
    });

    _toast("${t.editingBudget}: ${data['periodKey'] ?? docId}");
  }

  // ---------------- VIEW OLD ----------------
  Future<void> _viewOldBudgets() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const YourBudgetsScreen()),
    );

    if (result is String) {
      await _loadExistingBudget(result);
    }
  }

  // ---------------- SAVE ----------------
  Future<void> _saveBudget() async {
    final t = AppLocalizations.of(context)!;

    categoryBudget.clear();

    for (final cat in categories) {
      final value = double.tryParse(categoryControllers[cat]!.text.trim());
      if (value != null && value > 0) {
        categoryBudget[cat] = value;
      }
    }

    if (categoryBudget.isEmpty) {
      _toast(t.enterAtLeastOneCategoryBudget);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    // Keep your existing logic:
    // - if edit mode => must save into same docId
    // - else => generate new periodKey docId
    final docId = editingBudgetKey ?? _generatePeriodKey(now);
    final periodKey = docId;

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("budgets")
        .doc(docId);

    if (!isEditMode) {
      final exists = await docRef.get();
      if (exists.exists) {
        _toast(t.budgetAlreadyExistsLoadToEdit);
        await _loadExistingBudget(docId);
        return;
      }
    }

    setState(() => loading = true);

    await docRef.set({
      "periodType": selectedPeriod.name,
      "periodDays": selectedPeriod == BudgetPeriodType.custom ? customDays : null,
      "periodKey": periodKey,
      "categoryBudget": categoryBudget,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => loading = false);

    _toast(isEditMode ? t.budgetUpdated : t.budgetCreated);
    if (mounted) Navigator.pop(context);
  }

  // ---------------- DELETE ----------------
  Future<void> _deleteBudget() async {
    final t = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || editingBudgetKey == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("budgets")
        .doc(editingBudgetKey!)
        .delete();

    _toast(t.budgetDeleted);
    if (mounted) Navigator.pop(context);
  }

  // ---------------- CATEGORY LABEL ----------------
  String _catLabel(AppLocalizations t, String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'rent':
        return t.rent;
      case 'food':
        return t.food;
      case 'transport':
        return t.transport;
      case 'bills':
        return t.bills;
      case 'health':
        return t.health;
      case 'education':
        return t.education;
      case 'shopping':
        return t.shopping;
      case 'entertainment':
        return t.entertainment;
      case 'other':
      default:
        return t.other;
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? t.editBudget : t.setBudget,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _kAccentColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _kAccentColor))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildViewOldBudgetsButton(t),
                const SizedBox(height: 16),
                _buildPeriodSelector(t),
                const SizedBox(height: 24),
                Text(
                  t.categoryBudgets,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...categories.map((c) => _buildCategoryTile(t, c)).toList(),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: loading ? null : _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                isEditMode ? t.updateBudget : t.saveBudget,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isEditMode)
              TextButton(
                onPressed: _deleteBudget,
                child: Text(
                  t.deleteBudget,
                  style: const TextStyle(color: _kDangerColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- VIEW OLD BUTTON ----------------
  Widget _buildViewOldBudgetsButton(AppLocalizations t) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: _viewOldBudgets,
        icon: const Icon(Icons.history, size: 20),
        label: Text(t.viewEditOldBudgets),
        style: OutlinedButton.styleFrom(
          foregroundColor: _kAccentColor,
          side: const BorderSide(color: _kAccentColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ---------------- PERIOD SELECTOR ----------------
  Widget _buildPeriodSelector(AppLocalizations t) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.budgetPeriod,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BudgetPeriodType>(
              value: selectedPeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: _kAccentColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: BudgetPeriodType.monthly,
                  child: Text(t.monthly),
                ),
                DropdownMenuItem(
                  value: BudgetPeriodType.daily,
                  child: Text(t.daily),
                ),
                DropdownMenuItem(
                  value: BudgetPeriodType.custom,
                  child: Text(t.customDays),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  selectedPeriod = v!;
                  isEditMode = false;
                  editingBudgetKey = null;
                  for (final c in categoryControllers.values) {
                    c.clear();
                  }
                });
              },
            ),
            if (selectedPeriod == BudgetPeriodType.custom) ...[
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: customDays.toString()),
                decoration: InputDecoration(
                  labelText: t.numberOfDays,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: _kAccentColor, width: 2),
                  ),
                ),
                onChanged: (v) {
                  customDays = int.tryParse(v) ?? 7;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- CATEGORY TILE ----------------
  Widget _buildCategoryTile(AppLocalizations t, String category) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(_catLabel(t, category), style: const TextStyle(color: Colors.black87)),
        trailing: SizedBox(
          width: 120,
          child: TextField(
            controller: categoryControllers[category],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: t.currencyPrefix,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TOAST ----------------
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

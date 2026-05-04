import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

<<<<<<< HEAD
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
=======
enum BudgetGroup { needs, wants, savings }
>>>>>>> 0f10098 (Your commit message)

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  bool loading = false;
  bool isEditMode = false;

<<<<<<< HEAD
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
=======
  // income-based
  final TextEditingController incomeController = TextEditingController();
  double monthlyIncome = 0;

  // 50/30/20 group budgets
  double needsBudget = 0;
  double wantsBudget = 0;
  double savingsBudget = 0;

  // Recommended category budgets
  Map<String, double> categoryBudget = {};

  // Category meta: group + priority weight
  final Map<String, Map<String, dynamic>> categoryMeta = {
    "Food": {"group": BudgetGroup.needs, "priority": 5},
    "Transport": {"group": BudgetGroup.needs, "priority": 4},
    "Bills": {"group": BudgetGroup.needs, "priority": 6},
    "Rent": {"group": BudgetGroup.needs, "priority": 7},
    "Health": {"group": BudgetGroup.needs, "priority": 5},
    "Education": {"group": BudgetGroup.needs, "priority": 3},

    "Shopping": {"group": BudgetGroup.wants, "priority": 3},
    "Entertainment": {"group": BudgetGroup.wants, "priority": 2},
    "Others": {"group": BudgetGroup.wants, "priority": 1},
  };

  // Priority labels (UI only)
  final Map<String, String> categoryPriorityLabel = {
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
>>>>>>> 0f10098 (Your commit message)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    for (final cat in categories) {
      categoryControllers[cat] = TextEditingController();
    }
=======
    // Previously you predicted budget from last 60 days.
    // Now: user income drives the rule, so we start idle.
    loading = false;
  }

  @override
  void dispose() {
    incomeController.dispose();
    super.dispose();
  }

  void _buildPlanFromIncome() {
    final parsed = double.tryParse(incomeController.text.trim());
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid monthly income.")),
      );
      return;
    }

    monthlyIncome = parsed;

    // 50/30/20 rule
    needsBudget = monthlyIncome * 0.50;
    wantsBudget = monthlyIncome * 0.30;
    savingsBudget = monthlyIncome * 0.20;

    // Split needs & wants into categories by priority weights
    categoryBudget = {};
    _distributeGroupBudget(BudgetGroup.needs, needsBudget);
    _distributeGroupBudget(BudgetGroup.wants, wantsBudget);

    setState(() {});
  }

  void _distributeGroupBudget(BudgetGroup group, double totalGroupBudget) {
    final cats = categoryMeta.entries.where((e) => e.value["group"] == group).toList();
    final sumPriority = cats.fold<double>(
      0,
      (s, e) => s + (e.value["priority"] as int).toDouble(),
    );

    if (sumPriority == 0) return;

    for (final e in cats) {
      final p = (e.value["priority"] as int).toDouble();
      categoryBudget[e.key] = totalGroupBudget * (p / sumPriority);
    }
  }

  Future<void> _saveBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (monthlyIncome <= 0 || categoryBudget.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create a plan first by entering income.")),
      );
      return;
    }

    final uid = user.uid;
    final now = DateTime.now();
    final monthKey = "${now.year}-${now.month.toString().padLeft(2, "0")}";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("budget")
        .doc("current_month")
        .set({
      "monthKey": monthKey,
      "income": monthlyIncome,
      "rule": {"needs": 0.50, "wants": 0.30, "savings": 0.20},
      "groupBudgets": {
        "needs": needsBudget,
        "wants": wantsBudget,
        "savings": savingsBudget,
      },
      "categoryBudget": categoryBudget,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Budget saved successfully!")),
    );

    // After saving: run overspend check (creates alert docs in Firebase if needed)
    await _checkOverspendAndCreateAlerts();
  }

  /// Checks current month expenses vs recommended category budget.
  /// If exceeded => create an alert doc in Firestore (for notifications/reminders).
  Future<void> _checkOverspendAndCreateAlerts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    // fetch this month expenses
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .where("type", isEqualTo: "expense")
        .where("date", isGreaterThanOrEqualTo: startOfMonth)
        .where("date", isLessThan: endOfMonth)
        .get();

    final Map<String, double> spentByCategory = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final cat = (data["category"] ?? "Others").toString();
      final amt = (data["amount"] ?? 0).toDouble();
      spentByCategory[cat] = (spentByCategory[cat] ?? 0) + amt;
    }

    // compare spent vs recommended
    for (final entry in categoryBudget.entries) {
      final cat = entry.key;
      final rec = entry.value;
      final spent = spentByCategory[cat] ?? 0;

      if (spent > rec) {
        final overBy = spent - rec;

        // store alert doc (use this for local notif / FCM reminders later)
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("alerts")
            .add({
          "type": "overspend",
          "category": cat,
          "spent": spent,
          "recommended": rec,
          "overBy": overBy,
          "createdAt": FieldValue.serverTimestamp(),
          "resolved": false,
          "month": "${now.year}-${now.month.toString().padLeft(2, "0")}",
        });
      }
    }
>>>>>>> 0f10098 (Your commit message)
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
<<<<<<< HEAD
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
=======
                _incomeCard(),
                const SizedBox(height: 16),

                _groupRuleCard(),
                const SizedBox(height: 20),

                const Text(
                  "Category-wise Recommended Budget (Priority Based)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (categoryBudget.isEmpty)
                  const Text("Enter income and tap “Create Plan”."),
                ...categoryBudget.entries.map((e) => _buildCategoryTile(e.key, e.value)),
>>>>>>> 0f10098 (Your commit message)
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
<<<<<<< HEAD
=======
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

  Widget _incomeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
>>>>>>> 0f10098 (Your commit message)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
<<<<<<< HEAD
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
=======
            const Text(
              "Monthly Income",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "Rs ",
                hintText: "Enter monthly income",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _buildPlanFromIncome,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text("Create Plan (50/30/20)"),
>>>>>>> 0f10098 (Your commit message)
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

<<<<<<< HEAD
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
=======
  Widget _groupRuleCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "50/30/20 Rule Breakdown",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _ruleRow("Needs (50%)", needsBudget),
            _ruleRow("Wants (30%)", wantsBudget),
            _ruleRow("Savings (20%)", savingsBudget),
          ],
>>>>>>> 0f10098 (Your commit message)
        ),
      ),
    );
  }

<<<<<<< HEAD
  // ---------------- PERIOD SELECTOR ----------------
  Widget _buildPeriodSelector(AppLocalizations t) {
=======
  Widget _ruleRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "Rs ${amount.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String category, double amount) {
>>>>>>> 0f10098 (Your commit message)
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
<<<<<<< HEAD
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
=======
      child: ListTile(
        title: Text(category),
        subtitle: Text("Priority: ${categoryPriorityLabel[category] ?? "Low"}"),
        trailing: Text(
          "Rs ${amount.toStringAsFixed(0)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
>>>>>>> 0f10098 (Your commit message)
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

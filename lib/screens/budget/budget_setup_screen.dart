import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum BudgetGroup { needs, wants, savings }

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  bool loading = true;

  final TextEditingController incomeController = TextEditingController();
  double monthlyIncome = 0;

  double needsBudget = 0;
  double wantsBudget = 0;
  double savingsBudget = 0;

  Map<String, double> categoryBudget = {};

  final Map<String, Map<String, dynamic>> categoryMeta = {
    "Food": {"group": BudgetGroup.needs, "priority": 5},
    "Transport": {"group": BudgetGroup.needs, "priority": 4},
    "Bills": {"group": BudgetGroup.needs, "priority": 6},
    "Rent": {"group": BudgetGroup.needs, "priority": 7},
    "Health": {"group": BudgetGroup.needs, "priority": 5},
    "Education": {"group": BudgetGroup.needs, "priority": 3},
    "Shopping": {"group": BudgetGroup.wants, "priority": 3},
    "Entertainment": {"group": BudgetGroup.wants, "priority": 2},
    "Other": {"group": BudgetGroup.wants, "priority": 1},
  };

  final Map<String, String> categoryPriorityLabel = {
    "Rent": "High",
    "Food": "High",
    "Transport": "High",
    "Bills": "High",
    "Health": "Medium",
    "Education": "Medium",
    "Shopping": "Low",
    "Entertainment": "Low",
    "Other": "Low",
  };

  @override
  void initState() {
    super.initState();
    _loadIncomeAndBuildPlan();
  }

  @override
  void dispose() {
    incomeController.dispose();
    super.dispose();
  }

  Future<void> _loadIncomeAndBuildPlan() async {
    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final uid = user.uid;

    try {
      final doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final data = doc.data() ?? {};

      final directIncome = (data["income"] as num?)?.toDouble(); // ✅ stored by income/provider

      final balance = data["balance"] as Map<String, dynamic>?;
      final balanceIncome = (balance?["monthlyIncome"] as num?)?.toDouble();

      final income = (directIncome != null && directIncome > 0)
          ? directIncome
          : (balanceIncome != null && balanceIncome > 0)
              ? balanceIncome
              : 0.0;

      monthlyIncome = income;
      incomeController.text =
          monthlyIncome > 0 ? monthlyIncome.toStringAsFixed(0) : "";

      if (monthlyIncome > 0) {
        _buildPlanFromIncome(monthlyIncome);
      }
    } catch (_) {}

    setState(() => loading = false);
  }

  void _buildPlanFromIncome(double income) {
    monthlyIncome = income;

    needsBudget = monthlyIncome * 0.50;
    wantsBudget = monthlyIncome * 0.30;
    savingsBudget = monthlyIncome * 0.20;

    categoryBudget = {};
    _distributeGroupBudget(BudgetGroup.needs, needsBudget);
    _distributeGroupBudget(BudgetGroup.wants, wantsBudget);

    for (final cat in categoryMeta.keys) {
      categoryBudget[cat] = categoryBudget[cat] ?? 0.0;
    }

    setState(() {});
  }

  void _distributeGroupBudget(BudgetGroup group, double totalGroupBudget) {
    final cats =
        categoryMeta.entries.where((e) => e.value["group"] == group).toList();

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

  void _onCreatePlanPressed() {
    final parsed = double.tryParse(incomeController.text.trim());
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid monthly income.")),
      );
      return;
    }
    _buildPlanFromIncome(parsed);
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

    // ✅ keep users/{uid}.income synced too
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "income": monthlyIncome,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Budget saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Budget Setup"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
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
                ...categoryBudget.entries.map(
                  (e) => _buildCategoryTile(e.key, e.value),
                ),
                const SizedBox(height: 24),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Income (Auto from Add Income)",
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
                onPressed: _onCreatePlanPressed,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text("Create Plan (50/30/20)"),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        ),
      ),
    );
  }

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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(category),
        subtitle: Text("Priority: ${categoryPriorityLabel[category] ?? "Low"}"),
        trailing: Text(
          "Rs ${amount.toStringAsFixed(0)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

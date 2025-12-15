import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'your_budget_screen.dart'; // Import the YourBudgetsScreen

// --- THEME COLOR DEFINITIONS ---
const Color kStormyTeal = Color(0xFF156064); 
const Color kCoralGlow = Color(0xFFFB8F67); 
const Color _kAccentColor = kStormyTeal; 
const Color _kDangerColor = kCoralGlow;
// -------------------------------

/// ---------------- ENUM ----------------
enum BudgetPeriodType {
  monthly,
  daily,
  custom,
}

/// ---------------- SCREEN ----------------
class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  // ... (existing state variables)
  bool loading = false;
  bool isEditMode = false;

  BudgetPeriodType selectedPeriod = BudgetPeriodType.monthly;
  int customDays = 7;
  String? editingBudgetKey;

  final Map<String, TextEditingController> categoryControllers = {};
  final Map<String, double> categoryBudget = {};

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
  // ... (existing _generatePeriodKey, _loadExistingBudget, _saveBudget, _deleteBudget, _toast methods)
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

// In budget_setup_screen.dart

// ---------------- LOAD EXISTING ----------------
// Renaming the parameter to docId to be clearer about its purpose
Future<void> _loadExistingBudget(String docId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("budgets")
      // *** FIX 2: Use docId (which is the result from the previous screen) ***
      .doc(docId) 
      .get();
      
  // Add a check in case the document wasn't found
  if (!doc.exists || doc.data() == null) {
    _toast("Error: Budget document not found for editing.");
    return;
  }

  final data = doc.data()!;
  
  // Ensure all controllers are reset if we are loading a new budget key
  for (final c in categoryControllers.values) {
    c.text = "";
  }

  // ... (rest of the loading logic is fine) ...
  final Map<String, dynamic> map =
      Map<String, dynamic>.from(data['categoryBudget']);

  for (final cat in categories) {
    // This line should correctly populate the text field controllers
    final amount = map[cat];
    if (amount != null) {
      // Use toStringAsFixed(0) or just toString() for clean display, 
      // ensuring it's a string.
      categoryControllers[cat]!.text = amount.toString();
    } else {
       categoryControllers[cat]!.text = "";
    }
  }

  // Determine the period type from the loaded data for display purposes
  BudgetPeriodType loadedPeriodType;
  switch(data['periodType']) {
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
    // Set the editingBudgetKey to the docId for delete/save operations
    editingBudgetKey = docId; 
    selectedPeriod = loadedPeriodType; // Update the selector
    customDays = data['periodDays'] ?? 7;
  });

  _toast("Editing budget: ${data['periodKey'] ?? docId}");
}

// And update the _viewOldBudgets function to pass the result correctly:
// 🌟 NEW: Function to handle navigation to YourBudgetsScreen
Future<void> _viewOldBudgets() async {
  final result = await Navigator.push(
   context,
   MaterialPageRoute(builder: (context) => const YourBudgetsScreen()),
  );
  
  // result is now the Firestore docId
  if (result is String) {
   // Do not update state here, _loadExistingBudget will call setState
   await _loadExistingBudget(result); 
  } 
}
  // ---------------- SAVE ----------------
  Future<void> _saveBudget() async {
    categoryBudget.clear();

    for (final cat in categories) {
      final value =
          double.tryParse(categoryControllers[cat]!.text.trim());
      if (value != null && value > 0) {
        categoryBudget[cat] = value;
      }
    }

    if (categoryBudget.isEmpty) {
      _toast("Please enter at least one category budget");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final periodKey = editingBudgetKey ?? _generatePeriodKey(now); // Use existing key if editing

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("budgets")
        .doc(periodKey);

    if (!isEditMode) {
      final exists = await docRef.get();
      if (exists.exists) {
        // Prevent accidental overwrite if not explicitly editing
        _toast("Budget for this period already exists. Load it to edit.");
        await _loadExistingBudget(periodKey);
        return;
      }
    }

    setState(() => loading = true);

    await docRef.set({
      "periodType": selectedPeriod.name,
      "periodDays":
          selectedPeriod == BudgetPeriodType.custom ? customDays : null,
      "periodKey": periodKey,
      "categoryBudget": categoryBudget,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => loading = false);

    _toast(isEditMode ? "Budget updated" : "Budget created");
    Navigator.pop(context);
  }

  // ---------------- DELETE ----------------
  Future<void> _deleteBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || editingBudgetKey == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("budgets")
        .doc(editingBudgetKey!)
        .delete();

    _toast("Budget deleted");
    Navigator.pop(context);
  }
  
  // ---------------- UI ----------------
  // 🌟 NEW: Function to handle navigation to YourBudgetsScreen


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 THEMED APP BAR
      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Budget" : "Set Budget",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _kAccentColor, // Stormy Teal
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _kAccentColor))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🌟 NEW: View Old Budgets Button
                _buildViewOldBudgetsButton(),
                const SizedBox(height: 16),
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                const Text(
                  "Category Budgets",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...categories.map(_buildCategoryTile).toList(),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 THEMED SAVE BUTTON
            ElevatedButton(
              onPressed: loading ? null : _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccentColor, // Stormy Teal
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isEditMode ? "Update Budget" : "Save Budget", style: const TextStyle(fontSize: 16)),
            ),
            if (isEditMode)
              // 🔹 THEMED DELETE BUTTON
              TextButton(
                onPressed: _deleteBudget,
                child: const Text(
                  "Delete Budget",
                  style: TextStyle(color: _kDangerColor), // Coral Glow for danger
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- VIEW OLD BUTTON ----------------
  Widget _buildViewOldBudgetsButton() {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: _viewOldBudgets,
        icon: const Icon(Icons.history, size: 20),
        label: const Text("View/Edit Old Budgets"),
        style: OutlinedButton.styleFrom(
          foregroundColor: _kAccentColor, // Stormy Teal
          side: const BorderSide(color: _kAccentColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ---------------- PERIOD SELECTOR ----------------
  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Budget Period",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            // 🔹 THEMED DROPDOWN
            DropdownButtonFormField<BudgetPeriodType>(
              value: selectedPeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: _kAccentColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: BudgetPeriodType.monthly,
                    child: Text("Monthly")),
                DropdownMenuItem(
                    value: BudgetPeriodType.daily, child: Text("Daily")),
                DropdownMenuItem(
                    value: BudgetPeriodType.custom,
                    child: Text("Custom Days")),
              ],
              onChanged: (v) {
                setState(() {
                  selectedPeriod = v!;
                  // Reset edit mode when changing period type
                  isEditMode = false;
                  editingBudgetKey = null;
                  // Clear controllers to start fresh
                  for (final c in categoryControllers.values) {
                    c.clear();
                  }
                });
              },
            ),
            if (selectedPeriod == BudgetPeriodType.custom) ...[
              const SizedBox(height: 12),
              // 🔹 THEMED TEXT FIELD
              TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: customDays.toString()),
                decoration: InputDecoration(
                  labelText: "Number of days",
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
  Widget _buildCategoryTile(String category) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(category, style: const TextStyle(color: Colors.black87)),
        trailing: SizedBox(
          width: 120,
          // 🔹 THEMED TEXT FIELD
          child: TextField(
            controller: categoryControllers[category],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixText: "Rs ",
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
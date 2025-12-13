import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Theme Colors ---
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kErrorColor = Color(0xFFF44336);
const Color kExpenseColor = Color(0xFFE53935);

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String selectedCategory = "Food";
  bool loading = false;

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Healthcare",
    "Entertainment",
    "Education",
    "Rent",
    "Travel",
    "Other",
  ];

  // ---------------- ADD EXPENSE ----------------
  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final uid = user.uid;
    final amount = double.parse(amountCtrl.text.trim());
    final now = DateTime.now();

    try {
      final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

      // Ensure balance exists
      final snap = await userDoc.get();
      if (!snap.exists ||
          !(snap.data() as Map<String, dynamic>)
              .containsKey('balance')) {
        await userDoc.set({
          "balance": {
            "totalBalance": 0.0,
            "monthlyIncome": 0.0,
            "monthlyExpense": 0.0,
          }
        }, SetOptions(merge: true));
      }

      // Save to transactions (MAIN SOURCE)
      await userDoc.collection("transactions").add({
        "title": titleCtrl.text.trim(),
        "amount": amount,
        "type": "expense",
        "category": selectedCategory,
        "notes": notesCtrl.text.trim(),
        "date": now,
      });

      // Update balance
      await userDoc.update({
        "balance.totalBalance": FieldValue.increment(-amount),
        "balance.monthlyExpense": FieldValue.increment(amount),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expense added successfully"),
            backgroundColor: kExpenseColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add expense: $e"),
          backgroundColor: kErrorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Add Expense",
            style: TextStyle(color: Colors.white)),
        backgroundColor: kExpenseColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // TITLE
                    _field(
                      controller: titleCtrl,
                      label: "Title",
                      icon: Icons.title,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter title" : null,
                    ),
                    const SizedBox(height: 15),

                    // AMOUNT
                    _field(
                      controller: amountCtrl,
                      label: "Amount",
                      icon: Icons.money_off,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Enter amount";
                        }
                        if (double.tryParse(v) == null) {
                          return "Invalid number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // CATEGORY
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedCategory = v!),
                      decoration: _decoration(
                        "Category",
                        Icons.category,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // NOTES (OPTIONAL)
                    _field(
                      controller: notesCtrl,
                      label: "Notes (optional)",
                      icon: Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _addExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kExpenseColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Add Expense",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------- HELPERS ----------------
  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon, color: kExpenseColor),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: _decoration(label, icon),
    );
  }
}

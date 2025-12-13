import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Theme Colors ---
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kPrimaryDarkColor = Color(0xFF5A52D5);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kSuccessColor = Color(0xFF4CAF50);
const Color kErrorColor = Color(0xFFF44336);

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  String selectedCategory = "Salary";
  bool loading = false;

  final List<String> categories = [
    "Salary",
    "Freelance",
    "Business",
    "Bonus",
    "Gift",
    "Other"
  ];

  Future<void> _addIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      setState(() => loading = false);
      return;
    }

    final uid = user.uid;
    final amount = double.parse(amountCtrl.text.trim());

    try {
      final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

      // Ensure balance exists
      final snap = await userDoc.get();
      if (!snap.exists || !(snap.data() as Map<String, dynamic>).containsKey('balance')) {
        await userDoc.set({
          "balance": {
            "totalBalance": 0.0,
            "monthlyIncome": 0.0,
            "monthlyExpense": 0.0,
          }
        }, SetOptions(merge: true));
      }

      // Save income
      await userDoc.collection("incomes").add({
        "amount": amount,
        "category": selectedCategory,
        "description": descriptionCtrl.text.trim(),
        "date": DateTime.now(),
      });

      // Save transaction
      await userDoc.collection("transactions").add({
        "amount": amount,
        "type": "income",
        "category": selectedCategory,
        "description": descriptionCtrl.text.trim(),
        "date": DateTime.now(),
      });

      // Update balance
      await userDoc.update({
        "balance.totalBalance": FieldValue.increment(amount),
        "balance.monthlyIncome": FieldValue.increment(amount),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Income added successfully!"),
            backgroundColor: kSuccessColor,
          ),
        );
        Navigator.pop(context, true); // Refresh dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add income: $e"),
            backgroundColor: kErrorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Add Income",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryDarkColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      controller: amountCtrl,
                      label: "Amount",
                      icon: Icons.attach_money,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter amount";
                        if (double.tryParse(v) == null) return "Invalid number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: const TextStyle(color: kTextColor)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                      decoration: _inputDecoration.copyWith(
                        labelText: "Category",
                        prefixIcon: const Icon(Icons.category, color: kPrimaryColor),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: descriptionCtrl,
                      label: "Description (optional)",
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _addIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccessColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Add Income",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  final InputDecoration _inputDecoration = const InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: kPrimaryColor, width: 2),
    ),
    labelStyle: TextStyle(color: Color(0xFF718096)),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    filled: true,
    fillColor: Colors.white,
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(color: kTextColor, fontSize: 16),
      decoration: _inputDecoration.copyWith(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 8.0),
          child: Icon(icon, color: kPrimaryColor, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

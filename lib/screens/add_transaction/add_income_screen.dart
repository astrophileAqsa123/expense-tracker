import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      return;
    }

    String uid = user.uid;
    double amount = double.parse(amountCtrl.text.trim());

    try {
      final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

      // Ensure balance map exists (Good practice!)
      DocumentSnapshot snap = await userDoc.get();
      if (!snap.exists || !(snap.data() as Map<String, dynamic>).containsKey('balance')) {
        await userDoc.set({
          "balance": {
            "totalBalance": 0.0,
            "monthlyIncome": 0.0,
            "monthlyExpense": 0.0, // Added for completeness
          }
        }, SetOptions(merge: true));
      }

      // 1️⃣ Save all incomes in:  users → uid → incomes
      await userDoc.collection("incomes").add({
        "amount": amount,
        "category": selectedCategory,
        "description": descriptionCtrl.text.trim(),
        "date": DateTime.now(),
      });

      // 2️⃣ Also save inside transactions (dashboard history)
      await userDoc.collection("transactions").add({
        "amount": amount,
        "type": "income",
        "category": selectedCategory,
        "description": descriptionCtrl.text.trim(),
        "date": DateTime.now(),
      });

      // 3️⃣ Update financial balance
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

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add income: $e"),
          backgroundColor: kErrorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Add Income", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        // --- Improved AppBar Theming (using dashboard gradient) ---
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
        // --- End Improved AppBar Theming ---
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // --- Styled Amount Input ---
                    _buildStyledTextFormField(
                      controller: amountCtrl,
                      labelText: "Amount",
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter amount";
                        if (double.tryParse(v) == null) return "Invalid number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // --- Styled Category Dropdown ---
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(color: kTextColor)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                      decoration: _inputDecoration.copyWith(
                        labelText: "Category",
                        prefixIcon: const Icon(Icons.category, color: kPrimaryColor),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- Styled Description Input ---
                    _buildStyledTextFormField(
                      controller: descriptionCtrl,
                      labelText: "Description (optional)",
                      prefixIcon: Icons.description,
                    ),
                    const SizedBox(height: 30),

                    // --- Styled Submit Button (Green for Income) ---
                    ElevatedButton(
                      onPressed: _addIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSuccessColor, // Use success color for income
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 5, // Add subtle shadow for lift
                      ),
                      child: const Text(
                        "Add Income",
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

  // --- Reusable TextField Styling ---
  final InputDecoration _inputDecoration = const InputDecoration(
    // Base border definition
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    // Border when not focused
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5), // Light grey border
    ),
    // Border when focused (Primary Color)
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: kPrimaryColor, width: 2),
    ),
    labelStyle: TextStyle(color: Color(0xFF718096)), // Subtle label color
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    filled: true,
    fillColor: Colors.white, // Ensures fields stand out against background
  );

  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: kTextColor, fontSize: 16),
      decoration: _inputDecoration.copyWith(
        labelText: labelText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 8.0),
          child: Icon(prefixIcon, color: kPrimaryColor, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

<<<<<<< HEAD
import '../../l10n/app_localizations.dart';

// --- THEME COLOR DEFINITIONS (Stormy Teal Theme) ---
const Color kStormyTeal = Color(0xFF156064);
const Color kMintLeaf = Color(0xFF00C49A);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
=======
// --- Theme Colors ---
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kPrimaryDarkColor = Color(0xFF5A52D5);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kSuccessColor = Color(0xFF4CAF50);
>>>>>>> 0f10098 (Your commit message)
const Color kErrorColor = Color(0xFFF44336);

const Color _kIncomePrimary = kMintLeaf;
const Color _kFocusColor = kStormyTeal;
// -------------------------------

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // Keep RAW keys (do not translate stored values)
  String selectedCategory = "Salary";
  bool loading = false;

  // RAW category keys
  final List<String> categories = [
    "Salary",
    "Freelance",
    "Business",
    "Bonus",
    "Gift",
    "Other"
  ];

  @override
  void dispose() {
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  // Localized label for income categories (UI only)
  String _incomeCategoryLabel(AppLocalizations t, String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'salary':
        return t.salary;
      case 'freelance':
        return t.freelance;
      case 'business':
        return t.business;
      case 'bonus':
        return t.bonus;
      case 'gift':
        return t.gift;
      case 'other':
      default:
        return t.other;
    }
  }

  Future<void> _addIncome() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
<<<<<<< HEAD
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.userNotLoggedIn)),
        );
        setState(() => loading = false);
      }
=======
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      setState(() => loading = false);
>>>>>>> 0f10098 (Your commit message)
      return;
    }

    final uid = user.uid;
    final amount = double.parse(amountCtrl.text.trim());

    try {
      final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

<<<<<<< HEAD
      // Ensure user/balance exists
      final snap = await userDoc.get();
      final data = snap.data() as Map<String, dynamic>?;

      if (!snap.exists || data == null || !data.containsKey('balance')) {
=======
      // Ensure balance exists
      final snap = await userDoc.get();
      if (!snap.exists || !(snap.data() as Map<String, dynamic>).containsKey('balance')) {
>>>>>>> 0f10098 (Your commit message)
        await userDoc.set({
          "balance": {
            "totalBalance": 0.0,
            "monthlyIncome": 0.0,
            "monthlyExpense": 0.0,
          }
        }, SetOptions(merge: true));
      }

<<<<<<< HEAD
      // Save income into "transactions"
=======
      // Save income
      await userDoc.collection("incomes").add({
        "amount": amount,
        "category": selectedCategory,
        "description": descriptionCtrl.text.trim(),
        "date": DateTime.now(),
      });

      // Save transaction
>>>>>>> 0f10098 (Your commit message)
      await userDoc.collection("transactions").add({
        "amount": amount,
        "type": "income",
        "category": selectedCategory, // RAW key saved
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
          SnackBar(
            content: Text(t.incomeAddedSuccessfully),
            backgroundColor: _kIncomePrimary,
          ),
        );
<<<<<<< HEAD
        Navigator.pop(context, true);
=======
        Navigator.pop(context, true); // Refresh dashboard
>>>>>>> 0f10098 (Your commit message)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
<<<<<<< HEAD
            content: Text('${t.failedToAddIncome}: $e'),
=======
            content: Text("Failed to add income: $e"),
>>>>>>> 0f10098 (Your commit message)
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
<<<<<<< HEAD
        title: Text(
          t.addIncome,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _kIncomePrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
=======
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
>>>>>>> 0f10098 (Your commit message)
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _kIncomePrimary))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                      controller: amountCtrl,
<<<<<<< HEAD
                      label: t.amount,
=======
                      label: "Amount",
>>>>>>> 0f10098 (Your commit message)
                      icon: Icons.attach_money,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return t.enterAmount;
                        if (double.tryParse(v.trim()) == null) return t.invalidNumber;
                        if (double.parse(v.trim()) <= 0) return t.amountMustBeGreaterThanZero;
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
<<<<<<< HEAD
                          .map(
                            (raw) => DropdownMenuItem(
                              value: raw,
                              child: Text(
                                _incomeCategoryLabel(t, raw),
                                style: const TextStyle(color: kTextColor),
                              ),
                            ),
                          )
=======
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: const TextStyle(color: kTextColor)),
                              ))
>>>>>>> 0f10098 (Your commit message)
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                      decoration: _inputDecoration.copyWith(
                        labelText: t.category,
                        prefixIcon: const Icon(Icons.category, color: _kIncomePrimary),
                      ),
                      iconEnabledColor: _kIncomePrimary,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: descriptionCtrl,
<<<<<<< HEAD
                      label: t.descriptionOptional,
=======
                      label: "Description (optional)",
>>>>>>> 0f10098 (Your commit message)
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: loading ? null : _addIncome,
                      style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                        backgroundColor: _kIncomePrimary,
                        disabledBackgroundColor: _kIncomePrimary.withOpacity(0.5),
=======
                        backgroundColor: kSuccessColor,
>>>>>>> 0f10098 (Your commit message)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
<<<<<<< HEAD
                        elevation: 2,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              t.addIncome,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
=======
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
>>>>>>> 0f10098 (Your commit message)
                    ),
                  ],
                ),
              ),
            ),
    );
  }

<<<<<<< HEAD
  // THEMED INPUT DECORATION
  final InputDecoration _inputDecoration = const InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
=======
  final InputDecoration _inputDecoration = const InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
>>>>>>> 0f10098 (Your commit message)
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: _kFocusColor, width: 2),
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
<<<<<<< HEAD
          child: Icon(icon, color: _kIncomePrimary, size: 24),
=======
          child: Icon(icon, color: kPrimaryColor, size: 24),
>>>>>>> 0f10098 (Your commit message)
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

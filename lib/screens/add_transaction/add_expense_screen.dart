import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../provider/transaction_provider.dart';
import '../../l10n/app_localizations.dart';

// --- THEME COLOR DEFINITIONS (Stormy Teal Theme) ---
const Color kStormyTeal = Color(0xFF156064);
const Color kCoralGlow = Color(0xFFFB8F67);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kErrorColor = Color(0xFFF44336);

const Color _kExpenseAccent = kCoralGlow;
const Color _kFocusColor = kStormyTeal;
// -------------------------------

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

  // Keep RAW keys (do not translate these)
  String selectedCategory = "Food";
  bool loading = false;

  // RAW category keys
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

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  // --------- Category label helper (localized display) ----------
  String _categoryLabel(AppLocalizations t, String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'food':
        return t.food;
      case 'transport':
        return t.transport;
      case 'shopping':
        return t.shopping;
      case 'bills':
        return t.bills;
      case 'healthcare':
      case 'health':
        return t.health;
      case 'entertainment':
      case 'entertain':
        return t.entertainment;
      case 'education':
        return t.education;
      case 'rent':
        return t.rent;
      case 'travel':
        return t.travel;
      case 'other':
      default:
        return t.other;
    }
  }

  // ✅ Get available balance from Firestore: users/{uid}.balance.totalBalance
  Future<double> _getTotalBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final data = doc.data();
    if (data == null) return 0.0;

    final balance = data['balance'] as Map<String, dynamic>?;
    final totalBalance = (balance?['totalBalance'] as num?)?.toDouble() ?? 0.0;

    return totalBalance;
  }

  // ✅ Popup when expense > balance
  Future<void> _showOverLimitDialog({
    required double balance,
    required double expense,
  }) async {
    final t = AppLocalizations.of(context)!;
    final diff = expense - balance;

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.expenseFailedTitle),
        content: Text(
          t.expenseOverBalanceMessage(
            balance.toStringAsFixed(2),
            expense.toStringAsFixed(2),
            diff.toStringAsFixed(2),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    final expenseAmount = double.parse(amountCtrl.text.trim());

    setState(() => loading = true);

    try {
      // ✅ check balance before adding expense
      final currentBalance = await _getTotalBalance();

      if (expenseAmount > currentBalance) {
        if (!mounted) return;
        await _showOverLimitDialog(balance: currentBalance, expense: expenseAmount);
        setState(() => loading = false);
        return;
      }

      final transactionProvider = context.read<TransactionProvider>();

      await transactionProvider.addExpense(
        title: titleCtrl.text.trim(),
        amount: expenseAmount,
        category: selectedCategory, // RAW key saved
        notes: notesCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.expenseAddedSuccessfully),
            backgroundColor: _kExpenseAccent,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.failedToAddExpense}: $e'),
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
        title: Text(t.addExpense, style: const TextStyle(color: Colors.white)),
        backgroundColor: _kExpenseAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: _kExpenseAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _field(
                      titleCtrl,
                      t.title,
                      Icons.title,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? t.enterTitle : null,
                    ),
                    const SizedBox(height: 15),
                    _field(
                      amountCtrl,
                      t.amount,
                      Icons.money_off,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return t.enterAmount;
                        final n = double.tryParse(v.trim());
                        if (n == null) return t.invalidNumber;
                        if (n <= 0) return t.amountMustBeGreaterThanZero;
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map(
                            (raw) => DropdownMenuItem(
                              value: raw,
                              child: Text(
                                _categoryLabel(t, raw),
                                style: const TextStyle(color: kTextColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                      decoration: _decoration(t.category, Icons.category),
                      iconEnabledColor: _kExpenseAccent,
                    ),
                    const SizedBox(height: 15),

                    _field(
                      notesCtrl,
                      t.notesOptional,
                      Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: loading ? null : _submitExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kExpenseAccent,
                        disabledBackgroundColor: _kExpenseAccent.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              t.addExpense,
                              style: const TextStyle(
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

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _kFocusColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kFocusColor, width: 2),
      ),
      prefixIcon: Icon(icon, color: _kExpenseAccent),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: kTextColor),
      decoration: _decoration(label, icon),
    );
  }
}

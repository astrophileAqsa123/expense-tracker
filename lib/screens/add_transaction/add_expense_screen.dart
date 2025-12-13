import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/transaction_provider.dart';

// Theme colors
const Color kExpenseColor = Color(0xFFE53935);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kErrorColor = Color(0xFFF44336);

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

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await context.read<TransactionProvider>().addExpense(
            title: titleCtrl.text.trim(),
            amount: double.parse(amountCtrl.text.trim()),
            category: selectedCategory,
            notes: notesCtrl.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expense added successfully"),
            backgroundColor: kExpenseColor,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add expense: $e"),
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
        title: const Text("Add Expense", style: TextStyle(color: Colors.white)),
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
                    _field(titleCtrl, "Title", Icons.title,
                        validator: (v) => v == null || v.isEmpty ? "Enter title" : null),
                    const SizedBox(height: 15),
                    _field(amountCtrl, "Amount", Icons.money_off,
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Enter amount";
                          if (double.tryParse(v) == null) return "Invalid number";
                          return null;
                        }),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedCategory = v!),
                      decoration: _decoration("Category", Icons.category),
                    ),
                    const SizedBox(height: 15),
                    _field(notesCtrl, "Notes (optional)", Icons.notes, maxLines: 3),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitExpense,
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon, color: kExpenseColor),
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
      decoration: _decoration(label, icon),
    );
  }
}

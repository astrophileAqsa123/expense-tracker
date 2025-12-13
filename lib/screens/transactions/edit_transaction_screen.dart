import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final String transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Transaction state
  String selectedType = "expense";
  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

  bool loading = true;

  final List<String> expenseCategories = [
    "Food",
    "Travel",
    "Shopping",
    "Bills",
    "Entertainment",
    "Health",
    "Other",
  ];

  final List<String> incomeCategories = [
    "Salary",
    "Bonus",
    "Gift",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  /// Load transaction details from Firestore
  Future<void> _loadTransaction() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return setState(() => loading = false);

    try {
      final doc = await _db
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .doc(widget.transactionId)
          .get();

      if (!doc.exists || doc.data() == null) return setState(() => loading = false);

      final data = doc.data()!;

      titleController.text = data["title"]?.toString() ?? "";
      amountController.text = data["amount"]?.toString() ?? "";
      notesController.text = data["notes"]?.toString() ?? "";

      selectedType = data["type"] == "income" ? "income" : "expense";
      final validCategories = selectedType == "expense" ? expenseCategories : incomeCategories;
      selectedCategory = validCategories.contains(data["category"])
          ? data["category"]
          : validCategories.first;

      if (data["date"] is Timestamp) {
        selectedDate = (data["date"] as Timestamp).toDate();
      }
    } catch (_) {
      // Handle silently
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Update transaction in Firestore
  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .doc(widget.transactionId)
        .update({
      "title": titleController.text.trim(),
      "amount": double.tryParse(amountController.text.trim()) ?? 0,
      "category": selectedCategory,
      "type": selectedType,
      "date": selectedDate,
      "notes": notesController.text.trim(),
    });

    if (mounted) Navigator.pop(context, true); // Return true to refresh dashboard
  }

  /// Delete transaction
  Future<void> _deleteTransaction() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .doc(widget.transactionId)
        .delete();

    if (mounted) Navigator.pop(context, true);
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = selectedType == "expense" ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaction"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: const Text("Are you sure you want to delete this transaction?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                  ],
                ),
              );
              if (confirm == true) _deleteTransaction();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter amount";
                  if (double.tryParse(val.replaceAll(',', '')) == null) return "Invalid amount";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "Type"),
                items: const [
                  DropdownMenuItem(value: "expense", child: Text("Expense")),
                  DropdownMenuItem(value: "income", child: Text("Income")),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    selectedType = val;
                    selectedCategory = (val == "expense" ? expenseCategories : incomeCategories).first;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val ?? categories.first),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text("Date: ${DateFormat("yyyy-MM-dd").format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_month),
                onTap: _selectDate,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _updateTransaction,
                child: const Text("Update Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

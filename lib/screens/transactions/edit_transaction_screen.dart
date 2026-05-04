import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// --- THEME COLOR DEFINITIONS (Stormy Teal Theme) ---
const Color kStormyTeal = Color(0xFF156064); // Primary Accent/AppBar/Button
const Color kCoralGlow = Color(0xFFFB8F67); // Expense Color
const Color kMintLeaf = Color(0xFF00C49A); // Income Color
const Color kBackgroundColor = Color(0xFFF5F7FA); // Screen Background
const Color kTextColor = Color(0xFF2D3748); // Dark text
const Color kDeleteColor = Color(0xFFF44336); // Error/Delete
const Color kBorderColor = Color(0xFFE2E8F0); // Input Border
// -------------------------------

class EditTransactionScreen extends StatefulWidget {
 final String transactionId;

<<<<<<< HEAD
 const EditTransactionScreen({super.key, required this.transactionId});

 @override
 State<EditTransactionScreen> createState() => _EditTransactionScreenState();
=======
  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
>>>>>>> 0f10098 (Your commit message)
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
 final _formKey = GlobalKey<FormState>();
 final FirebaseFirestore _db = FirebaseFirestore.instance;
 final FirebaseAuth _auth = FirebaseAuth.instance;

<<<<<<< HEAD
 // Controllers
 final TextEditingController titleController = TextEditingController();
 final TextEditingController amountController = TextEditingController();
 final TextEditingController notesController = TextEditingController();

 // Transaction state (Current values)
 String selectedType = "expense";
 String selectedCategory = "Food";
 DateTime selectedDate = DateTime.now();
 
 // Original transaction data for balance reversal logic
 Map<String, dynamic>? _originalTransactionData;
=======
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Transaction state
  String selectedType = "expense";
  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();
>>>>>>> 0f10098 (Your commit message)

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

 @override
 void dispose() {
  titleController.dispose();
  amountController.dispose();
  notesController.dispose();
  super.dispose();
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

   if (!doc.exists || doc.data() == null) {
    return setState(() => loading = false);
   }

   final data = doc.data()!;
   _originalTransactionData = Map.from(data); // Save original for reversal

   titleController.text = data["title"]?.toString() ?? "";
   amountController.text = (data["amount"] as num?)?.toString() ?? "";
   notesController.text = data["notes"]?.toString() ?? "";

   selectedType = data["type"] == "income" ? "income" : "expense";
   final validCategories = selectedType == "expense" ? expenseCategories : incomeCategories;
   selectedCategory = validCategories.contains(data["category"])
     ? data["category"]
     : validCategories.first;

   if (data["date"] is Timestamp) {
    selectedDate = (data["date"] as Timestamp).toDate();
   }
  } catch (e) {
   debugPrint("Error loading transaction: $e");
   // Optionally show error to user
  } finally {
   if (mounted) setState(() => loading = false);
  }
 }

 /// Update transaction and re-calculate balance
 Future<void> _updateTransaction() async {
  if (!_formKey.currentState!.validate() || _originalTransactionData == null) return;

  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  final newAmount = double.tryParse(amountController.text.trim()) ?? 0;
  
  // Original values
  final originalAmount = (_originalTransactionData!["amount"] as num?)?.toDouble() ?? 0.0;
  final originalType = _originalTransactionData!["type"]?.toString() ?? "expense";

  final batch = _db.batch();
  final userDocRef = _db.collection("users").doc(uid);
  final transactionDocRef = userDocRef.collection("transactions").doc(widget.transactionId);

  // 1. Reverse the effect of the ORIGINAL transaction on the balance
  if (originalType == "income") {
   // Subtract the original income
   batch.update(userDocRef, {
    "balance.totalBalance": FieldValue.increment(-originalAmount),
    "balance.monthlyIncome": FieldValue.increment(-originalAmount),
   });
  } else { // expense
   // Add back the original expense
   batch.update(userDocRef, {
    "balance.totalBalance": FieldValue.increment(originalAmount),
    "balance.monthlyExpense": FieldValue.increment(-originalAmount),
   });
  }

<<<<<<< HEAD
  // 2. Apply the effect of the NEW transaction on the balance
  if (selectedType == "income") {
   batch.update(userDocRef, {
    "balance.totalBalance": FieldValue.increment(newAmount),
    "balance.monthlyIncome": FieldValue.increment(newAmount),
   });
  } else { // expense
   batch.update(userDocRef, {
    "balance.totalBalance": FieldValue.increment(-newAmount),
    "balance.monthlyExpense": FieldValue.increment(newAmount),
   });
  }
  
  // 3. Update the transaction document
  batch.update(transactionDocRef, {
   "title": titleController.text.trim(),
   "amount": newAmount,
   "category": selectedCategory,
   "type": selectedType,
   "date": selectedDate,
   "notes": notesController.text.trim(),
  });
=======
  /// Load transaction details from Firestore
  Future<void> _loadTransaction() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return setState(() => loading = false);
>>>>>>> 0f10098 (Your commit message)

  await batch.commit();

<<<<<<< HEAD
  if (mounted) {
   Navigator.pop(context, true); // Return true to refresh previous screens
   ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Transaction updated successfully!")),
   );
  }
 }
=======
      if (!doc.exists || doc.data() == null) return setState(() => loading = false);
>>>>>>> 0f10098 (Your commit message)

 /// Delete transaction and update balance
 Future<void> _deleteTransaction() async {
  if (_originalTransactionData == null) return;
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

<<<<<<< HEAD
  final originalAmount = (_originalTransactionData!["amount"] as num?)?.toDouble() ?? 0.0;
  final originalType = _originalTransactionData!["type"]?.toString() ?? "expense";

  final batch = _db.batch();
  final userDocRef = _db.collection("users").doc(uid);
  final transactionDocRef = userDocRef.collection("transactions").doc(widget.transactionId);

  // 1. Reverse the effect of the transaction on the balance
  if (originalType == "income") {
   // Subtract the income
   batch.update(userDocRef, {
    "balance.totalBalance": FieldValue.increment(-originalAmount),
    "balance.monthlyIncome": FieldValue.increment(-originalAmount),
   });
  } else { // expense
   // Add back the expense
   batch.update(userDocRef, {
    "balance.totalBalance": FieldValue.increment(originalAmount),
    "balance.monthlyExpense": FieldValue.increment(-originalAmount),
   });
  }

  // 2. Delete the transaction document
  batch.delete(transactionDocRef);

  await batch.commit();
  
  if (mounted) {
   Navigator.pop(context, true);
   ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Transaction deleted.")),
   );
=======
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
>>>>>>> 0f10098 (Your commit message)
  }
 }

<<<<<<< HEAD
 /// Show date picker
 Future<void> _selectDate() async {
  final picked = await showDatePicker(
   context: context,
   initialDate: selectedDate,
   firstDate: DateTime(2020),
   lastDate: DateTime(2100),
   builder: (context, child) {
    return Theme(
     data: ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
       primary: kStormyTeal, // Header background color
       onPrimary: Colors.white, // Header text color
       onSurface: kTextColor, // Body text color
      ),
      textButtonTheme: TextButtonThemeData(
       style: TextButton.styleFrom(foregroundColor: kStormyTeal),
      ),
     ),
     child: child!,
    );
   },
  );

  if (picked != null) setState(() => selectedDate = picked);
 }

 @override
 Widget build(BuildContext context) {
  if (loading) {
   return const Scaffold(
    body: Center(child: CircularProgressIndicator(color: kStormyTeal)),
   );
  }

  final categories = selectedType == "expense" ? expenseCategories : incomeCategories;

  return Scaffold(
   backgroundColor: kBackgroundColor,
   appBar: AppBar(
    title: const Text("Edit Transaction", style: TextStyle(color: Colors.white)),
    backgroundColor: kStormyTeal,
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
    actions: [
     IconButton(
      icon: const Icon(Icons.delete, color: kDeleteColor),
      onPressed: () async {
       final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
         title: const Text("Confirm Delete"),
         content: const Text("Are you sure you want to delete this transaction? This cannot be undone."),
         actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: kTextColor))),
          ElevatedButton(
           style: ElevatedButton.styleFrom(backgroundColor: kDeleteColor),
           onPressed: () => Navigator.pop(context, true), 
           child: const Text("Delete", style: TextStyle(color: Colors.white)),
=======
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
>>>>>>> 0f10098 (Your commit message)
          ),
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
       // Title
       _buildThemedTextFormField(
        controller: titleController,
        labelText: "Title",
        icon: Icons.title,
        validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
       ),
       const SizedBox(height: 15),

       // Amount
       _buildThemedTextFormField(
        controller: amountController,
        labelText: "Amount",
        icon: Icons.attach_money,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (val) {
         if (val == null || val.isEmpty) return "Enter amount";
         if (double.tryParse(val.replaceAll(',', '')) == null || double.parse(val) <= 0) return "Enter a valid positive amount";
         return null;
        },
       ),
       const SizedBox(height: 15),

       // Type Dropdown
       _buildThemedDropdownFormField<String>(
        labelText: "Type",
        value: selectedType,
        icon: Icons.swap_horiz,
        items: const [
         DropdownMenuItem(value: "expense", child: Text("Expense", style: TextStyle(color: kCoralGlow))),
         DropdownMenuItem(value: "income", child: Text("Income", style: TextStyle(color: kMintLeaf))),
        ],
        onChanged: (val) {
         if (val == null) return;
         setState(() {
          selectedType = val;
          // Reset category to the first valid one
          selectedCategory = (val == "expense" ? expenseCategories : incomeCategories).first;
         });
        },
       ),
       const SizedBox(height: 15),

       // Category Dropdown
       _buildThemedDropdownFormField<String>(
        labelText: "Category",
        value: selectedCategory,
        icon: Icons.list_alt,
        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => selectedCategory = val ?? categories.first),
       ),
       const SizedBox(height: 15),

       // Date Picker
       _buildDateListTile(),
       const SizedBox(height: 15),

       // Notes
       _buildThemedTextFormField(
        controller: notesController,
        labelText: "Notes/Description (Optional)",
        icon: Icons.description,
        maxLines: 3,
       ),
       const SizedBox(height: 30),

       // Update Button
       ElevatedButton(
        onPressed: _updateTransaction,
        style: ElevatedButton.styleFrom(
         backgroundColor: kStormyTeal,
         foregroundColor: Colors.white,
         padding: const EdgeInsets.symmetric(vertical: 16),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
         "Save Changes",
         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
       ),
      ],
     ),
    ),
   ),
  );
 }

 // --- THEMED WIDGETS ---

 Widget _buildThemedTextFormField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  int maxLines = 1,
 }) {
  return TextFormField(
   controller: controller,
   keyboardType: keyboardType,
   validator: validator,
   maxLines: maxLines,
   cursorColor: kStormyTeal,
   decoration: InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: kTextColor),
    prefixIcon: Icon(icon, color: kStormyTeal),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kStormyTeal, width: 2),
    ),
    errorBorder: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kDeleteColor, width: 2),
    ),
   ),
  );
 }

 Widget _buildThemedDropdownFormField<T>({
  required String labelText,
  required T value,
  required IconData icon,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?)? onChanged,
 }) {
  return DropdownButtonFormField<T>(
   value: value,
   onChanged: onChanged,
   decoration: InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: kTextColor),
    prefixIcon: Icon(icon, color: kStormyTeal),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: const BorderSide(color: kStormyTeal, width: 2),
    ),
   ),
   dropdownColor: Colors.white,
   items: items,
  );
 }

 Widget _buildDateListTile() {
  return Container(
   decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: kBorderColor),
   ),
   child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: const Icon(Icons.calendar_month, color: kStormyTeal),
    title: Text(
     "Date: ${DateFormat("yyyy-MM-dd").format(selectedDate)}",
     style: const TextStyle(color: kTextColor),
    ),
    trailing: const Icon(Icons.edit, color: kStormyTeal, size: 20),
    onTap: _selectDate,
   ),
  );
 }
}
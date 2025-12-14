import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/transaction_provider.dart';

// --- THEME COLOR DEFINITIONS (Stormy Teal Theme) ---
const Color kStormyTeal = Color(0xFF156064); 
const Color kCoralGlow = Color(0xFFFB8F67); // Used for Expense Accent/Primary
const Color kBackgroundColor = Color(0xFFF5F7FA); // Light background
const Color kTextColor = Color(0xFF2D3748); // Dark text
const Color kErrorColor = Color(0xFFF44336); // Red for error messages

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

 @override
 void dispose() {
  titleCtrl.dispose();
  amountCtrl.dispose();
  notesCtrl.dispose();
  super.dispose();
 }

Future<void> _submitExpense() async {
 if (!_formKey.currentState!.validate()) return;

 setState(() => loading = true);

 try {
  final transactionProvider = context.read<TransactionProvider>();

  await transactionProvider.addExpense(
   title: titleCtrl.text.trim(),
   amount: double.parse(amountCtrl.text.trim()),
   category: selectedCategory,
   notes: notesCtrl.text.trim(),
  );


  if (mounted) {
   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
     content: const Text("Expense added successfully"),
     backgroundColor: _kExpenseAccent, // Themed success background
    ),
   );
   Navigator.pop(context, true);
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
    // THEMED APP BAR
    title: const Text("Add Expense", style: TextStyle(color: Colors.white)),
    backgroundColor: _kExpenseAccent, // Coral Glow
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
   ),
   body: loading
     ? Center(child: CircularProgressIndicator(color: _kExpenseAccent))
     : Padding(
       padding: const EdgeInsets.all(20),
       child: Form(
        key: _formKey,
        child: ListView(
         children: [
          _field(
           titleCtrl,
           "Title",
           Icons.title,
           validator: (v) =>
             v == null || v.trim().isEmpty ? "Enter title" : null,
          ),
          const SizedBox(height: 15),
          _field(
           amountCtrl,
           "Amount",
           Icons.money_off,
           keyboard: TextInputType.number,
           validator: (v) {
            if (v == null || v.trim().isEmpty) return "Enter amount";
            final n = double.tryParse(v.trim());
            if (n == null) return "Invalid number";
            if (n <= 0) return "Amount must be > 0";
            return null;
           },
          ),
          const SizedBox(height: 15),
          // THEMED DROPDOWN
          DropdownButtonFormField<String>(
           value: selectedCategory,
           items: categories
             .map((c) =>
               DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: kTextColor))))
             .toList(),
           onChanged: (v) => setState(() => selectedCategory = v!),
           decoration: _decoration("Category", Icons.category),
           iconEnabledColor: _kExpenseAccent,
          ),
          const SizedBox(height: 15),
          _field(
           notesCtrl,
           "Notes (optional)",
           Icons.notes,
           maxLines: 3,
          ),
          const SizedBox(height: 30),
          // THEMED BUTTON
          ElevatedButton(
           onPressed: loading ? null : _submitExpense,
           style: ElevatedButton.styleFrom(
            backgroundColor: _kExpenseAccent, // Coral Glow
            disabledBackgroundColor: _kExpenseAccent.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
            ),
           ),
           child: loading 
           ? const SizedBox(
             width: 20, height: 20, 
             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
           : const Text(
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

 // THEMED DECORATION FUNCTION
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
    borderSide: const BorderSide(color: _kFocusColor, width: 2), // Stormy Teal Focus
   ),
   prefixIcon: Icon(icon, color: _kExpenseAccent), // Coral Glow icon
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
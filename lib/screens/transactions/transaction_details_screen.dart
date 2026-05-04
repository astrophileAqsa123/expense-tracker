import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../provider/currency_provider.dart';

import 'edit_transaction_screen.dart';

// --- THEME COLOR DEFINITIONS (Stormy Teal Theme) ---
const Color kStormyTeal = Color(0xFF156064); // Primary Accent/AppBar
const Color kCoralGlow = Color(0xFFFB8F67); // Expense Color
const Color kMintLeaf = Color(0xFF00C49A); // Income Color
const Color kBackgroundColor = Color(0xFFF5F7FA); // Light background
const Color kTextColor = Color(0xFF2D3748); // Dark text
const Color kDeleteColor = Color(0xFFF44336); // Error/Delete
const Color kInfoColor = Color(0xFF718096); // Secondary text/Label
// -------------------------------

class TransactionDetailsScreen extends StatefulWidget {
 final String transactionId;

<<<<<<< HEAD
 const TransactionDetailsScreen({super.key, required this.transactionId});

 @override
 State<TransactionDetailsScreen> createState() =>
   _TransactionDetailsScreenState();
=======
  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
>>>>>>> 0f10098 (Your commit message)
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
 final FirebaseFirestore _db = FirebaseFirestore.instance;
 final FirebaseAuth _auth = FirebaseAuth.instance;

 bool loading = true;
 Map<String, dynamic>? transactionData;

 @override
 void initState() {
  super.initState();
  _loadTransaction();
 }

 // ---------------- LOAD TRANSACTION ----------------
 Future<void> _loadTransaction() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

<<<<<<< HEAD
  setState(() => loading = true);

  try {
   final doc = await _db
     .collection("users")
     .doc(uid)
     .collection("transactions")
     .doc(widget.transactionId)
     .get();

   transactionData = doc.exists ? doc.data() : null;
  } catch (e) {
   debugPrint("Error loading transaction: $e");
   transactionData = null;
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text("Failed to load transaction details.")),
=======
    setState(() => loading = true);

    try {
      final doc = await _db
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .doc(widget.transactionId)
          .get();

      transactionData = doc.exists ? doc.data() : null;
    } catch (_) {
      transactionData = null;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ---------------- DELETE ----------------
  Future<void> _deleteTransaction() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .doc(widget.transactionId)
        .delete();

    if (mounted) Navigator.pop(context, true); // Return true to refresh previous screen
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Transaction?"),
        content: const Text("Are you sure you want to delete this entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
>>>>>>> 0f10098 (Your commit message)
    );
   }
  } finally {
   if (mounted) setState(() => loading = false);
  }
 }

 // ---------------- DELETE & UPDATE BALANCE (CRITICAL LOGIC) ----------------
 // NOTE: For a real finance app, deletion must also update the balance.
 // This function is simplified for this code context.
 Future<void> _deleteTransaction() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null || transactionData == null) return;

  final amount = (transactionData!["amount"] is num)
    ? (transactionData!["amount"] as num).toDouble()
    : 0.0;
  final type = transactionData!["type"]?.toString() ?? "expense";

  try {
   final userDoc = _db.collection("users").doc(uid);

<<<<<<< HEAD
   // 1. Remove the transaction
   await userDoc
     .collection("transactions")
     .doc(widget.transactionId)
     .delete();
=======
    final String title = data["title"]?.toString() ?? "Untitled";
    final double amount = (data["amount"] is num) ? (data["amount"] as num).toDouble() : 0.0;
    final String type = data["type"]?.toString() ?? "expense";
    final String category = data["category"]?.toString() ?? "No category";
    final String notes = data["notes"]?.toString() ?? "No notes";
>>>>>>> 0f10098 (Your commit message)

   // 2. Reverse the balance update (Subtract income, add back expense)
   if (type == "income") {
    await userDoc.update({
     "balance.totalBalance": FieldValue.increment(-amount),
     "balance.monthlyIncome": FieldValue.increment(-amount),
    });
   } else { // expense
    await userDoc.update({
     "balance.totalBalance": FieldValue.increment(amount), // Adding back the spent money
     "balance.monthlyExpense": FieldValue.increment(-amount),
    });
   }

<<<<<<< HEAD
   if (mounted) {
    Navigator.pop(context, true); // Return true to refresh previous screen
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text("Transaction deleted successfully!")),
=======
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTransactionScreen(
                    transactionId: widget.transactionId,
                  ),
                ),
              );

              if (result == true) {
                _loadTransaction(); // Reload after edit
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildDetailTile("Title", title),
            _buildDetailTile("Amount", "₹ ${amount.toStringAsFixed(2)}"),
            _buildDetailTile("Type", type == "expense" ? "Expense" : "Income"),
            _buildDetailTile("Category", category),
            _buildDetailTile(
              "Date",
              date != null ? DateFormat("yyyy-MM-dd").format(date) : "No date",
            ),
            _buildDetailTile("Notes", notes),
          ],
        ),
      ),
>>>>>>> 0f10098 (Your commit message)
    );
   }
  } catch (e) {
   debugPrint("Error deleting transaction: $e");
   if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text("Failed to delete transaction: $e")),
    );
   }
  }
 }

 void _confirmDelete() {
  showDialog(
   context: context,
   builder: (_) => AlertDialog(
    title: const Text("Delete Transaction?"),
    content: const Text("Are you sure you want to delete this entry? This action is irreversible."),
    actions: [
     TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Cancel", style: TextStyle(color: kTextColor)),
     ),
     ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: kDeleteColor),
      onPressed: () {
       Navigator.pop(context);
       _deleteTransaction();
      },
      child: const Text("Delete", style: TextStyle(color: Colors.white)),
     ),
    ],
   ),
  );
 }

 // ---------------- UI ----------------
 @override
 Widget build(BuildContext context) {
  final currency = context.watch<CurrencyProvider>();
  if (loading) {
   return const Scaffold(body: Center(child: CircularProgressIndicator(color: kStormyTeal)));
  }

<<<<<<< HEAD
  if (transactionData == null) {
   return const Scaffold(
    body: Center(
     child: Text("Transaction not found.", style: TextStyle(fontSize: 16)),
    ),
   );
  }

  final data = transactionData!;

  final String title = data["title"]?.toString() ?? "Untitled";
  final double amount = (data["amount"] is num)
    ? (data["amount"] as num).toDouble()
    : 0.0;
  final String type = data["type"]?.toString() ?? "expense";
  final String category = data["category"]?.toString() ?? "No category";
  final String notes = data["description"]?.toString() ?? "No notes"; // Changed from 'notes' to 'description'
  
  DateTime? date;
  if (data["date"] is Timestamp) {
   date = (data["date"] as Timestamp).toDate();
  }

  final isExpense = type == "expense";
  final amountColor = isExpense ? kCoralGlow : kMintLeaf;
  final amountSign = isExpense ? "-" : "+";

  return Scaffold(
   backgroundColor: kBackgroundColor,
   appBar: AppBar(
    title: const Text("Transaction Details", style: TextStyle(color: Colors.white)),
    backgroundColor: kStormyTeal,
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
    actions: [
     IconButton(
      icon: const Icon(Icons.edit, color: Colors.white),
      onPressed: () async {
       final result = await Navigator.push(
        context,
        MaterialPageRoute(
         builder: (_) => EditTransactionScreen(
          transactionId: widget.transactionId,
         ),
        ),
       );

       if (result == true) {
        _loadTransaction(); // Reload after edit
       }
      },
     ),
     IconButton(
      icon: const Icon(Icons.delete, color: kDeleteColor),
      onPressed: _confirmDelete,
     ),
    ],
   ),
   body: Padding(
    padding: const EdgeInsets.all(20),
    child: ListView(
     children: [
      // Highlighted Amount Card
      _buildAmountCard(
       amount: amount,
       currency: currency.symbol,
       amountColor: amountColor,
       amountSign: amountSign,
       type: isExpense ? "Expense" : "Income",
      ),
      const SizedBox(height: 20),

      _buildDetailTile(
       icon: Icons.title, 
       label: "Title", 
       value: title,
      ),
      _buildDetailTile(
       icon: Icons.category, 
       label: "Category", 
       value: category,
      ),
      _buildDetailTile(
       icon: Icons.calendar_today, 
       label: "Date",
       value: date != null ? DateFormat("yyyy-MM-dd").format(date) : "No date",
      ),
      _buildDetailTile(
       icon: Icons.description, 
       label: "Notes/Description", 
       value: notes,
       isLongText: true,
      ),
     ],
    ),
   ),
  );
 }

 // ---------------- DETAIL WIDGETS ----------------

 Widget _buildAmountCard({
  required double amount,
  required String currency,
  required Color amountColor,
  required String amountSign,
  required String type,
 }) {
  return Card(
   elevation: 4,
   color: amountColor,
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
   child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      Text(
       type,
       style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w500,
       ),
      ),
      const SizedBox(height: 8),
      Text(
       "$amountSign $currency ${amount.toStringAsFixed(2)}",
       style: const TextStyle(
=======
  // ---------------- DETAIL TILE ----------------
  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
>>>>>>> 0f10098 (Your commit message)
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
       ),
      ),
     ],
    ),
   ),
  );
 }

 // Themed Detail Tile with Icon
 Widget _buildDetailTile({
  required String label,
  required String value,
  required IconData icon,
  bool isLongText = false,
 }) {
  return Container(
   margin: const EdgeInsets.only(bottom: 12),
   padding: const EdgeInsets.all(16),
   decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200, width: 1),
   ),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Row(
      children: [
       Icon(icon, color: kStormyTeal, size: 20),
       const SizedBox(width: 8),
       Text(
        label,
        style: const TextStyle(
         fontWeight: FontWeight.bold,
         fontSize: 14,
         color: kInfoColor,
        ),
       ),
      ],
     ),
     if (isLongText) 
      const Divider(height: 12),
     
     Padding(
      padding: isLongText ? EdgeInsets.zero : const EdgeInsets.only(left: 28.0),
      child: Text(
       value,
       style: const TextStyle(
        fontSize: 16, 
        color: kTextColor,
        height: 1.4,
       ),
      ),
     ),
    ],
   ),
  );
 }
}
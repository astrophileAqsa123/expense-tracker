import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/currency_provider.dart';

import 'transaction_details_screen.dart';
import 'edit_transaction_screen.dart';

// --- THEME COLOR DEFINITIONS (Stormy Teal Theme) ---
const Color kStormyTeal = Color(0xFF156064); // Primary Accent/AppBar
const Color kCoralGlow = Color(0xFFFB8F67); // Expense Color
const Color kMintLeaf = Color(0xFF00C49A); // Income Color
const Color kBackgroundColor = Color(0xFFF5F7FA); // Light background
const Color kTextColor = Color(0xFF2D3748); // Dark text
const Color kDeleteColor = Color(0xFFF44336); // Error/Delete
const Color kEditColor = Color(0xFF4A90E2); // Edit/Info Blue
// -------------------------------

class TransactionsScreen extends StatefulWidget {
 const TransactionsScreen({super.key});

 @override
 State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
<<<<<<< HEAD
 final uid = FirebaseAuth.instance.currentUser?.uid;
=======
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }
>>>>>>> 0f10098 (Your commit message)

 @override
 Widget build(BuildContext context) {
  final currency = context.watch<CurrencyProvider>();
  if (uid == null) {
   return const Scaffold(
    body: Center(child: Text("User not logged in")),
   );
  }

  return Scaffold(
   backgroundColor: kBackgroundColor,
   appBar: AppBar(
    title: const Text("All Transactions", style: TextStyle(color: Colors.white)),
    backgroundColor: kStormyTeal, // Themed AppBar
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
   ),
   body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("transactions")
      .orderBy("date", descending: true)
      .snapshots(),
    builder: (context, snapshot) {
     if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: kStormyTeal));
     }

     final transactions = snapshot.data?.docs ?? [];

     if (transactions.isEmpty) {
      return const Center(
       child: Text(
        "No transactions yet",
        style: TextStyle(fontSize: 16, color: kTextColor),
       ),
      );
     }

     return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
       final doc = transactions[index];
       final data = doc.data() as Map<String, dynamic>?;

       if (data == null) return const SizedBox.shrink();

       // Handle potentially missing fields gracefully
       final String title = data['title']?.toString() ?? data['description']?.toString() ?? 'Untitled';
       final String category = data['category']?.toString() ?? 'No Category';
       final String type = data['type']?.toString() ?? 'expense';
       final double amount = (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;
       final Timestamp? date = data['date'] as Timestamp?;
       final bool isExpense = type == 'expense';
       final String id = doc.id;

       final Color transactionColor = isExpense ? kCoralGlow : kMintLeaf;
       final IconData transactionIcon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;

       return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Dismissible(
         key: Key(id),
         background: _editBackground(),
         secondaryBackground: _deleteBackground(),
         confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
           _editTransaction(id);
           return false;
          } else {
           return await _confirmDelete(context, id);
          }
<<<<<<< HEAD
         },
         child: Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
           side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
           contentPadding: const EdgeInsets.all(12),
           onTap: () => _openDetails(id),
           // THEMED LEADING ICON
           leading: CircleAvatar(
            radius: 22,
            backgroundColor: transactionColor.withOpacity(0.15),
            child: Icon(
             transactionIcon,
             color: transactionColor,
            ),
           ),
           // THEMED TEXT
           title: Text(
            title,
            style: const TextStyle(
             fontSize: 18,
             fontWeight: FontWeight.w600,
             color: kTextColor,
            ),
           ),
           subtitle: Text(
            "$category  ${_formatDate(date)}",
            style: const TextStyle(color: Color(0xFF718096)),
           ),
           // THEMED TRAILING AMOUNT
           trailing: Text(
            "${isExpense ? '-' : '+'} ${currency.symbol} ${amount.toStringAsFixed(2)}",
            style: TextStyle(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: transactionColor,
            ),
           ),
          ),
         ),
        ),
       );
      },
     );
    },
   ),
  );
 }

 // ---------------- HELPERS ----------------

 void _editTransaction(String id) {
  Navigator.push(
   context,
   MaterialPageRoute(
    builder: (_) => EditTransactionScreen(transactionId: id),
   ),
  ).then((_) {
   setState(() {}); // Refresh after editing
  });
 }

 void _openDetails(String id) {
  Navigator.push(
   context,
   MaterialPageRoute(
    builder: (_) => TransactionDetailsScreen(transactionId: id),
   ),
  ).then((_) => setState(() {}));
 }

 // THEMED SWIPE BACKGROUNDS
 Widget _editBackground() {
  return Container(
   color: kEditColor, // Themed Edit Color
   alignment: Alignment.centerLeft,
   padding: const EdgeInsets.only(left: 20),
   child: const Icon(Icons.edit, color: Colors.white, size: 28),
  );
 }

 Widget _deleteBackground() {
  return Container(
   color: kDeleteColor, // Themed Delete Color
   alignment: Alignment.centerRight,
   padding: const EdgeInsets.only(right: 20),
   child: const Icon(Icons.delete, color: Colors.white, size: 28),
  );
 }

 Future<bool> _confirmDelete(BuildContext context, String id) async {
  return (await showDialog<bool>(
     context: context,
     builder: (_) => AlertDialog(
      title: const Text("Delete Transaction?"),
      content: const Text("Are you sure you want to permanently delete this entry?"),
      actions: [
       TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text("Cancel", style: TextStyle(color: kTextColor)),
       ),
       ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kDeleteColor), // Themed Delete button
        onPressed: () async {
         await FirebaseFirestore.instance
           .collection("users")
           .doc(uid)
           .collection("transactions")
           .doc(id)
           .delete();
         Navigator.pop(context, true);
        },
        child: const Text("Delete", style: TextStyle(color: Colors.white)),
       ),
      ],
     ),
    )) ??
    false;
 }

 String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return "No date";
  final d = timestamp.toDate();
  return "${d.day}/${d.month}/${d.year}";
 }
}
=======

          final transactions = snapshot.data?.docs ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No transactions yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final doc = transactions[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox.shrink();

              final String title = data['title']?.toString() ?? 'Untitled';
              final String category = data['category']?.toString() ?? 'No Category';
              final String type = data['type']?.toString() ?? 'expense';
              final double amount = (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;
              final Timestamp? date = data['date'] as Timestamp?;
              final bool isExpense = type == 'expense';
              final String id = doc.id;

              return Dismissible(
                key: Key(id),
                background: _editBackground(),
                secondaryBackground: _deleteBackground(),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    _editTransaction(id);
                    return false;
                  } else {
                    return await _confirmDelete(context, id);
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => _openDetails(id),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: isExpense
                          ? Colors.redAccent.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      child: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text("$category • ${_formatDate(date)}"),
                    trailing: Text(
                      "${isExpense ? '-' : '+'} ₹${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------- HELPERS ----------------

  void _editTransaction(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transactionId: id),
      ),
    ).then((_) {
      setState(() {}); // Refresh after editing
    });
  }

  void _openDetails(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transactionId: id),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _editBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(Icons.edit, color: Colors.white, size: 28),
    );
  }

  Widget _deleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String id) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Transaction?"),
            content: const Text("Are you sure you want to delete this entry?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .collection("transactions")
                      .doc(id)
                      .delete();
                  Navigator.pop(context, true);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
        )) ??
        false;
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "No date";
    final d = timestamp.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}

>>>>>>> 0f10098 (Your commit message)

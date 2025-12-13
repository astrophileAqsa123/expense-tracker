import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
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

    try {
      final doc = await _db
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .doc(widget.transactionId)
          .get();

      if (doc.exists && doc.data() != null) {
        transactionData = doc.data();
      } else {
        transactionData = null;
      }
    } catch (e) {
      transactionData = null;
    }

    if (mounted) {
      setState(() => loading = false);
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

    if (mounted) Navigator.pop(context);
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
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (transactionData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Transaction not found.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final data = transactionData!;

    // SAFE DATA EXTRACTION
    final String title = data["title"]?.toString() ?? "Untitled";
    final String amount = data["amount"]?.toString() ?? "0";
    final String type = data["type"]?.toString() ?? "expense";
    final String category = data["category"]?.toString() ?? "No category";
    final String notes = data["notes"]?.toString() ?? "No notes";

    DateTime? date;
    if (data["date"] is Timestamp) {
      date = (data["date"] as Timestamp).toDate();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTransactionScreen(
                    transactionId: widget.transactionId,
                  ),
                ),
              ).then((_) => _loadTransaction());
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
            _buildDetailTile("Amount", "₹ $amount"),
            _buildDetailTile(
              "Type",
              type == "expense" ? "Expense" : "Income",
            ),
            _buildDetailTile("Category", category),
            _buildDetailTile(
              "Date",
              date != null
                  ? DateFormat("yyyy-MM-dd").format(date)
                  : "No date",
            ),
            _buildDetailTile("Notes", notes),
          ],
        ),
      ),
    );
  }

  // ---------------- TILE ----------------
  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

// --- Theme Colors (Consistent) ---
const Color kPrimaryColor = Color(0xFF6C63FF); // Main Purple/Indigo
const Color kPrimaryDarkColor = Color(0xFF5A52D5); // Darker shade for gradient
const Color kBackgroundColor = Color(0xFFF5F7FA); // Light background grey
const Color kTextColor = Color(0xFF2D3748); // Dark text
const Color kExpenseColor = Color(0xFFE53935); // Prominent Red tone for expense actions
const Color kSuccessColor = Color(0xFF4CAF50); // Green for success

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  _ReceiptScannerScreenState createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  File? _image;
  bool _loading = false;
  String extractedText = "Scan a receipt to see the extracted text here.";
  final picker = ImagePicker();

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        extractedText = "Scanning receipt...";
        _loading = true; // Set loading immediately after picking image
      });

      // Execute scan logic
      await _scanReceipt();
    }
  }

  // Scan receipt using MLKit Text Recognition
  Future<void> _scanReceipt() async {
    if (_image == null) return;

    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(_image!);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      extractedText = recognizedText.text;

      // Extract info
      double? amount = _extractAmount(extractedText);
      DateTime? date = _extractDate(extractedText);
      
      if (amount != null) {
        await _saveTransaction(amount, date ?? DateTime.now());
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Expense of \$${amount.toStringAsFixed(2)} added from receipt scan!"),
              backgroundColor: kSuccessColor,
            ),
          );
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Scan complete, but could not detect a total amount."),
              backgroundColor: kExpenseColor,
            ),
          );
        }
      }

    } catch (e) {
      extractedText = "Error during scan: $e";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to process image: $e"),
            backgroundColor: kExpenseColor,
          ),
        );
      }
    } finally {
      textRecognizer.close();
      if (mounted) setState(() => _loading = false);
    }
  }

  // Extract total amount from receipt text
  double? _extractAmount(String text) {
    // A slightly more complex regex to find lines that might indicate a total (Total, Amount Due, etc.)
    final totalRegex = RegExp(r'(total|sum|amount due|balance)\s*[:\$]?\s*(\d+[,.]\d{2})', caseSensitive: false);
    
    // Fallback to simpler decimal extraction
    final decimalRegex = RegExp(r'(\d+\.\d{2})'); 

    // Try to find a total line first
    final totalMatch = totalRegex.firstMatch(text);
    if (totalMatch != null && totalMatch.group(2) != null) {
      return double.tryParse(totalMatch.group(2)!.replaceAll(',', '.'));
    }

    // Otherwise, find the last occurring two-decimal number as a fallback for the total
    final decimalMatches = decimalRegex.allMatches(text).toList();
    if (decimalMatches.isNotEmpty) {
      return double.tryParse(decimalMatches.last.group(1)!);
    }
    
    return null;
  }

  // Extract date from text
  DateTime? _extractDate(String text) {
    // Matches common date formats (e.g., MM/DD/YY, DD.MM.YYYY, YYYY-MM-DD)
    final dateRegex = RegExp(r'(\d{1,4}[-/. ]\d{1,2}[-/. ]\d{2,4})'); 

    final match = dateRegex.firstMatch(text);

    if (match != null) {
      // Clean up common date separators and attempt parsing
      String dateString = match.group(1)!
          .replaceAll("/", "-")
          .replaceAll(".", "-")
          .trim();
          
      // Handle two-digit years (e.g., 05-02-24 to 2024)
      if (dateString.length <= 8) {
          // Assuming day/month/2-digit-year
          String lastPart = dateString.split('-').last;
          if (lastPart.length == 2) {
            dateString = dateString.replaceFirst(lastPart, '20$lastPart');
          }
      }

      try {
        return DateTime.parse(dateString);
      } catch (_) {
        // Fallback for parsing complex date strings
      }
    }

    return null;
  }

  // Save expense automatically in Firestore
  Future<void> _saveTransaction(double amount, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    // 1. Save in 'transactions'
    await userDoc.collection("transactions").add({
      "type": "expense",
      "amount": amount,
      "category": "Receipt Scan",
      "description": "Auto-added from scanned receipt",
      "date": Timestamp.fromDate(date),
    });

    // 2. Update user's balance
    await userDoc.update({
      "balance.totalBalance": FieldValue.increment(-amount),
      "balance.monthlyExpense": FieldValue.increment(amount),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Receipt Scanner", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        // --- Themed AppBar (Using Primary Color Gradient) ---
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
        // --- End Themed AppBar ---
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display Area
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Icon(Icons.receipt_long, size: 100, color: kPrimaryColor.withOpacity(0.5)),
            ),

            const SizedBox(height: 30),

            // Scan Buttons
            _buildThemedButton(
              context,
              icon: Icons.camera_alt,
              label: "Scan Using Camera",
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 15),
            _buildThemedButton(
              context,
              icon: Icons.photo,
              label: "Select from Gallery",
              onPressed: () => _pickImage(ImageSource.gallery),
            ),

            const SizedBox(height: 30),
            
            // Loading Indicator
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CircularProgressIndicator(color: kExpenseColor),
                ),
              ),

            // Extracted Text Display
            Text(
              "Extracted Text:",
              style: TextStyle(
                color: kTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    extractedText,
                    style: const TextStyle(fontSize: 14, color: kTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      )),
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        // Use Expense color since scan typically creates an expense
        backgroundColor: kExpenseColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 3,
      ),
    );
  }
}
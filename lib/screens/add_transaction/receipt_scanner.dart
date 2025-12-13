import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

// --- Theme Colors ---
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kPrimaryDarkColor = Color(0xFF5A52D5);
const Color kBackgroundColor = Color(0xFFF5F7FA);
const Color kTextColor = Color(0xFF2D3748);
const Color kExpenseColor = Color(0xFFE53935);
const Color kSuccessColor = Color(0xFF4CAF50);

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
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
        _loading = true;
      });
      await _scanReceipt();
    }
  }

  // Scan receipt using MLKit
  Future<void> _scanReceipt() async {
    if (_image == null) return;

    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(_image!);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      extractedText = recognizedText.text;

      // Extract amount and date
      double? amount = _extractTotalAmount(extractedText);
      DateTime? date = _extractDate(extractedText);

      if (amount != null) {
        await _saveTransaction(amount, date ?? DateTime.now());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Expense of ₹${amount.toStringAsFixed(2)} added!"),
              backgroundColor: kSuccessColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Scan complete, but could not detect a total amount."),
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

  // -------------------------
  // Extract total amount with comma and decimal handling
  // -------------------------
  double? _extractTotalAmount(String text) {
    if (text.trim().isEmpty) return null;

    final lines = text.split(RegExp(r'\r?\n'));
    final numberRegex =
        RegExp(r'\d{1,3}(?:,\d{3})*(?:\.\d+)?|\d+(?:\.\d+)?');

    List<double> parsedNumbers = [];

    for (final match in numberRegex.allMatches(text)) {
      String raw = match.group(0)!;
      raw = raw.replaceAll(',', ''); // remove thousand separators
      final value = double.tryParse(raw);
      if (value != null) parsedNumbers.add(value);
    }

    if (parsedNumbers.isEmpty) return null;

    // Keyword search for lines containing total
    final keywordRegex = RegExp(
      r'\b(total|amount due|amount|grand total|balance due|payable|total payable|net total)\b',
      caseSensitive: false,
    );

    for (final line in lines.reversed) {
      if (keywordRegex.hasMatch(line)) {
        final matches = numberRegex.allMatches(line);
        if (matches.isNotEmpty) {
          final last = matches.last.group(0)!.replaceAll(',', '');
          final val = double.tryParse(last);
          if (val != null) return val;
        }
      }
    }

    // Fallback: largest number
    parsedNumbers.sort();
    return parsedNumbers.last;
  }

  // Extract date from text (simple heuristic)
  DateTime? _extractDate(String text) {
    final dateRegex = RegExp(r'(\d{1,4}[-/.]\d{1,2}[-/.]\d{2,4})');
    final match = dateRegex.firstMatch(text);
    if (match == null) return null;
    String dateStr = match.group(1)!.replaceAll('/', '-').replaceAll('.', '-');
    final parts = dateStr.split('-');
    if (parts.length == 3 && parts[2].length == 2) {
      parts[2] = '20' + parts[2];
      dateStr = parts.join('-');
    }
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // Save expense in Firestore
  Future<void> _saveTransaction(double amount, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    await userDoc.collection('transactions').add({
      'type': 'expense',
      'amount': amount,
      'category': 'Receipt Scan',
      'description': 'Auto-added from receipt scan',
      'date': Timestamp.fromDate(date),
    });

    await userDoc.update({
      'balance.totalBalance': FieldValue.increment(-amount),
      'balance.monthlyExpense': FieldValue.increment(amount),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Receipt Scanner', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? Icon(Icons.receipt_long,
                      size: 100, color: kPrimaryColor.withOpacity(0.4))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(backgroundColor: kExpenseColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(backgroundColor: kExpenseColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(color: kExpenseColor),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Extracted Text:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(extractedText, style: const TextStyle(color: kTextColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

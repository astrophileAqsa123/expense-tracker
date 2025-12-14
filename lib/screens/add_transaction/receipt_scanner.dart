import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// --- Theme Colors (using kPrimaryColor: #6C63FF - Violet/Purple) ---
const Color kPrimaryColor = Color(0xFF6C63FF); // Main Accent
const Color kPrimaryDarkColor = Color(0xFF5A52D5); // Darker Accent
const Color kBackgroundColor = Color(0xFFF5F7FA); // Screen Background
const Color kTextColor = Color(0xFF2D3748); // Dark text
const Color kExpenseColor = Color(0xFFE53935); // Danger/Expense Red
const Color kSuccessColor = Color(0xFF4CAF50); // Success Green
const Color kCardColor = Colors.white; // Card background
const Color kBorderColor = Color(0xFFE2E8F0); // Input/Divider

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
 
 double? _extractedAmount;
 DateTime? _extractedDate;

 // ----------------- IMAGE PICKING -----------------

 Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
   setState(() {
    _image = File(pickedFile.path);
    extractedText = "Scanning receipt...";
    _loading = true;
    _extractedAmount = null;
   });
   await _scanReceipt();
  }
 }

 // ----------------- SCAN & OCR -----------------

 Future<void> _scanReceipt() async {
  if (_image == null) return;

  final textRecognizer = TextRecognizer();
  final inputImage = InputImage.fromFile(_image!);

  try {
   final recognizedText = await textRecognizer.processImage(inputImage);
    
   // Store full text and try to extract values
   final fullText = recognizedText.text;
    
   double? amount = _extractTotalAmount(fullText);
   DateTime? date = _extractDate(fullText);

   setState(() {
    extractedText = fullText;
    _extractedAmount = amount;
    _extractedDate = date;
   });

   if (amount != null) {
    await _saveTransaction(amount, date ?? DateTime.now());
    if (mounted) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
       content: Text(
         "Expense of ${amount.toStringAsFixed(2)} added successfully!"),
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
   debugPrint('Error processing image: $e');
   setState(() => extractedText = "Error during scan: $e");
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

 // ----------------- EXTRACTION LOGIC (IMPROVED) -----------------
 
 /// Extracts the most likely total amount using keyword search and heuristics.
 double? _extractTotalAmount(String text) {
  if (text.trim().isEmpty) return null;

  // Clean up text for easier parsing
  final cleanedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  final lines = cleanedText.split(RegExp(r'\r?\n'));

  // Regex for numbers: supports 1,000.00 and 1000,00 (if comma is decimal)
  // We will standardize to dot as decimal
  final numberRegex = RegExp(r'(\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?|\d+[.,]\d{2})');

  // Keywords that typically precede the final total
  final keywordRegex = RegExp(
   r'\b(total|sum|amount due|balance due|payable|net total|invoice total|totaali)\s*[:]?\s*(\d+)',
   caseSensitive: false,
  );

  // 1. Priority: Find matches near "total" keywords
  for (final line in lines.reversed) {
   if (keywordRegex.hasMatch(line)) {
    final matches = numberRegex.allMatches(line);
    if (matches.isNotEmpty) {
     // Get the last number in the line
     final rawNumber = matches.last.group(0)!;
     return _parseAmountString(rawNumber);
    }
   }
  }

  // 2. Fallback: Find the largest reasonable number (e.g., greater than 10)
  List<double> candidates = [];
  for (final match in numberRegex.allMatches(cleanedText)) {
   final val = _parseAmountString(match.group(0)!);
   if (val != null && val >= 5.0) { // filter out small, likely non-total numbers
    candidates.add(val);
   }
  }

  if (candidates.isNotEmpty) {
   candidates.sort();
   return candidates.last;
  }

  return null; // No reasonable amount found
 }

 /// Helper to clean and parse an amount string.
 double? _parseAmountString(String raw) {
  // Standardize decimal/thousand separators: assume the *last* comma/dot is the decimal point.
  if (raw.contains('.') && raw.contains(',')) {
   // Example: 1,000.00 -> remove comma, use dot
   // Example: 1.000,00 -> remove dot, use comma, then change comma to dot
   final lastDot = raw.lastIndexOf('.');
   final lastComma = raw.lastIndexOf(',');

   if (lastComma > lastDot) {
    // European style: 1.234,56
    raw = raw.replaceAll('.', '').replaceAll(',', '.');
   } else {
    // US style: 1,234.56
    raw = raw.replaceAll(',', '');
   }
  } else {
   // Simple case: remove any remaining commas for safety (if they are thousand separators)
   raw = raw.replaceAll(',', '');
  }
   
  return double.tryParse(raw);
 }

 /// Extracts the date from text (improved heuristic).
 DateTime? _extractDate(String text) {
  // Regex for common date formats: YYYY-MM-DD, DD/MM/YY, etc.
  final dateRegex = RegExp(
   r'(\d{1,4}[-/.\s]\d{1,2}[-/.\s]\d{2,4})',
  );
  final match = dateRegex.firstMatch(text);
  if (match == null) return null;

  String dateStr = match.group(1)!.trim();

  // Clean up and standardize separators to '/'
  dateStr = dateStr.replaceAll(RegExp(r'[\s.]'), '-').replaceAll('/', '-');

  final formats = [
   'dd-MM-yyyy',
   'MM-dd-yyyy',
   'yyyy-MM-dd',
   'dd-MM-yy', // For 2-digit years
  ];

  for (var format in formats) {
   try {
    final dateFormat = DateFormat(format);
    return dateFormat.parseStrict(dateStr, true);
   } catch (_) {
    // Try the next format
   }
  }

  return null;
 }

 // ----------------- FIREBASE & BALANCE UPDATE -----------------

 Future<void> _saveTransaction(double amount, DateTime date) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final uid = user.uid;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

  final batch = FirebaseFirestore.instance.batch();

  // 1. Add the transaction document
  final transactionRef = userDoc.collection('transactions').doc();
  batch.set(transactionRef, {
   'type': 'expense',
   'amount': amount,
   'category': 'Receipt Scan',
   'title': 'Receipt Scan: ${DateFormat('MMM dd, yyyy').format(date)}',
   'notes': 'Auto-added from receipt scan. Total text extracted:\n$extractedText',
   'date': Timestamp.fromDate(date),
   'createdAt': FieldValue.serverTimestamp(),
  });

  // 2. Update the user balance (atomic update)
  batch.update(userDoc, {
   'balance.totalBalance': FieldValue.increment(-amount),
   'balance.monthlyExpense': FieldValue.increment(amount),
  });

  await batch.commit();
 }

 // ----------------- UI BUILD -----------------

 Widget _buildScanResultsCard() {
  String amountText = 'Amount: Not detected';
  Color amountColor = kExpenseColor;
  if (_extractedAmount != null) {
   amountText = 'Amount: ${_extractedAmount!.toStringAsFixed(2)}';
   amountColor = kPrimaryDarkColor;
  }

  String dateText = 'Date: Not detected';
  if (_extractedDate != null) {
   dateText = 'Date: ${DateFormat('yyyy-MM-dd').format(_extractedDate!)}';
  }
  
  return Container(
   padding: const EdgeInsets.all(16),
   margin: const EdgeInsets.only(bottom: 20),
   decoration: BoxDecoration(
    color: kCardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: kBorderColor),
   ),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Text(dateText, style: const TextStyle(fontSize: 16, color: kTextColor)),
     const Divider(height: 20),
     Text(
      amountText,
      style: TextStyle(
       fontSize: 24,
       fontWeight: FontWeight.bold,
       color: amountColor,
      ),
     ),
    ],
   ),
  );
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: kBackgroundColor,
   appBar: AppBar(
    title: const Text('Receipt Scanner', style: TextStyle(color: Colors.white)),
    backgroundColor: kPrimaryColor,
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
   ),
   body: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
     children: [
      // Image preview Area
      Container(
       height: 200,
       decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
       ),
       child: _image == null
         ? Center(child: Icon(Icons.receipt_long,
           size: 100, color: kPrimaryColor.withOpacity(0.4)))
         : ClipRRect(
           borderRadius: BorderRadius.circular(12),
           child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
          ),
      ),
      const SizedBox(height: 20),

      // Buttons
      Row(
       children: [
        Expanded(
         child: _buildThemedButton(
          onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
          icon: Icons.camera_alt,
          label: 'Camera',
         ),
        ),
        const SizedBox(width: 10),
        Expanded(
         child: _buildThemedButton(
          onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
          icon: Icons.photo_library,
          label: 'Gallery',
         ),
        ),
       ],
      ),
      const SizedBox(height: 20),

      // Loading/Results
      if (_loading)
       const LinearProgressIndicator(color: kPrimaryColor)
      else if (_image != null)
       _buildScanResultsCard(),

      const Align(
       alignment: Alignment.centerLeft,
       child: Text('Full Extracted Text:',
         style: TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
      ),
      const SizedBox(height: 8),

      // Extracted Text Area
      Expanded(
       child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
         color: kCardColor,
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: kBorderColor),
        ),
        child: SingleChildScrollView(
         child: Text(extractedText, style: const TextStyle(color: kTextColor, fontFamily: 'monospace')),
        ),
       ),
      ),
     ],
    ),
   ),
  );
 }
 
 // --- Themed Button Widget ---
 Widget _buildThemedButton({
  required void Function()? onPressed,
  required IconData icon,
  required String label,
 }) {
  return ElevatedButton.icon(
   onPressed: onPressed,
   icon: Icon(icon, color: Colors.white),
   label: Text(label, style: const TextStyle(color: Colors.white)),
   style: ElevatedButton.styleFrom(
    backgroundColor: kPrimaryColor,
    disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 2,
   ),
  );
 }
}
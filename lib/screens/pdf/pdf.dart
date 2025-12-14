import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// --- THEME COLOR DEFINITIONS (From previous file) ---
class AppColors {
  static const Color kStormyTeal = Color(0xFF156064); 
 static const Color primaryTeal = Color(0xFF00C896); // Bright Teal (Accent)
 static const Color primaryBlue = Color(0xFF0077B6); // Deep Blue (Primary)
 static const Color secondaryDark = Color(0xFF1D3557); // Dark Navy (Text/Contrast)
 static const Color lightBackground = Color(0xFFF1FAEE); // Very Light Cream/Green (Main Background)
 static const Color midBackground = Color(0xFFE5E5E5); // Light Gray
}
// ---------------------------------------------------

class PdfGenerateScreen extends StatefulWidget {
 const PdfGenerateScreen({super.key});

 @override
 State<PdfGenerateScreen> createState() => _PdfGenerateScreenState();
}

enum ReportRange { thisMonth, lastMonth, last7Days, last30Days, allTime }

class _PdfGenerateScreenState extends State<PdfGenerateScreen> {
 final _auth = FirebaseAuth.instance;
 final _db = FirebaseFirestore.instance;

 ReportRange _range = ReportRange.thisMonth;
 bool _loading = false;
 String? _error;

 // Date Range Logic (Kept as is - it is correct)
 DateTimeRange _computeRange(ReportRange range) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (range) {
   case ReportRange.thisMonth:
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);

   case ReportRange.lastMonth:
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);

   case ReportRange.last7Days:
    final start = today.subtract(const Duration(days: 6));
    final end = today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);

   case ReportRange.last30Days:
    final start = today.subtract(const Duration(days: 29));
    final end = today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);

   case ReportRange.allTime:
    final start = DateTime(2000, 1, 1);
    final end = now.add(const Duration(days: 1));
    return DateTimeRange(start: start, end: end);
  }
 }

 String _rangeLabel(ReportRange r) {
  switch (r) {
   case ReportRange.thisMonth:
    return "This Month";
   case ReportRange.lastMonth:
    return "Last Month";
   case ReportRange.last7Days:
    return "Last 7 Days";
   case ReportRange.last30Days:
    return "Last 30 Days";
   case ReportRange.allTime:
    return "All Time";
  }
 }
 
 // Data Fetching Logic (Kept as is - it is correct)
 Future<List<Map<String, dynamic>>> _fetchExpenses(DateTimeRange range) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("User not logged in");

  final uid = user.uid;

  final snap = await _db
    .collection("users")
    .doc(uid)
    .collection("transactions")
    .where("type", isEqualTo: "expense")
    .get();

  // filter in Dart by date range
  final List<Map<String, dynamic>> rows = [];
  for (final doc in snap.docs) {
   final data = doc.data();
   final ts = data["date"];
   if (ts is! Timestamp) continue;

   final d = ts.toDate();
   if (d.isBefore(range.start) || d.isAfter(range.end)) continue;

   rows.add({
    "id": doc.id,
    "amount": (data["amount"] ?? 0).toDouble(),
    "category": (data["category"] ?? "Other").toString(),
    "description": (data["description"] ?? data["title"] ?? "Expense").toString(),
    "notes": (data["notes"] ?? "").toString(),
    "date": d,
   });
  }

  // Sort descending by date in Dart
  rows.sort((a, b) => (b["date"] as DateTime).compareTo(a["date"] as DateTime));
  return rows;
 }

 // PDF Generation Logic (Kept as is - it is correct)
 Future<Uint8List> _buildPdfBytes({
  required DateTimeRange range,
  required List<Map<String, dynamic>> expenses,
 }) async {
  final doc = pw.Document();

  final total = expenses.fold<double>(0.0, (s, e) => s + (e["amount"] as double));

  // category summary
  final Map<String, double> byCat = {};
  for (final e in expenses) {
   final cat = e["category"] as String;
   final amt = e["amount"] as double;
   byCat[cat] = (byCat[cat] ?? 0.0) + amt;
  }

  final catsSorted = byCat.entries.toList()
   ..sort((a, b) => b.value.compareTo(a.value));

  String fmtDate(DateTime d) =>
    "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";

  doc.addPage(
   pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(24),
    build: (context) => [
     pw.Text(
      "Expense Report",
      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.kStormyTeal.value)),
     ),
     pw.SizedBox(height: 6),
     pw.Text("Range: ${fmtDate(range.start)} to ${fmtDate(range.end)}"),
     pw.SizedBox(height: 12),

     // Total Expenses Box (Themed)
     pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
       color: PdfColor.fromInt(AppColors.kStormyTeal.withOpacity(0.1).value),
       border: pw.Border.all(width: 1, color: PdfColor.fromInt(AppColors.kStormyTeal.value)),
       borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
       children: [
        pw.Text("Total Expenses", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Rs ${total.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.kStormyTeal.value))),
       ],
      ),
     ),

     pw.SizedBox(height: 16),
     pw.Text("Category Summary", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value))),
     pw.SizedBox(height: 8),

     // Category Table (Themed Header)
     pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
       0: const pw.FlexColumnWidth(3),
       1: const pw.FlexColumnWidth(2),
      },
      children: [
       pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromInt(AppColors.kStormyTeal.withOpacity(0.1).value)),
        children: [
         pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Category", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value)))),
         pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value)))),
        ],
       ),
       ...catsSorted.map((e) => pw.TableRow(
          children: [
           pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(e.key)),
           pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Rs ${e.value.toStringAsFixed(2)}")),
          ],
         )),
      ],
     ),

     pw.SizedBox(height: 18),
     pw.Text("All Expenses", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value))),
     pw.SizedBox(height: 8),

     // Detail Table (Themed Header)
     pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
       0: const pw.FlexColumnWidth(2),
       1: const pw.FlexColumnWidth(2),
       2: const pw.FlexColumnWidth(3),
       3: const pw.FlexColumnWidth(2),
      },
      children: [
       pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromInt(AppColors.kStormyTeal.withOpacity(0.1).value)),
        children: [
         pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value)))),
         pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Category", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value)))),
         pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Description", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value)))),
         pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(AppColors.secondaryDark.value)))),
        ],
       ),
       ...expenses.map((e) {
        final d = e["date"] as DateTime;
        final cat = e["category"] as String;
        final desc = e["description"] as String;
        final amt = e["amount"] as double;

        return pw.TableRow(
         children: [
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtDate(d))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(cat)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(desc, maxLines: 2, overflow: pw.TextOverflow.clip)),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Rs ${amt.toStringAsFixed(2)}")),
         ],
        );
       }),
      ],
     ),

     pw.SizedBox(height: 14),
     pw.Text("Generated by Expense Tracker", style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
    ],
   ),
  );

  return doc.save();
 }

 Future<void> _generateAndDownload() async {
  setState(() {
   _loading = true;
   _error = null;
  });

  try {
   final range = _computeRange(_range);
   final expenses = await _fetchExpenses(range);

   final pdfBytes = await _buildPdfBytes(range: range, expenses: expenses);

   final fileName =
     "expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf";

   if (kIsWeb) {
    await Printing.layoutPdf(
     onLayout: (PdfPageFormat format) async => pdfBytes,
     name: fileName,
    );
   } else {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
     [XFile(file.path)],
     text: "Expense Report PDF",
    );
   }
  } catch (e) {
   setState(() => _error = e.toString());
  } finally {
   if (mounted) setState(() => _loading = false);
  }
 }

 @override
 Widget build(BuildContext context) {
  // Extract theme colors for Flutter widgets
  const Color primaryColor = AppColors.kStormyTeal;
  const Color tealAccent = AppColors.primaryTeal;
  const Color darkText = AppColors.secondaryDark;

  return Scaffold(
   backgroundColor: AppColors.lightBackground,
   appBar: AppBar(
    title: const Text("Generate PDF Report", style: TextStyle(color: Colors.white)),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
   ),
   body: Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.stretch,
     children: [
      Card(
       elevation: 4,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
       color: Colors.white,
       child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          const Text(
           "Select Report Range",
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReportRange>(
           value: _range,
           items: ReportRange.values
             .map((r) => DropdownMenuItem(
                value: r,
                child: Text(_rangeLabel(r), style: const TextStyle(color: darkText)),
               ))
             .toList(),
           onChanged: _loading ? null : (v) => setState(() => _range = v!),
           decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_month, color: primaryColor),
            labelText: "Time Period",
            border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
           ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
           onPressed: _loading ? null : _generateAndDownload,
           icon: _loading 
            ? const SizedBox(
             width: 20, 
             height: 20, 
             child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
             )
            )
            : const Icon(Icons.picture_as_pdf),
           label: Text(_loading ? "Generating..." : "Generate & Share PDF"),
           style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primaryColor.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           ),
          ),
         ],
        ),
       ),
      ),
      const SizedBox(height: 20),
      // Error/Tip Section
      if (_error != null)
       Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
         color: Colors.red.withOpacity(0.08),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.red),
        ),
        child: Text(
         "Failed to generate PDF: $_error",
         style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
       )
      else
       const Text(
        "Note: Report includes a category summary and a full, date-ordered table of all expenses within the selected period.",
        style: TextStyle(color: Colors.black54, fontSize: 13),
        textAlign: TextAlign.center,
       ),
     ],
    ),
   ),
  );
 }
}
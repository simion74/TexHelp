import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
// 🛠️ FIX: GlobalKey এই প্যাকেজে আছে — rendering.dart-এ নেই, তাই আগে
// "Undefined class 'GlobalKey'" এরর আসছিল।
import 'package:flutter/widgets.dart';
import 'package:excel/excel.dart' as xls;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 📤 সব "শিট" ফিচারের (Costing Sheet, Cutting/Marker Sheet, Order Sheet)
/// জন্য একটাই কমন Export ইঞ্জিন — Excel (.xlsx), PDF, এবং Image (PNG)
/// তিন ফরম্যাটেই এক্সপোর্ট/শেয়ার করার সুবিধা দেয়। সম্পূর্ণ অফলাইনে কাজ
/// করে, কোনো ইন্টারনেট লাগে না।
class ExportService {
  ExportService._();

  // ---------------------------------------------------------------------
  // 📊 EXCEL EXPORT (.xlsx)
  // ---------------------------------------------------------------------

  /// [sheetTitle] শিটের নাম, [headers] কলামের নাম, [rows] প্রতিটা সারির
  /// ডাটা (headers-এর সমান দৈর্ঘ্যের লিস্ট হতে হবে)।
  static Future<void> exportExcel({
    required String fileName,
    required String sheetTitle,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook[sheetTitle];
    workbook.setDefaultSheet(sheetTitle);

    // হেডার রো — বোল্ড স্টাইল সহ
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet
          .cell(xls.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = xls.TextCellValue(headers[col]);
      cell.cellStyle = xls.CellStyle(bold: true);
    }

    // ডাটা রো
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final cell = sheet.cell(
            xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        final value = rows[r][c];
        if (value is num) {
          cell.value = xls.DoubleCellValue(value.toDouble());
        } else {
          cell.value = xls.TextCellValue(value.toString());
        }
      }
    }

    final bytes = workbook.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fileName.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(path)],
        text: '$fileName - TexHelp থেকে এক্সপোর্ট করা হয়েছে');
  }

  // ---------------------------------------------------------------------
  // 📄 PDF EXPORT
  // ---------------------------------------------------------------------

  /// [title] PDF-এর উপরের শিরোনাম, [headers]/[rows] টেবিল ডাটা।
  static Future<void> exportPdf({
    required String fileName,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          // 🛠️ FIX: pw.Table.fromTextArray deprecated — এর বদলে
          // pw.TableHelper.fromTextArray ব্যবহার করা হলো (একই আচরণ)।
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE0F2E9),
            ),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'TexHelp অ্যাপ থেকে তৈরি',
            style: pw.TextStyle(
                fontSize: 9,
                color: const PdfColor.fromInt(0xFF888888),
                fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fileName.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(path)],
        text: '$fileName - TexHelp থেকে এক্সপোর্ট করা হয়েছে');
  }

  // ---------------------------------------------------------------------
  // 🖼️ IMAGE (PNG) EXPORT — স্ক্রিনের নির্দিষ্ট অংশ ছবি হিসেবে ক্যাপচার
  // ---------------------------------------------------------------------

  /// [repaintKey] হলো সেই widget-এর GlobalKey যেটা RepaintBoundary দিয়ে
  /// মোড়ানো আছে (নিচে ব্যবহারের উদাহরণ দেখুন)।
  static Future<void> exportImage({
    required GlobalKey repaintKey,
    required String fileName,
  }) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fileName.png';
    final file = File(path);
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(path)],
        text: '$fileName - TexHelp থেকে এক্সপোর্ট করা হয়েছে');
  }
}

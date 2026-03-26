// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../models/desk_reports_model/ledger_model.dart';

/// Client-side ledger download helper for web.
/// Generates PDF and Excel files from ledger data without API calls.
class LedgerDownloadHelper {
  /// Parse a string value to double safely.
  static double _toDouble(String? val) => double.tryParse(val ?? '0') ?? 0;

  /// Format date string: "2026-02-01 00:00:00" → "01/02/2026"
  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.trim());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  /// Generate and download an Excel file from ledger data.
  static Future<void> downloadExcel({
    required LedgerModelData ledgerData,
    required String clientId,
    required String clientName,
    required String panNo,
    required String email,
    required String year,
    required String fromDate,
    required String toDate,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = 'My Sheet';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];
    final items = (ledgerData.fullStat ?? []).reversed.toList();

    // Track max content length per column for auto-fit
    final Map<int, int> colWidths = {};
    void trackWidth(int col, String value) {
      if (value.length > (colWidths[col] ?? 0)) {
        colWidths[col] = value.length;
      }
    }

    // ── Thin border for all non-empty cells ──
    final thinBorder = Border(borderStyle: BorderStyle.Thin);

    // ── Style definitions ──
    // "Ledger" title: Arial 14pt Bold
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Client info labels & values: right-aligned
    final rightStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Summary headers: Arial 11pt Bold, right-aligned, #,##0.00
    final summaryHeaderStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontFamily: getFontFamily(FontFamily.Arial),
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_4,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Summary values: right-aligned, #,##0.00
    final summaryValueStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_4,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Column headers: dark blue bg (#1F226B), white bold, left-aligned
    final colHeaderLeftStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1F226B'),
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Column headers: dark blue bg, white bold, right-aligned
    final colHeaderRightStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1F226B'),
      horizontalAlign: HorizontalAlign.Right,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Data text cells: left-aligned with borders
    final textStyle = CellStyle(
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    // Data number cells: right-aligned, #,##0.00 with borders
    final numStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_4,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );

    // ── Helpers ──
    void setCell(int col, int row, CellValue value, CellStyle style) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      cell.value = value;
      cell.cellStyle = style;
    }

    void setTextCell(int col, int row, String value, CellStyle style) {
      if (value.isEmpty) return;
      setCell(col, row, TextCellValue(value), style);
      trackWidth(col, value);
    }

    void setNumCell(int col, int row, double value, CellStyle style) {
      setCell(col, row, DoubleCellValue(value), style);
      trackWidth(col, value.toStringAsFixed(2));
    }

    // ════════════════════════════════════════════════════════════
    // ROW 0: Logo placeholder + "Ledger" title + Client ID
    // ════════════════════════════════════════════════════════════
    setTextCell(1, 0, 'Ledger', titleStyle);
    setTextCell(3, 0, 'Client ID', rightStyle);
    setTextCell(4, 0, clientId, rightStyle);

    // ════════════════════════════════════════════════════════════
    // ROWS 1–6: Client info labels (col D) + values (col E)
    // ════════════════════════════════════════════════════════════
    final labels = [
      'Client Name',
      'Client PAN',
      'Client email',
      'Year',
      'From date',
      'To date'
    ];
    final values = [clientName, panNo, email, year, fromDate, toDate];
    for (int i = 0; i < labels.length; i++) {
      setTextCell(3, i + 1, labels[i], rightStyle);
      setTextCell(4, i + 1, values[i], rightStyle);
    }

    // ════════════════════════════════════════════════════════════
    // ROW 8: Summary headers (cols A–D, no gap)
    // ROW 9: Summary values
    // ════════════════════════════════════════════════════════════
    setTextCell(0, 8, 'Opening Balance', summaryHeaderStyle);
    setTextCell(1, 8, 'Debit', summaryHeaderStyle);
    setTextCell(2, 8, 'Credit', summaryHeaderStyle);
    setTextCell(3, 8, 'Closing Balance', summaryHeaderStyle);

    setNumCell(0, 9, _toDouble(ledgerData.openingBalance), summaryValueStyle);
    setNumCell(1, 9, _toDouble(ledgerData.drAmt), summaryValueStyle);
    setNumCell(2, 9, _toDouble(ledgerData.crAmt), summaryValueStyle);
    setNumCell(3, 9, _toDouble(ledgerData.closingBalance), summaryValueStyle);

    // ════════════════════════════════════════════════════════════
    // ROW 11: Data column headers (dark blue bg, white text)
    // ════════════════════════════════════════════════════════════
    setTextCell(0, 11, 'Date', colHeaderLeftStyle);
    setTextCell(1, 11, 'Exchange', colHeaderLeftStyle);
    setTextCell(2, 11, 'Details', colHeaderLeftStyle);
    setTextCell(3, 11, 'Debit', colHeaderRightStyle);
    setTextCell(4, 11, 'Credit', colHeaderRightStyle);
    setTextCell(5, 11, 'Net Amount', colHeaderRightStyle);

    // ════════════════════════════════════════════════════════════
    // ROW 12+: Data rows
    // ════════════════════════════════════════════════════════════
    for (int r = 0; r < items.length; r++) {
      final item = items[r];
      final row = 12 + r;
      setTextCell(0, row, _formatDate(item.vOUCHERDATE), textStyle);
      setTextCell(1, row, item.cOCD ?? '', textStyle);
      setTextCell(2, row, item.nARRATION ?? '', textStyle);
      setNumCell(3, row, _toDouble(item.dRAMT), numStyle);
      setNumCell(4, row, _toDouble(item.cRAMT), numStyle);
      setNumCell(5, row, _toDouble(item.nETAMT), numStyle);
    }

    // ════════════════════════════════════════════════════════════
    // FOOTER rows
    // ════════════════════════════════════════════════════════════
    final footerStart = 12 + items.length + 1;
    final footerLines = [
      'Zebu Share And Wealth Management Private Limited',
      'Correspondence Office: No: 301, 4th Main Road, Burma Colony, Perungudi, Chennai, Tamil Nadu 600 096.',
      'Phone No: 044-4855 7991, Fax: 044-4855 7991',
      'TRADING MEMBER CODE: NSE-EQ,F&O,CDS,COM: 13179 , BSE-EQ,F&O,CD,COM: 6550, MSEI - EQ,F&O,CDS:83300',
      'CIN NO: U67120TZ2013PTC019704 Website Address: www.zebuetrade.com, Investor Grievances Email id: grievance@zebuetrade.com',
    ];
    for (int i = 0; i < footerLines.length; i++) {
      // Write footer without tracking width (long text would bloat col A)
      setCell(0, footerStart + i, TextCellValue(footerLines[i]), textStyle);
    }

    // ════════════════════════════════════════════════════════════
    // AUTO-FIT COLUMN WIDTHS (min 10, content + 2)
    // ════════════════════════════════════════════════════════════
    for (final entry in colWidths.entries) {
      final w = entry.value < 10 ? 10.0 : (entry.value + 2).toDouble();
      sheet.setColumnWidth(entry.key, w);
    }

    // Column A: fixed 14 for date (DD/MM/YYYY)
    sheet.setColumnWidth(0, 14);

    // Row 1 height for logo
    sheet.setRowHeight(0, 33);

    // Encode and download
    final bytes = excel.encode();
    if (bytes == null) return;

    _downloadFile(
      Uint8List.fromList(bytes),
      'Ledger_$year.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// Generate and download a PDF file from ledger data.
  static Future<void> downloadPdf({
    required LedgerModelData ledgerData,
    required String clientId,
    required String clientName,
    required String panNo,
    required String email,
    required String mobile,
    required String address,
    required String fromDate,
    required String toDate,
  }) async {
    final pdf = pw.Document();

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes =
          await rootBundle.load('assets/icon/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    final items = (ledgerData.fullStat ?? []).reversed.toList();
    final openBal = ledgerData.openingBalance ?? '0.00';
    final debit = ledgerData.drAmt ?? '0.00';
    final credit = ledgerData.crAmt ?? '0.00';
    final closeBal = ledgerData.closingBalance ?? '0.00';

    // Build table data rows
    final tableRows = items
        .map((e) => [
              _formatDate(e.vOUCHERDATE),
              e.cOCD ?? '',
              e.nARRATION ?? '',
              e.dRAMT ?? '0',
              e.cRAMT ?? '0',
              e.nETAMT ?? '0',
            ])
        .toList();

    final headerStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
    );
    final valueStyle = const pw.TextStyle(fontSize: 7);
    final titleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo + Title row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoImage != null)
                  pw.Image(logoImage, width: 60, height: 30)
                else
                  pw.SizedBox(width: 60),
                pw.Text('Ledger', style: titleStyle),
                pw.SizedBox(width: 60),
              ],
            ),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 4),
            // Client info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Client Name  :  $clientName', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Client Code   :  $clientId', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('PAN                :  $panNo', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Email Id          :  $email', style: headerStyle),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('From  :  $fromDate', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('To      :  $toDate', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Mobile :  $mobile', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Address : $address', style: headerStyle),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            // Balance summary boxes
            pw.Row(
              children: [
                _balanceBox('Opening Balance', openBal),
                pw.SizedBox(width: 4),
                _balanceBox('Debit', debit, color: PdfColors.red),
                pw.SizedBox(width: 4),
                _balanceBox('Credit', credit, color: PdfColors.green),
                pw.SizedBox(width: 4),
                _balanceBox('Closing Balance', closeBal),
              ],
            ),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Text(
              'Zebu Share And Wealth Management Private Limited',
              style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Correspondence Office: No: 301, 4th Main Road, Burma Colony, Perungudi, Chennai, Tamil Nadu 600 096. Phone No: 044-4855 7991',
              style: const pw.TextStyle(fontSize: 4),
            ),
            pw.Text(
              'TRADING MEMBER CODE: NSE-EQ,F&O,CDS,COM: 13179 , BSE-EQ,F&O,CD,COM: 6550, MSEI - EQ,F&O,CDS:83300 CIN NO: U67120TZ2013PTC019704',
              style: const pw.TextStyle(fontSize: 4),
            ),
            pw.Text(
              'Website Address: www.zebuetrade.com, Investor Grievances Email id: grievance@zebuetrade.com',
              style: const pw.TextStyle(fontSize: 4),
            ),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1F3465),
            ),
            cellStyle: valueStyle,
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
            },
            headers: ['Date', 'Exchange', 'Details', 'Debit', 'Credit', 'Net Amount'],
            data: tableRows,
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    _downloadFile(
      Uint8List.fromList(bytes),
      'Ledger_${fromDate}_$toDate.pdf',
      'application/pdf',
    );
  }

  /// Helper: balance summary box for PDF
  static pw.Widget _balanceBox(String label, String value,
      {PdfColor? color}) {
    final val = double.tryParse(value) ?? 0;
    final displayColor = color ??
        (val < 0
            ? PdfColors.red
            : val > 0
                ? PdfColors.green
                : PdfColors.black);

    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 7, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(fontSize: 8, color: displayColor)),
          ],
        ),
      ),
    );
  }

  /// Trigger browser download
  static void _downloadFile(
      Uint8List bytes, String fileName, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

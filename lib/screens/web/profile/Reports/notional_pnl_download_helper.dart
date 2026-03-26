// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../models/desk_reports_model/pnl_model.dart';

/// Client-side Notional P&L download helper for web.
/// Generates PDF and Excel files from P&L transaction data.
class NotionalPnlDownloadHelper {
  static double _toDouble(String? val) => double.tryParse(val ?? '0') ?? 0;

  static String _formatNumber(String? val) {
    final num = _toDouble(val);
    return num.toStringAsFixed(2);
  }

  static String _formatQty(String? val) {
    final num = _toDouble(val);
    return num.toStringAsFixed(0);
  }

  /// Generate and download a PDF file from Notional P&L data.
  static Future<void> downloadPdf({
    required List<Transactions> transactions,
    required PnlModel pnlData,
    required String clientId,
    required String clientName,
    required String dateRange,
  }) async {
    final pdf = pw.Document();

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/icon/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    // Calculate segment totals
    double equityTotal = 0;
    double fnoTotal = 0;
    double currencyTotal = 0;
    for (final t in transactions) {
      final pnl = _toDouble(t.nOTPROFIT);
      final code = t.companyCode ?? '';
      if (code == 'NSE_CASH' || code == 'BSE_CASH') {
        equityTotal += pnl;
      } else if (code == 'NSE_FNO' || code == 'BSE_FNO') {
        fnoTotal += pnl;
      } else if (code == 'CDS') {
        currencyTotal += pnl;
      }
    }

    final netPnl = _toDouble(pnlData.netPnl);

    // Build table data rows
    final tableRows = transactions
        .map((t) => [
              t.sCRIPSYMBOL ?? '',
              _formatQty(t.bUYQUANTITY),
              _formatNumber(t.bUYRATE),
              _formatNumber(t.bUYAMOUNT),
              _formatQty(t.sALEQUANTITY),
              _formatNumber(t.sALERATE),
              _formatNumber(t.sALEAMOUNT),
              _formatQty(t.nETQUANTITY),
              _formatNumber(t.nETRATE),
              _formatNumber(t.nETAMOUNT),
              _formatNumber(t.cLOSINGPRICE),
              _formatNumber(t.nOTPROFIT),
            ])
        .toList();

    final headerStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
    );
    final valueStyle = const pw.TextStyle(fontSize: 6.5);
    final titleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
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
                pw.Text('Notional P&L', style: titleStyle),
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
                      pw.Text('Client Name  :  $clientName',
                          style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Client Code   :  $clientId',
                          style: headerStyle),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date  :  $dateStr', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Time  :  $timeStr', style: headerStyle),
                      pw.SizedBox(height: 2),
                      pw.Text('Period  :  $dateRange', style: headerStyle),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            // Summary boxes
            pw.Row(
              children: [
                _summaryBox('Net Notional', netPnl.toStringAsFixed(2),
                    color: netPnl >= 0 ? PdfColors.green : PdfColors.red),
                pw.SizedBox(width: 4),
                _summaryBox('Equity', equityTotal.toStringAsFixed(2),
                    color:
                        equityTotal >= 0 ? PdfColors.green : PdfColors.red),
                pw.SizedBox(width: 4),
                _summaryBox('FNO', fnoTotal.toStringAsFixed(2),
                    color: fnoTotal >= 0 ? PdfColors.green : PdfColors.red),
                pw.SizedBox(width: 4),
                _summaryBox('Currency', currencyTotal.toStringAsFixed(2),
                    color: currencyTotal >= 0
                        ? PdfColors.green
                        : PdfColors.red),
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
              style:
                  pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
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
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 6.5,
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
              0: const pw.FlexColumnWidth(2.5), // Symbol
              1: const pw.FlexColumnWidth(0.8), // Buy Qty
              2: const pw.FlexColumnWidth(1.0), // Buy Rate
              3: const pw.FlexColumnWidth(1.2), // Buy Amt
              4: const pw.FlexColumnWidth(0.8), // Sell Qty
              5: const pw.FlexColumnWidth(1.0), // Sell Rate
              6: const pw.FlexColumnWidth(1.2), // Sell Amt
              7: const pw.FlexColumnWidth(0.8), // Net Qty
              8: const pw.FlexColumnWidth(1.0), // Net Rate
              9: const pw.FlexColumnWidth(1.2), // Net Amt
              10: const pw.FlexColumnWidth(1.0), // Close Price
              11: const pw.FlexColumnWidth(1.2), // Notional
            },
            headers: [
              'Symbol',
              'Buy Qty',
              'Buy Rate',
              'Buy Amt',
              'Sell Qty',
              'Sell Rate',
              'Sell Amt',
              'Net Qty',
              'Net Rate',
              'Net Amt',
              'Close Price',
              'Notional',
            ],
            data: tableRows,
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    _downloadFile(
      Uint8List.fromList(bytes),
      'Notional_PnL_${DateFormat('dd-MM-yyyy').format(now)}.pdf',
      'application/pdf',
    );
  }

  /// Generate and download an Excel file from Notional P&L data.
  static Future<void> downloadExcel({
    required List<Transactions> transactions,
    required PnlModel pnlData,
    required String clientId,
    required String clientName,
    required String dateRange,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = 'Notional PnL';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);

    // Track max content length per column for auto-fit
    final Map<int, int> colWidths = {};
    void trackWidth(int col, String value) {
      if (value.length > (colWidths[col] ?? 0)) {
        colWidths[col] = value.length;
      }
    }

    // ── Thin border for all cells ──
    final thinBorder = Border(borderStyle: BorderStyle.Thin);

    // ── Style definitions ──
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    final rightStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
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
    final summaryValueStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      numberFormat: NumFormat.standard_4,
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
    final colHeaderStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1F226B'),
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
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
    final textStyle = CellStyle(
      leftBorder: thinBorder,
      rightBorder: thinBorder,
      topBorder: thinBorder,
      bottomBorder: thinBorder,
    );
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

    // Calculate segment totals
    double equityTotal = 0;
    double fnoTotal = 0;
    double currencyTotal = 0;

    for (final t in transactions) {
      final pnl = _toDouble(t.nOTPROFIT);
      final code = t.companyCode ?? '';
      if (code == 'NSE_CASH' || code == 'BSE_CASH') {
        equityTotal += pnl;
      } else if (code == 'NSE_FNO' || code == 'BSE_FNO') {
        fnoTotal += pnl;
      } else if (code == 'CDS') {
        currencyTotal += pnl;
      }
    }

    final netPnl = _toDouble(pnlData.netPnl);

    // ════════════════════════════════════════════════════════════
    // ROW 0: Title + Client info
    // ════════════════════════════════════════════════════════════
    setTextCell(1, 0, 'Notional P&L', titleStyle);
    setTextCell(9, 0, 'Client ID', rightStyle);
    setTextCell(10, 0, clientId, rightStyle);

    // ROW 1-3: Client info
    setTextCell(9, 1, 'Client Name', rightStyle);
    setTextCell(10, 1, clientName, rightStyle);
    setTextCell(9, 2, 'Date', rightStyle);
    setTextCell(10, 2, dateStr, rightStyle);
    setTextCell(9, 3, 'Period', rightStyle);
    setTextCell(10, 3, dateRange, rightStyle);

    // ════════════════════════════════════════════════════════════
    // ROW 5: Summary headers
    // ROW 6: Summary values
    // ════════════════════════════════════════════════════════════
    setTextCell(0, 5, 'Net Notional', summaryHeaderStyle);
    setTextCell(1, 5, 'Equity', summaryHeaderStyle);
    setTextCell(2, 5, 'FNO', summaryHeaderStyle);
    setTextCell(3, 5, 'Currency', summaryHeaderStyle);
    setTextCell(4, 5, 'Total Symbols', summaryHeaderStyle);

    setNumCell(0, 6, netPnl, summaryValueStyle);
    setNumCell(1, 6, equityTotal, summaryValueStyle);
    setNumCell(2, 6, fnoTotal, summaryValueStyle);
    setNumCell(3, 6, currencyTotal, summaryValueStyle);
    setNumCell(4, 6, transactions.length.toDouble(), summaryValueStyle);

    // ════════════════════════════════════════════════════════════
    // ROW 8: Column headers
    // ════════════════════════════════════════════════════════════
    final headers = [
      'Symbol',
      'Buy Qty',
      'Buy Rate',
      'Buy Amt',
      'Sell Qty',
      'Sell Rate',
      'Sell Amt',
      'Net Qty',
      'Net Rate',
      'Net Amt',
      'Close Price',
      'Notional',
    ];
    for (int i = 0; i < headers.length; i++) {
      final style = i >= 1 ? colHeaderRightStyle : colHeaderStyle;
      setTextCell(i, 8, headers[i], style);
    }

    // ════════════════════════════════════════════════════════════
    // ROW 9+: Data rows
    // ════════════════════════════════════════════════════════════
    for (int r = 0; r < transactions.length; r++) {
      final t = transactions[r];
      final row = 9 + r;
      setTextCell(0, row, t.sCRIPSYMBOL ?? '', textStyle);
      setNumCell(1, row, _toDouble(t.bUYQUANTITY), numStyle);
      setNumCell(2, row, _toDouble(t.bUYRATE), numStyle);
      setNumCell(3, row, _toDouble(t.bUYAMOUNT), numStyle);
      setNumCell(4, row, _toDouble(t.sALEQUANTITY), numStyle);
      setNumCell(5, row, _toDouble(t.sALERATE), numStyle);
      setNumCell(6, row, _toDouble(t.sALEAMOUNT), numStyle);
      setNumCell(7, row, _toDouble(t.nETQUANTITY), numStyle);
      setNumCell(8, row, _toDouble(t.nETRATE), numStyle);
      setNumCell(9, row, _toDouble(t.nETAMOUNT), numStyle);
      setNumCell(10, row, _toDouble(t.cLOSINGPRICE), numStyle);
      setNumCell(11, row, _toDouble(t.nOTPROFIT), numStyle);
    }

    // ════════════════════════════════════════════════════════════
    // FOOTER rows
    // ════════════════════════════════════════════════════════════
    final footerStart = 9 + transactions.length + 1;
    final footerLines = [
      'Zebu Share And Wealth Management Private Limited',
      'Correspondence Office: No: 301, 4th Main Road, Burma Colony, Perungudi, Chennai, Tamil Nadu 600 096.',
      'Phone No: 044-4855 7991, Fax: 044-4855 7991',
      'TRADING MEMBER CODE: NSE-EQ,F&O,CDS,COM: 13179 , BSE-EQ,F&O,CD,COM: 6550, MSEI - EQ,F&O,CDS:83300',
      'CIN NO: U67120TZ2013PTC019704 Website Address: www.zebuetrade.com, Investor Grievances Email id: grievance@zebuetrade.com',
    ];
    for (int i = 0; i < footerLines.length; i++) {
      setCell(
          0, footerStart + i, TextCellValue(footerLines[i]), textStyle);
    }

    // ════════════════════════════════════════════════════════════
    // AUTO-FIT COLUMN WIDTHS
    // ════════════════════════════════════════════════════════════
    for (final entry in colWidths.entries) {
      final w = entry.value < 10 ? 10.0 : (entry.value + 2).toDouble();
      sheet.setColumnWidth(entry.key, w);
    }

    // Symbol column: minimum 25
    if ((colWidths[0] ?? 0) < 25) {
      sheet.setColumnWidth(0, 25);
    }

    sheet.setRowHeight(0, 33);

    // Encode and download
    final bytes = excel.encode();
    if (bytes == null) return;

    _downloadFile(
      Uint8List.fromList(bytes),
      'Notional_PnL_${DateFormat('dd-MM-yyyy').format(now)}.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// Helper: summary box for PDF
  static pw.Widget _summaryBox(String label, String value,
      {PdfColor? color}) {
    final displayColor = color ?? PdfColors.black;
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

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import '../../../../models/desk_reports_model/contract_note_model.dart';

/// Client-side Contract Note download helper for web.
/// Generates an Excel file from contract note trade data.
class ContractNoteDownloadHelper {
  static double _toDouble(String? val) => double.tryParse(val ?? '0') ?? 0;

  /// Generate and download an Excel file from contract note data.
  static Future<void> downloadExcel({
    required List<ContractNoteTrade> trades,
    required Map<String, List<ContractNoteNet>>? netData,
    required Map<String, List<ContractNoteSettlement>>? settlementData,
    required String clientId,
    required String clientName,
    required String selectedDate,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = 'Contract Note';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

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
    final summaryLabelStyle = CellStyle(
      bold: true,
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
    // ROW 0: Title + Client info
    // ════════════════════════════════════════════════════════════
    setTextCell(1, 0, 'Contract Note', titleStyle);
    setTextCell(7, 0, 'Client ID', rightStyle);
    setTextCell(8, 0, clientId, rightStyle);

    // ROW 1-2: Client info
    setTextCell(7, 1, 'Client Name', rightStyle);
    setTextCell(8, 1, clientName, rightStyle);
    setTextCell(7, 2, 'Trade Date', rightStyle);
    setTextCell(8, 2, selectedDate, rightStyle);

    // ════════════════════════════════════════════════════════════
    // ROW 4: Column headers
    // ════════════════════════════════════════════════════════════
    final headers = [
      'Script',
      'Exchange',
      'Order No',
      'Trade No',
      'B/S',
      'Qty',
      'Gross Rate',
      'Brokerage',
      'Net Rate',
      'Net Total',
    ];
    for (int i = 0; i < headers.length; i++) {
      final style = i >= 5 ? colHeaderRightStyle : colHeaderStyle;
      setTextCell(i, 4, headers[i], style);
    }

    // ════════════════════════════════════════════════════════════
    // ROW 5+: Data rows
    // ════════════════════════════════════════════════════════════
    for (int r = 0; r < trades.length; r++) {
      final t = trades[r];
      final row = 5 + r;
      final isBuy = t.buySale == 'BUY';

      setTextCell(0, row, t.scripSymbol ?? '', textStyle);
      setTextCell(1, row, t.tradeExchange ?? '', textStyle);
      setTextCell(2, row, t.orderNumber ?? '', textStyle);
      setTextCell(3, row, t.tradeNumber ?? '', textStyle);
      setTextCell(4, row, t.buySale ?? '', textStyle);
      setNumCell(5, row, _toDouble(t.quantity), numStyle);
      setNumCell(
          6,
          row,
          isBuy ? _toDouble(t.buyPrice) : _toDouble(t.sellPrice),
          numStyle);
      setNumCell(7, row, _toDouble(t.tradeBrokerage), numStyle);
      setNumCell(
          8,
          row,
          isBuy ? _toDouble(t.netBuyPrice) : _toDouble(t.netSellPrice),
          numStyle);
      setNumCell(
          9,
          row,
          isBuy ? _toDouble(t.buyAmount) : _toDouble(t.sellAmount),
          numStyle);
    }

    int currentRow = 5 + trades.length + 1;

    // ════════════════════════════════════════════════════════════
    // NET SUMMARY (if available)
    // ════════════════════════════════════════════════════════════
    if (netData != null && netData.isNotEmpty) {
      setTextCell(0, currentRow, 'Net Summary', summaryLabelStyle);
      currentRow++;

      // Net summary headers
      final netHeaders = [
        'Exchange',
        'Buy Qty',
        'Buy Amt',
        'Buy Rate',
        'Sell Qty',
        'Sell Amt',
        'Sell Rate',
        'Net Qty',
        'Net Amt',
      ];
      for (int i = 0; i < netHeaders.length; i++) {
        final style = i >= 1 ? colHeaderRightStyle : colHeaderStyle;
        setTextCell(i, currentRow, netHeaders[i], style);
      }
      currentRow++;

      for (final entry in netData.entries) {
        for (final net in entry.value) {
          setTextCell(0, currentRow, entry.key, textStyle);
          setNumCell(1, currentRow, _toDouble(net.buyQuantity), numStyle);
          setNumCell(2, currentRow, _toDouble(net.buyAmount), numStyle);
          setNumCell(3, currentRow, _toDouble(net.buyRate), numStyle);
          setNumCell(4, currentRow, _toDouble(net.sellQuantity), numStyle);
          setNumCell(5, currentRow, _toDouble(net.sellAmount), numStyle);
          setNumCell(6, currentRow, _toDouble(net.sellRate), numStyle);
          setNumCell(7, currentRow, _toDouble(net.netQty), numStyle);
          setNumCell(8, currentRow, _toDouble(net.netAmt), numStyle);
          currentRow++;
        }
      }
      currentRow++;
    }

    // ════════════════════════════════════════════════════════════
    // SETTLEMENT (if available)
    // ════════════════════════════════════════════════════════════
    if (settlementData != null && settlementData.isNotEmpty) {
      setTextCell(0, currentRow, 'Settlement Details', summaryLabelStyle);
      currentRow++;

      final exchanges = settlementData.keys.toList();

      // Settlement headers
      setTextCell(0, currentRow, 'Particulars', colHeaderStyle);
      for (int i = 0; i < exchanges.length; i++) {
        setTextCell(i + 1, currentRow, exchanges[i], colHeaderRightStyle);
      }
      currentRow++;

      // Settlement rows
      final settlementRows = <MapEntry<String, String Function(ContractNoteSettlement)>>[
        MapEntry('Pay In/Pay Out Obligation', (s) => s.payinout ?? '0'),
        MapEntry('Brokerage', (s) => s.brokerage ?? '0'),
        MapEntry('TOT', (s) => s.tot ?? '0'),
        MapEntry('CGST (9%)', (s) => s.cgst ?? '0'),
        MapEntry('SGST (9%)', (s) => s.sgst ?? '0'),
        MapEntry('STT', (s) => s.stt ?? '0'),
        MapEntry('Stamp Duty', (s) => s.stampduty ?? '0'),
        MapEntry('Net Amount', (s) => s.netAmt ?? '0'),
      ];

      for (final sRow in settlementRows) {
        setTextCell(0, currentRow, sRow.key, textStyle);
        for (int i = 0; i < exchanges.length; i++) {
          final settlements = settlementData[exchanges[i]] ?? [];
          if (settlements.isNotEmpty) {
            setNumCell(
                i + 1, currentRow, _toDouble(sRow.value(settlements.first)), numStyle);
          }
        }
        currentRow++;
      }
      currentRow++;
    }

    // ════════════════════════════════════════════════════════════
    // FOOTER rows
    // ════════════════════════════════════════════════════════════
    final footerLines = [
      'Zebu Share And Wealth Management Private Limited',
      'Correspondence Office: No: 301, 4th Main Road, Burma Colony, Perungudi, Chennai, Tamil Nadu 600 096.',
      'Phone No: 044-4855 7991, Fax: 044-4855 7991',
      'TRADING MEMBER CODE: NSE-EQ,F&O,CDS,COM: 13179 , BSE-EQ,F&O,CD,COM: 6550, MSEI - EQ,F&O,CDS:83300',
      'CIN NO: U67120TZ2013PTC019704 Website Address: www.zebuetrade.com, Investor Grievances Email id: grievance@zebuetrade.com',
    ];
    for (int i = 0; i < footerLines.length; i++) {
      setCell(0, currentRow + i, TextCellValue(footerLines[i]), textStyle);
    }

    // ════════════════════════════════════════════════════════════
    // AUTO-FIT COLUMN WIDTHS
    // ════════════════════════════════════════════════════════════
    for (final entry in colWidths.entries) {
      final w = entry.value < 10 ? 10.0 : (entry.value + 2).toDouble();
      sheet.setColumnWidth(entry.key, w);
    }

    // Script column: minimum 25
    if ((colWidths[0] ?? 0) < 25) {
      sheet.setColumnWidth(0, 25);
    }

    sheet.setRowHeight(0, 33);

    // Encode and download
    final bytes = excel.encode();
    if (bytes == null) return;

    _downloadFile(
      Uint8List.fromList(bytes),
      'Contract_Note_${selectedDate.replaceAll('/', '-')}.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
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

import 'package:mynt_plus/models/order_book_model/order_book_model.dart';
import 'package:mynt_plus/models/order_book_model/trade_book_model.dart';
import 'package:mynt_plus/models/order_book_model/gtt_order_book.dart';
import '../models/sort_config.dart';

class SortingUtils {
  // Generic comparison helper
  static int _compare<T extends Comparable>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  // Parse numeric value
  static num _parseNum(String? v) => double.tryParse(v ?? '') ?? 0;

  // Sort orders
  static List<OrderBookModel> sortOrders(
    List<OrderBookModel> orders,
    SortConfig config,
  ) {
    if (config.sortColumnIndex == null) return orders;

    final sorted = [...orders];
    final c = config.sortColumnIndex!;
    final asc = config.sortAscending;

    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument
          r = _compare(a.tsym, b.tsym);
          break;
        case 1: // Product
          r = _compare(a.sPrdtAli ?? a.prd, b.sPrdtAli ?? b.prd);
          break;
        case 2: // Type
          r = _compare(a.trantype, b.trantype);
          break;
        case 3: // Qty
          r = _compare(
            num.tryParse(a.qty.toString()) ?? 0,
            num.tryParse(b.qty.toString()) ?? 0,
          );
          break;
        case 4: // Avg price
          r = _compare(_parseNum(a.avgprc), _parseNum(b.avgprc));
          break;
        case 5: // LTP
          r = _compare(_parseNum(a.ltp), _parseNum(b.ltp));
          break;
        case 6: // Price
          r = _compare(_parseNum(a.prc), _parseNum(b.prc));
          break;
        case 7: // Trigger price
          r = _compare(_parseNum(a.trgprc), _parseNum(b.trgprc));
          break;
        case 8: // Order value
          final av = _parseNum(a.avgprc ?? "0") *
              (int.tryParse(a.qty.toString()) ?? 0);
          final bv = _parseNum(b.avgprc ?? "0") *
              (int.tryParse(b.qty.toString()) ?? 0);
          r = _compare(av, bv);
          break;
        case 9: // Status
          r = _compare(a.status, b.status);
          break;
        case 10: // Time
          r = _compare(a.norentm, b.norentm);
          break;
      }
      return asc ? r : -r;
    });

    return sorted;
  }

  // Sort trades
  static List<TradeBookModel> sortTrades(
    List<TradeBookModel> trades,
    SortConfig config,
  ) {
    if (config.sortColumnIndex == null) return trades;

    final sorted = [...trades];
    final c = config.sortColumnIndex!;
    final asc = config.sortAscending;

    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument
          r = _compare(a.tsym, b.tsym);
          break;
        case 1: // Product
          r = _compare(a.sPrdtAli, b.sPrdtAli);
          break;
        case 2: // Type
          r = _compare(a.trantype, b.trantype);
          break;
        case 3: // Qty
          r = _compare(
            num.tryParse(a.qty.toString()) ?? 0,
            num.tryParse(b.qty.toString()) ?? 0,
          );
          break;
        case 4: // Price
          r = _compare(_parseNum(a.avgprc), _parseNum(b.avgprc));
          break;
        case 5: // Trade value
          final av = _parseNum(a.flqty?.toString() ?? "0") * _parseNum(a.flprc ?? "0");
          final bv = _parseNum(b.flqty?.toString() ?? "0") * _parseNum(b.flprc ?? "0");
          r = _compare(av, bv);
          break;
        case 6: // Order no
          r = _compare(a.norenordno, b.norenordno);
          break;
        case 7: // Time
          r = _compare(a.norentm, b.norentm);
          break;
      }
      return asc ? r : -r;
    });

    return sorted;
  }

  // Sort GTT orders
  static List<GttOrderBookModel> sortGttOrders(
    List<GttOrderBookModel> gttOrders,
    SortConfig config,
  ) {
    if (gttOrders.isEmpty || config.sortColumnIndex == null) return gttOrders;

    final sorted = [...gttOrders];
    final c = config.sortColumnIndex!;
    final asc = config.sortAscending;

    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument
          r = _compare(a.tsym, b.tsym);
          break;
        case 1: // Product
          r = _compare(a.placeOrderParams?.sPrdtAli, b.placeOrderParams?.sPrdtAli);
          break;
        case 2: // Type
          r = _compare(a.trantype, b.trantype);
          break;
        case 3: // Qty
          r = _compare(
            num.tryParse(a.qty.toString()) ?? 0,
            num.tryParse(b.qty.toString()) ?? 0,
          );
          break;
        case 4: // LTP
          r = _compare(_parseNum(a.ltp), _parseNum(b.ltp));
          break;
        case 5: // Trigger price
          r = _compare(_parseNum(a.d), _parseNum(b.d));
          break;
        case 6: // Status
          r = _compare(a.gttOrderCurrentStatus, b.gttOrderCurrentStatus);
          break;
        case 7: // Time
          r = _compare(a.norentm, b.norentm);
          break;
      }
      return asc ? r : -r;
    });

    return sorted;
  }
}

import '../utils/url_utils.dart';

class SpanCalcResponse {
  final String requestTime;
  final String stat;
  final String span;
  final String expo;
  final String spanTrade;
  final String expoTrade;
  final String preTrade;
  final String add;
  final String addTrade;
  final String ten;
  final String tenTrade;
  final String del;
  final String delTrade;
  final String spl;
  final String splTrade;

  SpanCalcResponse({
    required this.requestTime,
    required this.stat,
    required this.span,
    required this.expo,
    required this.spanTrade,
    required this.expoTrade,
    required this.preTrade,
    required this.add,
    required this.addTrade,
    required this.ten,
    required this.tenTrade,
    required this.del,
    required this.delTrade,
    required this.spl,
    required this.splTrade,
  });

  factory SpanCalcResponse.fromJson(Map<String, dynamic> json) {
    return SpanCalcResponse(
      requestTime: (json['request_time'] ?? '').toString(),
      stat: (json['stat'] ?? '').toString(),
      span: (json['span'] ?? '0.00').toString(),
      expo: (json['expo'] ?? '0.00').toString(),
      spanTrade: (json['span_trade'] ?? '0.00').toString(),
      expoTrade: (json['expo_trade'] ?? '0.00').toString(),
      preTrade: (json['pre_trade'] ?? '0.00').toString(),
      add: (json['add'] ?? '0.00').toString(),
      addTrade: (json['add_trade'] ?? '0.00').toString(),
      ten: (json['ten'] ?? '0.00').toString(),
      tenTrade: (json['ten_trade'] ?? '0.00').toString(),
      del: (json['del'] ?? '0.00').toString(),
      delTrade: (json['del_trade'] ?? '0.00').toString(),
      spl: (json['spl'] ?? '0.00').toString(),
      splTrade: (json['spl_trade'] ?? '0.00').toString(),
    );
  }

  double get spanValue => double.tryParse(span) ?? 0.0;
  double get expoValue => double.tryParse(expo) ?? 0.0;
}

class SpanCalcPositionItem {
  final String prd; // e.g., 'M'
  final String exch; // NFO/BFO
  final String tsym; // trading symbol
  final String symname; // display symbol
  final String instname; // FUTIDX/OPTIDX/etc.
  final String exd; // expiry dd-MMM-YYYY
  final String netqty; // number of lots or quantity
  final String optt; // XX/PE/CE
  final String strprc; // strike price or -0.01 for futures

  SpanCalcPositionItem({
    required this.prd,
    required this.exch,
    required this.tsym,
    required this.symname,
    required this.instname,
    required this.exd,
    required this.netqty,
    required this.optt,
    required this.strprc,
  });

  Map<String, dynamic> toJson() => {
        'prd': prd,
        'exch': exch,
        'tsym': UrlUtils.encodeParameter(tsym),
        'symname': symname,
        'instname': instname,
        'exd': exd,
        'netqty': netqty,
        'optt': optt,
        'strprc': strprc,
      };
}


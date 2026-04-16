import 'dart:convert';

import 'package:mynt_plus/api/core/api_core.dart';

MarketWatchScrip marketWatchScrip(String str) =>
    MarketWatchScrip.fromJson(json.decode(str));

String fetchWatchListResponseToJson(MarketWatchScrip data) =>
    json.encode(data.toJson());

class MarketWatchScrip {
  MarketWatchScrip(
      {required this.requestTime,
      required this.values,
      required this.stat,
      this.emsg});

  String requestTime;
  List<WatchListValues> values;
  String stat;
  String? emsg;
  factory MarketWatchScrip.fromJson(Map<String, dynamic> json) {
    final List<WatchListValues> values = [];
    if (json['values'] != null) {
      json['values'].forEach((v) {
        values.add(WatchListValues.fromJson(v as Map<String, dynamic>));
      });
    }
    return MarketWatchScrip(
      stat: json['stat'].toString(),
      values: values,
      emsg: json['emsg'].toString(),
      requestTime: json['requestTime'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestTime'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['values'] = values.map((v) => v.toJson()).toList();
    return data;
  }
}

class WatchListValues {
  String? high;
  String? low;
  String? close;
  String? ltp;
  String? change;
  String? token;
  String? perChange;
  String? open;
  String? exch;
  String? tsym;
  String? cname;
  String? pp;
  String? ls;
  bool? isSelected;
  String? ti;
  String? instname;
  bool? isExpandable;
  String? holdingQty;
  bool? hasStockEvent;
  String? weekly;
  String? symbol;
  String? expDate;
  String? option;
  String? dname;

  WatchListValues(
      {this.high,
      this.low,
      this.close,
      this.ltp,
      this.change,
      this.token,
      this.perChange,
      this.open,
      this.exch,
      this.tsym,
      this.pp,
      this.cname,
      this.ls,
      this.ti,
      this.instname,
      this.isSelected,
      this.isExpandable,
      this.holdingQty,
      this.hasStockEvent,
      this.expDate,
      this.dname,
      this.option,
      this.symbol,
      this.weekly});

  factory WatchListValues.fromJson(Map<String, dynamic> json) {
    bool isexpand = json['isexpand'] ?? false;
    return WatchListValues(
        high: json['high'].toString(),
        low: json['low'].toString(),
        close: json['close'],
        ltp: json['ltp'],
        change: json['Change'].toString(),
        token: json['token'].toString(),
        perChange: json['PerChange'].toString(),
        open: json['open'].toString(),
        exch: json["exch"],
        tsym: json["tsym"],
        pp: json["pp"],
        ls: json["ls"],
        cname: json['cname'],
        ti: json["ti"],
        instname: json["instname"],
        isSelected: json['isSelected'] ?? false,
        isExpandable: isexpand,
        holdingQty: json['holdingQty'],
        hasStockEvent:json['hasStockEvent'],
        expDate: json['expDate'],
        symbol: json['symbol'].toString().toUpperCase(),
        option: json['option'],
        weekly: json['weekly'],
        dname: json["dname"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['ltp'] = ltp;
    data['Change'] = change;
    data['token'] = token;
    data['cname'] = cname;
    data['PerChange'] = perChange;
    data['open'] = open;
    data['exch'] = exch;
    data['tsym'] = tsym;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['instname'] = instname;
    data['isSelected'] = isSelected;
    data['isExpandable'] = isExpandable;
    data['holdingQty'] = holdingQty;
    data['option'] = option;
    data['expDate'] = expDate;
    data['symbol'] = symbol;
    data['weekly'] = weekly;
    data['dname'] = dname;
    return data;
  }
}

class ChartArgs {
  String tsym;
  String exch;
  String token;
  ChartArgs({required this.exch, required this.tsym, required this.token});
}

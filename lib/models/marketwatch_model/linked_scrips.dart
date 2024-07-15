class LinkedScrips {
  String? requestTime;
  String? stat;
  List<Equls>? equls;
  List<Futures>? fut;
  List<OptionExp>? optExp;

  LinkedScrips(
      {this.requestTime, this.stat, this.equls, this.fut, this.optExp});

  LinkedScrips.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    if (json['equls'] != null) {
      equls = <Equls>[];
      json['equls'].forEach((v) {
        equls!.add(Equls.fromJson(v));
      });
    }
    if (json['fut'] != null) {
      fut = <Futures>[];
      json['fut'].forEach((v) {
        fut!.add(Futures.fromJson(v));
      });
    }
    if (json['opt_exp'] != null) {
      optExp = <OptionExp>[];
      json['opt_exp'].forEach((v) {
        optExp!.add(OptionExp.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    if (equls != null) {
      data['equls'] = equls!.map((v) => v.toJson()).toList();
    }
    if (fut != null) {
      data['fut'] = fut!.map((v) => v.toJson()).toList();
    }
    if (optExp != null) {
      data['opt_exp'] = optExp!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Equls {
  String? exch;
  String? token;
  String? tsym;
  String? pp;
  String? ti;
  String? ls;
  String? mult;

  Equls(
      {this.exch, this.token, this.tsym, this.pp, this.ti, this.ls, this.mult});

  Equls.fromJson(Map<String, dynamic> json) {
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    pp = json['pp'];
    ti = json['ti'];
    ls = json['ls'];
    mult = json['mult'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['pp'] = pp;
    data['ti'] = ti;
    data['ls'] = ls;
    data['mult'] = mult;
    return data;
  }
}

class Futures {
  String? exch;
  String? token;
  String? tsym;
  String? pp;
  String? ls;
  String? ti;
  String? mult;
  String? exd;
    String? high;
  String? low;
  String? close;
  String? ltp;
  String? change; 
  String? perChange;
  String? open;
   String? symbol;
  String? expDate;
  String? option;

  Futures(
      {this.exch,
      this.token,
      this.tsym,
      this.pp,
      this.ls,
      this.ti,
      this.mult,
      this.exd,
      
      this.change,
      this.close,
      this.high,
      this.low,
      this.ltp,this.open,this.perChange,this.expDate,
      this.option,
      this.symbol
      });

  Futures.fromJson(Map<String, dynamic> json) {
        high= json['high'].toString();
        low=json['low'].toString();
        close= json['close'];
        ltp= json['ltp'];
        change=json['Change'].toString();
       
        perChange=json['PerChange'].toString();
        open=json['open'].toString();
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    pp = json['pp'];
    ls = json['ls'];
    ti = json['ti'];
    mult = json['mult'];
    exd = json['exd']; expDate=json['expDate'];
        symbol= json['symbol'].toString().toUpperCase();
        option= json['option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
        data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['ltp'] = ltp;
    data['Change'] = change;
 
    data['PerChange'] = perChange;
    data['open'] = open;
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['mult'] = mult;
    data['exd'] = exd;
        data['option'] = option;
    data['expDate'] = expDate;
    data['symbol'] = symbol;
    return data;
  }
}

class OptionExp {
  String? exd;
  String? tsym;
  String? exch;

  OptionExp({this.exd, this.tsym, this.exch});

  OptionExp.fromJson(Map<String, dynamic> json) {
    exd = json['exd'];
    tsym = json['tsym'];
    exch = json['exch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exd'] = exd;
    data['tsym'] = tsym;
    data['exch'] = exch;
    return data;
  }
}

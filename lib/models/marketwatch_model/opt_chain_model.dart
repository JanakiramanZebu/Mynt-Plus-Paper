class OptionChainModel {
  String? stat;
  String? emsg;
  List<OptionValues>? optValue;

  OptionChainModel({this.stat, this.emsg, this.optValue});

  OptionChainModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    emsg = json['emsg'];
    if (json['values'] != null) {
      optValue = <OptionValues>[];
      json['values'].forEach((v) {
        optValue!.add(OptionValues.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['emsg'] = emsg;
    if (optValue != null) {
      data['values'] = optValue!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OptionValues {
  String? exch;
  String? token;
  String? tsym;
  String? optt;
  String? pp;
  String? ls;
  String? ti;
  String? lp;
  String? perChange;
    String? close;
  String? oi;
  String? poi;
  String? strprc;
  String? oiLack;
  String? oiPerChng;
  String? symbol;
String?expDate;
String? option;
  OptionValues(
      {this.exch,
      this.token,
      this.tsym,
      this.optt,
      this.pp,
      this.ls,
      this.ti,
      this.lp,
      this.perChange,
      this.oi,
      this.oiLack,
      this.poi,
      this.close,
      this.oiPerChng,
      this.strprc ,this.expDate,
      this.option,this.symbol});

  OptionValues.fromJson(Map<String, dynamic> json) {
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    optt = json['optt'];
    pp = json['pp'];
    ls = json['ls'];
    close=json["close"];
    ti = json['ti'];
    lp = json['lp'];
    perChange = json['perChange'];
    oi = json['oi'];
    poi = json['poi'];
    oiPerChng = json['oiPerChng'];
    oiLack = json['oiLack'];
    strprc = json['strprc'];
    expDate=json['expDate'];
        symbol=json['symbol'];option= json['option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['optt'] = optt;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['oiLack'] = oiLack;
    data['lp'] = lp;
    data['perChange'] = perChange;
    data['oi'] = oi;
    data['poi'] = poi;
    data['strprc'] = strprc;
    data['oiPerChng'] = oiPerChng;
data['close']=close;
    data['option']=option;
    data['expDate']=expDate;
    data['symbol']=symbol; 
    return data;
  }
}

class OptionChainArguments {
  String token;
  String symbol;
  String lp;
  String perChng;
  String exch;
  OptionChainArguments(
      {required this.token,
      required this.symbol,
      required this.lp,
      required this.exch,
      required this.perChng});
}

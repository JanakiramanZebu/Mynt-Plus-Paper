class SearchScripModel {
  String? stat;
  List<ScripValue>? values;
  String? emsg;
  SearchScripModel({this.stat, this.values});

  SearchScripModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['values'] != null) {
      values = <ScripValue>[];
      json['values'].forEach((v) {
        values!.add(ScripValue.fromJson(v));
      });
    }
    emsg = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    data['emsg'] = emsg;
    return data;
  }
}

class ScripValue {
  String? cname;
  String? exch;
  String? instname;
  String? ls;
  String? pp;
  String? ti;
  String? token;
  String? tsym;
  String? optt;
  String? weekly;
  bool? isAdded;
  String? symbol;
  String? expDate;
  String? option;
  String? dname;

  ScripValue(
      {this.cname,
      this.exch,
      this.instname,
      this.ls,
      this.pp,
      this.ti,
      this.token,
      this.tsym,
      this.optt,
      this.dname,
      this.weekly,
      this.isAdded,
      this.expDate,
      this.option,
      this.symbol});

  ScripValue.fromJson(Map<String, dynamic> json) {
    cname = json['cname'];
    exch = json['exch'];
    instname = json['instname'];
    ls = json['ls'];
    pp = json['pp'];
    ti = json['ti'];
    token = json['token'];
    tsym = json['tsym'];
    optt = json['optt'];
    dname = json['dname'];
    weekly = json['weekly'];
    isAdded = isAdded == null ? false : json['isAdded'];
    expDate = json['expDate'];
    symbol = json['symbol'];
    option = json['option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cname'] = cname;
    data['exch'] = exch;
    data['instname'] = instname;
    data['ls'] = ls;
    data['pp'] = pp;
    data['ti'] = ti;
    data['token'] = token;
    data['tsym'] = tsym;
    data['optt'] = optt;
    data['weekly'] = weekly;
    data['dname'] = dname;
    data['isAdded'] = isAdded;
    data['option'] = option;
    data['expDate'] = expDate;
    data['symbol'] = symbol;
    return data;
  }
}

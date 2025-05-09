class SearchScripNewModel {
  String? stat;
  List<ScripNewValue>? values;
  String? emsg;
  SearchScripNewModel({this.stat, this.values});

  SearchScripNewModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['values'] != null) {
      values = <ScripNewValue>[];
      json['values'].forEach((v) {
        values!.add(ScripNewValue.fromJson(v));
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

class ScripNewValue {
  String? exch;
  String? token;
  String? tsym;
  String? cname;
  String? dname;
  String? instname;
  String? symbol;
  String? ls;
  String? ti;
  String? marketCap;
  String? categoryKey;
  String? expiry;
  String? symbolFlag;
  String? symbolIndex;
  String? idx;
  String? sortKey;
  String? sortKey1;
  String? remain1;
  String? remain;
  String? remain2;
  String? priorityCol;
  String? futKey;

  String? optt;
  String? weekly;
  bool? isAdded;
  String? expDate;
  String? option;

  ScripNewValue({
    this.exch,
    this.token,
    this.tsym,
    this.cname,
    this.dname,
    this.instname,
    this.symbol,
    this.ls,
    this.ti,
    this.marketCap,
    this.categoryKey,
    this.expiry,
    this.symbolFlag,
    this.symbolIndex,
    this.idx,
    this.sortKey,
    this.sortKey1,
    this.remain1,
    this.remain,
    this.remain2,
    this.priorityCol,
    this.futKey,
    this.optt,
    this.weekly,
    this.isAdded,
    this.expDate,
    this.option,
  });

  ScripNewValue.fromJson(Map<String, dynamic> json) {
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    cname = json['cname'];
    dname = json['dname'];
    instname = json['instname'];
    symbol = json['symname'];
    ls = json['ls'];
    ti = json['ti'];
    marketCap = json['market_cap']?.toString();
    categoryKey = json['category_key']?.toString();
    expiry = json['Expiry']?.toString();
    symbolFlag = json['symbol_flag']?.toString();
    symbolIndex = json['Symbol_Index']?.toString();
    idx = json['idx']?.toString();
    sortKey = json['sort_key']?.toString();
    sortKey1 = json['sort_key1']?.toString();
    remain1 = json['remain1']?.toString();
    remain = json['remain']?.toString();
    remain2 = json['remain2']?.toString();
    priorityCol = json['priority_col']?.toString();
    futKey = json['fut_key']?.toString();

    optt = json['OptionType'];
    weekly = json['weekly'];
    isAdded = isAdded == null ? false : json['isAdded'];
    expDate = json['expDate'];
    option = json['option'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['cname'] = cname;
    data['dname'] = dname;
    data['instname'] = instname;
    data['symname'] = symbol;
    data['ls'] = ls;
    data['ti'] = ti;
    data['market_cap'] = marketCap;
    data['category_key'] = categoryKey;
    data['Expiry'] = expiry;
    data['symbol_flag'] = symbolFlag;
    data['Symbol_Index'] = symbolIndex;
    data['idx'] = idx;
    data['sort_key'] = sortKey;
    data['sort_key1'] = sortKey1;
    data['remain1'] = remain1;
    data['remain'] = remain;
    data['remain2'] = remain2;
    data['priority_col'] = priorityCol;
    data['fut_key'] = futKey;

    data['OptionType'] = optt;
    data['weekly'] = weekly;
    data['isAdded'] = isAdded;
    data['option'] = option;
    data['expDate'] = expDate;
    return data;
  }
}

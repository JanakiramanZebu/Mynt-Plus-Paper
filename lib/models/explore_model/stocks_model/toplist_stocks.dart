class TopListStocks {
  String? stat;
  List<TopGainers>? topGainers;
  List<TopGainers>? topLosers;
  List<TopGainers>? byValue;
  List<TopGainers>? byVolume;
  String? updatedtime;

  TopListStocks(
      {this.stat,
      this.topGainers,
      this.topLosers,
      this.byValue,
      this.byVolume,
      this.updatedtime});

  TopListStocks.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['topGainers'] != null) {
      topGainers = <TopGainers>[];
      json['topGainers'].forEach((v) {
        topGainers!.add(TopGainers.fromJson(v));
      });
    }else{
      json['topGainers']=<TopGainers>[];
    }
    if (json['topLosers'] != null) {
      topLosers = <TopGainers>[];
      json['topLosers'].forEach((v) {
        topLosers!.add(TopGainers.fromJson(v));
      });
    }else{
     json['topLosers']=<TopGainers>[];
    }
    if (json['byValue'] != null) {
      byValue = <TopGainers>[];
      json['byValue'].forEach((v) {
        byValue!.add(TopGainers.fromJson(v));
      });
    }else{
        json['byValue']=<TopGainers>[];
    }
    if (json['byVolume'] != null) {
      byVolume = <TopGainers>[];
      json['byVolume'].forEach((v) {
        byVolume!.add(TopGainers.fromJson(v));
      });
    }else{
     json['byVolume']=<TopGainers>[];
    }
    updatedtime = json['updatedtime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (topGainers != null) {
      data['topGainers'] = topGainers!.map((v) => v.toJson()).toList();
    }
    if (topLosers != null) {
      data['topLosers'] = topLosers!.map((v) => v.toJson()).toList();
    }
    if (byValue != null) {
      data['byValue'] = byValue!.map((v) => v.toJson()).toList();
    }
    if (byVolume != null) {
      data['byVolume'] = byVolume!.map((v) => v.toJson()).toList();
    }
    data['updatedtime'] = updatedtime;
    return data;
  }
}

class TopGainers {
  String? c;
  String? cname;
  String? exch;
  String? lp;
  String? ls;
  String? oi;
  String? pc;
  String? pp;
  String? ti;
  String? token;
  String? tsym;
  String? v;
  String? value;

  TopGainers(
      {this.c,
      this.cname,
      this.exch,
      this.lp,
      this.ls,
      this.oi,
      this.pc,
      this.pp,
      this.ti,
      this.token,
      this.tsym,
      this.v,
      this.value});

  TopGainers.fromJson(Map<String, dynamic> json) {
    c = json['c'];
    cname = json['cname'];
    exch = json['exch'];
    lp = json['lp'];
    ls = json['ls'];
    oi = json['oi'];
    pc = json['pc'];
    pp = json['pp'];
    ti = json['ti'];
    token = json['token'];
    tsym = json['tsym'];
    v = json['v'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['c'] = c;
    data['cname'] = cname;
    data['exch'] = exch;
    data['lp'] = lp;
    data['ls'] = ls;
    data['oi'] = oi;
    data['pc'] = pc;
    data['pp'] = pp;
    data['ti'] = ti;
    data['token'] = token;
    data['tsym'] = tsym;
    data['v'] = v;
    data['value'] = value;
    return data;
  }
}



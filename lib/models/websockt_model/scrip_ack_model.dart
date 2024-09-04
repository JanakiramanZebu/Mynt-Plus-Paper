class ScripAckData {
  String? t;
  String? pp;
  String? ml;
  String? e;
  String? tk;
  String? ts;
  String? ls;
  String? ti;
  String? c;
  String? lp;
  String? pc;
  String? ft;
  String? o;
  String? h;
  String? l;
  String? toi;
  String? oi;
  String? bp1;
  String? sp1;
  String? bq1;
  String? sq1;
  String? ap;
  String? v;
  String? poi;

  ScripAckData(
      {this.t,
      this.pp,
      this.ml,
      this.e,
      this.tk,
      this.ts,
      this.ls,
      this.ti,
      this.c,
      this.lp,
      this.pc,
      this.ft,
      this.o,
      this.h,
      this.l,
      this.toi,
      this.oi,
      this.bp1,
      this.sp1,
      this.bq1,
      this.sq1,
      this.ap,
      this.v,
      this.poi});

  ScripAckData.fromJson(Map<String, dynamic> json) {
    t = json['t'];
    pp = json['pp'];
    ml = json['ml'];
    e = json['e'];
    tk = json['tk'];
    ts = json['ts'];
    ls = json['ls'];
    ti = json['ti'];
    c = json['c'];
    lp = json['lp'];
    pc = json['pc'];
    ft = json['ft'];
    o = json['o'];
    h = json['h'];
    l = json['l'];
    toi = json['toi'];
    oi = json['oi'];
    bp1 = json['bp1'];
    sp1 = json['sp1'];
    bq1 = json['bq1'];
    sq1 = json['sq1'];
    ap = json['ap'];
    v = json['v'];
    poi = json['poi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['t'] = t;
    data['pp'] = pp;
    data['ml'] = ml;
    data['e'] = e;
    data['tk'] = tk;
    data['ts'] = ts;
    data['ls'] = ls;
    data['ti'] = ti;
    data['c'] = c;
    data['lp'] = lp;
    data['pc'] = pc;
    data['ft'] = ft;
    data['o'] = o;
    data['h'] = h;
    data['l'] = l;
    data['toi'] = toi;
    data['oi'] = oi;
    data['bp1'] = bp1;
    data['sp1'] = sp1;
    data['bq1'] = bq1;
    data['sq1'] = sq1;
    data['ap'] = ap;
    data['v'] = v;
    data['poi'] = poi;
    return data;
  }
}




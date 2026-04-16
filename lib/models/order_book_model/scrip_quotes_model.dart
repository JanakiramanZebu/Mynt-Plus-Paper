class ScripQuotesModel {
  String? requestTime;
  String? stat;
  String? exch;
  String? tsym;
  String? symname;
  String? seg;
  String? exd;
  String? instname;
  String? optt;
  String? pp;
  String? ls;
  String? ti;
  String? mult;
  String? lut;
  String? uc;
  String? lc;
  String? wk52H;
  String? wk52L;
  String? oi;
  String? strprc;
  String? prcftrD;
  String? token;
  String? lp;
  String? c;
  String? h;
  String? l;
  String? ap;
  String? o;
  String? v;
  String? ltq;
  String? ltt;
  String? tbq;
  String? tsq;
  String? bp1;
  String? sp1;
  String? bp2;
  String? sp2;
  String? bp3;
  String? sp3;
  String? bp4;
  String? sp4;
  String? bp5;
  String? sp5;
  String? bq1;
  String? sq1;
  String? bq2;
  String? sq2;
  String? bq3;
  String? sq3;
  String? bq4;
  String? sq4;
  String? bq5;
  String? sq5;
  String? bo1;
  String? so1;
  String? bo2;
  String? so2;
  String? bo3;
  String? so3;
  String? bo4;
  String? so4;
  String? bo5;
  String? so5;

  ScripQuotesModel(
      {this.requestTime,
      this.stat,
      this.exch,
      this.tsym,
      this.symname,
      this.seg,
      this.exd,
      this.instname,
      this.optt,
      this.pp,
      this.ls,
      this.ti,
      this.mult,
      this.lut,
      this.uc,
      this.lc,
      this.wk52H,
      this.wk52L,
      this.oi,
      this.strprc,
      this.prcftrD,
      this.token,
      this.lp,
      this.c,
      this.h,
      this.l,
      this.ap,
      this.o,
      this.v,
      this.ltq,
      this.ltt,
      this.tbq,
      this.tsq,
      this.bp1,
      this.sp1,
      this.bp2,
      this.sp2,
      this.bp3,
      this.sp3,
      this.bp4,
      this.sp4,
      this.bp5,
      this.sp5,
      this.bq1,
      this.sq1,
      this.bq2,
      this.sq2,
      this.bq3,
      this.sq3,
      this.bq4,
      this.sq4,
      this.bq5,
      this.sq5,
      this.bo1,
      this.so1,
      this.bo2,
      this.so2,
      this.bo3,
      this.so3,
      this.bo4,
      this.so4,
      this.bo5,
      this.so5});

  ScripQuotesModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    exch = json['exch'];
    tsym = json['tsym'];
    symname = json['symname'];
    seg = json['seg'];
    exd = json['exd'];
    instname = json['instname'];
    optt = json['optt'];
    pp = json['pp'];
    ls = json['ls'];
    ti = json['ti'];
    mult = json['mult'];
    lut = json['lut'];
    uc = json['uc'];
    lc = json['lc'];
    wk52H = json['wk52_h'];
    wk52L = json['wk52_l'];
    oi = json['oi'];
    strprc = json['strprc'];
    prcftrD = json['prcftr_d'];
    token = json['token'];
    lp = json['lp'];
    c = json['c'];
    h = json['h'];
    l = json['l'];
    ap = json['ap'];
    o = json['o'];
    v = json['v'];
    ltq = json['ltq'];
    ltt = json['ltt'];
    tbq = json['tbq'];
    tsq = json['tsq'];
    bp1 = json['bp1'];
    sp1 = json['sp1'];
    bp2 = json['bp2'];
    sp2 = json['sp2'];
    bp3 = json['bp3'];
    sp3 = json['sp3'];
    bp4 = json['bp4'];
    sp4 = json['sp4'];
    bp5 = json['bp5'];
    sp5 = json['sp5'];
    bq1 = json['bq1'];
    sq1 = json['sq1'];
    bq2 = json['bq2'];
    sq2 = json['sq2'];
    bq3 = json['bq3'];
    sq3 = json['sq3'];
    bq4 = json['bq4'];
    sq4 = json['sq4'];
    bq5 = json['bq5'];
    sq5 = json['sq5'];
    bo1 = json['bo1'];
    so1 = json['so1'];
    bo2 = json['bo2'];
    so2 = json['so2'];
    bo3 = json['bo3'];
    so3 = json['so3'];
    bo4 = json['bo4'];
    so4 = json['so4'];
    bo5 = json['bo5'];
    so5 = json['so5'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['exch'] = exch;
    data['tsym'] = tsym;
    data['symname'] = symname;
    data['seg'] = seg;
    data['exd'] = exd;
    data['instname'] = instname;
    data['optt'] = optt;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['mult'] = mult;
    data['lut'] = lut;
    data['uc'] = uc;
    data['lc'] = lc;
    data['wk52_h'] = wk52H;
    data['wk52_l'] = wk52L;
    data['oi'] = oi;
    data['strprc'] = strprc;
    data['prcftr_d'] = prcftrD;
    data['token'] = token;
    data['lp'] = lp;
    data['c'] = c;
    data['h'] = h;
    data['l'] = l;
    data['ap'] = ap;
    data['o'] = o;
    data['v'] = v;
    data['ltq'] = ltq;
    data['ltt'] = ltt;
    data['tbq'] = tbq;
    data['tsq'] = tsq;
    data['bp1'] = bp1;
    data['sp1'] = sp1;
    data['bp2'] = bp2;
    data['sp2'] = sp2;
    data['bp3'] = bp3;
    data['sp3'] = sp3;
    data['bp4'] = bp4;
    data['sp4'] = sp4;
    data['bp5'] = bp5;
    data['sp5'] = sp5;
    data['bq1'] = bq1;
    data['sq1'] = sq1;
    data['bq2'] = bq2;
    data['sq2'] = sq2;
    data['bq3'] = bq3;
    data['sq3'] = sq3;
    data['bq4'] = bq4;
    data['sq4'] = sq4;
    data['bq5'] = bq5;
    data['sq5'] = sq5;
    data['bo1'] = bo1;
    data['so1'] = so1;
    data['bo2'] = bo2;
    data['so2'] = so2;
    data['bo3'] = bo3;
    data['so3'] = so3;
    data['bo4'] = bo4;
    data['so4'] = so4;
    data['bo5'] = bo5;
    data['so5'] = so5;
    return data;
  }
}

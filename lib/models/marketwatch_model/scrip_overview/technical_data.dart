class TechnicalData {
  String? requestTime;
  String? stat;
  String? tsym;
  String? lp;
  String? ltt;
  String? pc;
  String? h;
  String? l;
  String? wk1H;
  String? wk1L;
  String? wk2H;
  String? wk2L;
  String? wk52H;
  String? wk52L;
  String? mnth1H;
  String? mnth1L;
  String? mnth3H;
  String? mnth3L;
  String? res1;
  String? res2;
  String? res3;
  String? sup1;
  String? sup2;
  String? sup3;
  String? pivotPoint;
  String? wk1C;
  String? wk2C;
  String? wk52C;
  String? mnth1C;
  String? mnth3C;
  String? emsg;
  String? wk1Pc;
  String? wk2Pc;
  String? mnth1Pc;
  String? mnth3Pc;
  String? wk52Pc;

  TechnicalData(
      {this.requestTime,
      this.stat,
      this.tsym,
      this.lp,
      this.ltt,
      this.pc,
      this.h,
      this.l,
      this.wk1H,
      this.wk1L,
      this.wk2H,
      this.wk2L,
      this.wk52H,
      this.wk52L,
      this.mnth1H,
      this.mnth1L,
      this.mnth3H,
      this.mnth3L,
      this.res1,
      this.res2,
      this.res3,
      this.sup1,
      this.sup2,
      this.sup3,
      this.pivotPoint,
      this.wk1C,
      this.wk2C,
      this.wk52C,
      this.mnth1C,
      this.mnth3C,
      this.emsg,
      this.wk1Pc,
      this.wk2Pc,
      this.mnth1Pc,
      this.mnth3Pc,
      this.wk52Pc});

  TechnicalData.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    tsym = json['tsym'];
    lp = json['lp'];
    ltt = json['ltt'];
    pc = json['pc'];
    h = json['h'];
    l = json['l'];
    wk1H = json['wk1_h'];
    wk1L = json['wk1_l'];
    wk2H = json['wk2_h'];
    wk2L = json['wk2_l'];
    wk52H = json['wk52_h'];
    wk52L = json['wk52_l'];
    mnth1H = json['mnth1_h'];
    mnth1L = json['mnth1_l'];
    mnth3H = json['mnth3_h'];
    mnth3L = json['mnth3_l'];
    res1 = json['res_1'];
    res2 = json['res_2'];
    res3 = json['res_3'];
    sup1 = json['sup_1'];
    sup2 = json['sup_2'];
    sup3 = json['sup_3'];
    pivotPoint = json['pivot_point'];
    wk1C = json['wk1_c'];
    wk2C = json['wk2_c'];
    wk52C = json['wk52_c'];
    mnth1C = json['mnth1_c'];
    mnth3C = json['mnth3_c'];
    emsg = json['emsg'];
    wk1Pc = json['wk1Pc'];
    wk2Pc = json['wk2Pc'];
    mnth1Pc = json['mnth1Pc'];
    mnth3Pc = json['mnth3Pc'];
    wk52Pc = json['wk52Pc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['tsym'] = tsym;
    data['lp'] = lp;
    data['ltt'] = ltt;
    data['pc'] = pc;
    data['h'] = h;
    data['l'] = l;
    data['wk1_h'] = wk1H;
    data['wk1_l'] = wk1L;
    data['wk2_h'] = wk2H;
    data['wk2_l'] = wk2L;
    data['wk52_h'] = wk52H;
    data['wk52_l'] = wk52L;
    data['mnth1_h'] = mnth1H;
    data['mnth1_l'] = mnth1L;
    data['mnth3_h'] = mnth3H;
    data['mnth3_l'] = mnth3L;
    data['res_1'] = res1;
    data['res_2'] = res2;
    data['res_3'] = res3;
    data['sup_1'] = sup1;
    data['sup_2'] = sup2;
    data['sup_3'] = sup3;
    data['pivot_point'] = pivotPoint;
    data['wk1_c'] = wk1C;
    data['wk2_c'] = wk2C;
    data['wk52_c'] = wk52C;
    data['mnth1_c'] = mnth1C;
    data['mnth3_c'] = mnth3C;
    data['emsg'] = emsg;

    data['wk1Pc'] = wk1Pc;
    data['wk2Pc'] = wk2Pc;
    data['mnth1Pc'] = mnth1Pc;
    data['mnth3Pc'] = mnth3Pc;
    data['wk52Pc'] = wk52Pc;
    return data;
  }
}

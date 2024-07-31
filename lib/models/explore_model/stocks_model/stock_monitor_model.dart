class StockMoniterModel {
  String? ap;
  String? c;
  String? exch;
  String? h;
  String? l;
  String? lp;
  String? ltt;
  String? pc;
   String? chng;
  String? priChngPerc;
  String? requestTime;
  String? stat;
  String? token;
  String? tsym;
  String? v;
  String? vp;
  String? emsg;

  StockMoniterModel(
      {this.ap,
      this.c,
      this.exch,
      this.h,
      this.l,
      this.lp,
      this.ltt,
      this.pc,
      this.priChngPerc,
      this.requestTime,
      this.stat,
      this.token,
      this.tsym,
      this.v,
      this.vp,
      this.emsg,this.chng});

  StockMoniterModel.fromJson(Map<String, dynamic> json) {
    ap = json['ap'];
    c = json['c'];
    exch = json['exch'];
    h = json['h'];
    l = json['l'];
    lp = json['lp'];
    ltt = json['ltt'];
    pc = json['pc'];
    priChngPerc = json['pri_chng_perc'];
    requestTime = json['request_time'];
    stat = json['stat'];
    token = json['token'];
    tsym = json['tsym'];
    v = json['v'];
    vp = json['vp'];
    emsg = json['emsg'];
    chng=json['chng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ap'] = ap;
    data['c'] = c;
    data['exch'] = exch;
    data['h'] = h;
    data['l'] = l;
    data['lp'] = lp;
    data['ltt'] = ltt;
    data['pc'] = pc;
    data['pri_chng_perc'] = priChngPerc;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['token'] = token;
    data['tsym'] = tsym;
    data['v'] = v;
    data['vp'] = vp;
    data['emsg'] = emsg;
    data['chng']=chng;
    return data;
  }
}

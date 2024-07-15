class AlertPendingModel {
  String? stat;
  String? aiT;
  String? alId;
  String? tsym;
  String? exch;
  String? token;
  String? remarks;
  String? norentm;
  String? validity;
  String? instname;
  String? pp;
  String? ls;
  String? ti;
  String? d;
  String? ltp;
  String? change;
  String? close;
  String? perChange;


  AlertPendingModel({
    this.stat,
    this.aiT,
    this.alId,
    this.tsym,
    this.exch,
    this.token,
    this.remarks,
    this.norentm,
    this.validity,
    this.instname,
    this.pp,
    this.ls,
    this.ti,
    this.d,
    this.ltp,
    this.change,
    this.close,
    this.perChange,
  });


  AlertPendingModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    aiT = json['ai_t'];
    alId = json['al_id'];
    tsym = json['tsym'];
    exch = json['exch'];
    token = json['token'];
    remarks = json['remarks'];
    norentm = json['norentm'];
    validity = json['validity'];
    instname = json['instname'];
    pp = json['pp'];
    ls = json['ls'];
    ti = json['ti'];
    d = json['d'];
    ltp = json['ltp'];
    change = json['change'];
    close = json['close'];
    perChange = json['perChange'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['ai_t'] = aiT;
    data['al_id'] = alId;
    data['tsym'] = tsym;
    data['exch'] = exch;
    data['token'] = token;
    data['remarks'] = remarks;
    data['norentm'] = norentm;
    data['validity'] = validity;
    data['instname'] = instname;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['d'] = d;
    data['ltp'] = ltp;
    data['change'] = change;
    data['close'] = close;
    data['perChange'] = perChange;
    return data;
  }
}




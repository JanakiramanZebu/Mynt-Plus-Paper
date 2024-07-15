class MFHoldingsModel {
  String? requestTime;
  String? stat;
  String? actid;
  String? prd;
  List<ExchTsym>? exchTsym;
  String? uploadPrc;
  String? invested;
  String? holdqty;
  String? colqty;
  String? colMode;
  String? hairCut;
  String? c;
  String? collateral;
  String? usedqty;
  String? emsg;
  String? currentVal;

  MFHoldingsModel(
      {this.requestTime,
      this.stat,
      this.actid,
      this.prd,
      this.exchTsym,
      this.uploadPrc,
      this.holdqty,
      this.colqty,
      this.colMode,
      this.hairCut,
      this.c,
      this.collateral,
      this.usedqty,
      this.invested,
      this.emsg,
      this.currentVal});

  MFHoldingsModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    actid = json['actid'];
    prd = json['prd'];
    if (json['exch_tsym'] != null) {
      exchTsym = <ExchTsym>[];
      json['exch_tsym'].forEach((v) {
        exchTsym!.add(ExchTsym.fromJson(v));
      });
    }
    uploadPrc = json['upload_prc'];
    holdqty = json['holdqty'];
    colqty = json['colqty'];
    colMode = json['col_mode'];
    hairCut = json['hair_cut'];
    c = json['c'];
    collateral = json['collateral'];
    usedqty = json['usedqty'];
    invested = json['invested'];
    emsg = json['emsg'];
    currentVal = json['currentVal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['actid'] = actid;
    data['prd'] = prd;
    if (exchTsym != null) {
      data['exch_tsym'] = exchTsym!.map((v) => v.toJson()).toList();
    }
    data['upload_prc'] = uploadPrc;
    data['holdqty'] = holdqty;
    data['colqty'] = colqty;
    data['col_mode'] = colMode;
    data['hair_cut'] = hairCut;
    data['c'] = c;
    data['collateral'] = collateral;
    data['usedqty'] = usedqty;
    data['emsg'] = emsg;
    data['invested'] = invested;
    data['currentVal'] = currentVal;
    return data;
  }
}

class ExchTsym {
  String? exch;
  String? token;
  String? tsym;
  String? cname;
  String? isin;
  String? pp;
  String? ti;
  String? nav;
   String? pnl;
    String? pnlPerChng;

  ExchTsym(
      {this.exch,
      this.token,
      this.tsym,
      this.cname,
      this.isin,this.nav,
      this.pp,
      this.ti,this.pnl,this.pnlPerChng});

  ExchTsym.fromJson(Map<String, dynamic> json) {
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    cname = json['cname'];
    isin = json['isin'];
    pp = json['pp'];
    ti = json['ti'];
    nav = json['nav'];
    pnl=json['pnl'];
    pnlPerChng=json['pnlPerChng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['cname'] = cname;
    data['isin'] = isin;
    data['pp'] = pp;
    data['nav'] = nav;
    data['ti'] = ti;
    data['pnl']=pnl;
    data['pnlPerChng']=pnlPerChng;
    return data;
  }
}

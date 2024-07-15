class MFQuotes {
  String? requestTime;
  String? stat;
  String? emsg;
  String? exch;
  String? tsym;
  String? cname;
  String? symname;
  String? seg;
  String? instname;
  String? optt;
  String? isin;
  String? pp;
  String? ls;
  String? ti;
  String? mult;
  String? prcftrD;
  String? token;
  String? nav;
  String? sipInd;
  String? minLotSize;
  String? minRdQty;
  String? multRdQty;
  String? boMinPrice;
  String? boMaxPrice;
  String? conProdId;

  MFQuotes(
      {this.requestTime,
      this.stat,
      this.emsg,
      this.exch,
      this.tsym,
      this.cname,
      this.symname,
      this.seg,
      this.instname,
      this.optt,
      this.isin,
      this.pp,
      this.ls,
      this.ti,
      this.mult,
      this.prcftrD,
      this.token,
      this.nav,
      this.sipInd,
      this.minLotSize,
      this.minRdQty,
      this.multRdQty,
      this.boMinPrice,
      this.boMaxPrice,
      this.conProdId});

  MFQuotes.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
    exch = json['exch'];
    tsym = json['tsym'];
    cname = json['cname'];
    symname = json['symname'];
    seg = json['seg'];
    instname = json['instname'];
    optt = json['optt'];
    isin = json['isin'];
    pp = json['pp'];
    ls = json['ls'];
    ti = json['ti'];
    mult = json['mult'];
    prcftrD = json['prcftr_d'];
    token = json['token'];
    nav = json['nav'];
    sipInd = json['sip_ind'];
    minLotSize = json['min_lot_size'];
    minRdQty = json['min_rd_qty'];
    multRdQty = json['mult_rd_qty'];
    boMinPrice = json['bo_min_price'];
    boMaxPrice = json['bo_max_price'];
    conProdId = json['con_prod_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['exch'] = exch;
    data['tsym'] = tsym;
    data['cname'] = cname;
    data['symname'] = symname;
    data['seg'] = seg;
    data['instname'] = instname;
    data['optt'] = optt;
    data['isin'] = isin;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['mult'] = mult;
    data['prcftr_d'] = prcftrD;
    data['token'] = token;
    data['nav'] = nav;
    data['sip_ind'] = sipInd;
    data['min_lot_size'] = minLotSize;
    data['min_rd_qty'] = minRdQty;
    data['mult_rd_qty'] = multRdQty;
    data['bo_min_price'] = boMinPrice;
    data['bo_max_price'] = boMaxPrice;
    data['con_prod_id'] = conProdId;
    return data;
  }
}

class mf_order_sig_det {
  Data? data;
  String? stat;
    String? msg;

  mf_order_sig_det({this.data, this.stat,this.msg});

  mf_order_sig_det.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    stat = json['stat'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['stat'] = this.stat;
    return data;
  }
}

class Data {
  String? amcCode;
  String? amount;
  String? buysell;
  String? date;
  String? dateTime;
  String? dptrans;
  String? enddate;
  String? foliono;
  String? frequencytype;
  String? isin;
  String? noofinstallment;
  String? ordernumber;
  String? orderremarks;
  String? orderstatus;
  String? ordertype;
  String? schemeCode;
  String? schemename;
  String? settno;
  String? sipregndate;
  String? sipregnno;
  String? startdate;
  String? units;

  Data(
      {this.amcCode,
      this.amount,
      this.buysell,
      this.date,
      this.dateTime,
      this.dptrans,
      this.enddate,
      this.foliono,
      this.frequencytype,
      this.isin,
      this.noofinstallment,
      this.ordernumber,
      this.orderremarks,
      this.orderstatus,
      this.ordertype,
      this.schemeCode,
      this.schemename,
      this.settno,
      this.sipregndate,
      this.sipregnno,
      this.startdate,
      this.units});

  Data.fromJson(Map<String, dynamic> json) {
    amcCode = json['amc_code'];
    amount = json['amount'];
    buysell = json['buysell'];
    date = json['date'];
    dateTime = json['date_time'];
    dptrans = json['dptrans'];
    enddate = json['enddate'];
    foliono = json['foliono'];
    frequencytype = json['frequencytype'];
    isin = json['isin'];
    noofinstallment = json['noofinstallment'];
    ordernumber = json['ordernumber'];
    orderremarks = json['orderremarks'];
    orderstatus = json['orderstatus'];
    ordertype = json['ordertype'];
    schemeCode = json['scheme_code'];
    schemename = json['schemename'];
    settno = json['settno'];
    sipregndate = json['sipregndate'];
    sipregnno = json['sipregnno'];
    startdate = json['startdate'];
    units = json['units'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amc_code'] = this.amcCode;
    data['amount'] = this.amount;
    data['buysell'] = this.buysell;
    data['date'] = this.date;
    data['date_time'] = this.dateTime;
    data['dptrans'] = this.dptrans;
    data['enddate'] = this.enddate;
    data['foliono'] = this.foliono;
    data['frequencytype'] = this.frequencytype;
    data['isin'] = this.isin;
    data['noofinstallment'] = this.noofinstallment;
    data['ordernumber'] = this.ordernumber;
    data['orderremarks'] = this.orderremarks;
    data['orderstatus'] = this.orderstatus;
    data['ordertype'] = this.ordertype;
    data['scheme_code'] = this.schemeCode;
    data['schemename'] = this.schemename;
    data['settno'] = this.settno;
    data['sipregndate'] = this.sipregndate;
    data['sipregnno'] = this.sipregnno;
    data['startdate'] = this.startdate;
    data['units'] = this.units;
    return data;
  }
}

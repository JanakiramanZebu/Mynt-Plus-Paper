class mf_order_sig_det {
  List<Data>? data;
  String? stat;
  String? emsg;

  mf_order_sig_det({this.data, this.stat,this.emsg});

  mf_order_sig_det.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = this.stat;
    data['emsg'] = this.emsg;
    return data;
  }
}

class Data {
  String? transCode;
  String? transNo;
  String? orderId;
  String? userId;
  String? memberCode;
  String? clientCode;
  String? remarks;
  String? status;
  String? name;
  String? stat;
  String? source;
  String? placedBy;
  String? iPAddress;
  String? datetime;
  String? orderVal;
  String? folioNo;
  String? iSIN;
  String? dPFolioNo;
  String? settType;
  String? orderType;
  String? subOrderType;
  String? buySell;
  String? allRedeem;
  String? accVPA;
  String? paymentType;

  Data(
      {this.transCode,
      this.transNo,
      this.orderId,
      this.userId,
      this.memberCode,
      this.clientCode,
      this.remarks,
      this.status,
      this.name,
      this.stat,
      this.source,
      this.placedBy,
      this.iPAddress,
      this.datetime,
      this.orderVal,
      this.folioNo,
      this.iSIN,
      this.dPFolioNo,
      this.settType,
      this.orderType,
      this.subOrderType,
      this.buySell,
      this.allRedeem,this.accVPA,this.paymentType});

  Data.fromJson(Map<String, dynamic> json) {
    transCode = json['TransCode'];
    transNo = json['TransNo'];
    orderId = json['OrderId'];
    userId = json['UserId'];
    memberCode = json['MemberCode'];
    clientCode = json['ClientCode'];
    remarks = json['Remarks'];
    status = json['status'];
    name = json['name'];
    stat = json['stat'];
    source = json['source'];
    placedBy = json['placed_by'];
    iPAddress = json['IPAddress'];
    datetime = json['datetime'];
    orderVal = json['OrderVal'];
    folioNo = json['FolioNo'];
    iSIN = json['ISIN'];
    dPFolioNo = json['DPFolioNo'];
    settType = json['SettType'];
    orderType = json['OrderType'];
    subOrderType = json['SubOrderType'];
    buySell = json['buy_sell'];
    allRedeem = json['AllRedeem'];
    accVPA = json['AccVPA'];
    paymentType = json['PaymentType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TransCode'] = this.transCode;
    data['TransNo'] = this.transNo;
    data['OrderId'] = this.orderId;
    data['UserId'] = this.userId;
    data['MemberCode'] = this.memberCode;
    data['ClientCode'] = this.clientCode;
    data['Remarks'] = this.remarks;
    data['status'] = this.status;
    data['name'] = this.name;
    data['stat'] = this.stat;
    data['source'] = this.source;
    data['placed_by'] = this.placedBy;
    data['IPAddress'] = this.iPAddress;
    data['datetime'] = this.datetime;
    data['OrderVal'] = this.orderVal;
    data['FolioNo'] = this.folioNo;
    data['ISIN'] = this.iSIN;
    data['DPFolioNo'] = this.dPFolioNo;
    data['SettType'] = this.settType;
    data['OrderType'] = this.orderType;
    data['SubOrderType'] = this.subOrderType;
    data['buy_sell'] = this.buySell;
    data['AllRedeem'] = this.allRedeem;
    data['AccVPA'] = this.accVPA;
    data['PaymentType'] = this.paymentType;
    return data;
  }
}

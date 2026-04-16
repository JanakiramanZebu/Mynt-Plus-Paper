class mf_order_sig_det {
  List<Data>? data;
  String? stat;
  String? emsg;

  mf_order_sig_det({this.data, this.stat,this.emsg});

  mf_order_sig_det.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    data['emsg'] = emsg;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TransCode'] = transCode;
    data['TransNo'] = transNo;
    data['OrderId'] = orderId;
    data['UserId'] = userId;
    data['MemberCode'] = memberCode;
    data['ClientCode'] = clientCode;
    data['Remarks'] = remarks;
    data['status'] = status;
    data['name'] = name;
    data['stat'] = stat;
    data['source'] = source;
    data['placed_by'] = placedBy;
    data['IPAddress'] = iPAddress;
    data['datetime'] = datetime;
    data['OrderVal'] = orderVal;
    data['FolioNo'] = folioNo;
    data['ISIN'] = iSIN;
    data['DPFolioNo'] = dPFolioNo;
    data['SettType'] = settType;
    data['OrderType'] = orderType;
    data['SubOrderType'] = subOrderType;
    data['buy_sell'] = buySell;
    data['AllRedeem'] = allRedeem;
    data['AccVPA'] = accVPA;
    data['PaymentType'] = paymentType;
    return data;
  }
}

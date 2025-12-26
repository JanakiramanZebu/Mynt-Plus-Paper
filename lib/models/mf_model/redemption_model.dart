class RedemptionModel {
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
  String? orderqty;
  String? folioNo;
  String? iSIN;
  String? dPFolioNo;
  String? emsg;

  RedemptionModel(
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
      this.orderqty,
      this.folioNo,
      this.iSIN,
      this.dPFolioNo,
      this.emsg});

  RedemptionModel.fromJson(Map<String, dynamic> json) {
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
    orderqty = json['Orderqty'];
    folioNo = json['FolioNo'];
    iSIN = json['ISIN'];
    dPFolioNo = json['DPFolioNo'];
    emsg = json['emsg'];
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
    data['Orderqty'] = orderqty;
    data['FolioNo'] = folioNo;
    data['ISIN'] = iSIN;
    data['DPFolioNo'] = dPFolioNo;
    data['emsg'] = emsg;
    return data;
  }
}

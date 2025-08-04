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
    data['Orderqty'] = this.orderqty;
    data['FolioNo'] = this.folioNo;
    data['ISIN'] = this.iSIN;
    data['DPFolioNo'] = this.dPFolioNo;
    data['emsg'] = this.emsg;
    return data;
  }
}

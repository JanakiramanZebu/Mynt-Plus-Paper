class UPIPaymentStatusCheck {
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

  UPIPaymentStatusCheck(
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
      this.orderVal});

  UPIPaymentStatusCheck.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
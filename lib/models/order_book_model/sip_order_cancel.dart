class CancleSipOrder {
  String? sipId;
  String? reqStatus;
  String? emsg;

  CancleSipOrder({this.sipId, this.reqStatus,this.emsg});

  CancleSipOrder.fromJson(Map<String, dynamic> json) {
    sipId = json['SipId'];
    reqStatus = json['ReqStatus'];
    emsg = json['Emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SipId'] = sipId;
    data['ReqStatus'] = reqStatus;
    data['Emsg'] = emsg;
    return data;
  }
}

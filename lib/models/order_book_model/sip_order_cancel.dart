class CancleSipOrder {
  String? sipId;
  String? reqStatus;


  CancleSipOrder({this.sipId, this.reqStatus});


  CancleSipOrder.fromJson(Map<String, dynamic> json) {
    sipId = json['SipId'];
    reqStatus = json['ReqStatus'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SipId'] = sipId;
    data['ReqStatus'] = reqStatus;
    return data;
  }
}

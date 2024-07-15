class SipPlaceOrderModel {
  String? reqStatus;
  String? rejreason;
  String? sipId;
  String? emsg;
  String? stat;


  SipPlaceOrderModel({this.reqStatus, this.rejreason, this.sipId, this.emsg, this.stat});


  SipPlaceOrderModel.fromJson(Map<String, dynamic> json) {
    reqStatus = json['ReqStatus'];
    rejreason = json['rejreason'];
    sipId = json['SipId'];
    emsg = json['emsg'];
    stat = json['stat'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ReqStatus'] = reqStatus;
    data['rejreason'] = rejreason;
    data['SipId'] = sipId;
    data['emsg'] = emsg;
    data['stat'] = stat;
    return data;
  }
}


class SipInputField {
  String? st;
  String? ed;
  String? frequency;
  String? sipName;
  String? exch;
  String? tsym;
  String? prd;
  String? token;
  String? qty;


  SipInputField(
      {required this.st,
      required this.ed,
      required this.frequency,
      required this.sipName,
      required this.exch,
      required this.tsym,
      required this.prd,
      required this.token,
      required this.qty});
}

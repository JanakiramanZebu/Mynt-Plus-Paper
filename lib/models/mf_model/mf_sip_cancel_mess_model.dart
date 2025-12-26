class mf_sip_cancel_message {
  String? xSIPRegId;
  String? bSERemarks;
  String? successFlag;
  String? intRefNo;
  String? stat;
  String? status;

  mf_sip_cancel_message(
      {this.xSIPRegId,
      this.bSERemarks,
      this.successFlag,
      this.intRefNo,
      this.stat,
      this.status});

  mf_sip_cancel_message.fromJson(Map<String, dynamic> json) {
    xSIPRegId = json['XSIPRegId'];
    bSERemarks = json['BSERemarks'];
    successFlag = json['SuccessFlag'];
    intRefNo = json['IntRefNo'];
    stat = json['stat'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['XSIPRegId'] = xSIPRegId;
    data['BSERemarks'] = bSERemarks;
    data['SuccessFlag'] = successFlag;
    data['IntRefNo'] = intRefNo;
    data['stat'] = stat;
    data['status'] = status;
    return data;
  }
}

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['XSIPRegId'] = this.xSIPRegId;
    data['BSERemarks'] = this.bSERemarks;
    data['SuccessFlag'] = this.successFlag;
    data['IntRefNo'] = this.intRefNo;
    data['stat'] = this.stat;
    data['status'] = this.status;
    return data;
  }
}

class mf_sip_cancel_message {
  Data? data;
  String? msg;
  String? stat;
  String? error;
   String? emsg;

  mf_sip_cancel_message({this.data, this.msg, this.stat,this.emsg,this.error});

  mf_sip_cancel_message.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
    stat = json['stat'];
    error = json['error'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    data['stat'] = this.stat;
    data['error'] = this.error;
 data['emsg'] = this.emsg;
    return data;
  }
}

class Data {
  String? bSERemarks;
  String? intRefNo;
  String? successFlag;
  String? xSIPRegId;

  Data({this.bSERemarks, this.intRefNo, this.successFlag, this.xSIPRegId});

  Data.fromJson(Map<String, dynamic> json) {
    bSERemarks = json['BSERemarks'];
    intRefNo = json['IntRefNo'];
    successFlag = json['SuccessFlag'];
    xSIPRegId = json['XSIPRegId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BSERemarks'] = this.bSERemarks;
    data['IntRefNo'] = this.intRefNo;
    data['SuccessFlag'] = this.successFlag;
    data['XSIPRegId'] = this.xSIPRegId;
    return data;
  }
}

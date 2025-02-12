class XsipOrderCancleResponces {
  Data? data;
  String? emsg;
  String? stat;

  XsipOrderCancleResponces({this.data, this.emsg, this.stat});

  XsipOrderCancleResponces.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    emsg = json['emsg'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['emsg'] = emsg;
    data['stat'] = stat;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BSERemarks'] = bSERemarks;
    data['IntRefNo'] = intRefNo;
    data['SuccessFlag'] = successFlag;
    data['XSIPRegId'] = xSIPRegId;
    return data;
  }
}

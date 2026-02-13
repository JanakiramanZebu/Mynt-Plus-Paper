class SipPlaceOrderModel {
  String? reqStatus;
  String? rejreason;
  String? sipId;
  String? emsg;
  String? stat;

  SipPlaceOrderModel(
      {this.reqStatus, this.rejreason, this.sipId, this.emsg, this.stat});

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
  String? regdate;
  String? startdate;
  String? frequency;
  String? endperiod;
  String? sipname;
  String? exch;
  String? tysm;
  String? prd;
  String? token;
  String? qty;

  SipInputField(
      {required this.regdate,
      required this.startdate,
      required this.frequency,
      required this.endperiod,
      required this.sipname,
      required this.exch,
      required this.tysm,
      required this.prd,
      required this.token,
      required this.qty});
}

class ModifySipInput {
  String? regdate;
  String? startdate;
  String? frequency;
  String? endperiod;
  String? sipname;
  String? prevExecutedate;
  String? duedate;
  String? exedate;
  String? period;
  String? active;
  String? sipId;
  String? exch;
  String? tysm;
  String? prd;
  String? token;
  String? qty;
  ModifySipInput(
      {required this.regdate,
      required this.startdate,
      required this.frequency,
      required this.endperiod,
      required this.sipname,
      required this.prevExecutedate,
      required this.duedate,
      required this.exedate,
      required this.period,
      required this.active,
      required this.sipId,
      required this.exch,
      required this.tysm,
      required this.prd,
      required this.token,
      required this.qty});
}

/// Model for creating SIP basket with multiple scrips
class SipBasketInput {
  String regdate;
  String startdate;
  String frequency;
  String endperiod;
  String sipname;
  List<SipScripInput> scrips;

  SipBasketInput({
    required this.regdate,
    required this.startdate,
    required this.frequency,
    required this.endperiod,
    required this.sipname,
    required this.scrips,
  });
}

/// Individual scrip input for SIP basket
class SipScripInput {
  String exch;
  String tsym;
  String prd;
  String token;
  String qty;
  String sipType; // 'qty' or 'amount'
  String? prc;

  SipScripInput({
    required this.exch,
    required this.tsym,
    required this.prd,
    required this.token,
    required this.qty,
    this.sipType = 'qty',
    this.prc,
  });

  Map<String, dynamic> toJson() {
    return {
      'exch': exch,
      'tsym': tsym,
      'prd': prd,
      'token': token,
      'qty': qty,
      'prc': prc ?? '',
      'sip_type': sipType,
    };
  }
}

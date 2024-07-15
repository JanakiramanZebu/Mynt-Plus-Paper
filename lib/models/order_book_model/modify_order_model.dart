class ModifyOrderModel {
  String? result;
  String? requestTime;
  String? stat;
  String? emsg;
  ModifyOrderModel({this.result, this.requestTime, this.stat,this.emsg});

  ModifyOrderModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class ModifyOrderInput {
  String exch, token;
  String tsym;
  String orderNum;
  String qty;
  String prc;
  String dscqty;
  String mktProt;
  String trgprc;
  String prctyp;
  String ret;

  ModifyOrderInput(
      {required this.dscqty,
      required this.token,
      required this.exch,
      required this.mktProt,
      required this.orderNum,
      required this.prc,
      required this.prctyp,
      required this.qty,
      required this.ret,
      required this.trgprc,
      required this.tsym});
}

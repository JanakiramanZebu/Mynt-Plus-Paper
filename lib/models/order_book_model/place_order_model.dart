class PlaceOrderModel {
  String? norenordno;
  String? requestTime;
  String? stat;
  String? emsg;
  PlaceOrderModel({this.norenordno, this.requestTime, this.stat});

  PlaceOrderModel.fromJson(Map<String, dynamic> json) {
    norenordno = json['norenordno'];
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['norenordno'] = norenordno;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class PlaceOrderInput {
  String exch;
  String tsym;
  String qty;
  String amo;
  String trgprc;
  String trailprc;
  String blprc;
  String bpprc;
  String prc;
  String dscqty;
  String prd;
  String trantype;
  String prctype;
  String ret;
  String mktProt;
  String channel;
  String userAgent;
  String appInstaId;

  PlaceOrderInput(
      {required this.amo,
      required this.exch,
      required this.qty,
      required this.tsym,
      required this.trgprc,
      required this.trailprc,
      required this.blprc,
      required this.bpprc,
      required this.prc,
      required this.dscqty,
      required this.prd,
      required this.trantype,
      required this.prctype,
      required this.ret,
      required this.mktProt, required this.channel,
      required this.userAgent,
      required this.appInstaId});
}

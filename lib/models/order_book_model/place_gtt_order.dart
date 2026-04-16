class PlaceGttOrderModel {
  String? requestTime;
  String? stat;
  String? alId;
  String? emsg;

  PlaceGttOrderModel({this.requestTime, this.stat, this.alId, this.emsg});

  PlaceGttOrderModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    alId = json['al_id'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['al_id'] = alId;
    data['emsg'] = emsg;
    return data;
  }
}

class PlaceOcoOrderInput {
  String tsym;
  String exch;
  String validity;
  String d1;
  String d2;
  String remarks;
  String trantype;
  String prctyp1;
  String prctyp2;
  String prd1;
  String prd2;
  String ret;
  String qty1;
  String qty2;
  String prc1;
  String prc2;
  String trgprc1;
  String trgprc2;
  String alid;

  PlaceOcoOrderInput(
      {required this.exch,
      required this.qty1,
      required this.tsym,
      required this.trgprc1,
      required this.prc1,
      required this.prd1,
      required this.trantype,
      required this.ret,
      required this.d1,
      required this.prctyp1,
      required this.remarks,
      required this.validity,
      required this.d2,
      required this.prc2,
      required this.prctyp2,
      required this.prd2,
      required this.qty2,
      required this.trgprc2,
      required this.alid});
}

class PlaceGTTOrderInput {
  String tsym;
  String exch;
  String ait;
  String validity;
  String d;
  String remarks;
  String trantype;
  String prctyp;
  String prd;
  String ret;
  String qty;
  String prc;
  String alid;
  String trgprc;

  PlaceGTTOrderInput(
      {required this.exch,
      required this.qty,
      required this.tsym,
      required this.trgprc,
      required this.ait,
      required this.prc,
      required this.prd,
      required this.trantype,
      required this.ret,
      required this.d,
      required this.prctyp,
      required this.remarks,
      required this.validity,
      required this.alid});
}

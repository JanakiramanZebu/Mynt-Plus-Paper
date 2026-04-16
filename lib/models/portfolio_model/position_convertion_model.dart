class PositionConvertionModel {
  String? requestTime;
  String? stat;
  String? emsg;
  PositionConvertionModel({this.requestTime, this.stat});

  PositionConvertionModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class PositionConvertionInput {
  String exch;
  String tsym;
  String qty;
  String prd;
  String prevprd;
  String trantype;
  String postype;
  PositionConvertionInput(
      {required this.exch,
      required this.postype,
      required this.prd,
      required this.prevprd,
      required this.qty,
      required this.trantype,
      required this.tsym});
}

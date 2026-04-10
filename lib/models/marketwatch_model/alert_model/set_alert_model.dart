class SetAlertModel {
  String? alId;
  String? requestTime;
  String? stat;
  String? emsg;


  SetAlertModel({this.alId, this.requestTime, this.stat, this.emsg});


  SetAlertModel.fromJson(Map<String, dynamic> json) {
    alId = json['al_id'];
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['al_id'] = alId;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

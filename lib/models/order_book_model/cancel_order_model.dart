class CancelOrderModel {
  String? result;
  String? requestTime;
  String? stat;
  String? emsg;
 String? dmsg;
  CancelOrderModel({this.result, this.requestTime, this.stat,this.dmsg});

  CancelOrderModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
    dmsg=json['dmsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['dmsg']=dmsg;
    return data;
  }
}

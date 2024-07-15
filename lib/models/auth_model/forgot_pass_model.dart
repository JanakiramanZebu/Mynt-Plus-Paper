class ForgetPasswordModel {
  String? clientid;
  String? requestTime;
  String? stat;
  String? emsg;
  String? msg;

  ForgetPasswordModel({this.clientid, this.requestTime, this.stat, this.emsg});

  ForgetPasswordModel.fromJson(Map<String, dynamic> json) {
    clientid = json['clientid'];
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientid'] = clientid;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['msg'] = msg;
    return data;
  }
}

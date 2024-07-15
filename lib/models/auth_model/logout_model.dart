class LogoutModel {
  String? emsg;
  String? stat;
  String? requestTime;

  LogoutModel({this.emsg, this.stat, this.requestTime});

  LogoutModel.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    stat = json['stat'];
    requestTime = json['request_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emsg'] = emsg;
    data['stat'] = stat;
    data['request_time'] = requestTime;
    return data;
  }
}

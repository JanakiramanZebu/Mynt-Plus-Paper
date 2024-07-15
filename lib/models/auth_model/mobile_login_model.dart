class MobileLoginModel {
  String? emsg;
  String? requestTime;
  String? stat;
  String? msg;
  int? otp;
  String? apitoken;
  String? clientid;
  String? mobile;
  String? name;
  String? token;
  String? source;
  String? url;
  String? wss;

  MobileLoginModel(
      {this.emsg,
      this.requestTime,
      this.stat,
      this.msg,
      this.otp,
      this.apitoken,
      this.clientid,
      this.mobile,
      this.name,
      this.token,
      this.source,
      this.url,
      this.wss});

  MobileLoginModel.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    requestTime = json['request_time'];
    stat = json['stat'];
    msg = json['msg'];
    otp = json['otp'];
    apitoken = json['apitoken'];
    clientid = json['clientid'];
    mobile = json['mobile'];
    name = json['name'];
    token = json['token'];
    url = json['url'];
    wss = json['wss'];
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emsg'] = emsg;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['msg'] = msg;
    data['otp'] = otp;
    data['apitoken'] = apitoken;
    data['clientid'] = clientid;
    data['mobile'] = mobile;
    data['name'] = name;
    data['source'] = source;
    data['url'] = url;
    data['wss'] = wss;
    data['token'] = token;
    return data;
  }
}

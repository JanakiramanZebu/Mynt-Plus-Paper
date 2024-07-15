class LoginOtpVerify {
  String? apitoken;
  String? clientid;
  String? mobile;
  String? stat;
  String? emsg;
  String? token;
  String? name;

  LoginOtpVerify(
      {this.apitoken,
      this.clientid,
      this.mobile,
      this.stat,
      this.emsg,
      this.name,
      this.token});

  LoginOtpVerify.fromJson(Map<String, dynamic> json) {
    apitoken = json['apitoken'];
    clientid = json['clientid'];
    mobile = json['mobile'];
    stat = json['stat'];
    emsg = json['emsg'];
    name = json['name'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['apitoken'] = apitoken;
    data['clientid'] = clientid;
    data['mobile'] = mobile;
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['name'] = name;
    data['token'] = token;
    return data;
  }
}

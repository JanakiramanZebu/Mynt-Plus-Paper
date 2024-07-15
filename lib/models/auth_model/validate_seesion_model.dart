class ValidateSession {
  String? apitoken;
  String? clientid;
  String? mobile;
  String? name;
  String? stat;
  String? token;
  String? emsg;

  ValidateSession(
      {this.apitoken,
      this.clientid,
      this.mobile,
      this.name,
      this.stat,
      this.token,
      this.emsg});

  ValidateSession.fromJson(Map<String, dynamic> json) {
    apitoken = json['apitoken'];
    clientid = json['clientid'];
    mobile = json['mobile'];
    name = json['name'];
    stat = json['stat'];
    token = json['token'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['apitoken'] = apitoken;
    data['clientid'] = clientid;
    data['mobile'] = mobile;
    data['name'] = name;
    data['stat'] = stat;
    data['token'] = token;
    data['emsg'] = emsg;
    return data;
  }
}

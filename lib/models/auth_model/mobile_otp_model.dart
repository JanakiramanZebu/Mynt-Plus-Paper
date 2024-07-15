class MobileOtpModel {
  String? apitoken;
  String? clientid;
  String? mobile;
  String? name;

  String? stat;
  String? token;
  String? source;
  String? url;
  String? wss;
  String? emsg;

  MobileOtpModel(
      {this.apitoken,
      this.clientid,
      this.mobile,
      this.name,
      this.source,
      this.stat,
      this.token,
      this.url,
      this.wss,
      this.emsg});

  MobileOtpModel.fromJson(Map<String, dynamic> json) {
    apitoken = json['apitoken'];
    clientid = json['clientid'];
    mobile = json['mobile'];
    name = json['name'];

    stat = json['stat'];
    token = json['token'];
    url = json['url'];
    wss = json['wss'];
    source = json['source'];
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
    data['source'] = source;
    data['url'] = url;
    data['wss'] = wss;
    data['emsg'] = emsg;
    return data;
  }
}

class QrResponces {
  String? uniqueId;
  String? browser;
  String? ip;
  String? loginSource;
  String? iP;
  String? city;
  String? region;

  QrResponces(
      {this.uniqueId,
      this.browser,
      this.ip,
      this.loginSource,
      this.iP,
      this.city,
      this.region});

  QrResponces.fromJson(Map<String, dynamic> json) {
    uniqueId = json['unique_id'];
    browser = json['Browser'];
    ip = json['ip'];
    loginSource = json['login_source'];
    iP = json['IP'];
    city = json['City'];
    region = json['Region'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unique_id'] = uniqueId;
    data['Browser'] = browser;
    data['ip'] = ip;
    data['login_source'] = loginSource;
    data['IP'] = iP;
    data['City'] = city;
    data['Region'] = region;
    return data;
  }
}
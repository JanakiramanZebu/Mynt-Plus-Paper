class OptionZmodel {
  String? stat;
  String? emsg;
  String? requestTime;
  String? url;

  OptionZmodel({this.stat, this.emsg, this.requestTime, this.url});

  OptionZmodel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    emsg = json['emsg'];
    requestTime = json['request_time'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['request_time'] = requestTime;
    data['url'] = url;
    return data;
  }
}

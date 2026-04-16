class MyntChangePasswordModel {
  String? dmsg;
  String? requestTime;
  String? emsg;
  String? stat;

  MyntChangePasswordModel({this.dmsg, this.requestTime, this.emsg, this.stat});

  MyntChangePasswordModel.fromJson(Map<String, dynamic> json) {
    dmsg = json['dmsg'];
    requestTime = json['request_time'];
    emsg = json['emsg'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dmsg'] = dmsg;
    data['request_time'] = requestTime;
    data['emsg'] = emsg;
    data['stat'] = stat;
    return data;
  }
}

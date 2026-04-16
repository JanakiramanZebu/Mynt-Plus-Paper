class GetHsTokenModel {
  String? requestTime;
  String? stat;
  String? hstk;
  String? uid;
  String? actid;
  String? brkname;
  String? emsg;
  GetHsTokenModel(
      {this.requestTime,
      this.stat,
      this.hstk,
      this.uid,
      this.actid,
      this.emsg,
      this.brkname});

  GetHsTokenModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    hstk = json['hstk'];
    uid = json['uid'];
    actid = json['actid'];
    emsg = json['emsg'];
    brkname = json['brkname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['hstk'] = hstk;
    data['uid'] = uid;
    data['actid'] = actid;
    data['brkname'] = brkname;
    data['emsg'] = emsg;
    return data;
  }
}

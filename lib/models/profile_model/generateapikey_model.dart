class GenerateApikeyModel {
  String? requestTime;
  String? uid;
  String? exd;
  String? valTime;
  String? status;
  String? renStatus;
  String? stat;
  String? emsg;


  GenerateApikeyModel(
      {this.requestTime,
      this.uid,
      this.exd,
      this.valTime,
      this.status,
      this.renStatus,
      this.stat,
      this.emsg});


  GenerateApikeyModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    uid = json['uid'];
    exd = json['exd'];
    valTime = json['valTime'];
    status = json['status'];
    renStatus = json['ren_status'];
    stat = json['stat'];
    emsg = json['emsg'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['uid'] = uid;
    data['exd'] = exd;
    data['valTime'] = valTime;
    data['status'] = status;
    data['ren_status'] = renStatus;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}






class Apikeymodel {
  String? requestTime;
  String? uid;
  String? apistatus;
  String? exd;
  String? apikey;
  String? renStatus;
  String? valTime;
  String? stat;
  String? emsg;


  Apikeymodel(
      {this.requestTime,
      this.uid,
      this.apistatus,
      this.exd,
      this.apikey,
      this.renStatus,
      this.valTime,
      this.stat,
      this.emsg});


  Apikeymodel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    uid = json['uid'];
    // apistatus = "EXPIRED";
    apistatus = json['apistatus'] ?? json['status'];
    exd = json['exd'];
    apikey = json['apikey'];
    renStatus = json['ren_status'];
    valTime = json['valTime'];
    stat = json['stat'];
    emsg = json['emsg'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['uid'] = uid;
    data['apistatus'] = apistatus;
    data['exd'] = exd;
    data['apikey'] = apikey;
    data['ren_status'] = renStatus;
    data['valTime'] = valTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}






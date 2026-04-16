class UserDetailModel {
  String? requestTime;
  String? uname;
  String? mNum;
  List<String>? accessType;
  List<String>? exarr;
  List<Prarr>? prarr;
  List<String>? orarr;
  String? brkname;
  String? uid;
  String? brnchid;
  String? email;
  String? actid;
  String? uprev;
  String? stat;
  String? emsg;

  UserDetailModel(
      {this.requestTime,
      this.uname,
      this.mNum,
      this.accessType,
      this.exarr,
      this.prarr,
      this.orarr,
      this.brkname,
      this.uid,
      this.brnchid,
      this.email,
      this.actid,
      this.uprev,
      this.stat,
      this.emsg});

  UserDetailModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    uname = json['uname'];
    mNum = json['m_num'];
    accessType = json['access_type'].cast<String>();
    exarr = json['exarr'].cast<String>();
    if (json['prarr'] != null) {
      prarr = <Prarr>[];
      json['prarr'].forEach((v) {
        prarr!.add(Prarr.fromJson(v));
      });
    }
    orarr = json['orarr'].cast<String>();
    brkname = json['brkname'];
    uid = json['uid'];
    brnchid = json['brnchid'];
    email = json['email'];
    actid = json['actid'];
    uprev = json['uprev'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['uname'] = uname;
    data['m_num'] = mNum;
    data['access_type'] = accessType;
    data['exarr'] = exarr;
    if (prarr != null) {
      data['prarr'] = prarr!.map((v) => v.toJson()).toList();
    }
    data['orarr'] = orarr;
    data['brkname'] = brkname;
    data['uid'] = uid;
    data['brnchid'] = brnchid;
    data['email'] = email;
    data['actid'] = actid;
    data['uprev'] = uprev;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class Prarr {
  String? prd;
  String? sPrdtAli;
  List<String>? exch;

  Prarr({this.prd, this.sPrdtAli, this.exch});

  Prarr.fromJson(Map<String, dynamic> json) {
    prd = json['prd'];
    sPrdtAli = json['s_prdt_ali'];
    exch = json['exch'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prd'] = prd;
    data['s_prdt_ali'] = sPrdtAli;
    data['exch'] = exch;
    return data;
  }
}

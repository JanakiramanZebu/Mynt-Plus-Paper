class CdslReponseModel {
  CDSLResp? cDSLResp;
  String? cDSLRespTime;
  String? cLIENTNAME;
  String? clientBoId;
  String? pledgeReqTime;
  String? uccid;

  CdslReponseModel(
      {this.cDSLResp,
      this.cDSLRespTime,
      this.cLIENTNAME,
      this.clientBoId,
      this.pledgeReqTime,
      this.uccid});

  CdslReponseModel.fromJson(Map<String, dynamic> json) {
    cDSLResp = json['CDSL_resp'] != null
        ? new CDSLResp.fromJson(json['CDSL_resp'])
        : null;
    cDSLRespTime = json['CDSL_resp_time'];
    cLIENTNAME = json['CLIENT_NAME'];
    clientBoId = json['client_bo_id'];
    pledgeReqTime = json['pledge_req_time'];
    uccid = json['uccid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (cDSLResp != null) {
      data['CDSL_resp'] = cDSLResp!.toJson();
    }
    data['CDSL_resp_time'] = cDSLRespTime;
    data['CLIENT_NAME'] = cLIENTNAME;
    data['client_bo_id'] = clientBoId;
    data['pledge_req_time'] = pledgeReqTime;
    data['uccid'] = uccid;
    return data;
  }
}

class CDSLResp {
  String? pledgeidentifier;
  Pledgeresdtls? pledgeresdtls;
  String? reqid;

  CDSLResp({this.pledgeidentifier, this.pledgeresdtls, this.reqid});

  CDSLResp.fromJson(Map<String, dynamic> json) {
    pledgeidentifier = json['pledgeidentifier'];
    pledgeresdtls = json['pledgeresdtls'] != null
        ? new Pledgeresdtls.fromJson(json['pledgeresdtls'])
        : null;
    reqid = json['reqid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pledgeidentifier'] = pledgeidentifier;
    if (pledgeresdtls != null) {
      data['pledgeresdtls'] = pledgeresdtls!.toJson();
    }
    data['reqid'] = reqid;
    return data;
  }
}

class Pledgeresdtls {
  Pledgeresdtlstwo? pledgeresdtlstwo;

  Pledgeresdtls({this.pledgeresdtlstwo});

  Pledgeresdtls.fromJson(Map<String, dynamic> json) {
    pledgeresdtlstwo = json['pledgeresdtls'] != null
        ? new Pledgeresdtlstwo.fromJson(json['pledgeresdtls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (pledgeresdtlstwo != null) {
      data['pledgeresdtls'] = pledgeresdtlstwo!.toJson();
    }
    return data;
  }
}

class Pledgeresdtlstwo {
  List<Isinresdtls>? isinresdtls;
  String? pledgeidentifier;
  String? remarks;
  String? reqid;
  String? reserrmsg;
  String? reserror;
  String? resid;
  String? resstatus;
  String? restime;

  Pledgeresdtlstwo(
      {this.isinresdtls,
      this.pledgeidentifier,
      this.remarks,
      this.reqid,
      this.reserrmsg,
      this.reserror,
      this.resid,
      this.resstatus,
      this.restime});

  Pledgeresdtlstwo.fromJson(Map<String, dynamic> json) {
    if (json['isinresdtls'] != null) {
      isinresdtls = <Isinresdtls>[];
      json['isinresdtls'].forEach((v) {
        isinresdtls!.add(new Isinresdtls.fromJson(v));
      });
    }
    pledgeidentifier = json['pledgeidentifier'];
    remarks = json['remarks'];
    reqid = json['reqid'];
    reserrmsg = json['reserrmsg'];
    reserror = json['reserror'];
    resid = json['resid'];
    resstatus = json['resstatus'];
    restime = json['restime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (isinresdtls != null) {
      data['isinresdtls'] = isinresdtls!.map((v) => v.toJson()).toList();
    }
    data['pledgeidentifier'] = pledgeidentifier;
    data['remarks'] = remarks;
    data['reqid'] = reqid;
    data['reserrmsg'] = reserrmsg;
    data['reserror'] = reserror;
    data['resid'] = resid;
    data['resstatus'] = resstatus;
    data['restime'] = restime;
    return data;
  }
}

class Isinresdtls {
  String? errorcode;
  String? errormsg;
  String? isin;
  String? isinreqid;
  String? isinresid;
  String? quantity;
  String? status;

  Isinresdtls(
      {this.errorcode,
      this.errormsg,
      this.isin,
      this.isinreqid,
      this.isinresid,
      this.quantity,
      this.status});

  Isinresdtls.fromJson(Map<String, dynamic> json) {
    errorcode = json['errorcode'];
    errormsg = json['errormsg'];
    isin = json['isin'];
    isinreqid = json['isinreqid'];
    isinresid = json['isinresid'];
    quantity = json['quantity'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errorcode'] = errorcode;
    data['errormsg'] = errormsg;
    data['isin'] = isin;
    data['isinreqid'] = isinreqid;
    data['isinresid'] = isinresid;
    data['quantity'] = quantity;
    data['status'] = status;
    return data;
  }
}

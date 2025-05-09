class PledgeHistoryModel {
  List<PledgeData>? data;

  PledgeHistoryModel({this.data});

  PledgeHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <PledgeData>[];
      json['data'].forEach((v) {
        data!.add(new PledgeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PledgeData {
  String? cLIENTNAME;
  String? cdslReqTime;
  String? clientBoId;
  String? datTim;
  String? dates;
  String? finalStage;
  String? remarks;
  List<ReqList>? reqList;
  String? reqid;
  String? reserrmsg;
  String? resstatus;
  String? status;
  String? times;
  String? uccid;

  PledgeData(
      {this.cLIENTNAME,
      this.cdslReqTime,
      this.clientBoId,
      this.datTim,
      this.dates,
      this.finalStage,
      this.remarks,
      this.reqList,
      this.reqid,
      this.reserrmsg,
      this.resstatus,
      this.status,
      this.times,
      this.uccid});

  PledgeData.fromJson(Map<String, dynamic> json) {
    cLIENTNAME = json['CLIENT_NAME'];
    cdslReqTime = json['cdsl_req_time'];
    clientBoId = json['client_bo_id'];
    datTim = json['dat_tim'];
    dates = json['dates'];
    finalStage = json['final_stage'];
    remarks = json['remarks'];
    if (json['reqList'] != null) {
      reqList = <ReqList>[];
      json['reqList'].forEach((v) {
        reqList!.add(new ReqList.fromJson(v));
      });
    }
    reqid = json['reqid'];
    reserrmsg = json['reserrmsg'];
    resstatus = json['resstatus'];
    status = json['status'];
    times = json['times'];
    uccid = json['uccid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CLIENT_NAME'] = this.cLIENTNAME;
    data['cdsl_req_time'] = this.cdslReqTime;
    data['client_bo_id'] = this.clientBoId;
    data['dat_tim'] = this.datTim;
    data['dates'] = this.dates;
    data['final_stage'] = this.finalStage;
    data['remarks'] = this.remarks;
    if (this.reqList != null) {
      data['reqList'] = this.reqList!.map((v) => v.toJson()).toList();
    }
    data['reqid'] = this.reqid;
    data['reserrmsg'] = this.reserrmsg;
    data['resstatus'] = this.resstatus;
    data['status'] = this.status;
    data['times'] = this.times;
    data['uccid'] = this.uccid;
    return data;
  }
}

class ReqList {
  String? symbol;
  String? isin;
  String? isinreqid;
  String? quantity;
  String? segments;
  String? status;

  ReqList(
      {this.symbol,
      this.isin,
      this.isinreqid,
      this.quantity,
      this.segments,
      this.status});

  ReqList.fromJson(Map<String, dynamic> json) {
    symbol = json['Symbol'];
    isin = json['isin'];
    isinreqid = json['isinreqid'];
    quantity = json['quantity'];
    segments = json['segments'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Symbol'] = this.symbol;
    data['isin'] = this.isin;
    data['isinreqid'] = this.isinreqid;
    data['quantity'] = this.quantity;
    data['segments'] = this.segments;
    data['status'] = this.status;
    return data;
  }
}

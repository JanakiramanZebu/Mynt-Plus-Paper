class PledgeHistoryModel {
  List<PledgeData>? data;

  PledgeHistoryModel({this.data});

  PledgeHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <PledgeData>[];
      json['data'].forEach((v) {
        data!.add(PledgeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
        reqList!.add(ReqList.fromJson(v));
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CLIENT_NAME'] = cLIENTNAME;
    data['cdsl_req_time'] = cdslReqTime;
    data['client_bo_id'] = clientBoId;
    data['dat_tim'] = datTim;
    data['dates'] = dates;
    data['final_stage'] = finalStage;
    data['remarks'] = remarks;
    if (reqList != null) {
      data['reqList'] = reqList!.map((v) => v.toJson()).toList();
    }
    data['reqid'] = reqid;
    data['reserrmsg'] = reserrmsg;
    data['resstatus'] = resstatus;
    data['status'] = status;
    data['times'] = times;
    data['uccid'] = uccid;
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
  String? reqid;
  String? datetime;

  ReqList(
      {this.symbol,
      this.isin,
      this.isinreqid,
      this.quantity,
      this.segments,
      this.status,
      this.reqid,
      });

  ReqList.fromJson(Map<String, dynamic> json) {
    symbol = json['Symbol'];
    isin = json['isin'];
    isinreqid = json['isinreqid'];
    quantity = json['quantity'];
    segments = json['segments'];
    status = json['status'];
    datetime = json['datetime'];
    reqid = json['reqid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Symbol'] = symbol;
    data['isin'] = isin;
    data['isinreqid'] = isinreqid;
    data['quantity'] = quantity;
    data['segments'] = segments;
    data['status'] = status;
    data['reqid'] = reqid;
    data['datetime'] = datetime;
    return data;
  }
}

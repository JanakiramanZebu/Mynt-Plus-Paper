class UnpledgeHistoryModel {
  List<Data>? data;

  UnpledgeHistoryModel({this.data});

  UnpledgeHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  String? bOID;
  String? cOLQTY;
  String? iSIN;
  String? nETQTY;
  String? appDatTime;
  String? clientName;
  String? clientid;
  String? dates;
  String? id;
  String? reason;
  String? reqDatTime;
  String? script;
  String? status;
  String? unPlegeQty;

  Data(
      {this.bOID,
      this.cOLQTY,
      this.iSIN,
      this.nETQTY,
      this.appDatTime,
      this.clientName,
      this.clientid,
      this.dates,
      this.id,
      this.reason,
      this.reqDatTime,
      this.script,
      this.status,
      this.unPlegeQty});

  Data.fromJson(Map<String, dynamic> json) {
    bOID = json['BOID'].toString();
    cOLQTY = json['COLQTY'].toString();
    iSIN = json['ISIN'].toString();
    nETQTY = json['NET_QTY'].toString();
    appDatTime = json['app_dat_time'].toString();
    clientName = json['client_name'].toString();
    clientid = json['clientid'].toString();
    dates = json['dates'].toString();
    id = json['id'].toString();
    reason = json['reason'].toString();
    reqDatTime = json['req_dat_time'].toString();
    script = json['script'].toString();
    status = json['status'].toString();
    unPlegeQty = json['un_plege_qty'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BOID'] = this.bOID;
    data['COLQTY'] = this.cOLQTY;
    data['ISIN'] = this.iSIN;
    data['NET_QTY'] = this.nETQTY;
    data['app_dat_time'] = this.appDatTime;
    data['client_name'] = this.clientName;
    data['clientid'] = this.clientid;
    data['dates'] = this.dates;
    data['id'] = this.id;
    data['reason'] = this.reason;
    data['req_dat_time'] = this.reqDatTime;
    data['script'] = this.script;
    data['status'] = this.status;
    data['un_plege_qty'] = this.unPlegeQty;
    return data;
  }
}

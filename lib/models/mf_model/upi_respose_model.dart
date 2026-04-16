class UpiIdOrderResponse {
  String? stat;
  Data? data;
  String? msg;
  String? emsg;
  String? type;
  String? file;

  UpiIdOrderResponse({this.stat, this.data, this.msg,this.emsg, this.type});

  UpiIdOrderResponse.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
    emsg = json['emsg'];
    type = json['type'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = msg;
    data['emsg'] = emsg;
    data['type'] = type;
    data['file'] = file;
    return data;
  }
}

class Data {
  String? responsestring;
  String? statuscode;
  String? internalrefno;
  String? filler1;
  String? filler2;
  String? filler3;
  String? filler4;

  Data(
      {this.responsestring,
      this.statuscode,
      this.internalrefno,
      this.filler1,
      this.filler2,
      this.filler3,
      this.filler4});

  Data.fromJson(Map<String, dynamic> json) {
    responsestring = json['responsestring'];
    statuscode = json['statuscode'];
    internalrefno = json['internalrefno'];
    filler1 = json['filler1'];
    filler2 = json['filler2'];
    filler3 = json['filler3'];
    filler4 = json['filler4'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responsestring'] = responsestring;
    data['statuscode'] = statuscode;
    data['internalrefno'] = internalrefno;
    data['filler1'] = filler1;
    data['filler2'] = filler2;
    data['filler3'] = filler3;
    data['filler4'] = filler4;
    return data;
  }
}

class AllPaymentMfModel {
  Data? data;
  String? file;
  String? error;
  String? msg;
  String? stat;
  String? emsg;

  AllPaymentMfModel(
      {this.error, this.msg, this.stat, this.data, this.file, this.emsg});

  AllPaymentMfModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    file = json['file'];
    error = json['error'];
    msg = json['msg'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['msg'] = msg;
    data['stat'] = stat;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['file'] = file;
    data['emsg'] = emsg;
    return data;
  }
}

class Data {
  String? filler1;
  String? filler2;
  String? filler3;
  String? filler4;
  String? internalrefno;
  String? responsestring;
  String? statuscode;

  Data(
      {this.filler1,
      this.filler2,
      this.filler3,
      this.filler4,
      this.internalrefno,
      this.responsestring,
      this.statuscode});

  Data.fromJson(Map<String, dynamic> json) {
    filler1 = json['filler1'];
    filler2 = json['filler2'];
    filler3 = json['filler3'];
    filler4 = json['filler4'];
    internalrefno = json['internalrefno'];
    responsestring = json['responsestring'];
    statuscode = json['statuscode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filler1'] = filler1;
    data['filler2'] = filler2;
    data['filler3'] = filler3;
    data['filler4'] = filler4;
    data['internalrefno'] = internalrefno;
    data['responsestring'] = responsestring;
    data['statuscode'] = statuscode;
    return data;
  }
}

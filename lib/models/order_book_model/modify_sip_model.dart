// ignore_for_file: unnecessary_this

class ModifySIPModel {
  String? reqStatus;
  String? rejreason;
  String? emsg;

  ModifySIPModel({this.reqStatus, this.rejreason,this.emsg});

  ModifySIPModel.fromJson(Map<String, dynamic> json) {
    reqStatus = json['ReqStatus'];
    rejreason = json['rejreason'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ReqStatus'] = this.reqStatus;
    data['rejreason'] = this.rejreason;
    data['emsg'] = this.emsg;
    return data;
  }
}

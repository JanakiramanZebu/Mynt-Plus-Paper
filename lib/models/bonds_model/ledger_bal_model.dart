class LedgerBalModel {
  String? clientid;
  String? total;
  String? emsg;

  LedgerBalModel({this.clientid, this.total, this.emsg});

  LedgerBalModel.fromJson(Map<String, dynamic> json) {
    clientid = json['clientid'];
    total = json['total'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientid'] = clientid;
    data['total'] = total;
    data['emsg'] = emsg;
    return data;
  }
}

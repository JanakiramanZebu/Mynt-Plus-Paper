class ManagePriceAlertModel {
  String? stat;
  String? norentm;
  String? dmsg;
  String? note;
  String? msgsubtyp;
  String? token;
  String? exch;
  String? emsg;
  ManagePriceAlertModel(
      {this.stat,
      this.norentm,
      this.dmsg,
      this.note,
      this.msgsubtyp,
      this.token,
      this.exch,
      this.emsg});

  ManagePriceAlertModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    norentm = json['norentm'];
    dmsg = json['dmsg'];
    note = json['note'];
    msgsubtyp = json['msgsubtyp'];
    token = json['token'];
    exch = json['exch'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['norentm'] = norentm;
    data['dmsg'] = dmsg;
    data['note'] = note;
    data['msgsubtyp'] = msgsubtyp;
    data['token'] = token;
    data['exch'] = exch;
    data['emsg'] = emsg;
    return data;
  }
}

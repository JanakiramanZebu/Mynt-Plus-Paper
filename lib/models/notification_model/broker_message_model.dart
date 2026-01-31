class BrokerMessage {
  String? stat;
  String? norentm;
  String? msgtyp;
  String? dmsg;
  String? emsg;
  String? tsym;
  String? exch;
  String? token;
  String? note;
  String? msgsubtyp;


  BrokerMessage({this.stat, this.norentm, this.msgtyp, this.dmsg, this.emsg, this.tsym, this.exch, this.token, this.note, this.msgsubtyp});


  BrokerMessage.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    norentm = json['norentm'];
    msgtyp = json['msgtyp'];
    dmsg = json['dmsg'];
    emsg = json['emsg'];
    tsym = json['tsym'];
    exch = json['exch'];
    token = json['token'];
    note = json['note'];
    msgsubtyp = json['msgsubtyp'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['norentm'] = norentm;
    data['msgtyp'] = msgtyp;
    data['dmsg'] = dmsg;
    data['emsg'] = emsg;
    data['tsym'] = tsym;
    data['exch'] = exch;
    data['token'] = token;
    data['note'] = note;
    data['msgsubtyp'] = msgsubtyp;
    return data;
  }
}






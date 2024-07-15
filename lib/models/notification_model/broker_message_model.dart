class BrokerMessage {
  String? stat;
  String? norentm;
  String? msgtyp;
  String? dmsg;
  String? emsg;


  BrokerMessage({this.stat, this.norentm, this.msgtyp, this.dmsg, this.emsg});


  BrokerMessage.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    norentm = json['norentm'];
    msgtyp = json['msgtyp'];
    dmsg = json['dmsg'];
    emsg = json['emsg'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['norentm'] = norentm;
    data['msgtyp'] = msgtyp;
    data['dmsg'] = dmsg;
    data['emsg'] = emsg;
    return data;
  }
}






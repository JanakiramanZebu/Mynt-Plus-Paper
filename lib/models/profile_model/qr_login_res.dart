class QrLoginResponces {
  String? emsg;
  String? msg;
  String? stat;

  QrLoginResponces({this.emsg, this.msg, this.stat});

  QrLoginResponces.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    msg = json['msg'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emsg'] = emsg;
    data['msg'] = msg;
    data['stat'] = stat;
    return data;
  }
}
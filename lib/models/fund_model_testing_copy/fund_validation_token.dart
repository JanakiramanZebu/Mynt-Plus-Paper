class FundTokenValidation {
  String? msg;
  String? emsg;

  FundTokenValidation({this.msg, this.emsg});

  FundTokenValidation.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['emsg'] = emsg;
    return data;
  }
}

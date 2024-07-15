class LoginOtp {
  String? emsg;
  String? requestTime;
  String? stat;
  String? msg;
  int? otp;

  LoginOtp({this.emsg, this.requestTime, this.stat, this.msg, this.otp});

  LoginOtp.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    requestTime = json['request_time'];
    stat = json['stat'];
    msg = json['msg'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emsg'] = emsg;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['msg'] = msg;
    data['otp'] = otp;
    return data;
  }
}

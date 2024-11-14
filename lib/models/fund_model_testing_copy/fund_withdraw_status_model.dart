class WithdrawStatus {
  String? eNTRYTIME;
  String? aCCOUNTCODE;
  String? dUEAMT;
  String? uSERID;
  String? iPADDRESS;
  String? cOCD;
  String? aUTHO;
  String? msg;

  WithdrawStatus(
      {this.eNTRYTIME,
      this.aCCOUNTCODE,
      this.dUEAMT,
      this.uSERID,
      this.iPADDRESS,
      this.cOCD,
      this.aUTHO,
      this.msg});

  WithdrawStatus.fromJson(Map<String, dynamic> json) {
    eNTRYTIME = json['ENTRYTIME'];
    aCCOUNTCODE = json['ACCOUNTCODE'];
    dUEAMT = json['DUE_AMT'];
    uSERID = json['USERID'];
    iPADDRESS = json['IPADDRESS'];
    cOCD = json['COCD'];
    aUTHO = json['AUTHO'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ENTRYTIME'] = eNTRYTIME;
    data['ACCOUNTCODE'] = aCCOUNTCODE;
    data['DUE_AMT'] = dUEAMT;
    data['USERID'] = uSERID;
    data['IPADDRESS'] = iPADDRESS;
    data['COCD'] = cOCD;
    data['AUTHO'] = aUTHO;
    data['msg'] = msg;
    return data;
  }
}

class MtfLimitsResponse {
  String? stat;
  String? actid;
  String? cash;
  String? payin;
  String? payout;
  String? marginused;
  String? emsg;

  MtfLimitsResponse({
    this.stat,
    this.actid,
    this.cash,
    this.payin,
    this.payout,
    this.marginused,
    this.emsg,
  });

  factory MtfLimitsResponse.fromJson(Map<String, dynamic> json) {
    return MtfLimitsResponse(
      stat: json['stat'],
      actid: json['actid'],
      cash: json['cash']?.toString(),
      payin: json['payin']?.toString(),
      payout: json['payout']?.toString(),
      marginused: json['marginused']?.toString(),
      emsg: json['emsg'],
    );
  }
}

class MtfLimitsMTFResponse {
  String? stat;
  String? cash;
  String? emsg;

  MtfLimitsMTFResponse({this.stat, this.cash, this.emsg});

  factory MtfLimitsMTFResponse.fromJson(Map<String, dynamic> json) {
    return MtfLimitsMTFResponse(
      stat: json['stat'],
      cash: json['cash']?.toString(),
      emsg: json['emsg'],
    );
  }
}

class MtfFundTransferResponse {
  String? pymtStatus;
  String? emsg;

  MtfFundTransferResponse({this.pymtStatus, this.emsg});

  factory MtfFundTransferResponse.fromJson(Map<String, dynamic> json) {
    return MtfFundTransferResponse(
      pymtStatus: json['pymt_status'],
      emsg: json['emsg'],
    );
  }
}

class PayoutDetails {
  String? emsg;
  String? clientID;
  String? totalLedger;
  String? margin;
  String? fD;
  String? collateral;
  String? withdrawAmount;
  String? actid;
  String? auxBrkcollamt;
  String? auxDaycash;
  String? auxUnclearedcash;
  String? blockamt;
  String? brkageDM;
  String? brkcollamt;
  String? brokerage;
  String? cash;
  String? daycash;
  String? expo;
  String? expoDM;
  String? margincurper;
  String? marginused;
  String? payin;
  String? payout;
  String? peakMar;
  String? pendordvallmt;
  String? premium;
  String? premiumDM;
  String? prfname;
  String? requestTime;
  String? span;
  String? spanDM;
  String? stat;
  String? turnover;
  String? turnoverlmt;
  String? unclearedcash;
  String? urmtom;
  String? uzpnlDM;

  PayoutDetails(
      {this.emsg,
      this.clientID,
      this.totalLedger,
      this.margin,
      this.fD,
      this.collateral,
      this.withdrawAmount,
      this.actid,
      this.auxBrkcollamt,
      this.auxDaycash,
      this.auxUnclearedcash,
      this.blockamt,
      this.brkageDM,
      this.brkcollamt,
      this.brokerage,
      this.cash,
      this.daycash,
      this.expo,
      this.expoDM,
      this.margincurper,
      this.marginused,
      this.payin,
      this.payout,
      this.peakMar,
      this.pendordvallmt,
      this.premium,
      this.premiumDM,
      this.prfname,
      this.requestTime,
      this.span,
      this.spanDM,
      this.stat,
      this.turnover,
      this.turnoverlmt,
      this.unclearedcash,
      this.urmtom,
      this.uzpnlDM});

  PayoutDetails.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    clientID = json['Client_ID'];
    totalLedger = json['Total_Ledger'];
    margin = json['Margin'];
    fD = json['FD'];
    collateral = json['Collateral'];
    withdrawAmount = json['withdraw_amount'];
    actid = json['actid'];
    auxBrkcollamt = json['aux_brkcollamt'];
    auxDaycash = json['aux_daycash'];
    auxUnclearedcash = json['aux_unclearedcash'];
    blockamt = json['blockamt'];
    brkageDM = json['brkage_d_m'];
    brkcollamt = json['brkcollamt'];
    brokerage = json['brokerage'];
    cash = json['cash'];
    daycash = json['daycash'];
    expo = json['expo'];
    expoDM = json['expo_d_m'];
    margincurper = json['margincurper'];
    marginused = json['marginused'];
    payin = json['payin'];
    payout = json['payout'];
    peakMar = json['peak_mar'];
    pendordvallmt = json['pendordvallmt'];
    premium = json['premium'];
    premiumDM = json['premium_d_m'];
    prfname = json['prfname'];
    requestTime = json['request_time'];
    span = json['span'];
    spanDM = json['span_d_m'];
    stat = json['stat'];
    turnover = json['turnover'];
    turnoverlmt = json['turnoverlmt'];
    unclearedcash = json['unclearedcash'];
    urmtom = json['urmtom'];
    uzpnlDM = json['uzpnl_d_m'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emsg'] = emsg;
    data['Client_ID'] = clientID;
    data['Total_Ledger'] = totalLedger;
    data['Margin'] = margin;
    data['FD'] = fD;
    data['Collateral'] = collateral;
    data['withdraw_amount'] = withdrawAmount;
    data['actid'] = actid;
    data['aux_brkcollamt'] = auxBrkcollamt;
    data['aux_daycash'] = auxDaycash;
    data['aux_unclearedcash'] = auxUnclearedcash;
    data['blockamt'] = blockamt;
    data['brkage_d_m'] = brkageDM;
    data['brkcollamt'] = brkcollamt;
    data['brokerage'] = brokerage;
    data['cash'] = cash;
    data['daycash'] = daycash;
    data['expo'] = expo;
    data['expo_d_m'] = expoDM;
    data['margincurper'] = margincurper;
    data['marginused'] = marginused;
    data['payin'] = payin;
    data['payout'] = payout;
    data['peak_mar'] = peakMar;
    data['pendordvallmt'] = pendordvallmt;
    data['premium'] = premium;
    data['premium_d_m'] = premiumDM;
    data['prfname'] = prfname;
    data['request_time'] = requestTime;
    data['span'] = span;
    data['span_d_m'] = spanDM;
    data['stat'] = stat;
    data['turnover'] = turnover;
    data['turnoverlmt'] = turnoverlmt;
    data['unclearedcash'] = unclearedcash;
    data['urmtom'] = urmtom;
    data['uzpnl_d_m'] = uzpnlDM;
    return data;
  }
}

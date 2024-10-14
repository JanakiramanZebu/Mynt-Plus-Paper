class PayoutDetails {
  String? clientID;
  String? totalLedger;
  String? margin;
  String? withdrawAmount;

  PayoutDetails(
      {this.clientID, this.totalLedger, this.margin, this.withdrawAmount});

  PayoutDetails.fromJson(Map<String, dynamic> json) {
    clientID = json['Client_ID'];
    totalLedger = json['Total_Ledger'];
    margin = json['Margin'];
    withdrawAmount = json['withdraw_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Client_ID'] = clientID;
    data['Total_Ledger'] = totalLedger;
    data['Margin'] = margin;
    data['withdraw_amount'] = withdrawAmount;
    return data;
  }
}
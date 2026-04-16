class ViewUpiIdModel {
  String? clientId;
  String? bankName;
  String? accountNumber;
  String? upiId;

  ViewUpiIdModel(
      {this.clientId, this.bankName, this.accountNumber, this.upiId});

  ViewUpiIdModel.fromJson(Map<String, dynamic> json) {
    clientId = json['client_id'];
    bankName = json['bank_name'];
    accountNumber = json['account_number'];
    upiId = json['upi_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_id'] = clientId;
    data['bank_name'] = bankName;
    data['account_number'] = accountNumber;
    data['upi_id'] = upiId;
    return data;
  }
}
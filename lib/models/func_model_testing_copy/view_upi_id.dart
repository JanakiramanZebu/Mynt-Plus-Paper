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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_id'] = this.clientId;
    data['bank_name'] = this.bankName;
    data['account_number'] = this.accountNumber;
    data['upi_id'] = this.upiId;
    return data;
  }
}
class IndentUpiResponse {
  Data? data;
  String? gateway;
  String? stat;
  String? emsg;

  IndentUpiResponse({this.data, this.gateway, this.stat, this.emsg});

  factory IndentUpiResponse.fromJson(Map<String, dynamic> json) {
    return IndentUpiResponse(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      gateway: json['gateway'],
      stat: json['stat'],
      emsg: json['emsg'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (gateway != null) data['gateway'] = gateway;
    if (stat != null) data['stat'] = stat;
    if (emsg != null) data['emsg'] = emsg;
    return data;
  }
}

class Data {
  String? amount;
  String? clientVPA;
  String? orderNumber;
  String? paidToVPA;
  String? status;
  String? statusDescription;
  String? upiTransactionNo;
  String? upilink;

  Data({
    this.amount,
    this.clientVPA,
    this.orderNumber,
    this.paidToVPA,
    this.status,
    this.statusDescription,
    this.upiTransactionNo,
    this.upilink,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      amount: json['amount'],
      clientVPA: json['client_VPA'],
      orderNumber: json['orderNumber'],
      paidToVPA: json['paid_to_VPA'],
      status: json['status'],
      statusDescription: json['status_description'],
      upiTransactionNo: json['upi_transaction_no'],
      upilink: json['upilink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'client_VPA': clientVPA,
      'orderNumber': orderNumber,
      'paid_to_VPA': paidToVPA,
      'status': status,
      'status_description': statusDescription,
      'upi_transaction_no': upiTransactionNo,
      'upilink': upilink,
    };
  }
}

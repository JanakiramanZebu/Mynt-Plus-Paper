class HdfcDirectPayment {
  Data? data;

  HdfcDirectPayment({this.data});

  HdfcDirectPayment.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
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

  Data(
      {this.amount,
      this.clientVPA,
      this.orderNumber,
      this.paidToVPA,
      this.status,
      this.statusDescription,
      this.upiTransactionNo,
      this.upilink});

  Data.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    clientVPA = json['client_VPA'];
    orderNumber = json['orderNumber'];
    paidToVPA = json['paid_to_VPA'];
    status = json['status'];
    statusDescription = json['status_description'];
    upiTransactionNo = json['upi_transaction_no'];
    upilink = json['upilink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['client_VPA'] = clientVPA;
    data['orderNumber'] = orderNumber;
    data['paid_to_VPA'] = paidToVPA;
    data['status'] = status;
    data['status_description'] = statusDescription;
    data['upi_transaction_no'] = upiTransactionNo;
    data['upilink'] = upilink;
    return data;
  }
}
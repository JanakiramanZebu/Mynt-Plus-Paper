class RedemptionModel {
  String? transactionCode;
  String? transactionNumber;
  String? clientCode;
  String? orderNumber;
  String? responseMessage;
  String? stat;
  String? emsg;
  String? error;
  String? msg;


  RedemptionModel(
      {this.transactionCode,
      this.transactionNumber,
      this.clientCode,
      this.orderNumber,
      this.responseMessage,
      this.stat,
      this.emsg,
      this.error,
      this.msg});

  RedemptionModel.fromJson(Map<String, dynamic> json) {
    transactionCode = json['transaction_code'];
    transactionNumber = json['transaction_number'];
    clientCode = json['client_code'];
    orderNumber = json['order_number'];
    responseMessage = json['response_message'];
    stat = json['stat'];
    emsg = json['emsg'];
    error = json['error'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction_code'] = transactionCode;
    data['transaction_number'] = transactionNumber;
    data['client_code'] = clientCode;
    data['order_number'] = orderNumber;
    data['response_message'] = responseMessage;
    data['stat'] = stat;
    data['emsg'] = emsg;
    data['error'] = error;
    data['msg'] = msg;
    return data;
  }
}

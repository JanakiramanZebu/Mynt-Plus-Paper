class MfPlaceOrderResponces {
  String? clientCode;
  String? orderNumber;
  String? responseMessage;
  String? stat;
  String? transactionCode;
  String? transactionNumber;

  MfPlaceOrderResponces(
      {this.clientCode,
      this.orderNumber,
      this.responseMessage,
      this.stat,
      this.transactionCode,
      this.transactionNumber});

  MfPlaceOrderResponces.fromJson(Map<String, dynamic> json) {
    clientCode = json['client_code'];
    orderNumber = json['order_number'];
    responseMessage = json['response_message'];
    stat = json['stat'];
    transactionCode = json['transaction_code'];
    transactionNumber = json['transaction_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['client_code'] = clientCode;
    data['order_number'] = orderNumber;
    data['response_message'] = responseMessage;
    data['stat'] = stat;
    data['transaction_code'] = transactionCode;
    data['transaction_number'] = transactionNumber;
    return data;
  }
}

class MfPlaceOrderInput {
  String transcode;
  String schemecode;
  String buysell;
  String buyselltype;
  String dptxn;
  String amount;
  String allredeem;
  String kycstatus;
  String qty;
  String euinflag;
  String minredeem;
  String dpc;

  MfPlaceOrderInput({
    required this.transcode,
    required this.schemecode,
    required this.buysell,
    required this.buyselltype,
    required this.dptxn,
    required this.amount,
    required this.allredeem,
    required this.kycstatus,
    required this.qty,
    required this.euinflag,
    required this.minredeem,
    required this.dpc,
  });
}


class MfPlaceSipInput {
  String transcode;
  String schemecode;
  String buysell;
  String buyselltype;
  String dptxn;
  String amount;
  String allredeem;
  String kycstatus;
  String qty;
  String euinflag;
  String minredeem;
  String dpc;

  MfPlaceSipInput({
    required this.transcode,
    required this.schemecode,
    required this.buysell,
    required this.buyselltype,
    required this.dptxn,
    required this.amount,
    required this.allredeem,
    required this.kycstatus,
    required this.qty,
    required this.euinflag,
    required this.minredeem,
    required this.dpc,
  });
}

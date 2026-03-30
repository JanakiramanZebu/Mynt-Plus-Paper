class WrapperCheckStatusResponse {
  WrapperCheckStatusData? data;
  String? stat;
  String? emsg;

  WrapperCheckStatusResponse({this.data, this.stat, this.emsg});

  factory WrapperCheckStatusResponse.fromJson(Map<String, dynamic> json) {
    return WrapperCheckStatusResponse(
      data: json['data'] != null
          ? WrapperCheckStatusData.fromJson(json['data'])
          : null,
      stat: json['stat'],
      emsg: json['emsg'],
    );
  }
}

class WrapperCheckStatusData {
  String? approvalNumber;
  String? npciClientRefNo;
  String? tempReferenceID;
  String? transactionAuthDate;
  String? amount;
  String? clientVPA;
  String? orderNumber;
  String? responseCode;
  String? status;
  String? statusDescription;
  String? upiTransactionNo;

  WrapperCheckStatusData({
    this.approvalNumber,
    this.npciClientRefNo,
    this.tempReferenceID,
    this.transactionAuthDate,
    this.amount,
    this.clientVPA,
    this.orderNumber,
    this.responseCode,
    this.status,
    this.statusDescription,
    this.upiTransactionNo,
  });

  factory WrapperCheckStatusData.fromJson(Map<String, dynamic> json) {
    return WrapperCheckStatusData(
      approvalNumber: json['Approval Number'],
      npciClientRefNo: json['NPCIclientRefNo'],
      tempReferenceID: json['TempReferenceID'],
      transactionAuthDate: json['TransactionAuthDate'],
      amount: json['amount'],
      clientVPA: json['client_VPA'],
      orderNumber: json['orderNumber'],
      responseCode: json['responseCode'],
      status: json['status'],
      statusDescription: json['status_description'],
      upiTransactionNo: json['upi_transaction_no'],
    );
  }
}

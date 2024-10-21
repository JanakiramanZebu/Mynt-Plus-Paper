class HdfcPaymentStatus {
  UpiId? upiId;

  HdfcPaymentStatus({this.upiId});

  HdfcPaymentStatus.fromJson(Map<String, dynamic> json) {
    upiId = json['data'] != null ? UpiId.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.upiId != null) {
      data['data'] = this.upiId!.toJson();
    }
    return data;
  }
}

class UpiId {
  String? approvalNumber;
  String? nPCIclientRefNo;
  String? tempReferenceID;
  String? transactionAuthDate;
  String? amount;
  String? clientVPA;
  String? orderNumber;
  String? responseCode;
  String? status;
  String? statusDescription;
  String? upiTransactionNo;

  UpiId(
      {this.approvalNumber,
      this.nPCIclientRefNo,
      this.tempReferenceID,
      this.transactionAuthDate,
      this.amount,
      this.clientVPA,
      this.orderNumber,
      this.responseCode,
      this.status,
      this.statusDescription,
      this.upiTransactionNo});

  UpiId.fromJson(Map<String, dynamic> json) {
    approvalNumber = json['Approval Number'];
    nPCIclientRefNo = json['NPCIclientRefNo'];
    tempReferenceID = json['TempReferenceID'];
    transactionAuthDate = json['TransactionAuthDate'];
    amount = json['amount'];
    clientVPA = json['client_VPA'];
    orderNumber = json['orderNumber'];
    responseCode = json['responseCode'];
    status = json['status'];
    statusDescription = json['status_description'];
    upiTransactionNo = json['upi_transaction_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Approval Number'] = approvalNumber;
    data['NPCIclientRefNo'] = nPCIclientRefNo;
    data['TempReferenceID'] = tempReferenceID;
    data['TransactionAuthDate'] = transactionAuthDate;
    data['amount'] = amount;
    data['client_VPA'] = clientVPA;
    data['orderNumber'] = orderNumber;
    data['responseCode'] = responseCode;
    data['status'] = status;
    data['status_description'] = statusDescription;
    data['upi_transaction_no'] = upiTransactionNo;
    return data;
  }
}

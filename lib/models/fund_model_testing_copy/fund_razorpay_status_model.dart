// ignore_for_file: unnecessary_question_mark, unnecessary_this

class RazorpayTranstationRes {
  AcquirerData? acquirerData;
  int? amount;
  int? amountRefunded;
  String? bank;
  bool? captured;
  Null? cardId;
  String? contact;
  int? createdAt;
  String? currency;
  String? description;
  String? email;
  String? entity;
  Null? errorCode;
  Null? errorDescription;
  Null? errorReason;
  Null? errorSource;
  Null? errorStep;
  int? fee;
  String? id;
  bool? international;
  Null? invoiceId;
  String? method;
  Notes? notes;
  String? orderId;
  Null? refundStatus;
  String? status;
  int? tax;
  Null? vpa;
  Null? wallet;

  RazorpayTranstationRes(
      {this.acquirerData,
      this.amount,
      this.amountRefunded,
      this.bank,
      this.captured,
      this.cardId,
      this.contact,
      this.createdAt,
      this.currency,
      this.description,
      this.email,
      this.entity,
      this.errorCode,
      this.errorDescription,
      this.errorReason,
      this.errorSource,
      this.errorStep,
      this.fee,
      this.id,
      this.international,
      this.invoiceId,
      this.method,
      this.notes,
      this.orderId,
      this.refundStatus,
      this.status,
      this.tax,
      this.vpa,
      this.wallet});

  RazorpayTranstationRes.fromJson(Map<String, dynamic> json) {
    acquirerData = json['acquirer_data'] != null
        ? new AcquirerData.fromJson(json['acquirer_data'])
        : null;
    amount = json['amount'];
    amountRefunded = json['amount_refunded'];
    bank = json['bank'];
    captured = json['captured'];
    cardId = json['card_id'];
    contact = json['contact'];
    createdAt = json['created_at'];
    currency = json['currency'];
    description = json['description'];
    email = json['email'];
    entity = json['entity'];
    errorCode = json['error_code'];
    errorDescription = json['error_description'];
    errorReason = json['error_reason'];
    errorSource = json['error_source'];
    errorStep = json['error_step'];
    fee = json['fee'];
    id = json['id'];
    international = json['international'];
    invoiceId = json['invoice_id'];
    method = json['method'];
    notes = json['notes'] != null ? new Notes.fromJson(json['notes']) : null;
    orderId = json['order_id'];
    refundStatus = json['refund_status'];
    status = json['status'];
    tax = json['tax'];
    vpa = json['vpa'];
    wallet = json['wallet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.acquirerData != null) {
      data['acquirer_data'] = this.acquirerData!.toJson();
    }
    data['amount'] = this.amount;
    data['amount_refunded'] = this.amountRefunded;
    data['bank'] = this.bank;
    data['captured'] = this.captured;
    data['card_id'] = this.cardId;
    data['contact'] = this.contact;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['description'] = this.description;
    data['email'] = this.email;
    data['entity'] = this.entity;
    data['error_code'] = this.errorCode;
    data['error_description'] = this.errorDescription;
    data['error_reason'] = this.errorReason;
    data['error_source'] = this.errorSource;
    data['error_step'] = this.errorStep;
    data['fee'] = this.fee;
    data['id'] = this.id;
    data['international'] = this.international;
    data['invoice_id'] = this.invoiceId;
    data['method'] = this.method;
    if (this.notes != null) {
      data['notes'] = this.notes!.toJson();
    }
    data['order_id'] = this.orderId;
    data['refund_status'] = this.refundStatus;
    data['status'] = this.status;
    data['tax'] = this.tax;
    data['vpa'] = this.vpa;
    data['wallet'] = this.wallet;
    return data;
  }
}

class AcquirerData {
  String? bankTransactionId;

  AcquirerData({this.bankTransactionId});

  AcquirerData.fromJson(Map<String, dynamic> json) {
    bankTransactionId = json['bank_transaction_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bank_transaction_id'] = this.bankTransactionId;
    return data;
  }
}

class Notes {
  String? accNo;
  String? bankname;
  String? clientcode;
  String? companyCode;
  String? ifsc;

  Notes(
      {this.accNo,
      this.bankname,
      this.clientcode,
      this.companyCode,
      this.ifsc});

  Notes.fromJson(Map<String, dynamic> json) {
    accNo = json['acc_no'];
    bankname = json['bankname'];
    clientcode = json['clientcode'];
    companyCode = json['company_code'];
    ifsc = json['ifsc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['acc_no'] = this.accNo;
    data['bankname'] = this.bankname;
    data['clientcode'] = this.clientcode;
    data['company_code'] = this.companyCode;
    data['ifsc'] = this.ifsc;
    return data;
  }
}

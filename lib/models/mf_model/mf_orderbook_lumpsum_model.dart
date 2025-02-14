class MfLumpSumOrderbook {
  List<Null>? purchase;
  List<PusrchaseNotListed>? pusrchaseNotListed;
  List<RedeemptionNotListed>? redeemptionNotListed;
  List<Null>? reedem;
  String? stat;
  List<Null>? xsipCancellationNotListed;
  List<XsipPurchaseNotListed>? xsipPurchaseNotListed;
  List allMFLumpSumOrderbook = [];

  MfLumpSumOrderbook(
      {this.purchase,
      this.pusrchaseNotListed,
      this.redeemptionNotListed,
      this.reedem,
      this.stat,
      this.xsipCancellationNotListed,
      this.xsipPurchaseNotListed});

  MfLumpSumOrderbook.fromJson(Map<String, dynamic> json) {
    // if (json['purchase'] != null) {
    //   purchase = <Null>[];
    //   json['purchase'].forEach((v) {
    //     purchase!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['pusrchase_not_listed'] != null) {
      pusrchaseNotListed = <PusrchaseNotListed>[];
      json['pusrchase_not_listed'].forEach((v) {
        pusrchaseNotListed!.add(PusrchaseNotListed.fromJson(v));
        allMFLumpSumOrderbook.add(PusrchaseNotListed.fromJson(v));
      });
    }
    if (json['redeemption_not_listed'] != null) {
      redeemptionNotListed = <RedeemptionNotListed>[];
      json['redeemption_not_listed'].forEach((v) {
        redeemptionNotListed!.add(RedeemptionNotListed.fromJson(v));
        allMFLumpSumOrderbook.add(RedeemptionNotListed.fromJson(v));
      });
    }
    // if (json['reedem'] != null) {
    //   reedem = <Null>[];
    //   json['reedem'].forEach((v) {
    //     reedem!.add(new Null.fromJson(v));
    //   });
    // }
    stat = json['stat'];
    // if (json['xsip_cancellation_not_listed'] != null) {
    //   xsipCancellationNotListed = <Null>[];
    //   json['xsip_cancellation_not_listed'].forEach((v) {
    //     xsipCancellationNotListed!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['xsip_purchase_not_listed'] != null) {
      xsipPurchaseNotListed = <XsipPurchaseNotListed>[];
      json['xsip_purchase_not_listed'].forEach((v) {
        xsipPurchaseNotListed!.add(XsipPurchaseNotListed.fromJson(v));
        allMFLumpSumOrderbook.add(XsipPurchaseNotListed.fromJson(v));

      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (this.purchase != null) {
    //   data['purchase'] = this.purchase!.map((v) => v.toJson()).toList();
    // }
    if (pusrchaseNotListed != null) {
      data['pusrchase_not_listed'] =
          pusrchaseNotListed!.map((v) => v.toJson()).toList();
    }
    if (redeemptionNotListed != null) {
      data['redeemption_not_listed'] =
          redeemptionNotListed!.map((v) => v.toJson()).toList();
    }
    // if (this.reedem != null) {
    //   data['reedem'] = this.reedem!.map((v) => v.toJson()).toList();
    // }
    data['stat'] = stat;
    // if (this.xsipCancellationNotListed != null) {
    //   data['xsip_cancellation_not_listed'] =
    //       this.xsipCancellationNotListed!.map((v) => v.toJson()).toList();
    // }
    if (xsipPurchaseNotListed != null) {
      data['xsip_purchase_not_listed'] =
          xsipPurchaseNotListed!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PusrchaseNotListed {
  String? amount;
  String? transactionType;
  String? transactionTypeOrderStatus;

  String? date;
  String? schemeCode;
  String? schemeName;
  String? clientcode;
  String? dates;
  String? dateTime;
  String? localStatus;
  String? memberId;
  String? mfStatus;
  String? orderNumber;
  String? purchaseRedeemption;
  String? response;
  String? response1;
  String? uniqueReferNumber;
  String? uniqueTransactionCode;
  String? userId;

  PusrchaseNotListed(
      {this.amount,
      this.date,
      this.schemeCode,
      this.schemeName,
      this.clientcode,
      this.dates,
      this.dateTime,
      this.localStatus,
      this.memberId,
      this.mfStatus,
      this.orderNumber,
      this.purchaseRedeemption,
      this.response,
      this.response1,
      this.uniqueReferNumber,
      this.uniqueTransactionCode,
      this.userId});

  PusrchaseNotListed.fromJson(Map<String, dynamic> json) {
    amount = json['Amount'];
    transactionType = "Lumpsum";
    transactionTypeOrderStatus = json['mf_status'] == "0" ? "Pending" : "Failed";
    date = json['Date'];
    schemeCode = json['Scheme_Code'];
    schemeName = json['Scheme_Name'];
    clientcode = json['clientcode'];
    dates = json['date'];
    dateTime = json['date_time'];
    localStatus = json['local_status'];
    memberId = json['member_id'];
    mfStatus = json['mf_status'];
    orderNumber = json['order_number'];
    purchaseRedeemption = json['purchase_redeemption'];
    response = json['response'];
    response1 = json['response1'];
    uniqueReferNumber = json['unique_refer_number'];
    uniqueTransactionCode = json['unique_transaction_code'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Amount'] = amount;
    data['Date'] = date;
    data['Scheme_Code'] = schemeCode;
    data['Scheme_Name'] = schemeName;
    data['clientcode'] = clientcode;
    data['date'] = dates;
    data['date_time'] = dateTime;
    data['local_status'] = localStatus;
    data['member_id'] = memberId;
    data['mf_status'] = mfStatus;
    data['order_number'] = orderNumber;
    data['purchase_redeemption'] = purchaseRedeemption;
    data['response'] = response;
    data['response1'] = response1;
    data['unique_refer_number'] = uniqueReferNumber;
    data['unique_transaction_code'] = uniqueTransactionCode;
    data['user_id'] = userId;
    return data;
  }
}

class RedeemptionNotListed {
  String? amount;
  String? transactionType;
  String? transactionTypeOrderStatus;
  String? date;
  String? schemeCode;
  String? schemeName;
  String? clientcode;
  String? dates;
  String? dateTime;
  String? localStatus;
  String? memberId;
  String? mfStatus;
  String? orderNumber;
  String? purchaseRedeemption;
  String? response;
  String? response1;
  String? uniqueReferNumber;
  String? uniqueTransactionCode;
  String? userId;

  RedeemptionNotListed(
      {this.amount,
      this.date,
      this.schemeCode,
      this.schemeName,
      this.clientcode,
      this.dates,
      this.dateTime,
      this.localStatus,
      this.memberId,
      this.mfStatus,
      this.orderNumber,
      this.purchaseRedeemption,
      this.response,
      this.response1,
      this.uniqueReferNumber,
      this.uniqueTransactionCode,
      this.userId});

  RedeemptionNotListed.fromJson(Map<String, dynamic> json) {
    amount = json['Amount'];
    transactionType = "Redeem";
    transactionTypeOrderStatus = json['mf_status'] == "NEW" ? "Success" : "Failed";
    date = json['Date'];
    schemeCode = json['Scheme_Code'];
    schemeName = json['Scheme_Name'];
    clientcode = json['clientcode'];
    dates = json['date'];
    dateTime = json['date_time'];
    localStatus = json['local_status'];
    memberId = json['member_id'];
    mfStatus = json['mf_status'];
    orderNumber = json['order_number'];
    purchaseRedeemption = json['purchase_redeemption'];
    response = json['response'];
    response1 = json['response1'];
    uniqueReferNumber = json['unique_refer_number'];
    uniqueTransactionCode = json['unique_transaction_code'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Amount'] = amount;
    data['Date'] = date;
    data['Scheme_Code'] = schemeCode;
    data['Scheme_Name'] = schemeName;
    data['clientcode'] = clientcode;
    data['date'] = dates;
    data['date_time'] = dateTime;
    data['local_status'] = localStatus;
    data['member_id'] = memberId;
    data['mf_status'] = mfStatus;
    data['order_number'] = orderNumber;
    data['purchase_redeemption'] = purchaseRedeemption;
    data['response'] = response;
    data['response1'] = response1;
    data['unique_refer_number'] = uniqueReferNumber;
    data['unique_transaction_code'] = uniqueTransactionCode;
    data['user_id'] = userId;
    return data;
  }
}

class XsipPurchaseNotListed {
  String? amount;
  String? transactionType;
  String? transactionTypeOrderStatus;
  String? bSESchemeCode;
  String? buySell;
  String? buySellType;
  String? clientCode;
  String? clientName;
  String? dPTxnType;
  String? date;
  String? eUINFlag;
  String? eUINNumber;
  String? firstOrderTodayFlag;
  String? folioNo;
  String? internalRefNo;
  String? kYCFlag;
  String? memberCode;
  String? orderNumber;
  String? orderStatus;
  String? orderType;
  String? quantity;
  String? rTASchemeCode;
  String? schemeName;
  String? subBrokerARNCode;
  String? subBrokerCode;
  String? subOrderType;
  String? childOrderStat;

  String? response;
  String? response1;
  String? responseMessage;
  String? stat;
  String? transactionCode;
  String? transactionNumber;
  String? uniqueReferNumber;

  XsipPurchaseNotListed(
      {this.amount,
      this.bSESchemeCode,
      this.buySell,
      this.buySellType,
      this.clientCode,
      this.clientName,
      this.dPTxnType,
      this.date,
      this.eUINFlag,
      this.eUINNumber,
      this.firstOrderTodayFlag,
      this.folioNo,
      this.internalRefNo,
      this.kYCFlag,
      this.memberCode,
      this.orderNumber,
      this.orderStatus,
      this.orderType,
      this.quantity,
      this.rTASchemeCode,
      this.schemeName,
      this.subBrokerARNCode,
      this.subBrokerCode,
      this.subOrderType,
      this.childOrderStat,
      this.response,
      this.response1,
      this.responseMessage,
      this.stat,
      this.transactionCode,
      this.transactionNumber,
      this.uniqueReferNumber});

  XsipPurchaseNotListed.fromJson(Map<String, dynamic> json) {
    amount = json['Amount'];
    transactionType = "X-SIP";
    transactionTypeOrderStatus = json['OrderStatus'] == "NEW" ? "Success" : "Failed";
    bSESchemeCode = json['BSESchemeCode'];
    buySell = json['BuySell'];
    buySellType = json['BuySellType'];
    clientCode = json['ClientCode'];
    clientName = json['ClientName'];
    dPTxnType = json['DPTxnType'];
    date = json['Date'];
    eUINFlag = json['EUINFlag'];
    eUINNumber = json['EUINNumber'];
    firstOrderTodayFlag = json['FirstOrderTodayFlag'];
    folioNo = json['FolioNo'];
    internalRefNo = json['InternalRefNo'];
    kYCFlag = json['KYCFlag'];
    memberCode = json['MemberCode'];
    orderNumber = json['OrderNumber'];
    orderStatus = json['OrderStatus'];
    orderType = json['OrderType'];
    quantity = json['Quantity'];
    rTASchemeCode = json['RTASchemeCode'];
    schemeName = json['SchemeName'];
    subBrokerARNCode = json['SubBrokerARNCode'];
    subBrokerCode = json['SubBrokerCode'];
    subOrderType = json['SubOrderType'];
    childOrderStat = json['child_order_stat'];
    clientCode = json['client_code'];
    orderNumber = json['order_number'];
    response = json['response'];
    response1 = json['response1'];
    responseMessage = json['response_message'];
    stat = json['stat'];
    transactionCode = json['transaction_code'];
    transactionNumber = json['transaction_number'];
    uniqueReferNumber = json['unique_refer_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Amount'] = amount;
    data['BSESchemeCode'] = bSESchemeCode;
    data['BuySell'] = buySell;
    data['BuySellType'] = buySellType;
    data['ClientCode'] = clientCode;
    data['ClientName'] = clientName;
    data['DPTxnType'] = dPTxnType;
    data['Date'] = date;
    data['EUINFlag'] = eUINFlag;
    data['EUINNumber'] = eUINNumber;
    data['FirstOrderTodayFlag'] = firstOrderTodayFlag;
    data['FolioNo'] = folioNo;
    data['InternalRefNo'] = internalRefNo;
    data['KYCFlag'] = kYCFlag;
    data['MemberCode'] = memberCode;
    data['OrderNumber'] = orderNumber;
    data['OrderStatus'] = orderStatus;
    data['OrderType'] = orderType;
    data['Quantity'] = quantity;
    data['RTASchemeCode'] = rTASchemeCode;
    data['SchemeName'] = schemeName;
    data['SubBrokerARNCode'] = subBrokerARNCode;
    data['SubBrokerCode'] = subBrokerCode;
    data['SubOrderType'] = subOrderType;
    data['child_order_stat'] = childOrderStat;
    data['client_code'] = clientCode;
    data['order_number'] = orderNumber;
    data['response'] = response;
    data['response1'] = response1;
    data['response_message'] = responseMessage;
    data['stat'] = stat;
    data['transaction_code'] = transactionCode;
    data['transaction_number'] = transactionNumber;
    data['unique_refer_number'] = uniqueReferNumber;
    return data;
  }
}

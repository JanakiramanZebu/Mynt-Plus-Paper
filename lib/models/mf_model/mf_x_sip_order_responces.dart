class XsipOrderResponces {
  String? amount;
  String? bSESchemeCode;
  String? buySell;
  String? buySellType;
  String? clientCode;
  String? clientName;
  String? dPTxnType;
  String? eUINFlag;
  String? eUINNumber;
  String? firstOrderTodayFlag;
  String? folioNo;
  String? intRefNo;
  String? kYCFlag;
  String? memberCode;
  String? orderNumber;
  String? orderType;
  String? quantity;
  String? rTASchemeCode;
  String? schemeName;
  String? subBrokerARNCode;
  String? subBrokerCode;
  String? subOrderType;
  String? childOrderStat;
  String? responseMessage;
  String? stat;
  String? transactionCode;
  String? transactionNumber;
  String? error;
  String? msg;
   String? transCode;
  String? transNo;
  String? userId; 
  String? remarks;
  String? status;
  String? name; 
  String? source;
  String? placedBy;
  String? iPAddress;
  String? datetime;
  String? installmentAmount; 
  String? iSIN;
  String? dPFolioNo;
  String? sIPRegnNo;
  String? sIPRegnDate;
  String? firstOrderNo;

  XsipOrderResponces(
      {this.amount,
      this.bSESchemeCode,
      this.buySell,
      this.buySellType,
      this.clientCode,
      this.clientName,
      this.dPTxnType,
      this.eUINFlag,
      this.eUINNumber,
      this.firstOrderTodayFlag,
      this.folioNo,
      this.intRefNo,
      this.kYCFlag,
      this.memberCode,
      this.orderNumber,
      this.orderType,
      this.quantity,
      this.rTASchemeCode,
      this.schemeName,
      this.subBrokerARNCode,
      this.subBrokerCode,
      this.subOrderType,
      this.childOrderStat,
      this.responseMessage,
      this.stat,
      this.transactionCode,
      this.transactionNumber,
      this.error,
      this.transCode,
      this.transNo,
      this.userId, 
      this.remarks,
      this.status,
      this.name, 
      this.source,
      this.placedBy,
      this.iPAddress,
      this.datetime,
      this.installmentAmount, 
      this.iSIN,
      this.dPFolioNo,
      this.sIPRegnNo,
      this.sIPRegnDate,
      this.firstOrderNo,
      this.msg});

  XsipOrderResponces.fromJson(Map<String, dynamic> json) {
    amount = json['Amount'];
    bSESchemeCode = json['BSESchemeCode'];
    buySell = json['BuySell'];
    buySellType = json['BuySellType'];
    clientCode = json['ClientCode'];
    clientName = json['ClientName'];
    dPTxnType = json['DPTxnType'];
    eUINFlag = json['EUINFlag'];
    eUINNumber = json['EUINNumber'];
    firstOrderTodayFlag = json['FirstOrderTodayFlag'];
    folioNo = json['FolioNo'];
    intRefNo = json['IntRefNo'];
    kYCFlag = json['KYCFlag'];
    memberCode = json['MemberCode'];
    orderNumber = json['OrderNumber'];
    orderType = json['OrderType'];
    quantity = json['Quantity'];
    rTASchemeCode = json['RTASchemeCode'];
    schemeName = json['SchemeName'];
    subBrokerARNCode = json['SubBrokerARNCode'];
    subBrokerCode = json['SubBrokerCode'];
    subOrderType = json['SubOrderType'];
    childOrderStat = json['child_order_stat'];
    responseMessage = json['response_message'];
    stat = json['stat'];
    transactionCode = json['transaction_code'];
    transactionNumber = json['transaction_number'];
    error = json['error'];
    msg = json['msg'];
    transCode = json['TransCode'];
    transNo = json['TransNo'];
    userId = json['UserId'];
    memberCode = json['MemberCode'];
    clientCode = json['ClientCode'];
    remarks = json['Remarks'];
    status = json['status'];
    name = json['name'];
    stat = json['stat'];
    source = json['source'];
    placedBy = json['placed_by'];
    iPAddress = json['IPAddress'];
    datetime = json['datetime'];
    installmentAmount = json['InstallmentAmount'];
    folioNo = json['FolioNo'];
    iSIN = json['ISIN'];
    dPFolioNo = json['DPFolioNo'];
    sIPRegnNo = json['SIPRegnNo'];
    sIPRegnDate = json['SIPRegnDate'];
    firstOrderNo = json['First_order_no'];
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
    data['EUINFlag'] = eUINFlag;
    data['EUINNumber'] = eUINNumber;
    data['FirstOrderTodayFlag'] = firstOrderTodayFlag;
    data['FolioNo'] = folioNo;
    data['IntRefNo'] = intRefNo;
    data['KYCFlag'] = kYCFlag;
    data['MemberCode'] = memberCode;
    data['OrderNumber'] = orderNumber;
    data['OrderType'] = orderType;
    data['Quantity'] = quantity;
    data['RTASchemeCode'] = rTASchemeCode;
    data['SchemeName'] = schemeName;
    data['SubBrokerARNCode'] = subBrokerARNCode;
    data['SubBrokerCode'] = subBrokerCode;
    data['SubOrderType'] = subOrderType;
    data['child_order_stat'] = childOrderStat;
    data['response_message'] = responseMessage;
    data['stat'] = stat;
    data['transaction_code'] = transactionCode;
    data['transaction_number'] = transactionNumber;
    data['error'] = error;
    data['msg'] = msg;
    data['TransCode'] = transCode;
    data['TransNo'] = transNo;
    data['UserId'] = userId;
    data['MemberCode'] = memberCode;
    data['ClientCode'] = clientCode;
    data['Remarks'] = remarks;
    data['status'] = status;
    data['name'] = name;
    data['stat'] = stat;
    data['source'] = source;
    data['placed_by'] = placedBy;
    data['IPAddress'] = iPAddress;
    data['datetime'] = datetime;
    data['InstallmentAmount'] = installmentAmount;
    data['FolioNo'] = folioNo;
    data['ISIN'] = iSIN;
    data['DPFolioNo'] = dPFolioNo;
    data['SIPRegnNo'] = sIPRegnNo;
    data['SIPRegnDate'] = sIPRegnDate;
    data['First_order_no'] = firstOrderNo;
    return data;
  }
}

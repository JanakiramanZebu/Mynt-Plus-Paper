class PlacedBondOrderResp {
  String? lastActionTime;
  String? applicationNumber;
  String? clearingReason;
  String? clearingStatus;
  String? clientBenId;
  String? clientRefNumber;
  String? depository;
  String? dpId;
  String? enteredBy;
  String? entryTime;
  int? investmentValue;
  int? orderNumber;
  String? orderStatus;
  String? orderStatusResponse;
  String? pan;
  String? physicalDematFlag;
  int? price;
  String? rejectionReason;
  String? series;
  String? status;
  String? symbol;
  String? reason;
  int? totalAmountPayable;
  String? verificationReason;
  String? verificationStatus;

  PlacedBondOrderResp(
      {this.lastActionTime,
      this.applicationNumber,
      this.clearingReason,
      this.clearingStatus,
      this.clientBenId,
      this.clientRefNumber,
      this.depository,
      this.dpId,
      this.enteredBy,
      this.entryTime,
      this.investmentValue,
      this.orderNumber,
      this.orderStatus,
      this.orderStatusResponse,
      this.pan,
      this.physicalDematFlag,
      this.price,
      this.rejectionReason,
      this.series,
      this.status,
      this.symbol,
      this.reason,
      this.totalAmountPayable,
      this.verificationReason,
      this.verificationStatus});

  PlacedBondOrderResp.fromJson(Map<String, dynamic> json) {
    print('json data :::::::::::;   ${json["totalAmountPayable"].runtimeType}');
    lastActionTime = json['LastActionTime'];
    applicationNumber = json['applicationNumber'];
    clearingReason = json['clearingReason'];
    clearingStatus = json['clearingStatus'];
    clientBenId = json['clientBenId'];
    clientRefNumber = json['clientRefNumber'];
    depository = json['depository'];
    dpId = json['dpId'];
    enteredBy = json['enteredBy'];
    entryTime = json['entryTime'];
    investmentValue = json.containsKey('investmentValue') ? int.parse(json['investmentValue'].toString()): null;
    orderNumber = json.containsKey('orderNumber') ? int.parse(json['orderNumber'].toString()) : null;
    orderStatus = json['orderStatus'];
    orderStatusResponse = json['orderStatus_response'];
    pan = json['pan'];
    physicalDematFlag = json['physicalDematFlag'];
    price = json.containsKey('price') ? double.parse(json['price'].toString()).toInt() : null;
    rejectionReason = json['rejectionReason'];
    series = json['series'];
    status = json['status'];
    symbol = json['symbol'];
    reason = json['reason'];
    totalAmountPayable = json.containsKey('totalAmountPayable') ? double.parse(json['totalAmountPayable'].toString()).toInt() : null; 
    verificationReason = json['verificationReason'];
    verificationStatus = json['verificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LastActionTime'] = lastActionTime;
    data['applicationNumber'] = applicationNumber;
    data['clearingReason'] = clearingReason;
    data['clearingStatus'] = clearingStatus;
    data['clientBenId'] = clientBenId;
    data['clientRefNumber'] = clientRefNumber;
    data['depository'] = depository;
    data['dpId'] = dpId;
    data['enteredBy'] = enteredBy;
    data['entryTime'] = entryTime;
    data['investmentValue'] = investmentValue;
    data['orderNumber'] = orderNumber;
    data['orderStatus'] = orderStatus;
    data['orderStatus_response'] = orderStatusResponse;
    data['pan'] = pan;
    data['physicalDematFlag'] = physicalDematFlag;
    data['price'] = price;
    data['rejectionReason'] = rejectionReason;
    data['series'] = series;
    data['status'] = status;
    data['symbol'] = symbol;
    data['reason']=reason;
    data['totalAmountPayable'] = totalAmountPayable;
    data['verificationReason'] = verificationReason;
    data['verificationStatus'] = verificationStatus;
    return data;
  }
}
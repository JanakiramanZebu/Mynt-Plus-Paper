// BondsOrderBookModel


//BidDetail
class BondsOrderBookModel {

  String? applicationNumber;
  BidDetail? bidDetail;
  String? clearingReason;
  String? clearingStatus;
  String? clientApplicationNumber;
  String? failReason;
  String? failReasonCode;
  String? investmentValue;
  String? orderNumber;
  String? orderStatus;
  String? reponseStatus;
  String? respApplicationNumber;
  String? responseDatetime;
  Map<String,dynamic>? responseJson;
  String? symbol;
  String? totalAmountPayable;
  String? verificationReason;
  String? verificationStatus;

  BondsOrderBookModel(
      {this.applicationNumber,
      this.bidDetail,
      this.clearingReason,
      this.clearingStatus,
      this.clientApplicationNumber,
      this.failReason,
      this.failReasonCode,
      this.investmentValue,
      this.orderNumber,
      this.orderStatus,
      this.reponseStatus,
      this.respApplicationNumber,
      this.responseDatetime,
      this.responseJson,
      this.symbol,
      this.totalAmountPayable,
      this.verificationReason,
      this.verificationStatus});

  BondsOrderBookModel.fromJson(Map<String, dynamic> json) {
    applicationNumber = json['applicationNumber'];
    bidDetail = BidDetail.fromJson(json['bid_detail']); // json['bid_detail'];
    clearingReason = json['clearingReason'];
    clearingStatus = json['clearingStatus'];
    clientApplicationNumber = json['clientApplicationNumber'];
    failReason = json['fail_reason'];
    failReasonCode = json['fail_reasonCode'].toString();
    investmentValue = json['investmentValue'];
    orderNumber = json['orderNumber'];
    orderStatus = json['orderStatus'];
    reponseStatus = json['reponse_status'];
    respApplicationNumber = json['resp_applicationNumber'].toString();
    responseDatetime = json['response_datetime'];
    responseJson = json['response_json'];
    symbol = json['symbol'];
    totalAmountPayable = json['totalAmountPayable'];
    verificationReason = json['verificationReason'];
    verificationStatus = json['verificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['applicationNumber'] = applicationNumber;
    data['bid_detail'] = bidDetail;
    data['clearingReason'] = clearingReason;
    data['clearingStatus'] = clearingStatus;
    data['clientApplicationNumber'] = clientApplicationNumber;
    data['fail_reason'] = failReason;
    data['fail_reasonCode'] = failReasonCode;
    data['investmentValue'] = investmentValue;
    data['orderNumber'] = orderNumber;
    data['orderStatus'] = orderStatus;
    data['reponse_status'] = reponseStatus;
    data['resp_applicationNumber'] = respApplicationNumber;
    data['response_datetime'] = responseDatetime;
    data['response_json'] = responseJson;
    data['symbol'] = symbol;
    data['totalAmountPayable'] = totalAmountPayable;
    data['verificationReason'] = verificationReason;
    data['verificationStatus'] = verificationStatus;
    return data;
  }

}


class BidDetail {
  String? requestfor;
  String? symbol;
  int? investmentValue;
  int? price;

  BidDetail(
      {this.requestfor, this.symbol, this.investmentValue, this.price});

  BidDetail.fromJson(Map<String, dynamic> json) {
    requestfor = json['requestfor'];
    symbol = json['symbol'];
    investmentValue = int.parse(json['investmentValue'].toString());
    price = int.parse(json['price'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestfor'] = requestfor;
    data['symbol'] = symbol;
    data['investmentValue'] = investmentValue;
    data['price'] = price;
    return data;
  }
}


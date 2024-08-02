class IpoOrderBookModel {
  String? section;
  String? applicationNumber;
  String? bidReferenceNumber;
  List<BidDetail>? bidDetail;
  String? biddingenddate;
  String? biddingstartdate;
  String? clientApplicationStringber;
  String? clientID;
  String? clientRelationID;
  String? companyName;
  String? cutoffprice;
  String? dailyendtime;
  String? dailystarttime;
  String? failReason;
  String? failReasonCode;
  String? investmentValue;
  String? issuesize;
  String? lotsize;
  String? maxprice;
  String? minbidquantity;
  String? minprice;
  String? price;
  String? reponseStatus;
  String? respApplicationStringber;
  List<RespBid>? respBid;
  String? responseDatetime;
  String? responseJson;
  String? symbol;
  String? type;
  String? upi;
  String? upiPaymentStatus;
  String? upiPaymentStatusFlag;

  IpoOrderBookModel(
      {this.section,
      this.applicationNumber,
      this.bidReferenceNumber,
      this.bidDetail,
      this.biddingenddate,
      this.biddingstartdate,
      this.clientApplicationStringber,
      this.clientID,
      this.clientRelationID,
      this.companyName,
      this.cutoffprice,
      this.dailyendtime,
      this.dailystarttime,
      this.failReason,
      this.failReasonCode,
      this.investmentValue,
      this.issuesize,
      this.lotsize,
      this.maxprice,
      this.minbidquantity,
      this.minprice,
      this.price,
      this.reponseStatus,
      this.respApplicationStringber,
      this.respBid,
      this.responseDatetime,
      this.responseJson,
      this.symbol,
      this.type,
      this.upi,
      this.upiPaymentStatus,
      this.upiPaymentStatusFlag});

  IpoOrderBookModel.fromJson(Map<String, dynamic> json) {
    section = json['Section'].toString();
    applicationNumber = json['applicationNumber'].toString();
    bidReferenceNumber = json['bidReferenceNumber'].toString();
    if (json['bid_detail'] != '' && json['bid_detail'] != null) {
      bidDetail = <BidDetail>[];
      json['bid_detail'].forEach((v) {
        bidDetail!.add(BidDetail.fromJson(v));
      });
    }
    biddingenddate = json['biddingenddate'].toString();
    biddingstartdate = json['biddingstartdate'].toString();
    clientApplicationStringber = json['clientApplicationStringber'].toString();
    clientID = json['client_ID'].toString();
    clientRelationID = json['client_relationID'].toString();
    companyName = json['company_name'].toString();
    cutoffprice = json['cutoffprice'].toString();
    dailyendtime = json['dailyendtime'].toString();
    dailystarttime = json['dailystarttime'].toString();
    failReason = json['fail_reason'].toString();
    failReasonCode = json['fail_reasonCode'].toString();
    investmentValue = json['investmentValue'].toString();
    issuesize = json['issuesize'].toString();
    lotsize = json['lotsize'].toString();
    maxprice = json['maxprice'].toString();
    minbidquantity = json['minbidquantity'].toString();
    minprice = json['minprice'].toString();
    price = json['price'].toString();
    reponseStatus = json['reponse_status'].toString();
    respApplicationStringber = json['resp_applicationStringber'].toString();
    if (json['resp_bid'] != '' && json['resp_bid'] != null) {
      respBid = <RespBid>[];
      json['resp_bid'].forEach((v) {
        respBid!.add(RespBid.fromJson(v));
      });
    }
    responseDatetime = json['response_datetime'].toString();
    responseJson = json['response_json'].toString();
    symbol = json['symbol'].toString();
    type = json['type'].toString();
    upi = json['upi'].toString();
    upiPaymentStatus = json['upiPaymentStatus'].toString();
    upiPaymentStatusFlag = json['upiPaymentStatusFlag'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Section'] = section;
    data['applicationStringber'] = applicationNumber;
    data['bidReferenceStringber'] = bidReferenceNumber;
    if (bidDetail != null) {
      data['bid_detail'] = bidDetail!.map((v) => v.toJson()).toList();
    }
    data['biddingenddate'] = biddingenddate;
    data['biddingstartdate'] = biddingstartdate;
    data['clientApplicationStringber'] = clientApplicationStringber;
    data['client_ID'] = clientID;
    data['client_relationID'] = clientRelationID;
    data['company_name'] = companyName;
    data['cutoffprice'] = cutoffprice;
    data['dailyendtime'] = dailyendtime;
    data['dailystarttime'] = dailystarttime;
    data['fail_reason'] = failReason;
    data['fail_reasonCode'] = failReasonCode;
    data['investmentValue'] = investmentValue;
    data['issuesize'] = issuesize;
    data['lotsize'] = lotsize;
    data['maxprice'] = maxprice;
    data['minbidquantity'] = minbidquantity;
    data['minprice'] = minprice;
    data['price'] = price;
    data['reponse_status'] = reponseStatus;
    data['resp_applicationStringber'] = respApplicationStringber;
    if (respBid != null) {
      data['resp_bid'] = respBid!.map((v) => v.toJson()).toList();
    }
    data['response_datetime'] = responseDatetime;
    data['response_json'] = responseJson;
    data['symbol'] = symbol;
    data['type'] = type;
    data['upi'] = upi;
    data['upiPaymentStatus'] = upiPaymentStatus;
    data['upiPaymentStatusFlag'] = upiPaymentStatusFlag;
    return data;
  }
}

class BidDetail {
  String? activityType;
  String? amount;
  bool? atCutOff;
  String? price;
  String? quantity;

  BidDetail(
      {this.activityType,
      this.amount,
      this.atCutOff,
      this.price,
      this.quantity});

  BidDetail.fromJson(Map<String, dynamic> json) {
    activityType = json['activityType'].toString();
    amount = json['amount'].toString();
    atCutOff = json['atCutOff'];
    price = json['price'].toString();
    quantity = json['quantity'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activityType'] = activityType;
    data['amount'] = amount;
    data['atCutOff'] = atCutOff;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class RespBid {
  String? activityType;
  String? amount;
  bool? atCutOff;
  String? bidReferenceStringber;
  String? price;
  String? quantity;
  String? remark;
  String? series;
  String? status;

  RespBid(
      {this.activityType,
      this.amount,
      this.atCutOff,
      this.bidReferenceStringber,
      this.price,
      this.quantity,
      this.remark,
      this.series,
      this.status});

  RespBid.fromJson(Map<String, dynamic> json) {
    activityType = json['activityType'].toString();
    amount = json['amount'].toString();
    atCutOff = json['atCutOff'];
    bidReferenceStringber = json['bidReferenceStringber'].toString();
    price = json['price'].toString();
    quantity = json['quantity'].toString();
    remark = json['remark'].toString();
    series = json['series'].toString();
    status = json['status'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activityType'] = activityType;
    data['amount'] = amount;
    data['atCutOff'] = atCutOff;
    data['bidReferenceStringber'] = bidReferenceStringber;
    data['price'] = price;
    data['quantity'] = quantity;
    data['remark'] = remark;
    data['series'] = series;
    data['status'] = status;
    return data;
  }
}

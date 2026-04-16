class CorporateActionModel {
  List<CorporateAction>? corporateAction;

  CorporateActionModel({this.corporateAction});

  CorporateActionModel.fromJson(Map<String, dynamic> json) {
    if (json['corporateAction'] != null) {
      corporateAction = <CorporateAction>[];
      json['corporateAction'].forEach((v) {
        corporateAction!.add(CorporateAction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (corporateAction != null) {
      data['corporateAction'] =
          corporateAction!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CorporateAction {
  String? asbanonasba;
  String? baseprice;
  String? biddingEndDate;
  String? biddingStartDate;
   String?  cutOffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  String? discounttype;
  String? discountvalue;
  String? errorcode;
  String? exchange;
   String?  faceValue;
   String?  id;
   String?  index;
  String? isin;
   String?  issueSize;
  String? issueType;
  String? issueValueSize;
  String?  lotSize;
 String?  maxPrice;
  String? maxbidqty;
  String? maximumpercentageday;
  String? maxvalue;
  String? message;
 String?  minBidQuantity;
   String?  minPrice;
  String? minimumpercentageday;
  String? minvalue;
  String? mktclosetime;
  String? mktopentime;
  String? name;
  String? openondate;
  String? registrar;
  String? seriesDetails;
  String? symbol;
  String?  tickSize;
  String? token;

  CorporateAction(
      {this.asbanonasba,
      this.baseprice,
      this.biddingEndDate,
      this.biddingStartDate,
      this.cutOffPrice,
      this.dailyEndTime,
      this.dailyStartTime,
      this.discounttype,
      this.discountvalue,
      this.errorcode,
      this.exchange,
      this.faceValue,
      this.id,
      this.index,
      this.isin,
      this.issueSize,
      this.issueType,
      this.issueValueSize,
      this.lotSize,
      this.maxPrice,
      this.maxbidqty,
      this.maximumpercentageday,
      this.maxvalue,
      this.message,
      this.minBidQuantity,
      this.minPrice,
      this.minimumpercentageday,
      this.minvalue,
      this.mktclosetime,
      this.mktopentime,
      this.name,
      this.openondate,
      this.registrar,
      this.seriesDetails,
      this.symbol,
      this.tickSize,
      this.token});

  CorporateAction.fromJson(Map<String, dynamic> json) {
    asbanonasba = json['asbanonasba'].toString();
    baseprice = json['baseprice'].toString();
    biddingEndDate = json['biddingEndDate'].toString();
    biddingStartDate = json['biddingStartDate'].toString();
    cutOffPrice = json['cutOffPrice'].toString();
    dailyEndTime = json['dailyEndTime'].toString();
    dailyStartTime = json['dailyStartTime'].toString();
    discounttype = json['discounttype'].toString();
    discountvalue = json['discountvalue'].toString();
    errorcode = json['errorcode'].toString();
    exchange = json['exchange'].toString();
    faceValue = json['faceValue'].toString();
    id = json['id'].toString();
    index = json['index'].toString();
    isin = json['isin'].toString();
    issueSize = json['issueSize'].toString();
    issueType = json['issueType'].toString();
    issueValueSize = json['issueValueSize'].toString();
    lotSize = json['lotSize'].toString();
    maxPrice = json['maxPrice'].toString();
    maxbidqty = json['maxbidqty'].toString();
    maximumpercentageday = json['maximumpercentageday'].toString();
    maxvalue = json['maxvalue'].toString();
    message = json['message'].toString();
    minBidQuantity = json['minBidQuantity'].toString();
    minPrice = json['minPrice'].toString();
    minimumpercentageday = json['minimumpercentageday'].toString();
    minvalue = json['minvalue'].toString();
    mktclosetime = json['mktclosetime'].toString();
    mktopentime = json['mktopentime'].toString();
    name = json['name'].toString();
    openondate = json['openondate'].toString();
    registrar = json['registrar'].toString();
    seriesDetails = json['seriesDetails'].toString();
    symbol = json['symbol'].toString();
    tickSize = json['tickSize'].toString();
    token = json['token'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['asbanonasba'] = asbanonasba;
    data['baseprice'] = baseprice;
    data['biddingEndDate'] = biddingEndDate;
    data['biddingStartDate'] = biddingStartDate;
    data['cutOffPrice'] = cutOffPrice;
    data['dailyEndTime'] = dailyEndTime;
    data['dailyStartTime'] = dailyStartTime;
    data['discounttype'] = discounttype;
    data['discountvalue'] = discountvalue;
    data['errorcode'] = errorcode;
    data['exchange'] = exchange;
    data['faceValue'] = faceValue;
    data['id'] = id;
    data['index'] = index;
    data['isin'] = isin;
    data['issueSize'] = issueSize;
    data['issueType'] = issueType;
    data['issueValueSize'] = issueValueSize;
    data['lotSize'] = lotSize;
    data['maxPrice'] = maxPrice;
    data['maxbidqty'] = maxbidqty;
    data['maximumpercentageday'] = maximumpercentageday;
    data['maxvalue'] = maxvalue;
    data['message'] = message;
    data['minBidQuantity'] = minBidQuantity;
    data['minPrice'] = minPrice;
    data['minimumpercentageday'] = minimumpercentageday;
    data['minvalue'] = minvalue;
    data['mktclosetime'] = mktclosetime;
    data['mktopentime'] = mktopentime;
    data['name'] = name;
    data['openondate'] = openondate;
    data['registrar'] = registrar;
    data['seriesDetails'] = seriesDetails;
    data['symbol'] = symbol;
    data['tickSize'] = tickSize;
    data['token'] = token;
    return data;
  }
}

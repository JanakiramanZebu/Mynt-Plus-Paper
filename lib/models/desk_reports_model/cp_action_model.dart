class CPActionModule {
  List<CorporateAction>? corporateAction;

  CPActionModule({this.corporateAction});

  CPActionModule.fromJson(Map<String, dynamic> json) {
    if (json['corporateAction'] != null) {
      corporateAction = <CorporateAction>[];
      json['corporateAction'].forEach((v) {
        corporateAction!.add(new CorporateAction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.corporateAction != null) {
      data['corporateAction'] =
          this.corporateAction!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CorporateAction {
  String? asbanonasba;
  String? orderstatus;
  String? eligibleornot;
  String? bidqty;
  String? approvedqty;
  String? appno;
  String? orderprice;
  String? havingqty;
  String? edisqty;
  String? baseprice;
  String? biddingEndDate;
  String? biddingStartDate;
  String? cutOffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  String? discounttype;
  String? discountvalue;
  String? errorcode;
  String? exchange;
  String? faceValue;
  String? id;
  String? index;
  String? isin;
  String? issueSize;
  String? issueType;
  String? issueValueSize;
  String? lotSize;
  String? maxPrice;
  String? maxbidqty;
  String? maximumpercentageday;
  String? maxvalue;
  String? message;
  String? minBidQuantity;
  String? minPrice;
  String? minimumpercentageday;
  String? minvalue;
  String? mktclosetime;
  String? mktopentime;
  String? name;
  String? openondate;
  String? registrar;
  String? seriesDetails;
  String? symbol;
  String? tickSize;
  String? token;

  CorporateAction(
      {this.asbanonasba,
      this.havingqty,
      this.edisqty,
      this.eligibleornot,
      this.bidqty,
      this.approvedqty,
      this.orderstatus,
      this.appno,
      this.orderprice,
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
    eligibleornot = json['eligibleornot'].toString();
    bidqty = json['bidqty'].toString();
    approvedqty = json['approvedqty'].toString();
    appno = json['appno'].toString();
    orderprice = json['orderprice'].toString();
    havingqty = json['havingqty'].toString();
    edisqty = json['edisqty'].toString();
    orderstatus = json['orderstatus'].toString();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['asbanonasba'] = this.asbanonasba;
    data['eligibleornot'] = this.eligibleornot;
    data['bidqty'] = this.bidqty;
    data['approvedqty'] = this.approvedqty;
    data['appno'] = this.appno;
    data['orderprice'] = this.orderprice;
    data['havingqty'] = this.havingqty;
    data['edisqty'] = this.edisqty;
    data['orderstatus'] = this.orderstatus;
    data['baseprice'] = this.baseprice;
    data['biddingEndDate'] = this.biddingEndDate;
    data['biddingStartDate'] = this.biddingStartDate;
    data['cutOffPrice'] = this.cutOffPrice;
    data['dailyEndTime'] = this.dailyEndTime;
    data['dailyStartTime'] = this.dailyStartTime;
    data['discounttype'] = this.discounttype;
    data['discountvalue'] = this.discountvalue;
    data['errorcode'] = this.errorcode;
    data['exchange'] = this.exchange;
    data['faceValue'] = this.faceValue;
    data['id'] = this.id;
    data['index'] = this.index;
    data['isin'] = this.isin;
    data['issueSize'] = this.issueSize;
    data['issueType'] = this.issueType;
    data['issueValueSize'] = this.issueValueSize;
    data['lotSize'] = this.lotSize;
    data['maxPrice'] = this.maxPrice;
    data['maxbidqty'] = this.maxbidqty;
    data['maximumpercentageday'] = this.maximumpercentageday;
    data['maxvalue'] = this.maxvalue;
    data['message'] = this.message;
    data['minBidQuantity'] = this.minBidQuantity;
    data['minPrice'] = this.minPrice;
    data['minimumpercentageday'] = this.minimumpercentageday;
    data['minvalue'] = this.minvalue;
    data['mktclosetime'] = this.mktclosetime;
    data['mktopentime'] = this.mktopentime;
    data['name'] = this.name;
    data['openondate'] = this.openondate;
    data['registrar'] = this.registrar;
    data['seriesDetails'] = this.seriesDetails;
    data['symbol'] = this.symbol;
    data['tickSize'] = this.tickSize;
    data['token'] = this.token;
    return data;
  }
}

class BondLists {
  String? allotmentDate;
  String? biddingEndDate;
  String? biddingStartDate;
  String? cutoffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  String? faceValue;
  String? index;
  String? isin;
  String? issueSize;
  String? issueValueSize;
  String? lastDayBiddingEndTime;
  String? lotSize;
  String? maxPrice;
  String? maxQuantity;
  String? minBidQuantity;
  String? minPrice;
  String? name;
  String? series;
  String? symbol;
  String? t1ModEndDate;
  String? t1ModEndTime;
  String? t1ModStartDate;
  String? t1ModStartTime;
  String? tickSize;

  BondLists(
      {this.allotmentDate,
      this.biddingEndDate,
      this.biddingStartDate,
      this.cutoffPrice,
      this.dailyEndTime,
      this.dailyStartTime,
      this.faceValue,
      this.index,
      this.isin,
      this.issueSize,
      this.issueValueSize,
      this.lastDayBiddingEndTime,
      this.lotSize,
      this.maxPrice,
      this.maxQuantity,
      this.minBidQuantity,
      this.minPrice,
      this.name,
      this.series,
      this.symbol,
      this.t1ModEndDate,
      this.t1ModEndTime,
      this.t1ModStartDate,
      this.t1ModStartTime,
      this.tickSize});

  BondLists.fromJson(Map<String, dynamic> json) {
    allotmentDate = json['allotmentDate'].toString();
    biddingEndDate = json['biddingEndDate'].toString();
    biddingStartDate = json['biddingStartDate'].toString();
    cutoffPrice = json['cutoffPrice'].toString();
    dailyEndTime = json['dailyEndTime'].toString();
    dailyStartTime = json['dailyStartTime'].toString();
    faceValue = json['faceValue'].toString();
    index = json['index'].toString();
    isin = json['isin'].toString();
    issueSize = json['issueSize'].toString();
    issueValueSize = json['issueValueSize'].toString();
    lastDayBiddingEndTime = json['lastDayBiddingEndTime'].toString();
    lotSize = json['lotSize'].toString();
    maxPrice = json['maxPrice'].toString();
    maxQuantity = json['maxQuantity'].toString();
    minBidQuantity = json['minBidQuantity'].toString();
    minPrice = json['minPrice'].toString();
    name = json['name'].toString();
    series = json['series'].toString();
    symbol = json['symbol'].toString();
    t1ModEndDate = json['t1ModEndDate'].toString();
    t1ModEndTime = json['t1ModEndTime'].toString();
    t1ModStartDate = json['t1ModStartDate'].toString();
    t1ModStartTime = json['t1ModStartTime'].toString();
    tickSize = json['tickSize'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allotmentDate'] = allotmentDate;
    data['biddingEndDate'] = biddingEndDate;
    data['biddingStartDate'] = biddingStartDate;
    data['cutoffPrice'] = cutoffPrice;
    data['dailyEndTime'] = dailyEndTime;
    data['dailyStartTime'] = dailyStartTime;
    data['faceValue'] = faceValue;
    data['index'] = index;
    data['isin'] = isin;
    data['issueSize'] = issueSize;
    data['issueValueSize'] = issueValueSize;
    data['lastDayBiddingEndTime'] = lastDayBiddingEndTime;
    data['lotSize'] = lotSize;
    data['maxPrice'] = maxPrice;
    data['maxQuantity'] = maxQuantity;
    data['minBidQuantity'] = minBidQuantity;
    data['minPrice'] = minPrice;
    data['name'] = name;
    data['series'] = series;
    data['symbol'] = symbol;
    data['t1ModEndDate'] = t1ModEndDate;
    data['t1ModEndTime'] = t1ModEndTime;
    data['t1ModStartDate'] = t1ModStartDate;
    data['t1ModStartTime'] = t1ModStartTime;
    data['tickSize'] = tickSize;
    return data;
  }
}
class Gsecdata {
  List<NCBGsec>? nCBGsec;

  Gsecdata({this.nCBGsec});

  Gsecdata.fromJson(Map<String, dynamic> json) {
    if (json['NCBGsec'] != null) {
      nCBGsec = <NCBGsec>[];
      json['NCBGsec'].forEach((v) {
        nCBGsec!.add(NCBGsec.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NCBGsec'] = nCBGsec!.map((v) => v.toJson()).toList();
    if (nCBGsec != null) {}
    return data;
  }
}

class NCBGsec {
  String? allotmentDate;
  String? biddingEndDate;
  String? biddingStartDate;
  num? cutoffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  num? faceValue;
  num? index;
  String? isin;
  num? issueSize;
  num? issueValueSize;
  String? lastDayBiddingEndTime;
  num? lotSize;
  num? maxPrice;
  num? maxQuantity;
  num? minBidQuantity;
  num? minPrice;
  String? name;
  String? series;
  String? symbol;
  String? t1ModEndDate;
  String? t1ModEndTime;
  String? t1ModStartDate;
  String? t1ModStartTime;
  num? tickSize;

  NCBGsec(
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

  NCBGsec.fromJson(Map<String, dynamic> json) {
    allotmentDate = json['allotmentDate'];
    biddingEndDate = json['biddingEndDate'];
    biddingStartDate = json['biddingStartDate'];
    cutoffPrice = json['cutoffPrice'];
    dailyEndTime = json['dailyEndTime'];
    dailyStartTime = json['dailyStartTime'];
    faceValue = json['faceValue'];
    index = json['index'];
    isin = json['isin'];
    issueSize = json['issueSize'];
    issueValueSize = json['issueValueSize'];
    lastDayBiddingEndTime = json['lastDayBiddingEndTime'];
    lotSize = json['lotSize'];
    maxPrice = json['maxPrice'];
    maxQuantity = json['maxQuantity'];
    minBidQuantity = json['minBidQuantity'];
    minPrice = json['minPrice'];
    name = json['name'];
    series = json['series'];
    symbol = json['symbol'];
    t1ModEndDate = json['t1ModEndDate'];
    t1ModEndTime = json['t1ModEndTime'];
    t1ModStartDate = json['t1ModStartDate'];
    t1ModStartTime = json['t1ModStartTime'];
    tickSize = json['tickSize'];
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

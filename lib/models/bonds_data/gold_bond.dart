class Goldbondmodel {
  List<SGB>? sGB;

  Goldbondmodel({this.sGB});

  Goldbondmodel.fromJson(Map<String, dynamic> json) {
    if (json['SGB'] != null) {
      sGB = <SGB>[];
      json['SGB'].forEach((v) {
        sGB!.add(SGB.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sGB != null) {
      data['SGB'] = sGB!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SGB {
  String? allotmentDate;
  String? biddingEndDate;
  String? biddingStartDate;
  String? dailyEndTime;
  String? dailyStartTime;
  num? faceValue;
  String? incompleteModEndDate;
  num? index;
  String? isin;
  num? issueSize;
  String? issueType;
  num? issueValueSize;
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

  SGB(
      {this.allotmentDate,
      this.biddingEndDate,
      this.biddingStartDate,
      this.dailyEndTime,
      this.dailyStartTime,
      this.faceValue,
      this.incompleteModEndDate,
      this.index,
      this.isin,
      this.issueSize,
      this.issueType,
      this.issueValueSize,
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

  SGB.fromJson(Map<String, dynamic> json) {
    allotmentDate = json['allotmentDate'];
    biddingEndDate = json['biddingEndDate'];
    biddingStartDate = json['biddingStartDate'];
    dailyEndTime = json['dailyEndTime'];
    dailyStartTime = json['dailyStartTime'];
    faceValue = json['faceValue'];
    incompleteModEndDate = json['incompleteModEndDate'];
    index = json['index'];
    isin = json['isin'];
    issueSize = json['issueSize'];
    issueType = json['issueType'];
    issueValueSize = json['issueValueSize'];
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
    data['dailyEndTime'] = dailyEndTime;
    data['dailyStartTime'] = dailyStartTime;
    data['faceValue'] = faceValue;
    data['incompleteModEndDate'] = incompleteModEndDate;
    data['index'] = index;
    data['isin'] = isin;
    data['issueSize'] = issueSize;
    data['issueType'] = issueType;
    data['issueValueSize'] = issueValueSize;
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

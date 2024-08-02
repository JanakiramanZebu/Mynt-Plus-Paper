class SmeIpoModel {
  List<SMEIPO>? sMEIPO;

  SmeIpoModel({this.sMEIPO});

  SmeIpoModel.fromJson(Map<String, dynamic> json) {
    if (json['SMEIPO'] != null) {
      sMEIPO = <SMEIPO>[];
      json['SMEIPO'].forEach((v) {
        sMEIPO!.add(SMEIPO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sMEIPO != null) {
      data['SMEIPO'] = sMEIPO!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SMEIPO {
  String? asbanonasba;
  String? biddingEndDate;
  String? biddingStartDate;
  List<CategoryDetails>? categoryDetails;
  String? closedatetime;
  String? companyName;
  num? cutOffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  String? discounttype;
  String? discountvalue;
  String? errorcode;
  num? faceValue;
  num? id;
  num? index;
  String? isin;
  num? issueSize;
  String? issueType;
  num? lotSize;
  num? maxPrice;
  String? maxbidqty;
  String? maxvalue;
  String? message;
  num? minBidQuantity;
  num? minPrice;
  String? minvalue;
  String? name;
  String? opendatetime;
  String? registrar;
  String? seriesDetails;
  List<SubCategorySettings>? subCategorySettings;
  String? subType;
  String? symbol;
  String? t1ModEndDate;
  String? t1ModEndTime;
  String? t1ModStartDate;
  String? t1ModStartTime;
  num? tickSize;
  String? tplusmodificationfrom;
  String? tplusmodificationto;
  String? type;
  String? updateIpoDate;

  SMEIPO(
      {this.asbanonasba,
      this.biddingEndDate,
      this.biddingStartDate,
      this.categoryDetails,
      this.closedatetime,
      this.companyName,
      this.cutOffPrice,
      this.dailyEndTime,
      this.dailyStartTime,
      this.discounttype,
      this.discountvalue,
      this.errorcode,
      this.faceValue,
      this.id,
      this.index,
      this.isin,
      this.issueSize,
      this.issueType,
      this.lotSize,
      this.maxPrice,
      this.maxbidqty,
      this.maxvalue,
      this.message,
      this.minBidQuantity,
      this.minPrice,
      this.minvalue,
      this.name,
      this.opendatetime,
      this.registrar,
      this.seriesDetails,
      this.subCategorySettings,
      this.subType,
      this.symbol,
      this.t1ModEndDate,
      this.t1ModEndTime,
      this.t1ModStartDate,
      this.t1ModStartTime,
      this.tickSize,
      this.tplusmodificationfrom,
      this.tplusmodificationto,
      this.type,
      this.updateIpoDate});

  SMEIPO.fromJson(Map<String, dynamic> json) {
    asbanonasba = json['asbanonasba'];
    biddingEndDate = json['biddingEndDate'];
    biddingStartDate = json['biddingStartDate'];
    if (json['categoryDetails'] != null) {
      categoryDetails = <CategoryDetails>[];
      json['categoryDetails'].forEach((v) {
        categoryDetails!.add(CategoryDetails.fromJson(v));
      });
    }
    closedatetime = json['closedatetime'];
    companyName = json['company_name'];
    cutOffPrice = json['cutOffPrice'];
    dailyEndTime = json['dailyEndTime'];
    dailyStartTime = json['dailyStartTime'];
    discounttype = json['discounttype'];
    discountvalue = json['discountvalue'];
    errorcode = json['errorcode'];
    faceValue = json['faceValue'];
    id = json['id'];
    index = json['index'];
    isin = json['isin'];
    issueSize = json['issueSize'];
    issueType = json['issueType'];
    lotSize = json['lotSize'];
    maxPrice = json['maxPrice'];
    maxbidqty = json['maxbidqty'];
    maxvalue = json['maxvalue'];
    message = json['message'];
    minBidQuantity = json['minBidQuantity'];
    minPrice = json['minPrice'];
    minvalue = json['minvalue'];
    name = json['name'];
    opendatetime = json['opendatetime'];
    registrar = json['registrar'];
    seriesDetails = json['seriesDetails'];
    if (json['subCategorySettings'] != null) {
      subCategorySettings = <SubCategorySettings>[];
      json['subCategorySettings'].forEach((v) {
        subCategorySettings!.add(SubCategorySettings.fromJson(v));
      });
    }
    subType = json['subType'];
    symbol = json['symbol'];
    t1ModEndDate = json['t1ModEndDate'];
    t1ModEndTime = json['t1ModEndTime'];
    t1ModStartDate = json['t1ModStartDate'];
    t1ModStartTime = json['t1ModStartTime'];
    tickSize = json['tickSize'];
    tplusmodificationfrom = json['tplusmodificationfrom'];
    tplusmodificationto = json['tplusmodificationto'];
    type = json['type'];
    updateIpoDate = json['update_ipo_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['asbanonasba'] = asbanonasba;
    data['biddingEndDate'] = biddingEndDate;
    data['biddingStartDate'] = biddingStartDate;
    if (categoryDetails != null) {
      data['categoryDetails'] =
          categoryDetails!.map((v) => v.toJson()).toList();
    }
    data['closedatetime'] = closedatetime;
    data['company_name'] = companyName;
    data['cutOffPrice'] = cutOffPrice;
    data['dailyEndTime'] = dailyEndTime;
    data['dailyStartTime'] = dailyStartTime;
    data['discounttype'] = discounttype;
    data['discountvalue'] = discountvalue;
    data['errorcode'] = errorcode;
    data['faceValue'] = faceValue;
    data['id'] = id;
    data['index'] = index;
    data['isin'] = isin;
    data['issueSize'] = issueSize;
    data['issueType'] = issueType;
    data['lotSize'] = lotSize;
    data['maxPrice'] = maxPrice;
    data['maxbidqty'] = maxbidqty;
    data['maxvalue'] = maxvalue;
    data['message'] = message;
    data['minBidQuantity'] = minBidQuantity;
    data['minPrice'] = minPrice;
    data['minvalue'] = minvalue;
    data['name'] = name;
    data['opendatetime'] = opendatetime;
    data['registrar'] = registrar;
    data['seriesDetails'] = seriesDetails;
    if (subCategorySettings != null) {
      data['subCategorySettings'] =
          subCategorySettings!.map((v) => v.toJson()).toList();
    }
    data['subType'] = subType;
    data['symbol'] = symbol;
    data['t1ModEndDate'] = t1ModEndDate;
    data['t1ModEndTime'] = t1ModEndTime;
    data['t1ModStartDate'] = t1ModStartDate;
    data['t1ModStartTime'] = t1ModStartTime;
    data['tickSize'] = tickSize;
    data['tplusmodificationfrom'] = tplusmodificationfrom;
    data['tplusmodificationto'] = tplusmodificationto;
    data['type'] = type;
    data['update_ipo_date'] = updateIpoDate;
    return data;
  }
}

class CategoryDetails {
  String? code;
  String? endTime;
  String? startTime;

  CategoryDetails({this.code, this.endTime, this.startTime});

  CategoryDetails.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    endTime = json['endTime'];
    startTime = json['startTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['endTime'] = endTime;
    data['startTime'] = startTime;
    return data;
  }
}

class SubCategorySettings {
  bool? allowCutOff;
  bool? allowUpi;
  String? caCode;
  num? discountPrice;
  String? discountType;
  num? maxQuantity;
  num? maxUpiLimit;
  num? maxValue;
  num? minValue;
  String? subCatCode;

  SubCategorySettings(
      {this.allowCutOff,
      this.allowUpi,
      this.caCode,
      this.discountPrice,
      this.discountType,
      this.maxQuantity,
      this.maxUpiLimit,
      this.maxValue,
      this.minValue,
      this.subCatCode});

  SubCategorySettings.fromJson(Map<String, dynamic> json) {
    allowCutOff = json['allowCutOff'];
    allowUpi = json['allowUpi'];
    caCode = json['caCode'];
    discountPrice = json['discountPrice'] ?? 0.0;
    discountType = json['discountType'];
    maxQuantity = json['maxQuantity'] ?? 0.0;
    maxUpiLimit = json['maxUpiLimit'];
    maxValue = json['maxValue'];
    minValue = json['minValue'];
    subCatCode = json['subCatCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allowCutOff'] = allowCutOff;
    data['allowUpi'] = allowUpi;
    data['caCode'] = caCode;
    data['discountPrice'] = discountPrice;
    data['discountType'] = discountType;
    data['maxQuantity'] = maxQuantity;
    data['maxUpiLimit'] = maxUpiLimit;
    data['maxValue'] = maxValue;
    data['minValue'] = minValue;
    data['subCatCode'] = subCatCode;
    return data;
  }
}

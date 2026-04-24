import 'dart:convert';

class MainStreamIpoModel {
  String? msg;
  List<MainIPO>? mainIPO;

  MainStreamIpoModel({this.mainIPO});

  MainStreamIpoModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['MainIPO'] != null) {
      mainIPO = <MainIPO>[];
      // Check if MainIPO is a List or String
      if (json['MainIPO'] is List) {
        json['MainIPO'].forEach((v) {
          mainIPO!.add(MainIPO.fromJson(v));
        });
      } else if (json['MainIPO'] is String) {
        // If MainIPO is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['MainIPO'] as String);
          if (parsedList is List) {
            for (var v in parsedList) {
              mainIPO!.add(MainIPO.fromJson(v));
            }
          }
        } catch (e) {
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (mainIPO != null) {
      data['MainIPO'] = mainIPO!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MainIPO {
  String? asbanonasba;
  String? biddingEndDate;
  String? biddingStartDate;
  List<CategoryDetails>? categoryDetails;
  String? closedatetime;
  String? companyName;
  String? cutOffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  String? days_to_end_ipo;
  String? discounttype;
  String? discountvalue;
  String? errorcode;
  String? faceValue;
  String? id;
  String? index;
  String? isin;
  String? issueSize;
  String? issueType;
  String? lotSize;
  String? maxPrice;
  String? maxbidqty;
  String? maxvalue;
  String? message;
  String? minBidQuantity;
  String? minPrice;
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
  String? tickSize;
  String? tplusmodificationfrom;
  String? tplusmodificationto;
  String? type;
  String? updateIpoDate;
  String? key;
  String? ipostatus;
  String? totalsub;

  MainIPO({
    this.asbanonasba,
    this.biddingEndDate,
    this.biddingStartDate,
    this.categoryDetails,
    this.closedatetime,
    this.companyName,
    this.cutOffPrice,
    this.dailyEndTime,
    this.dailyStartTime,
    this.days_to_end_ipo,
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
    this.updateIpoDate,
    this.totalsub,
  });

  MainIPO.fromJson(Map<String, dynamic> json) {
    asbanonasba = json['asbanonasba'].toString();
    biddingEndDate = json['biddingEndDate'].toString();
    biddingStartDate = json['biddingStartDate'].toString();
    if (json['categoryDetails'] != null) {
      categoryDetails = <CategoryDetails>[];
      // Check if categoryDetails is a List or String
      if (json['categoryDetails'] is List) {
        json['categoryDetails'].forEach((v) {
          categoryDetails!.add(CategoryDetails.fromJson(v));
        });
      } else if (json['categoryDetails'] is String) {
        // If categoryDetails is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['categoryDetails'] as String);
          if (parsedList is List) {
            for (var v in parsedList) {
              categoryDetails!.add(CategoryDetails.fromJson(v));
            }
          }
        } catch (e) {
        }
      }
    }
    days_to_end_ipo = json["days_to_end_ipo"].toString();
    closedatetime = json['closedatetime'].toString();
    companyName = json['company_name'].toString();
    cutOffPrice = json['cutOffPrice'].toString();
    dailyEndTime = json['dailyEndTime'].toString();
    dailyStartTime = json['dailyStartTime'].toString();
    discounttype = json['discounttype'].toString();
    discountvalue = json['discountvalue'].toString();
    days_to_end_ipo = json["days_to_end_ipo"].toString();
    errorcode = json['errorcode'].toString();
    faceValue = json['faceValue'].toString();
    id = json['id'].toString();
    index = json['index'].toString();
    isin = json['isin'].toString();
    issueSize = json['issueSize'].toString();
    issueType = json['issueType'].toString();
    lotSize = json['lotSize'].toString();
    maxPrice = json['maxPrice'].toString();
    maxbidqty = json['maxbidqty'].toString();
    maxvalue = json['maxvalue'].toString();
    message = json['message'].toString();
    minBidQuantity = json['minBidQuantity'].toString();
    minPrice = json['minPrice'].toString();
    minvalue = json['minvalue'].toString();
    name = json['name'].toString();
    totalsub = json['totalsub'].toString();
    opendatetime = json['opendatetime'].toString();
    registrar = json['registrar'].toString();
    seriesDetails = json['seriesDetails'].toString();
    if (json['subCategorySettings'] != null) {
      subCategorySettings = <SubCategorySettings>[];
      // Check if subCategorySettings is a List or String
      if (json['subCategorySettings'] is List) {
        json['subCategorySettings'].forEach((v) {
          subCategorySettings!.add(SubCategorySettings.fromJson(v));
        });
      } else if (json['subCategorySettings'] is String) {
        // If subCategorySettings is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['subCategorySettings'] as String);
          if (parsedList is List) {
            for (var v in parsedList) {
              subCategorySettings!.add(SubCategorySettings.fromJson(v));
            }
          }
        } catch (e) {
        }
      }
    }
    subType = json['subType'].toString();
    symbol = json['symbol'].toString();
    t1ModEndDate = json['t1ModEndDate'].toString();
    t1ModEndTime = json['t1ModEndTime'].toString();
    t1ModStartDate = json['t1ModStartDate'].toString();
    t1ModStartTime = json['t1ModStartTime'].toString();
    tickSize = json['tickSize'].toString();
    tplusmodificationfrom = json['tplusmodificationfrom'].toString();
    tplusmodificationto = json['tplusmodificationto'].toString();
    type = json['type'].toString();
    updateIpoDate = json['update_ipo_date'].toString();
    key = json['key'];
    ipostatus = "Live";
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
    data['totalsub'] = totalsub;
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
    data['key'] = key;
    return data;
  }
}

class CategoryDetails {
  String? code;
  String? endTime;
  String? startTime;

  CategoryDetails({this.code, this.endTime, this.startTime});

  CategoryDetails.fromJson(Map<String, dynamic> json) {
    code = json['code'].toString();
    endTime = json['endTime'].toString();
    startTime = json['startTime'].toString();
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
  String? discountPrice;
  String? discountType;
  String? maxQuantity;
  String? maxUpiLimit;
  String? maxValue;
  String? minValue;
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
    caCode = json['caCode'].toString();
    discountPrice = json['discountPrice'].toString();
    discountType = json['discountType'].toString();
    maxQuantity = json['maxQuantity'].toString();
    maxUpiLimit = json['maxUpiLimit'].toString();
    maxValue = json['maxValue'].toString();
    minValue = json['minValue'].toString();
    subCatCode = json['subCatCode'].toString();
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

import 'dart:convert';

class DashbordIposIPOS {
  List<Data>? data;

  DashbordIposIPOS({this.data});

  DashbordIposIPOS.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      // Check if data is a List or String
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(Data.fromJson(v));
        });
      } else if (json['data'] is String) {
        // If data is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['data'] as String);
          if (parsedList is List) {
            parsedList.forEach((v) {
              data!.add(Data.fromJson(v));
            });
          }
        } catch (e) {
          print("Error parsing data string: $e");
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? mS;
  String? asbanonasba;
  String? biddingEndDate;
  String? biddingStartDate;
  List<CategoryDetails>? categoryDetails;
  String? closedatetime;
  String? companyName;
  String? cutOffPrice;
  String? dailyEndTime;
  String? dailyStartTime;
  String? daysToEndIpo;
  String? discounttype;
  String? discountvalue;
  String? errorcode;
  String? faceValue;
  String? id;
  String? imageLink;
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
  TlSub? tlSub;
  String? tplusmodificationfrom;
  String? tplusmodificationto;
  String? type;
  String? updateIpoDate;

  Data.fromJson(Map<String, dynamic> json) {
    mS = json['MS'];
    asbanonasba = json['asbanonasba'];
    biddingEndDate = json['biddingEndDate'];
    biddingStartDate = json['biddingStartDate'];
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
            parsedList.forEach((v) {
              categoryDetails!.add(CategoryDetails.fromJson(v));
            });
          }
        } catch (e) {
          print("Error parsing categoryDetails string: $e");
        }
      }
    }
    closedatetime = json['closedatetime'];
    companyName = json['company_name'];
    cutOffPrice = json['cutOffPrice']?.toString();
    dailyEndTime = json['dailyEndTime'];
    dailyStartTime = json['dailyStartTime'];
    daysToEndIpo = json['days_to_end_ipo'];
    discounttype = json['discounttype'];
    discountvalue = json['discountvalue'];
    errorcode = json['errorcode'];
    faceValue = json['faceValue']?.toString();
    id = json['id']?.toString();
    imageLink = json['image_link'];
    index = json['index']?.toString();
    isin = json['isin'];
    issueSize = json['issueSize']?.toString();
    issueType = json['issueType'];
    lotSize = json['lotSize']?.toString();
    maxPrice = json['maxPrice']?.toString();
    maxbidqty = json['maxbidqty'];
    maxvalue = json['maxvalue'];
    message = json['message'];
    minBidQuantity = json['minBidQuantity']?.toString();
    minPrice = json['minPrice']?.toString();
    minvalue = json['minvalue'];
    name = json['name'];
    opendatetime = json['opendatetime'];
    registrar = json['registrar'];
    seriesDetails = json['seriesDetails'];
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
            parsedList.forEach((v) {
              subCategorySettings!.add(SubCategorySettings.fromJson(v));
            });
          }
        } catch (e) {
          print("Error parsing subCategorySettings string: $e");
        }
      }
    }
    subType = json['subType'];
    symbol = json['symbol'];
    t1ModEndDate = json['t1ModEndDate'];
    t1ModEndTime = json['t1ModEndTime'];
    t1ModStartDate = json['t1ModStartDate'];
    t1ModStartTime = json['t1ModStartTime'];
    tickSize = json['tickSize']?.toString();
    tlSub = json['tlSub'] != null ? TlSub.fromJson(json['tlSub']) : null;
    tplusmodificationfrom = json['tplusmodificationfrom'];
    tplusmodificationto = json['tplusmodificationto'];
    type = json['type'];
    updateIpoDate = json['update_ipo_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['MS'] = this.mS;
    data['asbanonasba'] = this.asbanonasba;
    data['biddingEndDate'] = this.biddingEndDate;
    data['biddingStartDate'] = this.biddingStartDate;
    if (this.categoryDetails != null) {
      data['categoryDetails'] =
          this.categoryDetails!.map((v) => v.toJson()).toList();
    }
    data['closedatetime'] = this.closedatetime;
    data['company_name'] = this.companyName;
    data['cutOffPrice'] = this.cutOffPrice;
    data['dailyEndTime'] = this.dailyEndTime;
    data['dailyStartTime'] = this.dailyStartTime;
    data['days_to_end_ipo'] = this.daysToEndIpo;
    data['discounttype'] = this.discounttype;
    data['discountvalue'] = this.discountvalue;
    data['errorcode'] = this.errorcode;
    data['faceValue'] = this.faceValue;
    data['id'] = this.id;
    data['image_link'] = this.imageLink;
    data['index'] = this.index;
    data['isin'] = this.isin;
    data['issueSize'] = this.issueSize;
    data['issueType'] = this.issueType;
    data['lotSize'] = this.lotSize;
    data['maxPrice'] = this.maxPrice;
    data['maxbidqty'] = this.maxbidqty;
    data['maxvalue'] = this.maxvalue;
    data['message'] = this.message;
    data['minBidQuantity'] = this.minBidQuantity;
    data['minPrice'] = this.minPrice;
    data['minvalue'] = this.minvalue;
    data['name'] = this.name;
    data['opendatetime'] = this.opendatetime;
    data['registrar'] = this.registrar;
    data['seriesDetails'] = this.seriesDetails;
    if (this.subCategorySettings != null) {
      data['subCategorySettings'] =
          this.subCategorySettings!.map((v) => v.toJson()).toList();
    }
    data['subType'] = this.subType;
    data['symbol'] = this.symbol;
    data['t1ModEndDate'] = this.t1ModEndDate;
    data['t1ModEndTime'] = this.t1ModEndTime;
    data['t1ModStartDate'] = this.t1ModStartDate;
    data['t1ModStartTime'] = this.t1ModStartTime;
    data['tickSize'] = this.tickSize;
    if (this.tlSub != null) {
      data['tlSub'] = this.tlSub!.toJson();
    }
    data['tplusmodificationfrom'] = this.tplusmodificationfrom;
    data['tplusmodificationto'] = this.tplusmodificationto;
    data['type'] = this.type;
    data['update_ipo_date'] = this.updateIpoDate;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['endTime'] = this.endTime;
    data['startTime'] = this.startTime;
    return data;
  }
}

class SubCategorySettings {
  bool? allowCutOff;
  bool? allowUpi;
  String? caCode;
  // double? discountPrice;
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
      // this.discountPrice,
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
    // discountPrice = json['discountPrice'];
    discountType = json['discountType'];
    maxQuantity = json['maxQuantity']?.toString();
    maxUpiLimit = json['maxUpiLimit']?.toString();
    maxValue = json['maxValue']?.toString();
    minValue = json['minValue']?.toString();
    subCatCode = json['subCatCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['allowCutOff'] = this.allowCutOff;
    data['allowUpi'] = this.allowUpi;
    data['caCode'] = this.caCode;
    // data['discountPrice'] = this.discountPrice;
    data['discountType'] = this.discountType;
    data['maxQuantity'] = this.maxQuantity;
    data['maxUpiLimit'] = this.maxUpiLimit;
    data['maxValue'] = this.maxValue;
    data['minValue'] = this.minValue;
    data['subCatCode'] = this.subCatCode;
    return data;
  }
}

class TlSub {
  String? category;
  String? sharesOffered;
  String? sharesBidFor;
  double? subscriptionTimes;
  String? totalApplication;

  TlSub(
      {this.category,
      this.sharesOffered,
      this.sharesBidFor,
      this.subscriptionTimes,
      this.totalApplication});

  TlSub.fromJson(Map<String, dynamic> json) {
    category = json['Category'];
    sharesOffered = json['Shares Offered']?.toString();
    sharesBidFor = json['Shares bid for']?.toString();
    subscriptionTimes = json['Subscription (times)'];
    totalApplication = json['Total Application']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Category'] = this.category;
    data['Shares Offered'] = this.sharesOffered;
    data['Shares bid for'] = this.sharesBidFor;
    data['Subscription (times)'] = this.subscriptionTimes;
    data['Total Application'] = this.totalApplication;
    return data;
  }
}

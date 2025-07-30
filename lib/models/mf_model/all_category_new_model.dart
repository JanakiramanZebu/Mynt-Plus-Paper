class mf_catge_newlist {
  List<Data>? data;

  mf_catge_newlist({this.data});

  mf_catge_newlist.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? name;
  List<Values>? values;

  Data({this.name, this.values});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values!.add(Values.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Values {
  String? name;
  List<Fund>? values;

  Values({this.name, this.values});

  Values.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['values'] != null) {
      values = <Fund>[];
      json['values'].forEach((v) {
        values!.add(Fund.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fund {
   String? aUM;
  String? name;
  String? s1Year;
  String? s3Year;
  String? s5Year;
  String? iSIN;
  String? type;
  String? subType;
  String? aMCCode;
  String? schemeType;
  String? schemeCode;
  String? exitLoadFlag;
  String? schemeName;
  String? purchaseAllowed;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? redemptionAllowed;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? redemptionAmountMinimum;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? exitLoad;
  String? reOpeningDate;
  String? sETTLEMENTTYPE;
  String? startDate;
  String? endDate;

  Fund(
      {
      this.aUM,
      this.name,
      this.s1Year,
      this.s3Year,
      this.s5Year,
      this.iSIN,
      this.type,
      this.subType,
      this.aMCCode,
      this.schemeType,
      this.schemeCode,
      this.exitLoadFlag,
      this.schemeName,
      this.purchaseAllowed,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.redemptionAllowed,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.redemptionAmountMinimum,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.exitLoad,
      this.reOpeningDate,
      this.sETTLEMENTTYPE,
      this.startDate,
      this.endDate});

  Fund.fromJson(Map<String, dynamic> json) {
     aUM = json['AUM'];
    name = json['name'];
    s1Year = json['1Year'];
    s3Year = json['3Year'];
    s5Year = json['5Year'];
    iSIN = json['ISIN'];
    type = json['Type'];
    subType = json['SubType'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemeCode = json['Scheme_Code'];
    exitLoadFlag = json['Exit_Load_Flag'];
    schemeName = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    redemptionAllowed = json['Redemption_Allowed'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    exitLoad = json['Exit_Load'];
    reOpeningDate = json['ReOpening_Date'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
     data['AUM'] = this.aUM;
    data['name'] = this.name;
    data['1Year'] = this.s1Year;
    data['3Year'] = this.s3Year;
    data['5Year'] = this.s5Year;
    data['ISIN'] = this.iSIN;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Code'] = this.schemeCode;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Scheme_Name'] = this.schemeName;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['Exit_Load'] = this.exitLoad;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    return data;
  }
}
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

class FundL1 {
  String? schemeCode;
  String? iSIN;
  String? schemeName;
  String? purchaseAllowed;
  String? sIPFLAG;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? redemptionAllowed;

  FundL1({
    this.schemeCode,
    this.iSIN,
    this.schemeName,
    this.purchaseAllowed,
    this.sIPFLAG,
    this.minimumPurchaseAmount,
    this.additionalPurchaseAmount,
    this.maximumPurchaseAmount,
    this.redemptionAllowed,
  });

  FundL1.fromJson(Map<String, dynamic> json) {
    schemeCode = json['Scheme_Code'];
    iSIN = json['ISIN'];
    schemeName = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    sIPFLAG = json['SIP_FLAG'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    redemptionAllowed = json['Redemption_Allowed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Scheme_Code'] = schemeCode;
    data['ISIN'] = iSIN;
    data['Scheme_Name'] = schemeName;
    data['Purchase_Allowed'] = purchaseAllowed;
    data['SIP_FLAG'] = sIPFLAG;
    data['Minimum_Purchase_Amount'] = minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = maximumPurchaseAmount;
    data['Redemption_Allowed'] = redemptionAllowed;
    return data;
  }
}

class FundVariant {
  String? schemeCode;
  String? iSIN;
  String? schemeName;
  String? purchaseAllowed;
  String? sIPFLAG;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? redemptionAllowed;
  FundL1? l1;

  FundVariant({
    this.schemeCode,
    this.iSIN,
    this.schemeName,
    this.purchaseAllowed,
    this.sIPFLAG,
    this.minimumPurchaseAmount,
    this.additionalPurchaseAmount,
    this.maximumPurchaseAmount,
    this.redemptionAllowed,
    this.l1,
  });

  FundVariant.fromJson(Map<String, dynamic> json) {
    schemeCode = json['Scheme_Code'];
    iSIN = json['ISIN'];
    schemeName = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    sIPFLAG = json['SIP_FLAG'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    redemptionAllowed = json['Redemption_Allowed'];
    l1 = (json['L1'] != null && (json['L1'] as Map).isNotEmpty)
        ? FundL1.fromJson(json['L1'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Scheme_Code'] = schemeCode;
    data['ISIN'] = iSIN;
    data['Scheme_Name'] = schemeName;
    data['Purchase_Allowed'] = purchaseAllowed;
    data['SIP_FLAG'] = sIPFLAG;
    data['Minimum_Purchase_Amount'] = minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = maximumPurchaseAmount;
    data['Redemption_Allowed'] = redemptionAllowed;
    if (l1 != null) data['L1'] = l1!.toJson();
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
  String? schemegroupid;
  FundVariant? iDCW;
  FundVariant? reinv;
  FundL1? l1;

  Fund({
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
    this.endDate,
    this.schemegroupid,
    this.iDCW,
    this.reinv,
    this.l1,
  });

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
    schemegroupid = json['schemegroupid'];
    iDCW = (json['IDCW'] != null && (json['IDCW'] as Map).isNotEmpty)
        ? FundVariant.fromJson(json['IDCW'])
        : null;
    reinv = (json['Reinv'] != null && (json['Reinv'] as Map).isNotEmpty)
        ? FundVariant.fromJson(json['Reinv'])
        : null;
    l1 = (json['L1'] != null && (json['L1'] as Map).isNotEmpty)
        ? FundL1.fromJson(json['L1'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AUM'] = aUM;
    data['name'] = name;
    data['1Year'] = s1Year;
    data['3Year'] = s3Year;
    data['5Year'] = s5Year;
    data['ISIN'] = iSIN;
    data['Type'] = type;
    data['SubType'] = subType;
    data['AMC_Code'] = aMCCode;
    data['Scheme_Type'] = schemeType;
    data['Scheme_Code'] = schemeCode;
    data['Exit_Load_Flag'] = exitLoadFlag;
    data['Scheme_Name'] = schemeName;
    data['Purchase_Allowed'] = purchaseAllowed;
    data['Minimum_Purchase_Amount'] = minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = maximumPurchaseAmount;
    data['Redemption_Allowed'] = redemptionAllowed;
    data['Minimum_Redemption_Qty'] = minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = redemptionQtyMultiplier;
    data['Redemption_Amount_Minimum'] = redemptionAmountMinimum;
    data['Dividend_Reinvestment_Flag'] = dividendReinvestmentFlag;
    data['SIP_FLAG'] = sIPFLAG;
    data['Exit_Load'] = exitLoad;
    data['ReOpening_Date'] = reOpeningDate;
    data['SETTLEMENT_TYPE'] = sETTLEMENTTYPE;
    data['Start_Date'] = startDate;
    data['End_Date'] = endDate;
    data['schemegroupid'] = schemegroupid;
    if (iDCW != null) data['IDCW'] = iDCW!.toJson();
    if (reinv != null) data['Reinv'] = reinv!.toJson();
    if (l1 != null) data['L1'] = l1!.toJson();
    return data;
  }
}

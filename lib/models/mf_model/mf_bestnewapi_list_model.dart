class BestmfNewlist {
  Data? data;

  BestmfNewlist({this.data});

  BestmfNewlist.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<BasketsLength>? basketsLength;
  Baskets? baskets;

  Data({this.basketsLength, this.baskets});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['baskets_length'] != null) {
      basketsLength = <BasketsLength>[];
      json['baskets_length'].forEach((v) {
        basketsLength!.add(BasketsLength.fromJson(v));
      });
    }
    baskets =
        json['baskets'] != null ? Baskets.fromJson(json['baskets']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (basketsLength != null) {
      data['baskets_length'] =
          basketsLength!.map((v) => v.toJson()).toList();
    }
    if (baskets != null) {
      data['baskets'] = baskets!.toJson();
    }
    return data;
  }
}

class BasketsLength {
  String? title;
  int? count;

  BasketsLength({this.title, this.count});

  BasketsLength.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['count'] = count;
    return data;
  }
}

class Baskets {
  List<TaxSaving>? taxSaving;
  List<HighGrowthEquity>? highGrowthEquity;
  List<StableDebt>? stableDebt;
  List<SectoralThematic>? sectoralThematic;
  List<InternationalExposure>? internationalExposure;
  List<BalancedHybrid>? balancedHybrid;

  Baskets(
      {this.taxSaving,
      this.highGrowthEquity,
      this.stableDebt,
      this.sectoralThematic,
      this.internationalExposure,
      this.balancedHybrid});

  Baskets.fromJson(Map<String, dynamic> json) {
    if (json['Tax Saving'] != null) {
      taxSaving = <TaxSaving>[];
      json['Tax Saving'].forEach((v) {
        taxSaving!.add(TaxSaving.fromJson(v));
      });
    }
    if (json['High Growth Equity'] != null) {
      highGrowthEquity = <HighGrowthEquity>[];
      json['High Growth Equity'].forEach((v) {
        highGrowthEquity!.add(HighGrowthEquity.fromJson(v));
      });
    }
    if (json['Stable Debt'] != null) {
      stableDebt = <StableDebt>[];
      json['Stable Debt'].forEach((v) {
        stableDebt!.add(StableDebt.fromJson(v));
      });
    }
    if (json['Sectoral Thematic'] != null) {
      sectoralThematic = <SectoralThematic>[];
      json['Sectoral Thematic'].forEach((v) {
        sectoralThematic!.add(SectoralThematic.fromJson(v));
      });
    }
    if (json['International Exposure'] != null) {
      internationalExposure = <InternationalExposure>[];
      json['International Exposure'].forEach((v) {
        internationalExposure!.add(InternationalExposure.fromJson(v));
      });
    }
    if (json['Balanced Hybrid'] != null) {
      balancedHybrid = <BalancedHybrid>[];
      json['Balanced Hybrid'].forEach((v) {
        balancedHybrid!.add(BalancedHybrid.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (taxSaving != null) {
      data['Tax Saving'] = taxSaving!.map((v) => v.toJson()).toList();
    }
    if (highGrowthEquity != null) {
      data['High Growth Equity'] =
          highGrowthEquity!.map((v) => v.toJson()).toList();
    }
    if (stableDebt != null) {
      data['Stable Debt'] = stableDebt!.map((v) => v.toJson()).toList();
    }
    if (sectoralThematic != null) {
      data['Sectoral Thematic'] =
          sectoralThematic!.map((v) => v.toJson()).toList();
    }
    if (internationalExposure != null) {
      data['International Exposure'] =
          internationalExposure!.map((v) => v.toJson()).toList();
    }
    if (balancedHybrid != null) {
      data['Balanced Hybrid'] =
          balancedHybrid!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaxSaving {
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

  TaxSaving(
      {this.aUM,
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

  TaxSaving.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}

class HighGrowthEquity {
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

  HighGrowthEquity(
      {this.aUM,
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

  HighGrowthEquity.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}

class StableDebt {
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

  StableDebt(
      {this.aUM,
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

  StableDebt.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}

class SectoralThematic {
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

  SectoralThematic(
      {this.aUM,
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

  SectoralThematic.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}


class InternationalExposure {
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

  InternationalExposure(
      {this.aUM,
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

  InternationalExposure.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
} 

class BalancedHybrid {
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

  BalancedHybrid(
      {this.aUM,
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

  BalancedHybrid.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}


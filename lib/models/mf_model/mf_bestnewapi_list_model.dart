class BestmfNewlist {
  Data? data;

  BestmfNewlist({this.data});

  BestmfNewlist.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
        basketsLength!.add(new BasketsLength.fromJson(v));
      });
    }
    baskets =
        json['baskets'] != null ? new Baskets.fromJson(json['baskets']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.basketsLength != null) {
      data['baskets_length'] =
          this.basketsLength!.map((v) => v.toJson()).toList();
    }
    if (this.baskets != null) {
      data['baskets'] = this.baskets!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['count'] = this.count;
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
        taxSaving!.add(new TaxSaving.fromJson(v));
      });
    }
    if (json['High Growth Equity'] != null) {
      highGrowthEquity = <HighGrowthEquity>[];
      json['High Growth Equity'].forEach((v) {
        highGrowthEquity!.add(new HighGrowthEquity.fromJson(v));
      });
    }
    if (json['Stable Debt'] != null) {
      stableDebt = <StableDebt>[];
      json['Stable Debt'].forEach((v) {
        stableDebt!.add(new StableDebt.fromJson(v));
      });
    }
    if (json['Sectoral Thematic'] != null) {
      sectoralThematic = <SectoralThematic>[];
      json['Sectoral Thematic'].forEach((v) {
        sectoralThematic!.add(new SectoralThematic.fromJson(v));
      });
    }
    if (json['International Exposure'] != null) {
      internationalExposure = <InternationalExposure>[];
      json['International Exposure'].forEach((v) {
        internationalExposure!.add(new InternationalExposure.fromJson(v));
      });
    }
    if (json['Balanced Hybrid'] != null) {
      balancedHybrid = <BalancedHybrid>[];
      json['Balanced Hybrid'].forEach((v) {
        balancedHybrid!.add(new BalancedHybrid.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.taxSaving != null) {
      data['Tax Saving'] = this.taxSaving!.map((v) => v.toJson()).toList();
    }
    if (this.highGrowthEquity != null) {
      data['High Growth Equity'] =
          this.highGrowthEquity!.map((v) => v.toJson()).toList();
    }
    if (this.stableDebt != null) {
      data['Stable Debt'] = this.stableDebt!.map((v) => v.toJson()).toList();
    }
    if (this.sectoralThematic != null) {
      data['Sectoral Thematic'] =
          this.sectoralThematic!.map((v) => v.toJson()).toList();
    }
    if (this.internationalExposure != null) {
      data['International Exposure'] =
          this.internationalExposure!.map((v) => v.toJson()).toList();
    }
    if (this.balancedHybrid != null) {
      data['Balanced Hybrid'] =
          this.balancedHybrid!.map((v) => v.toJson()).toList();
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


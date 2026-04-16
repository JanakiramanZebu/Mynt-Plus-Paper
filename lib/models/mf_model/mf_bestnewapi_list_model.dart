class BestmfNewlist {
  Data? data;

  BestmfNewlist({this.data});

  BestmfNewlist.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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
    final Map<String, dynamic> data = {};
    if (basketsLength != null) {
      data['baskets_length'] = basketsLength!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['count'] = count;
    return data;
  }
}

class Baskets {
  List<BestMfFund>? taxSaving;
  List<BestMfFund>? highGrowthEquity;
  List<BestMfFund>? stableDebt;
  List<BestMfFund>? sectoralThematic;
  List<BestMfFund>? internationalExposure;
  List<BestMfFund>? balancedHybrid;

  Baskets({
    this.taxSaving,
    this.highGrowthEquity,
    this.stableDebt,
    this.sectoralThematic,
    this.internationalExposure,
    this.balancedHybrid,
  });

  Baskets.fromJson(Map<String, dynamic> json) {
    if (json['Tax Saving'] != null) {
      taxSaving = <BestMfFund>[];
      json['Tax Saving'].forEach((v) => taxSaving!.add(BestMfFund.fromJson(v)));
    }
    if (json['High Growth Equity'] != null) {
      highGrowthEquity = <BestMfFund>[];
      json['High Growth Equity'].forEach((v) => highGrowthEquity!.add(BestMfFund.fromJson(v)));
    }
    if (json['Stable Debt'] != null) {
      stableDebt = <BestMfFund>[];
      json['Stable Debt'].forEach((v) => stableDebt!.add(BestMfFund.fromJson(v)));
    }
    if (json['Sectoral Thematic'] != null) {
      sectoralThematic = <BestMfFund>[];
      json['Sectoral Thematic'].forEach((v) => sectoralThematic!.add(BestMfFund.fromJson(v)));
    }
    if (json['International Exposure'] != null) {
      internationalExposure = <BestMfFund>[];
      json['International Exposure'].forEach((v) => internationalExposure!.add(BestMfFund.fromJson(v)));
    }
    if (json['Balanced Hybrid'] != null) {
      balancedHybrid = <BestMfFund>[];
      json['Balanced Hybrid'].forEach((v) => balancedHybrid!.add(BestMfFund.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (taxSaving != null) data['Tax Saving'] = taxSaving!.map((v) => v.toJson()).toList();
    if (highGrowthEquity != null) data['High Growth Equity'] = highGrowthEquity!.map((v) => v.toJson()).toList();
    if (stableDebt != null) data['Stable Debt'] = stableDebt!.map((v) => v.toJson()).toList();
    if (sectoralThematic != null) data['Sectoral Thematic'] = sectoralThematic!.map((v) => v.toJson()).toList();
    if (internationalExposure != null) data['International Exposure'] = internationalExposure!.map((v) => v.toJson()).toList();
    if (balancedHybrid != null) data['Balanced Hybrid'] = balancedHybrid!.map((v) => v.toJson()).toList();
    return data;
  }
}

/// Shared fund class used across all basket categories.
class BestMfFund {
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
  String? iDCWSchemeCode;
  String? iDCWMinimumPurchaseAmount;
  String? iDCWAdditionalPurchaseAmount;
  String? iDCWMaximumPurchaseAmount;
  String? iDCWL1SchemeCode;
  String? iDCWL1MinimumPurchaseAmount;
  String? iDCWL1MaximumPurchaseAmount;
  String? reinvSchemeCode;
  String? reinvMinimumPurchaseAmount;
  String? reinvAdditionalPurchaseAmount;
  String? reinvMaximumPurchaseAmount;
  String? reinvL1SchemeCode;
  String? reinvL1MinimumPurchaseAmount;
  String? reinvL1MaximumPurchaseAmount;
  String? l1SchemeCode;
  String? l1MinimumPurchaseAmount;
  String? l1MaximumPurchaseAmount;

  BestMfFund({
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
    this.iDCWSchemeCode,
    this.reinvSchemeCode,
    this.l1SchemeCode,
  });

  BestMfFund.fromJson(Map<String, dynamic> json) {
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
    if (json['IDCW'] is Map && (json['IDCW'] as Map).isNotEmpty) {
      iDCWSchemeCode = json['IDCW']['Scheme_Code'];
      iDCWMinimumPurchaseAmount = json['IDCW']['Minimum_Purchase_Amount'];
      iDCWAdditionalPurchaseAmount = json['IDCW']['Additional_Purchase_Amount'];
      iDCWMaximumPurchaseAmount = json['IDCW']['Maximum_Purchase_Amount'];
      if (json['IDCW']['L1'] is Map && (json['IDCW']['L1'] as Map).isNotEmpty) {
        iDCWL1SchemeCode = json['IDCW']['L1']['Scheme_Code'];
        iDCWL1MinimumPurchaseAmount = json['IDCW']['L1']['Minimum_Purchase_Amount'];
        iDCWL1MaximumPurchaseAmount = json['IDCW']['L1']['Maximum_Purchase_Amount'];
      }
    }
    if (json['Reinv'] is Map && (json['Reinv'] as Map).isNotEmpty) {
      reinvSchemeCode = json['Reinv']['Scheme_Code'];
      reinvMinimumPurchaseAmount = json['Reinv']['Minimum_Purchase_Amount'];
      reinvAdditionalPurchaseAmount = json['Reinv']['Additional_Purchase_Amount'];
      reinvMaximumPurchaseAmount = json['Reinv']['Maximum_Purchase_Amount'];
      if (json['Reinv']['L1'] is Map && (json['Reinv']['L1'] as Map).isNotEmpty) {
        reinvL1SchemeCode = json['Reinv']['L1']['Scheme_Code'];
        reinvL1MinimumPurchaseAmount = json['Reinv']['L1']['Minimum_Purchase_Amount'];
        reinvL1MaximumPurchaseAmount = json['Reinv']['L1']['Maximum_Purchase_Amount'];
      }
    }
    if (json['L1'] is Map && (json['L1'] as Map).isNotEmpty) {
      l1SchemeCode = json['L1']['Scheme_Code'];
      l1MinimumPurchaseAmount = json['L1']['Minimum_Purchase_Amount'];
      l1MaximumPurchaseAmount = json['L1']['Maximum_Purchase_Amount'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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
    if (iDCWSchemeCode != null) {
      final idcw = <String, dynamic>{
        'Scheme_Code': iDCWSchemeCode,
        'Minimum_Purchase_Amount': iDCWMinimumPurchaseAmount,
        'Additional_Purchase_Amount': iDCWAdditionalPurchaseAmount,
        'Maximum_Purchase_Amount': iDCWMaximumPurchaseAmount,
      };
      if (iDCWL1SchemeCode != null) {
        idcw['L1'] = {
          'Scheme_Code': iDCWL1SchemeCode,
          'Minimum_Purchase_Amount': iDCWL1MinimumPurchaseAmount,
          'Maximum_Purchase_Amount': iDCWL1MaximumPurchaseAmount,
        };
      }
      data['IDCW'] = idcw;
    }
    if (reinvSchemeCode != null) {
      final reinv = <String, dynamic>{
        'Scheme_Code': reinvSchemeCode,
        'Minimum_Purchase_Amount': reinvMinimumPurchaseAmount,
        'Additional_Purchase_Amount': reinvAdditionalPurchaseAmount,
        'Maximum_Purchase_Amount': reinvMaximumPurchaseAmount,
      };
      if (reinvL1SchemeCode != null) {
        reinv['L1'] = {
          'Scheme_Code': reinvL1SchemeCode,
          'Minimum_Purchase_Amount': reinvL1MinimumPurchaseAmount,
          'Maximum_Purchase_Amount': reinvL1MaximumPurchaseAmount,
        };
      }
      data['Reinv'] = reinv;
    }
    if (l1SchemeCode != null) {
      data['L1'] = {
        'Scheme_Code': l1SchemeCode,
        'Minimum_Purchase_Amount': l1MinimumPurchaseAmount,
        'Maximum_Purchase_Amount': l1MaximumPurchaseAmount,
      };
    }
    return data;
  }
}

// Type aliases for backwards compatibility with existing screen code
typedef TaxSaving = BestMfFund;
typedef HighGrowthEquity = BestMfFund;
typedef StableDebt = BestMfFund;
typedef SectoralThematic = BestMfFund;
typedef InternationalExposure = BestMfFund;
typedef BalancedHybrid = BestMfFund;

class BestmfNewlist {
  List<BasketsLength>? basketsLength;
  Baskets? baskets;

  BestmfNewlist({this.basketsLength, this.baskets});

  BestmfNewlist.fromJson(Map<String, dynamic> json) {
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
  String? count;

  BasketsLength({this.title, this.count});

  BasketsLength.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    count = json['count'].toString();
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
  Baskets({this.taxSaving, this.highGrowthEquity,this.stableDebt,this.sectoralThematic,this.internationalExposure, this.balancedHybrid});

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
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aum;
  String? s1Day;
  String? s7Day;
  String? s15Day;
  String? s30Day;
  String? s3Month;
  String? s6Month;
  String? s1Year;
  String? s2Year;
  String? s3Year;
  String? s5Year;
  String? s10Year;
  String? s15Year;
  String? s20Year;
  String? s25Year;
  String? isRecommended;
  String? s1YearSIPReturn;
  String? s3YearSIPReturn;
  String? s5YearSIPReturn;
  String? s10YearSIPReturn;
  String? s15YearSIPReturn;
  String? s20YearSIPReturn;
  String? sinceInceptionReturn;
  String? iSIN;
  String? schemeName;
  String? type;
  String? subType;
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
  String? schemeNameNew;
  String? purchaseAllowed;
  String? purchaseTransactionMode;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? redemptionAllowed;
  String? redemptionTransactionMode;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? maximumRedemptionQty;
  String? redemptionAmountMinimum;
  String? redemptionAmountMaximum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? rTAAgentCode;
  String? aMCActiveFlag;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? switchFLAG;
  String? sETTLEMENTTYPE;
  String? aMCIND;
  String? faceValue;
  String? startDate;
  String? endDate;
  String? exitLoadFlag;
  String? exitLoad;
  String? lockInPeriodFlag;
  String? lockInPeriod;
  String? channelPartnerCode;
  String? reOpeningDate;
  String? name;
  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? launchDate;
  String? closureDate;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
  bool? isAdd;

  TaxSaving(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aum,
      this.s1Day,
      this.s7Day,
      this.s15Day,
      this.s30Day,
      this.s3Month,
      this.s6Month,
      this.s1Year,
      this.s2Year,
      this.s3Year,
      this.s5Year,
      this.s10Year,
      this.s15Year,
      this.s20Year,
      this.s25Year,
      this.isRecommended,
      this.s1YearSIPReturn,
      this.s3YearSIPReturn,
      this.s5YearSIPReturn,
      this.s10YearSIPReturn,
      this.s15YearSIPReturn,
      this.s20YearSIPReturn,
      this.sinceInceptionReturn,
      this.iSIN,
      this.schemeName,
      this.type,
      this.subType,
      this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeNameNew,
      this.purchaseAllowed,
      this.purchaseTransactionMode,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.redemptionAllowed,
      this.redemptionTransactionMode,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.maximumRedemptionQty,
      this.redemptionAmountMinimum,
      this.redemptionAmountMaximum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.rTAAgentCode,
      this.aMCActiveFlag,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.switchFLAG,
      this.sETTLEMENTTYPE,
      this.aMCIND,
      this.faceValue,
      this.startDate,
      this.endDate,
      this.exitLoadFlag,
      this.exitLoad,
      this.lockInPeriodFlag,
      this.lockInPeriod,
      this.channelPartnerCode,
      this.reOpeningDate,
      this.name,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.nAVSchemeType,
      this.isAdd});

  TaxSaving.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aum = json['aum'];
    s1Day = json['1Day'];
    s7Day = json['7Day'];
    s15Day = json['15Day'];
    s30Day = json['30Day'];
    s3Month = json['3Month'];
    s6Month = json['6Month'];
    s1Year = json['1Year'];
    s2Year = json['2Year'];
    s3Year = json['3Year'];
    s5Year = json['5Year'];
    s10Year = json['10Year'];
    s15Year = json['15Year'];
    s20Year = json['20Year'];
    s25Year = json['25Year'];
    isRecommended = json['isRecommended'];
    s1YearSIPReturn = json['1YearSIPReturn'];
    s3YearSIPReturn = json['3YearSIPReturn'];
    s5YearSIPReturn = json['5YearSIPReturn'];
    s10YearSIPReturn = json['10YearSIPReturn'];
    s15YearSIPReturn = json['15YearSIPReturn'];
    s20YearSIPReturn = json['20YearSIPReturn'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
    iSIN = json['ISIN'];
    schemeName = json['schemeName'];
    type = json['Type'];
    subType = json['SubType'];
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemePlan = json['Scheme_Plan'];
    schemeNameNew = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    purchaseTransactionMode = json['Purchase_Transaction_mode'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
    purchaseCutoffTime = json['Purchase_Cutoff_Time'];
    redemptionAllowed = json['Redemption_Allowed'];
    redemptionTransactionMode = json['Redemption_Transaction_Mode'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    maximumRedemptionQty = json['Maximum_Redemption_Qty'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
    redemptionCutOffTime = json['Redemption_Cut_off_Time'];
    rTAAgentCode = json['RTA_Agent_Code'];
    aMCActiveFlag = json['AMC_Active_Flag'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    sTPFLAG = json['STP_FLAG'];
    sWPFlag = json['SWP_Flag'];
    switchFLAG = json['Switch_FLAG'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    aMCIND = json['AMC_IND'];
    faceValue = json['Face_Value'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
    exitLoadFlag = json['Exit_Load_Flag'];
    exitLoad = json['Exit_Load'];
    lockInPeriodFlag = json['Lock_in_Period_Flag'];
    lockInPeriod = json['Lock_in_Period'];
    channelPartnerCode = json['Channel Partner_Code'];
    reOpeningDate = json['ReOpening_Date'];
    name = json['Name'];
    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['THREE_YEAR_DATA'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    isAdd = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schemeGroupName'] = this.schemeGroupName;
    data['fundName'] = this.fundName;
    data['category'] = this.category;
    data['aum'] = this.aum;
    data['1Day'] = this.s1Day;
    data['7Day'] = this.s7Day;
    data['15Day'] = this.s15Day;
    data['30Day'] = this.s30Day;
    data['3Month'] = this.s3Month;
    data['6Month'] = this.s6Month;
    data['1Year'] = this.s1Year;
    data['2Year'] = this.s2Year;
    data['3Year'] = this.s3Year;
    data['5Year'] = this.s5Year;
    data['10Year'] = this.s10Year;
    data['15Year'] = this.s15Year;
    data['20Year'] = this.s20Year;
    data['25Year'] = this.s25Year;
    data['isRecommended'] = this.isRecommended;
    data['1YearSIPReturn'] = this.s1YearSIPReturn;
    data['3YearSIPReturn'] = this.s3YearSIPReturn;
    data['5YearSIPReturn'] = this.s5YearSIPReturn;
    data['10YearSIPReturn'] = this.s10YearSIPReturn;
    data['15YearSIPReturn'] = this.s15YearSIPReturn;
    data['20YearSIPReturn'] = this.s20YearSIPReturn;
    data['sinceInceptionReturn'] = this.sinceInceptionReturn;
    data['ISIN'] = this.iSIN;
    data['schemeName'] = this.schemeName;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeNameNew;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
    data['RTA_Agent_Code'] = this.rTAAgentCode;
    data['AMC_Active_Flag'] = this.aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['STP_FLAG'] = this.sTPFLAG;
    data['SWP_Flag'] = this.sWPFlag;
    data['Switch_FLAG'] = this.switchFLAG;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['AMC_IND'] = this.aMCIND;
    data['Face_Value'] = this.faceValue;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Exit_Load'] = this.exitLoad;
    data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
    data['Lock_in_Period'] = this.lockInPeriod;
    data['Channel Partner_Code'] = this.channelPartnerCode;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['Name'] = this.name;
    data['AUM'] = this.aUM;
    data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
    data['Launch_Date'] = this.launchDate;
    data['Closure_Date'] = this.closureDate;
    data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
    data['f_scheme_name'] = this.fSchemeName;
    data['NAV_Scheme_Type'] = this.nAVSchemeType;
    data['isAdd'] = isAdd;
    return data;
  }
}

class HighGrowthEquity {
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aum;
  String? s1Day;
  String? s7Day;
  String? s15Day;
  String? s30Day;
  String? s3Month;
  String? s6Month;
  String? s1Year;
  String? s2Year;
  String? d3Year;
  String? d5Year;
  String? s10Year;
  String? s15Year;
  String? s20Year;
  String? s25Year;
  String? isRecommended;
  String? s1YearSIPReturn;
  String? s3YearSIPReturn;
  String? s5YearSIPReturn;
  String? s10YearSIPReturn;
  String? s15YearSIPReturn;
  String? s20YearSIPReturn;
  String? sinceInceptionReturn;
  String? iSIN;
  String? schemeName;
  String? type;
  String? subType;
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
 String? schemeNameNew;
  String? purchaseAllowed;
  String? purchaseTransactionMode;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? redemptionAllowed;
  String? redemptionTransactionMode;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? maximumRedemptionQty;
  String? redemptionAmountMinimum;
  String? redemptionAmountMaximum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? rTAAgentCode;
  String? aMCActiveFlag;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? switchFLAG;
  String? sETTLEMENTTYPE;
  String? aMCIND;
  String? faceValue;
  String? startDate;
  String? endDate;
  String? exitLoadFlag;
  String? exitLoad;
  String? lockInPeriodFlag;
  String? lockInPeriod;
  String? channelPartnerCode;
  String? reOpeningDate;
  String? name;
  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? launchDate;
  String? closureDate;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
  bool? isAdd;

  HighGrowthEquity(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aum,
      this.s1Day,
      this.s7Day,
      this.s15Day,
      this.s30Day,
      this.s3Month,
      this.s6Month,
      this.s1Year,
      this.s2Year,
      this.d3Year,
      this.d5Year,
      this.s10Year,
      this.s15Year,
      this.s20Year,
      this.s25Year,
      this.isRecommended,
      this.s1YearSIPReturn,
      this.s3YearSIPReturn,
      this.s5YearSIPReturn,
      this.s10YearSIPReturn,
      this.s15YearSIPReturn,
      this.s20YearSIPReturn,
      this.sinceInceptionReturn,
      this.iSIN,
      this.schemeName,
      this.type,
      this.subType,
      this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeNameNew,
      this.purchaseAllowed,
      this.purchaseTransactionMode,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.redemptionAllowed,
      this.redemptionTransactionMode,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.maximumRedemptionQty,
      this.redemptionAmountMinimum,
      this.redemptionAmountMaximum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.rTAAgentCode,
      this.aMCActiveFlag,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.switchFLAG,
      this.sETTLEMENTTYPE,
      this.aMCIND,
      this.faceValue,
      this.startDate,
      this.endDate,
      this.exitLoadFlag,
      this.exitLoad,
      this.lockInPeriodFlag,
      this.lockInPeriod,
      this.channelPartnerCode,
      this.reOpeningDate,
      this.name,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.nAVSchemeType,
      this.isAdd});

  HighGrowthEquity.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aum = json['aum'];
    s1Day = json['1Day'];
    s7Day = json['7Day'];
    s15Day = json['15Day'];
    s30Day = json['30Day'];
    s3Month = json['3Month'];
    s6Month = json['6Month'];
    s1Year = json['1Year'];
    s2Year = json['2Year'];
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    s10Year = json['10Year'];
    s15Year = json['15Year'];
    s20Year = json['20Year'];
    s25Year = json['25Year'];
    isRecommended = json['isRecommended'];
    s1YearSIPReturn = json['1YearSIPReturn'];
    s3YearSIPReturn = json['3YearSIPReturn'];
    s5YearSIPReturn = json['5YearSIPReturn'];
    s10YearSIPReturn = json['10YearSIPReturn'];
    s15YearSIPReturn = json['15YearSIPReturn'];
    s20YearSIPReturn = json['20YearSIPReturn'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
    iSIN = json['ISIN'];
    schemeName = json['schemeName'];
    type = json['Type'];
    subType = json['SubType'];
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemePlan = json['Scheme_Plan'];
    // schemeNameNew = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    purchaseTransactionMode = json['Purchase_Transaction_mode'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
    purchaseCutoffTime = json['Purchase_Cutoff_Time'];
    redemptionAllowed = json['Redemption_Allowed'];
    redemptionTransactionMode = json['Redemption_Transaction_Mode'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    maximumRedemptionQty = json['Maximum_Redemption_Qty'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
    redemptionCutOffTime = json['Redemption_Cut_off_Time'];
    rTAAgentCode = json['RTA_Agent_Code'];
    aMCActiveFlag = json['AMC_Active_Flag'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    sTPFLAG = json['STP_FLAG'];
    sWPFlag = json['SWP_Flag'];
    switchFLAG = json['Switch_FLAG'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    aMCIND = json['AMC_IND'];
    faceValue = json['Face_Value'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
    exitLoadFlag = json['Exit_Load_Flag'];
    exitLoad = json['Exit_Load'];
    lockInPeriodFlag = json['Lock_in_Period_Flag'];
    lockInPeriod = json['Lock_in_Period'];
    channelPartnerCode = json['Channel Partner_Code'];
    reOpeningDate = json['ReOpening_Date'];
    name = json['Name'];
    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['THREE_YEAR_DATA'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    isAdd = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schemeGroupName'] = this.schemeGroupName;
    data['fundName'] = this.fundName;
    data['category'] = this.category;
    data['aum'] = this.aum;
    data['1Day'] = this.s1Day;
    data['7Day'] = this.s7Day;
    data['15Day'] = this.s15Day;
    data['30Day'] = this.s30Day;
    data['3Month'] = this.s3Month;
    data['6Month'] = this.s6Month;
    data['1Year'] = this.s1Year;
    data['2Year'] = this.s2Year;
    data['3Year'] = this.d3Year;
    data['5Year'] = this.d5Year;
    data['10Year'] = this.s10Year;
    data['15Year'] = this.s15Year;
    data['20Year'] = this.s20Year;
    data['25Year'] = this.s25Year;
    data['isRecommended'] = this.isRecommended;
    data['1YearSIPReturn'] = this.s1YearSIPReturn;
    data['3YearSIPReturn'] = this.s3YearSIPReturn;
    data['5YearSIPReturn'] = this.s5YearSIPReturn;
    data['10YearSIPReturn'] = this.s10YearSIPReturn;
    data['15YearSIPReturn'] = this.s15YearSIPReturn;
    data['20YearSIPReturn'] = this.s20YearSIPReturn;
    data['sinceInceptionReturn'] = this.sinceInceptionReturn;
    data['ISIN'] = this.iSIN;
    data['schemeName'] = this.schemeName;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeNameNew;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
    data['RTA_Agent_Code'] = this.rTAAgentCode;
    data['AMC_Active_Flag'] = this.aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['STP_FLAG'] = this.sTPFLAG;
    data['SWP_Flag'] = this.sWPFlag;
    data['Switch_FLAG'] = this.switchFLAG;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['AMC_IND'] = this.aMCIND;
    data['Face_Value'] = this.faceValue;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Exit_Load'] = this.exitLoad;
    data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
    data['Lock_in_Period'] = this.lockInPeriod;
    data['Channel Partner_Code'] = this.channelPartnerCode;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['Name'] = this.name;
    data['AUM'] = this.aUM;
    data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
    data['Launch_Date'] = this.launchDate;
    data['Closure_Date'] = this.closureDate;
    data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
    data['f_scheme_name'] = this.fSchemeName;
    data['NAV_Scheme_Type'] = this.nAVSchemeType;
     data['isAdd'] = isAdd;
    return data;
  }
}



class StableDebt {
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aum;
  String? s1Day;
  String? s7Day;
  String? s15Day;
  String? s30Day;
  String? s3Month;
  String? s6Month;
  String? s1Year;
  String? s2Year;
  String? d3Year;
  String? d5Year;
  String? s10Year;
  String? s15Year;
  String? s20Year;
  String? s25Year;
  String? isRecommended;
  String? s1YearSIPReturn;
  String? s3YearSIPReturn;
  String? s5YearSIPReturn;
  String? s10YearSIPReturn;
  String? s15YearSIPReturn;
  String? s20YearSIPReturn;
  String? sinceInceptionReturn;
  String? iSIN;
  String? schemeName;
  String? type;
  String? subType;
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
 String? schemeNameNew;
  String? purchaseAllowed;
  String? purchaseTransactionMode;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? redemptionAllowed;
  String? redemptionTransactionMode;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? maximumRedemptionQty;
  String? redemptionAmountMinimum;
  String? redemptionAmountMaximum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? rTAAgentCode;
  String? aMCActiveFlag;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? switchFLAG;
  String? sETTLEMENTTYPE;
  String? aMCIND;
  String? faceValue;
  String? startDate;
  String? endDate;
  String? exitLoadFlag;
  String? exitLoad;
  String? lockInPeriodFlag;
  String? lockInPeriod;
  String? channelPartnerCode;
  String? reOpeningDate;
  String? name;
  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? launchDate;
  String? closureDate;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
  bool? isAdd;

  StableDebt(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aum,
      this.s1Day,
      this.s7Day,
      this.s15Day,
      this.s30Day,
      this.s3Month,
      this.s6Month,
      this.s1Year,
      this.s2Year,
      this.d3Year,
      this.d5Year,
      this.s10Year,
      this.s15Year,
      this.s20Year,
      this.s25Year,
      this.isRecommended,
      this.s1YearSIPReturn,
      this.s3YearSIPReturn,
      this.s5YearSIPReturn,
      this.s10YearSIPReturn,
      this.s15YearSIPReturn,
      this.s20YearSIPReturn,
      this.sinceInceptionReturn,
      this.iSIN,
      this.schemeName,
      this.type,
      this.subType,
      this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeNameNew,
      this.purchaseAllowed,
      this.purchaseTransactionMode,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.redemptionAllowed,
      this.redemptionTransactionMode,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.maximumRedemptionQty,
      this.redemptionAmountMinimum,
      this.redemptionAmountMaximum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.rTAAgentCode,
      this.aMCActiveFlag,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.switchFLAG,
      this.sETTLEMENTTYPE,
      this.aMCIND,
      this.faceValue,
      this.startDate,
      this.endDate,
      this.exitLoadFlag,
      this.exitLoad,
      this.lockInPeriodFlag,
      this.lockInPeriod,
      this.channelPartnerCode,
      this.reOpeningDate,
      this.name,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.nAVSchemeType,
      this.isAdd});

  StableDebt.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aum = json['aum'];
    s1Day = json['1Day'];
    s7Day = json['7Day'];
    s15Day = json['15Day'];
    s30Day = json['30Day'];
    s3Month = json['3Month'];
    s6Month = json['6Month'];
    s1Year = json['1Year'];
    s2Year = json['2Year'];
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    s10Year = json['10Year'];
    s15Year = json['15Year'];
    s20Year = json['20Year'];
    s25Year = json['25Year'];
    isRecommended = json['isRecommended'];
    s1YearSIPReturn = json['1YearSIPReturn'];
    s3YearSIPReturn = json['3YearSIPReturn'];
    s5YearSIPReturn = json['5YearSIPReturn'];
    s10YearSIPReturn = json['10YearSIPReturn'];
    s15YearSIPReturn = json['15YearSIPReturn'];
    s20YearSIPReturn = json['20YearSIPReturn'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
    iSIN = json['ISIN'];
    schemeName = json['schemeName'];
    type = json['Type'];
    subType = json['SubType'];
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemePlan = json['Scheme_Plan'];
    // schemeNameNew = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    purchaseTransactionMode = json['Purchase_Transaction_mode'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
    purchaseCutoffTime = json['Purchase_Cutoff_Time'];
    redemptionAllowed = json['Redemption_Allowed'];
    redemptionTransactionMode = json['Redemption_Transaction_Mode'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    maximumRedemptionQty = json['Maximum_Redemption_Qty'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
    redemptionCutOffTime = json['Redemption_Cut_off_Time'];
    rTAAgentCode = json['RTA_Agent_Code'];
    aMCActiveFlag = json['AMC_Active_Flag'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    sTPFLAG = json['STP_FLAG'];
    sWPFlag = json['SWP_Flag'];
    switchFLAG = json['Switch_FLAG'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    aMCIND = json['AMC_IND'];
    faceValue = json['Face_Value'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
    exitLoadFlag = json['Exit_Load_Flag'];
    exitLoad = json['Exit_Load'];
    lockInPeriodFlag = json['Lock_in_Period_Flag'];
    lockInPeriod = json['Lock_in_Period'];
    channelPartnerCode = json['Channel Partner_Code'];
    reOpeningDate = json['ReOpening_Date'];
    name = json['Name'];
    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['THREE_YEAR_DATA'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    isAdd = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schemeGroupName'] = this.schemeGroupName;
    data['fundName'] = this.fundName;
    data['category'] = this.category;
    data['aum'] = this.aum;
    data['1Day'] = this.s1Day;
    data['7Day'] = this.s7Day;
    data['15Day'] = this.s15Day;
    data['30Day'] = this.s30Day;
    data['3Month'] = this.s3Month;
    data['6Month'] = this.s6Month;
    data['1Year'] = this.s1Year;
    data['2Year'] = this.s2Year;
    data['3Year'] = this.d3Year;
    data['5Year'] = this.d5Year;
    data['10Year'] = this.s10Year;
    data['15Year'] = this.s15Year;
    data['20Year'] = this.s20Year;
    data['25Year'] = this.s25Year;
    data['isRecommended'] = this.isRecommended;
    data['1YearSIPReturn'] = this.s1YearSIPReturn;
    data['3YearSIPReturn'] = this.s3YearSIPReturn;
    data['5YearSIPReturn'] = this.s5YearSIPReturn;
    data['10YearSIPReturn'] = this.s10YearSIPReturn;
    data['15YearSIPReturn'] = this.s15YearSIPReturn;
    data['20YearSIPReturn'] = this.s20YearSIPReturn;
    data['sinceInceptionReturn'] = this.sinceInceptionReturn;
    data['ISIN'] = this.iSIN;
    data['schemeName'] = this.schemeName;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeNameNew;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
    data['RTA_Agent_Code'] = this.rTAAgentCode;
    data['AMC_Active_Flag'] = this.aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['STP_FLAG'] = this.sTPFLAG;
    data['SWP_Flag'] = this.sWPFlag;
    data['Switch_FLAG'] = this.switchFLAG;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['AMC_IND'] = this.aMCIND;
    data['Face_Value'] = this.faceValue;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Exit_Load'] = this.exitLoad;
    data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
    data['Lock_in_Period'] = this.lockInPeriod;
    data['Channel Partner_Code'] = this.channelPartnerCode;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['Name'] = this.name;
    data['AUM'] = this.aUM;
    data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
    data['Launch_Date'] = this.launchDate;
    data['Closure_Date'] = this.closureDate;
    data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
    data['f_scheme_name'] = this.fSchemeName;
    data['NAV_Scheme_Type'] = this.nAVSchemeType;
     data['isAdd'] = isAdd;
    return data;
  }
}


class SectoralThematic {
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aum;
  String? s1Day;
  String? s7Day;
  String? s15Day;
  String? s30Day;
  String? s3Month;
  String? s6Month;
  String? s1Year;
  String? s2Year;
  String? d3Year;
  String? d5Year;
  String? s10Year;
  String? s15Year;
  String? s20Year;
  String? s25Year;
  String? isRecommended;
  String? s1YearSIPReturn;
  String? s3YearSIPReturn;
  String? s5YearSIPReturn;
  String? s10YearSIPReturn;
  String? s15YearSIPReturn;
  String? s20YearSIPReturn;
  String? sinceInceptionReturn;
  String? iSIN;
  String? schemeName;
  String? type;
  String? subType;
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
 String? schemeNameNew;
  String? purchaseAllowed;
  String? purchaseTransactionMode;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? redemptionAllowed;
  String? redemptionTransactionMode;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? maximumRedemptionQty;
  String? redemptionAmountMinimum;
  String? redemptionAmountMaximum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? rTAAgentCode;
  String? aMCActiveFlag;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? switchFLAG;
  String? sETTLEMENTTYPE;
  String? aMCIND;
  String? faceValue;
  String? startDate;
  String? endDate;
  String? exitLoadFlag;
  String? exitLoad;
  String? lockInPeriodFlag;
  String? lockInPeriod;
  String? channelPartnerCode;
  String? reOpeningDate;
  String? name;
  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? launchDate;
  String? closureDate;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
  bool? isAdd;

  SectoralThematic(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aum,
      this.s1Day,
      this.s7Day,
      this.s15Day,
      this.s30Day,
      this.s3Month,
      this.s6Month,
      this.s1Year,
      this.s2Year,
      this.d3Year,
      this.d5Year,
      this.s10Year,
      this.s15Year,
      this.s20Year,
      this.s25Year,
      this.isRecommended,
      this.s1YearSIPReturn,
      this.s3YearSIPReturn,
      this.s5YearSIPReturn,
      this.s10YearSIPReturn,
      this.s15YearSIPReturn,
      this.s20YearSIPReturn,
      this.sinceInceptionReturn,
      this.iSIN,
      this.schemeName,
      this.type,
      this.subType,
      this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeNameNew,
      this.purchaseAllowed,
      this.purchaseTransactionMode,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.redemptionAllowed,
      this.redemptionTransactionMode,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.maximumRedemptionQty,
      this.redemptionAmountMinimum,
      this.redemptionAmountMaximum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.rTAAgentCode,
      this.aMCActiveFlag,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.switchFLAG,
      this.sETTLEMENTTYPE,
      this.aMCIND,
      this.faceValue,
      this.startDate,
      this.endDate,
      this.exitLoadFlag,
      this.exitLoad,
      this.lockInPeriodFlag,
      this.lockInPeriod,
      this.channelPartnerCode,
      this.reOpeningDate,
      this.name,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.nAVSchemeType,
      this.isAdd});

  SectoralThematic.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aum = json['aum'];
    s1Day = json['1Day'];
    s7Day = json['7Day'];
    s15Day = json['15Day'];
    s30Day = json['30Day'];
    s3Month = json['3Month'];
    s6Month = json['6Month'];
    s1Year = json['1Year'];
    s2Year = json['2Year'];
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    s10Year = json['10Year'];
    s15Year = json['15Year'];
    s20Year = json['20Year'];
    s25Year = json['25Year'];
    isRecommended = json['isRecommended'];
    s1YearSIPReturn = json['1YearSIPReturn'];
    s3YearSIPReturn = json['3YearSIPReturn'];
    s5YearSIPReturn = json['5YearSIPReturn'];
    s10YearSIPReturn = json['10YearSIPReturn'];
    s15YearSIPReturn = json['15YearSIPReturn'];
    s20YearSIPReturn = json['20YearSIPReturn'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
    iSIN = json['ISIN'];
    schemeName = json['schemeName'];
    type = json['Type'];
    subType = json['SubType'];
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemePlan = json['Scheme_Plan'];
    // schemeNameNew = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    purchaseTransactionMode = json['Purchase_Transaction_mode'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
    purchaseCutoffTime = json['Purchase_Cutoff_Time'];
    redemptionAllowed = json['Redemption_Allowed'];
    redemptionTransactionMode = json['Redemption_Transaction_Mode'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    maximumRedemptionQty = json['Maximum_Redemption_Qty'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
    redemptionCutOffTime = json['Redemption_Cut_off_Time'];
    rTAAgentCode = json['RTA_Agent_Code'];
    aMCActiveFlag = json['AMC_Active_Flag'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    sTPFLAG = json['STP_FLAG'];
    sWPFlag = json['SWP_Flag'];
    switchFLAG = json['Switch_FLAG'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    aMCIND = json['AMC_IND'];
    faceValue = json['Face_Value'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
    exitLoadFlag = json['Exit_Load_Flag'];
    exitLoad = json['Exit_Load'];
    lockInPeriodFlag = json['Lock_in_Period_Flag'];
    lockInPeriod = json['Lock_in_Period'];
    channelPartnerCode = json['Channel Partner_Code'];
    reOpeningDate = json['ReOpening_Date'];
    name = json['Name'];
    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['THREE_YEAR_DATA'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    isAdd = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schemeGroupName'] = this.schemeGroupName;
    data['fundName'] = this.fundName;
    data['category'] = this.category;
    data['aum'] = this.aum;
    data['1Day'] = this.s1Day;
    data['7Day'] = this.s7Day;
    data['15Day'] = this.s15Day;
    data['30Day'] = this.s30Day;
    data['3Month'] = this.s3Month;
    data['6Month'] = this.s6Month;
    data['1Year'] = this.s1Year;
    data['2Year'] = this.s2Year;
    data['3Year'] = this.d3Year;
    data['5Year'] = this.d5Year;
    data['10Year'] = this.s10Year;
    data['15Year'] = this.s15Year;
    data['20Year'] = this.s20Year;
    data['25Year'] = this.s25Year;
    data['isRecommended'] = this.isRecommended;
    data['1YearSIPReturn'] = this.s1YearSIPReturn;
    data['3YearSIPReturn'] = this.s3YearSIPReturn;
    data['5YearSIPReturn'] = this.s5YearSIPReturn;
    data['10YearSIPReturn'] = this.s10YearSIPReturn;
    data['15YearSIPReturn'] = this.s15YearSIPReturn;
    data['20YearSIPReturn'] = this.s20YearSIPReturn;
    data['sinceInceptionReturn'] = this.sinceInceptionReturn;
    data['ISIN'] = this.iSIN;
    data['schemeName'] = this.schemeName;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeNameNew;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
    data['RTA_Agent_Code'] = this.rTAAgentCode;
    data['AMC_Active_Flag'] = this.aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['STP_FLAG'] = this.sTPFLAG;
    data['SWP_Flag'] = this.sWPFlag;
    data['Switch_FLAG'] = this.switchFLAG;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['AMC_IND'] = this.aMCIND;
    data['Face_Value'] = this.faceValue;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Exit_Load'] = this.exitLoad;
    data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
    data['Lock_in_Period'] = this.lockInPeriod;
    data['Channel Partner_Code'] = this.channelPartnerCode;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['Name'] = this.name;
    data['AUM'] = this.aUM;
    data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
    data['Launch_Date'] = this.launchDate;
    data['Closure_Date'] = this.closureDate;
    data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
    data['f_scheme_name'] = this.fSchemeName;
    data['NAV_Scheme_Type'] = this.nAVSchemeType;
     data['isAdd'] = isAdd;
    return data;
  }
}


class InternationalExposure {
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aum;
  String? s1Day;
  String? s7Day;
  String? s15Day;
  String? s30Day;
  String? s3Month;
  String? s6Month;
  String? s1Year;
  String? s2Year;
  String? d3Year;
  String? d5Year;
  String? s10Year;
  String? s15Year;
  String? s20Year;
  String? s25Year;
  String? isRecommended;
  String? s1YearSIPReturn;
  String? s3YearSIPReturn;
  String? s5YearSIPReturn;
  String? s10YearSIPReturn;
  String? s15YearSIPReturn;
  String? s20YearSIPReturn;
  String? sinceInceptionReturn;
  String? iSIN;
  String? schemeName;
  String? type;
  String? subType;
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
 String? schemeNameNew;
  String? purchaseAllowed;
  String? purchaseTransactionMode;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? redemptionAllowed;
  String? redemptionTransactionMode;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? maximumRedemptionQty;
  String? redemptionAmountMinimum;
  String? redemptionAmountMaximum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? rTAAgentCode;
  String? aMCActiveFlag;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? switchFLAG;
  String? sETTLEMENTTYPE;
  String? aMCIND;
  String? faceValue;
  String? startDate;
  String? endDate;
  String? exitLoadFlag;
  String? exitLoad;
  String? lockInPeriodFlag;
  String? lockInPeriod;
  String? channelPartnerCode;
  String? reOpeningDate;
  String? name;
  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? launchDate;
  String? closureDate;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
    bool? isAdd;

  InternationalExposure(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aum,
      this.s1Day,
      this.s7Day,
      this.s15Day,
      this.s30Day,
      this.s3Month,
      this.s6Month,
      this.s1Year,
      this.s2Year,
      this.d3Year,
      this.d5Year,
      this.s10Year,
      this.s15Year,
      this.s20Year,
      this.s25Year,
      this.isRecommended,
      this.s1YearSIPReturn,
      this.s3YearSIPReturn,
      this.s5YearSIPReturn,
      this.s10YearSIPReturn,
      this.s15YearSIPReturn,
      this.s20YearSIPReturn,
      this.sinceInceptionReturn,
      this.iSIN,
      this.schemeName,
      this.type,
      this.subType,
      this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeNameNew,
      this.purchaseAllowed,
      this.purchaseTransactionMode,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.redemptionAllowed,
      this.redemptionTransactionMode,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.maximumRedemptionQty,
      this.redemptionAmountMinimum,
      this.redemptionAmountMaximum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.rTAAgentCode,
      this.aMCActiveFlag,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.switchFLAG,
      this.sETTLEMENTTYPE,
      this.aMCIND,
      this.faceValue,
      this.startDate,
      this.endDate,
      this.exitLoadFlag,
      this.exitLoad,
      this.lockInPeriodFlag,
      this.lockInPeriod,
      this.channelPartnerCode,
      this.reOpeningDate,
      this.name,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.nAVSchemeType,
      this.isAdd});

  InternationalExposure.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aum = json['aum'];
    s1Day = json['1Day'];
    s7Day = json['7Day'];
    s15Day = json['15Day'];
    s30Day = json['30Day'];
    s3Month = json['3Month'];
    s6Month = json['6Month'];
    s1Year = json['1Year'];
    s2Year = json['2Year'];
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    s10Year = json['10Year'];
    s15Year = json['15Year'];
    s20Year = json['20Year'];
    s25Year = json['25Year'];
    isRecommended = json['isRecommended'];
    s1YearSIPReturn = json['1YearSIPReturn'];
    s3YearSIPReturn = json['3YearSIPReturn'];
    s5YearSIPReturn = json['5YearSIPReturn'];
    s10YearSIPReturn = json['10YearSIPReturn'];
    s15YearSIPReturn = json['15YearSIPReturn'];
    s20YearSIPReturn = json['20YearSIPReturn'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
    iSIN = json['ISIN'];
    schemeName = json['schemeName'];
    type = json['Type'];
    subType = json['SubType'];
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemePlan = json['Scheme_Plan'];
    // schemeNameNew = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    purchaseTransactionMode = json['Purchase_Transaction_mode'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
    purchaseCutoffTime = json['Purchase_Cutoff_Time'];
    redemptionAllowed = json['Redemption_Allowed'];
    redemptionTransactionMode = json['Redemption_Transaction_Mode'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    maximumRedemptionQty = json['Maximum_Redemption_Qty'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
    redemptionCutOffTime = json['Redemption_Cut_off_Time'];
    rTAAgentCode = json['RTA_Agent_Code'];
    aMCActiveFlag = json['AMC_Active_Flag'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    sTPFLAG = json['STP_FLAG'];
    sWPFlag = json['SWP_Flag'];
    switchFLAG = json['Switch_FLAG'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    aMCIND = json['AMC_IND'];
    faceValue = json['Face_Value'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
    exitLoadFlag = json['Exit_Load_Flag'];
    exitLoad = json['Exit_Load'];
    lockInPeriodFlag = json['Lock_in_Period_Flag'];
    lockInPeriod = json['Lock_in_Period'];
    channelPartnerCode = json['Channel Partner_Code'];
    reOpeningDate = json['ReOpening_Date'];
    name = json['Name'];
    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['THREE_YEAR_DATA'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    isAdd = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schemeGroupName'] = this.schemeGroupName;
    data['fundName'] = this.fundName;
    data['category'] = this.category;
    data['aum'] = this.aum;
    data['1Day'] = this.s1Day;
    data['7Day'] = this.s7Day;
    data['15Day'] = this.s15Day;
    data['30Day'] = this.s30Day;
    data['3Month'] = this.s3Month;
    data['6Month'] = this.s6Month;
    data['1Year'] = this.s1Year;
    data['2Year'] = this.s2Year;
    data['3Year'] = this.d3Year;
    data['5Year'] = this.d5Year;
    data['10Year'] = this.s10Year;
    data['15Year'] = this.s15Year;
    data['20Year'] = this.s20Year;
    data['25Year'] = this.s25Year;
    data['isRecommended'] = this.isRecommended;
    data['1YearSIPReturn'] = this.s1YearSIPReturn;
    data['3YearSIPReturn'] = this.s3YearSIPReturn;
    data['5YearSIPReturn'] = this.s5YearSIPReturn;
    data['10YearSIPReturn'] = this.s10YearSIPReturn;
    data['15YearSIPReturn'] = this.s15YearSIPReturn;
    data['20YearSIPReturn'] = this.s20YearSIPReturn;
    data['sinceInceptionReturn'] = this.sinceInceptionReturn;
    data['ISIN'] = this.iSIN;
    data['schemeName'] = this.schemeName;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeNameNew;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
    data['RTA_Agent_Code'] = this.rTAAgentCode;
    data['AMC_Active_Flag'] = this.aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['STP_FLAG'] = this.sTPFLAG;
    data['SWP_Flag'] = this.sWPFlag;
    data['Switch_FLAG'] = this.switchFLAG;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['AMC_IND'] = this.aMCIND;
    data['Face_Value'] = this.faceValue;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Exit_Load'] = this.exitLoad;
    data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
    data['Lock_in_Period'] = this.lockInPeriod;
    data['Channel Partner_Code'] = this.channelPartnerCode;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['Name'] = this.name;
    data['AUM'] = this.aUM;
    data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
    data['Launch_Date'] = this.launchDate;
    data['Closure_Date'] = this.closureDate;
    data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
    data['f_scheme_name'] = this.fSchemeName;
    data['NAV_Scheme_Type'] = this.nAVSchemeType;
     data['isAdd'] = isAdd;
    return data;
  }
}

class BalancedHybrid {
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aum;
  String? s1Day;
  String? s7Day;
  String? s15Day;
  String? s30Day;
  String? s3Month;
  String? s6Month;
  String? s1Year;
  String? s2Year;
  String? d3Year;
  String? d5Year;
  String? s10Year;
  String? s15Year;
  String? s20Year;
  String? s25Year;
  String? isRecommended;
  String? s1YearSIPReturn;
  String? s3YearSIPReturn;
  String? s5YearSIPReturn;
  String? s10YearSIPReturn;
  String? s15YearSIPReturn;
  String? s20YearSIPReturn;
  String? sinceInceptionReturn;
  String? iSIN;
  String? schemeName;
  String? type;
  String? subType;
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
 String? schemeNameNew;
  String? purchaseAllowed;
  String? purchaseTransactionMode;
  String? minimumPurchaseAmount;
  String? additionalPurchaseAmount;
  String? maximumPurchaseAmount;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? redemptionAllowed;
  String? redemptionTransactionMode;
  String? minimumRedemptionQty;
  String? redemptionQtyMultiplier;
  String? maximumRedemptionQty;
  String? redemptionAmountMinimum;
  String? redemptionAmountMaximum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? rTAAgentCode;
  String? aMCActiveFlag;
  String? dividendReinvestmentFlag;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? switchFLAG;
  String? sETTLEMENTTYPE;
  String? aMCIND;
  String? faceValue;
  String? startDate;
  String? endDate;
  String? exitLoadFlag;
  String? exitLoad;
  String? lockInPeriodFlag;
  String? lockInPeriod;
  String? channelPartnerCode;
  String? reOpeningDate;
  String? name;
  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? launchDate;
  String? closureDate;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
    bool? isAdd;

  BalancedHybrid(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aum,
      this.s1Day,
      this.s7Day,
      this.s15Day,
      this.s30Day,
      this.s3Month,
      this.s6Month,
      this.s1Year,
      this.s2Year,
      this.d3Year,
      this.d5Year,
      this.s10Year,
      this.s15Year,
      this.s20Year,
      this.s25Year,
      this.isRecommended,
      this.s1YearSIPReturn,
      this.s3YearSIPReturn,
      this.s5YearSIPReturn,
      this.s10YearSIPReturn,
      this.s15YearSIPReturn,
      this.s20YearSIPReturn,
      this.sinceInceptionReturn,
      this.iSIN,
      this.schemeName,
      this.type,
      this.subType,
      this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeNameNew,
      this.purchaseAllowed,
      this.purchaseTransactionMode,
      this.minimumPurchaseAmount,
      this.additionalPurchaseAmount,
      this.maximumPurchaseAmount,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.redemptionAllowed,
      this.redemptionTransactionMode,
      this.minimumRedemptionQty,
      this.redemptionQtyMultiplier,
      this.maximumRedemptionQty,
      this.redemptionAmountMinimum,
      this.redemptionAmountMaximum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.rTAAgentCode,
      this.aMCActiveFlag,
      this.dividendReinvestmentFlag,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.switchFLAG,
      this.sETTLEMENTTYPE,
      this.aMCIND,
      this.faceValue,
      this.startDate,
      this.endDate,
      this.exitLoadFlag,
      this.exitLoad,
      this.lockInPeriodFlag,
      this.lockInPeriod,
      this.channelPartnerCode,
      this.reOpeningDate,
      this.name,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.nAVSchemeType,
      this.isAdd});

  BalancedHybrid.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aum = json['aum'];
    s1Day = json['1Day'];
    s7Day = json['7Day'];
    s15Day = json['15Day'];
    s30Day = json['30Day'];
    s3Month = json['3Month'];
    s6Month = json['6Month'];
    s1Year = json['1Year'];
    s2Year = json['2Year'];
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    s10Year = json['10Year'];
    s15Year = json['15Year'];
    s20Year = json['20Year'];
    s25Year = json['25Year'];
    isRecommended = json['isRecommended'];
    s1YearSIPReturn = json['1YearSIPReturn'];
    s3YearSIPReturn = json['3YearSIPReturn'];
    s5YearSIPReturn = json['5YearSIPReturn'];
    s10YearSIPReturn = json['10YearSIPReturn'];
    s15YearSIPReturn = json['15YearSIPReturn'];
    s20YearSIPReturn = json['20YearSIPReturn'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
    iSIN = json['ISIN'];
    schemeName = json['schemeName'];
    type = json['Type'];
    subType = json['SubType'];
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    aMCCode = json['AMC_Code'];
    schemeType = json['Scheme_Type'];
    schemePlan = json['Scheme_Plan'];
    // schemeNameNew = json['Scheme_Name'];
    purchaseAllowed = json['Purchase_Allowed'];
    purchaseTransactionMode = json['Purchase_Transaction_mode'];
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
    additionalPurchaseAmount = json['Additional_Purchase_Amount'];
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
    purchaseCutoffTime = json['Purchase_Cutoff_Time'];
    redemptionAllowed = json['Redemption_Allowed'];
    redemptionTransactionMode = json['Redemption_Transaction_Mode'];
    minimumRedemptionQty = json['Minimum_Redemption_Qty'];
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
    maximumRedemptionQty = json['Maximum_Redemption_Qty'];
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
    redemptionCutOffTime = json['Redemption_Cut_off_Time'];
    rTAAgentCode = json['RTA_Agent_Code'];
    aMCActiveFlag = json['AMC_Active_Flag'];
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
    sIPFLAG = json['SIP_FLAG'];
    sTPFLAG = json['STP_FLAG'];
    sWPFlag = json['SWP_Flag'];
    switchFLAG = json['Switch_FLAG'];
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
    aMCIND = json['AMC_IND'];
    faceValue = json['Face_Value'];
    startDate = json['Start_Date'];
    endDate = json['End_Date'];
    exitLoadFlag = json['Exit_Load_Flag'];
    exitLoad = json['Exit_Load'];
    lockInPeriodFlag = json['Lock_in_Period_Flag'];
    lockInPeriod = json['Lock_in_Period'];
    channelPartnerCode = json['Channel Partner_Code'];
    reOpeningDate = json['ReOpening_Date'];
    name = json['Name'];
    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['THREE_YEAR_DATA'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    isAdd = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schemeGroupName'] = this.schemeGroupName;
    data['fundName'] = this.fundName;
    data['category'] = this.category;
    data['aum'] = this.aum;
    data['1Day'] = this.s1Day;
    data['7Day'] = this.s7Day;
    data['15Day'] = this.s15Day;
    data['30Day'] = this.s30Day;
    data['3Month'] = this.s3Month;
    data['6Month'] = this.s6Month;
    data['1Year'] = this.s1Year;
    data['2Year'] = this.s2Year;
    data['3Year'] = this.d3Year;
    data['5Year'] = this.d5Year;
    data['10Year'] = this.s10Year;
    data['15Year'] = this.s15Year;
    data['20Year'] = this.s20Year;
    data['25Year'] = this.s25Year;
    data['isRecommended'] = this.isRecommended;
    data['1YearSIPReturn'] = this.s1YearSIPReturn;
    data['3YearSIPReturn'] = this.s3YearSIPReturn;
    data['5YearSIPReturn'] = this.s5YearSIPReturn;
    data['10YearSIPReturn'] = this.s10YearSIPReturn;
    data['15YearSIPReturn'] = this.s15YearSIPReturn;
    data['20YearSIPReturn'] = this.s20YearSIPReturn;
    data['sinceInceptionReturn'] = this.sinceInceptionReturn;
    data['ISIN'] = this.iSIN;
    data['schemeName'] = this.schemeName;
    data['Type'] = this.type;
    data['SubType'] = this.subType;
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeNameNew;
    data['Purchase_Allowed'] = this.purchaseAllowed;
    data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
    data['Redemption_Allowed'] = this.redemptionAllowed;
    data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
    data['RTA_Agent_Code'] = this.rTAAgentCode;
    data['AMC_Active_Flag'] = this.aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
    data['SIP_FLAG'] = this.sIPFLAG;
    data['STP_FLAG'] = this.sTPFLAG;
    data['SWP_Flag'] = this.sWPFlag;
    data['Switch_FLAG'] = this.switchFLAG;
    data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
    data['AMC_IND'] = this.aMCIND;
    data['Face_Value'] = this.faceValue;
    data['Start_Date'] = this.startDate;
    data['End_Date'] = this.endDate;
    data['Exit_Load_Flag'] = this.exitLoadFlag;
    data['Exit_Load'] = this.exitLoad;
    data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
    data['Lock_in_Period'] = this.lockInPeriod;
    data['Channel Partner_Code'] = this.channelPartnerCode;
    data['ReOpening_Date'] = this.reOpeningDate;
    data['Name'] = this.name;
    data['AUM'] = this.aUM;
    data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
    data['Launch_Date'] = this.launchDate;
    data['Closure_Date'] = this.closureDate;
    data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
    data['f_scheme_name'] = this.fSchemeName;
    data['NAV_Scheme_Type'] = this.nAVSchemeType;
     data['isAdd'] = isAdd;
    return data;
  }
}

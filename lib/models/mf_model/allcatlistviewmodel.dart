class final_list_model {
  List<Values>? values;

  final_list_model({this.values});

  final_list_model.fromJson(Map<String, dynamic> json) {
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values!.add(Values.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Values {
  String? schemeGroupName;
  String? fundName;
  String? category;
  String? aUM;
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
  // String? schemeName;
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
  String? aum;
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

  Values(
      {this.schemeGroupName,
      this.fundName,
      this.category,
      this.aUM,
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
      // this.schemeName,
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
      this.aum,
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
      this.nAVSchemeType});

  Values.fromJson(Map<String, dynamic> json) {
    schemeGroupName = json['schemeGroupName'];
    fundName = json['fundName'];
    category = json['category'];
    aUM = json['AUM'];
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
    schemeName = json['Scheme_Name'];
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
    aum = json['aum'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schemeGroupName'] = schemeGroupName;
    data['fundName'] = fundName;
    data['category'] = category;
    data['AUM'] = aUM;
    data['1Day'] = s1Day;
    data['7Day'] = s7Day;
    data['15Day'] = s15Day;
    data['30Day'] = s30Day;
    data['3Month'] = s3Month;
    data['6Month'] = s6Month;
    data['1Year'] = s1Year;
    data['2Year'] = s2Year;
    data['3Year'] = s3Year;
    data['5Year'] = s5Year;
    data['10Year'] = s10Year;
    data['15Year'] = s15Year;
    data['20Year'] = s20Year;
    data['25Year'] = s25Year;
    data['isRecommended'] = isRecommended;
    data['1YearSIPReturn'] = s1YearSIPReturn;
    data['3YearSIPReturn'] = s3YearSIPReturn;
    data['5YearSIPReturn'] = s5YearSIPReturn;
    data['10YearSIPReturn'] = s10YearSIPReturn;
    data['15YearSIPReturn'] = s15YearSIPReturn;
    data['20YearSIPReturn'] = s20YearSIPReturn;
    data['sinceInceptionReturn'] = sinceInceptionReturn;
    data['ISIN'] = iSIN;
    data['schemeName'] = schemeName;
    data['Type'] = type;
    data['SubType'] = subType;
    data['Unique_No'] = uniqueNo;
    data['Scheme_Code'] = schemeCode;
    data['RTA_Scheme_Code'] = rTASchemeCode;
    data['AMC_Scheme_Code'] = aMCSchemeCode;
    data['AMC_Code'] = aMCCode;
    data['Scheme_Type'] = schemeType;
    data['Scheme_Plan'] = schemePlan;
    data['Scheme_Name'] = schemeName;
    data['Purchase_Allowed'] = purchaseAllowed;
    data['Purchase_Transaction_mode'] = purchaseTransactionMode;
    data['Minimum_Purchase_Amount'] = minimumPurchaseAmount;
    data['Additional_Purchase_Amount'] = additionalPurchaseAmount;
    data['Maximum_Purchase_Amount'] = maximumPurchaseAmount;
    data['Purchase_Amount_Multiplier'] = purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = purchaseCutoffTime;
    data['Redemption_Allowed'] = redemptionAllowed;
    data['Redemption_Transaction_Mode'] = redemptionTransactionMode;
    data['Minimum_Redemption_Qty'] = minimumRedemptionQty;
    data['Redemption_Qty_Multiplier'] = redemptionQtyMultiplier;
    data['Maximum_Redemption_Qty'] = maximumRedemptionQty;
    data['Redemption_Amount_Minimum'] = redemptionAmountMinimum;
    data['Redemption_Amount_Maximum'] = redemptionAmountMaximum;
    data['Redemption_Amount_Multiple'] = redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = redemptionCutOffTime;
    data['RTA_Agent_Code'] = rTAAgentCode;
    data['AMC_Active_Flag'] = aMCActiveFlag;
    data['Dividend_Reinvestment_Flag'] = dividendReinvestmentFlag;
    data['SIP_FLAG'] = sIPFLAG;
    data['STP_FLAG'] = sTPFLAG;
    data['SWP_Flag'] = sWPFlag;
    data['Switch_FLAG'] = switchFLAG;
    data['SETTLEMENT_TYPE'] = sETTLEMENTTYPE;
    data['AMC_IND'] = aMCIND;
    data['Face_Value'] = faceValue;
    data['Start_Date'] = startDate;
    data['End_Date'] = endDate;
    data['Exit_Load_Flag'] = exitLoadFlag;
    data['Exit_Load'] = exitLoad;
    data['Lock_in_Period_Flag'] = lockInPeriodFlag;
    data['Lock_in_Period'] = lockInPeriod;
    data['Channel Partner_Code'] = channelPartnerCode;
    data['ReOpening_Date'] = reOpeningDate;
    data['Name'] = name;
    data['aum'] = aum;
    data['INTER_NET_EXPENSE_RATIO'] = iNTERNETEXPENSERATIO;
    data['THREE_YEAR_DATA'] = tHREEYEARDATA;
    data['FIVE_YEAR_DATA'] = fIVEYEARDATA;
    data['NET_SCHEME_CODE'] = nETSCHEMECODE;
    data['NET_ASSET_VALUE'] = nETASSETVALUE;
    data['Launch_Date'] = launchDate;
    data['Closure_Date'] = closureDate;
    data['SCHEME_CATEGORY'] = sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = sCHEMESUBCATEGORY;
    data['Scheme_Minimum_Amount'] = schemeMinimumAmount;
    data['f_scheme_name'] = fSchemeName;
    data['NAV_Scheme_Type'] = nAVSchemeType;
    return data;
  }
}

class SearchMFmodel {
  List<MfList>? data;

  SearchMFmodel({this.data});

  SearchMFmodel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MfList>[];
      json['data'].forEach((v) {
        data!.add(MfList.fromJson(v));
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

class MfList {
  String? aMCActiveFlag;
  String? aMCCode;
  String? aMCIND;
  String? aMCSchemeCode;
  String? aUM;
  String? additionalPurchaseAmount;
  String? channelPartnerCode;
  String? closureDate;
  String? dividendReinvestmentFlag;
  String? endDate;
  String? exitLoad;
  String? exitLoadFlag;
  String? fIVEYEARDATA;
  String? faceValue;
  String? iNTERNETEXPENSERATIO;
  String? iSIN;
  String? launchDate;
  String? lockInPeriod;
  String? lockInPeriodFlag;
  String? maximumPurchaseAmount;
  String? maximumRedemptionQty;
  String? minimumPurchaseAmount;
  String? minimumRedemptionQty;
  String? nAVSchemeType;
  String? nETASSETVALUE;
  String? nETSCHEMECODE;
  String? name;
  String? purchaseAllowed;
  String? purchaseAmountMultiplier;
  String? purchaseCutoffTime;
  String? purchaseTransactionMode;
  String? rTAAgentCode;
  String? rTASchemeCode;
  String? reOpeningDate;
  String? redemptionAllowed;
  String? redemptionAmountMaximum;
  String? redemptionAmountMinimum;
  String? redemptionAmountMultiple;
  String? redemptionCutOffTime;
  String? redemptionQtyMultiplier;
  String? redemptionTransactionMode;
  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? sETTLEMENTTYPE;
  String? sIPFLAG;
  String? sTPFLAG;
  String? sWPFlag;
  String? schemeCode;
  String? schemeMinimumAmount;
  String? schemeName;
  String? schemePlan;
  String? schemeType;
  String? startDate;
  String? switchFLAG;
  String? tHREEYEARDATA;
  String? uniqueNo;
  String? fSchemeName;
  String? sortKey;
  bool? isAdd;

  MfList(
      {this.aMCActiveFlag,
      this.aMCCode,
      this.aMCIND,
      this.aMCSchemeCode,
      this.aUM,
      this.additionalPurchaseAmount,
      this.channelPartnerCode,
      this.closureDate,
      this.dividendReinvestmentFlag,
      this.endDate,
      this.exitLoad,
      this.exitLoadFlag,
      this.fIVEYEARDATA,
      this.faceValue,
      this.iNTERNETEXPENSERATIO,
      this.iSIN,
      this.launchDate,
      this.lockInPeriod,
      this.lockInPeriodFlag,
      this.maximumPurchaseAmount,
      this.maximumRedemptionQty,
      this.minimumPurchaseAmount,
      this.minimumRedemptionQty,
      this.nAVSchemeType,
      this.nETASSETVALUE,
      this.nETSCHEMECODE,
      this.name,
      this.purchaseAllowed,
      this.purchaseAmountMultiplier,
      this.purchaseCutoffTime,
      this.purchaseTransactionMode,
      this.rTAAgentCode,
      this.rTASchemeCode,
      this.reOpeningDate,
      this.redemptionAllowed,
      this.redemptionAmountMaximum,
      this.redemptionAmountMinimum,
      this.redemptionAmountMultiple,
      this.redemptionCutOffTime,
      this.redemptionQtyMultiplier,
      this.redemptionTransactionMode,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.sETTLEMENTTYPE,
      this.sIPFLAG,
      this.sTPFLAG,
      this.sWPFlag,
      this.schemeCode,
      this.schemeMinimumAmount,
      this.schemeName,
      this.schemePlan,
      this.schemeType,
      this.startDate,
      this.switchFLAG,
      this.tHREEYEARDATA,
      this.uniqueNo,
      this.fSchemeName,
      this.sortKey,
      this.isAdd});

  MfList.fromJson(Map<String, dynamic> json) {
    aMCActiveFlag = json['AMC_Active_Flag'].toString();
    aMCCode = json['AMC_Code'].toString();
    aMCIND = json['AMC_IND'].toString();
    aMCSchemeCode = json['AMC_Scheme_Code'].toString();
    aUM = json['AUM'].toString();
    additionalPurchaseAmount = json['Additional_Purchase_Amount'].toString();
    channelPartnerCode = json['Channel Partner_Code'].toString();
    closureDate = json['Closure_Date'].toString();
    dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'].toString();
    endDate = json['End_Date'].toString();
    exitLoad = json['Exit_Load'].toString();
    exitLoadFlag = json['Exit_Load_Flag'].toString();
    fIVEYEARDATA = json['FIVE_YEAR_DATA'].toString();
    faceValue = json['Face_Value'].toString();
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'].toString();
    iSIN = json['ISIN'].toString();
    launchDate = json['Launch_Date'].toString();
    lockInPeriod = json['Lock_in_Period'].toString();
    lockInPeriodFlag = json['Lock_in_Period_Flag'].toString();
    maximumPurchaseAmount = json['Maximum_Purchase_Amount'].toString();
    maximumRedemptionQty = json['Maximum_Redemption_Qty'].toString();
    minimumPurchaseAmount = json['Minimum_Purchase_Amount'].toString();
    minimumRedemptionQty = json['Minimum_Redemption_Qty'].toString();
    nAVSchemeType = json['NAV_Scheme_Type'].toString();
    nETASSETVALUE = json['NET_ASSET_VALUE'].toString();
    nETSCHEMECODE = json['NET_SCHEME_CODE'].toString();
    name = json['Name'].toString();
    purchaseAllowed = json['Purchase_Allowed'].toString();
    purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'].toString();
    purchaseCutoffTime = json['Purchase_Cutoff_Time'].toString();
    purchaseTransactionMode = json['Purchase_Transaction_mode'].toString();
    rTAAgentCode = json['RTA_Agent_Code'].toString();
    rTASchemeCode = json['RTA_Scheme_Code'].toString();
    reOpeningDate = json['ReOpening_Date'].toString();
    redemptionAllowed = json['Redemption_Allowed'].toString();
    redemptionAmountMaximum = json['Redemption_Amount_Maximum'].toString();
    redemptionAmountMinimum = json['Redemption_Amount_Minimum'].toString();
    redemptionAmountMultiple = json['Redemption_Amount_Multiple'].toString();
    redemptionCutOffTime = json['Redemption_Cut_off_Time'].toString();
    redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'].toString();
    redemptionTransactionMode = json['Redemption_Transaction_Mode'].toString();
    sCHEMECATEGORY = json['SCHEME_CATEGORY'].toString();
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'].toString();
    sETTLEMENTTYPE = json['SETTLEMENT_TYPE'].toString();
    sIPFLAG = json['SIP_FLAG'].toString();
    sTPFLAG = json['STP_FLAG'].toString();
    sWPFlag = json['SWP_Flag'].toString();
    schemeCode = json['Scheme_Code'].toString();
    schemeMinimumAmount = json['Scheme_Minimum_Amount'].toString();
    schemeName = json['Scheme_Name'].toString();
    schemePlan = json['Scheme_Plan'].toString();
    schemeType = json['Scheme_Type'].toString();
    startDate = json['Start_Date'].toString();
    switchFLAG = json['Switch_FLAG'].toString();
    tHREEYEARDATA = json['THREE_YEAR_DATA'].toString();
    uniqueNo = json['Unique_No'].toString();
    fSchemeName = json['f_scheme_name'].toString();
    sortKey = json['sort_key'].toString();
    isAdd = json['isAdd'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AMC_Active_Flag'] = aMCActiveFlag;
    data['AMC_Code'] = aMCCode;
    data['AMC_IND'] = aMCIND;
    data['AMC_Scheme_Code'] = aMCSchemeCode;
    data['AUM'] = aUM;
    data['Additional_Purchase_Amount'] = additionalPurchaseAmount;
    data['Channel Partner_Code'] = channelPartnerCode;
    data['Closure_Date'] = closureDate;
    data['Dividend_Reinvestment_Flag'] = dividendReinvestmentFlag;
    data['End_Date'] = endDate;
    data['Exit_Load'] = exitLoad;
    data['Exit_Load_Flag'] = exitLoadFlag;
    data['FIVE_YEAR_DATA'] = fIVEYEARDATA;
    data['Face_Value'] = faceValue;
    data['INTER_NET_EXPENSE_RATIO'] = iNTERNETEXPENSERATIO;
    data['ISIN'] = iSIN;
    data['Launch_Date'] = launchDate;
    data['Lock_in_Period'] = lockInPeriod;
    data['Lock_in_Period_Flag'] = lockInPeriodFlag;
    data['Maximum_Purchase_Amount'] = maximumPurchaseAmount;
    data['Maximum_Redemption_Qty'] = maximumRedemptionQty;
    data['Minimum_Purchase_Amount'] = minimumPurchaseAmount;
    data['Minimum_Redemption_Qty'] = minimumRedemptionQty;
    data['NAV_Scheme_Type'] = nAVSchemeType;
    data['NET_ASSET_VALUE'] = nETASSETVALUE;
    data['NET_SCHEME_CODE'] = nETSCHEMECODE;
    data['Name'] = name;
    data['Purchase_Allowed'] = purchaseAllowed;
    data['Purchase_Amount_Multiplier'] = purchaseAmountMultiplier;
    data['Purchase_Cutoff_Time'] = purchaseCutoffTime;
    data['Purchase_Transaction_mode'] = purchaseTransactionMode;
    data['RTA_Agent_Code'] = rTAAgentCode;
    data['RTA_Scheme_Code'] = rTASchemeCode;
    data['ReOpening_Date'] = reOpeningDate;
    data['Redemption_Allowed'] = redemptionAllowed;
    data['Redemption_Amount_Maximum'] = redemptionAmountMaximum;
    data['Redemption_Amount_Minimum'] = redemptionAmountMinimum;
    data['Redemption_Amount_Multiple'] = redemptionAmountMultiple;
    data['Redemption_Cut_off_Time'] = redemptionCutOffTime;
    data['Redemption_Qty_Multiplier'] = redemptionQtyMultiplier;
    data['Redemption_Transaction_Mode'] = redemptionTransactionMode;
    data['SCHEME_CATEGORY'] = sCHEMECATEGORY;
    data['SCHEME_SUB_CATEGORY'] = sCHEMESUBCATEGORY;
    data['SETTLEMENT_TYPE'] = sETTLEMENTTYPE;
    data['SIP_FLAG'] = sIPFLAG;
    data['STP_FLAG'] = sTPFLAG;
    data['SWP_Flag'] = sWPFlag;
    data['Scheme_Code'] = schemeCode;
    data['Scheme_Minimum_Amount'] = schemeMinimumAmount;
    data['Scheme_Name'] = schemeName;
    data['Scheme_Plan'] = schemePlan;
    data['Scheme_Type'] = schemeType;
    data['Start_Date'] = startDate;
    data['Switch_FLAG'] = switchFLAG;
    data['THREE_YEAR_DATA'] = tHREEYEARDATA;
    data['Unique_No'] = uniqueNo;
    data['f_scheme_name'] = fSchemeName;
    data['sort_key'] = sortKey;
    data['isAdd'] = isAdd;
    return data;
  }
}

import 'mutual_fundmodel.dart';

class NFODataModel {
  List<MutualFundList>? nfoList;

  NFODataModel({this.nfoList});

  NFODataModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      nfoList = <MutualFundList>[];
      json['data'].forEach((v) {
        nfoList!.add(MutualFundList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (nfoList != null) {
      data['data'] = nfoList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class NFODataList {
//   String? aMCActiveFlag;
//   String? aMCCode;
//   String? aMCIND;
//   String? aMCSchemeCode;
//   String? aUM;
//   String? additionalPurchaseAmount;
//   String? channelPartnerCode;
//   String? closureDate;
//   String? dividendReinvestmentFlag;
//   String? endDate;
//   String? exitLoad;
//   String? exitLoadFlag;
//   String? fIVEYEARDATA;
//   String? faceValue;
//   String? growthType;
//   String? iNTERNETEXPENSERATIO;
//   String? iSIN;
//   String? launchDate;
//   String? lockInPeriod;
//   String? lockInPeriodFlag;
//   String? maximumPurchaseAmount;
//   String? maximumRedemptionQty;
//   String? minimumPurchaseAmount;
//   String? minimumRedemptionQty;
//   String? nAVSchemeType;
//   String? nETASSETVALUE;
//   String? nETSCHEMECODE;
//   String? name;
//   String? purchaseAllowed;
//   String? purchaseAmountMultiplier;
//   String? purchaseCutoffTime;
//   String? purchaseTransactionMode;
//   String? rTAAgentCode;
//   String? rTASchemeCode;
//   String? reOpeningDate;
//   String? redemptionAllowed;
//   String? redemptionAmountMaximum;
//   String? redemptionAmountMinimum;
//   String? redemptionAmountMultiple;
//   String? redemptionCutOffTime;
//   String? redemptionQtyMultiplier;
//   String? redemptionTransactionMode;
//   String? sCHEMECATEGORY;
//   String? sCHEMESUBCATEGORY;
//   String? sETTLEMENTTYPE;
//   String? sIPFLAG;
//   String? sTPFLAG;
//   String? sWPFlag;
//   String? schemeCode;
//   String? schemeMinimumAmount;
//   String? schemeName;
//   String? schemePlan;
//   String? schemeType;
//   String? startDate;
//   String? switchFLAG;
//   String? tHREEYEARDATA;
//   String? uniqueNo;
//   String? fSchemeName;

//   NFODataList(
//       {this.aMCActiveFlag,
//       this.aMCCode,
//       this.aMCIND,
//       this.aMCSchemeCode,
//       this.aUM,
//       this.additionalPurchaseAmount,
//       this.channelPartnerCode,
//       this.closureDate,
//       this.dividendReinvestmentFlag,
//       this.endDate,
//       this.exitLoad,
//       this.exitLoadFlag,
//       this.fIVEYEARDATA,
//       this.faceValue,
//       this.growthType,
//       this.iNTERNETEXPENSERATIO,
//       this.iSIN,
//       this.launchDate,
//       this.lockInPeriod,
//       this.lockInPeriodFlag,
//       this.maximumPurchaseAmount,
//       this.maximumRedemptionQty,
//       this.minimumPurchaseAmount,
//       this.minimumRedemptionQty,
//       this.nAVSchemeType,
//       this.nETASSETVALUE,
//       this.nETSCHEMECODE,
//       this.name,
//       this.purchaseAllowed,
//       this.purchaseAmountMultiplier,
//       this.purchaseCutoffTime,
//       this.purchaseTransactionMode,
//       this.rTAAgentCode,
//       this.rTASchemeCode,
//       this.reOpeningDate,
//       this.redemptionAllowed,
//       this.redemptionAmountMaximum,
//       this.redemptionAmountMinimum,
//       this.redemptionAmountMultiple,
//       this.redemptionCutOffTime,
//       this.redemptionQtyMultiplier,
//       this.redemptionTransactionMode,
//       this.sCHEMECATEGORY,
//       this.sCHEMESUBCATEGORY,
//       this.sETTLEMENTTYPE,
//       this.sIPFLAG,
//       this.sTPFLAG,
//       this.sWPFlag,
//       this.schemeCode,
//       this.schemeMinimumAmount,
//       this.schemeName,
//       this.schemePlan,
//       this.schemeType,
//       this.startDate,
//       this.switchFLAG,
//       this.tHREEYEARDATA,
//       this.uniqueNo,
//       this.fSchemeName});

//   NFODataList.fromJson(Map<String, dynamic> json) {
//     aMCActiveFlag = json['AMC_Active_Flag'];
//     aMCCode = json['AMC_Code'];
//     aMCIND = json['AMC_IND'];
//     aMCSchemeCode = json['AMC_Scheme_Code'];
//     aUM = json['AUM'];
//     additionalPurchaseAmount = json['Additional_Purchase_Amount'];
//     channelPartnerCode = json['Channel Partner_Code'];
//     closureDate = json['Closure_Date'];
//     dividendReinvestmentFlag = json['Dividend_Reinvestment_Flag'];
//     endDate = json['End_Date'];
//     exitLoad = json['Exit_Load'];
//     exitLoadFlag = json['Exit_Load_Flag'];
//     fIVEYEARDATA = json['FIVE_YEAR_DATA'];
//     faceValue = json['Face_Value'];
//     growthType = json['Growth_Type'];
//     iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
//     iSIN = json['ISIN'];
//     launchDate = json['Launch_Date'];
//     lockInPeriod = json['Lock_in_Period'];
//     lockInPeriodFlag = json['Lock_in_Period_Flag'];
//     maximumPurchaseAmount = json['Maximum_Purchase_Amount'];
//     maximumRedemptionQty = json['Maximum_Redemption_Qty'];
//     minimumPurchaseAmount = json['Minimum_Purchase_Amount'];
//     minimumRedemptionQty = json['Minimum_Redemption_Qty'];
//     nAVSchemeType = json['NAV_Scheme_Type'];
//     nETASSETVALUE = json['NET_ASSET_VALUE'];
//     nETSCHEMECODE = json['NET_SCHEME_CODE'];
//     name = json['Name'];
//     purchaseAllowed = json['Purchase_Allowed'];
//     purchaseAmountMultiplier = json['Purchase_Amount_Multiplier'];
//     purchaseCutoffTime = json['Purchase_Cutoff_Time'];
//     purchaseTransactionMode = json['Purchase_Transaction_mode'];
//     rTAAgentCode = json['RTA_Agent_Code'];
//     rTASchemeCode = json['RTA_Scheme_Code'];
//     reOpeningDate = json['ReOpening_Date'];
//     redemptionAllowed = json['Redemption_Allowed'];
//     redemptionAmountMaximum = json['Redemption_Amount_Maximum'];
//     redemptionAmountMinimum = json['Redemption_Amount_Minimum'];
//     redemptionAmountMultiple = json['Redemption_Amount_Multiple'];
//     redemptionCutOffTime = json['Redemption_Cut_off_Time'];
//     redemptionQtyMultiplier = json['Redemption_Qty_Multiplier'];
//     redemptionTransactionMode = json['Redemption_Transaction_Mode'];
//     sCHEMECATEGORY = json['SCHEME_CATEGORY'];
//     sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
//     sETTLEMENTTYPE = json['SETTLEMENT_TYPE'];
//     sIPFLAG = json['SIP_FLAG'];
//     sTPFLAG = json['STP_FLAG'];
//     sWPFlag = json['SWP_Flag'];
//     schemeCode = json['Scheme_Code'];
//     schemeMinimumAmount = json['Scheme_Minimum_Amount'];
//     schemeName = json['Scheme_Name'];
//     schemePlan = json['Scheme_Plan'];
//     schemeType = json['Scheme_Type'];
//     startDate = json['Start_Date'];
//     switchFLAG = json['Switch_FLAG'];
//     tHREEYEARDATA = json['THREE_YEAR_DATA'];
//     uniqueNo = json['Unique_No'];
//     fSchemeName = json['f_scheme_name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['AMC_Active_Flag'] = this.aMCActiveFlag;
//     data['AMC_Code'] = this.aMCCode;
//     data['AMC_IND'] = this.aMCIND;
//     data['AMC_Scheme_Code'] = this.aMCSchemeCode;
//     data['AUM'] = this.aUM;
//     data['Additional_Purchase_Amount'] = this.additionalPurchaseAmount;
//     data['Channel Partner_Code'] = this.channelPartnerCode;
//     data['Closure_Date'] = this.closureDate;
//     data['Dividend_Reinvestment_Flag'] = this.dividendReinvestmentFlag;
//     data['End_Date'] = this.endDate;
//     data['Exit_Load'] = this.exitLoad;
//     data['Exit_Load_Flag'] = this.exitLoadFlag;
//     data['FIVE_YEAR_DATA'] = this.fIVEYEARDATA;
//     data['Face_Value'] = this.faceValue;
//     data['Growth_Type'] = this.growthType;
//     data['INTER_NET_EXPENSE_RATIO'] = this.iNTERNETEXPENSERATIO;
//     data['ISIN'] = this.iSIN;
//     data['Launch_Date'] = this.launchDate;
//     data['Lock_in_Period'] = this.lockInPeriod;
//     data['Lock_in_Period_Flag'] = this.lockInPeriodFlag;
//     data['Maximum_Purchase_Amount'] = this.maximumPurchaseAmount;
//     data['Maximum_Redemption_Qty'] = this.maximumRedemptionQty;
//     data['Minimum_Purchase_Amount'] = this.minimumPurchaseAmount;
//     data['Minimum_Redemption_Qty'] = this.minimumRedemptionQty;
//     data['NAV_Scheme_Type'] = this.nAVSchemeType;
//     data['NET_ASSET_VALUE'] = this.nETASSETVALUE;
//     data['NET_SCHEME_CODE'] = this.nETSCHEMECODE;
//     data['Name'] = this.name;
//     data['Purchase_Allowed'] = this.purchaseAllowed;
//     data['Purchase_Amount_Multiplier'] = this.purchaseAmountMultiplier;
//     data['Purchase_Cutoff_Time'] = this.purchaseCutoffTime;
//     data['Purchase_Transaction_mode'] = this.purchaseTransactionMode;
//     data['RTA_Agent_Code'] = this.rTAAgentCode;
//     data['RTA_Scheme_Code'] = this.rTASchemeCode;
//     data['ReOpening_Date'] = this.reOpeningDate;
//     data['Redemption_Allowed'] = this.redemptionAllowed;
//     data['Redemption_Amount_Maximum'] = this.redemptionAmountMaximum;
//     data['Redemption_Amount_Minimum'] = this.redemptionAmountMinimum;
//     data['Redemption_Amount_Multiple'] = this.redemptionAmountMultiple;
//     data['Redemption_Cut_off_Time'] = this.redemptionCutOffTime;
//     data['Redemption_Qty_Multiplier'] = this.redemptionQtyMultiplier;
//     data['Redemption_Transaction_Mode'] = this.redemptionTransactionMode;
//     data['SCHEME_CATEGORY'] = this.sCHEMECATEGORY;
//     data['SCHEME_SUB_CATEGORY'] = this.sCHEMESUBCATEGORY;
//     data['SETTLEMENT_TYPE'] = this.sETTLEMENTTYPE;
//     data['SIP_FLAG'] = this.sIPFLAG;
//     data['STP_FLAG'] = this.sTPFLAG;
//     data['SWP_Flag'] = this.sWPFlag;
//     data['Scheme_Code'] = this.schemeCode;
//     data['Scheme_Minimum_Amount'] = this.schemeMinimumAmount;
//     data['Scheme_Name'] = this.schemeName;
//     data['Scheme_Plan'] = this.schemePlan;
//     data['Scheme_Type'] = this.schemeType;
//     data['Start_Date'] = this.startDate;
//     data['Switch_FLAG'] = this.switchFLAG;
//     data['THREE_YEAR_DATA'] = this.tHREEYEARDATA;
//     data['Unique_No'] = this.uniqueNo;
//     data['f_scheme_name'] = this.fSchemeName;
//     return data;
//   }
// }
import 'mutual_fundmodel.dart';

class MFWatchlistModel {
  String? msg;
  List<MutualFundList>? scripts;
  String? stat;

  MFWatchlistModel({this.msg, this.scripts, this.stat});

  MFWatchlistModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['scripts'] != null) {
      scripts = <MutualFundList>[];
      json['scripts'].forEach((v) {
        scripts!.add(MutualFundList.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (scripts != null) {
      data['scripts'] = scripts!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

// class Scripts {
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
//   String? createdDate;
//   String? fSchemeName;
//   String? splito;
//   String? splitr;
//   String? splitt;

//   Scripts(
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
//       this.createdDate,
//       this.fSchemeName,
//       this.splito,
//       this.splitr,
//       this.splitt});

//   Scripts.fromJson(Map<String, dynamic> json) {
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
//     createdDate = json['created_date'];
//     fSchemeName = json['f_scheme_name'];
//     splito = json['splito'];
//     splitr = json['splitr'];
//     splitt = json['splitt'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['AMC_Active_Flag'] = aMCActiveFlag;
//     data['AMC_Code'] = aMCCode;
//     data['AMC_IND'] = aMCIND;
//     data['AMC_Scheme_Code'] = aMCSchemeCode;
//     data['AUM'] = aUM;
//     data['Additional_Purchase_Amount'] = additionalPurchaseAmount;
//     data['Channel Partner_Code'] = channelPartnerCode;
//     data['Closure_Date'] = closureDate;
//     data['Dividend_Reinvestment_Flag'] = dividendReinvestmentFlag;
//     data['End_Date'] = endDate;
//     data['Exit_Load'] = exitLoad;
//     data['Exit_Load_Flag'] = exitLoadFlag;
//     data['FIVE_YEAR_DATA'] = fIVEYEARDATA;
//     data['Face_Value'] = faceValue;
//     data['INTER_NET_EXPENSE_RATIO'] = iNTERNETEXPENSERATIO;
//     data['ISIN'] = iSIN;
//     data['Launch_Date'] = launchDate;
//     data['Lock_in_Period'] = lockInPeriod;
//     data['Lock_in_Period_Flag'] = lockInPeriodFlag;
//     data['Maximum_Purchase_Amount'] = maximumPurchaseAmount;
//     data['Maximum_Redemption_Qty'] = maximumRedemptionQty;
//     data['Minimum_Purchase_Amount'] = minimumPurchaseAmount;
//     data['Minimum_Redemption_Qty'] = minimumRedemptionQty;
//     data['NAV_Scheme_Type'] = nAVSchemeType;
//     data['NET_ASSET_VALUE'] = nETASSETVALUE;
//     data['NET_SCHEME_CODE'] = nETSCHEMECODE;
//     data['Name'] = name;
//     data['Purchase_Allowed'] = purchaseAllowed;
//     data['Purchase_Amount_Multiplier'] = purchaseAmountMultiplier;
//     data['Purchase_Cutoff_Time'] = purchaseCutoffTime;
//     data['Purchase_Transaction_mode'] = purchaseTransactionMode;
//     data['RTA_Agent_Code'] = rTAAgentCode;
//     data['RTA_Scheme_Code'] = rTASchemeCode;
//     data['ReOpening_Date'] = reOpeningDate;
//     data['Redemption_Allowed'] = redemptionAllowed;
//     data['Redemption_Amount_Maximum'] = redemptionAmountMaximum;
//     data['Redemption_Amount_Minimum'] = redemptionAmountMinimum;
//     data['Redemption_Amount_Multiple'] = redemptionAmountMultiple;
//     data['Redemption_Cut_off_Time'] = redemptionCutOffTime;
//     data['Redemption_Qty_Multiplier'] = redemptionQtyMultiplier;
//     data['Redemption_Transaction_Mode'] = redemptionTransactionMode;
//     data['SCHEME_CATEGORY'] = sCHEMECATEGORY;
//     data['SCHEME_SUB_CATEGORY'] = sCHEMESUBCATEGORY;
//     data['SETTLEMENT_TYPE'] = sETTLEMENTTYPE;
//     data['SIP_FLAG'] = sIPFLAG;
//     data['STP_FLAG'] = sTPFLAG;
//     data['SWP_Flag'] = sWPFlag;
//     data['Scheme_Code'] = schemeCode;
//     data['Scheme_Minimum_Amount'] = schemeMinimumAmount;
//     data['Scheme_Name'] = schemeName;
//     data['Scheme_Plan'] = schemePlan;
//     data['Scheme_Type'] = schemeType;
//     data['Start_Date'] = startDate;
//     data['Switch_FLAG'] = switchFLAG;
//     data['THREE_YEAR_DATA'] = tHREEYEARDATA;
//     data['Unique_No'] = uniqueNo;
//     data['created_date'] = createdDate;
//     data['f_scheme_name'] = fSchemeName;
//     data['splito'] = splito;
//     data['splitr'] = splitr;
//     data['splitt'] = splitt;
//     return data;
//   }
// }

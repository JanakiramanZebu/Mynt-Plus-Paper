class NFODataModel {
  List<Data>? data;

  NFODataModel({this.data});

  NFODataModel.fromJson(Map<String, dynamic> json) {
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
  String? uniqueNo;
  String? schemeCode;
  String? rTASchemeCode;
  String? aMCSchemeCode;
  String? iSIN;
  String? aMCCode;
  String? schemeType;
  String? schemePlan;
  String? schemeName;
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

  Data(
      {this.uniqueNo,
      this.schemeCode,
      this.rTASchemeCode,
      this.aMCSchemeCode,
      this.iSIN,
      this.aMCCode,
      this.schemeType,
      this.schemePlan,
      this.schemeName,
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
      this.name});

  Data.fromJson(Map<String, dynamic> json) {
    uniqueNo = json['Unique_No'];
    schemeCode = json['Scheme_Code'];
    rTASchemeCode = json['RTA_Scheme_Code'];
    aMCSchemeCode = json['AMC_Scheme_Code'];
    iSIN = json['ISIN'];
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
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Unique_No'] = uniqueNo;
    data['Scheme_Code'] = schemeCode;
    data['RTA_Scheme_Code'] = rTASchemeCode;
    data['AMC_Scheme_Code'] = aMCSchemeCode;
    data['ISIN'] = iSIN;
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
    data['name'] = name;
    return data;
  }
}

class NFODataModel {
  List<Data>? data;

  NFODataModel({this.data});

  NFODataModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
      this.name,
      this.iDCWSchemeCode,
      this.iDCWL1SchemeCode,
      this.reinvSchemeCode,
      this.reinvL1SchemeCode,
      this.l1SchemeCode});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Unique_No'] = this.uniqueNo;
    data['Scheme_Code'] = this.schemeCode;
    data['RTA_Scheme_Code'] = this.rTASchemeCode;
    data['AMC_Scheme_Code'] = this.aMCSchemeCode;
    data['ISIN'] = this.iSIN;
    data['AMC_Code'] = this.aMCCode;
    data['Scheme_Type'] = this.schemeType;
    data['Scheme_Plan'] = this.schemePlan;
    data['Scheme_Name'] = this.schemeName;
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
    data['name'] = this.name;
    if (iDCWSchemeCode != null) {
      data['IDCW'] = {
        'Scheme_Code': iDCWSchemeCode,
        if (iDCWMinimumPurchaseAmount != null) 'Minimum_Purchase_Amount': iDCWMinimumPurchaseAmount,
        if (iDCWMaximumPurchaseAmount != null) 'Maximum_Purchase_Amount': iDCWMaximumPurchaseAmount,
      };
    }
    if (reinvSchemeCode != null) {
      data['Reinv'] = {
        'Scheme_Code': reinvSchemeCode,
        if (reinvMinimumPurchaseAmount != null) 'Minimum_Purchase_Amount': reinvMinimumPurchaseAmount,
        if (reinvMaximumPurchaseAmount != null) 'Maximum_Purchase_Amount': reinvMaximumPurchaseAmount,
      };
    }
    return data;
  }
}

class MutualFundModel {
  String? stat;
  List<MutualFundList>? mutualFundList;

  MutualFundModel({this.stat, this.mutualFundList});

  MutualFundModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['data'] != null) {
      mutualFundList = <MutualFundList>[];
      json['data'].forEach((v) {
        mutualFundList!.add(MutualFundList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (mutualFundList != null) {
      data['data'] = mutualFundList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MutualFundList {
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
  String? mfsearchnamename;

  String? aUM;
  String? iNTERNETEXPENSERATIO;
  String? tHREEYEARDATA;
  String? fIVEYEARDATA;
  String? oneYearData;
  String? nETSCHEMECODE;
  String? nETASSETVALUE;
  String? cUurentnav;
  String? launchDate;
  String? closureDate;
  String? fundname;

  String? sCHEMECATEGORY;
  String? sCHEMESUBCATEGORY;
  String? schemeMinimumAmount;
  String? fSchemeName;
  String? nAVSchemeType;
  String? type;
  String? subtype;
  String? corpos;
  bool? isAdd;
  String? schemegroupName;
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

  MutualFundList(
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
      this.mfsearchnamename,
      this.aUM,
      this.iNTERNETEXPENSERATIO,
      this.tHREEYEARDATA,
      this.fIVEYEARDATA,
      this.nETSCHEMECODE,
      this.nETASSETVALUE,
      this.cUurentnav,
      this.launchDate,
      this.closureDate,
      this.sCHEMECATEGORY,
      this.sCHEMESUBCATEGORY,
      this.schemeMinimumAmount,
      this.fSchemeName,
      this.type,
      this.subtype,
      this.corpos,
      this.nAVSchemeType,
      this.isAdd,
      this.schemegroupName,
      this.oneYearData,
      this.iDCWSchemeCode,
      this.iDCWL1SchemeCode,
      this.reinvSchemeCode,
      this.reinvL1SchemeCode,
      this.l1SchemeCode});

  MutualFundList.fromJson(Map<String, dynamic> json) {
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
    mfsearchnamename = json['name'];
    name = json['name'];

    aUM = json['AUM'];
    iNTERNETEXPENSERATIO = json['INTER_NET_EXPENSE_RATIO'];
    tHREEYEARDATA = json['3Year'];
    oneYearData = json['1Year'];
    fIVEYEARDATA = json['FIVE_YEAR_DATA'] ?? json['5Year'];
    nETSCHEMECODE = json['NET_SCHEME_CODE'];
    nETASSETVALUE = json['NET_ASSET_VALUE'] ?? json['currentNAV'];
    launchDate = json['Launch_Date'];
    closureDate = json['Closure_Date'];
    sCHEMECATEGORY = json['SCHEME_CATEGORY'];
    sCHEMESUBCATEGORY = json['SCHEME_SUB_CATEGORY'];
    schemeMinimumAmount = json['Scheme_Minimum_Amount'];
    fSchemeName = json['f_scheme_name'];
    nAVSchemeType = json['NAV_Scheme_Type'];
    schemegroupName = json['schemeGroupName'];
    fundname = json['fundname'];

    type = json['Type'];
    subtype = json['SubType'];
    corpos = json["corpus"];
    isAdd = json['isAdd'] ?? false;
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
    data['fundname'] = fundname;

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
    data['name'] = mfsearchnamename;

    data['AUM'] = aUM;
    data['INTER_NET_EXPENSE_RATIO'] = iNTERNETEXPENSERATIO;
    data['3Year'] = tHREEYEARDATA;
    data['1Year'] = oneYearData;
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
    data['schemeGroupName'] = schemegroupName;
    data['Type'] = type;
    data['SubType'] = subtype;
    data['corpus'] = corpos;
    data['isAdd'] = isAdd;
    if (iDCWSchemeCode != null) {
      data['IDCW'] = {
        'Scheme_Code': iDCWSchemeCode,
        'Minimum_Purchase_Amount': iDCWMinimumPurchaseAmount,
        'Additional_Purchase_Amount': iDCWAdditionalPurchaseAmount,
        'Maximum_Purchase_Amount': iDCWMaximumPurchaseAmount,
        if (iDCWL1SchemeCode != null)
          'L1': {
            'Scheme_Code': iDCWL1SchemeCode,
            'Minimum_Purchase_Amount': iDCWL1MinimumPurchaseAmount,
            'Maximum_Purchase_Amount': iDCWL1MaximumPurchaseAmount,
          },
      };
    }
    if (reinvSchemeCode != null) {
      data['Reinv'] = {
        'Scheme_Code': reinvSchemeCode,
        'Minimum_Purchase_Amount': reinvMinimumPurchaseAmount,
        'Additional_Purchase_Amount': reinvAdditionalPurchaseAmount,
        'Maximum_Purchase_Amount': reinvMaximumPurchaseAmount,
        if (reinvL1SchemeCode != null)
          'L1': {
            'Scheme_Code': reinvL1SchemeCode,
            'Minimum_Purchase_Amount': reinvL1MinimumPurchaseAmount,
            'Maximum_Purchase_Amount': reinvL1MaximumPurchaseAmount,
          },
      };
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

class MFCategory {
  String? name;
  String? length;

  MFCategory({this.name, this.length});

  MFCategory.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    length = json['length'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['length'] = length;
    return data;
  }
}

class MFSubCatgory {
  String? name;

  MFSubCatgory({
    this.name,
  });

  MFSubCatgory.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    return data;
  }
}

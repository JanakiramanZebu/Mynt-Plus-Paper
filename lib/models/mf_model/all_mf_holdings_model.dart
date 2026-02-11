class AllMfModel {
  List<Data>? data;
  Summary? summary;
  String? stat;

  AllMfModel({this.data, this.summary, this.stat});

  AllMfModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    summary =
        json['summary'] != null ? new Summary.fromJson(json['summary']) : null;
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.summary != null) {
      data['summary'] = this.summary!.toJson();
    }
    data['stat'] = this.stat;
    return data;
  }
}

class Data {
  String? cLIENTCODE;
  String? iSIN;
  String? sCRIPNAME;
  String? pLEDGEQTY;
  String? bENQTY;
  String? cOLQTY;
  String? nSOHQTY;
  String? sOHQTY;
  String? iNSHORT;
  String? oUTSHORT;
  String? nET;
  String? sCRIPVALUE;
  String? aMOUNT;
  String? aMOUNT1;
  String? bSESYMBOL;
  String? nSESYMBOL;
  String? cLIENTNAME;
  String? hAIRCUT;
  String? hCPRICE;
  String? hCAMOUNT;
  String? cLIENTTEXT;
  String? planType;
  String? sCRIPSYMBOL;
  String? investedValue;
  String? currentValue;
  String? curNav;
  String? avgNav;
  String? totalUnits;
  String? profitLoss;
  String? changeprofitLoss;

  Data(
      {this.cLIENTCODE,
      this.iSIN,
      this.sCRIPNAME,
      this.pLEDGEQTY,
      this.bENQTY,
      this.cOLQTY,
      this.nSOHQTY,
      this.sOHQTY,
      this.iNSHORT,
      this.oUTSHORT,
      this.nET,
      this.sCRIPVALUE,
      this.aMOUNT,
      this.aMOUNT1,
      this.bSESYMBOL,
      this.nSESYMBOL,
      this.cLIENTNAME,
      this.hAIRCUT,
      this.hCPRICE,
      this.hCAMOUNT,
      this.cLIENTTEXT,
      this.planType,
      this.sCRIPSYMBOL,
      this.investedValue,
      this.currentValue,
      this.curNav,
      this.avgNav,
      this.totalUnits,
      this.profitLoss,
      this.changeprofitLoss});

  Data.fromJson(Map<String, dynamic> json) {
    cLIENTCODE = json['CLIENTCODE'];
    iSIN = json['ISIN'];
    sCRIPNAME = json['SCRIP_NAME'];
    pLEDGEQTY = json['PLEDGE_QTY'];
    bENQTY = json['BENQTY'];
    cOLQTY = json['COLQTY'];
    nSOHQTY = json['NSOHQTY'];
    sOHQTY = json['SOHQTY'];
    iNSHORT = json['INSHORT'];
    oUTSHORT = json['OUTSHORT'];
    nET = json['NET'];
    sCRIPVALUE = json['SCRIP_VALUE'];
    aMOUNT = json['AMOUNT'];
    aMOUNT1 = json['AMOUNT1'];
    bSESYMBOL = json['BSE_SYMBOL'];
    nSESYMBOL = json['NSE_SYMBOL'];
    cLIENTNAME = json['CLIENT_NAME'];
    hAIRCUT = json['HAIRCUT'];
    hCPRICE = json['HC_PRICE'];
    hCAMOUNT = json['HC_AMOUNT'];
    cLIENTTEXT = json['CLIENTTEXT'];
    planType = json['PlanType'];
    sCRIPSYMBOL = json['SCRIP_SYMBOL'];
    investedValue = json['invested_value'].toString();
    currentValue = json['current_value'].toString();
    curNav = json['Cur_Nav'].toString();
    avgNav = json['avg_nav'].toString();
    totalUnits = json['total_units'].toString();
    profitLoss = json['profit_loss'].toString();
    changeprofitLoss = json['changeprofitLoss'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CLIENTCODE'] = this.cLIENTCODE;
    data['ISIN'] = this.iSIN;
    data['SCRIP_NAME'] = this.sCRIPNAME;
    data['PLEDGE_QTY'] = this.pLEDGEQTY;
    data['BENQTY'] = this.bENQTY;
    data['COLQTY'] = this.cOLQTY;
    data['NSOHQTY'] = this.nSOHQTY;
    data['SOHQTY'] = this.sOHQTY;
    data['INSHORT'] = this.iNSHORT;
    data['OUTSHORT'] = this.oUTSHORT;
    data['NET'] = this.nET;
    data['SCRIP_VALUE'] = this.sCRIPVALUE;
    data['AMOUNT'] = this.aMOUNT;
    data['AMOUNT1'] = this.aMOUNT1;
    data['BSE_SYMBOL'] = this.bSESYMBOL;
    data['NSE_SYMBOL'] = this.nSESYMBOL;
    data['CLIENT_NAME'] = this.cLIENTNAME;
    data['HAIRCUT'] = this.hAIRCUT;
    data['HC_PRICE'] = this.hCPRICE;
    data['HC_AMOUNT'] = this.hCAMOUNT;
    data['CLIENTTEXT'] = this.cLIENTTEXT;
    data['PlanType'] = this.planType;
    data['SCRIP_SYMBOL'] = this.sCRIPSYMBOL;
    data['invested_value'] = this.investedValue;
    data['current_value'] = this.currentValue;
    data['Cur_Nav'] = this.curNav;
    data['avg_nav'] = this.avgNav;
    data['total_units'] = this.totalUnits;
    data['profit_loss'] = this.profitLoss;
    data['changeprofitLoss'] = this.changeprofitLoss;
    return data;
  }
}

class Summary {
  String? invested;
  String? currentValue;
  String? absReturnValue;
  String? absReturnPercent;

  Summary(
      {this.invested,
      this.currentValue,
      this.absReturnValue,
      this.absReturnPercent});

  Summary.fromJson(Map<String, dynamic> json) {
    invested = json['invested'].toString();
    currentValue = json['current_value'].toString();
    absReturnValue = json['abs_return_value'].toString();
    absReturnPercent = json['abs_return_percent'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invested'] = this.invested;
    data['current_value'] = this.currentValue;
    data['abs_return_value'] = this.absReturnValue;
    data['abs_return_percent'] = this.absReturnPercent;
    return data;
  }
}

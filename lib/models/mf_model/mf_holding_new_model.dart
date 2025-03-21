class mf_holdoing_new {
  List<DataMod>? data;
  String? stat;
  String? msg;
  String? purchaseValue;
  String? currentValue;
  String? gainOrLoss;
  String? percentage;


  mf_holdoing_new({this.data, this.stat, this.msg,
   this.purchaseValue,
      this.currentValue,
      this.gainOrLoss,
      this.percentage
  });

  mf_holdoing_new.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DataMod>[];
      json['data'].forEach((v) {
        data!.add(new DataMod.fromJson(v));
      });
    }
    stat = json['stat'];
    msg = json['msg'];
    purchaseValue = json['purchase_value'];
    currentValue = json['current_value'];
    gainOrLoss = json['gain_or_loss'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = this.stat;
    data['msg'] = this.msg;
     data['purchase_value'] = this.purchaseValue;
    data['current_value'] = this.currentValue;
    data['gain_or_loss'] = this.gainOrLoss;
    data['percentage'] = this.percentage;
    return data;
  }
} 

class DataMod {
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
  String? mINIMUMREDEMPTIONQTY;
  String? sCHEMECODE;
  String? sCHEMEPLAN;
  String? sCHEMENAME;
  String? aMCCODE;
  String? avgQty;
  String? bought;
  String? buyPrice;

  DataMod(
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
      this.mINIMUMREDEMPTIONQTY,
      this.sCHEMECODE,
      this.sCHEMEPLAN,
      this.sCHEMENAME,
      this.aMCCODE,
      this.avgQty,
      this.bought,
      this.buyPrice});

  DataMod.fromJson(Map<String, dynamic> json) {
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
    mINIMUMREDEMPTIONQTY = json['MINIMUM_REDEMPTION_QTY'];
    sCHEMECODE = json['SCHEME_CODE'];
    sCHEMEPLAN = json['SCHEME_PLAN'];
    sCHEMENAME = json['SCHEME_NAME'];
    aMCCODE = json['AMC_CODE'];
    avgQty = json['avg_qty'];
    bought = json['bought'];
    buyPrice = json['buy_price'];
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
    data['MINIMUM_REDEMPTION_QTY'] = this.mINIMUMREDEMPTIONQTY;
    data['SCHEME_CODE'] = this.sCHEMECODE;
    data['SCHEME_PLAN'] = this.sCHEMEPLAN;
    data['SCHEME_NAME'] = this.sCHEMENAME;
    data['AMC_CODE'] = this.aMCCODE;
    data['avg_qty'] = this.avgQty;
    data['bought'] = this.bought;
    data['buy_price'] = this.buyPrice;
    return data;
  }
}

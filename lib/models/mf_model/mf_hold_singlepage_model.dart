class mf_holding_sig_det {
  Data? data;
  String? stat;

  mf_holding_sig_det({this.data, this.stat});

  mf_holding_sig_det.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['stat'] = this.stat;
    return data;
  }
}

class Data {
  String? aMCCODE;
  String? aMOUNT;
  String? aMOUNT1;
  String? aVGQTY;
  String? bENQTY;
  String? bOUGHT;
  String? bSESYMBOL;
  String? bUYPRICE;
  String? cLIENTCODE;
  String? cLIENTTEXT;
  String? cLIENTNAME;
  String? cOLQTY;
  String? clientId;
  String? description;
  String? exchange;
  String? hAIRCUT;
  String? hCAMOUNT;
  String? hCPRICE;
  String? iNSHORT;
  String? iSIN;
  String? mINIMUMREDEMPTIONQTY;
  String? nET;
  String? nSESYMBOL;
  String? nSOHQTY;
  String? oUTSHORT;
  String? pLEDGEQTY;
  String? pRICEPREMIUM;
  String? pURDATE;
  String? qUANTITY;
  String? rOWID;
  String? sCHEMECODE;
  String? sCHEMENAME;
  String? sCRIPNAME;
  String? sCRIPSYMBOL;
  String? sCRIPVALUE;
  String? sOHQTY;
  String? sell;

  Data(
      {this.aMCCODE,
      this.aMOUNT,
      this.aMOUNT1,
      this.aVGQTY,
      this.bENQTY,
      this.bOUGHT,
      this.bSESYMBOL,
      this.bUYPRICE,
      this.cLIENTCODE,
      this.cLIENTTEXT,
      this.cLIENTNAME,
      this.cOLQTY,
      this.clientId,
      this.description,
      this.exchange,
      this.hAIRCUT,
      this.hCAMOUNT,
      this.hCPRICE,
      this.iNSHORT,
      this.iSIN,
      this.mINIMUMREDEMPTIONQTY,
      this.nET,
      this.nSESYMBOL,
      this.nSOHQTY,
      this.oUTSHORT,
      this.pLEDGEQTY,
      this.pRICEPREMIUM,
      this.pURDATE,
      this.qUANTITY,
      this.rOWID,
      this.sCHEMECODE,
      this.sCHEMENAME,
      this.sCRIPNAME,
      this.sCRIPSYMBOL,
      this.sCRIPVALUE,
      this.sOHQTY,
      this.sell});

  Data.fromJson(Map<String, dynamic> json) {
    aMCCODE = json['AMC_CODE'];
    aMOUNT = json['AMOUNT'];
    aMOUNT1 = json['AMOUNT1'];
    aVGQTY = json['AVG_QTY'];
    bENQTY = json['BENQTY'];
    bOUGHT = json['BOUGHT'];
    bSESYMBOL = json['BSE_SYMBOL'];
    bUYPRICE = json['BUY_PRICE'];
    cLIENTCODE = json['CLIENTCODE'];
    cLIENTTEXT = json['CLIENTTEXT'];
    cLIENTNAME = json['CLIENT_NAME'];
    cOLQTY = json['COLQTY'];
    clientId = json['Client_id'];
    description = json['Description'];
    exchange = json['Exchange'];
    hAIRCUT = json['HAIRCUT'];
    hCAMOUNT = json['HC_AMOUNT'];
    hCPRICE = json['HC_PRICE'];
    iNSHORT = json['INSHORT'];
    iSIN = json['ISIN'];
    mINIMUMREDEMPTIONQTY = json['MINIMUM_REDEMPTION_QTY'];
    nET = json['NET'];
    nSESYMBOL = json['NSE_SYMBOL'];
    nSOHQTY = json['NSOHQTY'];
    oUTSHORT = json['OUTSHORT'];
    pLEDGEQTY = json['PLEDGE_QTY'];
    pRICEPREMIUM = json['PRICE_PREMIUM'];
    pURDATE = json['PUR_DATE'];
    qUANTITY = json['QUANTITY'];
    rOWID = json['ROW_ID'];
    sCHEMECODE = json['SCHEME_CODE'];
    sCHEMENAME = json['SCHEME_NAME'];
    sCRIPNAME = json['SCRIP_NAME'];
    sCRIPSYMBOL = json['SCRIP_SYMBOL'];
    sCRIPVALUE = json['SCRIP_VALUE'];
    sOHQTY = json['SOHQTY'];
    sell = json['Sell'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AMC_CODE'] = this.aMCCODE;
    data['AMOUNT'] = this.aMOUNT;
    data['AMOUNT1'] = this.aMOUNT1;
    data['AVG_QTY'] = this.aVGQTY;
    data['BENQTY'] = this.bENQTY;
    data['BOUGHT'] = this.bOUGHT;
    data['BSE_SYMBOL'] = this.bSESYMBOL;
    data['BUY_PRICE'] = this.bUYPRICE;
    data['CLIENTCODE'] = this.cLIENTCODE;
    data['CLIENTTEXT'] = this.cLIENTTEXT;
    data['CLIENT_NAME'] = this.cLIENTNAME;
    data['COLQTY'] = this.cOLQTY;
    data['Client_id'] = this.clientId;
    data['Description'] = this.description;
    data['Exchange'] = this.exchange;
    data['HAIRCUT'] = this.hAIRCUT;
    data['HC_AMOUNT'] = this.hCAMOUNT;
    data['HC_PRICE'] = this.hCPRICE;
    data['INSHORT'] = this.iNSHORT;
    data['ISIN'] = this.iSIN;
    data['MINIMUM_REDEMPTION_QTY'] = this.mINIMUMREDEMPTIONQTY;
    data['NET'] = this.nET;
    data['NSE_SYMBOL'] = this.nSESYMBOL;
    data['NSOHQTY'] = this.nSOHQTY;
    data['OUTSHORT'] = this.oUTSHORT;
    data['PLEDGE_QTY'] = this.pLEDGEQTY;
    data['PRICE_PREMIUM'] = this.pRICEPREMIUM;
    data['PUR_DATE'] = this.pURDATE;
    data['QUANTITY'] = this.qUANTITY;
    data['ROW_ID'] = this.rOWID;
    data['SCHEME_CODE'] = this.sCHEMECODE;
    data['SCHEME_NAME'] = this.sCHEMENAME;
    data['SCRIP_NAME'] = this.sCRIPNAME;
    data['SCRIP_SYMBOL'] = this.sCRIPSYMBOL;
    data['SCRIP_VALUE'] = this.sCRIPVALUE;
    data['SOHQTY'] = this.sOHQTY;
    data['Sell'] = this.sell;
    return data;
  }
}

class TaxPnlEqModel {
  Data? data;

  TaxPnlEqModel({this.data});

  TaxPnlEqModel.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null ? Data.fromJson(json['data']['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? assetsTotal;
  String? longtermTotal;
  String? shortermTotal;
  String? tradingTotal;
  String? tradingTurnover;
  Map<String, dynamic>? details;
  List<ASSETS>? aSSETS;
  List<LIABILITIES>? lIABILITIES;
  List<SHORTTERM>? sHORTTERM;
  List<TRADING>? tRADING;

  Data({
    this.aSSETS,
    this.lIABILITIES,
    this.sHORTTERM,
    this.tRADING,
    this.assetsTotal,
    this.longtermTotal,
    this.shortermTotal,
    this.tradingTotal,
    this.tradingTurnover,
    this.details,
  });

  Data.fromJson(Map<String, dynamic> json) {

     assetsTotal = json['Assets_Total']?.toString();
    longtermTotal = json['longterm_Total']?.toString();
    shortermTotal = json['shorterm_Total']?.toString();
    tradingTotal = json['trading_Total']?.toString();
    tradingTurnover = json['trading_Turnover']?.toString();
    if (json['details'] != null && json['details'] is Map) {
      details = Map<String, dynamic>.from(json['details']);
    }


    print("json data ${ double.parse(tradingTurnover!) + double.parse(tradingTotal!)}");

    if (json['ASSETS'] != null) {
      aSSETS = <ASSETS>[];
      json['ASSETS'].forEach((v) {
        aSSETS!.add(ASSETS.fromJson(v));
      });
    }
    if (json['LIABILITIES'] != null) {
      lIABILITIES = <LIABILITIES>[];
      json['LIABILITIES'].forEach((v) {
        lIABILITIES!.add(LIABILITIES.fromJson(v));
      });
    }
    if (json['SHORTTERM'] != null) {
      sHORTTERM = <SHORTTERM>[];
      json['SHORTTERM'].forEach((v) {
        sHORTTERM!.add(SHORTTERM.fromJson(v));
      });
    }
    if (json['TRADING'] != null) {
      tRADING = <TRADING>[];
      json['TRADING'].forEach((v) {
        tRADING!.add(TRADING.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {

    
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Assets_Total'] = assetsTotal ;
    data['longterm_Total'] = longtermTotal ;
    data['shorterm_Total'] = shortermTotal ;
    data['trading_Total'] = tradingTotal ;
    data['trading_Turnover'] = tradingTurnover ;
    if (details != null) {
      data['details'] = details;
    }
    if (aSSETS != null) {
      
      data['ASSETS'] = aSSETS!.map((v) => v.toJson()).toList();
    }
    if (lIABILITIES != null) {
      data['LIABILITIES'] = lIABILITIES!.map((v) => v.toJson()).toList();
    }
    if (sHORTTERM != null) {
      data['SHORTTERM'] = sHORTTERM!.map((v) => v.toJson()).toList();
    }
    if (tRADING != null) {
      data['TRADING'] = tRADING!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ASSETS {
  String? tRTYPE1;
  String? tRNO;
  String? tRTYPE;
  String? cLIENTID;
  String? cLIENTNAME;
  String? sCRIPSYMBOL;
  String? bUYQTY;
  String? bUYRATE;
  String? bUYAMT;
  String? sALEQTY;
  String? sALEAMT;
  String? sALERATE;
  String? nETQTY;
  String? nETRATE;
  String? nETAMOUNT;
  String? cURRAMOUNT;
  String? pLAMT;
  String? closingPrice;
  String? priceDate;
  String? sCRIPNAME;
  String? lONGTERM;
  String? sHORTTERM;
  String? sPECULATION;
  String? sCRIPNAMEDATA;
  String? pANNO;
  String? aDDR1;
  String? aDDR2;
  String? aDDR3;
  String? aDDR4;
  String? aDDR5;
  String? iSIN;
  String? lTCGRATE;
  String? pRICERATE;
  String? per;
  String? sCRIPNAMEROWDATA;
  String? nOTIONALNET;

  ASSETS(
      {this.tRTYPE1,
      this.tRNO,
      this.tRTYPE,
      this.cLIENTID,
      this.cLIENTNAME,
      this.sCRIPSYMBOL,
      this.bUYQTY,
      this.bUYRATE,
      this.bUYAMT,
      this.sALEQTY,
      this.sALEAMT,
      this.sALERATE,
      this.nETQTY,
      this.nETRATE,
      this.nETAMOUNT,
      this.cURRAMOUNT,
      this.pLAMT,
      this.closingPrice,
      this.priceDate,
      this.sCRIPNAME,
      this.lONGTERM,
      this.sHORTTERM,
      this.sPECULATION,
      this.sCRIPNAMEDATA,
      this.pANNO,
      this.aDDR1,
      this.aDDR2,
      this.aDDR3,
      this.aDDR4,
      this.aDDR5,
      this.iSIN,
      this.lTCGRATE,
      this.pRICERATE,
      this.per,
      this.sCRIPNAMEROWDATA,
      this.nOTIONALNET});

  ASSETS.fromJson(Map<String, dynamic> json) {
    tRTYPE1 = json['TR_TYPE1'].toString();
    tRNO = json['TR_NO'].toString();
    tRTYPE = json['TR_TYPE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
    cLIENTNAME = json['CLIENT_NAME'].toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
    bUYQTY = json['BUY_QTY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    bUYAMT = json['BUY_AMT'].toString();
    sALEQTY = json['SALE_QTY'].toString();
    sALEAMT = json['SALE_AMT'].toString();
    sALERATE = json['SALE_RATE'].toString();
    nETQTY = json['NET_QTY'].toString();
    nETRATE = json['NET_RATE'].toString();
    nETAMOUNT = json['NET_AMOUNT'].toString();
    cURRAMOUNT = json['CURR_AMOUNT'].toString();
    pLAMT = json['PL_AMT'].toString();
    closingPrice = json['Closing_Price'].toString();
    priceDate = json['PriceDate'].toString();
    sCRIPNAME = json['SCRIP_NAME'].toString();
    lONGTERM = json['LONG_TERM'].toString();
    sHORTTERM = json['SHORT_TERM'].toString();
    sPECULATION = json['SPECULATION'].toString();
    sCRIPNAMEDATA = json['SCRIP_NAMEDATA'].toString();
    pANNO = json['PAN_NO'].toString();
    aDDR1 = json['ADDR1'].toString();
    aDDR2 = json['ADDR2'].toString();
    aDDR3 = json['ADDR3'].toString();
    aDDR4 = json['ADDR4'].toString();
    aDDR5 = json['ADDR5'].toString();
    iSIN = json['ISIN'].toString();
    lTCGRATE = json['LTCG_RATE'].toString();
    pRICERATE = json['PRICE_RATE'].toString();
    per = json['Per'].toString();
    sCRIPNAMEROWDATA = json['SCRIP_NAME_ROWDATA'].toString();
    nOTIONALNET = json['NOTIONAL_NET'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TR_TYPE1'] = tRTYPE1;
    data['TR_NO'] = tRNO;
    data['TR_TYPE'] = tRTYPE;
    data['CLIENT_ID'] = cLIENTID;
    data['CLIENT_NAME'] = cLIENTNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['BUY_QTY'] = bUYQTY;
    data['BUY_RATE'] = bUYRATE;
    data['BUY_AMT'] = bUYAMT;
    data['SALE_QTY'] = sALEQTY;
    data['SALE_AMT'] = sALEAMT;
    data['SALE_RATE'] = sALERATE;
    data['NET_QTY'] = nETQTY;
    data['NET_RATE'] = nETRATE;
    data['NET_AMOUNT'] = nETAMOUNT;
    data['CURR_AMOUNT'] = cURRAMOUNT;
    data['PL_AMT'] = pLAMT;
    data['Closing_Price'] = closingPrice;
    data['PriceDate'] = priceDate;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['LONG_TERM'] = lONGTERM;
    data['SHORT_TERM'] = sHORTTERM;
    data['SPECULATION'] = sPECULATION;
    data['SCRIP_NAMEDATA'] = sCRIPNAMEDATA;
    data['PAN_NO'] = pANNO;
    data['ADDR1'] = aDDR1;
    data['ADDR2'] = aDDR2;
    data['ADDR3'] = aDDR3;
    data['ADDR4'] = aDDR4;
    data['ADDR5'] = aDDR5;
    data['ISIN'] = iSIN;
    data['LTCG_RATE'] = lTCGRATE;
    data['PRICE_RATE'] = pRICERATE;
    data['Per'] = per;
    data['SCRIP_NAME_ROWDATA'] = sCRIPNAMEROWDATA;
    data['NOTIONAL_NET'] = nOTIONALNET;
    return data;
  }
}

class LIABILITIES {
  String? tRTYPE1;
  String? tRNO;
  String? tRTYPE;
  String? cLIENTID;
  String? cLIENTNAME;
  String? sCRIPSYMBOL;
  String? bUYQTY;
  String? bUYRATE;
  String? bUYAMT;
  String? sALEQTY;
  String? sALEAMT;
  String? sALERATE;
  String? nETQTY;
  String? nETRATE;
  String? nETAMOUNT;
  String? cURRAMOUNT;
  String? pLAMT;
  String? closingPrice;
  String? priceDate;
  String? sCRIPNAME;
  String? lONGTERM;
  String? sHORTTERM;
  String? sPECULATION;
  String? sCRIPNAMEDATA;
  String? pANNO;
  String? aDDR1;
  String? aDDR2;
  String? aDDR3;
  String? aDDR4;
  String? aDDR5;
  String? iSIN;
  String? lTCGRATE;
  String? pRICERATE;
  String? per;
  String? sCRIPNAMEROWDATA;
  String? nOTIONALNET;

  LIABILITIES(
      {this.tRTYPE1,
      this.tRNO,
      this.tRTYPE,
      this.cLIENTID,
      this.cLIENTNAME,
      this.sCRIPSYMBOL,
      this.bUYQTY,
      this.bUYRATE,
      this.bUYAMT,
      this.sALEQTY,
      this.sALEAMT,
      this.sALERATE,
      this.nETQTY,
      this.nETRATE,
      this.nETAMOUNT,
      this.cURRAMOUNT,
      this.pLAMT,
      this.closingPrice,
      this.priceDate,
      this.sCRIPNAME,
      this.lONGTERM,
      this.sHORTTERM,
      this.sPECULATION,
      this.sCRIPNAMEDATA,
      this.pANNO,
      this.aDDR1,
      this.aDDR2,
      this.aDDR3,
      this.aDDR4,
      this.aDDR5,
      this.iSIN,
      this.lTCGRATE,
      this.pRICERATE,
      this.per,
      this.sCRIPNAMEROWDATA,
      this.nOTIONALNET});

  LIABILITIES.fromJson(Map<String, dynamic> json) {
    tRTYPE1 = json['TR_TYPE1'].toString();
    tRNO = json['TR_NO'].toString();
    tRTYPE = json['TR_TYPE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
    cLIENTNAME = json['CLIENT_NAME'].toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
    bUYQTY = json['BUY_QTY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    bUYAMT = json['BUY_AMT'].toString();
    sALEQTY = json['SALE_QTY'].toString();
    sALEAMT = json['SALE_AMT'].toString();
    sALERATE = json['SALE_RATE'].toString();
    nETQTY = json['NET_QTY'].toString();
    nETRATE = json['NET_RATE'].toString();
    nETAMOUNT = json['NET_AMOUNT'].toString();
    cURRAMOUNT = json['CURR_AMOUNT'].toString();
    pLAMT = json['PL_AMT'].toString();
    closingPrice = json['Closing_Price'].toString();
    priceDate = json['PriceDate'].toString();
    sCRIPNAME = json['SCRIP_NAME'].toString();
    lONGTERM = json['LONG_TERM'].toString();
    sHORTTERM = json['SHORT_TERM'].toString();
    sPECULATION = json['SPECULATION'].toString();
    sCRIPNAMEDATA = json['SCRIP_NAMEDATA'].toString();
    pANNO = json['PAN_NO'].toString();
    aDDR1 = json['ADDR1'].toString();
    aDDR2 = json['ADDR2'].toString();
    aDDR3 = json['ADDR3'].toString();
    aDDR4 = json['ADDR4'].toString();
    aDDR5 = json['ADDR5'].toString();
    iSIN = json['ISIN'].toString();
    lTCGRATE = json['LTCG_RATE'].toString();
    pRICERATE = json['PRICE_RATE'].toString();
    per = json['Per'].toString();
    sCRIPNAMEROWDATA = json['SCRIP_NAME_ROWDATA'].toString();
    nOTIONALNET = json['NOTIONAL_NET'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TR_TYPE1'] = tRTYPE1;
    data['TR_NO'] = tRNO;
    data['TR_TYPE'] = tRTYPE;
    data['CLIENT_ID'] = cLIENTID;
    data['CLIENT_NAME'] = cLIENTNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['BUY_QTY'] = bUYQTY;
    data['BUY_RATE'] = bUYRATE;
    data['BUY_AMT'] = bUYAMT;
    data['SALE_QTY'] = sALEQTY;
    data['SALE_AMT'] = sALEAMT;
    data['SALE_RATE'] = sALERATE;
    data['NET_QTY'] = nETQTY;
    data['NET_RATE'] = nETRATE;
    data['NET_AMOUNT'] = nETAMOUNT;
    data['CURR_AMOUNT'] = cURRAMOUNT;
    data['PL_AMT'] = pLAMT;
    data['Closing_Price'] = closingPrice;
    data['PriceDate'] = priceDate;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['LONG_TERM'] = lONGTERM;
    data['SHORT_TERM'] = sHORTTERM;
    data['SPECULATION'] = sPECULATION;
    data['SCRIP_NAMEDATA'] = sCRIPNAMEDATA;
    data['PAN_NO'] = pANNO;
    data['ADDR1'] = aDDR1;
    data['ADDR2'] = aDDR2;
    data['ADDR3'] = aDDR3;
    data['ADDR4'] = aDDR4;
    data['ADDR5'] = aDDR5;
    data['ISIN'] = iSIN;
    data['LTCG_RATE'] = lTCGRATE;
    data['PRICE_RATE'] = pRICERATE;
    data['Per'] = per;
    data['SCRIP_NAME_ROWDATA'] = sCRIPNAMEROWDATA;
    data['NOTIONAL_NET'] = nOTIONALNET;
    return data;
  }
}

class SHORTTERM {
  String? tRTYPE1;
  String? tRNO;
  String? tRTYPE;
  String? cLIENTID;
  String? cLIENTNAME;
  String? sCRIPSYMBOL;
  String? bUYQTY;
  String? bUYRATE;
  String? bUYAMT;
  String? sALEQTY;
  String? sALEAMT;
  String? sALERATE;
  String? nETQTY;
  String? nETRATE;
  String? nETAMOUNT;
  String? cURRAMOUNT;
  String? pLAMT;
  String? closingPrice;
  String? priceDate;
  String? sCRIPNAME;
  String? lONGTERM;
  String? sHORTTERM;
  String? sPECULATION;
  String? sCRIPNAMEDATA;
  String? pANNO;
  String? aDDR1;
  String? aDDR2;
  String? aDDR3;
  String? aDDR4;
  String? aDDR5;
  String? iSIN;
  String? lTCGRATE;
  String? pRICERATE;
  String? per;
  String? sCRIPNAMEROWDATA;
  String? nOTIONALNET;

  SHORTTERM(
      {this.tRTYPE1,
      this.tRNO,
      this.tRTYPE,
      this.cLIENTID,
      this.cLIENTNAME,
      this.sCRIPSYMBOL,
      this.bUYQTY,
      this.bUYRATE,
      this.bUYAMT,
      this.sALEQTY,
      this.sALEAMT,
      this.sALERATE,
      this.nETQTY,
      this.nETRATE,
      this.nETAMOUNT,
      this.cURRAMOUNT,
      this.pLAMT,
      this.closingPrice,
      this.priceDate,
      this.sCRIPNAME,
      this.lONGTERM,
      this.sHORTTERM,
      this.sPECULATION,
      this.sCRIPNAMEDATA,
      this.pANNO,
      this.aDDR1,
      this.aDDR2,
      this.aDDR3,
      this.aDDR4,
      this.aDDR5,
      this.iSIN,
      this.lTCGRATE,
      this.pRICERATE,
      this.per,
      this.sCRIPNAMEROWDATA,
      this.nOTIONALNET});

  SHORTTERM.fromJson(Map<String, dynamic> json) {
    tRTYPE1 = json['TR_TYPE1'].toString();
    tRNO = json['TR_NO'].toString();
    tRTYPE = json['TR_TYPE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
    cLIENTNAME = json['CLIENT_NAME'].toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
    bUYQTY = json['BUY_QTY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    bUYAMT = json['BUY_AMT'].toString();
    sALEQTY = json['SALE_QTY'].toString();
    sALEAMT = json['SALE_AMT'].toString();
    sALERATE = json['SALE_RATE'].toString();
    nETQTY = json['NET_QTY'].toString();
    nETRATE = json['NET_RATE'].toString();
    nETAMOUNT = json['NET_AMOUNT'].toString();
    cURRAMOUNT = json['CURR_AMOUNT'].toString();
    pLAMT = json['PL_AMT'].toString();
    closingPrice = json['Closing_Price'].toString();
    priceDate = json['PriceDate'].toString();
    sCRIPNAME = json['SCRIP_NAME'].toString();
    lONGTERM = json['LONG_TERM'].toString();
    sHORTTERM = json['SHORT_TERM'].toString();
    sPECULATION = json['SPECULATION'].toString();
    sCRIPNAMEDATA = json['SCRIP_NAMEDATA'].toString();
    pANNO = json['PAN_NO'].toString();
    aDDR1 = json['ADDR1'].toString();
    aDDR2 = json['ADDR2'].toString();
    aDDR3 = json['ADDR3'].toString();
    aDDR4 = json['ADDR4'].toString();
    aDDR5 = json['ADDR5'].toString();
    iSIN = json['ISIN'].toString();
    lTCGRATE = json['LTCG_RATE'].toString();
    pRICERATE = json['PRICE_RATE'].toString();
    per = json['Per'].toString();
    sCRIPNAMEROWDATA = json['SCRIP_NAME_ROWDATA'].toString();
    nOTIONALNET = json['NOTIONAL_NET'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TR_TYPE1'] = tRTYPE1;
    data['TR_NO'] = tRNO;
    data['TR_TYPE'] = tRTYPE;
    data['CLIENT_ID'] = cLIENTID;
    data['CLIENT_NAME'] = cLIENTNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['BUY_QTY'] = bUYQTY;
    data['BUY_RATE'] = bUYRATE;
    data['BUY_AMT'] = bUYAMT;
    data['SALE_QTY'] = sALEQTY;
    data['SALE_AMT'] = sALEAMT;
    data['SALE_RATE'] = sALERATE;
    data['NET_QTY'] = nETQTY;
    data['NET_RATE'] = nETRATE;
    data['NET_AMOUNT'] = nETAMOUNT;
    data['CURR_AMOUNT'] = cURRAMOUNT;
    data['PL_AMT'] = pLAMT;
    data['Closing_Price'] = closingPrice;
    data['PriceDate'] = priceDate;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['LONG_TERM'] = lONGTERM;
    data['SHORT_TERM'] = sHORTTERM;
    data['SPECULATION'] = sPECULATION;
    data['SCRIP_NAMEDATA'] = sCRIPNAMEDATA;
    data['PAN_NO'] = pANNO;
    data['ADDR1'] = aDDR1;
    data['ADDR2'] = aDDR2;
    data['ADDR3'] = aDDR3;
    data['ADDR4'] = aDDR4;
    data['ADDR5'] = aDDR5;
    data['ISIN'] = iSIN;
    data['LTCG_RATE'] = lTCGRATE;
    data['PRICE_RATE'] = pRICERATE;
    data['Per'] = per;
    data['SCRIP_NAME_ROWDATA'] = sCRIPNAMEROWDATA;
    data['NOTIONAL_NET'] = nOTIONALNET;
    return data;
  }
}

class TRADING {
  String? tRTYPE1;
  String? tRNO;
  String? tRTYPE;
  String? cLIENTID;
  String? cLIENTNAME;
  String? sCRIPSYMBOL;
  String? bUYQTY;
  String? bUYRATE;
  String? bUYAMT;
  String? sALEQTY;
  String? sALEAMT;
  String? sALERATE;
  String? nETQTY;
  String? nETRATE;
  String? nETAMOUNT;
  String? cURRAMOUNT;
  String? pLAMT;
  String? closingPrice;
  String? priceDate;
  String? sCRIPNAME;
  String? lONGTERM;
  String? sHORTTERM;
  String? sPECULATION;
  String? sCRIPNAMEDATA;
  String? pANNO;
  String? aDDR1;
  String? aDDR2;
  String? aDDR3;
  String? aDDR4;
  String? aDDR5;
  String? iSIN;
  String? lTCGRATE;
  String? pRICERATE;
  String? per;
  String? sCRIPNAMEROWDATA;
  String? nOTIONALNET;

  TRADING(
      {this.tRTYPE1,
      this.tRNO,
      this.tRTYPE,
      this.cLIENTID,
      this.cLIENTNAME,
      this.sCRIPSYMBOL,
      this.bUYQTY,
      this.bUYRATE,
      this.bUYAMT,
      this.sALEQTY,
      this.sALEAMT,
      this.sALERATE,
      this.nETQTY,
      this.nETRATE,
      this.nETAMOUNT,
      this.cURRAMOUNT,
      this.pLAMT,
      this.closingPrice,
      this.priceDate,
      this.sCRIPNAME,
      this.lONGTERM,
      this.sHORTTERM,
      this.sPECULATION,
      this.sCRIPNAMEDATA,
      this.pANNO,
      this.aDDR1,
      this.aDDR2,
      this.aDDR3,
      this.aDDR4,
      this.aDDR5,
      this.iSIN,
      this.lTCGRATE,
      this.pRICERATE,
      this.per,
      this.sCRIPNAMEROWDATA,
      this.nOTIONALNET});

  TRADING.fromJson(Map<String, dynamic> json) {
    tRTYPE1 = json['TR_TYPE1'].toString();
    tRNO = json['TR_NO'].toString();
    tRTYPE = json['TR_TYPE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
    cLIENTNAME = json['CLIENT_NAME'].toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
    bUYQTY = json['BUY_QTY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    bUYAMT = json['BUY_AMT'].toString();
    sALEQTY = json['SALE_QTY'].toString();
    sALEAMT = json['SALE_AMT'].toString();
    sALERATE = json['SALE_RATE'].toString();
    nETQTY = json['NET_QTY'].toString();
    nETRATE = json['NET_RATE'].toString();
    nETAMOUNT = json['NET_AMOUNT'].toString();
    cURRAMOUNT = json['CURR_AMOUNT'].toString();
    pLAMT = json['PL_AMT'].toString();
    closingPrice = json['Closing_Price'].toString();
    priceDate = json['PriceDate'].toString();
    sCRIPNAME = json['SCRIP_NAME'].toString();
    lONGTERM = json['LONG_TERM'].toString();
    sHORTTERM = json['SHORT_TERM'].toString();
    sPECULATION = json['SPECULATION'].toString();
    sCRIPNAMEDATA = json['SCRIP_NAMEDATA'].toString();
    pANNO = json['PAN_NO'].toString();
    aDDR1 = json['ADDR1'].toString();
    aDDR2 = json['ADDR2'].toString();
    aDDR3 = json['ADDR3'].toString();
    aDDR4 = json['ADDR4'].toString();
    aDDR5 = json['ADDR5'].toString();
    iSIN = json['ISIN'].toString();
    lTCGRATE = json['LTCG_RATE'].toString();
    pRICERATE = json['PRICE_RATE'].toString();
    per = json['Per'].toString();
    sCRIPNAMEROWDATA = json['SCRIP_NAME_ROWDATA'].toString();
    nOTIONALNET = json['NOTIONAL_NET'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TR_TYPE1'] = tRTYPE1;
    data['TR_NO'] = tRNO;
    data['TR_TYPE'] = tRTYPE;
    data['CLIENT_ID'] = cLIENTID;
    data['CLIENT_NAME'] = cLIENTNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['BUY_QTY'] = bUYQTY;
    data['BUY_RATE'] = bUYRATE;
    data['BUY_AMT'] = bUYAMT;
    data['SALE_QTY'] = sALEQTY;
    data['SALE_AMT'] = sALEAMT;
    data['SALE_RATE'] = sALERATE;
    data['NET_QTY'] = nETQTY;
    data['NET_RATE'] = nETRATE;
    data['NET_AMOUNT'] = nETAMOUNT;
    data['CURR_AMOUNT'] = cURRAMOUNT;
    data['PL_AMT'] = pLAMT;
    data['Closing_Price'] = closingPrice;
    data['PriceDate'] = priceDate;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['LONG_TERM'] = lONGTERM;
    data['SHORT_TERM'] = sHORTTERM;
    data['SPECULATION'] = sPECULATION;
    data['SCRIP_NAMEDATA'] = sCRIPNAMEDATA;
    data['PAN_NO'] = pANNO;
    data['ADDR1'] = aDDR1;
    data['ADDR2'] = aDDR2;
    data['ADDR3'] = aDDR3;
    data['ADDR4'] = aDDR4;
    data['ADDR5'] = aDDR5;
    data['ISIN'] = iSIN;
    data['LTCG_RATE'] = lTCGRATE;
    data['PRICE_RATE'] = pRICERATE;
    data['Per'] = per;
    data['SCRIP_NAME_ROWDATA'] = sCRIPNAMEROWDATA;
    data['NOTIONAL_NET'] = nOTIONALNET;
    return data;
  }
}

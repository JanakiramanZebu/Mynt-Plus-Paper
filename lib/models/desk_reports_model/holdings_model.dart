class HoldingModel {
  List<dynamic>? holdings;
  List<dynamic>? fullStat;
  String? holdingsValueBuyprice;
  String? holdingsValueNoBuyprice;
  String? pnlPerc;
  String? totalInvested;
  String? totalPnl;

  HoldingModel(
      {this.holdings,
      this.fullStat,
      this.holdingsValueBuyprice,
      this.holdingsValueNoBuyprice,
      this.pnlPerc,
      this.totalInvested,
      this.totalPnl});

  HoldingModel.fromJson(Map<String, dynamic> json) {
    if (json['Holdings'] != null) {
      holdings = <dynamic>[];
      json['Holdings'].forEach((v) {
        holdings!.add(v);
      });
    }
    if (json['full_stat'] != null) {
      fullStat = <dynamic>[];
      json['full_stat'].forEach((v) {
        fullStat!.add(v);
      });
    }
    holdingsValueBuyprice = json['holdings_value_buyprice'].toString();
    holdingsValueNoBuyprice = json['holdings_value_no_buyprice'].toString();
    pnlPerc = json['pnl_perc'].toString();
    totalInvested = json['total_invested'].toString();
    totalPnl = json['total_pnl'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (holdings != null) {
      data['Holdings'] = holdings!.map((v) => v.toJson()).toList();
    }
    if (fullStat != null) {
      data['full_stat'] = fullStat!.map((v) => v.toJson()).toList();
    }
    data['holdings_value_buyprice'] = holdingsValueBuyprice;
    data['holdings_value_no_buyprice'] = holdingsValueNoBuyprice;
    data['pnl_perc'] = pnlPerc;
    data['total_invested'] = totalInvested;
    data['total_pnl'] = totalPnl;
    return data;
  }
}

// class Holdings {
//   String? exchange;
//   String? iSIN;
//   String? nET;
//   String? sCRIPNAME;
//   String? sCRIPSYMBOL;
//   String? sCRIPVALUE;
//   String? sERIES;
//   String? token;
//   String? total;
//   List<AvgRes>? avgRes;
//   String? buyPrice;
//   String? invested;
//   String? lastClose;
//   String? manualUpdt;
//   String? navPrice;
//   String? notUpdatedQty;
//   String? percentage;
//   String? pnl;
//   String? pnlPerc;
//   String? presentNoBuyPrice;
//   String? presentWithBuyPrice;
//   String? remQty;
//   String? segType;
//   String? updatedQty;

//   Holdings({
//     this.exchange,
//     this.iSIN,
//     this.nET,
//     this.sCRIPNAME,
//     this.sCRIPSYMBOL,
//     this.sCRIPVALUE,
//     this.sERIES,
//     this.token,
//     this.total,
//     this.avgRes,
//     this.buyPrice,
//     this.invested,
//     this.lastClose,
//     this.manualUpdt,
//     this.navPrice,
//     this.notUpdatedQty,
//     this.percentage,
//     this.pnl,
//     this.pnlPerc,
//     this.presentNoBuyPrice,
//     this.presentWithBuyPrice,
//     this.remQty,
//     this.segType,
//     this.updatedQty,
//   });

//   Holdings.fromJson(Map<String, dynamic> json) {
//     exchange = json['Exchange'];
//     iSIN = json['ISIN'];
//     nET = json['NET']?.toString();
//     sCRIPNAME = json['SCRIP_NAME'];
//     sCRIPSYMBOL = json['SCRIP_SYMBOL'];
//     sCRIPVALUE = json['SCRIP_VALUE']?.toString();
//     sERIES = json['SERIES']?.toString();
//     token = json['Token'];
//     total = json['Total']?.toString();
//     if (json['avg_res'] != null) {
//       avgRes = <AvgRes>[];
//       json['avg_res'].forEach((v) {
//         avgRes!.add(AvgRes.fromJson(v));
//       });
//     }
//     buyPrice = json['buy_price']?.toString();
//     invested = json['invested']?.toString();
//     lastClose = json['last_close']?.toString();
//     manualUpdt = json['manual_updt'];
//     navPrice = json['nav_price']?.toString();
//     notUpdatedQty = json['not_updated_qty']?.toString();
//     percentage = json['percentage']?.toString();
//     pnl = json['pnl']?.toString();
//     pnlPerc = json['pnl_perc']?.toString();
//     presentNoBuyPrice = json['present_no_buy_price']?.toString();
//     presentWithBuyPrice = json['present_with_buy_price']?.toString();
//     remQty = json['rem_qty']?.toString();
//     segType = json['seg_type'];
//     updatedQty = json['updated_qty']?.toString();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['Exchange'] = exchange;
//     data['ISIN'] = iSIN;
//     data['NET'] = nET;
//     data['SCRIP_NAME'] = sCRIPNAME;
//     data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
//     data['SCRIP_VALUE'] = sCRIPVALUE;
//     data['SERIES'] = sERIES;
//     data['Token'] = token;
//     data['Total'] = total;
//     if (avgRes != null) {
//       data['avg_res'] = avgRes!.map((v) => v.toJson()).toList();
//     }
//     data['buy_price'] = buyPrice;
//     data['invested'] = invested;
//     data['last_close'] = lastClose;
//     data['manual_updt'] = manualUpdt;
//     data['nav_price'] = navPrice;
//     data['not_updated_qty'] = notUpdatedQty;
//     data['percentage'] = percentage;
//     data['pnl'] = pnl;
//     data['pnl_perc'] = pnlPerc;
//     data['present_no_buy_price'] = presentNoBuyPrice;
//     data['present_with_buy_price'] = presentWithBuyPrice;
//     data['rem_qty'] = remQty;
//     data['seg_type'] = segType;
//     data['updated_qty'] = updatedQty;
//     return data;
//   }
// }

// class AvgRes {
//   String? clientId;
//   String? description;
//   String? exchange;
//   String? iSIN;
//   String? pRICEPREMIUM;
//   String? pURDATE;
//   String? qUANTITY;
//   String? rOWID;
//   String? sCRIPSYMBOL;
//   String? sell;
//   String? bought;

//   AvgRes(
//       {this.clientId,
//       this.description,
//       this.exchange,
//       this.iSIN,
//       this.pRICEPREMIUM,
//       this.pURDATE,
//       this.qUANTITY,
//       this.rOWID,
//       this.sCRIPSYMBOL,
//       this.sell,
//       this.bought});

//   AvgRes.fromJson(Map<String, dynamic> json) {
//     clientId = json['Client_id'];
//     description = json['Description'];
//     exchange = json['Exchange'];
//     iSIN = json['ISIN'];
//     pRICEPREMIUM = json['PRICE_PREMIUM'].toString();
//     pURDATE = json['PUR_DATE'];
//     qUANTITY = json['QUANTITY'].toString();
//     rOWID = json['ROW_ID'];
//     sCRIPSYMBOL = json['SCRIP_SYMBOL'];
//     sell = json['Sell'];
//     bought = json['bought'].toString();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['Client_id'] = clientId;
//     data['Description'] = description;
//     data['Exchange'] = exchange;
//     data['ISIN'] = iSIN;
//     data['PRICE_PREMIUM'] = pRICEPREMIUM;
//     data['PUR_DATE'] = pURDATE;
//     data['QUANTITY'] = qUANTITY;
//     data['ROW_ID'] = rOWID;
//     data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
//     data['Sell'] = sell;
//     data['bought'] = bought;
//     return data;
//   }
// }

// class FullStat {
//   String? iSINNUMBER;
//   String? aMOUNT;
//   String? aMOUNT1;
//   String? bENQTY;
//   String? bSESYMBOL;
//   String? bizDt;
//   String? cLIENTCODE;
//   String? cLIENTTEXT;
//   String? cLIENTNAME;
//   String? cOLQTY;
//   String? chngInOpnIntrst;
//   String? clsPric;
//   String? dATEOFLISTING;
//   String? exchange;
//   String? fACEVALUE;
//   String? finInstrmId;
//   String? finInstrmNm;
//   String? finInstrmTp;
//   String? fininstrmActlXpryDt;
//   String? hAIRCUT;
//   String? hCAMOUNT;
//   String? hCPRICE;
//   String? hghPric;
//   String? iNSHORT;
//   String? iSIN;
//   String? instrument;
//   String? lastPric;
//   String? lotSize;
//   String? lwPric;
//   String? mARKETLOT;
//   String? nAMEOFCOMPANY;
//   String? nET;
//   String? nSESYMBOL;
//   String? nSOHQTY;
//   String? newBrdLotQty;
//   String? oUTSHORT;
//   String? opnIntrst;
//   String? opnPric;
//   String? optnTp;
//   String? pAIDUPVALUE;
//   String? pLEDGEQTY;
//   String? prvsClsgPric;
//   String? rmks;
//   String? rsvd1;
//   String? rsvd2;
//   String? rsvd3;
//   String? rsvd4;
//   String? sCRIPNAME;
//   String? sCRIPSYMBOL;
//   String? sCRIPVALUE;
//   String? sERIES;
//   String? sERIESX;
//   String? sERIESY;
//   String? sOHQTY;
//   String? sYMBOL;
//   String? sctySrs;
//   String? sgmt;
//   String? src;
//   String? ssnId;
//   String? strkPric;
//   String? sttlmPric;
//   String? symbol;
//   String? tckrSymb;
//   String? tickSize;
//   String? token;
//   String? tradDt;
//   String? tradingSymbol;
//   String? ttlNbOfTxsExctd;
//   String? ttlTradgVol;
//   String? ttlTrfVal;
//   String? undrlygPric;
//   String? unnamed7;
//   String? xpryDt;
//   String? avgQty;
//   List<AvgRes>? avgRes;
//   String? buyPrice;
//   String? index;
//   String? lastClose;
//   String? manualUpdt;
//   String? navPrice;
//   String? notUpdatedQty;
//   String? remQty;
//   String? updatedBuyPrice;
//   String? updatedQty;

//   FullStat(
//       {this.iSINNUMBER,
//       this.aMOUNT,
//       this.aMOUNT1,
//       this.bENQTY,
//       this.bSESYMBOL,
//       this.bizDt,
//       this.cLIENTCODE,
//       this.cLIENTTEXT,
//       this.cLIENTNAME,
//       this.cOLQTY,
//       this.chngInOpnIntrst,
//       this.clsPric,
//       this.dATEOFLISTING,
//       this.exchange,
//       this.fACEVALUE,
//       this.finInstrmId,
//       this.finInstrmNm,
//       this.finInstrmTp,
//       this.fininstrmActlXpryDt,
//       this.hAIRCUT,
//       this.hCAMOUNT,
//       this.hCPRICE,
//       this.hghPric,
//       this.iNSHORT,
//       this.iSIN, 
//       this.instrument,
//       this.lastPric,
//       this.lotSize,
//       this.lwPric,
//       this.mARKETLOT,
//       this.nAMEOFCOMPANY,
//       this.nET,
//       this.nSESYMBOL,
//       this.nSOHQTY,
//       this.newBrdLotQty,
//       this.oUTSHORT,
//       this.opnIntrst,
//       this.opnPric,
//       this.optnTp,
//       this.pAIDUPVALUE,
//       this.pLEDGEQTY,
//       this.prvsClsgPric,
//       this.rmks,
//       this.rsvd1,
//       this.rsvd2,
//       this.rsvd3,
//       this.rsvd4,
//       this.sCRIPNAME,
//       this.sCRIPSYMBOL,
//       this.sCRIPVALUE,
//       this.sERIES,
//       this.sERIESX,
//       this.sERIESY,
//       this.sOHQTY,
//       this.sYMBOL,
//       this.sctySrs,
//       this.sgmt,
//       this.src,
//       this.ssnId,
//       this.strkPric,
//       this.sttlmPric,
//       this.symbol,
//       this.tckrSymb,
//       this.tickSize,
//       this.token,
//       this.tradDt,
//       this.tradingSymbol,
//       this.ttlNbOfTxsExctd,
//       this.ttlTradgVol,
//       this.ttlTrfVal,
//       this.undrlygPric,
//       this.unnamed7,
//       this.xpryDt,
//       this.avgQty,
//       this.avgRes,
//       this.buyPrice,
//       this.index,
//       this.lastClose,
//       this.manualUpdt,
//       this.navPrice,
//       this.notUpdatedQty,
//       this.remQty,
//       this.updatedBuyPrice,
//       this.updatedQty});

//   FullStat.fromJson(Map<String, dynamic> json) {
//     iSINNUMBER = json[' ISIN NUMBER'].toString();
//     aMOUNT = json['AMOUNT'].toString();
//     aMOUNT1 = json['AMOUNT1'].toString();
//     bENQTY = json['BENQTY'].toString();
//     bSESYMBOL = json['BSE_SYMBOL'].toString();
//     bizDt = json['BizDt'].toString();
//     cLIENTCODE = json['CLIENTCODE'].toString();
//     cLIENTTEXT = json['CLIENTTEXT'].toString();
//     cLIENTNAME = json['CLIENT_NAME'].toString();
//     cOLQTY = json['COLQTY'].toString();
//     chngInOpnIntrst = json['ChngInOpnIntrst'].toString();
//     clsPric = json['ClsPric'].toString();
//     dATEOFLISTING = json['DATE OF LISTING'].toString();
//     exchange = json['Exchange'].toString();
//     fACEVALUE = json['FACE VALUE'].toString();
//     finInstrmId = json['FinInstrmId'].toString();
//     finInstrmNm = json['FinInstrmNm'].toString();
//     finInstrmTp = json['FinInstrmTp'].toString();
//     fininstrmActlXpryDt = json['FininstrmActlXpryDt'].toString();
//     hAIRCUT = json['HAIRCUT'].toString();
//     hCAMOUNT = json['HC_AMOUNT'].toString();
//     hCPRICE = json['HC_PRICE'].toString();
//     hghPric = json['HghPric'].toString();
//     iNSHORT = json['INSHORT'].toString();
//     iSIN = json['ISIN'].toString();
//     iSINNUMBER = json['ISIN NUMBER'].toString();
//     instrument = json['Instrument'].toString();
//     lastPric = json['LastPric'].toString();
//     lotSize = json['LotSize'].toString();
//     lwPric = json['LwPric'].toString();
//     mARKETLOT = json['MARKET LOT'].toString();
//     nAMEOFCOMPANY = json['NAME OF COMPANY'].toString();
//     nET = json['NET'].toString();
//     nSESYMBOL = json['NSE_SYMBOL'].toString();
//     nSOHQTY = json['NSOHQTY'].toString();
//     newBrdLotQty = json['NewBrdLotQty'].toString();
//     oUTSHORT = json['OUTSHORT'].toString();
//     opnIntrst = json['OpnIntrst'].toString();
//     opnPric = json['OpnPric'].toString();
//     optnTp = json['OptnTp'].toString();
//     pAIDUPVALUE = json['PAID UP VALUE'].toString();
//     pLEDGEQTY = json['PLEDGE_QTY'].toString();
//     prvsClsgPric = json['PrvsClsgPric'].toString();
//     rmks = json['Rmks'].toString();
//     rsvd1 = json['Rsvd1'].toString();
//     rsvd2 = json['Rsvd2'].toString();
//     rsvd3 = json['Rsvd3'].toString();
//     rsvd4 = json['Rsvd4'].toString();
//     sCRIPNAME = json['SCRIP_NAME'].toString();
//     sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
//     sCRIPVALUE = json['SCRIP_VALUE'].toString();
//     sERIES = json['SERIES'].toString();
//     sERIESX = json['SERIES_x'].toString();
//     sERIESY = json['SERIES_y'].toString();
//     sOHQTY = json['SOHQTY'].toString();
//     sYMBOL = json['SYMBOL'].toString();
//     sctySrs = json['SctySrs'].toString();
//     sgmt = json['Sgmt'].toString();
//     src = json['Src'].toString();
//     ssnId = json['SsnId'].toString();
//     strkPric = json['StrkPric'].toString();
//     sttlmPric = json['SttlmPric'].toString();
//     symbol = json['Symbol'].toString();
//     tckrSymb = json['TckrSymb'].toString();
//     tickSize = json['TickSize'].toString();
//     token = json['Token'].toString();
//     tradDt = json['TradDt'].toString();
//     tradingSymbol = json['TradingSymbol'].toString();
//     ttlNbOfTxsExctd = json['TtlNbOfTxsExctd'].toString();
//     ttlTradgVol = json['TtlTradgVol'].toString();
//     ttlTrfVal = json['TtlTrfVal'].toString();
//     undrlygPric = json['UndrlygPric'].toString();
//     unnamed7 = json['Unnamed: 7'].toString();
//     xpryDt = json['XpryDt'].toString();
//     avgQty = json['avg_qty'].toString();
//     if (json['avg_res'] != null) {
//       avgRes = <AvgRes>[];
//       json['avg_res'].forEach((v) {
//         avgRes!.add(AvgRes.fromJson(v));
//       });
//     }
//     buyPrice = json['buy_price'].toString();
//     index = json['index'].toString();
//     lastClose = json['last_close'].toString();
//     manualUpdt = json['manual_updt'].toString();
//     navPrice = json['nav_price'].toString();
//     notUpdatedQty = json['not_updated_qty'].toString();
//     remQty = json['rem_qty'].toString();
//     updatedBuyPrice = json['updated_buy_price'].toString();
//     updatedQty = json['updated_qty'].toString();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data[' ISIN NUMBER'] = iSINNUMBER;
//     data['AMOUNT'] = aMOUNT;
//     data['AMOUNT1'] = aMOUNT1;
//     data['BENQTY'] = bENQTY;
//     data['BSE_SYMBOL'] = bSESYMBOL;
//     data['BizDt'] = bizDt;
//     data['CLIENTCODE'] = cLIENTCODE;
//     data['CLIENTTEXT'] = cLIENTTEXT;
//     data['CLIENT_NAME'] = cLIENTNAME;
//     data['COLQTY'] = cOLQTY;
//     data['ChngInOpnIntrst'] = chngInOpnIntrst;
//     data['ClsPric'] = clsPric;
//     data['DATE OF LISTING'] = dATEOFLISTING;
//     data['Exchange'] = exchange;
//     data['FACE VALUE'] = fACEVALUE;
//     data['FinInstrmId'] = finInstrmId;
//     data['FinInstrmNm'] = finInstrmNm;
//     data['FinInstrmTp'] = finInstrmTp;
//     data['FininstrmActlXpryDt'] = fininstrmActlXpryDt;
//     data['HAIRCUT'] = hAIRCUT;
//     data['HC_AMOUNT'] = hCAMOUNT;
//     data['HC_PRICE'] = hCPRICE;
//     data['HghPric'] = hghPric;
//     data['INSHORT'] = iNSHORT;
//     data['ISIN'] = iSIN;
//     data['ISIN NUMBER'] = iSINNUMBER;
//     data['Instrument'] = instrument;
//     data['LastPric'] = lastPric;
//     data['LotSize'] = lotSize;
//     data['LwPric'] = lwPric;
//     data['MARKET LOT'] = mARKETLOT;
//     data['NAME OF COMPANY'] = nAMEOFCOMPANY;
//     data['NET'] = nET;
//     data['NSE_SYMBOL'] = nSESYMBOL;
//     data['NSOHQTY'] = nSOHQTY;
//     data['NewBrdLotQty'] = newBrdLotQty;
//     data['OUTSHORT'] = oUTSHORT;
//     data['OpnIntrst'] = opnIntrst;
//     data['OpnPric'] = opnPric;
//     data['OptnTp'] = optnTp;
//     data['PAID UP VALUE'] = pAIDUPVALUE;
//     data['PLEDGE_QTY'] = pLEDGEQTY;
//     data['PrvsClsgPric'] = prvsClsgPric;
//     data['Rmks'] = rmks;
//     data['Rsvd1'] = rsvd1;
//     data['Rsvd2'] = rsvd2;
//     data['Rsvd3'] = rsvd3;
//     data['Rsvd4'] = rsvd4;
//     data['SCRIP_NAME'] = sCRIPNAME;
//     data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
//     data['SCRIP_VALUE'] = sCRIPVALUE;
//     data['SERIES'] = sERIES;
//     data['SERIES_x'] = sERIESX;
//     data['SERIES_y'] = sERIESY;
//     data['SOHQTY'] = sOHQTY;
//     data['SYMBOL'] = sYMBOL;
//     data['SctySrs'] = sctySrs;
//     data['Sgmt'] = sgmt;
//     data['Src'] = src;
//     data['SsnId'] = ssnId;
//     data['StrkPric'] = strkPric;
//     data['SttlmPric'] = sttlmPric;
//     data['Symbol'] = symbol;
//     data['TckrSymb'] = tckrSymb;
//     data['TickSize'] = tickSize;
//     data['Token'] = token;
//     data['TradDt'] = tradDt;
//     data['TradingSymbol'] = tradingSymbol;
//     data['TtlNbOfTxsExctd'] = ttlNbOfTxsExctd;
//     data['TtlTradgVol'] = ttlTradgVol;
//     data['TtlTrfVal'] = ttlTrfVal;
//     data['UndrlygPric'] = undrlygPric;
//     data['Unnamed: 7'] = unnamed7;
//     data['XpryDt'] = xpryDt;
//     data['avg_qty'] = avgQty;
//     if (avgRes != null) {
//       data['avg_res'] = avgRes!.map((v) => v.toJson()).toList();
//     }
//     data['buy_price'] = buyPrice;
//     data['index'] = index;
//     data['last_close'] = lastClose;
//     data['manual_updt'] = manualUpdt;
//     data['nav_price'] = navPrice;
//     data['not_updated_qty'] = notUpdatedQty;
//     data['rem_qty'] = remQty;
//     data['updated_buy_price'] = updatedBuyPrice;
//     data['updated_qty'] = updatedQty;
//     return data;
//   }
// }

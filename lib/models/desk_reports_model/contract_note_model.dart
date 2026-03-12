class ContractNoteModel {
  ContractNoteData? data;
  Map<String, List<ContractNoteNet>>? net;
  Map<String, List<ContractNoteSettlement>>? settlement;

  ContractNoteModel({this.data, this.net, this.settlement});

  ContractNoteModel.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null
        ? ContractNoteData.fromJson(json['Data'] as Map<String, dynamic>)
        : null;

    // Parse top-level Net
    if (json['Net'] != null) {
      net = {};
      (json['Net'] as Map<String, dynamic>).forEach((key, value) {
        net![key] = <ContractNoteNet>[];
        (value as List).forEach((v) {
          net![key]!.add(ContractNoteNet.fromJson(v as Map<String, dynamic>));
        });
      });
    }

    // Parse top-level settlement
    final settlementJson = json['settlement'] ?? json['Settlement'];
    if (settlementJson != null) {
      settlement = {};
      (settlementJson as Map<String, dynamic>).forEach((key, value) {
        settlement![key] = <ContractNoteSettlement>[];
        (value as List).forEach((v) {
          settlement![key]!
              .add(ContractNoteSettlement.fromJson(v as Map<String, dynamic>));
        });
      });
    }
  }
}

class ContractNoteData {
  List<ContractNoteTrade>? common;
  Map<String, List<ContractNoteNet>>? net;
  Map<String, List<ContractNoteSettlement>>? settlement;

  ContractNoteData({this.common, this.net, this.settlement});

  ContractNoteData.fromJson(Map<String, dynamic> json) {
    if (json['Common'] != null) {
      common = <ContractNoteTrade>[];
      (json['Common'] as List).forEach((v) {
        common!.add(ContractNoteTrade.fromJson(v as Map<String, dynamic>));
      });
    }

    if (json['Net'] != null) {
      net = {};
      (json['Net'] as Map<String, dynamic>).forEach((key, value) {
        net![key] = <ContractNoteNet>[];
        (value as List).forEach((v) {
          net![key]!.add(ContractNoteNet.fromJson(v as Map<String, dynamic>));
        });
      });
    }

    final settlementJson = json['settlement'] ?? json['Settlement'];
    if (settlementJson != null) {
      settlement = {};
      (settlementJson as Map<String, dynamic>).forEach((key, value) {
        settlement![key] = <ContractNoteSettlement>[];
        (value as List).forEach((v) {
          settlement![key]!
              .add(ContractNoteSettlement.fromJson(v as Map<String, dynamic>));
        });
      });
    }
  }
}

class ContractNoteTrade {
  String? billNo;
  String? buyPrice;
  String? buyQuantity;
  String? buySale;
  String? buyAmount;
  String? companyCode;
  String? contractNo;
  String? expiryDate;
  String? instrumentType;
  String? netBuyPrice;
  String? netSellPrice;
  String? optionType;
  String? orderDatetime;
  String? orderNumber;
  String? pricePremium;
  String? quantity;
  String? scripName;
  String? scripSymbol;
  String? sellPrice;
  String? sellQuantity;
  String? settlementNo;
  String? strikePrice;
  String? sellAmount;
  String? tradeBrokerage;
  String? tradeDatetime;
  String? tradeNumber;
  String? tradeExchange;

  ContractNoteTrade({
    this.billNo,
    this.buyPrice,
    this.buyQuantity,
    this.buySale,
    this.buyAmount,
    this.companyCode,
    this.contractNo,
    this.expiryDate,
    this.instrumentType,
    this.netBuyPrice,
    this.netSellPrice,
    this.optionType,
    this.orderDatetime,
    this.orderNumber,
    this.pricePremium,
    this.quantity,
    this.scripName,
    this.scripSymbol,
    this.sellPrice,
    this.sellQuantity,
    this.settlementNo,
    this.strikePrice,
    this.sellAmount,
    this.tradeBrokerage,
    this.tradeDatetime,
    this.tradeNumber,
    this.tradeExchange,
  });

  ContractNoteTrade.fromJson(Map<String, dynamic> json) {
    billNo = json['BILL_NO']?.toString();
    buyPrice = json['BUY_PRICE']?.toString();
    buyQuantity = json['BUY_QUANTITY']?.toString();
    buySale = json['BUY_SALE']?.toString();
    buyAmount = json['Buy_Amount']?.toString();
    companyCode = json['COMPANY_CODE']?.toString();
    contractNo = json['CONTRACT_NO']?.toString();
    expiryDate = json['EXPIRY_DATE']?.toString();
    instrumentType = json['INSTRUMENT_TYPE']?.toString();
    netBuyPrice = json['NET_BUY_PRICE']?.toString();
    netSellPrice = json['NET_SELL_PRICE']?.toString();
    optionType = json['OPTION_TYPE']?.toString();
    orderDatetime = json['ORDER_DATETIME']?.toString();
    orderNumber = json['ORDER_NUMBER']?.toString();
    pricePremium = json['PRICE_PREMIUM']?.toString();
    quantity = json['QUANTITY']?.toString();
    scripName = json['SCRIP_NAME']?.toString();
    scripSymbol = json['SCRIP_SYMBOL']?.toString();
    sellPrice = json['SELL_PRICE']?.toString();
    sellQuantity = json['SELL_QUANTITY']?.toString();
    settlementNo = json['SETTLEMENT_NO']?.toString();
    strikePrice = json['STRIKE_PRICE']?.toString();
    sellAmount = json['Sell_Amount']?.toString();
    tradeBrokerage = json['TRADE_BROKERAGE']?.toString();
    tradeDatetime = json['TRADE_DATETIME']?.toString();
    tradeNumber = json['TRADE_NUMBER']?.toString();
    tradeExchange = json['TradeExchange']?.toString();
  }
}

class ContractNoteNet {
  String? buyQuantity;
  String? buyAmount;
  String? buyRate;
  String? netAmt;
  String? netQty;
  String? sellQuantity;
  String? sellAmount;
  String? sellRate;

  ContractNoteNet({
    this.buyQuantity,
    this.buyAmount,
    this.buyRate,
    this.netAmt,
    this.netQty,
    this.sellQuantity,
    this.sellAmount,
    this.sellRate,
  });

  ContractNoteNet.fromJson(Map<String, dynamic> json) {
    buyQuantity = json['BUY_QUANTITY']?.toString();
    buyAmount = json['Buy_Amount']?.toString();
    buyRate = json['Buy_Rate']?.toString();
    netAmt = json['NET_AMT']?.toString();
    netQty = json['NET_QTY']?.toString();
    sellQuantity = json['SELL_QUANTITY']?.toString();
    sellAmount = json['Sell_Amount']?.toString();
    sellRate = json['Sell_Rate']?.toString();
  }
}

class ContractNoteSettlement {
  String? latestContractNo;
  String? brokerage;
  String? cgst;
  String? netAmt;
  String? payinout;
  String? sgst;
  String? stampduty;
  String? stt;
  String? tot;

  ContractNoteSettlement({
    this.latestContractNo,
    this.brokerage,
    this.cgst,
    this.netAmt,
    this.payinout,
    this.sgst,
    this.stampduty,
    this.stt,
    this.tot,
  });

  ContractNoteSettlement.fromJson(Map<String, dynamic> json) {
    latestContractNo = json['LATEST_CONTRACT_NO']?.toString();
    brokerage = json['brokerage']?.toString();
    cgst = json['cgst']?.toString();
    netAmt = json['net_amt']?.toString();
    payinout = json['payinout']?.toString();
    sgst = json['sgst']?.toString();
    stampduty = json['stampduty']?.toString();
    stt = json['stt']?.toString();
    tot = json['tot']?.toString();
  }
}

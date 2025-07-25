class CalenderpnlModel {
  List<TradeData>? data;
  Map? data2;
  Map? summary;
  Map? symbolarr;
  Map? fullresponse;

  List<Journal>? journal;
  double realized = 0;
  double unrealized = 0;
  double? totalCharges;
  String? segment;
  CalenderpnlModel(
      {this.data,
      this.data2,
      this.journal,
      this.totalCharges,
      this.summary,
      this.symbolarr,
      this.fullresponse});

  CalenderpnlModel.fromJson(Map<String, dynamic> json) {
    if (json['Data2'] != null) {
      data = <TradeData>[];
      json['Data2'].forEach((v) {
        realized += v['realisedpnl'];
        unrealized += v['unrealisedpnl'];
        data!.add(TradeData.fromJson(v));
      });
    }
    if (json['journal'] != null) {
      journal = <Journal>[];
      json['journal'].forEach((v) {
        journal!.add(Journal.fromJson(v));
      });
    }
    if (json['Data'] != null) {
      data2 = json['Data'];
    }
    if (json['summary'] != null) {
      this.summary = json['summary'];
    }

    if (json['symbolarr'] != null) {
      this.symbolarr = json['symbolarr'];
    }
    fullresponse = json;
    totalCharges = json['total_charges'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['Data2'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.data2 != null) {
      data['Data'] = this.data2;
    }
    if (this.summary != null) {
      data['summary'] = this.summary;
    }
    if (this.symbolarr != null) {
      data['symbolarr'] = this.symbolarr;
    }

    if (journal != null) {
      data['journal'] = journal!.map((v) => v.toJson()).toList();
    }
    data['fullresponse'] = fullresponse;

    data['total_charges'] = this.totalCharges;
    return data;
  }
}

class TradeData {
  String? aDJUSTEDNETRATE;
  String? bAMT;
  String? bQTY;
  String? bRATE;
  String? cLOSINGPRICE;
  String? cOMPANYCODE;
  String? eXCHANGE;
  String? nETAMT;
  String? nETQTY;
  String? nRATE;
  String? sAMT;
  String? sCRIPNAME;
  String? sCRIPSYMBOL;
  String? sQTY;
  String? sRATE;
  String? tRADEDATE;
  String? updatedNETQTY;
  String? cfBuyAmt;
  String? cfBuyQty;
  String? cfSellAmt;
  String? cfSellQty;
  String? index;
  bool? last;
  String? realisedpnl;
  String? totalBuyQty;
  String? totalBuyRate;
  String? totalRealisedPnl;
  String? totalSellQty;
  String? totalSellRate;
  String? unrealisedpnl;
  String? oQTY;
  String? oRATE;

  TradeData(
      {this.aDJUSTEDNETRATE,
      this.bAMT,
      this.bQTY,
      this.bRATE,
      this.cLOSINGPRICE,
      this.cOMPANYCODE,
      this.eXCHANGE,
      this.nETAMT,
      this.nETQTY,
      this.nRATE,
      this.sAMT,
      this.sCRIPNAME,
      this.sCRIPSYMBOL,
      this.sQTY,
      this.sRATE,
      this.tRADEDATE,
      this.updatedNETQTY,
      this.cfBuyAmt,
      this.cfBuyQty,
      this.cfSellAmt,
      this.cfSellQty,
      this.index,
      this.last,
      this.realisedpnl,
      this.totalBuyQty,
      this.totalBuyRate,
      this.totalRealisedPnl,
      this.totalSellQty,
      this.totalSellRate,
      this.unrealisedpnl,
      this.oQTY,
      this.oRATE});

  TradeData.fromJson(Map<String, dynamic> json) {
    aDJUSTEDNETRATE = json['ADJUSTED_NETRATE'].toString();
    bAMT = json['BAMT'].toString();
    bQTY = json['BQTY'].toString();
    bRATE = json['BRATE'].toString();
    cLOSINGPRICE = json['CLOSING_PRICE'].toString();
    cOMPANYCODE = json['COMPANY_CODE'].toString();
    eXCHANGE = json['EXCHANGE'].toString();
    nETAMT = json['NETAMT'].toString();
    nETQTY = json['NETQTY'].toString();
    nRATE = json['NRATE'].toString();
    sAMT = json['SAMT'].toString();
    sCRIPNAME = json['SCRIP_NAME'].toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
    sQTY = json['SQTY'].toString();
    sRATE = json['SRATE'].toString();
    tRADEDATE = json['TRADE_DATE'].toString();
    updatedNETQTY = json['Updated_NETQTY'].toString();
    cfBuyAmt = json['cf_buy_amt'].toString();
    cfBuyQty = json['cf_buy_qty'].toString();
    cfSellAmt = json['cf_sell_amt'].toString();
    cfSellQty = json['cf_sell_qty'].toString();
    index = json['index'].toString();
    last = json['last'];
    realisedpnl = json['realisedpnl'].toString();
    totalBuyQty = json['total_buy_qty'].toString();
    totalBuyRate = json['total_buy_rate'].toString();
    totalRealisedPnl = json['total_realised_pnl'].toString();
    totalSellQty = json['total_sell_qty'].toString();
    totalSellRate = json['total_sell_rate'].toString();
    unrealisedpnl = json['unrealisedpnl'].toString();
    oQTY = json['Open_Qty'].toString();
    oRATE = json['Open_Rate'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ADJUSTED_NETRATE'] = aDJUSTEDNETRATE;
    data['BAMT'] = bAMT;
    data['BQTY'] = bQTY;
    data['BRATE'] = bRATE;
    data['CLOSING_PRICE'] = cLOSINGPRICE;
    data['COMPANY_CODE'] = cOMPANYCODE;
    data['EXCHANGE'] = eXCHANGE;
    data['NETAMT'] = nETAMT;
    data['NETQTY'] = nETQTY;
    data['NRATE'] = nRATE;
    data['SAMT'] = sAMT;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['SQTY'] = sQTY;
    data['SRATE'] = sRATE;
    data['TRADE_DATE'] = tRADEDATE;
    data['Updated_NETQTY'] = updatedNETQTY;
    data['cf_buy_amt'] = cfBuyAmt;
    data['cf_buy_qty'] = cfBuyQty;
    data['cf_sell_amt'] = cfSellAmt;
    data['cf_sell_qty'] = cfSellQty;
    data['index'] = index;
    data['last'] = last;
    data['realisedpnl'] = realisedpnl;
    data['total_buy_qty'] = totalBuyQty;
    data['total_buy_rate'] = totalBuyRate;
    data['total_realised_pnl'] = totalRealisedPnl;
    data['total_sell_qty'] = totalSellQty;
    data['total_sell_rate'] = totalSellRate;
    data['unrealisedpnl'] = unrealisedpnl;
    data['Open_Qty'] = oQTY;
    data['Open_Rate'] = oRATE;
    return data;
  }
}

class Journal {
  String? tRADEDATE;
  String? realisedpnl;
  String? totalBillNet;
  String? unrealisedpnl;

  Journal(
      {this.tRADEDATE,
      this.realisedpnl,
      this.totalBillNet,
      this.unrealisedpnl});

  Journal.fromJson(Map<String, dynamic> json) {
    tRADEDATE = json['TRADE_DATE'];
    realisedpnl = json['realisedpnl'].toString();
    totalBillNet = json['total_bill_net'].toString();
    unrealisedpnl = json['unrealisedpnl'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['TRADE_DATE'] = tRADEDATE;
    data['realisedpnl'] = realisedpnl;
    data['total_bill_net'] = totalBillNet;
    data['unrealisedpnl'] = unrealisedpnl;
    return data;
  }
}

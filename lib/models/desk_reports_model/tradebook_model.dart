class TradeBookModel {
  List<Trades>? trades;

  TradeBookModel({this.trades});

  TradeBookModel.fromJson(Map<String, dynamic> json) {
    if (json['trades'] != null) {
      trades = <Trades>[];
      json['trades'].forEach((v) {
        trades!.add(Trades.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (trades != null) {
      data['trades'] = trades!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void sort(int Function(dynamic a, dynamic b) param0) {}
}

class Trades {
  String? cLIENTCODE;
  String? sTRIKEPRICE;
  String? iSIN;
  String? uSERID;
  String? eXPIRYDATE;
  String? bUYQUANTITY;
  String? bUYPRICE;
  String? sELLQUANTITY;
  String? sELLPRICE;
  String? cOMPANYCODE;
  String? oRDERTIME;
  String? oRDERNUMBER;
  String? tRADETYPE;
  String? tRADENUMBER;
  String? tRADEDATE;
  String? tRADETIME;
  String? sCRIPNAME;
  String? sERIES;
  String? sCRIPSERIES;
  String? oPTIONTYPE;
  String? showtype;
  String? showprice;
  String? showqnt;
  String? showamt;
  String? showseries;

  Trades(
      {this.cLIENTCODE,
      this.sTRIKEPRICE,
      this.iSIN,
      this.uSERID,
      this.eXPIRYDATE,
      this.bUYQUANTITY,
      this.bUYPRICE,
      this.sELLQUANTITY,
      this.sELLPRICE,
      this.cOMPANYCODE,
      this.oRDERTIME,
      this.oRDERNUMBER,
      this.tRADETYPE,
      this.tRADENUMBER,
      this.tRADEDATE,
      this.tRADETIME,
      this.sCRIPNAME,
      this.sERIES,
      this.sCRIPSERIES,
      this.oPTIONTYPE,
      this.showtype,
      this.showprice,
      this.showqnt,
      this.showamt,
      this.showseries});

  Trades.fromJson(Map<String, dynamic> json) {
    cLIENTCODE = json['CLIENT_CODE'].toString();
    sTRIKEPRICE = json['STRIKE_PRICE'].toString();
    iSIN = json['ISIN'].toString();
    uSERID = json['USER_ID'].toString();
    eXPIRYDATE = json['EXPIRY_DATE'].toString();
    bUYQUANTITY = json['BUY_QUANTITY'].toString();
    bUYPRICE = json['BUY_PRICE'].toString();
    sELLQUANTITY = json['SELL_QUANTITY'].toString();
    sELLPRICE = json['SELL_PRICE'].toString();
    cOMPANYCODE = json['COMPANY_CODE'].toString();
    oRDERTIME = json['ORDER_TIME'].toString();
    oRDERNUMBER = json['ORDER_NUMBER'].toString();
    tRADETYPE = json['TRADE_TYPE'].toString();
    tRADENUMBER = json['TRADE_NUMBER'].toString();
    tRADEDATE = json['TRADE_DATE'].toString();
    tRADETIME = json['TRADE_TIME'].toString();
    sCRIPNAME = json['SCRIP_NAME'].toString();
    sERIES = json['SERIES'].toString();
    sCRIPSERIES = json['SCRIP_SERIES'].toString();
    oPTIONTYPE = json['OPTION_TYPE'].toString();
    showtype = json['showtype'].toString();
    showprice = json['showprice'].toString();
    showqnt = json['showqnt'].toString();
    showamt = json['showamt'].toString();
    showseries = json['showseries'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CLIENT_CODE'] = cLIENTCODE;
    data['STRIKE_PRICE'] = sTRIKEPRICE;
    data['ISIN'] = iSIN;
    data['USER_ID'] = uSERID;
    data['EXPIRY_DATE'] = eXPIRYDATE;
    data['BUY_QUANTITY'] = bUYQUANTITY;
    data['BUY_PRICE'] = bUYPRICE;
    data['SELL_QUANTITY'] = sELLQUANTITY;
    data['SELL_PRICE'] = sELLPRICE;
    data['COMPANY_CODE'] = cOMPANYCODE;
    data['ORDER_TIME'] = oRDERTIME;
    data['ORDER_NUMBER'] = oRDERNUMBER;
    data['TRADE_TYPE'] = tRADETYPE;
    data['TRADE_NUMBER'] = tRADENUMBER;
    data['TRADE_DATE'] = tRADEDATE;
    data['TRADE_TIME'] = tRADETIME;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['SERIES'] = sERIES;
    data['SCRIP_SERIES'] = sCRIPSERIES;
    data['OPTION_TYPE'] = oPTIONTYPE;
    data['showtype'] = showtype;
    data['showprice'] = showprice;
    data['showqnt'] = showqnt;
    data['showamt'] = showamt;
    data['showseries'] = showseries;
    return data;
  }
}

class TradeBookModel {
  List<Trades>? trades;

  TradeBookModel({this.trades});

  TradeBookModel.fromJson(Map<String, dynamic> json) {
    if (json['trades'] != null) {
      trades = <Trades>[];
      json['trades'].forEach((v) {
        trades!.add(new Trades.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trades != null) {
      data['trades'] = this.trades!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CLIENT_CODE'] = this.cLIENTCODE;
    data['STRIKE_PRICE'] = this.sTRIKEPRICE;
    data['ISIN'] = this.iSIN;
    data['USER_ID'] = this.uSERID;
    data['EXPIRY_DATE'] = this.eXPIRYDATE;
    data['BUY_QUANTITY'] = this.bUYQUANTITY;
    data['BUY_PRICE'] = this.bUYPRICE;
    data['SELL_QUANTITY'] = this.sELLQUANTITY;
    data['SELL_PRICE'] = this.sELLPRICE;
    data['COMPANY_CODE'] = this.cOMPANYCODE;
    data['ORDER_TIME'] = this.oRDERTIME;
    data['ORDER_NUMBER'] = this.oRDERNUMBER;
    data['TRADE_TYPE'] = this.tRADETYPE;
    data['TRADE_NUMBER'] = this.tRADENUMBER;
    data['TRADE_DATE'] = this.tRADEDATE;
    data['TRADE_TIME'] = this.tRADETIME;
    data['SCRIP_NAME'] = this.sCRIPNAME;
    data['SERIES'] = this.sERIES;
    data['SCRIP_SERIES'] = this.sCRIPSERIES;
    data['OPTION_TYPE'] = this.oPTIONTYPE;
    data['showtype'] = this.showtype;
    data['showprice'] = this.showprice;
    data['showqnt'] = this.showqnt;
    data['showamt'] = this.showamt;
    data['showseries'] = this.showseries;
    return data;
  }
}

class PnlSegCharge {
  String? expenseAmt;
  List<Expenses>? expenses;

  PnlSegCharge({this.expenseAmt, this.expenses});

  PnlSegCharge.fromJson(Map<String, dynamic> json) {
    expenseAmt = json['expense_amt'].toString();
    if (json['expenses'] != null) {
      expenses = <Expenses>[];
      json['expenses'].forEach((v) {
        expenses!.add(Expenses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expense_amt'] = expenseAmt;
    if (expenses != null) {
      data['expenses'] = expenses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Expenses {
  String? bUYAMOUNT;
  String? bUYQUANTITY;
  String? bUYRATE;
  String? cLIENTID;
  String? cLOSINGAMT;
  String? cLOSINGPRICE;
  String? nETAMOUNT;
  String? nETQUANTITY;
  String? nETRATE;
  String? nOTPROFIT;
  String? openAMOUNT;
  String? sALEAMOUNT;
  String? sALEQUANTITY;
  String? sALERATE;
  String? sCRIPSYMBOL;
  String? scripName1;
  String? sr;
  String? companyCode;
  String? openQUANTITY;

  Expenses(
      {this.bUYAMOUNT,
      this.bUYQUANTITY,
      this.bUYRATE,
      this.cLIENTID,
      this.cLOSINGAMT,
      this.cLOSINGPRICE,
      this.nETAMOUNT,
      this.nETQUANTITY,
      this.nETRATE,
      this.nOTPROFIT,
      this.openAMOUNT,
      this.sALEAMOUNT,
      this.sALEQUANTITY,
      this.sALERATE,
      this.sCRIPSYMBOL,
      this.scripName1,
      this.sr,
      this.companyCode,
      this.openQUANTITY});

  Expenses.fromJson(Map<String, dynamic> json) {
    bUYAMOUNT = json['BUY_AMOUNT'].toString();
    bUYQUANTITY = json['BUY_QUANTITY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
    cLOSINGAMT = json['CLOSING_AMT'].toString();
    cLOSINGPRICE = json['CLOSING_PRICE'].toString();
    nETAMOUNT = json['NET_AMOUNT'].toString();
    nETQUANTITY = json['NET_QUANTITY'].toString();
    nETRATE = json['NET_RATE'].toString();
    nOTPROFIT = json['NOT_PROFIT'].toString();
    openAMOUNT = json['Open_AMOUNT'].toString();
    sALEAMOUNT = json['SALE_AMOUNT'].toString();
    sALEQUANTITY = json['SALE_QUANTITY'].toString();
    sALERATE = json['SALE_RATE'].toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'].toString();
    scripName1 = json['Scrip_Name1'].toString();
    sr = json['Sr'].toString();
    companyCode = json['company_code'].toString();
    openQUANTITY = json['open_QUANTITY'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BUY_AMOUNT'] = bUYAMOUNT;
    data['BUY_QUANTITY'] = bUYQUANTITY;
    data['BUY_RATE'] = bUYRATE;
    data['CLIENT_ID'] = cLIENTID;
    data['CLOSING_AMT'] = cLOSINGAMT;
    data['CLOSING_PRICE'] = cLOSINGPRICE;
    data['NET_AMOUNT'] = nETAMOUNT;
    data['NET_QUANTITY'] = nETQUANTITY;
    data['NET_RATE'] = nETRATE;
    data['NOT_PROFIT'] = nOTPROFIT;
    data['Open_AMOUNT'] = openAMOUNT;
    data['SALE_AMOUNT'] = sALEAMOUNT;
    data['SALE_QUANTITY'] = sALEQUANTITY;
    data['SALE_RATE'] = sALERATE;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['Scrip_Name1'] = scripName1;
    data['Sr'] = sr;
    data['company_code'] = companyCode;
    data['open_QUANTITY'] = openQUANTITY;
    return data;
  }
}

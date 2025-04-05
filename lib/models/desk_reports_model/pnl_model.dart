class PnlModel {
  String? expenseAmt;
  List<Expenses>? expenses;
  String? netPnl;
  List<Transactions>? transactions;

  PnlModel({this.expenseAmt, this.expenses, this.netPnl, this.transactions});

  PnlModel.fromJson(Map<String, dynamic> json) {
    expenseAmt = json['expense_amt'].toString();
    if (json['expenses'] != null) {
      expenses = <Expenses>[];
      json['expenses'].forEach((v) {
        expenses!.add(Expenses.fromJson(v));
      });
    }
    netPnl = json['net_pnl'].toString();
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['expense_amt'] = expenseAmt;
    if (expenses != null) {
      data['expenses'] = expenses!.map((v) => v.toJson()).toList();
    }
    data['net_pnl'] = netPnl;
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Expenses {
  String? bUYAMOUNT;
  String? bUYQUANTITY;
  String? bUYRATE;
  String? cLIENTID;
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
  String? sr;
  String? companyCode;
  String? openQUANTITY;

  Expenses(
      {this.bUYAMOUNT,
      this.bUYQUANTITY,
      this.bUYRATE,
      this.cLIENTID,
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
      this.sr,
      this.companyCode,
      this.openQUANTITY});

  Expenses.fromJson(Map<String, dynamic> json) {
    bUYAMOUNT = json['BUY_AMOUNT'].toString();
    bUYQUANTITY = json['BUY_QUANTITY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
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
    sr = json['Sr'].toString();
    companyCode = json['company_code'].toString();
    openQUANTITY = json['open_QUANTITY'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['BUY_AMOUNT'] = bUYAMOUNT;
    data['BUY_QUANTITY'] = bUYQUANTITY;
    data['BUY_RATE'] = bUYRATE;
    data['CLIENT_ID'] = cLIENTID;
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
    data['Sr'] = sr;
    data['company_code'] = companyCode;
    data['open_QUANTITY'] = openQUANTITY;
    return data;
  }
}

class Transactions {
  String? bUYAMOUNT;
  String? bUYQUANTITY;
  String? bUYRATE;
  String? cLIENTID;
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
  String? sortNo;
  String? sr;
  String? companyCode;
  String? openQUANTITY;

  Transactions(
      {this.bUYAMOUNT,
      this.bUYQUANTITY,
      this.bUYRATE,
      this.cLIENTID,
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
      this.sortNo,
      this.sr,
      this.companyCode,
      this.openQUANTITY});

  Transactions.fromJson(Map<String, dynamic> json) {
    bUYAMOUNT = json['BUY_AMOUNT'].toString();
    bUYQUANTITY = json['BUY_QUANTITY'].toString();
    bUYRATE = json['BUY_RATE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
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
    sortNo = json['Sort_No'].toString();
    sr = json['Sr'].toString();
    companyCode = json['company_code'].toString();
    openQUANTITY = json['open_QUANTITY'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['BUY_AMOUNT'] = bUYAMOUNT;
    data['BUY_QUANTITY'] = bUYQUANTITY;
    data['BUY_RATE'] = bUYRATE;
    data['CLIENT_ID'] = cLIENTID;
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
    data['Sort_No'] = sortNo;
    data['Sr'] = sr;
    data['company_code'] = companyCode;
    data['open_QUANTITY'] = openQUANTITY;
    return data;
  }
}

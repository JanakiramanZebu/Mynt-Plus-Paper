class LedgerBillModel {
  List<Expenses>? expenses;
  List<Transactions>? transactions;

  LedgerBillModel({this.expenses, this.transactions});

  LedgerBillModel.fromJson(Map<String, dynamic> json) {
    if (json['Expenses'] != null) {
      expenses = <Expenses>[];
      json['Expenses'].forEach((v) {
        expenses!.add(Expenses.fromJson(v));
      });
    }
    if (json['Transactions'] != null) {
      transactions = <Transactions>[];
      json['Transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (expenses != null) {
      data['Expenses'] = expenses!.map((v) => v.toJson()).toList();
    }
    if (transactions != null) {
      data['Transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Expenses {
  String? bAMT;
  String? bILLNO;
  String? bQTY;
  String? bRATE;
  String? bRATEA;
  String? nETAMT;
  String? nETQTY;
  String? nETRATE;
  String? nETRATEA;
  String? sAMT;
  String? sCRIPBRK;
  String? sCRIPBRK1;
  String? sCRIPBRK2;
  String? sCRIPBRKd;
  String? sCRIPNAME;
  String? sCRIPSYMBOL;
  String? sQTY;
  String? sRATE;
  String? sRATEA;
  String? sYMBOL;

  Expenses(
      {this.bAMT,
      this.bILLNO,
      this.bQTY,
      this.bRATE,
      this.bRATEA,
      this.nETAMT,
      this.nETQTY,
      this.nETRATE,
      this.nETRATEA,
      this.sAMT,
      this.sCRIPBRK,
      this.sCRIPBRK1,
      this.sCRIPBRK2,
      this.sCRIPBRKd,
      this.sCRIPNAME,
      this.sCRIPSYMBOL,
      this.sQTY,
      this.sRATE,
      this.sRATEA,
      this.sYMBOL});

  Expenses.fromJson(Map<String, dynamic> json) {
    bAMT = json['BAMT'].toString();
    bILLNO = json['BILL_NO'];
    bQTY = json['BQTY'].toString();
    bRATE = json['BRATE'].toString();
    bRATEA = json['BRATE_A'];
    nETAMT = json['NETAMT'].toString();
    nETQTY = json['NETQTY'].toString();
    nETRATE = json['NETRATE'].toString();
    nETRATEA = json['NETRATE_A'];
    sAMT = json['SAMT'].toString();
    sCRIPBRK = json['SCRIPBRK'];
    sCRIPBRK1 = json['SCRIPBRK1'];
    sCRIPBRK2 = json['SCRIPBRK2'];
    sCRIPBRKd = json['SCRIPBRKd'];
    sCRIPNAME = json['SCRIP_NAME'];
    sCRIPSYMBOL = json['SCRIP_SYMBOL'];
    sQTY = json['SQTY'].toString();
    sRATE = json['SRATE'].toString();
    sRATEA = json['SRATE_A'];
    sYMBOL = json['SYMBOL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BAMT'] = bAMT;
    data['BILL_NO'] = bILLNO;
    data['BQTY'] = bQTY;
    data['BRATE'] = bRATE;
    data['BRATE_A'] = bRATEA;
    data['NETAMT'] = nETAMT;
    data['NETQTY'] = nETQTY;
    data['NETRATE'] = nETRATE;
    data['NETRATE_A'] = nETRATEA;
    data['SAMT'] = sAMT;
    data['SCRIPBRK'] = sCRIPBRK;
    data['SCRIPBRK1'] = sCRIPBRK1;
    data['SCRIPBRK2'] = sCRIPBRK2;
    data['SCRIPBRKd'] = sCRIPBRKd;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['SQTY'] = sQTY;
    data['SRATE'] = sRATE;
    data['SRATE_A'] = sRATEA;
    data['SYMBOL'] = sYMBOL;
    return data;
  }
}

class Transactions {
  String? bAMT;
  String? bILLNO;
  String? bQTY;
  String? bRATE;
  String? bRATEA;
  String? nETAMT;
  String? nETQTY;
  String? nETRATE;
  String? nETRATEA;
  String? sAMT;
  String? sCRIPBRK;
  String? sCRIPBRK1;
  String? sCRIPBRK2;
  String? sCRIPBRKd;
  String? sCRIPNAME;
  String? sCRIPSYMBOL;
  String? sQTY;
  String? sRATE;
  String? sRATEA;
  String? sYMBOL;

  Transactions(
      {this.bAMT,
      this.bILLNO,
      this.bQTY,
      this.bRATE,
      this.bRATEA,
      this.nETAMT,
      this.nETQTY,
      this.nETRATE,
      this.nETRATEA,
      this.sAMT,
      this.sCRIPBRK,
      this.sCRIPBRK1,
      this.sCRIPBRK2,
      this.sCRIPBRKd,
      this.sCRIPNAME,
      this.sCRIPSYMBOL,
      this.sQTY,
      this.sRATE,
      this.sRATEA,
      this.sYMBOL});

  Transactions.fromJson(Map<String, dynamic> json) {
    bAMT = json['BAMT'].toString();
    bILLNO = json['BILL_NO'];
    bQTY = json['BQTY'].toString();
    bRATE = json['BRATE'].toString();
    bRATEA = json['BRATE_A'];
    nETAMT = json['NETAMT'].toString();
    nETQTY = json['NETQTY'].toString();
    nETRATE = json['NETRATE'].toString();
    nETRATEA = json['NETRATE_A'];
    sAMT = json['SAMT'].toString();
    sCRIPBRK = json['SCRIPBRK'];
    sCRIPBRK1 = json['SCRIPBRK1'];
    sCRIPBRK2 = json['SCRIPBRK2'];
    sCRIPBRKd = json['SCRIPBRKd'];
    sCRIPNAME = json['SCRIP_NAME'];
    sCRIPSYMBOL = json['SCRIP_SYMBOL'];
    sQTY = json['SQTY'].toString();
    sRATE = json['SRATE'].toString();
    sRATEA = json['SRATE_A'];
    sYMBOL = json['SYMBOL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BAMT'] = bAMT;
    data['BILL_NO'] = bILLNO;
    data['BQTY'] = bQTY;
    data['BRATE'] = bRATE;
    data['BRATE_A'] = bRATEA;
    data['NETAMT'] = nETAMT;
    data['NETQTY'] = nETQTY;
    data['NETRATE'] = nETRATE;
    data['NETRATE_A'] = nETRATEA;
    data['SAMT'] = sAMT;
    data['SCRIPBRK'] = sCRIPBRK;
    data['SCRIPBRK1'] = sCRIPBRK1;
    data['SCRIPBRK2'] = sCRIPBRK2;
    data['SCRIPBRKd'] = sCRIPBRKd;
    data['SCRIP_NAME'] = sCRIPNAME;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    data['SQTY'] = sQTY;
    data['SRATE'] = sRATE;
    data['SRATE_A'] = sRATEA;
    data['SYMBOL'] = sYMBOL;
    return data;
  }
}

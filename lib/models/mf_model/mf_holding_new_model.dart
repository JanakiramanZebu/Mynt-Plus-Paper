class mf_holdoing_new {
  List<Data>? data;
  Summary? summary;
  String? stat;

  mf_holdoing_new({this.data, this.summary, this.stat});

  mf_holdoing_new.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    summary =
        json['summary'] != null ? new Summary.fromJson(json['summary']) : null;
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.summary != null) {
      data['summary'] = this.summary!.toJson();
    }
    data['stat'] = this.stat;
    return data;
  }
}

class Data {
  String? clientCode;
  String? name;
  String? foliono;
  String? iSIN;
  String? stampduty;
  String? stt;
  String? avgQty;
  String? avgNav;
  String? curNav;
  String? investedValue;
  String? currentValue;
  String? profitLoss;
  String? changeprofitLoss;
  String? minRedemptionQty;
  String? sCHEMECODE; 
  List<Transactions>? transactions;

  Data(
      {this.clientCode,
      this.name,
      this.foliono,
      this.iSIN,
      this.stampduty,
      this.stt,
      this.avgQty,
      this.avgNav,
      this.curNav,
      this.investedValue,
      this.currentValue,
      this.changeprofitLoss,
      this.profitLoss,
      this.transactions});

  Data.fromJson(Map<String, dynamic> json) {
    clientCode = json['ClientCode'].toString();
    changeprofitLoss = json['changeprofitloss'].toString(); 
    name = json['name'].toString();
    foliono = json['foliono'].toString();
    iSIN = json['ISIN'].toString();
    stampduty = json['stampduty'].toString();
    stt = json['stt'].toString();
    avgQty = json['avg_qty'].toString();
    avgNav = json['avg_nav'].toString();
    curNav = json['Cur_Nav'].toString();
    investedValue = json['invested_value'].toString();
    currentValue = json['current_value'].toString();
    profitLoss = json['profit_loss'].toString();
    sCHEMECODE= json["Scheme_Code"].toString();

    minRedemptionQty=json["Minimum_Redemption_Qty"].toString();
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(new Transactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientCode'] = this.clientCode;
    data['name'] = this.name;
    data['foliono'] = this.foliono;
    data['ISIN'] = this.iSIN;
    data['stampduty'] = this.stampduty;
    data['stt'] = this.stt;
    data['avg_qty'] = this.avgQty;
    data['avg_nav'] = this.avgNav;
    data['Cur_Nav'] = this.curNav;
    data['invested_value'] = this.investedValue;
    data['current_value'] = this.currentValue;
    data['profit_loss'] = this.profitLoss;
    data['Minimum_Redemption_Qty'] = this.minRedemptionQty;
    data['Scheme_Code'] = this.sCHEMECODE;
    data['changeprofitLoss'] = this.changeprofitLoss;
    
    
 
    if (this.transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  String? txnDate;
  String? txnType;
  String? txnNo;
  String? seqNo;
  String? arnNo;
  String? units;
  String? avgNav;
  String? invAmount;
  String? stampDuty;
  String? sTT;
  String? pR;
  String? purRed;

  Transactions(
      {this.txnDate,
      this.txnType,
      this.txnNo,
      this.seqNo,
      this.arnNo,
      this.units,
      this.avgNav,
      this.invAmount,
      this.stampDuty,
      this.sTT,
      this.pR,
      this.purRed});

  Transactions.fromJson(Map<String, dynamic> json) {
    txnDate = json['TxnDate'].toString();
    txnType = json['txnType'].toString();
    txnNo = json['txnNo'].toString();
    seqNo = json['seqNo'].toString();
    arnNo = json['arnNo'].toString();
    units = json['units'].toString();
    avgNav = json['avg_nav'].toString();
    invAmount = json['Inv_amount'].toString();
    stampDuty = json['stampDuty'].toString();
    sTT = json['STT'].toString();
    pR = json['PR'].toString();
    purRed = json['pur_red'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TxnDate'] = this.txnDate;
    data['txnType'] = this.txnType;
    data['txnNo'] = this.txnNo;
    data['seqNo'] = this.seqNo;
    data['arnNo'] = this.arnNo;
    data['units'] = this.units;
    data['avg_nav'] = this.avgNav;
    data['Inv_amount'] = this.invAmount;
    data['stampDuty'] = this.stampDuty;
    data['STT'] = this.sTT;
    data['PR'] = this.pR;
    data['pur_red'] = this.purRed;
    return data;
  }
}

class Summary {
  String? invested;
  String? currentValue;
  String? absReturnValue;
  String? absReturnPercent;

  Summary(
      {this.invested,
      this.currentValue,
      this.absReturnValue,
      this.absReturnPercent});

  Summary.fromJson(Map<String, dynamic> json) {
    invested = json['invested'].toString();
    currentValue = json['current_value'].toString();
    absReturnValue = json['abs_return_value'].toString();
    absReturnPercent = json['abs_return_percent'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invested'] = this.invested;
    data['current_value'] = this.currentValue;
    data['abs_return_value'] = this.absReturnValue;
    data['abs_return_percent'] = this.absReturnPercent;
    return data;
  }
}

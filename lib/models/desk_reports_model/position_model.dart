class PositionModel {
  List<Data>? data;

  PositionModel({this.data});

  PositionModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? buyPrice;
  String? buyQuantity;
  String? buypricemtm;
  String? buyValue;
  String? buyvaluemtm;
  String? netAvgPrc;
  String? netavgpricemtm;
  String? sellPrice;
  String? sellPricemtm;
  String? sellQuantity;
  String? sellValue;
  String? sellValuemtm;
  String? exch;
  String? ltp;
  String? netqty;
  String? netqtymtm;
  String? rpnl;
  String? rmtm;
  String? token;
  String? tsym;

  Data(
      {this.buyPrice,
      this.buyQuantity,
      this.buypricemtm,
      this.buyValue,
      this.buyvaluemtm,
      this.netAvgPrc,
      this.netavgpricemtm,
      this.sellPrice,
      this.sellPricemtm,
      this.sellQuantity,
      this.sellValue,
      this.sellValuemtm,
      this.exch,
      this.ltp,
      this.netqty,
      this.netqtymtm,
      this.rpnl,
      this.token,
      this.tsym});

  Data.fromJson(Map<String, dynamic> json) {
    buyPrice = json['BuyPrice'].toString();
    buyQuantity = json['BuyQuantity'].toString();
    buypricemtm = json['BuyPriceMTM'].toString();
    buyValue = json['BuyValue'].toString();
    buyvaluemtm = json['BuyValueMTM'].toString();
    netAvgPrc = json['NetAvgPrc'].toString();
    netavgpricemtm = json['NetAvgPrcMTM'].toString();
    sellPrice = json['SellPriceMTM'].toString();
    sellPricemtm = json['SellPrice'].toString();
    sellQuantity = json['SellQuantity'].toString();
    sellValue = json['SellValue'].toString();
    sellValuemtm = json['SellValueMTM'].toString();
    exch = json['exch'].toString();
    ltp = json['ltp'].toString();
    netqty = json['netqty'].toString();
    netqtymtm = json['netqtyMTM'].toString();
    rpnl = json['rpnl'].toString();
    rmtm = json['rmtm'].toString();
    token = json['token'].toString();
    tsym = json['tsym'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['BuyPrice'] = buyPrice;
    data['BuyQuantity'] = buyQuantity;
    data['BuyPriceMTM'] = buypricemtm;
    data['BuyValue'] = buyValue;
    data['BuyValueMTM'] = buyvaluemtm;
    data['NetAvgPrc'] = netAvgPrc;
    data['NetAvgPrcMTM'] = netavgpricemtm;
    data['SellPrice'] = sellPrice;
    data['SellPriceMTM'] = sellPricemtm;
    data['SellQuantity'] = sellQuantity;
    data['SellValue'] = sellValue;
    data['SellValueMTM'] = sellValuemtm;
    data['exch'] = exch;
    data['ltp'] = ltp;
    data['netqty'] = netqty;
    data['netqtyMTM'] = netqtymtm;
    data['rpnl'] = rpnl;
    data['rmtm'] = rmtm;
    data['token'] = token;
    data['tsym'] = tsym;
    return data;
  }
}

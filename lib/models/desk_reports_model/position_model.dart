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
  String? buyValue;
  String? netAvgPrc;
  String? sellPrice;
  String? sellQuantity;
  String? sellValue;
  String? exch;
  String? ltp;
  String? netqty;
  String? rpnl;
  String? token;
  String? tsym;

  Data(
      {this.buyPrice,
      this.buyQuantity,
      this.buyValue,
      this.netAvgPrc,
      this.sellPrice,
      this.sellQuantity,
      this.sellValue,
      this.exch,
      this.ltp,
      this.netqty,
      this.rpnl,
      this.token,
      this.tsym});

  Data.fromJson(Map<String, dynamic> json) {
    buyPrice = json['BuyPrice'].toString();
    buyQuantity = json['BuyQuantity'].toString();
    buyValue = json['BuyValue'].toString();
    netAvgPrc = json['NetAvgPrc'].toString();
    sellPrice = json['SellPrice'].toString();
    sellQuantity = json['SellQuantity'].toString();
    sellValue = json['SellValue'].toString();
    exch = json['exch'].toString();
    ltp = json['ltp'].toString();
    netqty = json['netqty'].toString();
    rpnl = json['rpnl'].toString();
    token = json['token'].toString();
    tsym = json['tsym'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['BuyPrice'] = buyPrice;
    data['BuyQuantity'] = buyQuantity;
    data['BuyValue'] = buyValue;
    data['NetAvgPrc'] = netAvgPrc;
    data['SellPrice'] = sellPrice;
    data['SellQuantity'] = sellQuantity;
    data['SellValue'] = sellValue;
    data['exch'] = exch;
    data['ltp'] = ltp;
    data['netqty'] = netqty;
    data['rpnl'] = rpnl;
    data['token'] = token;
    data['tsym'] = tsym;
    return data;
  }
}
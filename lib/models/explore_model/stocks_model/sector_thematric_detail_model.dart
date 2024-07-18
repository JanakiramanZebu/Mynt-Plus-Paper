class SectorThematicDetailModel {
  String? companyName;
  String? industry;
  String? sYMBOL;
  String? token;
  String? change;
  String? close;
  String? high;
  String? low;
   String? perChng;
  String? ltp;
    String? marketCap;

  SectorThematicDetailModel(
      {this.companyName,
      this.industry,
      this.sYMBOL,
      this.token,
      this.change,
      this.close,
      this.high,
      this.low,
      this.ltp,
      this.marketCap,this.perChng});

  SectorThematicDetailModel.fromJson(Map<String, dynamic> json) {
    companyName = json['Company Name'].toString();
    industry = json['Industry'].toString();
    sYMBOL = json['SYMBOL'].toString();
    token = json['Token'].toString();
    change = json['change'].toString();
    close = json['close'].toString();
    high = json['high'].toString();
    low = json['low'].toString();
    ltp = json['ltp'].toString();
    marketCap = json['market_cap'].toString();
    perChng=json['perChng'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Company Name'] = companyName;
    data['Industry'] = industry;
    data['SYMBOL'] = sYMBOL;
    data['Token'] = token;
    data['change'] = change;
    data['close'] = close;
    data['high'] = high;
    data['low'] = low;
    data['ltp'] = ltp;
    data['market_cap'] = marketCap;
    data['perChng']=perChng;
    return data;
  }
}

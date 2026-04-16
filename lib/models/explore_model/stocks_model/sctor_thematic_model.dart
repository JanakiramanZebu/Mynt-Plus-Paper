class SectorThemeaticModel {
  String? secName;
  String? name;
  String? secCount;
  String? ltp;
  String? chng;
  String? perChng;
  String? negative;
  String? poistive;
  String? token;
  String? nutral;
  String? marketCap;
  String? close;
  SectorThemeaticModel(
      {this.secName,
      this.name,
      this.secCount,
      this.ltp,
      this.chng,
      this.perChng,
      this.negative,
      this.poistive,
      this.close,
      this.token,
      this.nutral,
      this.marketCap});

  SectorThemeaticModel.fromJson(Map<String, dynamic> json) {
    secName = json['secName'].toString();
    name = json['name'].toString();
    secCount = json['secCount'].toString();
    ltp = json['ltp'].toString();
    chng = json['chng'].toString();
    perChng = json['perChng'].toString();
    negative = json['negative'].toString();
    poistive = json['poistive'].toString();
    token = json['token'].toString();
    nutral = json['Neutral'].toString();
    marketCap = json["marketCap"].toString();
    close = json['close'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['secName'] = secName;
    data['name'] = name;
    data['secCount'] = secCount;
    data['ltp'] = ltp;
    data['chng'] = chng;
    data['perChng'] = perChng;
    data['negative'] = negative;
    data['poistive'] = poistive;
    data['token'] = token;
    data['Neutral'] = nutral;
    data['marketCap'] = marketCap;
    data['close'] = close;
    return data;
  }
}

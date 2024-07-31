class ActionTradeModel {
  String? tsym;
  String? ltp;
  String? token;
  String? change;
  String? perChange;
  String? open;
  String? high;
  String? close;
  String? low;
  String? volume;

  ActionTradeModel(
      {this.tsym,
      this.ltp,
      this.token,
      this.change,
      this.perChange,
      this.open,
      this.high,
      this.close,
      this.low,
      this.volume});

  ActionTradeModel.fromJson(Map<String, dynamic> json) {
    tsym = json['tsym'];
    ltp = json['ltp'];
    token = json['token'];
    change = json['change'];
    perChange = json['perChange'];
    open = json['open'];
    high = json['high'];
    close = json['close'];
    low = json['low'];
    volume = json['volume'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tsym'] = tsym;
    data['ltp'] = ltp;
    data['token'] = token;
    data['change'] = change;
    data['perChange'] = perChange;
    data['open'] = open;
    data['high'] = high;
    data['close'] = close;
    data['low'] = low;
    data['volume'] = volume;
    return data;
  }
}

class TopIndicesModel {
  String? exchange;
  String? change;
  String? close;
  String? high;
  String? idxname;
  String? low;
  String? lp;
  String? open;
  String? requestTime;
  int? sort;
  String? token;
  String? vol;
  String? perChange;
  TopIndicesModel(
      {this.exchange,
      this.change,
      this.close,
      this.high,
      this.idxname,
      this.low,
      this.lp,
      this.open,
      this.requestTime,
      this.sort,
      this.token,
      this.vol,
      this.perChange});

  TopIndicesModel.fromJson(Map<String, dynamic> json) {
    exchange = json['Exchange'];
    change = json['change'];
    close = json['close'];
    high = json['high'];
    idxname = json['idxname'];
    low = json['low'];
    lp = json['lp'];
    open = json['open'];
    requestTime = json['request_time'];
    sort = json['sort'];
    token = json['token'];
    vol = json['vol'];
    perChange = json['perChange'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Exchange'] = exchange;
    data['change'] = change;
    data['close'] = close;
    data['high'] = high;
    data['idxname'] = idxname;
    data['low'] = low;
    data['lp'] = lp;
    data['open'] = open;
    data['request_time'] = requestTime;
    data['sort'] = sort;
    data['token'] = token;
    data['perChange'] = perChange;
    data['vol'] = vol;

    return data;
  }
}

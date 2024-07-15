class MarketWatchlist {
  String? requestTime;
  String? stat;
  List<String>? values;
  String? emsg;
  MarketWatchlist({this.requestTime, this.stat, this.values, this.emsg});

  MarketWatchlist.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'].toString();
    stat = json['stat'].toString();
    values = json['values'] == null ? [] : json['values'].cast<String>();
    emsg = json['emsg'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['values'] = values;
    data['emsg'] = emsg;
    return data;
  }
}

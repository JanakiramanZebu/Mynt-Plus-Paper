class WatchlistRenameModel {
  String? requestTime;
  String? emsg;
  String? stat;

  WatchlistRenameModel({this.requestTime, this.emsg, this.stat});

  WatchlistRenameModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    emsg = json['emsg'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['emsg'] = emsg;
    data['stat'] = stat;
    return data;
  }
}
class AddDeleteScripModel {
  String? requestTime;
  String? stat;
  String? emsg;
  AddDeleteScripModel({this.requestTime, this.stat});

  AddDeleteScripModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class IndexListModel {
  String? requestTime;
  List<IndexValue>? indValues;
  String? emsg;
  String? stat;

  IndexListModel({this.requestTime, this.indValues, this.emsg, this.stat});

  IndexListModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    if (json['values'] != null) {
      indValues = <IndexValue>[];
      json['values'].forEach((v) {
        indValues!.add(IndexValue.fromJson(v));
      });
    }
    emsg = json['emsg'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    if (indValues != null) {
      data['values'] = indValues!.map((v) => v.toJson()).toList();
    }
    data['emsg'] = emsg;
    data['stat'] = stat;
    return data;
  }
}

class IndexValue {
  String? idxname;
  String? token;
  String? high;
  String? low;
  String? close;
  String? ltp;
  String? change;
  String? exch;
  String? perChange;
  String? open;
  IndexValue({
    this.idxname,
    this.token,
    this.high,
    this.low,
    this.close,
    this.ltp,
    this.change,
    this.exch,
    this.perChange,
    this.open,
  });

  IndexValue.fromJson(Map<String, dynamic> json) {
    idxname = json['idxname'];
    token = json['token'];
    exch = json['exch'].toString();
    high = json['high'].toString();
    low = json['low'] ;
    close = json['close'] ;
    ltp = json['ltp'] ;
    change = json['Change'].toString();
    perChange = json['PerChange'].toString();
    open = json['open'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idxname'] = idxname;
    data['token'] = token;
    data['exch'] = exch;
    data['high'] = high;
    data['low'] = low;
    data['close'] = close;
    data['ltp'] = ltp;
    data['Change'] = change;
    data['token'] = token;
    data['PerChange'] = perChange;
    data['open'] = open;
    return data;
  }

 
}

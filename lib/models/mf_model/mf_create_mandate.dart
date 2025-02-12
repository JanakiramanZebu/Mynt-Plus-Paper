class MfCreateMandateModel {
  String? mandate;
  String? resp;
  String? resp2;
  String? stat;
  String? url1;
  String? error;

  MfCreateMandateModel(
      {this.mandate, this.resp, this.resp2, this.stat, this.url1, this.error});

  MfCreateMandateModel.fromJson(Map<String, dynamic> json) {
    mandate = json['mandate'];
    resp = json['resp'];
    resp2 = json['resp2'];
    stat = json['stat'];
    url1 = json['url1'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mandate'] = mandate;
    data['resp'] = resp;
    data['resp2'] = resp2;
    data['stat'] = stat;
    data['url1'] = url1;
    data['error'] = error;
    return data;
  }
}

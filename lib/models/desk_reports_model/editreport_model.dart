class EdisReportModel {
  List<Data>? data;

  EdisReportModel({this.data});

  EdisReportModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? isin;
  String? qty;

  Data({this.isin, this.qty});

  Data.fromJson(Map<String, dynamic> json) {
    isin = json['isin'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isin'] = isin;
    data['qty'] = qty;
    return data;
  }
}

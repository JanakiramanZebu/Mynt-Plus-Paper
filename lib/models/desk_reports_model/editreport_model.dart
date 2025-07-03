class EdisReportModel {
  List<Data>? data;

  EdisReportModel({this.data});

  EdisReportModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isin'] = this.isin;
    data['qty'] = this.qty;
    return data;
  }
}

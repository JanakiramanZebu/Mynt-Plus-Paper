class MFFactSheetGraph {
  List<SheetGraphData>? data;
  String? stat;

  MFFactSheetGraph({this.data, this.stat});

  MFFactSheetGraph.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SheetGraphData>[];
      json['data'].forEach((v) {
        data!.add(SheetGraphData.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class SheetGraphData {
  String? s0ISIN;
  String? d0amount;
  String? s0schemeName;
  String? d0units;
  String? s1ISIN;
  String? d1amount;
  String? s1schemeName;
  String? d1units;
  String? iSIN;
  String? benchmarkReturns;
  String? navDate;
  String? schReturns;

  SheetGraphData(
      {this.s0ISIN,
      this.d0amount,
      this.s0schemeName,
      this.d0units,
      this.s1ISIN,
      this.d1amount,
      this.s1schemeName,
      this.d1units,
      this.iSIN,
      this.benchmarkReturns,
      this.navDate,
      this.schReturns});

  SheetGraphData.fromJson(Map<String, dynamic> json) {
    s0ISIN = json['0ISIN'].toString();
    d0amount = json['0amount'].toString();
    s0schemeName = json['0schemeName'].toString();
    d0units = json['0units'].toString();
    s1ISIN = json['1ISIN'].toString();
    d1amount = json['1amount'].toString();
    s1schemeName = json['1schemeName'].toString();
    d1units = json['1units'].toString();
    iSIN = json['ISIN'].toString();
    benchmarkReturns = json['benchmarkReturns'].toString();
    navDate = json['navDate'].toString();
    schReturns = json['schReturns'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['0ISIN'] = s0ISIN;
    data['0amount'] = d0amount;
    data['0schemeName'] = s0schemeName;
    data['0units'] = d0units;
    data['1ISIN'] = s1ISIN;
    data['1amount'] = d1amount;
    data['1schemeName'] = s1schemeName;
    data['1units'] = d1units;
    data['ISIN'] = iSIN;
    data['benchmarkReturns'] = benchmarkReturns;
    data['navDate'] = navDate;
    data['schReturns'] = schReturns;
    return data;
  }
}

class MFPostRollingReturn {
  List<ReturnData>? returnData;
  String? stat;

  MFPostRollingReturn({this.returnData, this.stat});

  MFPostRollingReturn.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
     returnData = <ReturnData>[];
      json['data'].forEach((v) {
       returnData!.add(ReturnData.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (returnData != null) {
      data['data'] = returnData!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class ReturnData {
  String? s0ISIN;
  String? s0schemeName;
  String? s1ISIN;
  String? s1schemeName;
  String? s2ISIN;
  String? s2schemeName;
  String? s3ISIN;
  String? s3schemeName;
  String? s4ISIN;
  String? s4schemeName;
  String? date1;
  String? date2;
  String? finalDate;
  double? ret0;
  double? ret1;
  double? ret2;
  double? ret3;
  double? ret4;

  ReturnData(
      {this.s0ISIN,
      this.s0schemeName,
      this.s1ISIN,
      this.s1schemeName,
      this.s2ISIN,
      this.s2schemeName,
      this.s3ISIN,
      this.s3schemeName,
      this.s4ISIN,
      this.s4schemeName,
      this.date1,
      this.date2,
      this.finalDate,
      this.ret0,
      this.ret1,
      this.ret2,
      this.ret3,
      this.ret4});

  ReturnData.fromJson(Map<String, dynamic> json) {
    s0ISIN = json['0ISIN'];
    s0schemeName = json['0schemeName'];
    s1ISIN = json['1ISIN'];
    s1schemeName = json['1schemeName'];
    s2ISIN = json['2ISIN'];
    s2schemeName = json['2schemeName'];
    s3ISIN = json['3ISIN'];
    s3schemeName = json['3schemeName'];
    s4ISIN = json['4ISIN'];
    s4schemeName = json['4schemeName'];
    date1 = json['Date1'];
    date2 = json['Date2'];
    finalDate = json['finalDate'];
    ret0 = json['ret0'];
    ret1 = json['ret1'];
    ret2 = json['ret2'];
    ret3 = json['ret3'];
    ret4 = json['ret4'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['0ISIN'] = s0ISIN;
    data['0schemeName'] = s0schemeName;
    data['1ISIN'] = s1ISIN;
    data['1schemeName'] = s1schemeName;
    data['2ISIN'] = s2ISIN;
    data['2schemeName'] = s2schemeName;
    data['3ISIN'] = s3ISIN;
    data['3schemeName'] = s3schemeName;
    data['4ISIN'] = s4ISIN;
    data['4schemeName'] = s4schemeName;
    data['Date1'] = date1;
    data['Date2'] = date2;
    data['finalDate'] = finalDate;
    data['ret0'] = ret0;
    data['ret1'] = ret1;
    data['ret2'] = ret2;
    data['ret3'] = ret3;
    data['ret4'] = ret4;
    return data;
  }
}

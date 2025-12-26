class TaxPnlEqCharges {
  String? total;
  List<Eq>? eq;

  TaxPnlEqCharges({this.total, this.eq});

  TaxPnlEqCharges.fromJson(Map<String, dynamic> json) {
    total = json['Total'].toString();
    if (json['eq'] != null) {
      eq = <Eq>[];
      json['eq'].forEach((v) {
        eq!.add(Eq.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Total'] = total;
    if (eq != null) {
      data['eq'] = eq!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Eq {
  String ? nOTPROFIT;
  String? sCRIPSYMBOL;

  Eq({this.nOTPROFIT, this.sCRIPSYMBOL});

  Eq.fromJson(Map<String, dynamic> json) {
    nOTPROFIT = json['NOT_PROFIT'] .toString();
    sCRIPSYMBOL = json['SCRIP_SYMBOL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NOT_PROFIT'] = nOTPROFIT;
    data['SCRIP_SYMBOL'] = sCRIPSYMBOL;
    return data;
  }
}

import 'bond_lists.dart';

class GovtBond {
  String? msg;
  List<BondLists>? nCBGsec;
  GovtBond({this.msg, this.nCBGsec});

  GovtBond.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];

    if (json['NCBGsec'] != null) {
      nCBGsec = <BondLists>[];
      json['NCBGsec'].forEach((v) {
        nCBGsec!.add(BondLists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;

    if (nCBGsec != null) {
      data['NCBGsec'] = nCBGsec!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

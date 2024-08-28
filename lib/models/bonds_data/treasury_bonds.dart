import 'bond_lists.dart';

class TreasuryBond {
  String? msg;
  List<BondLists>? nCBTBill;

  TreasuryBond({this.msg, this.nCBTBill});

  TreasuryBond.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];

    if (json['NCBTBill'] != null) {
      nCBTBill = <BondLists>[];
      json['NCBTBill'].forEach((v) {
        nCBTBill!.add(BondLists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;

    if (nCBTBill != null) {
      data['NCBTBill'] = nCBTBill!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

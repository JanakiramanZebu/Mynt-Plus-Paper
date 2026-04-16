import 'all_bonds_list_model.dart';

class TreasuryBonds {
  String? msg;
  List<BondsList>? ncbTBill;

  TreasuryBonds({this.msg, this.ncbTBill});

  TreasuryBonds.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];

    if (json['NCBTBill'] != null) {
      ncbTBill = <BondsList>[];
      json['NCBTBill'].forEach((v) {
        ncbTBill!.add(BondsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;

    if (ncbTBill != null) {
      data['NCBTBill'] = ncbTBill!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

import 'bond_lists.dart';

class SovereignGoldBonds {
  String? msg;
  List<BondLists>? sGB;

  SovereignGoldBonds({this.msg, this.sGB});

  SovereignGoldBonds.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['SGB'] != null) {
      sGB = <BondLists>[];
      json['SGB'].forEach((v) {
        sGB!.add(BondLists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (sGB != null) {
      data['SGB'] = sGB!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

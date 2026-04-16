import 'all_bonds_list_model.dart';

class SovereignGoldBonds {
  String? msg;
  List<BondsList>? ncbSGB;

  SovereignGoldBonds({this.msg, this.ncbSGB});

  SovereignGoldBonds.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['SGB'] != null) {
      ncbSGB = <BondsList>[];
      json['SGB'].forEach((v) {
        ncbSGB!.add(BondsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (ncbSGB != null) {
      data['SGB'] = ncbSGB!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

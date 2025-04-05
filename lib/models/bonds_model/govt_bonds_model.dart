import 'all_bonds_list_model.dart';

class GovtBonds {
  String? msg;
  List<BondsList>? ncbGSec;
  GovtBonds({this.msg, this.ncbGSec});

  GovtBonds.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];

    if (json['NCBGsec'] != null) {
      ncbGSec = <BondsList>[];
      json['NCBGsec'].forEach((v) {
        ncbGSec!.add(BondsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;

    if (ncbGSec != null) {
      data['NCBGsec'] = ncbGSec!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

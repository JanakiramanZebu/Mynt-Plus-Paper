import 'all_bonds_list_model.dart';

class StateBonds {
  String? msg;
  List<BondsList>? ncbSDL;

  StateBonds({this.msg, this.ncbSDL});

  StateBonds.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];

    if (json['NCBSDL'] != null) {
      ncbSDL = <BondsList>[];
      json['NCBSDL'].forEach((v) {
        ncbSDL!.add(BondsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;

    if (ncbSDL != null) {
      data['NCBSDL'] = ncbSDL!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

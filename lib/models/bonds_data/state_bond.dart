import 'bond_lists.dart';

class StateBonds {
  String? msg;
  List<BondLists>? nCBSDL;

  StateBonds({this.msg, this.nCBSDL});

  StateBonds.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];

    if (json['NCBSDL'] != null) {
      nCBSDL = <BondLists>[];
      json['NCBSDL'].forEach((v) {
        nCBSDL!.add(new BondLists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;

    if (nCBSDL != null) {
      data['NCBSDL'] = nCBSDL!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

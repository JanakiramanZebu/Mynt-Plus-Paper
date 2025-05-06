class BankDetails {
  List<String>? cOLUMNS;
  List<List>? dATA;

  BankDetails({this.cOLUMNS, this.dATA});

  BankDetails.fromJson(Map<String, dynamic> json) {
    cOLUMNS = json['COLUMNS'].cast<String>();
    if (json['DATA'] != null) {
      dATA = <List>[];
      json['DATA'].forEach((v) {
        dATA!.add((v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['COLUMNS'] = cOLUMNS;
    if (dATA != null) {
      data['DATA'] = dATA!.map((v) => v).toList();
    }
    return data;
  }
}


class AccountItem {
  String accno;
  String ifsc;

  AccountItem({required this.accno, required this.ifsc});
}
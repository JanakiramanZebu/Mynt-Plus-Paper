class CreateGroupName {
  int? id;
  String? status;

  CreateGroupName({this.id, this.status});

  CreateGroupName.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    return data;
  }
}

class AddGroupSymbol {
  String? status;

  AddGroupSymbol({this.status});

  AddGroupSymbol.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    return data;
  }
}

class GetGroupSymbol {
  int? id;
  List<Posdata>? posdata;
  String? posname;

  GetGroupSymbol({this.id, this.posdata, this.posname});

  GetGroupSymbol.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['posdata'] != null) {
      posdata = <Posdata>[];
      json['posdata'].forEach((v) {
        posdata!.add(Posdata.fromJson(v));
      });
    }
    posname = json['posname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (posdata != null) {
      data['posdata'] = posdata!.map((v) => v.toJson()).toList();
    }
    data['posname'] = posname;
    return data;
  }
}

class Posdata {
  String? expDate;
  String? symbol;
  String? token;
  String? tsym;

  Posdata({this.expDate, this.symbol, this.token, this.tsym});

  Posdata.fromJson(Map<String, dynamic> json) {
    expDate = json['expDate'];
    symbol = json['symbol'];
    token = json['token'];
    tsym = json['tsym'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expDate'] = expDate;
    data['symbol'] = symbol;
    data['token'] = token;
    data['tsym'] = tsym;
    return data;
  }
}

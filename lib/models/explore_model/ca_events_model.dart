class CAevents {
  List<Dividend>? dividend;
  List<Bonus>? bonus;
  List<Splits>? splits;
  List<Rights>? rights;

  CAevents({this.dividend, this.bonus, this.splits, this.rights});

  CAevents.fromJson(Map<String, dynamic> json) {
    if (json['dividend'] != null) {
      dividend = <Dividend>[];
      json['dividend'].forEach((v) {
        dividend!.add(Dividend.fromJson(v));
      });
    }
    if (json['bonus'] != null) {
      bonus = <Bonus>[];
      json['bonus'].forEach((v) {
        bonus!.add(Bonus.fromJson(v));
      });
    }
    if (json['splits'] != null) {
      splits = <Splits>[];
      json['splits'].forEach((v) {
        splits!.add(Splits.fromJson(v));
      });
    }
    if (json['rights'] != null) {
      rights = <Rights>[];
      json['rights'].forEach((v) {
        rights!.add(Rights.fromJson(v));
      });
    }
  }

  get caEventdata => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dividend != null) {
      data['dividend'] = dividend!.map((v) => v.toJson()).toList();
    }
    if (bonus != null) {
      data['bonus'] = bonus!.map((v) => v.toJson()).toList();
    }
    if (splits != null) {
      data['splits'] = splits!.map((v) => v.toJson()).toList();
    }
    if (rights != null) {
      data['rights'] = rights!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dividend {
  String? exDate;
  String? name;
  String? ratio;
  String? exch;
  String? symbol;
  String? token;

  Dividend({this.exDate, this.name, this.ratio});

  Dividend.fromJson(Map<String, dynamic> json) {
    exDate = json['ex_date'];
    name = json['name'];
    ratio = json['ratio'];
    exch = json['exch'];
    symbol = json['symbol'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ex_date'] = exDate;
    data['name'] = name;
    data['ratio'] = ratio;
    data['exch'] = exch;
    data['symbol'] = symbol;
    data['token'] = token;
    return data;
  }
}

class Bonus {
  String? exDate;
  String? name;
  String? ratio;
  String? exch;
  String? symbol;
  String? token;

  Bonus({this.exDate, this.name, this.ratio});

  Bonus.fromJson(Map<String, dynamic> json) {
    exDate = json['ex_date'];
    name = json['name'];
    ratio = json['ratio'];
    exch = json['exch'];
    symbol = json['symbol'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ex_date'] = exDate;
    data['name'] = name;
    data['ratio'] = ratio;
    data['exch'] = exch;
    data['symbol'] = symbol;
    data['token'] = token;
    return data;
  }
}

class Splits {
  String? exDate;
  String? name;
  String? ratio;
  String? exch;
  String? symbol;
  String? token;

  Splits({this.exDate, this.name, this.ratio});

  Splits.fromJson(Map<String, dynamic> json) {
    exDate = json['ex_date'];
    name = json['name'];
    ratio = json['ratio'];
    exch = json['exch'];
    symbol = json['symbol'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ex_date'] = exDate;
    data['name'] = name;
    data['ratio'] = ratio;
    data['exch'] = exch;
    data['symbol'] = symbol;
    data['token'] = token;
    return data;
  }
}

class Rights {
  String? exDate;
  String? name;
  String? ratio;
  String? exch;
  String? symbol;
  String? token;

  Rights({this.exDate, this.name, this.ratio});

  Rights.fromJson(Map<String, dynamic> json) {
    exDate = json['ex_date'];
    name = json['name'];
    ratio = json['ratio'];
    exch = json['exch'];
    symbol = json['symbol'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ex_date'] = exDate;
    data['name'] = name;
    data['ratio'] = ratio;
    data['exch'] = exch;
    data['symbol'] = symbol;
    data['token'] = token;
    return data;
  }
}

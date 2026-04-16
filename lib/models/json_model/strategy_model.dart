class StrategyJosnModel {
  List<Bullish>? bullish;
  List<Bearish>? bearish;
  List<Neutral>? neutral;

  StrategyJosnModel({this.bullish, this.bearish, this.neutral});

  StrategyJosnModel.fromJson(Map<String, dynamic> json) {
    if (json['bullish'] != null) {
      bullish = <Bullish>[];
      json['bullish'].forEach((v) {
        bullish!.add(Bullish.fromJson(v));
      });
    }
    if (json['bearish'] != null) {
      bearish = <Bearish>[];
      json['bearish'].forEach((v) {
        bearish!.add(Bearish.fromJson(v));
      });
    }
    if (json['neutral'] != null) {
      neutral = <Neutral>[];
      json['neutral'].forEach((v) {
        neutral!.add(Neutral.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bullish != null) {
      data['bullish'] = bullish!.map((v) => v.toJson()).toList();
    }
    if (bearish != null) {
      data['bearish'] = bearish!.map((v) => v.toJson()).toList();
    }
    if (neutral != null) {
      data['neutral'] = neutral!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bullish {
  String? img;
  String? brkEven;
  int? leg;
  String? name;
  List<Data>? data;
  Info? info;

  Bullish({this.img, this.brkEven, this.leg, this.name, this.data, this.info});

  Bullish.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    brkEven = json['brk_even'];
    leg = json['leg'];
    name = json['name'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['img'] = img;
    data['brk_even'] = brkEven;
    data['leg'] = leg;
    data['name'] = name;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (info != null) {
      data['info'] = info!.toJson();
    }
    return data;
  }
}

class Data {
  String? action;
  String? type;
  String? typeof;
  int? letselection;
  String? strike;
  String? premiun;
  int? leg;

  Data(
      {this.action,
      this.type,
      this.typeof,
      this.letselection,
      this.strike,
      this.premiun,
      this.leg});

  Data.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    type = json['type'];
    typeof = json['typeof'];
    letselection = json['letselection'];
    strike = json['strike'];
    premiun = json['premiun'];
    leg = json['leg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['type'] = type;
    data['typeof'] = typeof;
    data['letselection'] = letselection;
    data['strike'] = strike;
    data['premiun'] = premiun;
    data['leg'] = leg;
    return data;
  }
}

class Bearish {
  String? img;
  String? brkEven;
  int? leg;
  String? name;
  List<Data>? data;
  Info? info;

  Bearish({this.img, this.brkEven, this.leg, this.name, this.data, this.info});

  Bearish.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    brkEven = json['brk_even'];
    leg = json['leg'];
    name = json['name'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['img'] = img;
    data['brk_even'] = brkEven;
    data['leg'] = leg;
    data['name'] = name;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (info != null) {
      data['info'] = info!.toJson();
    }
    return data;
  }
}

class Neutral {
  String? img;
  String? upBrkEven;
  String? lowBrkEven;
  int? leg;
  String? name;
  List<Data>? data;
  Info? info;

  Neutral(
      {this.img,
      this.upBrkEven,
      this.lowBrkEven,
      this.leg,
      this.name,
      this.data,
      this.info});

  Neutral.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    upBrkEven = json['up_brk_even'];
    lowBrkEven = json['low_brk_even'];
    leg = json['leg'];
    name = json['name'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['img'] = img;
    data['up_brk_even'] = upBrkEven;
    data['low_brk_even'] = lowBrkEven;
    data['leg'] = leg;
    data['name'] = name;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (info != null) {
      data['info'] = info!.toJson();
    }
    return data;
  }
}

class Info {
  String? view;
  String? stratery;
  String? risk;
  String? reward;
  String? breakEven;
  String? profitWhen;
  String? lossWhen;
  String? maxProfit;
  String? maxLoss;
  String? upperBE;
  String? lowerBE;

  Info(
      {this.view,
      this.stratery,
      this.risk,
      this.reward,
      this.breakEven,
      this.profitWhen,
      this.lossWhen,
      this.maxProfit,
      this.maxLoss,
      this.upperBE,
      this.lowerBE});

  Info.fromJson(Map<String, dynamic> json) {
    view = json['View'];
    stratery = json['Stratery'];
    risk = json['Risk'];
    reward = json['Reward'];
    breakEven = json['Break even'];
    profitWhen = json['Profit, when'];
    lossWhen = json['Loss, when'];
    maxProfit = json['Max Profit'];
    maxLoss = json['Max loss'];
    upperBE = json['Upper BE'];
    lowerBE = json['Lower  BE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['View'] = view;
    data['Stratery'] = stratery;
    data['Risk'] = risk;
    data['Reward'] = reward;
    data['Break even'] = breakEven;
    data['Profit, when'] = profitWhen;
    data['Loss, when'] = lossWhen;
    data['Max Profit'] = maxProfit;
    data['Max loss'] = maxLoss;
    data['Upper BE'] = upperBE;
    data['Lower  BE'] = lowerBE;
    return data;
  }
}

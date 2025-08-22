// models/strategy_model.dart
import 'dart:convert';

class StrategyRequest {
  final String uid;
  final String email;
  final String statname;
  final String exch;
  final String product;
  final String symbol;
  final String idxtoken;
  final String idxexch;
  final List<StrategyLeg> statlegs;
  final Target target;
  final StopLoss stoploss;
  final String starttime;
  final String endtime;
  final List<String> executionOn;
  final String broker;
  final String datetime;

  StrategyRequest({
    required this.uid,
    required this.email,
    required this.statname,
    required this.exch,
    required this.product,
    required this.symbol,
    required this.idxtoken,
    required this.idxexch,
    required this.statlegs,
    required this.target,
    required this.stoploss,
    required this.starttime,
    required this.endtime,
    required this.executionOn,
    required this.broker,
    required this.datetime,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'statname': statname,
      'exch': exch,
      'product': product,
      'symbol': symbol,
      'idxtoken': idxtoken,
      'idxexch': idxexch,
      'statlegs': statlegs.map((leg) => leg.toJson()).toList(),
      'target': target.toJson(),
      'stoploss': stoploss.toJson(),
      'starttime': starttime,
      'endtime': endtime,
      'execution_on': executionOn,
      'broker': broker,
      'datetime': datetime,
    };
  }

  factory StrategyRequest.fromJson(Map<String, dynamic> json) {
    return StrategyRequest(
      uid: json['uid'],
      email: json['email'],
      statname: json['statname'],
      exch: json['exch'],
      product: json['product'],
      symbol: json['symbol'],
      idxtoken: json['idxtoken'],
      idxexch: json['idxexch'],
      statlegs: (json['statlegs'] as List)
          .map((leg) => StrategyLeg.fromJson(leg))
          .toList(),
      target: Target.fromJson(json['target']),
      stoploss: StopLoss.fromJson(json['stoploss']),
      starttime: json['starttime'],
      endtime: json['endtime'],
      executionOn: List<String>.from(json['execution_on']),
      broker: json['broker'],
      datetime: json['datetime'],
    );
  }
}

class StrategyLeg {
  final String strike;
  final String expiry;
  final String optionType;
  final String quantity;
  final String action;
  final String prctype;
  final String? nearPremium;

  StrategyLeg({
    required this.strike,
    required this.expiry,
    required this.optionType,
    required this.quantity,
    required this.action,
    required this.prctype,
    this.nearPremium,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'strike': strike,
      'expiry': expiry,
      'OptionType': optionType,
      'quantity': quantity,
      'action': action,
      'prctype': prctype,
    };
    
    if (nearPremium != null) {
      json['near_premium'] = nearPremium;
    }
    
    return json;
  }

  factory StrategyLeg.fromJson(Map<String, dynamic> json) {
    return StrategyLeg(
      strike: json['strike'],
      expiry: json['expiry'],
      optionType: json['OptionType'],
      quantity: json['quantity'],
      action: json['action'],
      prctype: json['prctype'],
      nearPremium: json['near_premium'],
    );
  }
}

// class Target {
//   final String type;
//   final int value;

//   Target({
//     required this.type,
//     required this.value,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type,
//       'VALUE': value,
//     };
//   }

//   factory Target.fromJson(Map<String, dynamic> json) {
//     return Target(
//       type: json['type'],
//       value: json['VALUE'],
//     );
//   }
// }

class StopLoss {
  final String? type;
  final String? value;

  StopLoss({
    this.type,
    this.value,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (type != null) json['type'] = type;
    if (value != null) json['VALUE'] = value;
    return json;
  }

  factory StopLoss.fromJson(Map<String, dynamic> json) {
    return StopLoss(
      type: json['type'],
      value: json['VALUE'],
    );
  }
}

class StrategyResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  StrategyResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StrategyResponse.fromJson(Map<String, dynamic> json) {
    return StrategyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class StrategyList {
  List<Data>? data;

  StrategyList({this.data});

  StrategyList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? uid;
  String? email;
  String? statname;
  String? exch;
  String? product;
  List<Statlegs>? statlegs;
  Target? target;
  Target? stoploss;
  String? starttime;
  String? endtime;
  List<String>? executionon;
  String? broker;
  String? datetime;
  String? idxtoken;
  String? symbol;
  String? status;
  String? strategyid;
  String? idxexch;

  Data(
      {this.uid,
      this.email,
      this.statname,
      this.exch,
      this.product,
      this.statlegs,
      this.target,
      this.stoploss,
      this.starttime,
      this.endtime,
      this.executionon,
      this.broker,
      this.datetime,
      this.idxtoken,
      this.symbol,
      this.status,
      this.strategyid,
      this.idxexch});

 Data.fromJson(Map<String, dynamic> json) {
  uid = json['uid'];
  email = json['email'];
  statname = json['statname'];
  exch = json['exch'];
  product = json['product'];
  
  if (json['statlegs'] != null) {
    statlegs = <Statlegs>[];
    json['statlegs'].forEach((v) {
      statlegs!.add(new Statlegs.fromJson(v));
    });
  }
  
  target = json['target'] != null ? new Target.fromJson(json['target']) : null;
  stoploss = json['stoploss'] != null && json['stoploss'].isNotEmpty 
      ? new Target.fromJson(json['stoploss']) : null;
  
  starttime = json['starttime'];
  endtime = json['endtime'];
  
  // Fix for executionon casting
  if (json['executionon'] != null) {
    executionon = List<String>.from(json['executionon']);
  }
  
  broker = json['broker'];
  datetime = json['datetime'];
  idxtoken = json['idxtoken'];
  symbol = json['symbol'];
  status = json['status'];
  strategyid = json['strategyid'];
  idxexch = json['idxexch'];
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['email'] = this.email;
    data['statname'] = this.statname;
    data['exch'] = this.exch;
    data['product'] = this.product;
    if (this.statlegs != null) {
      data['statlegs'] = this.statlegs!.map((v) => v.toJson()).toList();
    }
    if (this.target != null) {
      data['target'] = this.target!.toJson();
    }
    if (this.stoploss != null) {
      data['stoploss'] = this.stoploss!.toJson();
    }
    data['starttime'] = this.starttime;
    data['endtime'] = this.endtime;
    data['executionon'] = this.executionon;
    data['broker'] = this.broker;
    data['datetime'] = this.datetime;
    data['idxtoken'] = this.idxtoken;
    data['symbol'] = this.symbol;
    data['status'] = this.status;
    data['strategyid'] = this.strategyid;
    data['idxexch'] = this.idxexch;
    return data;
  }
}

class Statlegs {
  String? action;
  String? expiry;
  String? strike;
  String? prctype;
  String? quantity;
  String? optionType;
  String? nearPremium;

  Statlegs(
      {this.action,
      this.expiry,
      this.strike,
      this.prctype,
      this.quantity,
      this.optionType,
      this.nearPremium});

  Statlegs.fromJson(Map<String, dynamic> json) {
  action = json['action'];
  expiry = json['expiry']; // Already nullable
  strike = json['strike']?.toString(); // Convert to string if not null
  prctype = json['prctype'];
  quantity = json['quantity']?.toString(); // Convert to string if not null
  optionType = json['OptionType'];
  nearPremium = json['near_premium']?.toString(); // Convert to string if not null
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['action'] = this.action;
    data['expiry'] = this.expiry;
    data['strike'] = this.strike;
    data['prctype'] = this.prctype;
    data['quantity'] = this.quantity;
    data['OptionType'] = this.optionType;
    data['near_premium'] = this.nearPremium;
    return data;
  }
}

class Target {
  String? type;
  String? value;

  Target({this.type, this.value});

  Target.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['VALUE']?.toString(); // Note: your JSON uses 'VALUE' not 'value'
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['VALUE'] = this.value;
    return data;
  }
}

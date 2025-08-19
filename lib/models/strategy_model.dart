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

class Target {
  final String type;
  final int value;

  Target({
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'VALUE': value,
    };
  }

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      type: json['type'],
      value: json['VALUE'],
    );
  }
}

class StopLoss {
  final String? type;
  final int? value;

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

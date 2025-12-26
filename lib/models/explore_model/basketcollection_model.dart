class SavedStrategyModel {
  String? msg;
  List<Data>? data;

  SavedStrategyModel({this.msg, this.data});

  SavedStrategyModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  List<SchemaValues>? schemaValues;
  String? uuid;
  int? years;
  double? investAmount;
  String? datetime;
  String? investmentDetails;
  String? basketName;
  String? name;

  Data(
      {this.schemaValues,
      this.uuid,
      this.years,
      this.investAmount,
      this.datetime,
      this.investmentDetails,
      this.basketName,
      this.name,
      });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['schema_values'] != null) {
      schemaValues = <SchemaValues>[];
      json['schema_values'].forEach((v) {
        schemaValues!.add(SchemaValues.fromJson(v));
      });
    }
    uuid = json['uuid'];
    years = json['years'];
    investAmount = json['invest_amount'];
    datetime = json['datetime'];
    investmentDetails = json['investment_details'];
    basketName = json['basket_name'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (schemaValues != null) {
      data['schema_values'] =
          schemaValues!.map((v) => v.toJson()).toList();
    }
    data['uuid'] = uuid;
    data['years'] = years;
    data['invest_amount'] = investAmount;
    data['datetime'] = datetime;
    data['investment_details'] = investmentDetails;
    data['basket_name'] = basketName;
    data['name'] = name;
    return data;
  }
}

class SchemaValues {
  int? percentage;
  String? schemaName;
  String? schemeType;
  String? isin;
  String? aMCCode;
  double? aum;
  String? name;

  SchemaValues({this.percentage, this.schemaName, this.schemeType, this.isin, this.name});

  SchemaValues.fromJson(Map<String, dynamic> json) {
    percentage = json['percentage'];
    schemaName = json['schema_name'];
    schemeType = json['scheme_type'];
    isin = json['isin'];
    aMCCode = json['aMCCode'];
    aum = json['aum'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['percentage'] = percentage;
    data['schema_name'] = schemaName;
    data['scheme_type'] = schemeType;
    data['isin'] = isin;
    data['aMCCode'] = aMCCode;
    data['aum'] = aum;
    data['name'] = name;
    return data;
  }
}


// Fund Model
class FundListModel {
  final String name;
  final String type;
  final double fiveYearCAGR;
  final double threeYearCAGR;
  final double aum;
  final double sharpe;
  final String? aMCCode;
  final String? isin;
  double percentage;
  final String? schemeName;
  bool isLocked;

  FundListModel({
    required this.name,
    required this.type,
    required this.fiveYearCAGR,
    required this.threeYearCAGR,
    required this.aum,
    required this.sharpe,
    this.aMCCode,
    this.percentage = 0.0,
    this.isin,
    this.schemeName,
    this.isLocked = false,
  });
}
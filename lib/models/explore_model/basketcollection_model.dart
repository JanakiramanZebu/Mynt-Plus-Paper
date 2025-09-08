class SavedStrategyModel {
  String? msg;
  List<Data>? data;

  SavedStrategyModel({this.msg, this.data});

  SavedStrategyModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
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

  Data(
      {this.schemaValues,
      this.uuid,
      this.years,
      this.investAmount,
      this.datetime,
      this.investmentDetails,
      this.basketName,
      });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['schema_values'] != null) {
      schemaValues = <SchemaValues>[];
      json['schema_values'].forEach((v) {
        schemaValues!.add(new SchemaValues.fromJson(v));
      });
    }
    uuid = json['uuid'];
    years = json['years'];
    investAmount = json['invest_amount'];
    datetime = json['datetime'];
    investmentDetails = json['investment_details'];
    basketName = json['basket_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.schemaValues != null) {
      data['schema_values'] =
          this.schemaValues!.map((v) => v.toJson()).toList();
    }
    data['uuid'] = this.uuid;
    data['years'] = this.years;
    data['invest_amount'] = this.investAmount;
    data['datetime'] = this.datetime;
    data['investment_details'] = this.investmentDetails;
    data['basket_name'] = this.basketName;
    return data;
  }
}

class SchemaValues {
  int? percentage;
  String? schemaName;
  String? schemeType;
  String? isin;
  String? aMCCode;

  SchemaValues({this.percentage, this.schemaName, this.schemeType, this.isin});

  SchemaValues.fromJson(Map<String, dynamic> json) {
    percentage = json['percentage'];
    schemaName = json['schema_name'];
    schemeType = json['scheme_type'];
    isin = json['isin'];
    aMCCode = json['aMCCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['percentage'] = this.percentage;
    data['schema_name'] = this.schemaName;
    data['scheme_type'] = this.schemeType;
    data['isin'] = this.isin;
    data['aMCCode'] = this.aMCCode;
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
  });
}
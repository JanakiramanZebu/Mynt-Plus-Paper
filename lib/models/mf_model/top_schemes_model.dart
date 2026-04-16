class TopSchemesModel {
  String? msg;
  List<TopSchemesModelData>? data;

  TopSchemesModel({this.msg,this.data});

  TopSchemesModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <TopSchemesModelData>[];
      json['data'].forEach((v) {
        data!.add(TopSchemesModelData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopSchemesModelData {
  String? d10Year;
  String? d10YearSIPReturn;
  String? d15Day;
  String? d15Year;
  String? d15YearSIPReturn;
  String? d1Day;
  String? d1Year;
  String? d1YearSIPReturn;
  String? d20Year;
  String? d20YearSIPReturn;
  String? d25Year;
  String? d2Year;
  String? d30Day;
  String? d3Month;
  String? d3Year;
  String? d3YearSIPReturn;
  String? d5Year;
  String? d5YearSIPReturn;
  String? d6Month;
  String? d7Day;
  String? aUM;
  String? category;
  String? fundName;
  String? isRecommended;
  String? isinNo;
  String? schemeGroupName;
  String? schemeName;
  String? sinceInceptionReturn;

  TopSchemesModelData(
      {this.d10Year,
      this.d10YearSIPReturn,
      this.d15Day,
      this.d15Year,
      this.d15YearSIPReturn,
      this.d1Day,
      this.d1Year,
      this.d1YearSIPReturn,
      this.d20Year,
      this.d20YearSIPReturn,
      this.d25Year,
      this.d2Year,
      this.d30Day,
      this.d3Month,
      this.d3Year,
      this.d3YearSIPReturn,
      this.d5Year,
      this.d5YearSIPReturn,
      this.d6Month,
      this.d7Day,
      this.aUM,
      this.category,
      this.fundName,
      this.isRecommended,
      this.isinNo,
      this.schemeGroupName,
      this.schemeName,
      this.sinceInceptionReturn});

  TopSchemesModelData.fromJson(Map<String, dynamic> json) {
    d10Year = json['10Year'];
    d10YearSIPReturn = json['10YearSIPReturn'];
    d15Day = json['15Day'];
    d15Year = json['15Year'];
    d15YearSIPReturn = json['15YearSIPReturn'];
    d1Day = json['1Day'];
    d1Year = json['1Year'];
    d1YearSIPReturn = json['1YearSIPReturn'];
    d20Year = json['20Year'];
    d20YearSIPReturn = json['20YearSIPReturn'];
    d25Year = json['25Year'];
    d2Year = json['2Year'];
    d30Day = json['30Day'];
    d3Month = json['3Month'];
    d3Year = json['3Year'];
    d3YearSIPReturn = json['3YearSIPReturn'];
    d5Year = json['5Year'];
    d5YearSIPReturn = json['5YearSIPReturn'];
    d6Month = json['6Month'];
    d7Day = json['7Day'];
    aUM = json['AUM'];
    category = json['category'];
    fundName = json['fundName'];
    isRecommended = json['isRecommended'];
    isinNo = json['isinNo'];
    schemeGroupName = json['schemeGroupName'];
    schemeName = json['schemeName'];
    sinceInceptionReturn = json['sinceInceptionReturn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['10Year'] = d10Year;
    data['10YearSIPReturn'] = d10YearSIPReturn;
    data['15Day'] = d15Day;
    data['15Year'] = d15Year;
    data['15YearSIPReturn'] = d15YearSIPReturn;
    data['1Day'] = d1Day;
    data['1Year'] = d1Year;
    data['1YearSIPReturn'] = d1YearSIPReturn;
    data['20Year'] = d20Year;
    data['20YearSIPReturn'] = d20YearSIPReturn;
    data['25Year'] = d25Year;
    data['2Year'] = d2Year;
    data['30Day'] = d30Day;
    data['3Month'] = d3Month;
    data['3Year'] = d3Year;
    data['3YearSIPReturn'] = d3YearSIPReturn;
    data['5Year'] = d5Year;
    data['5YearSIPReturn'] = d5YearSIPReturn;
    data['6Month'] = d6Month;
    data['7Day'] = d7Day;
    data['AUM'] = aUM;
    data['category'] = category;
    data['fundName'] = fundName;
    data['isRecommended'] = isRecommended;
    data['isinNo'] = isinNo;
    data['schemeGroupName'] = schemeGroupName;
    data['schemeName'] = schemeName;
    data['sinceInceptionReturn'] = sinceInceptionReturn;
    return data;
  }
}

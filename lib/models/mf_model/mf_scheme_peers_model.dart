class MFSchemePeers {
  String? stat;
  Statistics? statistics;
  List<TopSchemes>? topSchemes;

  MFSchemePeers({this.stat, this.statistics, this.topSchemes});

  MFSchemePeers.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    statistics = json['statistics'] != null
        ? Statistics.fromJson(json['statistics'])
        : null;
    if (json['topSchemes'] != null) {
      topSchemes = <TopSchemes>[];
      json['topSchemes'].forEach((v) {
        topSchemes!.add(TopSchemes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (statistics != null) {
      data['statistics'] = statistics!.toJson();
    }
    if (topSchemes != null) {
      data['topSchemes'] = topSchemes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Statistics {
  String? average;
  String? highest;
  String? lowest;
  String? thisScheme;

  Statistics({this.average, this.highest, this.lowest, this.thisScheme});

  Statistics.fromJson(Map<String, dynamic> json) {
    average = json['average'].toString();
    highest = json['highest'].toString();
    lowest = json['lowest'].toString();
    thisScheme = json['thisScheme'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['average'] = average;
    data['highest'] = highest;
    data['lowest'] = lowest;
    data['thisScheme'] = thisScheme;
    return data;
  }
}

class TopSchemes {
  String? d10Year;
  String? iSIN;
  String? aum;
  String? fundRat;
  String? name;
  String? schid;
  String? d1Year;
  String? d2Year;
  String? d3Year;
  String? d5Year;
  String? yearPer;
  String? yearName;
  TopSchemes(
      {this.d10Year,
      this.iSIN,
      this.aum,
      this.fundRat,
      this.name,
      this.schid,
      this.d1Year,
      this.d2Year,
      this.d3Year,
      this.d5Year,
      this.yearPer,
      this.yearName});

  TopSchemes.fromJson(Map<String, dynamic> json) {
    d10Year = json['10Year'].toString();
    iSIN = json['ISIN'].toString();
    aum = json['aum'].toString();
    fundRat = json['fundRat'].toString();
    name = json['name'].toString();
    schid = json['schid'].toString();
    d1Year = json['1Year'].toString();
    d2Year = json['2Year'].toString();
    d3Year = json['3Year'].toString();
    d5Year = json['5Year'].toString();
    yearPer = json['yearPer'].toString();
    yearName = json['yearName'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['10Year'] = d10Year;
    data['ISIN'] = iSIN;
    data['aum'] = aum;
    data['fundRat'] = fundRat;
    data['name'] = name;
    data['schid'] = schid;
    data['1Year'] = d1Year;
    data['2Year'] = d2Year;
    data['3Year'] = d3Year;
    data['5Year'] = d5Year;
    data['yearName'] = yearName;
    data['yearPer'] = yearPer;
    return data;
  }
}

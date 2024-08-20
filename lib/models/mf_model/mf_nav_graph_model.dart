class MFNavGraph {
  List<NavGraphData>? data;
  String? stat;

  MFNavGraph({this.data, this.stat});

  MFNavGraph.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NavGraphData>[];
      json['data'].forEach((v) {
        data!.add(NavGraphData.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class NavGraphData {
  num? nav;
  String? navDate;

  NavGraphData({this.nav, this.navDate});

  NavGraphData.fromJson(Map<String, dynamic> json) {
    nav = json['nav'];
    navDate = json['navDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nav'] = nav;
    data['navDate'] = navDate;
    return data;
  }
}

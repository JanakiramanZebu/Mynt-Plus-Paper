class Upcoming_ipo {
  List<Upcoming>? upcoming;
  String? msg;

  Upcoming_ipo({this.upcoming,this.msg});

  Upcoming_ipo.fromJson(Map<String, dynamic> json) {
    if (json['upcoming'] != null) {
      upcoming = <Upcoming>[];
      json['upcoming'].forEach((v) {
        upcoming!.add(new Upcoming.fromJson(v));
      });
    }
    msg = json["msg"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.upcoming != null) {
      data['upcoming'] = this.upcoming!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Upcoming {
  String? companyName;
  String? dRHPStatus;
  String? issueSize;
  String? lastUpdated;
  String? stockExchanges;
  String? drhp;
  String? imageLink;
  String? ipoType;
  String? year;

  Upcoming(
      {this.companyName,
      this.dRHPStatus,
      this.issueSize,
      this.lastUpdated,
      this.stockExchanges,
      this.drhp,
      this.imageLink,
      this.ipoType,
      this.year});

  Upcoming.fromJson(Map<String, dynamic> json) {
    companyName = json['Company Name'];
    dRHPStatus = json['DRHP status'];
    issueSize = json['Issue Size'];
    lastUpdated = json['Last Updated'];
    stockExchanges = json['Stock Exchanges'];
    drhp = json['drhp'];
    imageLink = json['image_link'];
    ipoType = json['ipo_type'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Company Name'] = this.companyName;
    data['DRHP status'] = this.dRHPStatus;
    data['Issue Size'] = this.issueSize;
    data['Last Updated'] = this.lastUpdated;
    data['Stock Exchanges'] = this.stockExchanges;
    data['drhp'] = this.drhp;
    data['image_link'] = this.imageLink;
    data['ipo_type'] = this.ipoType;
    data['year'] = this.year;
    return data;
  }
}

import 'dart:convert';

class Upcoming_ipo {
  List<Upcoming>? upcoming;
  String? msg;

  Upcoming_ipo({this.upcoming, this.msg});

  Upcoming_ipo.fromJson(Map<String, dynamic> json) {
    if (json['upcoming'] != null) {
      upcoming = <Upcoming>[];
      // Check if upcoming is a List or String
      if (json['upcoming'] is List) {
        json['upcoming'].forEach((v) {
          upcoming!.add(Upcoming.fromJson(v));
        });
      } else if (json['upcoming'] is String) {
        // If upcoming is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['upcoming'] as String);
          if (parsedList is List) {
            for (var v in parsedList) {
              upcoming!.add(Upcoming.fromJson(v));
            }
          }
        } catch (e) {
          print("Error parsing upcoming string: $e");
        }
      }
    }
    msg = json["msg"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (upcoming != null) {
      data['upcoming'] = upcoming!.map((v) => v.toJson()).toList();
    }
    data['msg'] = msg;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Company Name'] = companyName;
    data['DRHP status'] = dRHPStatus;
    data['Issue Size'] = issueSize;
    data['Last Updated'] = lastUpdated;
    data['Stock Exchanges'] = stockExchanges;
    data['drhp'] = drhp;
    data['image_link'] = imageLink;
    data['ipo_type'] = ipoType;
    data['year'] = year;
    return data;
  }
}

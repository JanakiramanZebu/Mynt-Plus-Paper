import 'dart:convert';

class IpoPreCloseModel {
  List<Msg> msg = [];

  IpoPreCloseModel({required this.msg});

  IpoPreCloseModel.fromJson(Map<String, dynamic> json) {
    if (json['msg'] != "no data") {
      msg = <Msg>[];
      // Check if msg is a List or String
      if (json['msg'] is List) {
        json['msg'].forEach((v) {
          msg.add(Msg.fromJson(v));
        });
      } else if (json['msg'] is String) {
        // If msg is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['msg'] as String);
          if (parsedList is List) {
            for (var v in parsedList) {
              msg.add(Msg.fromJson(v));
            }
          }
        } catch (e) {
        }
      }
    } else {
      msg = <Msg>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (msg.isNotEmpty) {
      data['msg'] = msg.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Msg {
  String? companyName;
  String? iPOEndDate;
  String? iPOStartDate;
  String? iSIN;
  String? issueSize;
  String? link;
  String? listingDate;
  String? lotSize;
  String? priceRange;
  String? stockExchanges;
  String? bsesymbol;
  int? id;
  String? imageLink;
  String? ipoData;
  String? ipoType;
  String? isin;
  String? listedDate;
  int? minAmount;
  int? minBidQu;
  int? minPrice;
  String? name;
  String? nsesymbol;
  String? scriptData;
  String? year;
  String? ipostatus;
  String? totalsub;

  Msg(
      {this.companyName,
      this.iPOEndDate,
      this.iPOStartDate,
      this.iSIN,
      this.issueSize,
      this.link,
      this.listingDate,
      this.lotSize,
      this.priceRange,
      this.stockExchanges,
      this.bsesymbol,
      this.id,
      this.imageLink,
      this.ipoData,
      this.ipoType,
      this.isin,
      this.listedDate,
      this.minAmount,
      this.minBidQu,
      this.minPrice,
      this.name,
      this.nsesymbol,
      this.scriptData,
      this.totalsub,
      this.year});

  Msg.fromJson(Map<String, dynamic> json) {
    companyName = json['Company Name'];
    iPOEndDate = json['IPO End Date'];
    iPOStartDate = json['IPO Start Date'];
    iSIN = json['ISIN'];
    issueSize = json['Issue Size'];
    link = json['Link'];
    listingDate = json['Listing_date'];
    lotSize = json['Lot Size'];
    priceRange = json['Price Range'];
    stockExchanges = json['Stock Exchanges'];
    bsesymbol = json['bsesymbol'];
    id = json['id'];
    imageLink = json['image_link'];
    ipoData = json['ipo_data'];
    ipoType = json['ipo_type'];
    isin = json['isin'];
    listedDate = json['listed_date'];
    minAmount = json['min_amount'].toInt();
    minBidQu = json['min_bid_qu'].toInt();
    minPrice = json['min_price'].toInt();
    name = json['name'];
    nsesymbol = json['nsesymbol'];
    scriptData = json['script_data'];
    year = json['year'];
    totalsub = json['total_sub'];
    ipostatus = "Closed";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Company Name'] = companyName;
    data['IPO End Date'] = iPOEndDate;
    data['IPO Start Date'] = iPOStartDate;
    data['ISIN'] = iSIN;
    data['Issue Size'] = issueSize;
    data['Link'] = link;
    data['Listing_date'] = listingDate;
    data['Lot Size'] = lotSize;
    data['Price Range'] = priceRange;
    data['Stock Exchanges'] = stockExchanges;
    data['bsesymbol'] = bsesymbol;
    data['id'] = id;
    data['image_link'] = imageLink;
    data['ipo_data'] = ipoData;
    data['ipo_type'] = ipoType;
    data['isin'] = isin;
    data['listed_date'] = listedDate;
    data['min_amount'] = minAmount;
    data['min_bid_qu'] = minBidQu;
    data['min_price'] = minPrice;
    data['name'] = name;
    data['nsesymbol'] = nsesymbol;
    data['script_data'] = scriptData;
    data['year'] = year;
    data['totalsub'] = totalsub;
    return data;
  }

  bool hasKey() {
    return true;
  }
}

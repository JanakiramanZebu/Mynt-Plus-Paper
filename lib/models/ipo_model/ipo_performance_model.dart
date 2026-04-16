import 'dart:convert';

class IpoPerformanceModel {
  String? emsg;
  List<IpoScrip>? data;

  IpoPerformanceModel({this.emsg, this.data});

  IpoPerformanceModel.fromJson(Map<String, dynamic> json) {
    emsg = json['emsg'];
    if (json['data'] != null) {
      data = <IpoScrip>[];
      // Check if data is a List or String
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(IpoScrip.fromJson(v));
        });
      } else if (json['data'] is String) {
        // If data is a string, try to parse it as JSON
        try {
          final parsedList = jsonDecode(json['data'] as String);
          if (parsedList is List) {
            for (var v in parsedList) {
              data!.add(IpoScrip.fromJson(v));
            }
          }
        } catch (e) {
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emsg'] = emsg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class IpoScrip {
  num? clsPric;
  String? companyName;
  String? iSIN;
  num? priceRange;
  List<String>? stockExchanges;
  String? covertdate;
  String? imageLink;
  String? listedDate;
  num? listingGain;
  num? listingGainPer;
  String? symbol;
  String? token;
  String? exchange;
  String? ipostatus;

  IpoScrip({
    this.clsPric,
    this.companyName,
    this.iSIN,
    this.priceRange,
    this.stockExchanges,
    this.covertdate,
    this.imageLink,
    this.listedDate,
    this.listingGain,
    this.listingGainPer,
    this.symbol,
    this.token,
    this.exchange,
  });

  IpoScrip.fromJson(Map<String, dynamic> json) {
    clsPric = json['ClsPric'];
    companyName = json['Company Name'];
    iSIN = json['ISIN'];
    priceRange = json['Price_Range'];
    stockExchanges = json['Stock Exchanges'].cast<String>();
    covertdate = json['covertdate'];
    imageLink = json['image_link'];
    listedDate = json['listed_date'];
    listingGain = json['listing_gain'];
    listingGainPer = json['listing_gain_per'];
    symbol = json['symbol'];
    token = json['token'];
    exchange = json['exchange'];
    ipostatus = "Listed";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ClsPric'] = clsPric;
    data['Company Name'] = companyName;
    data['ISIN'] = iSIN;
    data['Price_Range'] = priceRange;
    data['Stock Exchanges'] = stockExchanges;
    data['covertdate'] = covertdate;
    data['image_link'] = imageLink;
    data['listed_date'] = listedDate;
    data['listing_gain'] = listingGain;
    data['listing_gain_per'] = listingGainPer;
    data['symbol'] = symbol;
    data['token'] = token;
    data['exchange'] = exchange;
    return data;
  }
}

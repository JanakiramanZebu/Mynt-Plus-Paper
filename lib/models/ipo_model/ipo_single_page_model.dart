class IpoSinglePage {
  final dynamic data; // Can be a Map<String, dynamic> or String
  final dynamic scripdata;
  // Constructor to initialize IpoSinglePage
  IpoSinglePage({
    required this.data,
    required this.scripdata,
  });

  // Factory constructor to create an instance from JSON
  factory IpoSinglePage.fromJson(Map<String, dynamic> json) {
    return IpoSinglePage(
        data: json['data'] ?? {}, // Handling default value
        scripdata: json['data']['script_data']);
  }

  // Method to convert IpoSinglePage instance to a JSON representation
  Map<String, dynamic> toJson() {
    return {'data': data.toString(), 'scripdata': scripdata.toString()};
  }

  // Getter to check if the model contains any data
  bool get isNotEmpty => (data is String ? data.isNotEmpty : data.isNotEmpty);
}



// class IpoSinglePage {
//   Data? data;

//   IpoSinglePage({
//     required this.data,
//   });

//   factory IpoSinglePage.fromJson(Map<String, dynamic> json) {
//     return IpoSinglePage(
//       data: json['data'] is Map<String, dynamic>
//           ? Data.fromJson(json['data'])
//           : null, // Handle "no data" as null
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'data': data,
//     };
//   }
// }

// class Data {
//   String? data;
//   String? bse;
//   String? companyName;
//   String? ipoEndDate;
//   String? ipoStartDate;
//   String? isin;
//   String? issueSize;
//   String? link;
//   String? listingDate;
//   String? lotSize;
//   String? nse;
//   String? priceRange;
//   String? stockExchanges;
//   String? bseSymbol;
//   int? id;
//   String? imageLink;
//   String? ipoData;
//   String? ipoType;
//   String? listedDate;
//   String? name;
//   String? nseSymbol;
//   ScriptData? scriptData;
//   String? year;

//   Data({
//     this.data,
//     this.bse,
//     this.companyName,
//     this.ipoEndDate,
//     this.ipoStartDate,
//     this.isin,
//     this.issueSize,
//     this.link,
//     this.listingDate,
//     this.lotSize,
//     this.nse,
//     this.priceRange,
//     this.stockExchanges,
//     this.bseSymbol,
//     this.id,
//     this.imageLink,
//     this.ipoData,
//     this.ipoType,
//     this.listedDate,
//     this.name,
//     this.nseSymbol,
//     this.scriptData,
//     this.year,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(
//       data: json['data'] ?? '',
//       bse: json['BSE'] ?? '',
//       companyName: json['Company Name'] ?? '',
//       ipoEndDate: json['IPO End Date'] ?? '',
//       ipoStartDate: json['IPO Start Date'] ?? '',
//       isin: json['ISIN'] ?? '',
//       issueSize: json['Issue Size'] ?? '',
//       link: json['Link'] ?? '',
//       listingDate: json['Listing_date'] ?? '',
//       lotSize: json['Lot Size'] ?? '',
//       nse: json['NSE'] ?? '',
//       priceRange: json['Price Range'] ?? '',
//       stockExchanges: json['Stock Exchanges'] ?? '',
//       bseSymbol: json['bsesymbol'] ?? '',
//       id: json['id'] ?? 0,
//       imageLink: json['image_link'] ?? '',
//       ipoData: json['ipo_data'] ?? '',
//       ipoType: json['ipo_type'] ?? '',
//       listedDate: json['listed_date'] ?? '',
//       name: json['name'] ?? '',
//       nseSymbol: json['nsesymbol'] ?? '',
//       scriptData: ScriptData.fromJson(json['script_data']),
//       year: json['year'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'data': data,
//       'BSE': bse,
//       'Company Name': companyName,
//       'IPO End Date': ipoEndDate,
//       'IPO Start Date': ipoStartDate,
//       'ISIN': isin,
//       'Issue Size': issueSize,
//       'Link': link,
//       'Listing_date': listingDate,
//       'Lot Size': lotSize,
//       'NSE': nse,
//       'Price Range': priceRange,
//       'Stock Exchanges': stockExchanges,
//       'bsesymbol': bseSymbol,
//       'id': id,
//       'image_link': imageLink,
//       'ipo_data': ipoData,
//       'ipo_type': ipoType,
//       'listed_date': listedDate,
//       'name': name,
//       'nsesymbol': nseSymbol,
//       'script_data': scriptData,
//       'year': year,
//     };
//   }
// }

// class ScriptData {
//   List<Map<String, String>> ipoDetails;
//   List<Map<String, String>> ipoFinancialInformation;
//   List<Map<String, String>> ipoLotSize;
//   List<Map<String, String>> ipoPromoterHolding;
//   List<Map<String, String>> ipoReservation;
//   List<Map<String, String>> ipoTimeline;
//   List<Map<String, dynamic>> keyPerformanceIndicator;

//   ScriptData({
//     required this.ipoDetails,
//     required this.ipoFinancialInformation,
//     required this.ipoLotSize,
//     required this.ipoPromoterHolding,
//     required this.ipoReservation,
//     required this.ipoTimeline,
//     required this.keyPerformanceIndicator,
//   });

//   factory ScriptData.fromJson(Map<String, dynamic> json) {
//     return ScriptData(
//       ipoDetails: List<Map<String, String>>.from(
//         (json['IPO_Details'] as List)
//             .map((item) => Map<String, String>.from(item)),
//       ),
//       ipoFinancialInformation: List<Map<String, String>>.from(
//         (json['IPO_Financial_Information'] as List)
//             .map((item) => Map<String, String>.from(item)),
//       ),
//       ipoLotSize: List<Map<String, String>>.from(
//         (json['IPO_Lot_Size'] as List)
//             .map((item) => Map<String, String>.from(item)),
//       ),
//       ipoPromoterHolding: List<Map<String, String>>.from(
//         (json['IPO_Promoter_Holding'] as List)
//             .map((item) => Map<String, String>.from(item)),
//       ),
//       ipoReservation: List<Map<String, String>>.from(
//         (json['IPO_Reservation'] as List)
//             .map((item) => Map<String, String>.from(item)),
//       ),
//       ipoTimeline: List<Map<String, String>>.from(
//         (json['IPO_Timeline'] as List)
//             .map((item) => Map<String, String>.from(item)),
//       ),
//       keyPerformanceIndicator: List<Map<String, dynamic>>.from(
//         (json['Key_Performance_Indicator'] as List)
//             .map((item) => Map<String, dynamic>.from(item)),
//       ),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'IPO_Details': ipoDetails,
//       'IPO_Financial_Information': ipoFinancialInformation,
//       'IPO_Lot_Size': ipoLotSize,
//       'IPO_Promoter_Holding': ipoPromoterHolding,
//       'IPO_Reservation': ipoReservation,
//       'IPO_Timeline': ipoTimeline,
//       'Key_Performance_Indicator': keyPerformanceIndicator,
//     };
//   }
// }




// class IpoSinglePage {
//   IpoSinglePage({
//     this.data,
//   });

//   final Data? data;
//   static const String dataKey = "data";

//   factory IpoSinglePage.fromJson(Map<String, dynamic> json) {
//     return IpoSinglePage(
//       data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );
//   }
// }

// class Data {
//   Data({
//     this.bse,
//     this.companyName,
//     this.ipoEndDate,
//     this.ipoStartDate,
//     this.isin,
//     this.issueSize,
//     this.link,
//     this.listingDate,
//     this.lotSize,
//     this.nse,
//     this.priceRange,
//     this.stockExchanges,
//     this.bsesymbol,
//     this.id,
//     this.imageLink,
//     this.ipoData,
//     this.ipoType,
//     this.dataIsin,
//     this.listedDate,
//     this.name,
//     this.nsesymbol,
//     this.scriptData,
//     this.year,
//   });

//   final String? bse;
//   static const String bseKey = "BSE";

//   final String? companyName;
//   static const String companyNameKey = "Company Name";

//   final String? ipoEndDate;
//   static const String ipoEndDateKey = "IPO End Date";

//   final String? ipoStartDate;
//   static const String ipoStartDateKey = "IPO Start Date";

//   final String? isin;
//   static const String isinKey = "ISIN";

//   final String? issueSize;
//   static const String issueSizeKey = "Issue Size";

//   final String? link;
//   static const String linkKey = "Link";

//   final String? listingDate;
//   static const String listingDateKey = "Listing_date";

//   final String? lotSize;
//   static const String lotSizeKey = "Lot Size";

//   final String? nse;
//   static const String nseKey = "NSE";

//   final String? priceRange;
//   static const String priceRangeKey = "Price Range";

//   final String? stockExchanges;
//   static const String stockExchangesKey = "Stock Exchanges";

//   final String? bsesymbol;
//   static const String bsesymbolKey = "bsesymbol";

//   final String? id;
//   static const String idKey = "id";

//   final String? imageLink;
//   static const String imageLinkKey = "image_link";

//   final String? ipoData;
//   static const String ipoDataKey = "ipo_data";

//   final String? ipoType;
//   static const String ipoTypeKey = "ipo_type";

//   final String? dataIsin;
//   static const String dataIsinKey = "isin";

//   final String? listedDate;
//   static const String listedDateKey = "listed_date";

//   final String? name;
//   static const String nameKey = "name";

//   final String? nsesymbol;
//   static const String nsesymbolKey = "nsesymbol";

//   final ScriptData? scriptData;
//   static const String scriptDataKey = "script_data";

//   final String? year;
//   static const String yearKey = "year";

//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(
//       bse: json["BSE"].toString(),
//       companyName: json["Company Name"].toString(),
//       ipoEndDate: json["IPO End Date"].toString(),
//       ipoStartDate: json["IPO Start Date"].toString(),
//       isin: json["ISIN"].toString(),
//       issueSize: json["Issue Size"].toString(),
//       link: json["Link"].toString(),
//       listingDate: json["Listing_date"].toString(),
//       lotSize: json["Lot Size"].toString(),
//       nse: json["NSE"].toString(),
//       priceRange: json["Price Range"].toString(),
//       stockExchanges: json["Stock Exchanges"].toString(),
//       bsesymbol: json["bsesymbol"].toString(),
//       id: json["id"].toString(),
//       imageLink: json["image_link"].toString(),
//       ipoData: json["ipo_data"].toString(),
//       ipoType: json["ipo_type"].toString(),
//       dataIsin: json["isin"].toString(),
//       listedDate: json["listed_date"].toString(),
//       name: json["name"].toString(),
//       nsesymbol: json["nsesymbol"].toString(),
//       scriptData: json["script_data"] == null
//           ? null
//           : ScriptData.fromJson(json["script_data"]),
//       year: json["year"],
//     );
//   }
// }

// class ScriptData {
//   ScriptData({
//     required this.ipoDetails,
//     required this.ipoFinancialInformation,
//     required this.ipoLotSize,
//     required this.ipoPromoterHolding,
//     required this.ipoReservation,
//     required this.ipoTimeline,
//     required this.keyPerformanceIndicator,
//     required this.exchange,
//     required this.summary,
//     required this.symbol,
//     required this.token,
//   });

//   final List<Ipo> ipoDetails;
//   static const String ipoDetailsKey = "IPO_Details";

//   final List<IpoFinancialInformation> ipoFinancialInformation;
//   static const String ipoFinancialInformationKey = "IPO_Financial_Information";

//   final List<IpoLotSize> ipoLotSize;
//   static const String ipoLotSizeKey = "IPO_Lot_Size";

//   final List<Ipo> ipoPromoterHolding;
//   static const String ipoPromoterHoldingKey = "IPO_Promoter_Holding";

//   final List<IpoReservation> ipoReservation;
//   static const String ipoReservationKey = "IPO_Reservation";

//   final List<Ipo> ipoTimeline;
//   static const String ipoTimelineKey = "IPO_Timeline";

//   final List<KeyPerformanceIndicator> keyPerformanceIndicator;
//   static const String keyPerformanceIndicatorKey = "Key_Performance_Indicator";

//   final String? exchange;
//   static const String exchangeKey = "exchange";

//   final String? summary;
//   static const String summaryKey = "summary";

//   final String? symbol;
//   static const String symbolKey = "symbol";

//   final String? token;
//   static const String tokenKey = "token";

//   factory ScriptData.fromJson(Map<String, dynamic> json) {
//     return ScriptData(
//       ipoDetails: json["IPO_Details"] == null
//           ? []
//           : List<Ipo>.from(json["IPO_Details"]!.map((x) => Ipo.fromJson(x))),
//       ipoFinancialInformation: json["IPO_Financial_Information"] == null
//           ? []
//           : List<IpoFinancialInformation>.from(
//               json["IPO_Financial_Information"]!
//                   .map((x) => IpoFinancialInformation.fromJson(x))),
//       ipoLotSize: json["IPO_Lot_Size"] == null
//           ? []
//           : List<IpoLotSize>.from(
//               json["IPO_Lot_Size"]!.map((x) => IpoLotSize.fromJson(x))),
//       ipoPromoterHolding: json["IPO_Promoter_Holding"] == null
//           ? []
//           : List<Ipo>.from(
//               json["IPO_Promoter_Holding"]!.map((x) => Ipo.fromJson(x))),
//       ipoReservation: json["IPO_Reservation"] == null
//           ? []
//           : List<IpoReservation>.from(
//               json["IPO_Reservation"]!.map((x) => IpoReservation.fromJson(x))),
//       ipoTimeline: json["IPO_Timeline"] == null
//           ? []
//           : List<Ipo>.from(json["IPO_Timeline"]!.map((x) => Ipo.fromJson(x))),
//       keyPerformanceIndicator: json["Key_Performance_Indicator"] == null
//           ? []
//           : List<KeyPerformanceIndicator>.from(
//               json["Key_Performance_Indicator"]!
//                   .map((x) => KeyPerformanceIndicator.fromJson(x))),
//       exchange: json["exchange"],
//       summary: json["summary"],
//       symbol: json["symbol"],
//       token: json["token"],
//     );
//   }
// }

// class Ipo {
//   Ipo({
//     required this.name,
//     required this.value,
//   });

//   final String? name;
//   static const String nameKey = "name";

//   final String? value;
//   static const String valueKey = "value";

//   factory Ipo.fromJson(Map<String, dynamic> json) {
//     return Ipo(
//       name: json["name"],
//       value: json["value"],
//     );
//   }
// }

// class IpoFinancialInformation {
//   IpoFinancialInformation({
//     required this.empty,
//     required this.assets,
//     required this.netWorth,
//     required this.periodEnded,
//     required this.profitAfterTax,
//     required this.reservesAndSurplus,
//     required this.revenue,
//     required this.totalBorrowing,
//   });

//   final String? empty;
//   static const String emptyKey = "";

//   final String? assets;
//   static const String assetsKey = "Assets";

//   final String? netWorth;
//   static const String netWorthKey = "Net Worth";

//   final String? periodEnded;
//   static const String periodEndedKey = "Period Ended";

//   final String? profitAfterTax;
//   static const String profitAfterTaxKey = "Profit After Tax";

//   final String? reservesAndSurplus;
//   static const String reservesAndSurplusKey = "Reserves and Surplus";

//   final String? revenue;
//   static const String revenueKey = "Revenue";

//   final String? totalBorrowing;
//   static const String totalBorrowingKey = "Total Borrowing";

//   factory IpoFinancialInformation.fromJson(Map<String, dynamic> json) {
//     return IpoFinancialInformation(
//       empty: json[""],
//       assets: json["Assets"],
//       netWorth: json["Net Worth"],
//       periodEnded: json["Period Ended"],
//       profitAfterTax: json["Profit After Tax"],
//       reservesAndSurplus: json["Reserves and Surplus"],
//       revenue: json["Revenue"],
//       totalBorrowing: json["Total Borrowing"],
//     );
//   }
// }

// class IpoLotSize {
//   IpoLotSize({
//     required this.amount,
//     required this.application,
//     required this.lots,
//     required this.shares,
//   });

//   final String? amount;
//   static const String amountKey = "Amount";

//   final String? application;
//   static const String applicationKey = "Application";

//   final String? lots;
//   static const String lotsKey = "Lots";

//   final String? shares;
//   static const String sharesKey = "Shares";

//   factory IpoLotSize.fromJson(Map<String, dynamic> json) {
//     return IpoLotSize(
//       amount: json["Amount"],
//       application: json["Application"],
//       lots: json["Lots"],
//       shares: json["Shares"],
//     );
//   }
// }

// class IpoReservation {
//   IpoReservation({
//     required this.investorCategory,
//     required this.sharesOffered,
//   });

//   final String? investorCategory;
//   static const String investorCategoryKey = "Investor Category";

//   final String? sharesOffered;
//   static const String sharesOfferedKey = "Shares Offered";

//   factory IpoReservation.fromJson(Map<String, dynamic> json) {
//     return IpoReservation(
//       investorCategory: json["Investor Category"],
//       sharesOffered: json["Shares Offered"],
//     );
//   }
// }

// class KeyPerformanceIndicator {
//   KeyPerformanceIndicator({
//     required this.kpi,
//     required this.values,
//   });

//   final String? kpi;
//   static const String kpiKey = "KPI";

//   final double? values;
//   static const String valuesKey = "Values";

//   factory KeyPerformanceIndicator.fromJson(Map<String, dynamic> json) {
//     return KeyPerformanceIndicator(
//       kpi: json["KPI"],
//       values: json["Values"],
//     );
//   }
// }

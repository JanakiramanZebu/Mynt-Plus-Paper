import 'market_watch_scrip_model.dart';

class PreDefinedMWlist {
  List<WatchListValues>? nIFTY50NSE;
  List<WatchListValues>? nIFTYBANKNSE;
  List<WatchListValues>? sENSEXBSE;
  String? stat;

  PreDefinedMWlist(
      {this.nIFTY50NSE, this.nIFTYBANKNSE, this.sENSEXBSE, this.stat});

  PreDefinedMWlist.fromJson(Map<String, dynamic> json) {
    if (json['NIFTY50:NSE'] != null) {
      nIFTY50NSE = <WatchListValues>[];
      json['NIFTY50:NSE'].forEach((v) {
        nIFTY50NSE!.add(WatchListValues.fromJson(v));
      });
    }
    if (json['NIFTYBANK:NSE'] != null) {
      nIFTYBANKNSE = <WatchListValues>[];
      json['NIFTYBANK:NSE'].forEach((v) {
        nIFTYBANKNSE!.add(WatchListValues.fromJson(v));
      });
    }
    if (json['SENSEX:BSE'] != null) {
      sENSEXBSE = <WatchListValues>[];
      json['SENSEX:BSE'].forEach((v) {
        sENSEXBSE!.add(WatchListValues.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (nIFTY50NSE != null) {
      data['NIFTY50:NSE'] = nIFTY50NSE!.map((v) => v.toJson()).toList();
    }
    if (nIFTYBANKNSE != null) {
      data['NIFTYBANK:NSE'] = nIFTYBANKNSE!.map((v) => v.toJson()).toList();
    }
    if (sENSEXBSE != null) {
      data['SENSEX:BSE'] = sENSEXBSE!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}
 

class ApprovedPledgeListModel {
  bool? cached;
  int? count;
  Data? data;
  String? lastUpdated;
  String? stat;

  ApprovedPledgeListModel(
      {this.cached, this.count, this.data, this.lastUpdated, this.stat});

  ApprovedPledgeListModel.fromJson(Map<String, dynamic> json) {
    cached = json['cached'];
    count = json['count'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    lastUpdated = json['last_updated'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cached'] = this.cached;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['last_updated'] = this.lastUpdated;
    data['stat'] = this.stat;
    return data;
  }
}

class Data {
  Map<String, List<PledgeItem>>? cash;
  Map<String, List<PledgeItem>>? noncash;

  Data({this.cash, this.noncash});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['cash'] != null && json['cash'] is Map) {
      cash = {};
      json['cash'].forEach((key, value) {
        if (value != null && value is List) {
          cash![key] = value.map((v) => PledgeItem.fromJson(v)).toList();
        }
      });
    }
    if (json['noncash'] != null && json['noncash'] is Map) {
      noncash = {};
      json['noncash'].forEach((key, value) {
        if (value != null && value is List) {
          noncash![key] = value.map((v) => PledgeItem.fromJson(v)).toList();
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cash != null) {
      data['cash'] = cash!.map((key, value) => MapEntry(key, value.map((v) => v.toJson()).toList()));
    }
    if (noncash != null) {
      data['noncash'] = noncash!.map((key, value) => MapEntry(key, value.map((v) => v.toJson()).toList()));
    }
    return data;
  }
}

class PledgeItem {
  String? category;
  String? haircut;
  String? iSIN;
  String? name;
  String? price;
  String? sERIES;
  String? symbol;
  String? type;

  PledgeItem(
      {this.category,
      this.haircut,
      this.iSIN,
      this.name,
      this.price,
      this.sERIES,
      this.symbol,
      this.type});

  PledgeItem.fromJson(Map<String, dynamic> json) {
    category = json['Category'];
    haircut = json['Haircut'];
    iSIN = json['ISIN'];
    name = json['Name'];
    price = json['Price'];
    sERIES = json['SERIES'];
    symbol = json['Symbol'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Category'] = this.category;
    data['Haircut'] = this.haircut;
    data['ISIN'] = this.iSIN;
    data['Name'] = this.name;
    data['Price'] = this.price;
    data['SERIES'] = this.sERIES;
    data['Symbol'] = this.symbol;
    data['type'] = this.type;
    return data;
  }
}
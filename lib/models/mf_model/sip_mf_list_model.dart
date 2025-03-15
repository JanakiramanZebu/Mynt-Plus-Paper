class Sip_list_data {
  String? clientCode;
  String? stat;
  String? totalSipAmount;
  List<Xsip>? xsip;

  Sip_list_data({this.clientCode, this.stat, this.totalSipAmount, this.xsip});

  Sip_list_data.fromJson(Map<String, dynamic> json) {
    clientCode = json['client_code'];
    stat = json['stat'];
    totalSipAmount = json['total_sip_amount'];
    if (json['xsip'] != null) {
      xsip = <Xsip>[];
      json['xsip'].forEach((v) {
        xsip!.add(new Xsip.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_code'] = this.clientCode;
    data['stat'] = this.stat;
    data['total_sip_amount'] = this.totalSipAmount;
    if (this.xsip != null) {
      data['xsip'] = this.xsip!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Xsip {
  String? amount;
  String? dateTime;
  String? frequencyType;
  String? nextSipDate;
  String? liveCancel;
  String? schemeCode;
  String? schemeName;
  String? startDate;
  String? xsipRegId;

  Xsip(
      {this.amount,
      this.dateTime,
      this.frequencyType,
      this.nextSipDate,
      this.liveCancel,
      this.schemeCode,
      this.schemeName,
      this.startDate,
      this.xsipRegId});

  Xsip.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    dateTime = json['date_time'];
    frequencyType = json['frequency_type'];
    nextSipDate = json['next_sip_date'];
    liveCancel = json['live_cancel'];
    schemeCode = json['scheme_code'];
    schemeName = json['scheme_name'];
    startDate = json['start_date'];
    xsipRegId = json['xsip_reg_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['date_time'] = this.dateTime;
    data['frequency_type'] = this.frequencyType;
    data['next_sip_date'] = this.nextSipDate;
    data['live_cancel'] = this.liveCancel;
    data['scheme_code'] = this.schemeCode;
    data['scheme_name'] = this.schemeName;
    data['start_date'] = this.startDate;
    data['xsip_reg_id'] = this.xsipRegId;
    return data;
  }
}

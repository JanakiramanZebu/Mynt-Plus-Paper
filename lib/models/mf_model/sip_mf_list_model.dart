class Sip_list_data {
  List<Xsip>? data;
  String? stat;

  Sip_list_data({this.data, this.stat});

  Sip_list_data.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Xsip>[];
      json['data'].forEach((v) {
        data!.add(new Xsip.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = this.stat;
    return data;
  }
}

class Xsip {
  String? transCode;
  String? transNo;
  String? orderId;
  String? userId;
  String? memberCode;
  String? clientCode;
  String? remarks;
  String? status;
  String? name;
  String? stat;
  String? source;
  String? placedBy;
  String? iPAddress;
  String? datetime;
  String? folioNo;
  String? iSIN;
  String? dPFolioNo;
  String? settType;
  String? orderType;
  String? subOrderType;
  String? frequencyType;
  String? sIPRegnDate;
  String? sIPRegnNo;
  String? buySell;
  String? allRedeem;
  String? installmentAmount;
  String? startDate;
  String? endDate;
  String? schemeCode;
  String? NextSIPDate;

  Xsip(
      {this.transCode,
      this.transNo,
      this.orderId,
      this.userId,
      this.memberCode,
      this.clientCode,
      this.remarks,
      this.status,
      this.name,
      this.stat,
      this.source,
      this.placedBy,
      this.iPAddress,
      this.datetime,
      this.folioNo,
      this.iSIN,
      this.dPFolioNo,
      this.settType,
      this.orderType,
      this.subOrderType,
      this.frequencyType,
      this.sIPRegnDate,
      this.sIPRegnNo,
      this.buySell,
      this.allRedeem,
      this.installmentAmount,
      this.startDate,
      this.endDate,
      this.NextSIPDate,
      this.schemeCode});

  Xsip.fromJson(Map<String, dynamic> json) {
    transCode = json['TransCode'].toString();
    transNo = json['TransNo'].toString();
    orderId = json['OrderId'].toString();
    userId = json['UserId'].toString();
    memberCode = json['MemberCode'].toString();
    clientCode = json['ClientCode'].toString();
    remarks = json['Remarks'].toString();
    status = json['status'].toString();
    name = json['name'].toString();
    stat = json['stat'].toString();
    source = json['source'].toString();
    placedBy = json['placed_by'].toString();
    iPAddress = json['IPAddress'].toString();
    datetime = json['datetime'].toString();
    folioNo = json['FolioNo'].toString();
    iSIN = json['ISIN'].toString();
    dPFolioNo = json['DPFolioNo'].toString();
    settType = json['SettType'].toString();
    orderType = json['OrderType'].toString();
    subOrderType = json['SubOrderType'].toString();
    frequencyType = json['FrequencyType'].toString();
    sIPRegnDate = json['SIPRegnDate'].toString();
    sIPRegnNo = json['SIPRegnNo'].toString();
    buySell = json['buy_sell'].toString();
    allRedeem = json['AllRedeem'].toString();
    installmentAmount = json['InstallmentAmount'].toString();
    startDate = json['StartDate'].toString();
    endDate = json['EndDate'].toString();
    NextSIPDate = json['NextSIPDate'].toString();
    schemeCode = json['Scheme_Code'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TransCode'] = this.transCode;
    data['TransNo'] = this.transNo;
    data['OrderId'] = this.orderId;
    data['UserId'] = this.userId;
    data['MemberCode'] = this.memberCode;
    data['ClientCode'] = this.clientCode;
    data['Remarks'] = this.remarks;
    data['status'] = this.status;
    data['name'] = this.name;
    data['stat'] = this.stat;
    data['source'] = this.source;
    data['placed_by'] = this.placedBy;
    data['IPAddress'] = this.iPAddress;
    data['datetime'] = this.datetime;
    data['FolioNo'] = this.folioNo;
    data['ISIN'] = this.iSIN;
    data['DPFolioNo'] = this.dPFolioNo;
    data['SettType'] = this.settType;
    data['OrderType'] = this.orderType;
    data['SubOrderType'] = this.subOrderType;
    data['FrequencyType'] = this.frequencyType;
    data['SIPRegnDate'] = this.sIPRegnDate;
    data['SIPRegnNo'] = this.sIPRegnNo;
    data['buy_sell'] = this.buySell;
    data['AllRedeem'] = this.allRedeem;
    data['InstallmentAmount'] = this.installmentAmount;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    data['NextSIPDate'] = this.NextSIPDate;
    data['Scheme_Code'] = this.schemeCode;
    return data;
  }
}

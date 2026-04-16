class MFOrderBookModel {
  List<Data>? data;
  String? stat;

  MFOrderBookModel({this.data, this.stat});

  MFOrderBookModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != String) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != String) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class Data {
  String? amount;
  String? buysell;
  String? amcCode;
  String? clientcode;
  String? date;
  String? dateTime;
  String? foliono;
  String? internalReferNo;
  String? ordernumber;
  String? orderremarks;
  String? orderstatus;
  String? ordertype;
  String? schemename;
  String? settno;
  String? sipregndate;
  String? sipregnno;
  String? units;
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
  String? orderVal;
  String? folioNo;
  String? iSIN;
  String? dPFolioNo;
  String? settType;
  String? orderType;
  String? subOrderType;
  String? buySell;
  String? allRedeem;

  Data(
      {this.amount,
      this.amcCode,
      this.buysell,
      this.clientcode,
      this.date,
      this.dateTime,
      this.foliono,
      this.internalReferNo,
      this.ordernumber,
      this.orderremarks,
      this.orderstatus,
      this.ordertype,
      this.schemename,
      this.settno,
      this.sipregndate,
      this.sipregnno,
      this.units,
      this.transCode,
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
      this.orderVal,
      this.folioNo,
      this.iSIN,
      this.dPFolioNo,
      this.settType,
      this.orderType,
      this.subOrderType,
      this.buySell,
      this.allRedeem});

  Data.fromJson(Map<String, dynamic> json) {
    amount = json['amount']?.toString();
    buysell = json['buysell']?.toString();
    amcCode = json['amc_code']?.toString();
    clientcode = json['clientcode']?.toString();
    date = json['date']?.toString();
    dateTime = json['date_time']?.toString();
    foliono = json['foliono']?.toString();
    internalReferNo = json['internal_refer_no']?.toString();
    ordernumber = json['ordernumber']?.toString();
    orderremarks = json['orderremarks']?.toString();
    orderstatus = json['orderstatus']?.toString();
    ordertype = json['ordertype']?.toString();
    schemename = json['schemename']?.toString();
    settno = json['settno']?.toString();
    sipregndate = json['sipregndate']?.toString();
    sipregnno = json['sipregnno']?.toString();
    units = json['units']?.toString();
    transCode = json['TransCode']?.toString();
    transNo = json['TransNo']?.toString();
    orderId = json['OrderId']?.toString();
    userId = json['UserId']?.toString();
    memberCode = json['MemberCode']?.toString();
    clientCode = json['ClientCode']?.toString();
    remarks = json['Remarks']?.toString();
    status = json['status']?.toString();
    name = json['name']?.toString();
    stat = json['stat']?.toString();
    source = json['source']?.toString();
    placedBy = json['placed_by']?.toString();
    iPAddress = json['IPAddress']?.toString();
    datetime = json['datetime']?.toString();
    orderVal = json['OrderVal']?.toString();
    folioNo = json['FolioNo']?.toString();
    iSIN = json['ISIN']?.toString();
    dPFolioNo = json['DPFolioNo']?.toString();
    settType = json['SettType']?.toString();
    orderType = json['OrderType']?.toString();
    subOrderType = json['SubOrderType']?.toString();
    buySell = json['buy_sell']?.toString();
    allRedeem = json['AllRedeem']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['buysell'] = buysell;
    data['amc_code'] = amcCode;
    data['clientcode'] = clientcode;
    data['date'] = date;
    data['date_time'] = dateTime;
    data['foliono'] = foliono;
    data['internal_refer_no'] = internalReferNo;
    data['ordernumber'] = ordernumber;
    data['orderremarks'] = orderremarks;
    data['orderstatus'] = orderstatus;
    data['ordertype'] = ordertype;
    data['schemename'] = schemename;
    data['settno'] = settno;
    data['sipregndate'] = sipregndate;
    data['sipregnno'] = sipregnno;
    data['units'] = units;
    data['TransCode'] = transCode;
    data['TransNo'] = transNo;
    data['OrderId'] = orderId;
    data['UserId'] = userId;
    data['MemberCode'] = memberCode;
    data['ClientCode'] = clientCode;
    data['Remarks'] = remarks;
    data['status'] = status;
    data['name'] = name;
    data['stat'] = stat;
    data['source'] = source;
    data['placed_by'] = placedBy;
    data['IPAddress'] = iPAddress;
    data['datetime'] = datetime;
    data['OrderVal'] = orderVal;
    data['FolioNo'] = folioNo;
    data['ISIN'] = iSIN;
    data['DPFolioNo'] = dPFolioNo;
    data['SettType'] = settType;
    data['OrderType'] = orderType;
    data['SubOrderType'] = subOrderType;
    data['buy_sell'] = buySell;
    data['AllRedeem'] = allRedeem;
    return data;
  }
}

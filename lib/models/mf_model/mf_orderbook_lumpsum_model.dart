class MFOrderBookModel {
  List<Data>? data;
  String? stat;

  MFOrderBookModel({this.data, this.stat});

  MFOrderBookModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
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
  Null? folioNo;
  String? iSIN;
  Null? dPFolioNo;
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
      this.allRedeem
      });

  Data.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    buysell = json['buysell'];
    amcCode = json['amc_code'];
    clientcode = json['clientcode'];
    date = json['date'];
    dateTime = json['date_time'];
    foliono = json['foliono'];
    internalReferNo = json['internal_refer_no'];
    ordernumber = json['ordernumber'];
    orderremarks = json['orderremarks'];
    orderstatus = json['orderstatus'];
    ordertype = json['ordertype'];
    schemename = json['schemename'];
    settno = json['settno'];
    sipregndate = json['sipregndate'];
    sipregnno = json['sipregnno'];
    units = json['units'];
    transCode = json['TransCode'];
    transNo = json['TransNo'];
    orderId = json['OrderId'];
    userId = json['UserId'];
    memberCode = json['MemberCode'];
    clientCode = json['ClientCode'];
    remarks = json['Remarks'];
    status = json['status'];
    name = json['name'];
    stat = json['stat'];
    source = json['source'];
    placedBy = json['placed_by'];
    iPAddress = json['IPAddress'];
    datetime = json['datetime'];
    orderVal = json['OrderVal'];
    folioNo = json['FolioNo'];
    iSIN = json['ISIN'];
    dPFolioNo = json['DPFolioNo'];
    settType = json['SettType'];
    orderType = json['OrderType'];
    subOrderType = json['SubOrderType'];
    buySell = json['buy_sell'];
    allRedeem = json['AllRedeem'];
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

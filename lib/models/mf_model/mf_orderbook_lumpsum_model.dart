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

  Data(
      {this.amount,
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
      this.units});

  Data.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    buysell = json['buysell'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['buysell'] = buysell;
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
    return data;
  }
}

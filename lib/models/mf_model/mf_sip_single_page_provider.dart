class Sip_single_page {
  String? clientCode;
  String? installmentAmount;
  List ? invList;
  String? nextInstallmentDate;
  String? sipregnno;
  String? stat;
   String? liveCancel;
    String? schemename;
     String? Msg;
  String? internalrefernumber;
  String?frequency_type;

  Sip_single_page(
      {this.clientCode,
      this.installmentAmount,
      this.invList,
      this.liveCancel,
      this.nextInstallmentDate,
      this.sipregnno,
       this.schemename,
      this.stat,
      this.internalrefernumber,
      this.Msg,
      this.frequency_type});

  Sip_single_page.fromJson(Map<String, dynamic> json) {
    clientCode = json['client_code'];
    installmentAmount = json['installment_amount'];
    internalrefernumber = json['internalrefernumber'];
    if (json['inv_list'] != null) {
      invList =json['inv_list'];
      };
      liveCancel = json['live_cancel'];
      schemename = json['schemename'];
    nextInstallmentDate = json['next_installment_date'];
    sipregnno = json['sipregnno'];
    stat = json['stat'];
    Msg = json['msg'];
    frequency_type = json['frequency_type'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_code'] = this.clientCode;
    data['installment_amount'] = this.installmentAmount;
    data['internalrefernumber'] = this.internalrefernumber;
    if (this.invList != null) {
      data['inv_list'] = this.invList!.map((v) => v.toJson()).toList();
    }
    data['live_cancel'] = this.liveCancel;
     data['schemename'] = this.schemename;
    data['next_installment_date'] = this.nextInstallmentDate;
    data['sipregnno'] = this.sipregnno;
    data['stat'] = this.stat;
     data['msg'] = this.Msg;
     data['frequency_type'] = this.frequency_type;
    return data;
  }
}

class InvList {
  String? iSIN;
  String? amcCode;
  String? amount;
  String? date;
  String? foliono;
  String? installments;
  String? ordernumber;
  String? orderremarks;
  String? orderstatus;
  String? registerCancel;
  String? schemename;
  String? sipregndate;
  

  InvList(
      {this.iSIN,
      this.amcCode,
      this.amount,
      this.date,
      this.foliono,
      this.installments,
      this.ordernumber,
      this.orderremarks,
      this.orderstatus,
      this.registerCancel,
      this.schemename,
      this.sipregndate});

  InvList.fromJson(Map<String, dynamic> json) {
    iSIN = json['ISIN'];
    amcCode = json['amc_code'];
    amount = json['amount'];
    date = json['date'];
    foliono = json['foliono'];
    installments = json['installments'];
    ordernumber = json['ordernumber'];
    orderremarks = json['orderremarks'];
    orderstatus = json['orderstatus'];
    registerCancel = json['register_cancel'];
    schemename = json['schemename'];
    sipregndate = json['sipregndate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ISIN'] = this.iSIN;
    data['amc_code'] = this.amcCode;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['foliono'] = this.foliono;
    data['installments'] = this.installments;
    data['ordernumber'] = this.ordernumber;
    data['orderremarks'] = this.orderremarks;
    data['orderstatus'] = this.orderstatus;
    data['register_cancel'] = this.registerCancel;
    data['schemename'] = this.schemename;
    data['sipregndate'] = this.sipregndate;
    return data;
  }
}


class LedgerModelData{
  String? closingBalance;
  List<Cr>? cr;
  String? crAmt;
  List<Dr>? dr;
  String? drAmt;
  List<FullStat>? fullStat;
  String? openingBalance;

  LedgerModelData(
      {this.closingBalance,
      this.cr,
      this.crAmt,
      this.dr,
      this.drAmt,
      this.fullStat,
      this.openingBalance});


LedgerModelData clone() {
    return LedgerModelData(
      closingBalance: closingBalance,
      cr: cr?.map((e) => e.clone()).toList(),
      crAmt: crAmt,
      dr: dr?.map((e) => e.clone()).toList(),
      drAmt: drAmt,
      fullStat: fullStat?.map((e) => e.clone()).toList(),
      openingBalance: openingBalance,
    );
  }



  LedgerModelData.fromJson(Map<String, dynamic> json) {
    closingBalance = json['closing_balance'].toString();
    if (json['cr'] != null) {
      cr = <Cr>[];
      json['cr'].forEach((v) {
        cr!.add(Cr.fromJson(v));
      });
    }
    crAmt = json['cr_amt'].toString();
    if (json['dr'] != null) {
      dr = <Dr>[];
      json['dr'].forEach((v) {
        dr!.add(Dr.fromJson(v));
      });
    }
    drAmt = json['dr_amt'].toString();
    if (json['full_stat'] != null) {
      fullStat = <FullStat>[];
      json['full_stat'].forEach((v) {
        fullStat!.add(FullStat.fromJson(v));
      });
    }
    openingBalance = json['opening_balance'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['closing_balance'] = closingBalance;
    if (cr != null) {
      data['cr'] = cr!.map((v) => v.toJson()).toList();
    }
    data['cr_amt'] = crAmt;
    if (dr != null) {
      data['dr'] = dr!.map((v) => v.toJson()).toList();
    }
    data['dr_amt'] = drAmt;
    if (fullStat != null) {
      data['full_stat'] = fullStat!.map((v) => v.toJson()).toList();
    }
    data['opening_balance'] = openingBalance;
    return data;
  }

  where(bool Function(dynamic o) param0) {}
}

class Cr {
  String? aCCOUNTCODE;
  String? aCCOUNTNAME;
  String? bILLNO;
  String? cOCD;
  String? cRAMT;
  String? dRAMT;
  String? mKTTYPE;
  String? nARRATION;
  String? nETAMT;
  String? oPENINGBALANCE;
  String? sETLPAYINDATE;
  String? sETTLEMENTNO;
  String? tRANSTYPE;
  String? tYPE;
  String? vOUCHERDATE;
  String? bill;
  String? index;

  Cr(
      {this.aCCOUNTCODE,
      this.aCCOUNTNAME,
      this.bILLNO,
      this.cOCD,
      this.cRAMT,
      this.dRAMT,
      this.mKTTYPE,
      this.nARRATION,
      this.nETAMT,
      this.oPENINGBALANCE,
      this.sETLPAYINDATE,
      this.sETTLEMENTNO,
      this.tRANSTYPE,
      this.tYPE,
      this.vOUCHERDATE,
      this.bill,
      this.index});


  Cr clone() {
    return Cr(
      aCCOUNTCODE:aCCOUNTCODE,
      aCCOUNTNAME:aCCOUNTNAME,
      bILLNO:bILLNO,
      cOCD:cOCD,
      cRAMT:cRAMT,
      dRAMT:dRAMT,
      mKTTYPE:mKTTYPE,
      nARRATION:nARRATION,
      nETAMT:nETAMT,
      oPENINGBALANCE:oPENINGBALANCE,
      sETLPAYINDATE:sETLPAYINDATE,
      sETTLEMENTNO:sETTLEMENTNO,
      tRANSTYPE:tRANSTYPE,
      tYPE:tYPE,
      vOUCHERDATE:vOUCHERDATE,
      bill:bill,
      index:index
    );
  }
  Cr.fromJson(Map<String, dynamic> json) {
    aCCOUNTCODE = json['ACCOUNTCODE'];
    aCCOUNTNAME = json['ACCOUNTNAME'];
    bILLNO = json['BILLNO'];
    cOCD = json['COCD'];
    cRAMT = json['CR_AMT'].toString();
    dRAMT = json['DR_AMT'].toString();
    mKTTYPE = json['MKT_TYPE'];
    nARRATION = json['NARRATION'];
    nETAMT = json['NET_AMT'].toString();
    oPENINGBALANCE = json['OPENINGBALANCE'];
    sETLPAYINDATE = json['SETL_PAYINDATE'];
    sETTLEMENTNO = json['SETTLEMENT_NO'];
    tRANSTYPE = json['TRANS_TYPE'];
    tYPE = json['TYPE'];
    vOUCHERDATE = json['VOUCHERDATE'];
    bill = json['bill'];
    index = json['index'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ACCOUNTCODE'] = aCCOUNTCODE;
    data['ACCOUNTNAME'] = aCCOUNTNAME;
    data['BILLNO'] = bILLNO;
    data['COCD'] = cOCD;
    data['CR_AMT'] = cRAMT;
    data['DR_AMT'] = dRAMT;
    data['MKT_TYPE'] = mKTTYPE;
    data['NARRATION'] = nARRATION;
    data['NET_AMT'] = nETAMT;
    data['OPENINGBALANCE'] = oPENINGBALANCE;
    data['SETL_PAYINDATE'] = sETLPAYINDATE;
    data['SETTLEMENT_NO'] = sETTLEMENTNO;
    data['TRANS_TYPE'] = tRANSTYPE;
    data['TYPE'] = tYPE;
    data['VOUCHERDATE'] = vOUCHERDATE;
    data['bill'] = bill;
    data['index'] = index;
    return data;
  }
}

class Dr {
  String? aCCOUNTCODE;
  String? aCCOUNTNAME;
  String? bILLNO;
  String? cOCD;
  String? cRAMT;
  String? dRAMT;
  String? mKTTYPE;
  String? nARRATION;
  String? nETAMT;
  String? oPENINGBALANCE;
  String? sETLPAYINDATE;
  String? sETTLEMENTNO;
  String? tRANSTYPE;
  String? tYPE;
  String? vOUCHERDATE;
  String? bill;
  String? index;

  Dr(
      {this.aCCOUNTCODE,
      this.aCCOUNTNAME,
      this.bILLNO,
      this.cOCD,
      this.cRAMT,
      this.dRAMT,
      this.mKTTYPE,
      this.nARRATION,
      this.nETAMT,
      this.oPENINGBALANCE,
      this.sETLPAYINDATE,
      this.sETTLEMENTNO,
      this.tRANSTYPE,
      this.tYPE,
      this.vOUCHERDATE,
      this.bill,
      this.index});

Dr clone() {
    return Dr(
      aCCOUNTCODE:aCCOUNTCODE,
      aCCOUNTNAME:aCCOUNTNAME,
      bILLNO:bILLNO,
      cOCD:cOCD,
      cRAMT:cRAMT,
      dRAMT:dRAMT,
      mKTTYPE:mKTTYPE,
      nARRATION:nARRATION,
      nETAMT:nETAMT,
      oPENINGBALANCE:oPENINGBALANCE,
      sETLPAYINDATE:sETLPAYINDATE,
      sETTLEMENTNO:sETTLEMENTNO,
      tRANSTYPE:tRANSTYPE,
      tYPE:tYPE,
      vOUCHERDATE:vOUCHERDATE,
      bill:bill,
      index:index,
    );
  }




  Dr.fromJson(Map<String, dynamic> json) {
    aCCOUNTCODE = json['ACCOUNTCODE'];
    aCCOUNTNAME = json['ACCOUNTNAME'];
    bILLNO = json['BILLNO'];
    cOCD = json['COCD'];
    cRAMT = json['CR_AMT'].toString();
    dRAMT = json['DR_AMT'].toString();
    mKTTYPE = json['MKT_TYPE'];
    nARRATION = json['NARRATION'];
    nETAMT = json['NET_AMT'].toString();
    oPENINGBALANCE = json['OPENINGBALANCE'];
    sETLPAYINDATE = json['SETL_PAYINDATE'];
    sETTLEMENTNO = json['SETTLEMENT_NO'];
    tRANSTYPE = json['TRANS_TYPE'];
    tYPE = json['TYPE'];
    vOUCHERDATE = json['VOUCHERDATE'];
    bill = json['bill'];
    index = json['index'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ACCOUNTCODE'] = aCCOUNTCODE;
    data['ACCOUNTNAME'] = aCCOUNTNAME;
    data['BILLNO'] = bILLNO;
    data['COCD'] = cOCD;
    data['CR_AMT'] = cRAMT;
    data['DR_AMT'] = dRAMT;
    data['MKT_TYPE'] = mKTTYPE;
    data['NARRATION'] = nARRATION;
    data['NET_AMT'] = nETAMT;
    data['OPENINGBALANCE'] = oPENINGBALANCE;
    data['SETL_PAYINDATE'] = sETLPAYINDATE;
    data['SETTLEMENT_NO'] = sETTLEMENTNO;
    data['TRANS_TYPE'] = tRANSTYPE;
    data['TYPE'] = tYPE;
    data['VOUCHERDATE'] = vOUCHERDATE;
    data['bill'] = bill;
    data['index'] = index;
    return data;
  }
}

class FullStat {
  String? aCCOUNTCODE;
  String? aCCOUNTNAME;
  String? bILLNO;
  String? cOCD;
  String? cRAMT;
  String? dRAMT;
  String? mKTTYPE;
  String? nARRATION;
  String? nETAMT;
  String? oPENINGBALANCE;
  String? sETLPAYINDATE;
  String? sETTLEMENTNO;
  String? sortNo;
  String? tRANSTYPE;
  String? tYPE;
  String? vOUCHERDATE;
  String? bill;
  String? index;

  FullStat(
      {this.aCCOUNTCODE,
      this.aCCOUNTNAME,
      this.bILLNO,
      this.cOCD,
      this.cRAMT,
      this.dRAMT,
      this.mKTTYPE,
      this.nARRATION,
      this.nETAMT,
      this.oPENINGBALANCE,
      this.sETLPAYINDATE,
      this.sETTLEMENTNO,
      this.sortNo,
      this.tRANSTYPE,
      this.tYPE,
      this.vOUCHERDATE,
      this.bill,
      this.index});

  FullStat clone() {
    return FullStat(
              aCCOUNTCODE:aCCOUNTCODE,
              aCCOUNTNAME:aCCOUNTNAME,
              bILLNO:bILLNO,
              cOCD:cOCD,
              cRAMT:cRAMT,
              dRAMT:dRAMT,
              mKTTYPE:mKTTYPE,
              nARRATION:nARRATION,
              nETAMT:nETAMT,
              oPENINGBALANCE:oPENINGBALANCE,
              sETLPAYINDATE:sETLPAYINDATE,
              sETTLEMENTNO:sETTLEMENTNO,
              sortNo:sortNo,
              tRANSTYPE:tRANSTYPE,
              tYPE:tYPE,
              vOUCHERDATE:vOUCHERDATE,
              bill:bill,
              index:index
    );
  }


  FullStat.fromJson(Map<String, dynamic> json) {
    aCCOUNTCODE = json['ACCOUNTCODE'];
    aCCOUNTNAME = json['ACCOUNTNAME'];
    bILLNO = json['BILLNO'];
    cOCD = json['COCD'];
    cRAMT = json['CR_AMT'].toString();
    dRAMT = json['DR_AMT'].toString();
    mKTTYPE = json['MKT_TYPE'];
    nARRATION = json['NARRATION'];
    nETAMT = json['NET_AMT'].toString();
    oPENINGBALANCE = json['OPENINGBALANCE'];
    sETLPAYINDATE = json['SETL_PAYINDATE'];
    sETTLEMENTNO = json['SETTLEMENT_NO'];
    sortNo = json['Sort_No'].toString();
    tRANSTYPE = json['TRANS_TYPE'];
    tYPE = json['TYPE'];
    vOUCHERDATE = json['VOUCHERDATE'];
    bill = json['bill'];
    index = json['index'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ACCOUNTCODE'] = aCCOUNTCODE;
    data['ACCOUNTNAME'] = aCCOUNTNAME;
    data['BILLNO'] = bILLNO;
    data['COCD'] = cOCD;
    data['CR_AMT'] = cRAMT;
    data['DR_AMT'] = dRAMT;
    data['MKT_TYPE'] = mKTTYPE;
    data['NARRATION'] = nARRATION;
    data['NET_AMT'] = nETAMT;
    data['OPENINGBALANCE'] = oPENINGBALANCE;
    data['SETL_PAYINDATE'] = sETLPAYINDATE;
    data['SETTLEMENT_NO'] = sETTLEMENTNO;
    data['Sort_No'] = sortNo;
    data['TRANS_TYPE'] = tRANSTYPE;
    data['TYPE'] = tYPE;
    data['VOUCHERDATE'] = vOUCHERDATE;
    data['bill'] = bill;
    data['index'] = index;
    return data;
  }
}


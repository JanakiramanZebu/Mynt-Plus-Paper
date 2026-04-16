class ClientDetailModel {
  String? actSts;
  String? actid;
  String? addr;
  String? addrcity;
  String? addroffice;
  String? addrstate;
  List<Bankdetails>? bankdetails;
  String? cliname;
  String? creatdte;
  String? creattme;
  String? dob;
  List<DpAcctNum>? dpAcctNum;
  String? email;
  // List<String>? exarr;
  String? mNum;

  String? pan;
  String? requestTime;
  String? stat;
  String? emsg;

  ClientDetailModel(
      {this.actSts,
      this.actid,
      this.addr,
      this.addrcity,
      this.addroffice,
      this.addrstate,
      this.bankdetails,
      this.cliname,
      this.creatdte,
      this.creattme,
      this.dob,
      this.dpAcctNum,
      this.email,
      // this.exarr,
      this.mNum,
      this.pan,
      this.requestTime,
      this.stat,
      this.emsg});

  ClientDetailModel.fromJson(Map<String, dynamic> json) {
    actSts = json['act_sts'];
    actid = json['actid'];
    addr = json['addr'];
    addrcity = json['addrcity'];
    addroffice = json['addroffice'];
    addrstate = json['addrstate'];
    if (json['bankdetails'] != null) {
      bankdetails = <Bankdetails>[];
      json['bankdetails'].forEach((v) {
        bankdetails!.add(Bankdetails.fromJson(v));
      });
    }
    cliname = json['cliname'];
    creatdte = json['creatdte'];
    creattme = json['creattme'];
    dob = json['dob'];
    if (json['dp_acct_num'] != null) {
      dpAcctNum = <DpAcctNum>[];
      json['dp_acct_num'].forEach((v) {
        dpAcctNum!.add(DpAcctNum.fromJson(v));
      });
    }
    email = json['email'];
    // exarr = json['exarr'].cast<String>();
    mNum = json['m_num'];

    pan = json['pan'];
    requestTime = json['request_time'];
    stat = json['stat'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['act_sts'] = actSts;
    data['actid'] = actid;
    data['addr'] = addr;
    data['addrcity'] = addrcity;
    data['addroffice'] = addroffice;
    data['addrstate'] = addrstate;
    if (bankdetails != null) {
      data['bankdetails'] = bankdetails!.map((v) => v.toJson()).toList();
    }
    data['cliname'] = cliname;
    data['creatdte'] = creatdte;
    data['creattme'] = creattme;
    data['dob'] = dob;
    if (dpAcctNum != null) {
      data['dp_acct_num'] = dpAcctNum!.map((v) => v.toJson()).toList();
    }
    data['email'] = email;
    // data['exarr'] = exarr;
    data['m_num'] = mNum;

    data['pan'] = pan;
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['emsg'] = emsg;
    return data;
  }
}

class Bankdetails {
  String? acctnum;
  String? bankn;
  String? ifscCode;

  Bankdetails({this.acctnum, this.bankn, this.ifscCode});

  Bankdetails.fromJson(Map<String, dynamic> json) {
    acctnum = json['acctnum'];
    bankn = json['bankn'];
    ifscCode = json['ifsc_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['acctnum'] = acctnum;
    data['bankn'] = bankn;
    data['ifsc_code'] = ifscCode;
    return data;
  }
}

class DpAcctNum {
  String? dpnum;

  DpAcctNum({this.dpnum});

  DpAcctNum.fromJson(Map<String, dynamic> json) {
    dpnum = json['dpnum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dpnum'] = dpnum;
    return data;
  }
}

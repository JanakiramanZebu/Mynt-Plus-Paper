class OrderHistoryModel {
  String? stat;
  String? norenordno;
  String? kidid;
  String? uid;
  String? srcUid;
  String? actid;
  String? exch;
  String? tsym;
  String? qty;
  String? trantype;
  String? prctyp;
  String? ret;
  String? rejby;
  String? pan;
  String? ordersource;
  String? token;
  String? pp;
  String? ls;
  String? ti;
  String? prc;
  String? dscqty;
  String? sPrdtAli;
  String? prd;
  String? status;
  String? stIntrn;
  String? rpt;
  String? ordenttm;
  String? norentm;
  String? rejreason;
  String? intropExch;String? emsg;

  OrderHistoryModel(
      {this.stat,
      this.norenordno,
      this.kidid,
      this.uid,
      this.srcUid,
      this.actid,
      this.exch,
      this.tsym,
      this.qty,
      this.trantype,
      this.prctyp,
      this.ret,
      this.rejby,
      this.pan,
      this.ordersource,
      this.token,
      this.pp,
      this.ls,
      this.ti,
      this.prc,
      this.dscqty,
      this.sPrdtAli,
      this.prd,
      this.status,
      this.stIntrn,
      this.rpt,
      this.ordenttm,
      this.norentm,
      this.rejreason,
      this.intropExch,this.emsg});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    norenordno = json['norenordno'];
    kidid = json['kidid'];
    uid = json['uid'];
    srcUid = json['src_uid'];
    actid = json['actid'];
    exch = json['exch'];
    tsym = json['tsym'];
    qty = json['qty'];
    trantype = json['trantype'];
    prctyp = json['prctyp'];
    ret = json['ret'];
    rejby = json['rejby'];
    pan = json['pan'];
    ordersource = json['ordersource'];
    token = json['token'];
    pp = json['pp'];
    ls = json['ls'];
    ti = json['ti'];
    prc = json['prc'];
    dscqty = json['dscqty'];
    sPrdtAli = json['s_prdt_ali'];
    prd = json['prd'];
    status = json['status'];
    stIntrn = json['st_intrn'];
    rpt = json['rpt'];
    ordenttm = json['ordenttm'];
    norentm = json['norentm'];
    rejreason = json['rejreason'];
    intropExch = json['introp_exch'];
    emsg=json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['norenordno'] = norenordno;
    data['kidid'] = kidid;
    data['uid'] = uid;
    data['src_uid'] = srcUid;
    data['actid'] = actid;
    data['exch'] = exch;
    data['tsym'] = tsym;
    data['qty'] = qty;
    data['trantype'] = trantype;
    data['prctyp'] = prctyp;
    data['ret'] = ret;
    data['rejby'] = rejby;
    data['pan'] = pan;
    data['ordersource'] = ordersource;
    data['token'] = token;
    data['pp'] = pp;
    data['ls'] = ls;
    data['ti'] = ti;
    data['prc'] = prc;
    data['dscqty'] = dscqty;
    data['s_prdt_ali'] = sPrdtAli;
    data['prd'] = prd;
    data['status'] = status;
    data['st_intrn'] = stIntrn;
    data['rpt'] = rpt;
    data['ordenttm'] = ordenttm;
    data['norentm'] = norentm;
    data['rejreason'] = rejreason;
    data['introp_exch'] = intropExch;
    data['emsg']=emsg;
    return data;
  }
}

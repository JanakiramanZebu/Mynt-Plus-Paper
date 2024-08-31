class SipOrderBookModel {
  String? stat;
  List<SipDetails>? sipDetails;

  SipOrderBookModel({this.stat, this.sipDetails});

  SipOrderBookModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    if (json['SipDetails'] != null) {
      sipDetails = <SipDetails>[];
      json['SipDetails'].forEach((v) {
        sipDetails!.add(SipDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    if (sipDetails != null) {
      data['SipDetails'] = sipDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SipDetails {
  String? regDate;
  String? startDate;
  String? frequency;
  String? endPeriod;
  String? sipName;
  String? actid;
  String? uid;
  String? brkname;
  List<Scrips>? scrips;
  Internal? internal;

  SipDetails(
      {this.regDate,
      this.startDate,
      this.frequency,
      this.endPeriod,
      this.sipName,
      this.actid,
      this.uid,
      this.brkname,
      this.scrips,
      this.internal});

  SipDetails.fromJson(Map<String, dynamic> json) {
    regDate = json['reg_date'];
    startDate = json['start_date'];
    frequency = json['frequency'];
    endPeriod = json['end_period'];
    sipName = json['sip_name'];
    actid = json['actid'];
    uid = json['uid'];
    brkname = json['brkname'];
    if (json['Scrips'] != null) {
      scrips = <Scrips>[];
      json['Scrips'].forEach((v) {
        scrips!.add(Scrips.fromJson(v));
      });
    }
    internal =
        json['internal'] != null ? Internal.fromJson(json['internal']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reg_date'] = regDate;
    data['start_date'] = startDate;
    data['frequency'] = frequency;
    data['end_period'] = endPeriod;
    data['sip_name'] = sipName;
    data['actid'] = actid;
    data['uid'] = uid;
    data['brkname'] = brkname;
    if (scrips != null) {
      data['Scrips'] = scrips!.map((v) => v.toJson()).toList();
    }
    if (internal != null) {
      data['internal'] = internal!.toJson();
    }
    return data;
  }
}

class Scrips {
  String? exch;
  String? token;
  String? tsym;
  String? sprdtali;
  String? prd;
  String? qty;
  String? sipType;
  String? ltp;
  String? change;
  String? close;
  String? perChange;

  Scrips({
    this.exch,
    this.token,
    this.tsym,
    this.sprdtali,
    this.prd,
    this.qty,
    this.sipType,
    this.ltp,
    this.change,
    this.close,
    this.perChange,
  });

  Scrips.fromJson(Map<String, dynamic> json) {
    exch = json['exch'];
    token = json['token'];
    tsym = json['tsym'];
    sprdtali = json['s_prdt_ali'];
    prd = json['prod'];
    qty = json['qty'];
    sipType = json['sip_type'];
    ltp = json['ltp'];
    change = json['change'];
    close = json['close'];
    perChange = json['perChange'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exch'] = exch;
    data['token'] = token;
    data['tsym'] = tsym;
    data['s_prdt_ali'] = sprdtali;
    data['prod'] = prd;
    data['qty'] = qty;
    data['sip_type'] = sipType;
    data['ltp'] = ltp;
    data['change'] = change;
    data['close'] = close;
    data['perChange'] = perChange;
    return data;
  }
}

class Internal {
  String? prevExecDate;
  String? dueDate;
  String? execDate;
  String? period;
  String? active;
  String? sipId;
  String? paused;

  Internal(
      {this.prevExecDate,
      this.dueDate,
      this.execDate,
      this.period,
      this.active,
      this.sipId,
      this.paused});

  Internal.fromJson(Map<String, dynamic> json) {
    prevExecDate = json['PrevExecDate'];
    dueDate = json['DueDate'];
    execDate = json['ExecDate'];
    period = json['period'];
    active = json['active'];
    sipId = json['SipId'];
    paused = json['paused'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PrevExecDate'] = prevExecDate;
    data['DueDate'] = dueDate;
    data['ExecDate'] = execDate;
    data['period'] = period;
    data['active'] = active;
    data['SipId'] = sipId;
    data['paused'] = paused;
    return data;
  }
}

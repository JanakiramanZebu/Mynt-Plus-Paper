class GetBrokerageModel {
  String? requestTime;
  String? stat;
  String? brkageAmt;
  String? sttAmt;
  String? exchChrg;
  String? sebiChrg;
  String? stampDuty;
  String? clrChrg;
  String? gst;
  String? ipftAmt;
  String? cmAmt;
  String? totChrg;
  String? remarks;
  String? url;
  String? emsg;

  GetBrokerageModel(
      {this.requestTime,
      this.stat,
      this.brkageAmt,
      this.sttAmt,
      this.exchChrg,
      this.sebiChrg,
      this.stampDuty,
      this.clrChrg,
      this.gst,
      this.ipftAmt,
      this.cmAmt,
      this.totChrg,
      this.remarks,
      this.url,
      this.emsg});

  GetBrokerageModel.fromJson(Map<String, dynamic> json) {
    requestTime = json['request_time'];
    stat = json['stat'];
    brkageAmt = json['brkage_amt'];
    sttAmt = json['stt_amt'];
    exchChrg = json['exch_chrg'];
    sebiChrg = json['sebi_chrg'];
    stampDuty = json['stamp_duty'];
    clrChrg = json['clr_chrg'];
    gst = json['gst'];
    ipftAmt = json['ipft_amt'];
    cmAmt = json['cm_amt'];
    totChrg = json['tot_chrg'];
    remarks = json['remarks'];
    url = json['url'];
    emsg = json['emsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_time'] = requestTime;
    data['stat'] = stat;
    data['brkage_amt'] = brkageAmt;
    data['stt_amt'] = sttAmt;
    data['exch_chrg'] = exchChrg;
    data['sebi_chrg'] = sebiChrg;
    data['stamp_duty'] = stampDuty;
    data['clr_chrg'] = clrChrg;
    data['gst'] = gst;
    data['ipft_amt'] = ipftAmt;
    data['cm_amt'] = cmAmt;
    data['tot_chrg'] = totChrg;
    data['remarks'] = remarks;
    data['url'] = url;
    data['emsg'] = emsg;
    return data;
  }
}

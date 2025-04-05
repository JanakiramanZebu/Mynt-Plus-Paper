class PnlSummaryModel {
  List<Data>? data;

  PnlSummaryModel({this.data});

  PnlSummaryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String ? bAMT;
  String? bQTY;
  String? bRATE;
  String? cLIENTID;
  String? cOMPANYCODE;
  String? fULLSCRIPSYMBOL;
  String? nETAMT;
  String? nETQTY;
  String? nRATE;
  String? sAMT;
  String? sQTY;
  String? sRATE;
  String? tRADEDATE;

  Data(
      {this.bAMT,
      this.bQTY,
      this.bRATE,
      this.cLIENTID,
      this.cOMPANYCODE,
      this.fULLSCRIPSYMBOL,
      this.nETAMT,
      this.nETQTY,
      this.nRATE,
      this.sAMT,
      this.sQTY,
      this.sRATE,
      this.tRADEDATE});

  Data.fromJson(Map<String, dynamic> json) {
    bAMT = json['BAMT'].toString();
    bQTY = json['BQTY'].toString();
    bRATE = json['BRATE'].toString();
    cLIENTID = json['CLIENT_ID'].toString();
    cOMPANYCODE = json['COMPANY_CODE'].toString();
    fULLSCRIPSYMBOL = json['FULL_SCRIP_SYMBOL'].toString();
    nETAMT = json['NETAMT'].toString();
    nETQTY = json['NETQTY'].toString();
    nRATE = json['NRATE'].toString();
    sAMT = json['SAMT'].toString();
    sQTY = json['SQTY'].toString();
    sRATE = json['SRATE'].toString();
    tRADEDATE = json['TRADE_DATE'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BAMT'] = bAMT;
    data['BQTY'] = bQTY;
    data['BRATE'] = bRATE;
    data['CLIENT_ID'] = cLIENTID;
    data['COMPANY_CODE'] = cOMPANYCODE;
    data['FULL_SCRIP_SYMBOL'] = fULLSCRIPSYMBOL;
    data['NETAMT'] = nETAMT;
    data['NETQTY'] = nETQTY;
    data['NRATE'] = nRATE;
    data['SAMT'] = sAMT;
    data['SQTY'] = sQTY;
    data['SRATE'] = sRATE;
    data['TRADE_DATE'] = tRADEDATE;
    return data;
  }
}

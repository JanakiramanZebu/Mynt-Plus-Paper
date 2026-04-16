// ignore_for_file: unnecessary_this


class ExchangeStatusModel {
  String? stat;
  String? exch;
  String? exchstat;
  String? exchtype;
  String? description;
  String? norentm;
  String? norenNsecs;
  String? exchTm;
  String? emsg;


  ExchangeStatusModel(
      {this.stat,
      this.exch,
      this.exchstat,
      this.exchtype,
      this.description,
      this.norentm,
      this.norenNsecs,
      this.exchTm,
      this.emsg});


  ExchangeStatusModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    exch = json['exch'];
    exchstat = json['exchstat'];
    exchtype = json['exchtype'];
    description = json['description'];
    norentm = json['norentm'];
    norenNsecs = json['noren_nsecs'];
    exchTm = json['exch_tm'];
    emsg = json['emsg'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = this.stat;
    data['exch'] = this.exch;
    data['exchstat'] = this.exchstat;
    data['exchtype'] = this.exchtype;
    data['description'] = this.description;
    data['norentm'] = this.norentm;
    data['noren_nsecs'] = this.norenNsecs;
    data['exch_tm'] = this.exchTm;
    data['emsg'] = this.emsg;
    return data;
  }
}






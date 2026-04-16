class ExchangeMessageModel {
  String? stat;
  String? exchTm;
  String? exch;
  String? exchMsg;
  String? emsg;


  ExchangeMessageModel({this.stat, this.exchTm, this.exch, this.exchMsg,this.emsg});


  ExchangeMessageModel.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    exchTm = json['exch_tm'];
    exch = json['exch'];
    exchMsg = json['exch_msg'];
    emsg = json['emsg'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['exch_tm'] = exchTm;
    data['exch'] = exch;
    data['exch_msg'] = exchMsg;
    data['emsg'] = emsg;
    return data;
  }
}




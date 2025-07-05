class TpSeries {
  List<Data>? data;

  TpSeries({this.data});

  TpSeries.fromJson(Map<String, dynamic> json) {
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
  String? stat;
  String? time;
  String? ssboe;
  String? into;
  String? inth;
  String? intl;
  String? intc;
  String? intvwap;
  String? intv;
  String? intoi;
  String? v;
  String? oi;

  Data(
      {this.stat,
      this.time,
      this.ssboe,
      this.into,
      this.inth,
      this.intl,
      this.intc,
      this.intvwap,
      this.intv,
      this.intoi,
      this.v,
      this.oi});

  Data.fromJson(Map<String, dynamic> json) {
    stat = json['stat'];
    time = json['time'];
    ssboe = json['ssboe'];
    into = json['into'];
    inth = json['inth'];
    intl = json['intl'];
    intc = json['intc'];
    intvwap = json['intvwap'];
    intv = json['intv'];
    intoi = json['intoi'];
    v = json['v'];
    oi = json['oi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stat'] = this.stat;
    data['time'] = this.time;
    data['ssboe'] = this.ssboe;
    data['into'] = this.into;
    data['inth'] = this.inth;
    data['intl'] = this.intl;
    data['intc'] = this.intc;
    data['intvwap'] = this.intvwap;
    data['intv'] = this.intv;
    data['intoi'] = this.intoi;
    data['v'] = this.v;
    data['oi'] = this.oi;
    return data;
  }
}

class TpSeries {
  List<Data>? data;

  TpSeries({this.data});

  TpSeries.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stat'] = stat;
    data['time'] = time;
    data['ssboe'] = ssboe;
    data['into'] = into;
    data['inth'] = inth;
    data['intl'] = intl;
    data['intc'] = intc;
    data['intvwap'] = intvwap;
    data['intv'] = intv;
    data['intoi'] = intoi;
    data['v'] = v;
    data['oi'] = oi;
    return data;
  }
}

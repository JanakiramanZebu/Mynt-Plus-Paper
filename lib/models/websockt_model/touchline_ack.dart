// To parse this JSON data, do
//
//     final touchlineAcknowledgementStream = touchlineAcknowledgementStreamFromJson(jsonString);

import 'dart:convert';

TouchlineAckStream touchlineAckStreamFromJson(String str) =>
    TouchlineAckStream.fromJson(json.decode(str) as Map<String, dynamic>);

String touchlineAckStreamToJson(TouchlineAckStream data) =>
    json.encode(data.toJson());

class TouchlineAckStream {
  String? t;
  String? pp;
  String? ml;
  String? e;
  String? tk;
  String? ts;
  String? ls;
  String? ti;
  String? c;
  String? lp;
  String? pc;
  String? ft;
  String? o;
  String? h;
  String? l;
  String? ap;
  String? v;
  String? bp1;
  String? sp1;
  String? bq1;
  String? sq1;
  String? sStatus;
  String? ordMsg;
  String? oi;
  String? poi;
  String? toi;

  TouchlineAckStream(
      {this.t,
      this.pp,
      this.ml,
      this.e,
      this.tk,
      this.ts,
      this.ls,
      this.ti,
      this.c,
      this.lp,
      this.pc,
      this.ft,
      this.o,
      this.h,
      this.l,
      this.ap,
      this.v,
      this.bp1,
      this.sp1,
      this.bq1,
      this.sq1,
      this.oi,
      this.poi,
      this.toi,
      this.sStatus,
      this.ordMsg});

  TouchlineAckStream.fromJson(Map<String, dynamic> json) {
    t = json['t'];
    pp = json['pp'];
    ml = json['ml'];
    e = json['e'];
    tk = json['tk'];
    ts = json['ts'];
    ls = json['ls'];
    ti = json['ti'];
    c = json['c'];
    lp = json['lp'];
    pc = json['pc'];
    ft = json['ft'];
    o = json['o'];
    h = json['h'];
    l = json['l'];
    ap = json['ap'];
    v = json['v'];
    bp1 = json['bp1'];
    sp1 = json['sp1'];
    bq1 = json['bq1'];
    sq1 = json['sq1'];
    oi = json["oi"];
    poi = json["poi"];
    toi = json["toi"];
    sStatus = json['s_status'];
    ordMsg = json['ord_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['t'] = t;
    data['pp'] = pp;
    data['ml'] = ml;
    data['e'] = e;
    data['tk'] = tk;
    data['ts'] = ts;
    data['ls'] = ls;
    data['ti'] = ti;
    data['c'] = c;
    data['lp'] = lp;
    data['pc'] = pc;
    data['ft'] = ft;
    data['o'] = o;
    data['h'] = h;
    data['l'] = l;
    data['ap'] = ap;
    data['v'] = v;
    data['bp1'] = bp1;
    data['sp1'] = sp1;
    data['bq1'] = bq1;
    data['sq1'] = sq1;
    data["oi"] = oi;
    data["poi"] = poi;
    data["toi"] = toi;
    data['s_status'] = sStatus;
    data['ord_msg'] = ordMsg;

    return data;
  }
}

// import 'dart:convert';

UpdateStream updateStreamFromJson(String str) =>
    UpdateStream.fromJson(json.decode(str) as Map<String, dynamic>);

String updateStreamToJson(UpdateStream data) => json.encode(data.toJson());

class UpdateStream {
  String? t;
  String? pp;
  String? ml;
  String? e;
  String? tk;
  String? ts;
  String? ls;
  String? ti;
  String? c;
  String? lp;
  String? pc;
  String? ft;
  String? o;
  String? h;
  String? l;
  String? ap;
  String? v;
  String? bp1;
  String? sp1;
  String? bq1;
  String? sq1;
  String? sStatus;
  String? ordMsg;
  String? oi;
  String? poi;
  String? toi;

  UpdateStream(
      {this.t,
      this.pp,
      this.ml,
      this.e,
      this.tk,
      this.ts,
      this.ls,
      this.ti,
      this.c,
      this.lp,
      this.pc,
      this.ft,
      this.o,
      this.h,
      this.l,
      this.ap,
      this.v,
      this.bp1,
      this.sp1,
      this.bq1,
      this.sq1,
      this.oi,
      this.poi,
      this.toi,
      this.sStatus,
      this.ordMsg});

  UpdateStream.fromJson(Map<String, dynamic> json) {
    t = json['t'];
    pp = json['pp'];
    ml = json['ml'];
    e = json['e'];
    tk = json['tk'];
    ts = json['ts'];
    ls = json['ls'];
    ti = json['ti'];
    c = json['c'];
    lp = json['lp'];
    pc = json['pc'];
    ft = json['ft'];
    o = json['o'];
    h = json['h'];
    l = json['l'];
    ap = json['ap'];
    v = json['v'];
    bp1 = json['bp1'];
    sp1 = json['sp1'];
    bq1 = json['bq1'];
    sq1 = json['sq1'];
    sStatus = json['s_status'];
    ordMsg = json['ord_msg'];
    oi = json["oi"];
    poi = json["poi"];
    toi = json["toi"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['t'] = t;
    data['pp'] = pp;
    data['ml'] = ml;
    data['e'] = e;
    data['tk'] = tk;
    data['ts'] = ts;
    data['ls'] = ls;
    data['ti'] = ti;
    data['c'] = c;
    data['lp'] = lp;
    data['pc'] = pc;
    data['ft'] = ft;
    data['o'] = o;
    data['h'] = h;
    data['l'] = l;
    data['ap'] = ap;
    data['v'] = v;
    data['bp1'] = bp1;
    data['sp1'] = sp1;
    data['bq1'] = bq1;
    data['sq1'] = sq1;
    data['s_status'] = sStatus;
    data['ord_msg'] = ordMsg;
    data["oi"] = oi;
    data["poi"] = poi;
    data["toi"] = toi;
    return data;
  }
}

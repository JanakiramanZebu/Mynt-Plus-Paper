class mf_sip_reject_res {
  List<Data>? data;
  String? stat;

  mf_sip_reject_res({this.data, this.stat});

  mf_sip_reject_res.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class Data {
  String? id;
  String? reasonName;

  Data({this.id, this.reasonName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reasonName = json['reason_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason_name'] = reasonName;
    return data;
  }
}

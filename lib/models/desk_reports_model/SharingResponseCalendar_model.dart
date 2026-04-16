class SharingResponse {
  List<Data>? data;
  String? stat;

  SharingResponse({this.data, this.stat});

  SharingResponse.fromJson(Map<String, dynamic> json) {
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
  String? sharing;
  String? uqCode;

  Data({this.sharing, this.uqCode});

  Data.fromJson(Map<String, dynamic> json) {
    sharing = json['sharing'];
    uqCode = json['uq_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sharing'] = sharing;
    data['uq_code'] = uqCode;
    return data;
  }
}

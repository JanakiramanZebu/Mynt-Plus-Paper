class OnorOffSharingModel {
  String? msg;
  String? stat;
  Data? data;

  OnorOffSharingModel({this.msg, this.stat, this.data});

  OnorOffSharingModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    stat = json['stat'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['stat'] = stat;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? uqCode;

  Data({this.uqCode});

  Data.fromJson(Map<String, dynamic> json) {
    uqCode = json['uq_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uq_code'] = uqCode;
    return data;
  }
}

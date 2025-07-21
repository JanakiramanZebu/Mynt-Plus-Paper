class CmrDownloadModel {
  String? msg;
  String? path;
  String? stat;

  CmrDownloadModel({this.msg, this.path, this.stat});

  CmrDownloadModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    path = json['path'];
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['path'] = this.path;
    data['stat'] = this.stat;
    return data;
  }
}

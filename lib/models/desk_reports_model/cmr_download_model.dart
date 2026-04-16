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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['path'] = path;
    data['stat'] = stat;
    return data;
  }
}

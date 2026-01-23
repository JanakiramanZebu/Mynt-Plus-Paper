class DeskLogoutModel {
  String? msg;

  DeskLogoutModel({this.msg});

  DeskLogoutModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['msg'] = msg;
    return map;
  }
}

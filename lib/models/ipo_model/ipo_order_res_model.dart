class IpoOrderResponcesModel {
  String? msg;

  IpoOrderResponcesModel({this.msg});

  IpoOrderResponcesModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    return data;
  }
}

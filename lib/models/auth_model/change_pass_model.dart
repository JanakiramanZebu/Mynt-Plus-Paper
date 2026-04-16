class ChangePasswordModel {
  String? reqStatus;

  ChangePasswordModel({this.reqStatus});

  ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    reqStatus = json['ReqStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ReqStatus'] = reqStatus;
    return data;
  }
}

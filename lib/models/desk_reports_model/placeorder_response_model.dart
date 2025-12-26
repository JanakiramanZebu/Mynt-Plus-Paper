class placeOrderResponseCopModel {
  String? msg;

  placeOrderResponseCopModel({this.msg});

  placeOrderResponseCopModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    return data;
  }
}

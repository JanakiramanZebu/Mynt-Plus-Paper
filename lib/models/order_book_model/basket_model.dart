class BasketModel {
  String? basketname;
  String? createdDate;
  String? max;

  BasketModel({this.basketname, this.createdDate, this.max});

  BasketModel.fromJson(Map<String, dynamic> json) {
    basketname = json['basketname'];
    createdDate = json['createdDate'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['basketname'] = basketname;
    data['createdDate'] = createdDate;
    data['max'] = max;
    return data;
  }
}

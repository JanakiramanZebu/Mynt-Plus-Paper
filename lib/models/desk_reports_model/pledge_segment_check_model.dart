class PledgeSegmentCheckModel {
  String? str;

  PledgeSegmentCheckModel({this.str});

  PledgeSegmentCheckModel.fromJson(Map<String, dynamic> json) {
    str = json['str'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['str'] = str;
    return data;
  }
}

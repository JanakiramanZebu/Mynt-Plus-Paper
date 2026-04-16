import 'mutual_fundmodel.dart';

class SearchMFmodel {
  List<MutualFundList>? data;

  SearchMFmodel({this.data});

  SearchMFmodel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MutualFundList>[];
      json['data'].forEach((v) {
        data!.add(MutualFundList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



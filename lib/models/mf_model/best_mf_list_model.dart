import 'mutual_fundmodel.dart';

class BestMFListModel {
  List<MutualFundList>? bestMFList;
  String? stat;

  BestMFListModel({this.bestMFList, this.stat});

  BestMFListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      bestMFList = <MutualFundList>[];
      json['data'].forEach((v) {
        bestMFList!.add(MutualFundList.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bestMFList != null) {
      data['data'] = bestMFList!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}
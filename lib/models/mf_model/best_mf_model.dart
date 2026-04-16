class BestMFModel {
  int? nFOCount;
  List<BestMFList>? bestMFList;
  String? stat;

  BestMFModel({this.nFOCount, this.bestMFList, this.stat});

  BestMFModel.fromJson(Map<String, dynamic> json) {
    nFOCount = json['NFO_count'];
    if (json['data'] != null) {
      bestMFList = <BestMFList>[];
      json['data'].forEach((v) {
        bestMFList!.add(BestMFList.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NFO_count'] = nFOCount;
    if (bestMFList != null) {
      data['data'] = bestMFList!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}

class BestMFList {
  String? title;
  String? counts;

  BestMFList({this.title,this.counts});

  BestMFList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    counts = json['counts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['counts'] = counts;
    return data;
  }
}

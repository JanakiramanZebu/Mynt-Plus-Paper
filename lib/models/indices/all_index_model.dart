 

 

import 'index_list_model.dart';

class AllIndexModel {
  List< IndexValue>? bSE;
  List<IndexValue>? mCX;
  List<IndexValue>? nSE;
  String? stat;

  AllIndexModel({this.bSE, this.mCX, this.nSE, this.stat});

  AllIndexModel.fromJson(Map<String, dynamic> json) {
    if (json['BSE'] != null) {
      bSE = <IndexValue>[];
      json['BSE'].forEach((v) {
        bSE!.add(IndexValue.fromJson(v));
      });
    }
    if (json['MCX'] != null) {
      mCX = <IndexValue>[];
      json['MCX'].forEach((v) {
        mCX!.add(IndexValue.fromJson(v));
      });
    }
    if (json['NSE'] != null) {
      nSE = <IndexValue>[];
      json['NSE'].forEach((v) {
        nSE!.add(IndexValue.fromJson(v));
      });
    }
    stat = json['stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bSE != null) {
      data['BSE'] = bSE!.map((v) => v.toJson()).toList();
    }
    if (mCX != null) {
      data['MCX'] = mCX!.map((v) => v.toJson()).toList();
    }
    if (nSE != null) {
      data['NSE'] = nSE!.map((v) => v.toJson()).toList();
    }
    data['stat'] = stat;
    return data;
  }
}
 
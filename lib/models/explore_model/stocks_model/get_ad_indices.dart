class GetAdIndicesModel {
  List<String>? niftyIndices;
  List<String>? sectoralIndices;
  List<String>? strategyIndices;
  List<String>? thematicIndices;

  GetAdIndicesModel(
      {this.niftyIndices,
      this.sectoralIndices,
      this.strategyIndices,
      this.thematicIndices}); 

  GetAdIndicesModel.fromJson(Map<String, dynamic> json) {
    niftyIndices = json['Nifty-Indices'].cast<String>();
    sectoralIndices = json['Sectoral-Indices'].cast<String>();
    strategyIndices = json['Strategy-Indices'].cast<String>();
    thematicIndices = json['Thematic-Indices'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Nifty-Indices'] = niftyIndices;
    data['Sectoral-Indices'] = sectoralIndices;
    data['Strategy-Indices'] = strategyIndices;
    data['Thematic-Indices'] = thematicIndices;
    return data;
  }
}

class NewsModel {
  String? date;
  String? link;
  String? source;
  String? title;
  String? id;

  NewsModel({this.date, this.link, this.source, this.title, this.id});

  NewsModel.fromJson(Map<String, dynamic> json) {
    date = json['DATE_WITH_TIME'];
    link = json['LINK'];
    source = json['SOURCE'];
    title = json['TITLE'];
    id = json['ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DATE_WITH_TIME'] = date;
    data['LINK'] = link;
    data['SOURCE'] = source;
    data['TITLE'] = title;
    data['ID'] = id;
    return data;
  }
}

class NewsModel {
  int? totalpages;
  List<Data>? data;
  int? newsCount;
  int? pagecount;
  int? pagesize;

  NewsModel(
      {this.totalpages,
      this.data,
      this.newsCount,
      this.pagecount,
      this.pagesize});

  NewsModel.fromJson(Map<String, dynamic> json) {
    totalpages = json['Totalpages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    newsCount = json['newsCount'];
    pagecount = json['pagecount'];
    pagesize = json['pagesize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Totalpages'] = totalpages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['newsCount'] = newsCount;
    data['pagecount'] = pagecount;
    data['pagesize'] = pagesize;
    return data;
  }
}

class Data {
  String? description;
  String? image;
  String? link;
  String? pubDate;
  String? title;

  Data({this.description, this.image, this.link, this.pubDate, this.title});

  Data.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    image = json['image'];
    link = json['link'];
    pubDate = json['pubDate'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['image'] = image;
    data['link'] = link;
    data['pubDate'] = pubDate;
    data['title'] = title;
    return data;
  }
}

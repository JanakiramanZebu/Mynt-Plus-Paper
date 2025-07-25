class InformationMessageModel {
  final String datetime;
  final String imageurl;
  final String msg;
  final String title;
  final String url;

  InformationMessageModel({
    required this.datetime,
    required this.imageurl,
    required this.msg,
    required this.title,
    required this.url,
  });

  factory InformationMessageModel.fromJson(Map<String, dynamic> json) {
    return InformationMessageModel(
      datetime: json['datetime'] ?? '',
      imageurl: json['imageurl'] ?? '',
      msg: json['msg'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime,
      'imageurl': imageurl,
      'msg': msg,
      'title': title,
      'url': url,
    };
  }
}
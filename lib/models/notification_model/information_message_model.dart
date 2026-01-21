class InformationMessageModel {
  final String datetime;
  final String imageurl;
  final String msg;
  final String title;
  final String url;
  // Unique ID for this message - used for push notification highlighting
  // This field will be sent from backend in push notification payload
  final String? uniqueId;

  InformationMessageModel({
    required this.datetime,
    required this.imageurl,
    required this.msg,
    required this.title,
    required this.url,
    this.uniqueId, // Optional - may not exist in all API responses
  });

  factory InformationMessageModel.fromJson(Map<String, dynamic> json) {
    return InformationMessageModel(
      datetime: json['datetime'] ?? '',
      imageurl: json['imageurl'] ?? '',
      msg: json['msg'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      // Try multiple possible field names from backend
      // Backend might send: uniqueID, uniqueId, id, msgId, etc.
      uniqueId: json['uniqueID'] ?? json['uniqueId'] ?? json['id'] ?? json['msgId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime,
      'imageurl': imageurl,
      'msg': msg,
      'title': title,
      'url': url,
      if (uniqueId != null) 'uniqueId': uniqueId,
    };
  }
}
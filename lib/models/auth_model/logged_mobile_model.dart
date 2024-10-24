import 'dart:convert';

class LoggedMobile {
  String clientId;
  String mobile;
  String userName;
  String sesstion;
  String imei;
  LoggedMobile(
      {required this.clientId,
      required this.mobile,
      required this.sesstion,
      required this.userName,
      required this.imei});

  // Convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'mobile': mobile,
      'sesstion': sesstion,
      'userName': userName,
      'imei': imei
    };
  }

  // Create an object from a Map
  factory LoggedMobile.fromMap(Map<String, dynamic> map) {
    return LoggedMobile(
        clientId: map['clientId'],
        mobile: map['mobile'],
        sesstion: map['sesstion'],
        userName: map['userName'],
        imei: map['imei']);
  }

  // Convert the object to a JSON string
  String toJson() => json.encode(toMap());

  // Create an object from a JSON string
  factory LoggedMobile.fromJson(String source) =>
      LoggedMobile.fromMap(json.decode(source));
}

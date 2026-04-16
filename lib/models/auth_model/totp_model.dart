class TotpKey {
  final String uid;
  final String pwd;

  TotpKey({required this.uid, required this.pwd});

  // Factory method to create a TotpKey from JSON
  factory TotpKey.fromJson(Map<String, dynamic> json) {
    return TotpKey(
      uid: json['uid'],
      pwd: json['pwd'],
    );
  }

  // Convert the TotpKey to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'pwd': pwd,
    };
  }
}

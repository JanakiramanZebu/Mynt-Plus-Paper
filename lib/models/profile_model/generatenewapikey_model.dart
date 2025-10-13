class GenerateNewApiKeyModel {
  GenerateNewApiKeyModel({
    required this.stat,
    required this.appKey,
    required this.displayName,
    required this.secretCode,
    required this.redirectUrl,
    required this.ipAddresses,
    required this.exchangeAlgos,
    required this.userIds,
  });

  final String stat;
  final String appKey;
  final String displayName;
  final String secretCode;
  final String redirectUrl;
  final List<IpAddressEntry> ipAddresses;
  final List<dynamic> exchangeAlgos;
  final List<UserIdEntry> userIds;

  factory GenerateNewApiKeyModel.fromJson(Map<String, dynamic> json) {
    return GenerateNewApiKeyModel(
      stat: json['stat'] as String? ?? '',
      appKey: json['app_key'] as String? ?? '',
      displayName: json['dname'] as String? ?? '',
      secretCode: json['sec_code'] as String? ?? '',
      redirectUrl: json['red_url'] as String? ?? '',
      ipAddresses: (json['ipaddr'] as List<dynamic>? ?? [])
          .map((e) => IpAddressEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      exchangeAlgos: (json['exch_algo'] as List<dynamic>? ?? []),
      userIds: (json['uid'] as List<dynamic>? ?? [])
          .map((e) => UserIdEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stat': stat,
      'app_key': appKey,
      'dname': displayName,
      'sec_code': secretCode,
      'red_url': redirectUrl,
      'ipaddr': ipAddresses.map((e) => e.toJson()).toList(),
      'exch_algo': exchangeAlgos,
      'uid': userIds.map((e) => e.toJson()).toList(),
    };
  }
}

class IpAddressEntry {
  IpAddressEntry({
    required this.ipAddress,
  });

  final String ipAddress;

  factory IpAddressEntry.fromJson(Map<String, dynamic> json) {
    return IpAddressEntry(
      ipAddress: json['ipaddr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ipaddr': ipAddress,
    };
  }
}

class UserIdEntry {
  UserIdEntry({
    required this.userId,
  });

  final String userId;

  factory UserIdEntry.fromJson(Map<String, dynamic> json) {
    return UserIdEntry(
      userId: json['uid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': userId,
    };
  }
}



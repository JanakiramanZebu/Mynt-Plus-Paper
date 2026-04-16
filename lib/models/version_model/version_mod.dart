class VersionModel {
  final VersionAttributes attributes;

  VersionModel({
    required this.attributes,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      attributes: VersionAttributes.fromJson(json['data']['attributes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'attributes': attributes.toJson(),
      },
    };
  }
}

class VersionAttributes {
  final VersionDetails version;

  VersionAttributes({
    required this.version,
  });

  factory VersionAttributes.fromJson(Map<String, dynamic> json) {
    return VersionAttributes(
      version: VersionDetails.fromJson(json['version']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version.toJson(),
    };
  }
}

class VersionDetails {
  final String android;
  final String ios;
  final String mandate;

  VersionDetails(
      {required this.android, required this.ios, required this.mandate});

  factory VersionDetails.fromJson(Map<String, dynamic> json) {
    return VersionDetails(
      android: json['and'] ?? '',
      ios: json['ios'] ?? '',
      mandate: json['mandate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'and': android, 'ios': ios, 'mandate': mandate};
  }
}

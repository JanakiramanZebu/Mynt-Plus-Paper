import 'dart:convert';
import 'dart:typed_data';

class BannerImageCache {
  final String bannerId;
  final String imageData; // base64 encoded
  final int cachedAt; // timestamp in milliseconds
  final String originalUrl;
  final double imageWidth;
  final double imageHeight;

  BannerImageCache({
    required this.bannerId,
    required this.imageData,
    required this.cachedAt,
    required this.originalUrl,
    required this.imageWidth,
    required this.imageHeight,
  });

  // Check if cache is expired (7 days = 7 * 24 * 60 * 60 * 1000 ms)
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    const sevenDaysInMs = 7 * 24 * 60 * 60 * 1000;
    return (now - cachedAt) > sevenDaysInMs;
  }

  // Convert base64 to Uint8List for display
  Uint8List get imageBytes {
    return base64Decode(imageData);
  }

  // Convert from Uint8List to BannerImageCache
  factory BannerImageCache.fromImageBytes({
    required String bannerId,
    required Uint8List imageBytes,
    required String originalUrl,
    required double imageWidth,
    required double imageHeight,
  }) {
    return BannerImageCache(
      bannerId: bannerId,
      imageData: base64Encode(imageBytes),
      cachedAt: DateTime.now().millisecondsSinceEpoch,
      originalUrl: originalUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  // Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'bannerId': bannerId,
      'imageData': imageData,
      'cachedAt': cachedAt,
      'originalUrl': originalUrl,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
    };
  }

  // Convert from JSON
  factory BannerImageCache.fromJson(Map<String, dynamic> json) {
    return BannerImageCache(
      bannerId: json['bannerId'] as String,
      imageData: json['imageData'] as String,
      cachedAt: json['cachedAt'] as int,
      originalUrl: json['originalUrl'] as String,
      imageWidth: (json['imageWidth'] as num).toDouble(),
      imageHeight: (json['imageHeight'] as num).toDouble(),
    );
  }

  // Convert to JSON string for SharedPreferences
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Convert from JSON string
  factory BannerImageCache.fromJsonString(String jsonString) {
    return BannerImageCache.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return 'BannerImageCache(bannerId: $bannerId, cachedAt: $cachedAt, originalUrl: $originalUrl, expired: $isExpired)';
  }
}
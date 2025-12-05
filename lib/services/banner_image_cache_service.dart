import 'dart:developer';
import 'dart:typed_data';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/banner_model/banner_image_cache.dart';

class BannerImageCacheService {
  final Preferences _pref = locator<Preferences>();

  // Save banner image to cache
  Future<bool> saveBannerImage({
    required String bannerId,
    required Uint8List imageBytes,
    required String originalUrl,
    required double imageWidth,
    required double imageHeight,
  }) async {
    try {
      final cache = BannerImageCache.fromImageBytes(
        bannerId: bannerId,
        imageBytes: imageBytes,
        originalUrl: originalUrl,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      await _pref.setBannerImageCache(bannerId, cache.toJsonString());
      log('Cached banner image for ID: $bannerId (${imageBytes.length} bytes)');
      return true;
    } catch (e) {
      log('Failed to cache banner image for ID: $bannerId - Error: $e');
      return false;
    }
  }

  // Load banner image from cache
  Future<BannerImageCache?> loadBannerImage(String bannerId) async {
    try {
      final cacheData = _pref.getBannerImageCache(bannerId);
      if (cacheData == null) {
        log('No cache found for banner ID: $bannerId');
        return null;
      }

      final cache = BannerImageCache.fromJsonString(cacheData);
      log('Loaded cached banner for ID: $bannerId (expired: ${cache.isExpired})');
      return cache;
    } catch (e) {
      log('Failed to load cached banner for ID: $bannerId - Error: $e');
      // Remove corrupted cache entry
      await _pref.removeBannerImageCache(bannerId);
      return null;
    }
  }

  // Check if banner image is cached and not expired
  Future<bool> isBannerImageCached(String bannerId) async {
    final cache = await loadBannerImage(bannerId);
    return cache != null && !cache.isExpired;
  }

  // Get valid cached image (not expired)
  Future<BannerImageCache?> getValidCachedImage(String bannerId) async {
    final cache = await loadBannerImage(bannerId);
    if (cache != null && !cache.isExpired) {
      return cache;
    }
    return null;
  }

  // Remove specific banner from cache
  Future<void> removeBannerFromCache(String bannerId) async {
    try {
      await _pref.removeBannerImageCache(bannerId);
      log('Removed banner from cache: $bannerId');
    } catch (e) {
      log('Failed to remove banner from cache: $bannerId - Error: $e');
    }
  }

  // Clean up expired cache entries
  Future<void> cleanupExpiredCache() async {
    try {
      final keys = await _pref.getAllBannerCacheKeys();
      int removedCount = 0;

      for (final key in keys) {
        final bannerId = key.replaceFirst('bannerImageCache_', '');
        final cache = await loadBannerImage(bannerId);

        if (cache == null || cache.isExpired) {
          await _pref.removeBannerImageCache(bannerId);
          removedCount++;
          log('Removed expired/corrupted cache for banner: $bannerId');
        }
      }

      log('Cache cleanup completed. Removed $removedCount expired entries.');
    } catch (e) {
      log('Failed to cleanup expired cache: $e');
    }
  }

  // Clean up cache for inactive banners (not in current active banner list)
  Future<void> cleanupInactiveCache(List<String> activeBannerIds) async {
    try {
      final keys = await _pref.getAllBannerCacheKeys();
      int removedCount = 0;

      for (final key in keys) {
        final bannerId = key.replaceFirst('bannerImageCache_', '');

        if (!activeBannerIds.contains(bannerId)) {
          await _pref.removeBannerImageCache(bannerId);
          removedCount++;
          log('Removed cache for inactive banner: $bannerId');
        }
      }

      log('Inactive cache cleanup completed. Removed $removedCount inactive entries.');
    } catch (e) {
      log('Failed to cleanup inactive cache: $e');
    }
  }

  // Clear all banner cache
  Future<void> clearAllCache() async {
    try {
      await _pref.clearAllBannerCache();
      log('Cleared all banner image cache');
    } catch (e) {
      log('Failed to clear all banner cache: $e');
    }
  }

  // Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    try {
      final keys = await _pref.getAllBannerCacheKeys();
      int totalEntries = keys.length;
      int expiredEntries = 0;
      int validEntries = 0;

      for (final key in keys) {
        final bannerId = key.replaceFirst('bannerImageCache_', '');
        final cache = await loadBannerImage(bannerId);

        if (cache == null) {
          expiredEntries++;
        } else if (cache.isExpired) {
          expiredEntries++;
        } else {
          validEntries++;
        }
      }

      return {
        'total': totalEntries,
        'valid': validEntries,
        'expired': expiredEntries,
      };
    } catch (e) {
      log('Failed to get cache stats: $e');
      return {'total': 0, 'valid': 0, 'expired': 0};
    }
  }
}
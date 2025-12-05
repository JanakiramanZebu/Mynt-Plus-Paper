import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/banner_model/banner_model.dart';
import '../services/banner_image_cache_service.dart';
import 'core/default_change_notifier.dart';

final bannerProvider = ChangeNotifierProvider((ref) => BannerProvider(ref));

class BannerProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final BannerImageCacheService _cacheService = BannerImageCacheService();
  final Ref ref;

  BannerProvider(this.ref);

  List<BannerModel> _banners = [];
  final List<String> _shownBannerIds = [];
  final Map<BannerScreenType, List<BannerModel>> _bannersByScreen = {};

  List<BannerModel> get banners => _banners;
  List<String> get shownBannerIds => _shownBannerIds;

  Future<void> loadBanners() async {
    try {
      log('Starting to load banners...');
      toggleLoadingOn(true);
      setErrorMessage('');

      // Clean up expired cache entries before loading
      await _cacheService.cleanupExpiredCache();

      log('Calling API to fetch banners...');
      var response = await api.fetchBanners();

      if (response != null) {
        log('API response received - Success: ${response.success}');

        if (response.success) {
          // Get all banners from all screens
          var allActiveBanners = response.allBanners
              .where((banner) => banner.shouldDisplay)
              .toList();

          log('Found ${allActiveBanners.length} active banners from all screens');

          // Filter out seen banners
          final userId = pref.clientId ?? '';
          var unseenBanners = allActiveBanners
              .where((banner) => !pref.isBannerSeen(userId, banner.id))
              .toList();

          log('Filtered to ${unseenBanners.length} unseen banners (${allActiveBanners.length - unseenBanners.length} already seen)');

          // Clean up cache for inactive banners first
          final activeBannerIds = allActiveBanners.map((b) => b.id).toList();
          await _cacheService.cleanupInactiveCache(activeBannerIds);

          // Load image data for each unseen banner (with cache-first approach)
          log('About to load image data for ${unseenBanners.length} unseen banners');
          _banners = await _loadImageDataForBanners(unseenBanners);
          log('Finished loading image data, final banner count: ${_banners.length}');

          // Sort by priority (higher first)
          _banners.sort((a, b) => b.priority.compareTo(a.priority));

          // Group banners by screen using the loaded banners with image data
          _groupBannersByScreen();

          log('Banners grouped by screen: ${_bannersByScreen.keys}');
          for (var entry in _bannersByScreen.entries) {
            log('Screen ${entry.key}: ${entry.value.length} banners');
          }

          log('Successfully loaded ${_banners.length} active banners');
        } else {
          final errorMsg = response.message ?? 'API returned success=false';
          setErrorMessage(errorMsg);
          log('API returned failure: $errorMsg');
        }
      } else {
        const errorMsg = 'API response was null';
        setErrorMessage(errorMsg);
        log(errorMsg);
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Exception loading banners: $e';
      setErrorMessage(errorMsg);
      log(errorMsg);
      log('Stack trace: $stackTrace');
    } finally {
      toggleLoadingOn(false);
      log('Banner loading finished');
    }
  }

  List<BannerModel> getBannersForScreen(BannerScreenType screenType) {
    return _bannersByScreen[screenType] ?? [];
  }

  BannerModel? getNextBannerForScreen(BannerScreenType screenType) {
    final screenBanners = getBannersForScreen(screenType);
    final userId = pref.clientId ?? '';

    // Filter out seen banners in real-time
    final unseenBanners = screenBanners
        .where((banner) => !pref.isBannerSeen(userId, banner.id))
        .toList();

    log('getNextBannerForScreen: ${screenBanners.length} total, ${unseenBanners.length} unseen for screen $screenType');

    // Return the first unseen banner
    return unseenBanners.isNotEmpty ? unseenBanners.first : null;
  }

  bool shouldShowBanner(String bannerId, BannerScreenType screenType) {
    final userId = pref.clientId ?? '';

    // First check if banner is seen
    if (pref.isBannerSeen(userId, bannerId)) {
      return false;
    }

    // Check if banner exists and is active
    final banner = _banners.firstWhere(
      (b) => b.id == bannerId,
      orElse: () => BannerModel(
        id: '',
        imageUrl: '',
        screenName: screenType,
        isActive: false,
        priority: 0,
      ),
    );

    return banner.shouldDisplay;
  }

  Future<void> markBannerAsShown(String bannerId) async {
    try {
      final userId = pref.clientId ?? '';

      // Mark as seen locally first (immediate effect)
      await pref.setBannerSeen(userId, bannerId);
      log('Marked banner as seen locally: $bannerId for user: $userId');

      // Add to shown list for current session
      if (!_shownBannerIds.contains(bannerId)) {
        _shownBannerIds.add(bannerId);
      }

      // Call API to mark as seen on backend
      final success = await api.markBannerSeen(bannerId: bannerId);

      if (success) {
        log('Successfully marked banner as seen on backend: $bannerId');
      } else {
        log('Failed to mark banner as seen on backend: $bannerId (local tracking still active)');
      }

      // Trigger UI rebuild so banner widgets can update immediately
      notifyListeners();
    } catch (e) {
      log('Error marking banner as shown: $e');
    }
  }

  Future<void> refreshBanners() async {
    await loadBanners();
  }

  void clearShownBanners() {
    _shownBannerIds.clear();
    notifyListeners();
  }

  // Cache management methods
  Future<void> clearBannerCache() async {
    await _cacheService.clearAllCache();
    log('Cleared all banner image cache');
  }

  Future<Map<String, int>> getBannerCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  // Seen banner management methods
  Future<void> clearSeenBanners() async {
    final userId = pref.clientId ?? '';
    await pref.clearSeenBanners(userId);
    log('Cleared seen banners for user: $userId');
    // Reload banners to show previously seen ones
    await loadBanners();
  }

  Future<List<String>> getSeenBannerIds() async {
    final userId = pref.clientId ?? '';
    return await pref.getSeenBannerIds(userId);
  }

  // Logout cleanup method
  Future<void> onUserLogout() async {
    try {
      final userId = pref.clientId ?? '';

      // Clear seen banners for the logging out user
      await pref.clearSeenBanners(userId);
      log('Cleared seen banners for logged out user: $userId');

      // Clear current session data
      _banners.clear();
      _shownBannerIds.clear();
      _bannersByScreen.clear();

      log('Cleared banner provider session data on logout');
      notifyListeners();
    } catch (e) {
      log('Error during banner logout cleanup: $e');
    }
  }

  // Private methods
  Future<List<BannerModel>> _loadImageDataForBanners(List<BannerModel> banners) async {
    log('_loadImageDataForBanners called with ${banners.length} banners');
    List<BannerModel> bannersWithImages = [];

    for (var banner in banners) {
      try {
        log('Processing banner ${banner.id} from ${banner.imageUrl}');

        // Step 1: Check cache first
        final cachedImage = await _cacheService.getValidCachedImage(banner.id);

        if (cachedImage != null) {
          // Use cached image
          log('Using cached image for banner ${banner.id}');
          final bannerWithImage = banner.copyWith(
            imageData: cachedImage.imageBytes,
            imageWidth: cachedImage.imageWidth,
            imageHeight: cachedImage.imageHeight,
          );
          bannersWithImages.add(bannerWithImage);
          continue;
        }

        // Step 2: Cache miss or expired, try network download
        log('Cache miss/expired for banner ${banner.id}, downloading from network');

        final response = await http.get(
          Uri.parse(banner.imageUrl),
          headers: {
            'User-Agent': 'Flutter App',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final imageData = response.bodyBytes;

          // Get actual image dimensions
          final dimensions = await _getImageDimensions(imageData);
          log('Downloaded image for banner ${banner.id}: ${dimensions.width} x ${dimensions.height}');

          // Save to cache
          await _cacheService.saveBannerImage(
            bannerId: banner.id,
            imageBytes: imageData,
            originalUrl: banner.imageUrl,
            imageWidth: dimensions.width,
            imageHeight: dimensions.height,
          );

          final bannerWithImage = banner.copyWith(
            imageData: imageData,
            imageWidth: dimensions.width,
            imageHeight: dimensions.height,
          );

          bannersWithImages.add(bannerWithImage);
          log('Successfully loaded and cached image data for banner ${banner.id}');
        } else {
          log('Failed to download image for banner ${banner.id}: HTTP ${response.statusCode}');
          // Skip banner - no image means no banner shown
        }
      } catch (e) {
        log('Error loading image data for banner ${banner.id}: $e');
        // Skip banner - error means no banner shown
      }
    }

    log('Final result: ${bannersWithImages.length} banners with valid images out of ${banners.length} total');
    return bannersWithImages;
  }

  void _groupBannersByScreenFromResponse(BannerResponse response) {
    _bannersByScreen.clear();

    // Convert screen name strings to BannerScreenType enum
    for (var screenEntry in response.screens.entries) {
      final screenName = screenEntry.key;
      final screenBanners = screenEntry.value;

      // Convert screen name to enum
      final screenType = BannerScreenType.fromString(screenName);

      // Add active banners for this screen
      final activeBanners = screenBanners.banners
          .where((banner) => banner.shouldDisplay)
          .toList();

      if (activeBanners.isNotEmpty) {
        _bannersByScreen[screenType] = activeBanners;

        // Sort by priority (higher first)
        _bannersByScreen[screenType]!.sort((a, b) => b.priority.compareTo(a.priority));
      }
    }
  }

  void _groupBannersByScreen() {
    _bannersByScreen.clear();

    for (final banner in _banners) {
      if (!_bannersByScreen.containsKey(banner.screenName)) {
        _bannersByScreen[banner.screenName] = [];
      }
      _bannersByScreen[banner.screenName]!.add(banner);
    }

    // Sort each screen's banners by priority
    for (final screenBanners in _bannersByScreen.values) {
      screenBanners.sort((a, b) => b.priority.compareTo(a.priority));
    }
  }

  Future<Size> _getImageDimensions(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      log('Failed to get image dimensions: $e');
      // Fallback to default dimensions if image dimension detection fails
      return const Size(400.0, 200.0);
    }
  }


}
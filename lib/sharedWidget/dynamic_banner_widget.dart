import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/banner_model/banner_model.dart';
import '../provider/banner_provider.dart';

class DynamicBannerWidget extends ConsumerStatefulWidget {
  final BannerScreenType screenType;
  final Duration showDelay;
  final bool showImmediately;

  const DynamicBannerWidget({
    super.key,
    required this.screenType,
    this.showDelay = const Duration(seconds: 5),
    this.showImmediately = false,
  });

  @override
  ConsumerState<DynamicBannerWidget> createState() => _DynamicBannerWidgetState();
}

class _DynamicBannerWidgetState extends ConsumerState<DynamicBannerWidget> {
  Timer? _showTimer;
  bool _shouldShow = false;
  bool _bannerShown = false;

  @override
  void initState() {
    super.initState();
    log('DynamicBannerWidget initState for ${widget.screenType}');

    // If showing immediately, preload banners
    if (widget.showImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadBanners();
      });
    } else {
      _scheduleBannerDisplay();
    }
  }

  void _preloadBanners() async {
    log('Preloading banners for ${widget.screenType}');
    final bannerProv = ref.read(bannerProvider.notifier);

    // Only load if banners haven't been loaded yet
    if (ref.read(bannerProvider).banners.isEmpty) {
      await bannerProv.loadBanners();
    }

    // Check for banners after loading completes, but delay slightly to ensure widget is built
    if (mounted && !_bannerShown) {
      setState(() {
        _shouldShow = true;
      });
      // Use another post frame callback to ensure context is ready for showDialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_bannerShown) {
          _checkAndShowBanner();
        }
      });
    }
  }

  void _scheduleBannerDisplay() {
    log('Scheduling banner display for ${widget.screenType} with ${widget.showDelay.inSeconds}s delay');
    _showTimer = Timer(widget.showDelay, () {
      if (mounted) {
        log('Timer fired for ${widget.screenType}, setting shouldShow = true');
        setState(() {
          _shouldShow = true;
        });
        _checkAndShowBanner();
      } else {
        log('Timer fired but widget not mounted for ${widget.screenType}');
      }
    });
  }

  void _checkAndShowBanner() {
    if (_bannerShown) {
      log('Banner already shown for ${widget.screenType}');
      return;
    }

    final bannerProv = ref.read(bannerProvider);

    // Debug: Check provider state
    log('BannerProvider loading state: ${bannerProv.loading}');
    log('BannerProvider error: ${bannerProv.errorMessage}');

    // Debug: Check all available banners
    final allBanners = bannerProv.banners;
    log('Total banners loaded: ${allBanners.length}');
    for (var b in allBanners) {
      log('Available banner: ${b.id} for ${b.screenName}, active: ${b.isActive}, shouldDisplay: ${b.shouldDisplay}');
    }

    // Check banners specifically for this screen
    final screenBanners = bannerProv.getBannersForScreen(widget.screenType);
    log('Banners for ${widget.screenType}: ${screenBanners.length}');
    for (var b in screenBanners) {
      log('Screen banner: ${b.id}, imageUrl=${b.imageUrl}, active=${b.isActive}, shouldDisplay: ${b.shouldDisplay}');
    }

    final banner = bannerProv.getNextBannerForScreen(widget.screenType);

    log('Checking banner for ${widget.screenType} - Banner found: ${banner != null}, shouldShow: $_shouldShow');
    if (banner != null) {
      log('Banner details: id=${banner.id}, imageUrl=${banner.imageUrl}, isActive=${banner.isActive}');
    } else {
      log('No banner found for ${widget.screenType} - checking if banners are loaded at all');
      if (allBanners.isEmpty) {
        log('No banners loaded yet - API might not have been called');
      }
    }

    if (banner != null && _shouldShow) {
      _bannerShown = true;
      log('Showing banner dialog for ${widget.screenType}');
      _showBannerDialog(banner);
    }
  }

  void _showBannerDialog(BannerModel banner) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => BannerDialog(
        banner: banner,
        screenType: widget.screenType,
        onClose: () {
          Navigator.of(context).pop();
        },
        onAction: (actionUrl) {
          Navigator.of(context).pop();
          if (actionUrl != null && actionUrl.isNotEmpty) {
            _launchUrl(actionUrl);
          }
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    log('DynamicBannerWidget disposed for ${widget.screenType}');
    _showTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class BannerDialog extends ConsumerStatefulWidget {
  final BannerModel banner;
  final VoidCallback onClose;
  final ValueChanged<String?> onAction;
  final BannerScreenType screenType;

  const BannerDialog({
    super.key,
    required this.banner,
    required this.onClose,
    required this.onAction,
    required this.screenType,
  });

  @override
  ConsumerState<BannerDialog> createState() => _BannerDialogState();
}

class _BannerDialogState extends ConsumerState<BannerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    log('BannerDialog initialized for image: ${widget.banner.imageUrl}');
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Size _calculateDisplaySize(BuildContext context, BannerModel banner) {
    final screenSize = MediaQuery.of(context).size;

    // Adjust sizing based on screen type - homescreen gets larger banners
    double widthMultiplier = widget.screenType == BannerScreenType.homescreen ? 0.95 : 0.9;
    double heightMultiplier = widget.screenType == BannerScreenType.homescreen ? 0.85 : 0.75;

    final maxWidth = screenSize.width * widthMultiplier;
    final maxHeight = screenSize.height * heightMultiplier;

    // Use actual image dimensions if available
    if (banner.imageWidth != null && banner.imageHeight != null) {
      final imageAspectRatio = banner.imageWidth! / banner.imageHeight!;

      // Calculate size maintaining aspect ratio
      double width = maxWidth;
      double height = width / imageAspectRatio;

      // If height exceeds screen limits, adjust by height
      if (height > maxHeight) {
        height = maxHeight;
        width = height * imageAspectRatio;
      }

      // Ensure minimum bounds - larger minimums for homescreen
      double minWidth = widget.screenType == BannerScreenType.homescreen ? 320.0 : 280.0;
      double minHeight = widget.screenType == BannerScreenType.homescreen ? 240.0 : 200.0;

      width = width.clamp(minWidth, maxWidth);
      height = height.clamp(minHeight, maxHeight);

      // Reserve space for action button if present
      if (banner.actionUrl?.isNotEmpty == true) {
        height = height - 60;
      }

      return Size(width, height);
    }

    // Fallback to default sizing with screen-specific adjustments
    double width = maxWidth.clamp(
      widget.screenType == BannerScreenType.homescreen ? 320.0 : 280.0,
      widget.screenType == BannerScreenType.homescreen ? 600.0 : 500.0
    );
    double height = maxHeight.clamp(
      widget.screenType == BannerScreenType.homescreen ? 240.0 : 200.0,
      widget.screenType == BannerScreenType.homescreen ? 700.0 : 600.0
    );

    if (widget.banner.actionUrl?.isNotEmpty == true) {
      height = height - 60;
    }

    return Size(width, height);
  }

  Widget _buildImageWidget(Size displaySize, BannerModel banner) {
    log('Building image widget for banner: ${banner.id}');

    // Check if we have image data
    if (banner.imageData != null) {
      log('Using image data for banner: ${banner.id}');
      return Image.memory(
        banner.imageData!,
        width: displaySize.width,
        height: displaySize.height,
        fit: BoxFit.contain, // Use contain to prevent cropping
        filterQuality: FilterQuality.high,
      );
    } else {
      log('No image data available for banner: ${banner.id}, using cached network image');
      return CachedNetworkImage(
        imageUrl: banner.imageUrl,
        width: displaySize.width,
        height: displaySize.height,
        fit: BoxFit.contain,
        httpHeaders: const {
          'User-Agent': 'Flutter App',
        },
        memCacheWidth: 800, // Optimize for web
        memCacheHeight: 600,
        placeholder: (context, url) => Container(
          width: displaySize.width,
          height: displaySize.height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          log('CachedNetworkImage failed to load: $error');
          return Container(
            width: displaySize.width,
            height: displaySize.height,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Failed to load banner'),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: _buildBannerContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerContent(BuildContext context) {
    final displaySize = _calculateDisplaySize(context, widget.banner);

    log('Building banner content with size: ${displaySize.width} x ${displaySize.height}');

    // Add back action button space to container height
    final hasActionButton = widget.banner.actionUrl?.isNotEmpty == true;
    final containerHeight = displaySize.height + (hasActionButton ? 60 : 0);

    return Container(
      width: displaySize.width,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Banner Image - using cached widget to prevent multiple network requests
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImageWidget(displaySize, widget.banner),
          ),

          // Close Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                // Mark banner as seen when close button is tapped
                await ref.read(bannerProvider.notifier).markBannerAsShown(widget.banner.id);
                widget.onClose();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Action Button (if actionUrl exists)
          if (widget.banner.actionUrl != null &&
              widget.banner.actionUrl!.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () async {
                  // Mark banner as seen when action button is tapped
                  await ref.read(bannerProvider.notifier).markBannerAsShown(widget.banner.id);
                  widget.onAction(widget.banner.actionUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Learn More',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
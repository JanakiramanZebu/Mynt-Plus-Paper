import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import '../res/mynt_web_color_styles.dart';

/// Common loader widget library for Mynt Plus project
/// Provides consistent loading indicators across the application
///
/// Usage Examples:
///
/// 1. Branded loader with Mynt logo (for major loading states):
///    MyntLoader.branded()
///    MyntLoader.branded(size: MyntLoaderSize.large)
///
/// 2. Simple circular spinner:
///    MyntLoader.simple()
///    MyntLoader.simple(size: MyntLoaderSize.small)
///
/// 3. Inline loader for buttons:
///    MyntLoader.inline(color: Colors.white)
///
/// 4. Progressive dots animation:
///    MyntLoader.dots()
///    MyntLoader.dots(numberOfDots: 5, dotColor: Colors.blue)
///
/// 5. Full-screen overlay loader:
///    MyntLoaderOverlay(
///      isLoading: true,
///      child: YourContent(),
///    )
///
/// 6. Centered loader with optional message:
///    MyntLoader.centered(message: 'Loading data...')

/// Size variants for loaders
enum MyntLoaderSize {
  /// Extra small - 16px (for inline/button use)
  xs,

  /// Small - 24px
  small,

  /// Medium - 40px (default)
  medium,

  /// Large - 64px
  large,

  /// Extra large - 90px (for branded loader)
  xl,
}

/// Main loader widget with factory constructors for different types
class MyntLoader extends StatelessWidget {
  final MyntLoaderSize size;
  final Color? color;
  final double? strokeWidth;
  final bool showLogo;
  final String? message;
  final Widget? customChild;

  const MyntLoader({
    super.key,
    this.size = MyntLoaderSize.medium,
    this.color,
    this.strokeWidth,
    this.showLogo = false,
    this.message,
    this.customChild,
  });

  /// Branded loader with Mynt logo - use for major loading states
  /// (splash screen, page loads, initial data fetch)
  factory MyntLoader.branded({
    Key? key,
    MyntLoaderSize size = MyntLoaderSize.xl,
    Color? color,
  }) {
    return MyntLoader(
      key: key,
      size: size,
      color: color,
      showLogo: true,
    );
  }

  /// Simple circular spinner - use for general loading
  factory MyntLoader.simple({
    Key? key,
    MyntLoaderSize size = MyntLoaderSize.medium,
    Color? color,
    double? strokeWidth,
  }) {
    return MyntLoader(
      key: key,
      size: size,
      color: color,
      strokeWidth: strokeWidth,
      showLogo: false,
    );
  }

  /// Inline loader for buttons - extra small with custom color
  factory MyntLoader.inline({
    Key? key,
    Color color = Colors.white,
    double strokeWidth = 2.0,
  }) {
    return MyntLoader(
      key: key,
      size: MyntLoaderSize.xs,
      color: color,
      strokeWidth: strokeWidth,
      showLogo: false,
    );
  }

  /// Centered loader with optional message
  factory MyntLoader.centered({
    Key? key,
    MyntLoaderSize size = MyntLoaderSize.medium,
    Color? color,
    String? message,
    bool showLogo = false,
  }) {
    return MyntLoader(
      key: key,
      size: size,
      color: color,
      showLogo: showLogo,
      message: message,
    );
  }

  /// Dots loader - progressive animated dots
  static Widget dots({
    Key? key,
    int numberOfDots = 8,
    double dotSize = 10.0,
    Duration duration = const Duration(seconds: 1),
    Color dotColor = Colors.grey,
  }) {
    return _ProgressiveDotsLoader(
      key: key,
      numberOfDots: numberOfDots,
      dotSize: dotSize,
      duration: duration,
      dotColor: dotColor,
    );
  }

  double _getSize() {
    switch (size) {
      case MyntLoaderSize.xs:
        return 16.0;
      case MyntLoaderSize.small:
        return 24.0;
      case MyntLoaderSize.medium:
        return 40.0;
      case MyntLoaderSize.large:
        return 64.0;
      case MyntLoaderSize.xl:
        return 90.0;
    }
  }

  double _getLogoSize() {
    switch (size) {
      case MyntLoaderSize.xs:
        return 12.0;
      case MyntLoaderSize.small:
        return 18.0;
      case MyntLoaderSize.medium:
        return 32.0;
      case MyntLoaderSize.large:
        return 54.0;
      case MyntLoaderSize.xl:
        return 80.0;
    }
  }

  double _getStrokeWidth() {
    if (strokeWidth != null) return strokeWidth!;
    switch (size) {
      case MyntLoaderSize.xs:
        return 2.0;
      case MyntLoaderSize.small:
        return 2.5;
      case MyntLoaderSize.medium:
        return 3.0;
      case MyntLoaderSize.large:
        return 4.0;
      case MyntLoaderSize.xl:
        return 5.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaderSize = _getSize();
    final loaderStrokeWidth = _getStrokeWidth();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use theme-aware primary color; branded loaders keep Colors.blue
    final loaderColor = color ?? (showLogo ? Colors.blue : (isDarkMode ? MyntColors.primaryDark : MyntColors.primary));

    Widget loader;

    if (showLogo) {
      // Branded loader with logo
      loader = Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/icon/MYNT App Logo_v2.svg',
              width: _getLogoSize(),
              height: _getLogoSize(),
            ),
          ),
          SizedBox(
            width: loaderSize,
            height: loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: loaderStrokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
            ),
          ),
        ],
      );
    } else if (customChild != null) {
      // Custom child with spinner around it
      loader = Stack(
        alignment: Alignment.center,
        children: [
          customChild!,
          SizedBox(
            width: loaderSize,
            height: loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: loaderStrokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
            ),
          ),
        ],
      );
    } else {
      // Simple spinner
      loader = SizedBox(
        width: loaderSize,
        height: loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: loaderStrokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      );
    }

    // Add message if provided
    if (message != null && message!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loader,
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? MyntColors.textSecondaryDark
                  : MyntColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loader;
  }
}

/// Full-screen overlay loader that wraps content
/// Replaces TransparentLoaderScreen for consistency
class MyntLoaderOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final MyntLoaderSize loaderSize;
  final Color? loaderColor;
  final bool showLogo;
  final String? message;
  final Color? overlayColor;
  final double overlayOpacity;
  final bool barrierDismissible;

  const MyntLoaderOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loaderSize = MyntLoaderSize.xl,
    this.loaderColor,
    this.showLogo = true,
    this.message,
    this.overlayColor,
    this.overlayOpacity = 1.0,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bgColor = overlayColor ??
        (isDarkMode ? MyntColors.backgroundColorDark : Colors.white).withValues(alpha: overlayOpacity);

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: barrierDismissible ? () {} : null,
              child: Container(
                color: bgColor,
                child: Center(
                  child: showLogo
                      ? MyntLoader.branded(
                          size: loaderSize,
                          color: loaderColor,
                        )
                      : MyntLoader.centered(
                          size: loaderSize,
                          color: loaderColor,
                          message: message,
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Semi-transparent overlay loader (doesn't fully cover content)
class MyntLoaderSemiOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final MyntLoaderSize loaderSize;
  final Color? loaderColor;
  final double overlayOpacity;

  const MyntLoaderSemiOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loaderSize = MyntLoaderSize.medium,
    this.loaderColor,
    this.overlayOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (isDarkMode ? MyntColors.backgroundColorDark : Colors.white)
                  .withValues(alpha: overlayOpacity),
              child: Center(
                child: MyntLoader.simple(
                  size: loaderSize,
                  color: loaderColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Progressive dots loader widget (animated dots)
class _ProgressiveDotsLoader extends StatefulWidget {
  final int numberOfDots;
  final double dotSize;
  final Duration duration;
  final Color dotColor;

  const _ProgressiveDotsLoader({
    super.key,
    this.numberOfDots = 8,
    this.dotSize = 10.0,
    this.duration = const Duration(seconds: 1),
    this.dotColor = Colors.grey,
  });

  @override
  State<_ProgressiveDotsLoader> createState() => _ProgressiveDotsLoaderState();
}

class _ProgressiveDotsLoaderState extends State<_ProgressiveDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.dotSize * 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.numberOfDots, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _getDotScale(index),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.dotColor,
              ),
            ),
          );
        }),
      ),
    );
  }

  double _getDotScale(int index) {
    double progress = (_controller.value * widget.numberOfDots - index).abs();
    return max(0.3, 1.0 - progress);
  }
}

/// Shimmer loading effect for skeleton screens
class MyntShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const MyntShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<MyntShimmerLoader> createState() => _MyntShimmerLoaderState();
}

class _MyntShimmerLoaderState extends State<MyntShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final baseColor = widget.baseColor ??
        (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ??
        (isDarkMode ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Extension for easy loader display in dialogs
extension MyntLoaderDialog on BuildContext {
  /// Show a loading dialog
  void showLoaderDialog({
    bool barrierDismissible = false,
    String? message,
    bool showLogo = true,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? MyntColors.backgroundColorDark
                    : MyntColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  showLogo
                      ? MyntLoader.branded(size: MyntLoaderSize.large)
                      : MyntLoader.simple(size: MyntLoaderSize.large),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? MyntColors.textSecondaryDark
                            : MyntColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hide the loading dialog
  void hideLoaderDialog() {
    Navigator.of(this).pop();
  }
}

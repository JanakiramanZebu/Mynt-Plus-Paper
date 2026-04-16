import 'package:flutter/material.dart';
import '../res/app_breakpoints.dart';
import '../res/responsive_extensions.dart';

/// A widget that builds different layouts based on screen size
///
/// Uses LayoutBuilder internally for accurate constraint-based sizing.
///
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Builder for mobile screens (< 600px)
  final Widget Function(BuildContext context)? mobile;

  /// Builder for small tablet screens (600px - 768px)
  final Widget Function(BuildContext context)? smallTablet;

  /// Builder for tablet screens (768px - 992px)
  final Widget Function(BuildContext context)? tablet;

  /// Builder for desktop screens (992px - 1200px)
  final Widget Function(BuildContext context)? desktop;

  /// Builder for large desktop screens (1200px - 1440px)
  final Widget Function(BuildContext context)? largeDesktop;

  /// Builder for widescreen (>= 1440px)
  final Widget Function(BuildContext context)? widescreen;

  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.smallTablet,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.widescreen,
  }) : assert(
          mobile != null || tablet != null || desktop != null,
          'At least one builder must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Determine which builder to use based on width
        Widget Function(BuildContext)? builder;

        if (width >= AppBreakpoints.xxl && widescreen != null) {
          builder = widescreen;
        } else if (width >= AppBreakpoints.xl && largeDesktop != null) {
          builder = largeDesktop;
        } else if (width >= AppBreakpoints.lg && desktop != null) {
          builder = desktop;
        } else if (width >= AppBreakpoints.md && tablet != null) {
          builder = tablet;
        } else if (width >= AppBreakpoints.sm && smallTablet != null) {
          builder = smallTablet;
        } else if (mobile != null) {
          builder = mobile;
        }

        // Fallback chain: widescreen -> largeDesktop -> desktop -> tablet -> smallTablet -> mobile
        builder ??=
            widescreen ?? largeDesktop ?? desktop ?? tablet ?? smallTablet ?? mobile;

        return builder!(context);
      },
    );
  }
}

/// A simpler version with just mobile/desktop distinction
///
/// Matches the pattern used in responsive_modal.dart (600px breakpoint)
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileWidget(),
///   desktop: DesktopWidget(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Widget for mobile layout (< breakpoint)
  final Widget mobile;

  /// Widget for desktop layout (>= breakpoint)
  final Widget desktop;

  /// Breakpoint to switch layouts (default 600px - matches responsive_modal.dart)
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
    this.breakpoint = AppBreakpoints.sm,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return desktop;
        }
        return mobile;
      },
    );
  }
}

/// Widget that shows/hides based on screen size
///
/// Usage:
/// ```dart
/// ResponsiveVisibility(
///   visibleOnMobile: false,
///   visibleOnDesktop: true,
///   child: DesktopOnlyWidget(),
/// )
/// ```
class ResponsiveVisibility extends StatelessWidget {
  /// The child widget to show/hide
  final Widget child;

  /// Show on mobile (< 600px)
  final bool visibleOnMobile;

  /// Show on tablet (600px - 992px)
  final bool visibleOnTablet;

  /// Show on desktop (>= 992px)
  final bool visibleOnDesktop;

  /// Widget to show when hidden (default: SizedBox.shrink())
  final Widget? replacement;

  /// Whether to maintain state when hidden (wraps with Offstage instead of removing)
  final bool maintainState;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
    this.maintainState = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;

    bool isVisible = switch (deviceType) {
      DeviceType.mobile => visibleOnMobile,
      DeviceType.smallTablet || DeviceType.tablet => visibleOnTablet,
      _ => visibleOnDesktop,
    };

    if (maintainState) {
      return Offstage(
        offstage: !isVisible,
        child: child,
      );
    }

    return isVisible ? child : (replacement ?? const SizedBox.shrink());
  }
}

/// Show widget only on mobile devices (< 600px)
class MobileOnly extends StatelessWidget {
  final Widget child;
  final Widget? replacement;

  const MobileOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveVisibility(
      visibleOnMobile: true,
      visibleOnTablet: false,
      visibleOnDesktop: false,
      replacement: replacement,
      child: child,
    );
  }
}

/// Show widget only on tablet devices (600px - 992px)
class TabletOnly extends StatelessWidget {
  final Widget child;
  final Widget? replacement;

  const TabletOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveVisibility(
      visibleOnMobile: false,
      visibleOnTablet: true,
      visibleOnDesktop: false,
      replacement: replacement,
      child: child,
    );
  }
}

/// Show widget only on desktop devices (>= 992px)
class DesktopOnly extends StatelessWidget {
  final Widget child;
  final Widget? replacement;

  const DesktopOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveVisibility(
      visibleOnMobile: false,
      visibleOnTablet: false,
      visibleOnDesktop: true,
      replacement: replacement,
      child: child,
    );
  }
}

/// Show widget only on web layout (>= 600px)
/// Matches responsive_modal.dart pattern
class WebOnly extends StatelessWidget {
  final Widget child;
  final Widget? replacement;

  const WebOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveVisibility(
      visibleOnMobile: false,
      visibleOnTablet: true,
      visibleOnDesktop: true,
      replacement: replacement,
      child: child,
    );
  }
}

/// Widget that provides responsive values to its builder
///
/// Usage:
/// ```dart
/// ResponsiveValueBuilder<double>(
///   mobile: 16.0,
///   tablet: 24.0,
///   desktop: 32.0,
///   builder: (context, value) => Padding(
///     padding: EdgeInsets.all(value),
///     child: child,
///   ),
/// )
/// ```
class ResponsiveValueBuilder<T> extends StatelessWidget {
  /// Value for mobile screens
  final T mobile;

  /// Value for tablet screens (optional, falls back to mobile)
  final T? tablet;

  /// Value for desktop screens (optional, falls back to tablet or mobile)
  final T? desktop;

  /// Builder that receives the responsive value
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValueBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.responsive<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return builder(context, value);
  }
}

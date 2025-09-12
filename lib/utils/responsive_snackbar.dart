import 'package:flutter/material.dart';
import 'package:mynt_plus/res/res.dart';

/// Responsive SnackBar utility that adapts to screen size
/// Shows toast-style notification in bottom-right corner on desktop
/// Uses standard SnackBar behavior on mobile
class ResponsiveSnackBar {
  
  /// Shows a responsive snackbar/toast notification
  /// On desktop (width >= 600): Shows as toast in bottom-right corner
  /// On mobile (width < 600): Uses standard SnackBar
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 600) {
      // Desktop: Show as custom toast in bottom-right corner
      _showDesktopToast(
        context: context,
        message: message,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      );
    } else {
      // Mobile: Use standard SnackBar
      _showMobileSnackBar(
        context: context,
        message: message,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      );
    }
  }
  
  /// Shows desktop toast notification in bottom-right corner
  static void _showDesktopToast({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final overlay = Overlay.of(context);
    
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _DesktopToastWidget(
        message: message,
        type: type,
        onDismiss: () => overlayEntry.remove(),
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
  
  /// Shows standard mobile SnackBar
  static void _showMobileSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final colorScheme = _getColorScheme(type);
    
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: colorScheme.surface,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.primary, width: 1),
      ),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: colorScheme.primary,
              onPressed: onActionPressed,
            )
          : null,
    );
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  /// Gets color scheme based on SnackBar type
  static _ColorScheme _getColorScheme(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _ColorScheme(
          surface: colors.successLight.withOpacity(0.9),
          onSurface: Colors.white,
          primary: colors.successLight,
        );
      case SnackBarType.error:
        return _ColorScheme(
          surface: colors.lossLight.withOpacity(0.9),
          onSurface: Colors.white,
          primary: colors.lossLight,
        );
      case SnackBarType.warning:
        return _ColorScheme(
          surface: Colors.orange.withOpacity(0.9),
          onSurface: Colors.white,
          primary: Colors.orange,
        );
      case SnackBarType.info:
      default:
        return _ColorScheme(
          surface: colors.colorBlue.withOpacity(0.9),
          onSurface: Colors.white,
          primary: colors.colorBlue,
        );
    }
  }
  
  /// Convenience methods for different types
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    show(context: context, message: message, type: SnackBarType.success, duration: duration ?? const Duration(seconds: 3));
  }
  
  static void showError(BuildContext context, String message, {Duration? duration}) {
    show(context: context, message: message, type: SnackBarType.error, duration: duration ?? const Duration(seconds: 4));
  }
  
  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    show(context: context, message: message, type: SnackBarType.warning, duration: duration ?? const Duration(seconds: 3));
  }
  
  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    show(context: context, message: message, type: SnackBarType.info, duration: duration ?? const Duration(seconds: 3));
  }
}

/// SnackBar types for different message categories
enum SnackBarType {
  info,
  success,
  warning,
  error,
}

/// Desktop toast widget that appears in bottom-right corner
class _DesktopToastWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  
  const _DesktopToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.actionLabel,
    this.onActionPressed,
  });
  
  @override
  State<_DesktopToastWidget> createState() => _DesktopToastWidgetState();
}

class _DesktopToastWidgetState extends State<_DesktopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = ResponsiveSnackBar._getColorScheme(widget.type);
    final screenSize = MediaQuery.of(context).size;
    
    return Positioned(
      right: 16,
      bottom: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.3,
                    minWidth: 280,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon based on type
                        _buildTypeIcon(widget.type, colorScheme),
                        const SizedBox(width: 12),
                        // Message
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // Action button if provided
                        if (widget.actionLabel != null && widget.onActionPressed != null) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              widget.onActionPressed!();
                              _dismiss();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              minimumSize: const Size(60, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        // Close button
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _dismiss,
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTypeIcon(SnackBarType type, _ColorScheme colorScheme) {
    IconData icon;
    switch (type) {
      case SnackBarType.success:
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      default:
        icon = Icons.info;
        break;
    }
    
    return Icon(
      icon,
      color: colorScheme.primary,
      size: 20,
    );
  }
}

/// Simple color scheme class for SnackBar theming
class _ColorScheme {
  final Color surface;
  final Color onSurface;
  final Color primary;
  
  const _ColorScheme({
    required this.surface,
    required this.onSurface,
    required this.primary,
  });
}
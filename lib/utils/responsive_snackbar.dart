import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/provider/thems.dart';


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
      builder: (context) => ProviderScope(
        parent: ProviderScope.containerOf(context, listen: false),
        child: _DesktopToastWidget(
          message: message,
          type: type,
          onDismiss: () => overlayEntry.remove(),
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
        ),
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
class _DesktopToastWidget extends ConsumerStatefulWidget {
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
  ConsumerState<_DesktopToastWidget> createState() => _DesktopToastWidgetState();
}

class _DesktopToastWidgetState extends ConsumerState<_DesktopToastWidget>
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
    final theme = ref.watch(themeProvider);
    final screenSize = MediaQuery.of(context).size;
    
    // Get theme-aware colors based on type
    final toastColors = _getToastColors(widget.type, theme.isDarkMode);
    
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
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.3,
                    minWidth: 320,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        toastColors.backgroundColor,
                        toastColors.backgroundColor.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular icon on the left
                        _buildTypeIcon(widget.type, toastColors.iconColor),
                        const SizedBox(width: 12),
                        // Text content on the right
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type label (SUCCESS, ERROR, INFO, WARNING)
                              Text(
                                _getTypeLabel(widget.type),
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: toastColors.textColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Message text
                              Text(
                                widget.message,
                                style: WebTextStyles.bodySmall(
                                  isDarkTheme: theme.isDarkMode,
                                  color:  const Color(0xFF000000),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _dismiss,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: toastColors.textColor.withOpacity(0.7),
                              ),
                            ),
                          ),
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
  
  String _getTypeLabel(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return 'SUCCESS';
      case SnackBarType.error:
        return 'ERROR';
      case SnackBarType.warning:
        return 'WARNING';
      case SnackBarType.info:
      default:
        return 'INFO';
    }
  }
  
  Widget _buildTypeIcon(SnackBarType type, Color iconBgColor) {
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        icon = Icons.check;
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
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconBgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }
  
  _ToastColors _getToastColors(SnackBarType type, bool isDarkMode) {
    switch (type) {
      case SnackBarType.success:
        return const _ToastColors(
          backgroundColor: Color(0xFFE8F5E9), // Light green background
          borderColor: Color(0xFF4CAF50), // Green border (not used but kept for consistency)
          headerColor: Color(0xFF2E7D32), // Dark green text
          iconColor: Color(0xFF4CAF50), // Green icon background
          textColor: Color(0xFF1B5E20), // Dark green text color
        );
      case SnackBarType.error:
        return const _ToastColors(
          backgroundColor: Color(0xFFFFEBEE), // Light red background
          borderColor: Color(0xFFF44336), // Red border
          headerColor: Color(0xFFC62828), // Dark red text
          iconColor: Color(0xFFF44336), // Red icon background
          textColor: Color(0xFFB71C1C), // Dark red text color
        );
      case SnackBarType.warning:
        return const _ToastColors(
          backgroundColor: Color(0xFFFFF3E0), // Light orange background
          borderColor: Color(0xFFFF9800), // Orange border
          headerColor: Color(0xFFE65100), // Dark orange text
          iconColor: Color(0xFFFF9800), // Orange icon background
          textColor: Color(0xFFBF360C), // Dark orange text color
        );
      case SnackBarType.info:
      default:
        return const _ToastColors(
          backgroundColor: Color(0xFFE3F2FD), // Light blue background
          borderColor: Color(0xFF2196F3), // Blue border
          headerColor: Color(0xFF1565C0), // Dark blue text
          iconColor: Color(0xFF2196F3), // Blue icon background
          textColor: Color(0xFF0D47A1), // Dark blue text color
        );
    }
  }
}

/// Toast color scheme
class _ToastColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color headerColor;
  final Color iconColor;
  final Color textColor;
  
  const _ToastColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.headerColor,
    required this.iconColor,
    required this.textColor,
  });
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
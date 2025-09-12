import 'package:flutter/material.dart';

/// Utility class for showing responsive modals
/// Shows a Dialog on desktop (width >= 600) and ModalBottomSheet on mobile
class ResponsiveModal {
  /// Shows a responsive modal that adapts to screen size
  /// On desktop (width >= 600): Shows as a Dialog
  /// On mobile (width < 600): Shows as a ModalBottomSheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    
    // Dialog specific properties
    double? dialogWidth,
    double? dialogHeight,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    
    // BottomSheet specific properties
    ShapeBorder? shape,
    Color? backgroundColor,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool isScrollControlled = false,
    
    // PopScope specific properties (for non-dismissible modals)
    bool canPop = true,
    Function(bool, dynamic)? onPopInvokedWithResult,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 600) {
      // Desktop: Show as Dialog
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        builder: (BuildContext context) {
          Widget dialogChild = child;
          
          // Wrap with PopScope if needed
          if (!canPop && onPopInvokedWithResult != null) {
            dialogChild = PopScope(
              canPop: canPop,
              onPopInvokedWithResult: onPopInvokedWithResult,
              child: dialogChild,
            );
          }
          
          return Dialog(
            shape: shape ?? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: backgroundColor,
            child: SizedBox(
              width: dialogWidth ?? MediaQuery.of(context).size.width * 0.4,
              height: dialogHeight,
              child: dialogChild,
            ),
          );
        },
      );
    } else {
      // Mobile: Show as ModalBottomSheet
      Widget bottomSheetChild = child;
      
      // Wrap with PopScope if needed
      if (!canPop && onPopInvokedWithResult != null) {
        bottomSheetChild = PopScope(
          canPop: canPop,
          onPopInvokedWithResult: onPopInvokedWithResult,
          child: bottomSheetChild,
        );
      }
      
      return showModalBottomSheet<T>(
        context: context,
        shape: shape ?? const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))
        ),
        backgroundColor: backgroundColor ?? const Color(0xffffffff),
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle,
        useSafeArea: useSafeArea,
        isScrollControlled: isScrollControlled,
        builder: (BuildContext context) => bottomSheetChild,
      );
    }
  }

  /// Convenience method for non-dismissible modals
  static Future<T?> showNonDismissible<T>({
    required BuildContext context,
    required Widget child,
    double? dialogWidth,
    double? dialogHeight,
    ShapeBorder? shape,
    Color? backgroundColor,
  }) {
    return show<T>(
      context: context,
      child: child,
      dialogWidth: dialogWidth,
      dialogHeight: dialogHeight,
      shape: shape,
      backgroundColor: backgroundColor,
      barrierDismissible: false,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      useSafeArea: false,
      isScrollControlled: true,
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
    );
  }

  /// Helper method to get responsive width
  static double getResponsiveWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Helper method to check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}
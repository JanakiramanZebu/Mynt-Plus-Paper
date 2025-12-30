import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Shadcn Drawer wrapper for Mynt Plus
/// A side panel that slides in from the right (or left) using the official shadcn_flutter drawer
///
/// Usage:
/// ```dart
/// showShadDrawerRight(
///   context: context,
///   child: MyDrawerContent(),
///   width: 500,
/// );
/// ```

/// Shows a drawer from the right side
///
/// Uses the official shadcn_flutter drawer component with:
/// - Smooth slide-in animation from right
/// - Backdrop transformation and dimming
/// - Draggable to dismiss gesture support
/// - Proper theming and safe area handling
Future<T?> showShadDrawerRight<T>({
  required BuildContext context,
  required Widget child,
  double width = 500,
  bool barrierDismissible = true,
  bool draggable = true,
  bool showDragHandle = false,
  Color? barrierColor,
}) {
  return shadcn.openDrawer<T>(
    context: context,
    position: shadcn.OverlayPosition.end,
    expands: false,
    draggable: draggable,
    barrierDismissible: barrierDismissible,
    useSafeArea: true,
    showDragHandle: showDragHandle,
    barrierColor: barrierColor,
    transformBackdrop: true,
    constraints: BoxConstraints(
      maxWidth: width,
      minWidth: width,
    ),
    alignment: Alignment.centerRight,
    builder: (context) => SizedBox(
      width: width,
      child: child,
    ),
  );
}

/// Shows a drawer from the left side
///
/// Uses the official shadcn_flutter drawer component with:
/// - Smooth slide-in animation from left
/// - Backdrop transformation and dimming
/// - Draggable to dismiss gesture support
/// - Proper theming and safe area handling
Future<T?> showShadDrawerLeft<T>({
  required BuildContext context,
  required Widget child,
  double width = 500,
  bool barrierDismissible = true,
  bool draggable = true,
  bool showDragHandle = false,
  Color? barrierColor,
}) {
  return shadcn.openDrawer<T>(
    context: context,
    position: shadcn.OverlayPosition.start,
    expands: false,
    draggable: draggable,
    barrierDismissible: barrierDismissible,
    useSafeArea: true,
    showDragHandle: showDragHandle,
    barrierColor: barrierColor,
    transformBackdrop: true,
    constraints: BoxConstraints(
      maxWidth: width,
      minWidth: width,
    ),
    alignment: Alignment.centerLeft,
    builder: (context) => SizedBox(
      width: width,
      child: child,
    ),
  );
}

/// Shows a sheet from the bottom
///
/// Uses the official shadcn_flutter sheet component for bottom sheets.
/// Sheets are similar to drawers but without backdrop transformation,
/// typically used for mobile-style bottom sheets.
Future<T?> showShadSheetBottom<T>({
  required BuildContext context,
  required Widget child,
  double? height,
  bool barrierDismissible = true,
  bool draggable = true,
  Color? barrierColor,
}) {
  return shadcn.openDrawer<T>(
    context: context,
    position: shadcn.OverlayPosition.bottom,
    expands: height == null,
    draggable: draggable,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transformBackdrop: false,
    useSafeArea: true,
    constraints: height != null
        ? BoxConstraints(
            maxHeight: height,
            minHeight: height,
          )
        : null,
    builder: (context) => child,
  );
}

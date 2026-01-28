import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/responsive_snackbar.dart';

//It serves to display information to the user.

void error(BuildContext context, String errorText) {
  if (kIsWeb) {
    ResponsiveSnackBar.showError(rootNavigatorKey.currentContext ?? context, errorText);
    return;
  }
  rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.error_outline, size: 20, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: '✕',
          onPressed: () {
            // Automatically dismisses the snackbar
            rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
          textColor: Colors.white70,
        ),
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF2C2C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 16,
          right: 0,
        ),
        elevation: 4));
}

void successMessage(BuildContext context, String success) {
  if (kIsWeb) {
    ResponsiveSnackBar.showSuccess(rootNavigatorKey.currentContext ?? context, success);
    return;
  }
  rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.check_circle_outline,
                size: 20, color: Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: '✕',
          onPressed: () {
            // Automatically dismisses the snackbar
            rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
          textColor: Colors.white70,
        ),
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF2C2C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 16,
          right: 0,
        ),
        elevation: 4));
}

void warningMessage(BuildContext context, String warning) {
  if (kIsWeb) {
    ResponsiveSnackBar.showWarning(rootNavigatorKey.currentContext ?? context, warning);
    return;
  }
  rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.warning_amber_outlined,
                size: 20, color: Color(0xFFFFC107)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                warning,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: '✕',
          onPressed: () {
            // Automatically dismisses the snackbar
            rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
          textColor: Colors.white70,
        ),
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF2C2C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 16,
          right: 0,
        ), // Changed to EdgeInsets.only to avoid unnecessary padding
        // .symmetric(vertical: 0, horizontal: 0),

        elevation: 4));
}

void warningToaster(BuildContext context, String warningtoaster) {
  if (kIsWeb) {
    ResponsiveSnackBar.showWarning(rootNavigatorKey.currentContext ?? context, warningtoaster);
    return;
  }
  rootScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.warning_amber_outlined,
              size: 20, color: Color(0xFFFFC107)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              warningtoaster,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: '✕',
        onPressed: () {
          // Automatically dismisses the snackbar
          rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        },
        textColor: Colors.white70,
      ),
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF2C2C2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 0,
        left: 16,
        right: 0,
      ),
      elevation: 4));
}

// === RESPONSIVE SNACKBAR FUNCTIONS ===
// These functions use ResponsiveSnackBar for better desktop experience

/// Shows responsive error message
/// Desktop: Toast in bottom-right corner | Mobile: Standard SnackBar
void showResponsiveError(BuildContext context, String message) {
  ResponsiveSnackBar.showError(
      rootNavigatorKey.currentContext ?? context, message);
}

/// Shows responsive warning message
/// Desktop: Toast in bottom-right corner | Mobile: Standard SnackBar
void showResponsiveWarning(BuildContext context, String message) {
  ResponsiveSnackBar.showWarning(
      rootNavigatorKey.currentContext ?? context, message);
}

/// Shows responsive success message
/// Desktop: Toast in bottom-right corner | Mobile: Standard SnackBar
void showResponsiveSuccess(BuildContext context, String message) {
  ResponsiveSnackBar.showSuccess(
      rootNavigatorKey.currentContext ?? context, message);
}

/// Shows responsive info message
/// Desktop: Toast in bottom-right corner | Mobile: Standard SnackBar
void showResponsiveInfo(BuildContext context, String message) {
  ResponsiveSnackBar.showInfo(
      rootNavigatorKey.currentContext ?? context, message);
}

/// Replaces ScaffoldMessenger.of(context).showSnackBar(warningMessage(context, message))
/// with responsive version for better desktop experience
void showResponsiveWarningMessage(BuildContext context, String message) {
  ResponsiveSnackBar.showWarning(context, message);
}

/// Replaces ScaffoldMessenger.of(context).showSnackBar(error(context, message))
/// with responsive version for better desktop experience
void showResponsiveErrorMessage(BuildContext context, String message) {
  ResponsiveSnackBar.showError(context, message);
}

import 'package:flutter/material.dart';

/// Global manager for tracking and controlling all open overlay dialogs
/// (order screens, modify order screens, GTT screens, etc.)
class OverlayManager {
  OverlayManager._();

  // Store all active overlay entries
  static final List<OverlayEntry> _activeOverlays = [];

  /// Register a new overlay entry and close any existing overlays
  /// This ensures only ONE order dialog is visible at a time
  static void register(OverlayEntry entry) {
    // Close all existing overlays before adding the new one
    closeAllExisting();

    // Add the new overlay
    _activeOverlays.add(entry);
  }

  /// Unregister an overlay entry when it's closed
  static void unregister(OverlayEntry entry) {
    _activeOverlays.remove(entry);
  }

  /// Close all existing overlays (internal method)
  static void closeAllExisting() {
    // Create a copy of the list to avoid concurrent modification
    final overlaysCopy = List<OverlayEntry>.from(_activeOverlays);

    for (final overlay in overlaysCopy) {
      try {
        if (overlay.mounted) {
          overlay.remove();
        }
      } catch (e) {
        debugPrint('Error removing overlay: $e');
      }
    }

    // Clear the list
    _activeOverlays.clear();
  }

  /// Close all open overlays (used for session expiry, account switch, logout)
  static void closeAll() {
    closeAllExisting();
  }

  /// Check if there are any active overlays
  static bool get hasActiveOverlays => _activeOverlays.isNotEmpty;

  /// Get count of active overlays
  static int get activeOverlayCount => _activeOverlays.length;
}

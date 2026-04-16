import 'package:flutter/material.dart';
import '../models/panel_config.dart';
import '../models/screen_type.dart';

class PanelUtils {
  /// Calculate responsive split ratio for watchlist based on screen width
  /// Uses Bootstrap-inspired breakpoints for optimal layout at different screen sizes
  ///
  /// Breakpoints:
  /// - XL (>= 1600px): 20% watchlist width
  /// - LG (>= 1200px): 25% watchlist width (default)
  /// - MD (>= 992px): 28% watchlist width
  /// - SM (>= 768px): 30% watchlist width
  /// - XS (< 768px): 35% watchlist width
  ///
  /// [isLeftPanel] - true if watchlist is in left panel, false if in right panel
  static double getResponsiveWatchlistRatio(BuildContext context,
      {required bool isLeftPanel}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double watchlistRatio;

    // Calculate watchlist width percentage based on screen size
    if (screenWidth >= 1600) {
      // Extra Large screens (>= 1600px): 20% watchlist
      watchlistRatio = 0.20;
    } else if (screenWidth >= 1200) {
      // Large screens (>= 1200px): 25% watchlist (default)
      watchlistRatio = 0.25;
    } else if (screenWidth >= 992) {
      // Medium screens (>= 992px): 28% watchlist
      watchlistRatio = 0.28;
    } else if (screenWidth >= 768) {
      // Small screens (>= 768px): 30% watchlist
      watchlistRatio = 0.30;
    } else {
      // Extra Small screens (< 768px): 35% watchlist
      watchlistRatio = 0.35;
    }

    // Apply min/max constraints to prevent extreme widths
    const double minWatchlistWidth = 280.0; // Minimum 280px for readability
    const double maxWatchlistWidth = 450.0; // Maximum 450px to prevent oversized

    // Calculate actual pixel width
    double actualWidth = screenWidth * watchlistRatio;

    // Clamp to min/max bounds
    actualWidth = actualWidth.clamp(minWatchlistWidth, maxWatchlistWidth);

    // Recalculate ratio based on clamped width
    watchlistRatio = actualWidth / screenWidth;

    // Return appropriate ratio based on panel position
    // If watchlist is on left: return the ratio directly (left panel = ratio, right panel = 1-ratio)
    // If watchlist is on right: return 1-ratio (left panel = 1-ratio, right panel = ratio)
    return isLeftPanel ? watchlistRatio : (1.0 - watchlistRatio);
  }

  // Check if panel has watchlist
  static bool hasWatchlist(PanelConfig panel) {
    return panel.screenType == ScreenType.watchlist ||
        (panel.screens.isNotEmpty &&
            panel.screens.contains(ScreenType.watchlist));
  }

  // Get first available panel index
  static int getFirstAvailablePanelIndex(List<PanelConfig> panels) {
    for (int i = 0; i < panels.length; i++) {
      if (panels[i].screenType == null && panels[i].screens.isEmpty) {
        return i;
      }
    }
    return 0; // Return first panel if all are filled
  }

  // Find panel without watchlist
  static int findPanelWithoutWatchlist(List<PanelConfig> panels) {
    for (int i = 0; i < panels.length; i++) {
      if (!hasWatchlist(panels[i])) {
        return i;
      }
    }
    return 0; // Default to first panel
  }

  // Check if screen exists in any panel
  static bool screenExistsInPanels(
      List<PanelConfig> panels, ScreenType screenType) {
    for (var panel in panels) {
      if (panel.screenType == screenType ||
          (panel.screens.isNotEmpty && panel.screens.contains(screenType))) {
        return true;
      }
    }
    return false;
  }

  // Get active screen from panel
  static ScreenType? getActiveScreen(PanelConfig panel) {
    if (panel.screens.isNotEmpty &&
        panel.activeScreenIndex >= 0 &&
        panel.activeScreenIndex < panel.screens.length) {
      return panel.screens[panel.activeScreenIndex];
    } else {
      return panel.screenType;
    }
  }
}

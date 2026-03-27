import 'package:flutter/material.dart';

/// Mixin that provides client-side progressive rendering (scroll-to-load)
/// for report table screens.
///
/// Usage:
/// 1. Add `with ScrollToLoadMixin` to your State class.
/// 2. Override `tableScrollController` to return the ScrollController
///    attached to the scrollable table body.
/// 3. Call `initScrollToLoad()` in `initState()`.
/// 4. Call `disposeScrollToLoad()` in `dispose()`.
/// 5. Use `takeDisplayed(list)` or `.take(displayedItemCount)` on your data list.
/// 6. Call `resetDisplayCount()` when filters, search, tabs, or data change.
mixin ScrollToLoadMixin<T extends StatefulWidget> on State<T> {
  static const int itemsPerPage = 20;

  int displayedItemCount = itemsPerPage;
  bool _isLoadingMore = false;

  /// Subclasses must return the ScrollController attached to the
  /// scrollable table body.
  ScrollController get tableScrollController;

  /// Call in initState() to attach the scroll listener.
  void initScrollToLoad() {
    tableScrollController.addListener(_onScroll);
  }

  /// Call in dispose() to detach the scroll listener.
  void disposeScrollToLoad() {
    tableScrollController.removeListener(_onScroll);
  }

  /// Resets the display count back to the first page.
  void resetDisplayCount() {
    setState(() {
      displayedItemCount = itemsPerPage;
    });
  }

  /// Convenience: apply `.take(displayedItemCount)` on any list.
  List<E> takeDisplayed<E>(List<E> items) {
    return items.take(displayedItemCount).toList();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    final position = tableScrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = maxScroll * 0.8;

    if (currentScroll >= threshold) {
      setState(() {
        _isLoadingMore = true;
        displayedItemCount += itemsPerPage;
        _isLoadingMore = false;
      });
    }
  }
}

import 'package:flutter/material.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';

/// A symmetric vertical split view with two equal panels and a shared grab handle.
/// Similar to VS Code's split panel / timeline UI.
///
/// Features:
/// - Both panels have identical visual styling (card-like surface with header)
/// - Shared center grab handle for resizing
/// - Dragging only expands the bottom panel
/// - Top panel scrolls when space is insufficient (does NOT shrink)
/// - Both panels scroll independently
class ResizablePanelSplitter extends StatefulWidget {
  /// The top panel content (Market Info: OHLC, Bid/Ask, etc.)
  final Widget topChild;

  /// The bottom panel content (Positions & Orders)
  final Widget bottomChild;

  /// Label for the top section header
  final String topSectionLabel;

  /// Label for the bottom section header
  final String bottomSectionLabel;

  /// Initial height of the bottom panel
  final double initialBottomHeight;

  /// Minimum height for the top panel
  final double minTopHeight;

  /// Minimum height for the bottom panel (collapsed state)
  final double minBottomHeight;

  /// Maximum height for the bottom panel
  final double maxBottomHeight;

  /// Whether to show the bottom panel
  final bool showBottomPanel;

  /// Callback when the bottom panel is expanded/collapsed
  final ValueChanged<bool>? onExpansionChanged;

  const ResizablePanelSplitter({
    super.key,
    required this.topChild,
    required this.bottomChild,
    this.topSectionLabel = "Market Info",
    this.bottomSectionLabel = "Positions & Orders",
    this.initialBottomHeight = 280.0,
    this.minTopHeight = 100.0,
    this.minBottomHeight = 60.0,
    this.maxBottomHeight = 400.0,
    this.showBottomPanel = true,
    this.onExpansionChanged,
  });

  @override
  State<ResizablePanelSplitter> createState() => _ResizablePanelSplitterState();
}

class _ResizablePanelSplitterState extends State<ResizablePanelSplitter> {
  late double _bottomPanelHeight;
  bool _isDragging = false;
  bool _isExpanded = false;
  final ScrollController _topScrollController = ScrollController();
  final ScrollController _bottomScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bottomPanelHeight = widget.initialBottomHeight;
    _isExpanded = _bottomPanelHeight > widget.minBottomHeight + 20;
  }

  @override
  void dispose() {
    _topScrollController.dispose();
    _bottomScrollController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      // Dragging up increases bottom panel height (negative delta)
      // Dragging down decreases bottom panel height (positive delta)
      final newHeight = _bottomPanelHeight - details.primaryDelta!;
      _bottomPanelHeight = newHeight.clamp(
        widget.minBottomHeight,
        widget.maxBottomHeight,
      );
      _isExpanded = _bottomPanelHeight > widget.minBottomHeight + 20;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      // Snap to expanded or collapsed state
      if (_bottomPanelHeight < widget.minBottomHeight + 40) {
        _bottomPanelHeight = widget.minBottomHeight;
        _isExpanded = false;
      } else if (_bottomPanelHeight > widget.maxBottomHeight - 40) {
        _bottomPanelHeight = widget.maxBottomHeight;
        _isExpanded = true;
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  void _toggleExpansion() {
    setState(() {
      if (_isExpanded) {
        _bottomPanelHeight = widget.minBottomHeight;
        _isExpanded = false;
      } else {
        _bottomPanelHeight = widget.maxBottomHeight * 0.6;
        _isExpanded = true;
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  /// Build a panel header bar with title
  Widget _buildPanelHeader(String title, {bool isTopPanel = true}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
        // Add rounded corners at top for the first panel header to match container border
        borderRadius: isTopPanel
            ? const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              )
            : null,
        border: isTopPanel
            ? null
            : Border(
                bottom: BorderSide(
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider,
                  ),
                  width: 0.5,
                ),
              ),
      ),
      child: Text(
        title,
        style: MyntWebTextStyles.body(
          context,
          fontWeight: MyntFonts.semiBold,
          color: resolveThemeColor(
            context,
            dark: MyntColors.textPrimaryDark,
            light: MyntColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Build a simple grab handle divider between panels
  Widget _buildGrabHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleExpansion,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          width: double.infinity,
          height: 24, // Consistent hit area height
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor,
            ),
            border: Border(
              top: BorderSide(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
                width: 4,
              ),
            ),
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _isDragging
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary,
                      )
                    : resolveThemeColor(
                        context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary,
                      ).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Single panel mode (no bottom panel)
    if (!widget.showBottomPanel) {
      return Container(
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            dark: MyntColors.backgroundColorDark,
            light: MyntColors.backgroundColor,
          ),
          border: Border(
            left: BorderSide(
              color: resolveThemeColor(
                context,
                dark: MyntColors.dividerDark,
                light: MyntColors.divider,
              ),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header bar
            _buildPanelHeader(widget.topSectionLabel),
            // Scrollable content
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                  child: RawScrollbar(
                    controller: _topScrollController,
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(0),
                    thumbColor: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ).withValues(alpha: 0.5),
                    child: SingleChildScrollView(
                      controller: _topScrollController,
                      child: widget.topChild,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Two-panel split view mode
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        // Account for the grab handle height (hit area and visual: 24px)
        final dividerHeight = 24.0;
        final availableTopHeight = totalHeight - _bottomPanelHeight - dividerHeight;

        return Container(
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor,
            ),
            border: Border(
              left: BorderSide(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
                width: 1,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ===== TOP PANEL (Market Info) =====
              SizedBox(
                height: availableTopHeight > widget.minTopHeight
                    ? availableTopHeight
                    : widget.minTopHeight,
                child: Column(
                  children: [
                    // Top panel header
                    _buildPanelHeader(widget.topSectionLabel),
                    // Top panel scrollable content
                    Expanded(
                      child: ClipRect(
                        child: ScrollConfiguration(
                          behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                          child: RawScrollbar(
                            controller: _topScrollController,
                            thumbVisibility: true,
                            thickness: 6,
                            radius: const Radius.circular(0),
                            thumbColor: resolveThemeColor(
                              context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary,
                            ).withValues(alpha: 0.5),
                            child: SingleChildScrollView(
                              controller: _topScrollController,
                              child: widget.topChild,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== GRAB HANDLE =====
              _buildGrabHandle(),

              // ===== BOTTOM PANEL (Positions & Orders) =====
              SizedBox(
                height: _bottomPanelHeight,
                child: Column(
                  children: [
                    // Bottom panel header (same style as top panel)
                    _buildPanelHeader(widget.bottomSectionLabel, isTopPanel: false),
                    // Bottom panel scrollable content
                    Expanded(
                      child: ClipRect(
                        child: ScrollConfiguration(
                          behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                          child: RawScrollbar(
                            controller: _bottomScrollController,
                            thumbVisibility: _isExpanded,
                            thickness: 6,
                            radius: const Radius.circular(0),
                            thumbColor: resolveThemeColor(
                              context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary,
                            ).withValues(alpha: 0.5),
                            child: SingleChildScrollView(
                              controller: _bottomScrollController,
                              padding: EdgeInsets.zero,
                              child: widget.bottomChild,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

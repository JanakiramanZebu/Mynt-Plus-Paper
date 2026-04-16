import 'package:flutter/material.dart';
import '../res/app_breakpoints.dart';
import '../res/responsive_extensions.dart';
import '../res/app_spacing.dart';

/// A container that adapts its constraints and padding based on screen size
///
/// Prevents overflow by constraining content appropriately.
///
/// Usage:
/// ```dart
/// ResponsiveContainer(
///   child: MyContent(),
///   maxWidth: 800,
///   useResponsivePadding: true,
/// )
/// ```
class ResponsiveContainer extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Maximum width constraint (uses responsive default if not provided)
  final double? maxWidth;

  /// Minimum width constraint
  final double? minWidth;

  /// Use responsive horizontal padding based on screen size
  final bool useResponsivePadding;

  /// Additional padding (added to responsive padding if enabled)
  final EdgeInsets? padding;

  /// Center the content horizontally
  final bool center;

  /// Background color
  final Color? backgroundColor;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Box decoration (overrides backgroundColor and borderRadius)
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.minWidth,
    this.useResponsivePadding = true,
    this.padding,
    this.center = true,
    this.backgroundColor,
    this.borderRadius,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply constraints
    final effectiveMaxWidth = maxWidth ?? context.maxContentWidth;
    content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: effectiveMaxWidth,
        minWidth: minWidth ?? 0,
      ),
      child: content,
    );

    // Apply padding
    EdgeInsets basePadding = padding ?? EdgeInsets.zero;
    EdgeInsets responsivePadding = useResponsivePadding
        ? context.responsiveHorizontalPadding
        : EdgeInsets.zero;

    final effectivePadding = EdgeInsets.only(
      left: basePadding.left + responsivePadding.left,
      top: basePadding.top + responsivePadding.top,
      right: basePadding.right + responsivePadding.right,
      bottom: basePadding.bottom + responsivePadding.bottom,
    );

    if (effectivePadding != EdgeInsets.zero) {
      content = Padding(padding: effectivePadding, child: content);
    }

    // Center if requested
    if (center) {
      content = Center(child: content);
    }

    // Apply decoration or background
    if (decoration != null) {
      content = DecoratedBox(decoration: decoration!, child: content);
    } else if (backgroundColor != null || borderRadius != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: content,
      );
    }

    return content;
  }
}

/// A Row that wraps to Column on smaller screens
///
/// Prevents horizontal overflow by switching to vertical layout.
///
/// Usage:
/// ```dart
/// ResponsiveRow(
///   wrapBreakpoint: 768,
///   children: [
///     Text('Item 1'),
///     Text('Item 2'),
///     Text('Item 3'),
///   ],
/// )
/// ```
class ResponsiveRow extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Breakpoint below which to use Column (default: tablet at 768px)
  final double wrapBreakpoint;

  /// Spacing between items in Row
  final double rowSpacing;

  /// Spacing between items in Column
  final double columnSpacing;

  /// Main axis alignment for Row
  final MainAxisAlignment rowMainAxisAlignment;

  /// Cross axis alignment for Row
  final CrossAxisAlignment rowCrossAxisAlignment;

  /// Main axis alignment for Column
  final MainAxisAlignment columnMainAxisAlignment;

  /// Cross axis alignment for Column
  final CrossAxisAlignment columnCrossAxisAlignment;

  /// Main axis size for Row
  final MainAxisSize rowMainAxisSize;

  /// Main axis size for Column
  final MainAxisSize columnMainAxisSize;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.wrapBreakpoint = AppBreakpoints.md,
    this.rowSpacing = AppSpacing.md,
    this.columnSpacing = AppSpacing.sm,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.rowMainAxisSize = MainAxisSize.max,
    this.columnMainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= wrapBreakpoint) {
          // Use Row with spacing
          return Row(
            mainAxisAlignment: rowMainAxisAlignment,
            crossAxisAlignment: rowCrossAxisAlignment,
            mainAxisSize: rowMainAxisSize,
            children: _addSpacing(children, rowSpacing, Axis.horizontal),
          );
        } else {
          // Use Column with spacing
          return Column(
            mainAxisAlignment: columnMainAxisAlignment,
            crossAxisAlignment: columnCrossAxisAlignment,
            mainAxisSize: columnMainAxisSize,
            children: _addSpacing(children, columnSpacing, Axis.vertical),
          );
        }
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing, Axis axis) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(
          axis == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }
    return result;
  }
}

/// A grid that adapts column count based on screen width
///
/// Usage:
/// ```dart
/// ResponsiveGrid(
///   mobileColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 3,
///   children: [
///     Card1(),
///     Card2(),
///     Card3(),
///   ],
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Number of columns on mobile (< 600px)
  final int mobileColumns;

  /// Number of columns on tablet (600px - 992px)
  final int tabletColumns;

  /// Number of columns on desktop (>= 992px)
  final int desktopColumns;

  /// Spacing between columns
  final double crossAxisSpacing;

  /// Spacing between rows
  final double mainAxisSpacing;

  /// Child aspect ratio (width / height)
  final double childAspectRatio;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether the grid should shrink-wrap
  final bool shrinkWrap;

  /// Padding around the grid
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.crossAxisSpacing = AppSpacing.md,
    this.mainAxisSpacing = AppSpacing.md,
    this.childAspectRatio = 1,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A grid with responsive column count using extent-based sizing
///
/// Automatically calculates column count based on minimum item width.
///
/// Usage:
/// ```dart
/// ResponsiveExtentGrid(
///   minItemWidth: 300,
///   children: [
///     Card1(),
///     Card2(),
///     Card3(),
///   ],
/// )
/// ```
class ResponsiveExtentGrid extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Minimum width for each item
  final double minItemWidth;

  /// Maximum width for each item (optional)
  final double? maxItemWidth;

  /// Spacing between columns
  final double crossAxisSpacing;

  /// Spacing between rows
  final double mainAxisSpacing;

  /// Child aspect ratio (width / height)
  final double childAspectRatio;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether the grid should shrink-wrap
  final bool shrinkWrap;

  /// Padding around the grid
  final EdgeInsets? padding;

  const ResponsiveExtentGrid({
    super.key,
    required this.children,
    this.minItemWidth = 280,
    this.maxItemWidth,
    this.crossAxisSpacing = AppSpacing.md,
    this.mainAxisSpacing = AppSpacing.md,
    this.childAspectRatio = 1,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxItemWidth ?? minItemWidth * 1.5,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A Wrap widget that adjusts spacing based on screen size
///
/// Usage:
/// ```dart
/// ResponsiveWrap(
///   children: [
///     Chip(label: Text('Tag 1')),
///     Chip(label: Text('Tag 2')),
///     Chip(label: Text('Tag 3')),
///   ],
/// )
/// ```
class ResponsiveWrap extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Horizontal spacing between children on mobile
  final double mobileSpacing;

  /// Horizontal spacing between children on desktop
  final double desktopSpacing;

  /// Vertical spacing between lines on mobile
  final double mobileRunSpacing;

  /// Vertical spacing between lines on desktop
  final double desktopRunSpacing;

  /// Alignment of children within the wrap
  final WrapAlignment alignment;

  /// Cross axis alignment
  final WrapCrossAlignment crossAxisAlignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.mobileSpacing = AppSpacing.sm,
    this.desktopSpacing = AppSpacing.md,
    this.mobileRunSpacing = AppSpacing.sm,
    this.desktopRunSpacing = AppSpacing.md,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsive(
      mobile: mobileSpacing,
      desktop: desktopSpacing,
    );
    final runSpacing = context.responsive(
      mobile: mobileRunSpacing,
      desktop: desktopRunSpacing,
    );

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// A widget that provides responsive padding
///
/// Usage:
/// ```dart
/// ResponsivePadding(
///   child: MyContent(),
/// )
/// ```
class ResponsivePadding extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Padding on mobile
  final EdgeInsets? mobilePadding;

  /// Padding on tablet
  final EdgeInsets? tabletPadding;

  /// Padding on desktop
  final EdgeInsets? desktopPadding;

  /// Use horizontal-only responsive padding (default behavior if no padding specified)
  final bool horizontalOnly;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.horizontalOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets effectivePadding;

    if (mobilePadding != null || tabletPadding != null || desktopPadding != null) {
      effectivePadding = context.responsive(
        mobile: mobilePadding ?? EdgeInsets.all(AppSpacing.md),
        tablet: tabletPadding,
        desktop: desktopPadding,
      );
    } else if (horizontalOnly) {
      effectivePadding = context.responsiveHorizontalPadding;
    } else {
      effectivePadding = context.responsiveAllPadding;
    }

    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}

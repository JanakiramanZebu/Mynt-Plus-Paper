import 'package:flutter/material.dart';

/// A Text widget that prevents overflow with ellipsis
/// and optionally scales font based on available width
///
/// Usage:
/// ```dart
/// SafeText(
///   'Long text that might overflow...',
///   maxLines: 2,
///   autoScale: true,
/// )
/// ```
class SafeText extends StatelessWidget {
  /// The text to display
  final String text;

  /// Text style
  final TextStyle? style;

  /// Maximum number of lines before truncating
  final int maxLines;

  /// Text alignment
  final TextAlign? textAlign;

  /// Whether to auto-scale font size to fit
  final bool autoScale;

  /// Text direction
  final TextDirection? textDirection;

  /// Soft wrap
  final bool? softWrap;

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.textAlign,
    this.autoScale = false,
    this.textDirection,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    if (autoScale) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: textAlign == TextAlign.center
            ? Alignment.center
            : textAlign == TextAlign.right
                ? Alignment.centerRight
                : Alignment.centerLeft,
        child: Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
        ),
      );
    }

    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
    );
  }
}

/// A Row that prevents overflow by using Flexible/Expanded correctly
///
/// Usage:
/// ```dart
/// SafeRow(
///   flexibleIndices: [0], // Make first child flexible
///   children: [
///     Text('This can shrink'),
///     Text('Fixed'),
///   ],
/// )
/// ```
class SafeRow extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Main axis alignment
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  /// Main axis size
  final MainAxisSize mainAxisSize;

  /// Which children should be flexible (by index)
  final List<int> flexibleIndices;

  /// Which children should be expanded (by index)
  final List<int> expandedIndices;

  /// Flex values for flexible/expanded children (defaults to 1)
  final Map<int, int>? flexValues;

  const SafeRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.flexibleIndices = const [],
    this.expandedIndices = const [],
    this.flexValues,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final flex = flexValues?[index] ?? 1;

        if (expandedIndices.contains(index)) {
          return Expanded(flex: flex, child: child);
        }
        if (flexibleIndices.contains(index)) {
          return Flexible(flex: flex, child: child);
        }
        return child;
      }).toList(),
    );
  }
}

/// A Column that prevents overflow by using Flexible/Expanded correctly
///
/// Usage:
/// ```dart
/// SafeColumn(
///   expandedIndices: [1], // Make second child expanded
///   children: [
///     Header(),
///     ExpandableContent(),
///     Footer(),
///   ],
/// )
/// ```
class SafeColumn extends StatelessWidget {
  /// Children widgets
  final List<Widget> children;

  /// Main axis alignment
  final MainAxisAlignment mainAxisAlignment;

  /// Cross axis alignment
  final CrossAxisAlignment crossAxisAlignment;

  /// Main axis size
  final MainAxisSize mainAxisSize;

  /// Which children should be flexible (by index)
  final List<int> flexibleIndices;

  /// Which children should be expanded (by index)
  final List<int> expandedIndices;

  /// Flex values for flexible/expanded children (defaults to 1)
  final Map<int, int>? flexValues;

  const SafeColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.flexibleIndices = const [],
    this.expandedIndices = const [],
    this.flexValues,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final flex = flexValues?[index] ?? 1;

        if (expandedIndices.contains(index)) {
          return Expanded(flex: flex, child: child);
        }
        if (flexibleIndices.contains(index)) {
          return Flexible(flex: flex, child: child);
        }
        return child;
      }).toList(),
    );
  }
}

/// Ensures content is scrollable when it might overflow
///
/// Usage:
/// ```dart
/// SafeScrollView(
///   child: Column(children: [...]),
/// )
/// ```
class SafeScrollView extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Scroll direction
  final Axis scrollDirection;

  /// Padding around the content
  final EdgeInsets? padding;

  /// Scroll controller
  final ScrollController? controller;

  /// Whether this is the primary scroll view
  final bool? primary;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Reverse scroll direction
  final bool reverse;

  /// Keyboard dismiss behavior
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  const SafeScrollView({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.controller,
    this.primary,
    this.physics,
    this.reverse = false,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      padding: padding,
      controller: controller,
      primary: primary,
      physics: physics,
      reverse: reverse,
      keyboardDismissBehavior: keyboardDismissBehavior,
      child: child,
    );
  }
}

/// A constrained box that prevents unbounded sizes
///
/// Usage:
/// ```dart
/// SafeConstraints(
///   maxWidth: 600,
///   maxHeight: 400,
///   child: MyContent(),
/// )
/// ```
class SafeConstraints extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Minimum width
  final double? minWidth;

  /// Maximum width
  final double? maxWidth;

  /// Minimum height
  final double? minHeight;

  /// Maximum height
  final double? maxHeight;

  const SafeConstraints({
    super.key,
    required this.child,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: child,
    );
  }
}

/// Intrinsic width wrapper for unbounded horizontal constraints
///
/// Use sparingly as IntrinsicWidth can be expensive.
///
/// Usage:
/// ```dart
/// SafeIntrinsicWidth(
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.stretch,
///     children: [...],
///   ),
/// )
/// ```
class SafeIntrinsicWidth extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Step width for sizing
  final double? stepWidth;

  /// Step height for sizing
  final double? stepHeight;

  const SafeIntrinsicWidth({
    super.key,
    required this.child,
    this.stepWidth,
    this.stepHeight,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      stepWidth: stepWidth,
      stepHeight: stepHeight,
      child: child,
    );
  }
}

/// Intrinsic height wrapper for unbounded vertical constraints
///
/// Use sparingly as IntrinsicHeight can be expensive.
///
/// Usage:
/// ```dart
/// SafeIntrinsicHeight(
///   child: Row(
///     crossAxisAlignment: CrossAxisAlignment.stretch,
///     children: [...],
///   ),
/// )
/// ```
class SafeIntrinsicHeight extends StatelessWidget {
  /// The child widget
  final Widget child;

  const SafeIntrinsicHeight({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(child: child);
  }
}

/// A widget that clips content that would overflow
///
/// Usage:
/// ```dart
/// SafeClip(
///   child: Image.network(url),
/// )
/// ```
class SafeClip extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Clip behavior
  final Clip clipBehavior;

  /// Border radius for rounded clipping
  final BorderRadius? borderRadius;

  const SafeClip({
    super.key,
    required this.child,
    this.clipBehavior = Clip.hardEdge,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    return ClipRect(
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// A sized box with optional constraints that ensures a minimum size
///
/// Usage:
/// ```dart
/// SafeSizedBox(
///   minWidth: 100,
///   minHeight: 50,
///   child: Text('Content'),
/// )
/// ```
class SafeSizedBox extends StatelessWidget {
  /// The child widget
  final Widget? child;

  /// Exact width
  final double? width;

  /// Exact height
  final double? height;

  /// Minimum width
  final double? minWidth;

  /// Minimum height
  final double? minHeight;

  /// Maximum width
  final double? maxWidth;

  /// Maximum height
  final double? maxHeight;

  const SafeSizedBox({
    super.key,
    this.child,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (minWidth != null || minHeight != null || maxWidth != null || maxHeight != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? width ?? 0,
          maxWidth: maxWidth ?? width ?? double.infinity,
          minHeight: minHeight ?? height ?? 0,
          maxHeight: maxHeight ?? height ?? double.infinity,
        ),
        child: child,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}

/// A widget that ensures scrollable content in horizontal direction
/// with proper constraints
///
/// Usage:
/// ```dart
/// SafeHorizontalScroll(
///   child: Row(children: [...]),
/// )
/// ```
class SafeHorizontalScroll extends StatelessWidget {
  /// The child widget (typically a Row)
  final Widget child;

  /// Scroll controller
  final ScrollController? controller;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Padding
  final EdgeInsets? padding;

  const SafeHorizontalScroll({
    super.key,
    required this.child,
    this.controller,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          physics: physics,
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

/// A widget that provides overflow indication
/// Shows a gradient fade when content is clipped
///
/// Usage:
/// ```dart
/// SafeOverflowBox(
///   maxWidth: 200,
///   child: Text('Very long text...'),
/// )
/// ```
class SafeOverflowBox extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// Maximum width
  final double? maxWidth;

  /// Maximum height
  final double? maxHeight;

  /// Show fade gradient on overflow (horizontal)
  final bool showHorizontalFade;

  /// Show fade gradient on overflow (vertical)
  final bool showVerticalFade;

  /// Fade gradient color (defaults to white)
  final Color? fadeColor;

  const SafeOverflowBox({
    super.key,
    required this.child,
    this.maxWidth,
    this.maxHeight,
    this.showHorizontalFade = false,
    this.showVerticalFade = false,
    this.fadeColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (maxWidth != null || maxHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: ClipRect(child: content),
      );
    }

    if (showHorizontalFade || showVerticalFade) {
      final effectiveFadeColor = fadeColor ?? Theme.of(context).scaffoldBackgroundColor;
      content = ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: showHorizontalFade ? Alignment.centerLeft : Alignment.topCenter,
            end: showHorizontalFade ? Alignment.centerRight : Alignment.bottomCenter,
            colors: [
              effectiveFadeColor,
              effectiveFadeColor.withValues(alpha: 0),
              effectiveFadeColor.withValues(alpha: 0),
              effectiveFadeColor,
            ],
            stops: const [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstOut,
        child: content,
      );
    }

    return content;
  }
}

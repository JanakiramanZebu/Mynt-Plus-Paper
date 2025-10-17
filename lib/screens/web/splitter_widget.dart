import 'package:flutter/material.dart';

class SplitterWidget extends StatefulWidget {
  final Widget child1;
  final Widget child2;
  final Axis direction;
  final double initialSplitRatio; // 0.0 to 1.0
  final double minSize1; // Minimum size for first child
  final double minSize2; // Minimum size for second child
  final double splitterSize;
  final Color? splitterColor;
  final VoidCallback? onSplitChanged;
  final bool enableResize;

  const SplitterWidget({
    super.key,
    required this.child1,
    required this.child2,
    this.direction = Axis.horizontal,
    this.initialSplitRatio = 0.5,
    this.minSize1 = 100.0,
    this.minSize2 = 100.0,
    this.splitterSize = 8.0,
    this.splitterColor,
    this.onSplitChanged,
    this.enableResize = true,
  });

  @override
  State<SplitterWidget> createState() => _SplitterWidgetState();
}

class _SplitterWidgetState extends State<SplitterWidget> {
  late double _splitRatio;
  bool _isDragging = false;
  Offset? _lastPanUpdate;

  @override
  void initState() {
    super.initState();
    _splitRatio = widget.initialSplitRatio;
  }

  @override
  void didUpdateWidget(SplitterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSplitRatio != widget.initialSplitRatio) {
      _splitRatio = widget.initialSplitRatio;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enableResize) return;
    _isDragging = true;
    _lastPanUpdate = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging || !widget.enableResize || _lastPanUpdate == null) return;

    final delta = details.globalPosition - _lastPanUpdate!;
    _lastPanUpdate = details.globalPosition;

    final screenSize = widget.direction == Axis.horizontal
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final deltaRatio = widget.direction == Axis.horizontal
        ? delta.dx / screenSize
        : delta.dy / screenSize;

    setState(() {
      final newRatio = (_splitRatio + deltaRatio).clamp(0.0, 1.0);
      
      // Check minimum size constraints
      final totalSize = screenSize;
      final size1 = newRatio * totalSize;
      final size2 = (1.0 - newRatio) * totalSize;
      
      if (size1 >= widget.minSize1 && size2 >= widget.minSize2) {
        _splitRatio = newRatio;
        widget.onSplitChanged?.call();
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _lastPanUpdate = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        final size1 = _splitRatio * totalSize;
        final size2 = totalSize - size1 - widget.splitterSize;

        if (widget.direction == Axis.horizontal) {
          return Row(
            children: [
              SizedBox(
                width: size1,
                child: widget.child1,
              ),
              _buildSplitter(),
              Expanded(
                child: SizedBox(
                  width: size2,
                  child: widget.child2,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(
                height: size1,
                child: widget.child1,
              ),
              _buildSplitter(),
              Expanded(
                child: SizedBox(
                  height: size2,
                  child: widget.child2,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSplitter() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    // Use theme colors for better integration
    final hoverColor = isDarkMode ? theme.primaryColor : theme.primaryColor;
    final handleColor = isDarkMode ? Colors.grey[300]! : Colors.grey[600]!;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.direction == Axis.horizontal ? widget.splitterSize : null,
        height: widget.direction == Axis.vertical ? widget.splitterSize : null,
        decoration: BoxDecoration(
          color: _isDragging 
              ? hoverColor.withOpacity(0.1) 
              : (isDarkMode ? Colors.grey[800]!.withOpacity(0.1) : Colors.grey[100]!.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(widget.splitterSize / 2),
        ),
        child: widget.enableResize
            ? Center(
                child: Container(
                  width: widget.direction == Axis.horizontal ? 6 : 16,
                  height: widget.direction == Axis.vertical ? 6 : 16,
                  decoration: BoxDecoration(
                    color: _isDragging ? hoverColor : handleColor,
                    borderRadius: BorderRadius.circular(widget.direction == Axis.horizontal ? 3 : 12),
                    boxShadow: _isDragging ? [
                      BoxShadow(
                        color: hoverColor.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: _isDragging
                      ? Icon(
                          widget.direction == Axis.horizontal
                              ? Icons.drag_handle
                              : Icons.drag_handle,
                          color: Colors.white,
                          size: widget.direction == Axis.horizontal ? 12 : 16,
                        )
                      : null,
                ),
              )
            : null,
      ),
    );
  }

  // Getter for current split ratio
  double get currentSplitRatio => _splitRatio;
}

// Helper class for nested splitters
class NestedSplitter extends StatelessWidget {
  final List<Widget> children;
  final List<Axis> directions;
  final List<double> splitRatios;
  final double splitterSize;
  final Color? splitterColor;
  final VoidCallback? onSplitChanged;

  const NestedSplitter({
    super.key,
    required this.children,
    required this.directions,
    required this.splitRatios,
    this.splitterSize = 8.0,
    this.splitterColor,
    this.onSplitChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.first;

    Widget result = children.first;
    
    for (int i = 1; i < children.length; i++) {
      final direction = i - 1 < directions.length 
          ? directions[i - 1] 
          : Axis.horizontal;
      final ratio = i - 1 < splitRatios.length 
          ? splitRatios[i - 1] 
          : 0.5;

      result = SplitterWidget(
        child1: result,
        child2: children[i],
        direction: direction,
        initialSplitRatio: ratio,
        splitterSize: splitterSize,
        splitterColor: splitterColor,
        onSplitChanged: onSplitChanged,
      );
    }

    return result;
  }
}

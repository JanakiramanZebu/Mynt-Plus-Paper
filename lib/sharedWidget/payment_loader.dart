import 'package:flutter/material.dart';
import 'dart:math';

class ProgressiveDotsLoader extends StatefulWidget {
  final int numberOfDots;
  final double dotSize;
  final Duration duration;
  final Color dotColor;

  const ProgressiveDotsLoader({
    super.key,
    this.numberOfDots = 8, // Default 8 dots
    this.dotSize = 10.0,
    this.duration = const Duration(seconds: 1),
    this.dotColor = Colors.grey,
  });

  @override
  _ProgressiveDotsLoaderState createState() => _ProgressiveDotsLoaderState();
}

class _ProgressiveDotsLoaderState extends State<ProgressiveDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.dotSize * 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.numberOfDots, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _getDotScale(index),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.dotColor,
              ),
            ),
          );
        }),
      ),
    );
  }

  double _getDotScale(int index) {
    double progress = (_controller.value * widget.numberOfDots - index).abs();
    return max(0.3, 1.0 - progress);
  }
}

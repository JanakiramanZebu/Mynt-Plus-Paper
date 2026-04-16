import 'package:flutter/material.dart';
 

class CustomSliderTumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(8, 11);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double>? activationAnimation,
      Animation<double>? enableAnimation,
      required bool isDiscrete,
      TextPainter? labelPainter,
      RenderBox? parentBox,
      SliderThemeData? sliderTheme,
      TextDirection? textDirection,
      double? value,
      double? textScaleFactor,
      Size? sizeWithOverflow}) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(
        center: center,
        width: getPreferredSize(false, isDiscrete).width,
        height: getPreferredSize(false, isDiscrete).height);

    final paint = Paint();
     
      paint.style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }
}

// import 'package:flutter/material.dart';

// class CustomSlider extends StatelessWidget {
//   final double minValue;
//   final double maxValue;
//   final double value;
//   final ValueChanged<double> onChanged;

//   const CustomSlider({super.key, 
//     required this.value,
//     required this.onChanged,
//     required this.minValue,
//     required this.maxValue, required String assetImage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         // Calculate the new value based on the drag position.
//         final newValue =
//             (details.localPosition.dx / context.size!.width).clamp(0.0, 1.0);
//         onChanged(newValue);
//       },
//       child: CustomPaint(
//         size: const Size(200, 20), // Adjust the size as needed.
//         painter: CustomSliderPainter(value: value),
//       ),
//     );
//   }
// }

// class CustomSliderPainter extends CustomPainter {
//   final double value;

//   CustomSliderPainter({required this.value});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xffD9D9D9)
//       ..strokeWidth = 6.0
//       ..style = PaintingStyle.fill;

//     final paints = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 4.0
//       ..style = PaintingStyle.fill;

//     final thumbX = value * size.width;
//     const thumbRadius = 2.0;

//     // Draw the slider track.
//     canvas.drawLine(
//         Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

//     // Draw the slider thumb.
//     canvas.drawCircle(Offset(thumbX, size.height / 2), thumbRadius, paints);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }

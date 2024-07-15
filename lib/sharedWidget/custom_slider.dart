import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSliders extends StatefulWidget {
  final String assetImage;
  final LinearGradient linearGradient;
  final Color inActiveTrackColor;
  final double trackHeight;
  final double min;
  final double max;
  final int? assetImageHeight;
  final int? assetImageWidth;
  final int? divisions;

  const CustomSliders({
    super.key,
    required this.assetImage,
    required this.linearGradient,
    required this.inActiveTrackColor,
    required this.trackHeight,
    required this.min,
    required this.max,
    this.divisions,
    this.assetImageHeight = 50,
    this.assetImageWidth = 60,
  });

  @override
  State<CustomSliders> createState() => _CustomSlidersState();
}

class _CustomSlidersState extends State<CustomSliders> {
  double intValue = 0;
  ui.Image? customImage;

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: widget.assetImageHeight,
        targetWidth: widget.assetImageWidth);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  void initState() {
    load(widget.assetImage).then((image) {
      setState(() {
        customImage = image;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
          inactiveTrackColor: widget.inActiveTrackColor,
          trackHeight: widget.trackHeight,
          overlayColor: Colors.purple.withAlpha(36),
          thumbShape: customImage != null
              ? SliderThumbImage(customImage!)
              : const RoundSliderThumbShape()),
      child: Slider(
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        onChanged: (double value) {
          setState(() {
            intValue = value;
          });
        },
        value: intValue,
      ),
    );
  }
}

class SliderThumbImage extends SliderComponentShape {
  final ui.Image image;

  SliderThumbImage(this.image);
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(0, 0);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    var canvas = context.canvas;
    final picWidth = image.width;
    final picHeight = image.height;

    Offset picOffset = Offset(
      (center.dx - (picWidth / 2)),
      (center.dy - (picHeight / 2)),
    );

    Paint paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImage(image, picOffset, paint);
  }
}




// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SliderthumbImage extends SliderComponentShape {
//   final ui.Image image;

//   SliderthumbImage(this.image);
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscreate) {
//     throw UnimplementedError();
//   }

//   @override
//   void paint(PaintingContext context, ui.Offset center,
//       {required Animation<double> activationAnimation,
//       required Animation<double> enableAnimation,
//       required bool isDiscrete,
//       required TextPainter labelPainter,
//       required RenderBox parentBox,
//       required SliderThemeData sliderTheme,
//       required TextDirection textDirection,
//       required double value,
//       required double textScaleFactor,
//       required Size sizeWithOverflow}) {
//     var canvas = context.canvas;
//     final picWidth = image.width;
//     final picHeight = image.height;

//     Offset picOffset =
//         Offset(center.dx - (picWidth / 2), center.dy - (picHeight / 2));

//          Paint paint = Paint()..filterQuality = FilterQuality.high;
//     canvas.drawImage(image, picOffset, paint);
//   }
// }

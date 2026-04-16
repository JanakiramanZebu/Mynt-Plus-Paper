class DrawingModel {
  final String drawingName;
  final String drawingIcon;
  const DrawingModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<DrawingModel> drawingList = [
    const DrawingModel(
      drawingName: 'Measure',
      drawingIcon: 'assets/tvchart/measure.svg',
    ),
    const DrawingModel(
      drawingName: 'Zoom In',
      drawingIcon: 'assets/tvchart/zoom.svg',
    ),
    const DrawingModel(
      drawingName: 'Eraser',
      drawingIcon: 'assets/tvchart/eraser.svg',
    ),
    const DrawingModel(
      drawingName: 'Magnet',
      drawingIcon: 'assets/tvchart/weak_magnet.svg',
    ),
    const DrawingModel(
      drawingName: 'Drawing',
      drawingIcon: 'assets/tvchart/brush.svg',
    ),
    const DrawingModel(
      drawingName: 'Hide',
      drawingIcon: 'assets/tvchart/hide.svg',
    ),
    const DrawingModel(
      drawingName: 'Remove',
      drawingIcon: 'assets/tvchart/delete.svg',
    ),
  ];
}

class DrawingId {
  final String drawingId;
  const DrawingId({
    required this.drawingId,
  });

  List<Object?> get props => [drawingId];

  static List<DrawingId> drawingIdList = [
    const DrawingId(drawingId: 'measure'),
    const DrawingId(drawingId: 'zoom'),
    const DrawingId(drawingId: 'eraser'),
    const DrawingId(drawingId: 'dot'),
    const DrawingId(drawingId: 'arrow_cursor'),
    const DrawingId(drawingId: 'cursor'),
    const DrawingId(drawingId: 'brush'),
  ];
}

class TrendingLineModel {
  final String drawingName;
  final String drawingIcon;
  const TrendingLineModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<TrendingLineModel> trendingLineList = [
    const TrendingLineModel(
      drawingName: 'Trend Line',
      drawingIcon: 'assets/tvchart/tradeline.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Arrow',
      drawingIcon: 'assets/tvchart/tradeline_arrow.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Ray',
      drawingIcon: 'assets/tvchart/ray.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Info Line',
      drawingIcon: 'assets/tvchart/info_line.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Extented Line',
      drawingIcon: 'assets/tvchart/extended_line.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Trend Angle',
      drawingIcon: 'assets/tvchart/trade _angle.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Horizontal Line',
      drawingIcon: 'assets/tvchart/horizontal_line.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Horizontal Ray',
      drawingIcon: 'assets/tvchart/horizontal_ray.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Vertical Line',
      drawingIcon: 'assets/tvchart/vertical_line.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Cross Line',
      drawingIcon: 'assets/tvchart/cross_line.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Parallel Channel',
      drawingIcon: 'assets/tvchart/parallel_channel.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Regression Trend',
      drawingIcon: 'assets/tvchart/regression_trend.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Flat Top/Bottom',
      drawingIcon: 'assets/tvchart/flattopbottom.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Disjoint Channel',
      drawingIcon: 'assets/tvchart/disjiont_channel.svg',
    ),
    const TrendingLineModel(
      drawingName: 'Anchored VWAP',
      drawingIcon: 'assets/tvchart/anchored_vwap.svg',
    ),
  ];
}

class TrendingLineId {
  final String drawingName;
  const TrendingLineId({
    required this.drawingName,
  });

  List<Object?> get props => [drawingName];

  static List<TrendingLineId> trendingLineIdList = [
    const TrendingLineId(drawingName: 'trend_line'),
    const TrendingLineId(drawingName: 'arrow'),
    const TrendingLineId(drawingName: 'ray'),
    const TrendingLineId(drawingName: 'trend_infoline'),
    const TrendingLineId(drawingName: 'fib_trend_ext'),
    const TrendingLineId(drawingName: 'trend_angle'),
    const TrendingLineId(drawingName: 'horizontal_line'),
    const TrendingLineId(drawingName: 'horizontal_ray'),
    const TrendingLineId(drawingName: 'vertical_line'),
    const TrendingLineId(drawingName: 'cross_line'),
    const TrendingLineId(drawingName: 'parallel_channel'),
    const TrendingLineId(drawingName: 'regression_trend'),
    const TrendingLineId(drawingName: 'flat_bottom'),
    const TrendingLineId(drawingName: 'disjoint_angle'),
    const TrendingLineId(drawingName: 'anchored_text'),
  ];
}

class FibonacciModel {
  final String drawingName;
  final String drawingIcon;
  const FibonacciModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<FibonacciModel> fibonacciList = [
    const FibonacciModel(
      drawingName: 'Fib Retracement',
      drawingIcon: 'assets/tvchart/fib_retracement.svg',
    ),
    const FibonacciModel(
      drawingName: 'Trend_Based Fib Extension',
      drawingIcon: 'assets/tvchart/trade_based_fib_extension.svg',
    ),
    const FibonacciModel(
      drawingName: 'Pitchfork',
      drawingIcon: 'assets/tvchart/pitchfork.svg',
    ),
    const FibonacciModel(
      drawingName: 'Modified Schiff Pitchfork',
      drawingIcon: 'assets/tvchart/modified_schiff_pitchfork.svg',
    ),
    const FibonacciModel(
      drawingName: 'Schiff Pitchfork',
      drawingIcon: 'assets/tvchart/schiff_pitchfork.svg',
    ),
    const FibonacciModel(
      drawingName: 'Inside Pitchfork',
      drawingIcon: 'assets/tvchart/inside_pitchfork.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Channel',
      drawingIcon: 'assets/tvchart/fib_channel.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Time Zone',
      drawingIcon: 'assets/tvchart/fib_time_zone.svg',
    ),
    const FibonacciModel(
      drawingName: 'Gann Square Fixed',
      drawingIcon: 'assets/tvchart/gann_square_fixed.svg',
    ),
    const FibonacciModel(
      drawingName: 'Gann Square',
      drawingIcon: 'assets/tvchart/gann_square.svg',
    ),
    const FibonacciModel(
      drawingName: 'Gann Box',
      drawingIcon: 'assets/tvchart/gann_box.svg',
    ),
    const FibonacciModel(
      drawingName: 'Gann Fan',
      drawingIcon: 'assets/tvchart/gann_fan.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Speed Resistance Fan',
      drawingIcon: 'assets/tvchart/fib_speen_resistance_fan.svg',
    ),
    const FibonacciModel(
      drawingName: 'Trend-Based Fib Time',
      drawingIcon: 'assets/tvchart/trend_based_fib_time.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Circles',
      drawingIcon: 'assets/tvchart/fib_circle.svg',
    ),
    const FibonacciModel(
      drawingName: 'Pitchfan',
      drawingIcon: 'assets/tvchart/pitchfan.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Spiral',
      drawingIcon: 'assets/tvchart/fib_spiral.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Speed Resistance Arcs',
      drawingIcon: 'assets/tvchart/fib_speed_resistance_arcs.svg',
    ),
    const FibonacciModel(
      drawingName: 'Fib Wedge',
      drawingIcon: 'assets/tvchart/fib_wedge.svg',
    ),
  ];
}

class FibonacciId {
  final String drawingName;
  const FibonacciId({required this.drawingName});

  List<Object?> get props => [drawingName];

  static List<FibonacciId> fibonacciIdList = [
    const FibonacciId(drawingName: 'fib_retracement'),
    const FibonacciId(drawingName: 'fib_trend_ext'),
    const FibonacciId(drawingName: 'pitchfork'),
    const FibonacciId(drawingName: 'schiff_pitchfork_modified'),
    const FibonacciId(drawingName: 'schiff_pitchfork'),
    const FibonacciId(drawingName: 'inside_pitchfork'),
    const FibonacciId(drawingName: 'fib_channel'),
    const FibonacciId(drawingName: 'fib_timezone'),
    const FibonacciId(drawingName: 'gannbox_square'),
    const FibonacciId(drawingName: 'gannbox_square'),
    const FibonacciId(drawingName: 'gannbox'),
    const FibonacciId(drawingName: 'gannbox_fan'),
    const FibonacciId(drawingName: 'fib_speed_resist_fan'),
    const FibonacciId(drawingName: 'fib_trend_time'),
    const FibonacciId(drawingName: 'fib_circles'),
    const FibonacciId(drawingName: 'pitchfan'),
    const FibonacciId(drawingName: 'fib_spiral'),
    const FibonacciId(drawingName: 'fib_speed_resist_arcs'),
    const FibonacciId(drawingName: 'fib_wedge'),
  ];
}

class GeometricModel {
  final String drawingName;
  final String drawingIcon;
  const GeometricModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<GeometricModel> geometricList = [
    const GeometricModel(
      drawingName: 'Brush',
      drawingIcon: 'assets/tvchart/brush.svg',
    ),
    const GeometricModel(
      drawingName: 'Highlighter',
      drawingIcon: 'assets/tvchart/highlighter.svg',
    ),
    const GeometricModel(
      drawingName: 'Path',
      drawingIcon: 'assets/tvchart/path.svg',
    ),
    const GeometricModel(
      drawingName: 'Rectangle',
      drawingIcon: 'assets/tvchart/rectangle.svg',
    ),
    const GeometricModel(
      drawingName: 'Circle',
      drawingIcon: 'assets/tvchart/circle.svg',
    ),
    const GeometricModel(
      drawingName: 'Rotated Rectangle',
      drawingIcon: 'assets/tvchart/rotated_rectangle.svg',
    ),
    const GeometricModel(
      drawingName: 'Ellipse',
      drawingIcon: 'assets/tvchart/ellipse.svg',
    ),
    const GeometricModel(
      drawingName: 'Triangle',
      drawingIcon: 'assets/tvchart/triangle.svg',
    ),
    const GeometricModel(
      drawingName: 'Polyline',
      drawingIcon: 'assets/tvchart/polyline.svg',
    ),
    const GeometricModel(
      drawingName: 'Curve',
      drawingIcon: 'assets/tvchart/curve.svg',
    ),
    const GeometricModel(
      drawingName: 'Double Curve',
      drawingIcon: 'assets/tvchart/double_curve.svg',
    ),
    const GeometricModel(
      drawingName: 'Arc',
      drawingIcon: 'assets/tvchart/arcs.svg',
    ),
  ];
}

class GeometricId {
  final String drawingName;
  const GeometricId({
    required this.drawingName,
  });

  List<Object?> get props => [drawingName];

  static List<GeometricId> geometricIdList = [
    const GeometricId(drawingName: 'brush'),
    const GeometricId(drawingName: 'highlighter'),
    const GeometricId(drawingName: 'path'),
    const GeometricId(drawingName: 'rectangle'),
    const GeometricId(drawingName: 'circle'),
    const GeometricId(drawingName: 'rotated_rectangle'),
    const GeometricId(drawingName: 'ellipse'),
    const GeometricId(drawingName: 'triangle'),
    const GeometricId(drawingName: 'polyline'),
    const GeometricId(drawingName: 'curve'),
    const GeometricId(drawingName: 'double_curve'),
    const GeometricId(drawingName: 'arc'),
  ];
}

class AnnotationModel {
  final String drawingName;
  final String drawingIcon;
  const AnnotationModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<AnnotationModel> annotationList = [
    const AnnotationModel(
      drawingName: 'Text',
      drawingIcon: 'assets/tvchart/text.svg',
    ),
    const AnnotationModel(
      drawingName: 'Anchored Text',
      drawingIcon: 'assets/tvchart/anchored_text.svg',
    ),
    const AnnotationModel(
      drawingName: 'Note',
      drawingIcon: 'assets/tvchart/note.svg',
    ),
    const AnnotationModel(
      drawingName: 'Anchored Note',
      drawingIcon: 'assets/tvchart/anchored_note.svg',
    ),
    const AnnotationModel(
      drawingName: 'Signpost',
      drawingIcon: 'assets/tvchart/signpost.svg',
    ),
    const AnnotationModel(
      drawingName: 'Tweet',
      drawingIcon: 'assets/tvchart/bars.svg',
    ),
    const AnnotationModel(
      drawingName: 'Idea',
      drawingIcon: 'assets/tvchart/bars.svg',
    ),
    const AnnotationModel(
      drawingName: 'Image',
      drawingIcon: 'assets/tvchart/bars.svg',
    ),
    const AnnotationModel(
      drawingName: 'Callout',
      drawingIcon: 'assets/tvchart/callout.svg',
    ),
    const AnnotationModel(
      drawingName: 'Comment',
      drawingIcon: 'assets/tvchart/comment.svg',
    ),
    const AnnotationModel(
      drawingName: 'Price Lable',
      drawingIcon: 'assets/tvchart/price_lable.svg',
    ),
    const AnnotationModel(
      drawingName: 'Price Note',
      drawingIcon: 'assets/tvchart/price_note.svg',
    ),
    const AnnotationModel(
      drawingName: 'Arrow Marker',
      drawingIcon: 'assets/tvchart/arrow_marker.svg',
    ),
    const AnnotationModel(
      drawingName: 'Arrow Marker Left',
      drawingIcon: 'assets/tvchart/arrow_mark_left.svg',
    ),
    const AnnotationModel(
      drawingName: 'Arrow Marker Right',
      drawingIcon: 'assets/tvchart/arrow_mark_right.svg',
    ),
    const AnnotationModel(
      drawingName: 'Arrow Marker Up',
      drawingIcon: 'assets/tvchart/arrow_mark_up.svg',
    ),
    const AnnotationModel(
      drawingName: 'Arrow Marker Down',
      drawingIcon: 'assets/tvchart/arrow_mark_down.svg',
    ),
    const AnnotationModel(
      drawingName: 'Flag Mark',
      drawingIcon: 'assets/tvchart/flag_mark.svg',
    ),
  ];
}

class AnnotationId {
  final String drawingName;
  const AnnotationId({
    required this.drawingName,
  });

  List<Object?> get props => [drawingName];

  static List<AnnotationId> annotationIdList = [
    const AnnotationId(drawingName: 'text'),
    const AnnotationId(drawingName: 'anchored_text'),
    const AnnotationId(drawingName: 'note'),
    const AnnotationId(drawingName: 'anchored_note'),
    //
    const AnnotationId(drawingName: 'Signpost'),
    const AnnotationId(drawingName: 'Tweet'),
    const AnnotationId(drawingName: 'Idea'),
    const AnnotationId(drawingName: 'Image'),
    //
    const AnnotationId(drawingName: 'callout'),
    const AnnotationId(drawingName: 'comment'),
    const AnnotationId(drawingName: 'price_label'),
    const AnnotationId(drawingName: 'price_note'),
    const AnnotationId(drawingName: 'arrow_marker'),
    const AnnotationId(drawingName: 'arrow_left'),
    const AnnotationId(drawingName: 'arrow_right'),
    const AnnotationId(drawingName: 'arrow_up'),
    const AnnotationId(drawingName: 'arrow_down'),
    const AnnotationId(drawingName: 'flag'),
  ];
}

class PatternModel {
  final String drawingName;
  final String drawingIcon;
  const PatternModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<PatternModel> patternList = [
    const PatternModel(
      drawingName: 'XABCD Pattern',
      drawingIcon: 'assets/tvchart/xabcd_pattern.svg',
    ),
    const PatternModel(
      drawingName: 'Cypher Pattern',
      drawingIcon: 'assets/tvchart/cypher_pattern.svg',
    ),
    const PatternModel(
      drawingName: 'ABCD Pattern',
      drawingIcon: 'assets/tvchart/abcb_pattern.svg',
    ),
    const PatternModel(
      drawingName: 'Triangle Pattern',
      drawingIcon: 'assets/tvchart/triangle_pattern.svg',
    ),
    const PatternModel(
      drawingName: 'Three Drives Pattern',
      drawingIcon: 'assets/tvchart/three_drives_pattern.svg',
    ),
    const PatternModel(
      drawingName: 'Head and Shoulders',
      drawingIcon: 'assets/tvchart/head_and_shoulders.svg',
    ),
    const PatternModel(
      drawingName: 'Elliott Impulse Wave(12345)',
      drawingIcon: 'assets/tvchart/elliott_impulse_wave_12345.svg',
    ),
    const PatternModel(
      drawingName: 'Elliott Triangle Wave(ABCDE)',
      drawingIcon: 'assets/tvchart/elliott_triangle_wave_abcde.svg',
    ),
    const PatternModel(
      drawingName: 'Elliott Triple Combo Wave(WXYXZ)',
      drawingIcon: 'assets/tvchart/ellicott_triple_combo_wave_wxyxz.svg',
    ),
    const PatternModel(
      drawingName: 'Elliott Correction Wave(ABC)',
      drawingIcon: 'assets/tvchart/ellicott_correction_wave_abc.svg',
    ),
    const PatternModel(
      drawingName: 'Elliott Double Combo Wave(WXY)',
      drawingIcon: 'assets/tvchart/ellicott_double_combo_wave_wxy.svg',
    ),
    const PatternModel(
      drawingName: 'Cyclic Lines',
      drawingIcon: 'assets/tvchart/cyclic_lines.svg',
    ),
    const PatternModel(
      drawingName: 'Time Cycles',
      drawingIcon: 'assets/tvchart/time_cycles.svg',
    ),
    const PatternModel(
      drawingName: 'Sine Line',
      drawingIcon: 'assets/tvchart/sine_line.svg',
    ),
  ];
}

class PatternId {
  final String drawingName;
  const PatternId({required this.drawingName});

  List<Object?> get props => [drawingName];

  static List<PatternId> patternIdList = [
    const PatternId(drawingName: 'xabcd_pattern'),
    const PatternId(drawingName: 'cypher_pattern'),
    const PatternId(drawingName: 'abcd_pattern'),
    const PatternId(drawingName: 'triangle_pattern'),
    const PatternId(drawingName: '3divers_pattern'),
    const PatternId(drawingName: 'head_and_shoulders'),
    const PatternId(drawingName: 'elliott_impulse_wave'),
    const PatternId(drawingName: 'elliott_triangle_wave'),
    const PatternId(drawingName: 'elliott_triple_combo'),
    const PatternId(drawingName: 'elliott_correction'),
    const PatternId(drawingName: 'elliott_double_combo'),
    const PatternId(drawingName: 'cyclic_lines'),
    const PatternId(drawingName: 'time_cycles'),
    const PatternId(drawingName: 'sine_line'),
  ];
}

class PredictionModel {
  final String drawingName;
  final String drawingIcon;
  const PredictionModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<PredictionModel> predictionModelList = [
    const PredictionModel(
      drawingName: 'Long Position',
      drawingIcon: 'assets/tvchart/long_position.svg',
    ),
    const PredictionModel(
      drawingName: 'Short Postion',
      drawingIcon: 'assets/tvchart/short_position.svg',
    ),
    const PredictionModel(
      drawingName: 'Forecast',
      drawingIcon: 'assets/tvchart/forecast.svg',
    ),
    const PredictionModel(
      drawingName: 'Date Range',
      drawingIcon: 'assets/tvchart/date_range.svg',
    ),
    const PredictionModel(
      drawingName: 'Price Range',
      drawingIcon: 'assets/tvchart/price_range.svg',
    ),
    const PredictionModel(
      drawingName: 'Date and Price Range',
      drawingIcon: 'assets/tvchart/date_and_price_range.svg',
    ),
    const PredictionModel(
      drawingName: 'Bars Pattern',
      drawingIcon: 'assets/tvchart/bars_pattern.svg',
    ),
    const PredictionModel(
      drawingName: 'Ghost Feed',
      drawingIcon: 'assets/tvchart/ghost_feed.svg',
    ),
    const PredictionModel(
      drawingName: 'Projection',
      drawingIcon: 'assets/tvchart/projection.svg',
    ),
    const PredictionModel(
      drawingName: 'Fixed Range Volume Profile',
      drawingIcon: 'assets/tvchart/fixed_range_volume_profile.svg',
    ),
  ];
}

class PredictionId {
  final String drawingName;
  const PredictionId({required this.drawingName});

  List<Object?> get props => [drawingName];

  static List<PredictionId> predictionIdList = [
    const PredictionId(drawingName: 'long_position'),
    const PredictionId(drawingName: 'short_position'),
    const PredictionId(drawingName: 'forecast'),
    const PredictionId(drawingName: 'date_range'),
    const PredictionId(drawingName: 'price_range'),
    const PredictionId(drawingName: 'date_and_price_range'),
    const PredictionId(drawingName: 'bars_pattern'),
    const PredictionId(drawingName: 'ghost_feed'),
    const PredictionId(drawingName: 'projection'),
    const PredictionId(drawingName: 'fixed_range_volume_profile'),
  ];
}

class VisualModel {
  final String drawingName;
  final String drawingIcon;
  const VisualModel({
    required this.drawingName,
    required this.drawingIcon,
  });

  List<Object?> get props => [drawingName, drawingIcon];

  static List<VisualModel> visualList = [
    const VisualModel(
      drawingName: 'Icon',
      drawingIcon: 'assets/tvchart/heart.svg',
    )
  ];
}

class VisualId {
  final String drawingName;
  const VisualId({required this.drawingName});

  List<Object?> get props => [drawingName];

  static List<VisualId> visualIdList = [const VisualId(drawingName: 'icon')];
}

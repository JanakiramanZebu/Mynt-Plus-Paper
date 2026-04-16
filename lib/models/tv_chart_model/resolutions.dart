import 'package:flutter/material.dart';

class ResolutionModel {
  final String chartType;
  final IconData chartIcon;
  const ResolutionModel({
    required this.chartType,
    required this.chartIcon,
  });

  List<Object?> get props => [chartType, chartIcon];

  static List<ResolutionModel> categories = [
    const ResolutionModel(
      chartType: 'Bars',
      chartIcon: Icons.bar_chart_outlined,
    ),
    const ResolutionModel(
      chartType: 'Candles',
      chartIcon: Icons.candlestick_chart_outlined,
    ),
    const ResolutionModel(
      chartType: 'Hollow Candles',
      chartIcon: Icons.candlestick_chart,
    ),
    const ResolutionModel(
      chartType: 'Columns',
      chartIcon: Icons.equalizer,
    ),
    const ResolutionModel(
      chartType: 'Line',
      chartIcon: Icons.line_axis_outlined,
    ),
    const ResolutionModel(
      chartType: 'Line with markers',
      chartIcon: Icons.linear_scale,
    ),
    const ResolutionModel(
      chartType: 'Stepline',
      chartIcon: Icons.scatter_plot,
    ),
    const ResolutionModel(
      chartType: 'Area',
      chartIcon: Icons.area_chart_outlined,
    ),
    const ResolutionModel(
      chartType: 'Baseline',
      chartIcon: Icons.line_axis,
    ),
    const ResolutionModel(
      chartType: 'High-Low',
      chartIcon: Icons.highlight,
    ),
    const ResolutionModel(
      chartType: 'Heikin Ashi',
      chartIcon: Icons.abc,
    ),
    const ResolutionModel(
      chartType: 'Renko',
      chartIcon: Icons.scatter_plot,
    ),
    const ResolutionModel(
      chartType: 'Line Break',
      chartIcon: Icons.candlestick_chart,
    ),
    const ResolutionModel(
      chartType: 'Kagi',
      chartIcon: Icons.mosque_rounded,
    ),
    const ResolutionModel(
      chartType: 'Range',
      chartIcon: Icons.date_range,
    ),
    const ResolutionModel(
      chartType: 'Point & Figure',
      chartIcon: Icons.grid_4x4,
    ),
  ];
}

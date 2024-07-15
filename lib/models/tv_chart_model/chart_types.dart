class ChartTypeModel {
  final String chartType;
  final String chartIcon;
  const ChartTypeModel({
    required this.chartType,
    required this.chartIcon,
  });

  List<Object?> get props => [chartType, chartIcon];

  static List<ChartTypeModel> categories = [
    const ChartTypeModel(
      chartType: 'Bars',
      chartIcon: 'assets/tvchart/bars.svg',
    ),
    const ChartTypeModel(
      chartType: 'Candle',
      chartIcon: 'assets/tvchart/candle.svg',
    ),
    const ChartTypeModel(
      chartType: 'Line',
      chartIcon: 'assets/tvchart/line.svg',
    ),
    const ChartTypeModel(
      chartType: 'Area',
      chartIcon: 'assets/tvchart/area.svg',
    ),
    const ChartTypeModel(
      chartType: 'Renko',
      chartIcon: 'assets/tvchart/renko.svg',
    ),
    const ChartTypeModel(
      chartType: 'Kagi',
      chartIcon: 'assets/tvchart/kagi.svg',
    ),
    const ChartTypeModel(
      chartType: 'PnF',
      chartIcon: 'assets/tvchart/point_figure.svg',
    ),
    const ChartTypeModel(
      chartType: 'Line Break',
      chartIcon: 'assets/tvchart/line_break.svg',
    ),
    const ChartTypeModel(
      chartType: 'Heikin-Ashi',
      chartIcon: 'assets/tvchart/heikin_ashi.svg',
    ),
    const ChartTypeModel(
      chartType: 'Hollow Candle',
      chartIcon: 'assets/tvchart/hollow_candle.svg',
    ),
    const ChartTypeModel(
      chartType: 'Base Line',
      chartIcon: 'assets/tvchart/baseline.svg',
    ),
    const ChartTypeModel(
      chartType: 'Hi-Lo',
      chartIcon: 'assets/tvchart/high_low.svg',
    ),
    const ChartTypeModel(
      chartType: 'Column',
      chartIcon: 'assets/tvchart/column.svg',
    ),
  ];
}

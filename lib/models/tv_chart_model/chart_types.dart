class ChartTypeModel {
  final String chartType;
  final String chartIcon;
  final String chartValue;
  const ChartTypeModel({
    required this.chartType,
    required this.chartIcon,
    required this.chartValue,
  });

  List<Object?> get props => [chartType, chartIcon, chartValue];

  static List<ChartTypeModel> categories = [
    const ChartTypeModel(
        chartType: 'Bars',
        chartIcon: 'assets/tvchart/bars.svg',
        chartValue: '0'),
    const ChartTypeModel(
        chartType: 'Candles',
        chartIcon: 'assets/tvchart/candle.svg',
        chartValue: '1'),
    const ChartTypeModel(
        chartType: 'Hollow candles',
        chartIcon: 'assets/tvchart/hollow_candle.svg',
        chartValue: '9'),
    const ChartTypeModel(
        chartType: 'Line',
        chartIcon: 'assets/tvchart/line_chart.svg',
        chartValue: '2'),
    const ChartTypeModel(
        chartType: 'Area',
        chartIcon: 'assets/tvchart/area.svg',
        chartValue: '3'),
    const ChartTypeModel(
        chartType: 'Line with markers',
        chartIcon: 'assets/tvchart/line_marker_chart.svg',
        chartValue: '14'),
    const ChartTypeModel(
        chartType: 'Step line',
        chartIcon: 'assets/tvchart/kagi.svg',
        chartValue: '15'),
    const ChartTypeModel(
        chartType: 'HLC area',
        chartIcon: 'assets/tvchart/hlc_area_chart.svg',
        chartValue: '16'),
    const ChartTypeModel(
        chartType: 'Baseline',
        chartIcon: 'assets/tvchart/base_line_chart.svg',
        chartValue: '10'),
    const ChartTypeModel(
        chartType: 'Columns',
        chartIcon: 'assets/tvchart/column_chart.svg',
        chartValue: '13'),
    const ChartTypeModel(
        chartType: 'High-Low',
        chartIcon: 'assets/tvchart/high_low.svg',
        chartValue: '12'),
    const ChartTypeModel(
        chartType: 'Heikin Ashi',
        chartIcon: 'assets/tvchart/heikin_ashi_chart.svg',
        chartValue: '8')
  ];
}

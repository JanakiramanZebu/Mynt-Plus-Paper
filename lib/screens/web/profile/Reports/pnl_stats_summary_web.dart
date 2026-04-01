import 'dart:math' show pow;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/desk_reports_model/calender_pnl_model.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/no_data_found.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void showPnlStatsSummaryDialog(
  BuildContext context, {
  required CalenderpnlModel data,
  required String segment,
}) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 820),
        child: _PnlStatsSummaryContent(data: data, segment: segment),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog content
// ─────────────────────────────────────────────────────────────────────────────

class _PnlStatsSummaryContent extends StatefulWidget {
  final CalenderpnlModel data;
  final String segment;

  const _PnlStatsSummaryContent({required this.data, required this.segment});

  @override
  State<_PnlStatsSummaryContent> createState() =>
      _PnlStatsSummaryContentState();
}

class _PnlStatsSummaryContentState extends State<_PnlStatsSummaryContent> {
  Map<String, dynamic> get _summaryMap {
    final d = widget.data;
    if (d.summary != null && d.summary!.isNotEmpty) {
      return d.summary!.cast<String, dynamic>();
    }
    if (d.stat != null && d.stat!.isNotEmpty) {
      return d.stat!.cast<String, dynamic>();
    }
    return {};
  }

  List<_DailyPnl> get _dailyPnlList {
    final list = <_DailyPnl>[];
    if (widget.data.journal != null) {
      for (final j in widget.data.journal!) {
        DateTime? date;
        try {
          date = DateTime.parse(j.tRADEDATE ?? '');
        } catch (_) {}
        final pnl = double.tryParse(j.realisedpnl ?? '0') ?? 0;
        if (date != null) list.add(_DailyPnl(date: date, pnl: pnl));
      }
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<_DailyPnl> _cumulative(List<_DailyPnl> src) {
    final out = <_DailyPnl>[];
    double cum = 0;
    for (final d in src) {
      cum += d.pnl;
      out.add(_DailyPnl(date: d.date, pnl: cum));
    }
    return out;
  }

  List<_DailyPnl> _drawdown(List<_DailyPnl> src) {
    final out = <_DailyPnl>[];
    double peak = 0, cum = 0;
    for (final d in src) {
      cum += d.pnl;
      if (cum > peak) peak = cum;
      out.add(_DailyPnl(date: d.date, pnl: cum - peak));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summaryMap;
    final daily = _dailyPnlList;
    final cum = _cumulative(daily);
    final dd = _drawdown(daily);

    final cumColor = cum.isEmpty || cum.last.pnl >= 0
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
    final ddColor = resolveThemeColor(context,
        dark: MyntColors.lossDark, light: MyntColors.loss);
    final bgColor = resolveThemeColor(context,
        dark: MyntColors.cardDark, light: MyntColors.card);
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.cardBorderDark, light: MyntColors.cardBorder);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "P&L Summary — ${widget.segment}",
                  style: MyntWebTextStyles.title(
                    context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                    fontWeight: MyntFonts.semiBold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: (summary.isEmpty && daily.isEmpty) ?
                    Center(
                        child: NoDataFound(secondaryEnabled: false)) : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildStatsSection(context, summary),
                  ],
                  if (daily.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _card(context,
                        title: "Daily P&L",
                        child: _WebBarChart(data: daily)),
                    const SizedBox(height: 16),
                    _card(context,
                        title: "Cumulative P&L",
                        child: _WebLineChart(
                            data: cum, lineColor: cumColor)),
                    const SizedBox(height: 16),
                    _card(context,
                        title: "Drawdown",
                        child: _WebLineChart(
                            data: dd,
                            lineColor: ddColor,
                            isDrawdown: true)),
                    const SizedBox(height: 8),
                  ],
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.cardBorderDark,
              light: MyntColors.cardBorder),
        ),
        color: resolveThemeColor(context,
            dark: MyntColors.cardDark, light: MyntColors.card),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MyntWebTextStyles.body(context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.semiBold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ─── Statistics section ──────────────────────────────────────────────────

  Widget _buildStatsSection(
      BuildContext context, Map<String, dynamic> s) {
    final winRate = s['Win Rate'] is num
        ? '${(s['Win Rate'] * 100).toStringAsFixed(1)}%'
        : '${s['Win Rate'] ?? 'N/A'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: resolveThemeColor(context,
              dark: MyntColors.cardBorderDark,
              light: MyntColors.cardBorder),
        ),
        color: resolveThemeColor(context,
            dark: MyntColors.cardDark, light: MyntColors.card),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statistics",
            style: MyntWebTextStyles.body(context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.semiBold),
          ),
          const SizedBox(height: 16),
          _secHead(context, "Overview"),
          const SizedBox(height: 12),
          _row3(
              context,
              "TRADING DAYS", '${s['Trading Days'] ?? 'N/A'}',
              "WIN DAYS",     '${s['Win Days'] ?? 'N/A'}',
              "LOSS DAYS",    '${s['Loss Days'] ?? 'N/A'}'),
          const SizedBox(height: 14),
          _row3(
              context,
              "WIN RATE",    winRate,
              "WIN STREAK",  '${s['Winning Streak Days'] ?? 'N/A'} days',
              "LOSS STREAK", '${s['Losing Streak Days'] ?? 'N/A'} days'),
          const SizedBox(height: 20),
          _secHead(context, "P&L Metrics"),
          const SizedBox(height: 12),
          _row3(
              context,
              "MAX PROFIT/DAY", _fmt(s['Maximum Profit in a Day']),
              "MAX LOSS/DAY",   _fmt(s['Maximum Loss in a Day']),
              "AVG DAILY P&L",  _fmt(s['Average Profit/Loss Daily'])),
          const SizedBox(height: 14),
          _row3(
              context,
              "AVG PROFIT",   _fmt(s['Average Profit on Profit Days']),
              "AVG LOSS",     _fmt(s['Average Loss on Loss Days']),
              "MAX DRAWDOWN", _fmt(s['Maximum Drawdown'])),
        ],
      ),
    );
  }

  Widget _secHead(BuildContext context, String t) => Text(
        t,
        style: MyntWebTextStyles.bodySmall(context,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
            fontWeight: MyntFonts.semiBold),
      );

  Widget _row3(BuildContext context, String t1, String v1, String t2,
          String v2, String t3, String v3) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _cell(context, t1, v1)),
          if (t2.isNotEmpty) ...[
            const SizedBox(width: 18),
            Expanded(child: _cell(context, t2, v2))
          ],
          if (t3.isNotEmpty) ...[
            const SizedBox(width: 18),
            Expanded(child: _cell(context, t3, v3))
          ],
        ],
      );

  Widget _cell(BuildContext context, String label, String value) {
    final neg = value.startsWith('-');
    final numVal = double.tryParse(value.replaceAll('₹', '').trim());
    final isProfit =
        !neg && numVal != null && numVal > 0 && value.contains('.');
    Color? col;
    if (neg) {
      col = resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (isProfit) {
      col = resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MyntWebTextStyles.caption(context,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: MyntWebTextStyles.body(context,
              darkColor: col ?? MyntColors.textPrimaryDark,
              lightColor: col ?? MyntColors.textPrimary,
              fontWeight: MyntFonts.semiBold),
        ),
        const SizedBox(height: 2),
        Divider(
          color: resolveThemeColor(context,
              dark: MyntColors.dividerDark, light: MyntColors.divider),
        ),
      ],
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return 'N/A';
    final n = double.tryParse(v.toString()) ?? 0;
    return n.toStringAsFixed(2);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart filter
// ─────────────────────────────────────────────────────────────────────────────

enum _ChartFilter { month, threeMonths, all }

extension _ChartFilterX on _ChartFilter {
  String get label => switch (this) {
        _ChartFilter.month => '1M',
        _ChartFilter.threeMonths => '3M',
        _ChartFilter.all => 'All',
      };
}

List<_DailyPnl> _applyFilter(List<_DailyPnl> data, _ChartFilter f) {
  if (f == _ChartFilter.all || data.isEmpty) return data;
  final cutoff = data.last.date
      .subtract(Duration(days: f == _ChartFilter.month ? 30 : 90));
  final filtered = data.where((d) => !d.date.isBefore(cutoff)).toList();
  return filtered.isEmpty ? data : filtered;
}

// ─────────────────────────────────────────────────────────────────────────────
// Web Line Chart
// ─────────────────────────────────────────────────────────────────────────────

class _WebLineChart extends StatefulWidget {
  final List<_DailyPnl> data;
  final Color lineColor;
  final bool isDrawdown;

  const _WebLineChart({
    required this.data,
    required this.lineColor,
    this.isDrawdown = false,
  });

  @override
  State<_WebLineChart> createState() => _WebLineChartState();
}

class _WebLineChartState extends State<_WebLineChart> {
  _ChartFilter _filter = _ChartFilter.threeMonths;
  late List<_DailyPnl> _filteredData;

  void _setFilter(_ChartFilter f) {
    final d = _applyFilter(widget.data, f);
    setState(() {
      _filter = f;
      _filteredData = d;
      _minX = 0;
      _maxX = (d.length - 1).toDouble().clamp(0, double.infinity);
    });
  }

  double _computedMinY(List<_DailyPnl> d) {
    if (d.isEmpty) return -1;
    final mn = d.fold<double>(0, (m, e) => e.pnl < m ? e.pnl : m);
    return widget.isDrawdown ? mn * 1.15 : mn;
  }

  double _computedMaxY(List<_DailyPnl> d) {
    if (d.isEmpty) return 1;
    if (widget.isDrawdown) {
      final mn = d.fold<double>(0, (m, e) => e.pnl < m ? e.pnl : m);
      return (-mn) * 0.15;
    }
    final mx = d.fold<double>(0, (m, e) => e.pnl > m ? e.pnl : m);
    final mn = d.fold<double>(0, (m, e) => e.pnl < m ? e.pnl : m);
    return mx + (mx - mn).abs() * 0.1;
  }

  late double _minX;
  late double _maxX;
  int? _crosshairIdx;

  double _panDragStartX = 0;
  double _panDragStartMinX = 0;
  double _panStartRange = 0;

  double _zoomDragStartX = 0;
  double _zoomStartRange = 0;
  double _zoomStartFocal = 0;
  double _zoomStartFocalRatio = 0;

  @override
  void initState() {
    super.initState();
    _filteredData = _applyFilter(widget.data, _filter);
    _minX = 0;
    _maxX = (_filteredData.length - 1).toDouble();
  }

  double get _range => (_maxX - _minX).clamp(1, double.infinity);

  void _onPanStart(DragStartDetails details) {
    if (_filter != _ChartFilter.all) {
      final offset = widget.data.length - _filteredData.length;
      setState(() {
        _minX = (_minX + offset)
            .clamp(0.0, (widget.data.length - 1).toDouble());
        _maxX = (_maxX + offset)
            .clamp(0.0, (widget.data.length - 1).toDouble());
        _filter = _ChartFilter.all;
        _filteredData = widget.data;
      });
    }
    _panDragStartX = details.localPosition.dx;
    _panDragStartMinX = _minX;
    _panStartRange = _range;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final w = box.size.width;
    final maxIdx = (_filteredData.length - 1).toDouble();
    final totalDx = details.localPosition.dx - _panDragStartX;
    final dataDelta = (totalDx / w) * _panStartRange;
    final newMin = (_panDragStartMinX - dataDelta)
        .clamp(0.0, maxIdx - _panStartRange);
    setState(() {
      _minX = newMin;
      _maxX = newMin + _panStartRange;
    });
  }

  void _onZoomStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    _zoomDragStartX = details.localPosition.dx;
    _zoomStartRange = _range;
    _zoomStartFocalRatio = box != null
        ? (details.localPosition.dx / box.size.width).clamp(0.0, 1.0)
        : 0.5;
    _zoomStartFocal = _minX + _zoomStartFocalRatio * _range;
  }

  void _onZoomUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final w = box.size.width;
    final maxIdx = (_filteredData.length - 1).toDouble();
    final totalDx = details.localPosition.dx - _zoomDragStartX;
    final factor = pow(2.0, totalDx / (w * 0.5)).toDouble();
    final newRange = (_zoomStartRange * factor).clamp(2.0, maxIdx);
    var newMin = _zoomStartFocal - _zoomStartFocalRatio * newRange;
    var newMax = newMin + newRange;
    if (newMin < 0) {
      newMin = 0;
      newMax = newRange;
    }
    if (newMax > maxIdx) {
      newMax = maxIdx;
      newMin = maxIdx - newRange;
    }
    setState(() {
      _minX = newMin.clamp(0, maxIdx);
      _maxX = newMax.clamp(0, maxIdx);
    });
  }

  int _localToIdx(double dx) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    final ratio = (dx / box.size.width).clamp(0.0, 1.0);
    return (_minX + ratio * _range)
        .round()
        .clamp(0, _filteredData.length - 1);
  }

  void _onHover(PointerHoverEvent event) {
    if (event.localPosition.dy > 172) return;
    final idx = _localToIdx(event.localPosition.dx);
    if (_crosshairIdx != idx) setState(() => _crosshairIdx = idx);
  }

  Widget _filterRow(BuildContext context) {
    final profitColor = resolveThemeColor(context,
        dark: MyntColors.profitDark, light: MyntColors.profit);
    final borderCol = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);
    return Row(
      children: _ChartFilter.values.map((f) {
        final active = _filter == f;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _setFilter(f),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: active
                    ? profitColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: active
                      ? profitColor
                      : borderCol.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                f.label,
                style: MyntWebTextStyles.caption(context,
                    color: active
                        ? profitColor
                        : borderCol.withValues(alpha: 0.7),
                    fontWeight: active
                        ? MyntFonts.semiBold
                        : MyntFonts.regular),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox();
    final data = _filteredData;
    final minY = _computedMinY(data);
    final maxY = _computedMaxY(data);
    final item = _crosshairIdx != null ? data[_crosshairIdx!] : null;
    final secCol = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _filterRow(context),
        const SizedBox(height: 8),
        SizedBox(
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _minX > 0 || _maxX < data.length - 1
                    ? 'Drag to pan  •  drag dates to zoom'
                    : 'Drag dates to zoom',
                style: MyntWebTextStyles.caption(context,
                    color: secCol.withValues(
                        alpha: _minX > 0 || _maxX < data.length - 1
                            ? 1.0
                            : 0.5)),
              ),
              if (item != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: secCol.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: secCol.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd MMM yy').format(item.date),
                        style: MyntWebTextStyles.caption(context,
                            color: secCol),
                      ),
                      const SizedBox(width: 10),
                      Container(
                          width: 1,
                          height: 12,
                          color: secCol.withValues(alpha: 0.3)),
                      const SizedBox(width: 10),
                      Text(
                        item.pnl.toStringAsFixed(2),
                        style: MyntWebTextStyles.caption(context,
                            color: item.pnl >= 0
                                ? resolveThemeColor(context,
                                    dark: MyntColors.profitDark,
                                    light: MyntColors.profit)
                                : resolveThemeColor(context,
                                    dark: MyntColors.lossDark,
                                    light: MyntColors.loss)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Chart + gesture overlays
        MouseRegion(
          onHover: _onHover,
          onExit: (_) {
            if (_crosshairIdx != null) {
              setState(() => _crosshairIdx = null);
            }
          },
          child: Stack(
            children: [
              ClipRect(
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: LineChart(
                    duration: Duration.zero,
                    LineChartData(
                      minX: _minX,
                      maxX: _maxX,
                      minY: minY,
                      maxY: maxY,
                      lineTouchData:
                          const LineTouchData(enabled: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval:
                                (_range / 5).clamp(1, double.infinity),
                            getTitlesWidget: (value, meta) {
                              final idx = value
                                  .round()
                                  .clamp(0, data.length - 1);
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 6),
                                child: Text(
                                  DateFormat('dd/MM')
                                      .format(data[idx].date),
                                  style: MyntWebTextStyles.caption(
                                      context,
                                      color: secCol),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      extraLinesData: ExtraLinesData(
                        verticalLines: _crosshairIdx != null
                            ? [
                                VerticalLine(
                                  x: _crosshairIdx!.toDouble(),
                                  color: Colors.grey[500]!,
                                  strokeWidth: 1,
                                  dashArray: [4, 4],
                                ),
                              ]
                            : [],
                        horizontalLines: [
                          HorizontalLine(
                            y: 0,
                            color: isDarkMode(context)
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ],
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(data.length,
                              (i) => FlSpot(i.toDouble(), data[i].pnl)),
                          isCurved: true,
                          curveSmoothness: 0.2,
                          color: widget.lineColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) {
                              final isTouched =
                                  _crosshairIdx == spot.x.toInt();
                              return FlDotCirclePainter(
                                radius: isTouched ? 4 : 0,
                                color: widget.lineColor,
                                strokeWidth: isTouched ? 2 : 0,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                              show: true,
                              color: widget.lineColor
                                  .withValues(alpha: 0.08)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Pan overlay — top 172px (chart plot area)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 172,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: _onPanStart,
                  onHorizontalDragUpdate: _onPanUpdate,
                ),
              ),
              // Zoom overlay — bottom 28px (date axis area)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 28,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: _onZoomStart,
                  onHorizontalDragUpdate: _onZoomUpdate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Web Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _WebBarChart extends StatefulWidget {
  final List<_DailyPnl> data;

  const _WebBarChart({required this.data});

  @override
  State<_WebBarChart> createState() => _WebBarChartState();
}

class _WebBarChartState extends State<_WebBarChart> {
  late int _startIdx;
  late int _endIdx;
  int? _crosshairIdx;

  _ChartFilter _filter = _ChartFilter.threeMonths;
  late List<_DailyPnl> _filteredData;

  void _setFilter(_ChartFilter f) {
    final d = _applyFilter(widget.data, f);
    setState(() {
      _filter = f;
      _filteredData = d;
      _startIdx = 0;
      _endIdx = d.length - 1;
    });
  }

  double _panDragStartX = 0;
  int _panDragStartIdx = 0;
  int _panStartVisibleCount = 0;

  double _zoomDragStartX = 0;
  double _zoomStartRange = 0;
  double _zoomStartFocalRatio = 0;
  int _zoomStartFocalAbs = 0;

  @override
  void initState() {
    super.initState();
    _filteredData = _applyFilter(widget.data, _filter);
    _startIdx = 0;
    _endIdx = _filteredData.length - 1;
  }

  int get _visibleCount =>
      (_endIdx - _startIdx + 1).clamp(1, _filteredData.length);

  void _onPanStart(DragStartDetails details) {
    if (_filter != _ChartFilter.all) {
      final offset = widget.data.length - _filteredData.length;
      setState(() {
        _startIdx =
            (_startIdx + offset).clamp(0, widget.data.length - 1);
        _endIdx = (_endIdx + offset).clamp(0, widget.data.length - 1);
        _filter = _ChartFilter.all;
        _filteredData = widget.data;
      });
    }
    _panDragStartX = details.localPosition.dx;
    _panDragStartIdx = _startIdx;
    _panStartVisibleCount = _visibleCount;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final total = _filteredData.length;
    final totalDx = details.localPosition.dx - _panDragStartX;
    final barDelta = (totalDx / box.size.width) * _panStartVisibleCount;
    final s = (_panDragStartIdx - barDelta)
        .round()
        .clamp(0, total - _panStartVisibleCount);
    setState(() {
      _startIdx = s;
      _endIdx = s + _panStartVisibleCount - 1;
    });
  }

  void _onZoomStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    _zoomDragStartX = details.localPosition.dx;
    _zoomStartRange = _visibleCount.toDouble();
    _zoomStartFocalRatio = box != null
        ? (details.localPosition.dx / box.size.width).clamp(0.0, 1.0)
        : 0.5;
    _zoomStartFocalAbs =
        (_startIdx + _zoomStartFocalRatio * (_endIdx - _startIdx))
            .round()
            .clamp(0, _filteredData.length - 1);
  }

  void _onZoomUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final total = _filteredData.length;
    final totalDx = details.localPosition.dx - _zoomDragStartX;
    final factor =
        pow(2.0, totalDx / (box.size.width * 0.5)).toDouble();
    final newRange =
        (_zoomStartRange * factor).clamp(2.0, total.toDouble()).round();
    var s =
        (_zoomStartFocalAbs - _zoomStartFocalRatio * newRange).round();
    var e = s + newRange - 1;
    if (s < 0) {
      s = 0;
      e = newRange - 1;
    }
    if (e >= total) {
      e = total - 1;
      s = e - newRange + 1;
    }
    setState(() {
      _startIdx = s.clamp(0, total - 1);
      _endIdx = e.clamp(0, total - 1);
    });
  }

  int _localToGlobalIdx(double dx) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return _startIdx;
    final ratio = (dx / box.size.width).clamp(0.0, 1.0);
    return (_startIdx + ratio * (_endIdx - _startIdx))
        .round()
        .clamp(0, _filteredData.length - 1);
  }

  void _onHover(PointerHoverEvent event) {
    if (event.localPosition.dy > 172) return;
    final idx = _localToGlobalIdx(event.localPosition.dx);
    if (_crosshairIdx != idx) setState(() => _crosshairIdx = idx);
  }

  Widget _filterRow(BuildContext context) {
    final profitColor = resolveThemeColor(context,
        dark: MyntColors.profitDark, light: MyntColors.profit);
    final borderCol = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);
    return Row(
      children: _ChartFilter.values.map((f) {
        final active = _filter == f;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _setFilter(f),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: active
                    ? profitColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: active
                      ? profitColor
                      : borderCol.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                f.label,
                style: MyntWebTextStyles.caption(context,
                    color: active
                        ? profitColor
                        : borderCol.withValues(alpha: 0.7),
                    fontWeight: active
                        ? MyntFonts.semiBold
                        : MyntFonts.regular),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox();
    final data = _filteredData;
    final visible = data.sublist(_startIdx, _endIdx + 1);
    final maxVal = visible.fold<double>(
        0, (m, e) => e.pnl.abs() > m ? e.pnl.abs() : m);
    final item = _crosshairIdx != null ? data[_crosshairIdx!] : null;
    final localCrosshair =
        _crosshairIdx != null ? _crosshairIdx! - _startIdx : null;
    final secCol = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _filterRow(context),
        const SizedBox(height: 8),
        SizedBox(
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _visibleCount < data.length
                    ? 'Drag to pan  •  drag dates to zoom'
                    : 'Drag dates to zoom',
                style: MyntWebTextStyles.caption(context,
                    color: secCol.withValues(
                        alpha: _visibleCount < data.length ? 1.0 : 0.5)),
              ),
              if (item != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: secCol.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: secCol.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd MMM yy').format(item.date),
                        style: MyntWebTextStyles.caption(context,
                            color: secCol),
                      ),
                      const SizedBox(width: 10),
                      Container(
                          width: 1,
                          height: 12,
                          color: secCol.withValues(alpha: 0.3)),
                      const SizedBox(width: 10),
                      Text(
                        item.pnl.toStringAsFixed(2),
                        style: MyntWebTextStyles.caption(context,
                            color: item.pnl >= 0
                                ? resolveThemeColor(context,
                                    dark: MyntColors.profitDark,
                                    light: MyntColors.profit)
                                : resolveThemeColor(context,
                                    dark: MyntColors.lossDark,
                                    light: MyntColors.loss)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          onHover: _onHover,
          onExit: (_) {
            if (_crosshairIdx != null) {
              setState(() => _crosshairIdx = null);
            }
          },
          child: Stack(
            children: [
              SizedBox(
                height: 200,
                child: BarChart(
                  duration: Duration.zero,
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.2,
                    minY: -maxVal * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= visible.length) {
                              return const SizedBox();
                            }
                            final step = (visible.length / 5)
                                .ceil()
                                .clamp(1, visible.length);
                            if (idx % step != 0 &&
                                idx != visible.length - 1) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat('dd/MM')
                                    .format(visible[idx].date),
                                style: MyntWebTextStyles.caption(
                                    context,
                                    color: secCol),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(visible.length, (i) {
                      final pnl = visible[i].pnl;
                      final isTouched = localCrosshair == i;
                      final barColor = pnl >= 0
                          ? resolveThemeColor(context,
                              dark: MyntColors.profitDark,
                              light: MyntColors.profit)
                          : resolveThemeColor(context,
                              dark: MyntColors.lossDark,
                              light: MyntColors.loss);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: pnl,
                            color: barColor.withValues(
                                alpha: isTouched ? 1.0 : 0.85),
                            width: (240 / visible.length)
                                .clamp(3.0, 20.0),
                            borderRadius: pnl >= 0
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    topRight: Radius.circular(2))
                                : const BorderRadius.only(
                                    bottomLeft: Radius.circular(2),
                                    bottomRight: Radius.circular(2)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: isTouched,
                              toY: maxVal * 1.2,
                              fromY: -maxVal * 1.2,
                              color: (isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black)
                                  .withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              // Pan overlay — top 172px
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 172,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: _onPanStart,
                  onHorizontalDragUpdate: _onPanUpdate,
                ),
              ),
              // Zoom overlay — bottom 28px (date axis area)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 28,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: _onZoomStart,
                  onHorizontalDragUpdate: _onZoomUpdate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class _DailyPnl {
  final DateTime date;
  final double pnl;
  _DailyPnl({required this.date, required this.pnl});
}

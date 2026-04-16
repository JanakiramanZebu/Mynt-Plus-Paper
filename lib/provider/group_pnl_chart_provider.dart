import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../models/marketwatch_model/tpseries.dart';
import '../models/order_book_model/trade_book_model.dart';
import '../models/portfolio_model/group_pnl_chart_model.dart';

final groupPnlChartProvider =
    ChangeNotifierProvider((ref) => GroupPnlChartProvider());

class GroupPnlChartProvider extends ChangeNotifier {
  final _api = locator<ApiExporter>();

  // --------------- State ---------------

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String _interval = '5';
  String get interval => _interval;

  String? _activeGroupName;
  String? get activeGroupName => _activeGroupName;

  List<GroupPnlDataPoint> _dataPoints = [];
  List<GroupPnlDataPoint> get dataPoints => _dataPoints;

  List<Map<String, dynamic>> _positions = [];

  // --------------- Cache ---------------

  final Map<String, Map<String, List<Data>>> _tpCache = {};
  final Map<String, List<GroupPnlDataPoint>> _resultCache = {};
  final Map<String, _PositionTimeline> _timelineMap = {};
  bool _tradeBookFetched = false;

  // --------------- Public API ---------------

  Future<void> loadGroupChart({
    required String groupName,
    required List groupList,
    required bool isDay,
    required bool isNetPnl,
    String interval = '5',
  }) async {
    final groupChanged = _activeGroupName != groupName;
    _activeGroupName = groupName;
    _interval = interval;
    _positions = groupList
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // Only clear caches when group changes
    if (groupChanged) {
      _resultCache.clear();
      _tpCache.clear();
      _timelineMap.clear();
      _tradeBookFetched = false;
    }

    final cacheKey = _resultCacheKey(groupName, interval, isDay, isNetPnl);
    if (_resultCache.containsKey(cacheKey)) {
      _dataPoints = _resultCache[cacheKey]!;
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchTradeInfo();
      await _fetchMissingTpData(interval);
      _dataPoints = _computeGroupPnl(isDay: isDay, isNetPnl: isNetPnl);
      _resultCache[cacheKey] = _dataPoints;
    } catch (e) {
      _error = 'Failed to load chart data';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> switchInterval({
    required String newInterval,
    required bool isDay,
    required bool isNetPnl,
  }) async {
    if (newInterval == _interval) return;
    _interval = newInterval;

    final cacheKey =
        _resultCacheKey(_activeGroupName!, newInterval, isDay, isNetPnl);
    if (_resultCache.containsKey(cacheKey)) {
      _dataPoints = _resultCache[cacheKey]!;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      await _fetchMissingTpData(newInterval);
      _dataPoints = _computeGroupPnl(isDay: isDay, isNetPnl: isNetPnl);
      _resultCache[cacheKey] = _dataPoints;
    } catch (e) {
      _error = 'Failed to load chart data';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// WebSocket LTP update — updates the last data point for all matching positions.
  void onTickUpdate({
    required String token,
    required String ltp,
    required bool isDay,
    required bool isNetPnl,
  }) {
    if (_activeGroupName == null || _dataPoints.isEmpty) return;

    // Update ALL positions with this token (NRML + MIS share the same token)
    bool updated = false;
    for (var pos in _positions) {
      if (pos['token']?.toString() != token) continue;

      final oldLp = double.tryParse(pos['lp']?.toString() ?? '0') ?? 0.0;
      final newLp = double.tryParse(ltp) ?? 0.0;
      if (oldLp == newLp) continue;

      final netQty =
          (int.tryParse(pos['netqty']?.toString() ?? '0') ?? 0).toDouble();
      final prcFtr =
          double.tryParse(pos['prcftr']?.toString() ?? '1.0') ?? 1.0;
      final mult =
          double.tryParse(pos['mult']?.toString() ?? '1.0') ?? 1.0;
      final pnlDelta = netQty * prcFtr * mult * (newLp - oldLp);

      pos['lp'] = ltp;
      final oldPnl =
          double.tryParse(pos['profitNloss']?.toString() ?? '0') ?? 0.0;
      final oldMtm =
          double.tryParse(pos['mTm']?.toString() ?? '0') ?? 0.0;
      pos['profitNloss'] = (oldPnl + pnlDelta).toStringAsFixed(2);
      pos['mTm'] = (oldMtm + pnlDelta).toStringAsFixed(2);
      updated = true;
    }
    if (!updated) return;

    final now = DateTime.now();
    double groupPnl = 0.0;
    for (var pos in _positions) {
      final field = isNetPnl ? 'profitNloss' : 'mTm';
      groupPnl += double.tryParse(pos[field]?.toString() ?? '0') ?? 0.0;
    }

    final previousPeak = _dataPoints.last.peak;
    final peak = max(previousPeak, groupPnl);
    final drawdown = groupPnl - peak;

    _dataPoints[_dataPoints.length - 1] = GroupPnlDataPoint(
      time: now,
      pnl: groupPnl,
      drawdown: drawdown,
      peak: peak,
    );

    _resultCache.removeWhere((key, _) => key.startsWith('$_activeGroupName|'));
    notifyListeners();
  }

  void clearCache() {
    _tpCache.clear();
    _resultCache.clear();
    _timelineMap.clear();
    _tradeBookFetched = false;
    _dataPoints = [];
    _activeGroupName = null;
    _positions = [];
  }

  // --------------- Internals ---------------

  String _resultCacheKey(
          String group, String interval, bool isDay, bool isNetPnl) =>
      '$group|$interval|$isDay|$isNetPnl';

  Future<void> _fetchTradeInfo() async {
    if (_tradeBookFetched) return;

    final now = DateTime.now();
    final marketOpenEpoch =
        DateTime(now.year, now.month, now.day, 9, 15).millisecondsSinceEpoch ~/
            1000;

    final posKeys = <String>{};
    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final prd = pos['prd']?.toString() ?? '';
      posKeys.add('$token|$prd');
    }

    final tradesPerKey = <String, List<TradeBookModel>>{};
    try {
      final response = await _api.getTradeBook();
      final allTrades = response['data'] as List<TradeBookModel>? ?? [];
      for (var trade in allTrades) {
        final key = '${trade.token ?? ''}|${trade.prd ?? ''}';
        if (!posKeys.contains(key)) continue;
        tradesPerKey.putIfAbsent(key, () => []).add(trade);
      }
    } catch (_) {}

    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final prd = pos['prd']?.toString() ?? '';
      final key = '$token|$prd';
      final trades = tradesPerKey[key];

      // Carry-forward: position qty from previous day
      final cfBuyQty =
          (int.tryParse(pos['cfbuyqty']?.toString() ?? '0') ?? 0).toDouble();
      final cfSellQty =
          (int.tryParse(pos['cfsellqty']?.toString() ?? '0') ?? 0).toDouble();
      final cfNetQty = cfBuyQty - cfSellQty;
      // netupldprc = previous day settlement price (base for CF P&L)
      final netUpldPrc =
          double.tryParse(pos['netupldprc']?.toString() ?? '0') ?? 0.0;
      final upldPrc =
          double.tryParse(pos['upldprc']?.toString() ?? '0') ?? 0.0;
      final cfPrice = netUpldPrc != 0 ? netUpldPrc : upldPrc;
      final hasCF = cfNetQty != 0;

      final hasTrades = trades != null && trades.isNotEmpty;

      if (!hasTrades && !hasCF) {
        _timelineMap[key] = _PositionTimeline(
          entryEpoch: marketOpenEpoch,
          snapshots: [],
        );
        continue;
      }

      if (hasTrades) {
        trades.sort((a, b) {
          final ea = _parseTradeTime(a.norentm) ?? 0;
          final eb = _parseTradeTime(b.norentm) ?? 0;
          if (ea != eb) return ea.compareTo(eb);
          final fa = int.tryParse(a.flid ?? '0') ?? 0;
          final fb = int.tryParse(b.flid ?? '0') ?? 0;
          return fa.compareTo(fb);
        });
      }

      final firstTradeEpoch = hasTrades
          ? (_parseTradeTime(trades.first.norentm) ?? marketOpenEpoch)
          : marketOpenEpoch;
      // CF positions exist from market open; day-only from first trade
      final entryEpoch = hasCF ? marketOpenEpoch : firstTradeEpoch;

      // Initialize from carry-forward position
      double runQty = cfNetQty;
      double avgEntry = (hasCF && cfPrice != 0) ? cfPrice : 0;
      double realizedPnl = 0;
      final snapshots = <_TimelineSnapshot>[];

      // Synthetic snapshot at market open for carry-forward positions
      if (hasCF) {
        snapshots.add(_TimelineSnapshot(
          epoch: marketOpenEpoch,
          runningQty: runQty,
          avgEntryPrice: avgEntry,
          cumulativeRealizedPnl: 0,
        ));
      }

      for (var t in trades ?? <TradeBookModel>[]) {
        final epoch = _parseTradeTime(t.norentm) ?? 0;
        final fillQty =
            (int.tryParse(t.flqty ?? t.qty ?? '0') ?? 0).toDouble();
        final fillPrc = double.tryParse(t.flprc ?? '0') ?? 0.0;
        final isBuy = t.trantype == 'B';
        final signedQty = isBuy ? fillQty : -fillQty;

        if (runQty == 0) {
          runQty = signedQty;
          avgEntry = fillPrc;
        } else if ((runQty > 0 && isBuy) || (runQty < 0 && !isBuy)) {
          final newQty = runQty + signedQty;
          avgEntry =
              (avgEntry * runQty.abs() + fillPrc * fillQty) / newQty.abs();
          runQty = newQty;
        } else {
          final closedQty = min(fillQty, runQty.abs());
          if (runQty > 0) {
            realizedPnl += closedQty * (fillPrc - avgEntry);
          } else {
            realizedPnl += closedQty * (avgEntry - fillPrc);
          }
          final prevSign = runQty.sign;
          runQty += signedQty;
          if (runQty != 0 && prevSign != runQty.sign) {
            avgEntry = fillPrc;
          }
        }

        snapshots.add(_TimelineSnapshot(
          epoch: epoch,
          runningQty: runQty,
          avgEntryPrice: avgEntry,
          cumulativeRealizedPnl: realizedPnl,
        ));
      }

      _timelineMap[key] = _PositionTimeline(
        entryEpoch: entryEpoch,
        snapshots: snapshots,
      );
    }

    _tradeBookFetched = true;
  }

  int? _parseTradeTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final dt = DateFormat('HH:mm:ss dd-MM-yyyy').parse(timeStr);
      return dt.millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return null;
    }
  }

  _PositionTimeline _getTimeline(Map<String, dynamic> pos) {
    final token = pos['token']?.toString() ?? '';
    final prd = pos['prd']?.toString() ?? '';
    final key = '$token|$prd';
    final now = DateTime.now();
    final marketOpen =
        DateTime(now.year, now.month, now.day, 9, 15).millisecondsSinceEpoch ~/
            1000;
    return _timelineMap[key] ??
        _PositionTimeline(entryEpoch: marketOpen, snapshots: []);
  }

  Future<void> _fetchMissingTpData(String interval) async {
    final now = DateTime.now();
    final endEpoch = now.millisecondsSinceEpoch ~/ 1000;

    final futures = <Future>[];

    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final exch = pos['exch']?.toString() ?? 'NFO';
      if (token.isEmpty) continue;

      if (_tpCache.containsKey(token) &&
          _tpCache[token]!.containsKey(interval) &&
          _tpCache[token]![interval]!.isNotEmpty) {
        continue;
      }

      final entryEpoch = _getTimeline(pos).entryEpoch;
      futures.add(
          _fetchAndCacheToken(token, exch, interval, entryEpoch, endEpoch));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _fetchAndCacheToken(String token, String exchange,
      String interval, int startEpoch, int endEpoch) async {
    try {
      final result = await _api.getTPSeriesChart(
        exchange: exchange,
        token: token,
        interval: interval,
        startEpoch: startEpoch,
        endEpoch: endEpoch,
      );
      _tpCache.putIfAbsent(token, () => {});
      _tpCache[token]![interval] = result.data ?? [];
    } catch (e) {
      _tpCache.putIfAbsent(token, () => {});
      _tpCache[token]![interval] = [];
    }
  }

  /// Compute aggregated group P&L timeline.
  /// Uses trade timeline for ALL positions with endpoint anchoring.
  List<GroupPnlDataPoint> _computeGroupPnl({
    required bool isDay,
    required bool isNetPnl,
  }) {
    final posCalcs = <_PositionCalcInfo>[];

    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final candles = _tpCache[token]?[_interval] ?? [];

      final pnlField = isNetPnl ? 'profitNloss' : 'mTm';
      final currentPnl =
          double.tryParse(pos[pnlField]?.toString() ?? '0') ?? 0.0;
      final prcFtr =
          double.tryParse(pos['prcftr']?.toString() ?? '1.0') ?? 1.0;
      final mult =
          double.tryParse(pos['mult']?.toString() ?? '1.0') ?? 1.0;

      final timeline = _getTimeline(pos);

      posCalcs.add(_PositionCalcInfo(
        currentPnl: currentPnl,
        prcFtr: prcFtr,
        mult: mult,
        entryEpoch: timeline.entryEpoch,
        timeline: timeline,
        candles: candles,
      ));
    }

    // Collect timestamps from each position's entry time onwards
    final allTimestamps = <int>{};
    for (var pc in posCalcs) {
      for (var c in pc.candles) {
        final epoch = int.tryParse(c.ssboe ?? '0') ?? 0;
        if (epoch >= pc.entryEpoch) allTimestamps.add(epoch);
      }
    }

    final sortedTimestamps = allTimestamps.toList()..sort();
    if (sortedTimestamps.isEmpty) return [];

    // Pre-compute forward-filled price maps (O(n) per position instead of O(n²))
    for (var pc in posCalcs) {
      // Build raw price map
      for (var c in pc.candles) {
        final epoch = int.tryParse(c.ssboe ?? '0') ?? 0;
        final close = double.tryParse(c.intc ?? '0') ?? 0.0;
        if (epoch > 0) pc.priceAtTime[epoch] = close;
      }
      // Forward-fill: for each timestamp in sortedTimestamps, ensure a price
      double? lastKnown;
      for (var t in sortedTimestamps) {
        if (pc.priceAtTime.containsKey(t)) {
          lastKnown = pc.priceAtTime[t];
        } else if (lastKnown != null) {
          pc.priceAtTime[t] = lastKnown;
        }
      }
    }

    // Endpoint anchoring: correction per position
    final lastEpoch = sortedTimestamps.last;
    for (var pc in posCalcs) {
      if (pc.timeline.snapshots.isEmpty) {
        pc.correction = 0;
        continue;
      }
      final lastPrice = pc.priceAtTime[lastEpoch] ?? 0;
      final timelineFinal =
          pc.timeline.pnlAtTime(lastEpoch, lastPrice, pc.prcFtr, pc.mult);
      pc.correction = pc.currentPnl - timelineFinal;
    }

    // Compute group P&L at each timestamp
    final result = <GroupPnlDataPoint>[];
    double runningPeak = double.negativeInfinity;

    for (var epoch in sortedTimestamps) {
      double groupPnl = 0.0;

      for (var pc in posCalcs) {
        if (epoch < pc.entryEpoch) continue;

        final price = pc.priceAtTime[epoch];
        if (price == null) continue;

        if (pc.timeline.snapshots.isNotEmpty) {
          groupPnl += pc.timeline.pnlAtTime(epoch, price, pc.prcFtr, pc.mult) +
              pc.correction;
        } else {
          groupPnl += pc.currentPnl;
        }
      }

      runningPeak = max(runningPeak, groupPnl);
      final drawdown = groupPnl - runningPeak;

      result.add(GroupPnlDataPoint(
        time: DateTime.fromMillisecondsSinceEpoch(epoch * 1000),
        pnl: groupPnl,
        drawdown: drawdown,
        peak: runningPeak,
      ));
    }

    return result;
  }
}

// --------------- Data Classes ---------------

class _TimelineSnapshot {
  final int epoch;
  final double runningQty;
  final double avgEntryPrice;
  final double cumulativeRealizedPnl;

  const _TimelineSnapshot({
    required this.epoch,
    required this.runningQty,
    required this.avgEntryPrice,
    required this.cumulativeRealizedPnl,
  });
}

class _PositionTimeline {
  final int entryEpoch;
  final List<_TimelineSnapshot> snapshots;

  const _PositionTimeline({
    required this.entryEpoch,
    required this.snapshots,
  });

  _TimelineSnapshot? getSnapshot(int epoch) {
    if (snapshots.isEmpty) return null;
    _TimelineSnapshot? state;
    for (var s in snapshots) {
      if (s.epoch <= epoch) {
        state = s;
      } else {
        break;
      }
    }
    return state;
  }

  double pnlAtTime(int epoch, double candlePrice, double prcFtr, double mult) {
    final state = getSnapshot(epoch);
    if (state == null) return 0;

    final unrealized =
        state.runningQty * prcFtr * mult * (candlePrice - state.avgEntryPrice);
    return state.cumulativeRealizedPnl * prcFtr * mult + unrealized;
  }
}

class _PositionCalcInfo {
  final double currentPnl;
  final double prcFtr;
  final double mult;
  final int entryEpoch;
  final _PositionTimeline timeline;
  double correction = 0;

  final List<Data> candles;
  final Map<int, double> priceAtTime = {};

  _PositionCalcInfo({
    required this.currentPnl,
    required this.prcFtr,
    required this.mult,
    required this.entryEpoch,
    required this.timeline,
    required this.candles,
  });
}

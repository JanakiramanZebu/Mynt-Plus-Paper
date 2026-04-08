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

  // Current group positions (kept for WebSocket recalc)
  List<Map<String, dynamic>> _positions = [];

  // --------------- Cache ---------------
  // token → interval → List<Data>
  final Map<String, Map<String, List<Data>>> _tpCache = {};

  // Cached computed results: "groupName|interval|isDay|isNetPnl" → dataPoints
  final Map<String, List<GroupPnlDataPoint>> _resultCache = {};

  // Entry epoch per position: "token|prd" → first trade epoch (seconds)
  // For carry-forward positions this is market open (09:15).
  final Map<String, int> _entryEpochs = {};
  bool _tradeBookFetched = false;

  // --------------- Public API ---------------

  /// Open chart for a group. Fetches data if not cached.
  Future<void> loadGroupChart({
    required String groupName,
    required List groupList,
    required bool isDay,
    required bool isNetPnl,
    String interval = '5',
  }) async {
    print('>>> GroupPnlChart: loadGroupChart called for $groupName with ${groupList.length} positions');
    _activeGroupName = groupName;
    _interval = interval;
    _positions = groupList
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // Clear stale caches when entry times may have changed
    if (!_tradeBookFetched) {
      _resultCache.removeWhere((key, _) => key.startsWith('$groupName|'));
      _tpCache.clear();
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
      await _fetchEntryTimes();
      await _fetchMissingTpData(interval);
      _dataPoints = _computeGroupPnl(isDay: isDay, isNetPnl: isNetPnl);
      _resultCache[cacheKey] = _dataPoints;
    } catch (e) {
      _error = 'Failed to load chart data';
      debugPrint('GroupPnlChart error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Switch interval (5 → 1 or 1 → 5). Uses cache if available.
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
      debugPrint('GroupPnlChart interval switch error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Called when WebSocket updates a position's LTP.
  /// Recalculates only the last data point.
  void onTickUpdate({
    required String token,
    required String ltp,
    required bool isDay,
    required bool isNetPnl,
  }) {
    if (_activeGroupName == null || _dataPoints.isEmpty) return;

    // Update LTP and adjust P&L by delta in our local positions copy
    bool updated = false;
    for (var pos in _positions) {
      if (pos['token']?.toString() == token) {
        final oldLp = double.tryParse(pos['lp']?.toString() ?? '0') ?? 0.0;
        final newLp = double.tryParse(ltp) ?? 0.0;
        final netQty = (int.tryParse(pos['netqty']?.toString() ?? '0') ?? 0).toDouble();
        final prcFtr = double.tryParse(pos['prcftr']?.toString() ?? '1.0') ?? 1.0;
        final mult = double.tryParse(pos['mult']?.toString() ?? '1.0') ?? 1.0;
        final pnlDelta = netQty * prcFtr * mult * (newLp - oldLp);

        // Update LTP
        pos['lp'] = ltp;
        // Update stored P&L values by delta
        final oldPnl = double.tryParse(pos['profitNloss']?.toString() ?? '0') ?? 0.0;
        final oldMtm = double.tryParse(pos['mTm']?.toString() ?? '0') ?? 0.0;
        pos['profitNloss'] = (oldPnl + pnlDelta).toStringAsFixed(2);
        pos['mTm'] = (oldMtm + pnlDelta).toStringAsFixed(2);
        updated = true;
        break;
      }
    }
    if (!updated) return;

    // Recompute the last point using current P&L values
    final now = DateTime.now();
    double groupPnl = 0.0;
    for (var pos in _positions) {
      final field = isNetPnl ? 'profitNloss' : 'mTm';
      groupPnl += double.tryParse(pos[field]?.toString() ?? '0') ?? 0.0;
    }

    // Peak never decreases — take the existing peak and only go higher
    final previousPeak = _dataPoints.last.peak;
    final peak = max(previousPeak, groupPnl);
    final drawdown = groupPnl - peak;

    final updatedLast = GroupPnlDataPoint(
      time: now,
      pnl: groupPnl,
      drawdown: drawdown,
      peak: peak,
    );

    _dataPoints = List.from(_dataPoints)
      ..removeLast()
      ..add(updatedLast);

    // Invalidate result cache for this group (since live data changed)
    _resultCache.removeWhere((key, _) => key.startsWith('$_activeGroupName|'));

    notifyListeners();
  }

  /// Clear all caches (e.g. on logout or full position refresh).
  void clearCache() {
    _tpCache.clear();
    _resultCache.clear();
    _entryEpochs.clear();
    _tradeBookFetched = false;
    _dataPoints = [];
    _activeGroupName = null;
    _positions = [];
  }

  // --------------- Internals ---------------

  String _resultCacheKey(
          String group, String interval, bool isDay, bool isNetPnl) =>
      '$group|$interval|$isDay|$isNetPnl';

  /// Fetch trade book to determine the first execution time for each position.
  /// Looks up today's trades for all positions in the group.
  /// Falls back to market open (09:15) if no trade found.
  Future<void> _fetchEntryTimes() async {
    if (_tradeBookFetched) return;

    final now = DateTime.now();
    final marketOpenEpoch =
        DateTime(now.year, now.month, now.day, 9, 15).millisecondsSinceEpoch ~/
            1000;

    // Collect all token|prd keys we need entry times for
    final posKeys = <String>{};
    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final prd = pos['prd']?.toString() ?? '';
      final key = '$token|$prd';
      posKeys.add(key);
      // Default to market open
      _entryEpochs[key] = marketOpenEpoch;
    }

    try {
      final response = await _api.getTradeBook();
      final trades = response['data'] as List<TradeBookModel>? ?? [];

      // For each position, find the EARLIEST execution time from today's trades
      // norentm format: "HH:mm:ss dd-MM-yyyy"
      for (var trade in trades) {
        final tradeToken = trade.token ?? '';
        final tradePrd = trade.prd ?? '';
        final key = '$tradeToken|$tradePrd';

        if (!posKeys.contains(key)) continue;

        final epoch = _parseTradeTime(trade.norentm);
        if (epoch == null) continue;

        // Keep the earliest trade time for this token+prd
        if (epoch < _entryEpochs[key]!) {
          _entryEpochs[key] = epoch;
        }
      }
    } catch (e) {
      debugPrint('Trade book fetch failed: $e');
    }

    // Log detected entry times for debugging
    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final prd = pos['prd']?.toString() ?? '';
      final key = '$token|$prd';
      final epoch = _entryEpochs[key] ?? 0;
      final entryTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
      print('>>> GroupPnlChart entry: ${pos['tsym']} ($prd) → $entryTime');
    }

    _tradeBookFetched = true;
  }

  /// Parse trade time string "HH:mm:ss dd-MM-yyyy" into epoch seconds.
  int? _parseTradeTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final dt = DateFormat('HH:mm:ss dd-MM-yyyy').parse(timeStr);
      return dt.millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return null;
    }
  }

  /// Get the entry epoch for a position identified by token+prd.
  int _getEntryEpoch(Map<String, dynamic> pos) {
    final token = pos['token']?.toString() ?? '';
    final prd = pos['prd']?.toString() ?? '';
    final key = '$token|$prd';
    // Default to market open if not found
    final now = DateTime.now();
    final marketOpen =
        DateTime(now.year, now.month, now.day, 9, 15).millisecondsSinceEpoch ~/
            1000;
    return _entryEpochs[key] ?? marketOpen;
  }

  /// Fetch TPSeries for any tokens not yet cached at the given interval.
  /// Uses the position's entry time as start (not market open).
  Future<void> _fetchMissingTpData(String interval) async {
    final now = DateTime.now();
    final endEpoch = now.millisecondsSinceEpoch ~/ 1000;

    final futures = <Future>[];

    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final exch = pos['exch']?.toString() ?? 'NFO';
      if (token.isEmpty) continue;

      // Skip if already cached for this interval
      if (_tpCache.containsKey(token) &&
          _tpCache[token]!.containsKey(interval) &&
          _tpCache[token]![interval]!.isNotEmpty) {
        continue;
      }

      // Fetch from this position's entry time, not market open
      final entryEpoch = _getEntryEpoch(pos);
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
      debugPrint('TPSeries fetch failed for token $token: $e');
      _tpCache.putIfAbsent(token, () => {});
      _tpCache[token]![interval] = [];
    }
  }

  /// Compute aggregated group P&L timeline from cached TPSeries data.
  ///
  /// Uses the already-computed P&L from positionGroupCal as the anchor
  /// (profitNloss or mTm), then derives historical values via price delta:
  ///
  ///   P&L(t) = currentPnl + netQty × prcFtr × mult × (close(t) − currentLtp)
  ///
  /// At t=now the delta is 0, so the chart endpoint equals the position
  /// screen value exactly. For past timestamps the delta captures how
  /// much the P&L differed based on the instrument's price at that time.
  List<GroupPnlDataPoint> _computeGroupPnl({
    required bool isDay,
    required bool isNetPnl,
  }) {
    // Step 1: Read each position's anchor values
    final posCalcs = <_PositionCalcInfo>[];

    for (var pos in _positions) {
      final token = pos['token']?.toString() ?? '';
      final candles = _tpCache[token]?[_interval] ?? [];

      // The P&L already computed by positionGroupCal — the source of truth
      final pnlField = isNetPnl ? 'profitNloss' : 'mTm';
      final currentPnl =
          double.tryParse(pos[pnlField]?.toString() ?? '0') ?? 0.0;
      final currentLtp =
          double.tryParse(pos['lp']?.toString() ?? '0') ?? 0.0;
      final netQty =
          (int.tryParse(pos['netqty']?.toString() ?? '0') ?? 0).toDouble();
      final prcFtr =
          double.tryParse(pos['prcftr']?.toString() ?? '1.0') ?? 1.0;
      final mult =
          double.tryParse(pos['mult']?.toString() ?? '1.0') ?? 1.0;

      // Entry time: carry-forward = market open, day trade = first execution
      final entryEpoch = _getEntryEpoch(pos);

      posCalcs.add(_PositionCalcInfo(
        currentPnl: currentPnl,
        currentLtp: currentLtp,
        netQty: netQty,
        prcFtr: prcFtr,
        mult: mult,
        entryEpoch: entryEpoch,
        candles: candles,
      ));
    }

    // Step 2: Collect timestamps only from each position's entry time onwards
    final allTimestamps = <int>{};
    for (var pc in posCalcs) {
      for (var c in pc.candles) {
        final epoch = int.tryParse(c.ssboe ?? '0') ?? 0;
        // Only include candles from this position's entry time
        if (epoch >= pc.entryEpoch) allTimestamps.add(epoch);
      }
    }

    final sortedTimestamps = allTimestamps.toList()..sort();
    if (sortedTimestamps.isEmpty) return [];

    // Step 3: Build candle lookup per position (epoch → close price)
    for (var pc in posCalcs) {
      for (var c in pc.candles) {
        final epoch = int.tryParse(c.ssboe ?? '0') ?? 0;
        final close = double.tryParse(c.intc ?? '0') ?? 0.0;
        if (epoch > 0) pc.priceAtTime[epoch] = close;
      }
    }

    // Step 4: For each timestamp, compute group P&L via delta
    final result = <GroupPnlDataPoint>[];
    double runningPeak = double.negativeInfinity;

    for (var epoch in sortedTimestamps) {
      double groupPnl = 0.0;

      for (var pc in posCalcs) {
        // Position didn't exist before its entry time — contributes 0
        if (epoch < pc.entryEpoch) continue;

        final price = _getPrice(pc, epoch, sortedTimestamps);
        if (price == null) continue;

        // currentPnl + delta: how much the P&L differed at this candle
        final pnl = pc.currentPnl +
            pc.netQty * pc.prcFtr * pc.mult * (price - pc.currentLtp);
        groupPnl += pnl;
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

  /// Get price for a position at a given epoch.
  /// Uses exact match first, then forward-fills from last known price.
  double? _getPrice(
      _PositionCalcInfo pc, int epoch, List<int> sortedTimestamps) {
    if (pc.priceAtTime.containsKey(epoch)) {
      return pc.priceAtTime[epoch];
    }
    // Forward-fill: find the latest price before this epoch
    double? lastKnown;
    for (var t in sortedTimestamps) {
      if (t > epoch) break;
      if (pc.priceAtTime.containsKey(t)) {
        lastKnown = pc.priceAtTime[t];
      }
    }
    return lastKnown;
  }
}

/// Per-position anchor data and candle lookup.
class _PositionCalcInfo {
  /// P&L value already computed by positionGroupCal (profitNloss or mTm)
  final double currentPnl;

  /// Current last traded price — the reference for computing deltas
  final double currentLtp;

  final double netQty;
  final double prcFtr;
  final double mult;

  /// Epoch (seconds) when this position was first entered.
  /// Candles before this time are ignored (position didn't exist).
  final int entryEpoch;

  final List<Data> candles;
  final Map<int, double> priceAtTime = {};

  _PositionCalcInfo({
    required this.currentPnl,
    required this.currentLtp,
    required this.netQty,
    required this.prcFtr,
    required this.mult,
    required this.entryEpoch,
    required this.candles,
  });
}

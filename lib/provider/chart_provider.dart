import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';

@immutable
class ChartState {
  final bool isVisible;
  final ChartArgs? chartArgs;
  final String? previousRoute;
  final dynamic originalArgs; // Store original arguments when needed (e.g., DepthInputArgs for option chain)

  const ChartState({this.isVisible = false, this.chartArgs, this.previousRoute, this.originalArgs});

  ChartState copyWith({bool? isVisible, ChartArgs? chartArgs, String? previousRoute, dynamic originalArgs}) {
    return ChartState(
      isVisible: isVisible ?? this.isVisible,
      chartArgs: chartArgs ?? this.chartArgs,
      previousRoute: previousRoute ?? this.previousRoute,
      originalArgs: originalArgs ?? this.originalArgs,
    );
  }
}

class ChartNotifier extends StateNotifier<ChartState> {
  ChartNotifier() : super(const ChartState());

  void showChart(ChartArgs chartArgs, {String? previousRoute, dynamic originalArgs}) {
    log("showChart called with: ${chartArgs.tsym}, previousRoute: $previousRoute");
    
    // Always create fresh state with new navigation context - don't inherit old values
    state = ChartState(
      isVisible: true,
      chartArgs: chartArgs,
      previousRoute: previousRoute,      // Use exactly what's passed (can be null)
      originalArgs: originalArgs,        // Use exactly what's passed (can be null)
    );
  }

  void hideChart() {
    log("hideChart called");
    state = state.copyWith(isVisible: false);
  }

  void clearChart() {
    log("clearChart called - resetting chart state");
    state = const ChartState();
  }
}

final chartProvider = StateNotifierProvider<ChartNotifier, ChartState>((ref) {
  return ChartNotifier();
});
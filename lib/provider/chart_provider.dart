import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';

@immutable
class ChartState {
  final bool isVisible;
  final ChartArgs? chartArgs;
  final String? previousRoute;

  const ChartState({this.isVisible = false, this.chartArgs, this.previousRoute});

  ChartState copyWith({bool? isVisible, ChartArgs? chartArgs, String? previousRoute}) {
    return ChartState(
      isVisible: isVisible ?? this.isVisible,
      chartArgs: chartArgs ?? this.chartArgs,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }
}

class ChartNotifier extends StateNotifier<ChartState> {
  ChartNotifier() : super(const ChartState());

  void showChart(ChartArgs chartArgs, {String? previousRoute}) {
    log("showChart called with: ${chartArgs.tsym}");
    state = state.copyWith(isVisible: true, chartArgs: chartArgs, previousRoute: previousRoute);
  }

  void hideChart() {
    log("hideChart called");
    state = state.copyWith(isVisible: false);
  }
}

final chartProvider = StateNotifierProvider<ChartNotifier, ChartState>((ref) {
  return ChartNotifier();
});
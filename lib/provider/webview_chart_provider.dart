import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/locator/constant.dart';
import 'package:mynt_plus/provider/core/default_change_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/websocket_provider.dart';

final chartUpdateProvider =
    ChangeNotifierProvider((ref) => ChartUpdateNotifier(ref.read));

class ChartUpdateNotifier extends DefaultChangeNotifier {
  Timer? chartUpdateTimer;
  SharedPreferences? sharedPrefs;
  final Reader ref;
  ChartUpdateNotifier(this.ref);
  String orientation = 'portrait';

  void startChartUpdateTimer(showchartof) {
    initializePreferences();
    chartUpdateTimer?.cancel();

    if (showchartof) {
      chartUpdateTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {

        final socketDatas = ref(websocketProvider).socketDatas;
        final depthData = ref(marketWatchProvider).getQuotes!;
        final tokenData = socketDatas[depthData.token];
        // print("||||||||||||||||| Updating chart data ${depthData.tsym}");

        if (tokenData != null) {
          final json = {
            "t": "df",
            "e": depthData.exch,
            "tk": depthData.token,
            "lp": tokenData['lp']?.toString() ?? "0.00",
            "v": tokenData['v']?.toString() ?? "0.00",
          };
          sharedPrefs?.setString("chartData", jsonEncode(json));

          ConstantName.webViewController!.evaluateJavascript(
              source:
                  'window.localStorage.setItem("tick_tick",\'${jsonEncode(json)}\')');
        }
      });

      notifyListeners();
    } else {
      print("Updating chart stop");
      stopChartUpdateTimer();
    }
  }

  void stopChartUpdateTimer() {
    chartUpdateTimer?.cancel();
    chartUpdateTimer = null;
    notifyListeners();
  }

  void changeOrientation(String orientationData){
    if(orientationData == 'landscape'){
    SystemChrome.setPreferredOrientations([
                              DeviceOrientation.landscapeLeft,
                          ]);
      orientation = 'landscape';
    }
    else{
      SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                          ]);
      orientation = 'portrait';
      
    }
    notifyListeners();
  }

  Future initializePreferences() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }
}

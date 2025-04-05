import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/marketwatch_model/market_watch_scrip_model.dart';

class ConstantName {
  static InAppWebViewController? webViewController;
  static InAppWebViewController? chartwebViewController;
  static String tsym = "";
  static String interval = "5";

  static PageController bottamTab = PageController(initialPage: 0);

  static bool watchlistLoader = false;

  static String pageName = "";

  static String lastSubscribe = "";
  static String lastSubscribeDepth = "";

  static Timer? timer;

  static Timer? charttimer;
  static ChartArgs? chartArgs;
  static bool sessCheck = false;

  static String phoneNum = "(+91) 93 8010 8010";
  static String gamil = "assist@zebuetrade.com";
  static String gamil1 = "grievance@zebuetrade.com";

  static String? msgToken = "";
}

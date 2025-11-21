import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/core/default_change_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

final chartUpdateProvider =
    ChangeNotifierProvider((ref) => ChartUpdateNotifier(ref));

class ChartUpdateNotifier extends DefaultChangeNotifier {
  SharedPreferences? sharedPrefs;
  final Ref ref;
  ChartUpdateNotifier(this.ref);
  String orientation = 'portrait';

  void changeOrientation(String orientationData){
    if(orientationData == 'landscape'){
    if(Platform.isIOS){
    SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeRight,
              ]);}
    else{
              SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              ]);
    }
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

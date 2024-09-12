import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../provider/auth_provider.dart';
import '../provider/network_state_provider.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/no_internet_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> { ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
 
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initializeResources(context: context);
      // context.read(networkStateProvider).networkStream();
      context.read(networkStateProvider).getContext(context);
      // initialRoute();
    }); initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

        setState(() {
           ConstantName.timer = Timer.periodic(const Duration(seconds: 0), (timer) {});
        });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    // late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    // return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;

      if (_connectionStatus == ConnectivityResult.wifi) {
        initialRoute();
      } else if (_connectionStatus == ConnectivityResult.mobile) {
        initialRoute();
      }

      log("_connectionStatus $_connectionStatus");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Center(
          child: SvgPicture.asset("assets/icon/zebulogo.svg",
              color: const Color(0xff003F9E),
              height: 80,
              width: 150,
              fit: BoxFit.contain)),
      if (context.read(networkStateProvider).connectionStatus ==
          ConnectivityResult.none)
        const NoInternetWidget()
    ]));
  }

  initialRoute() async {
    final Preferences pref = locator<Preferences>();
    try {
      print("Device  Name  ${pref.deviceName!} - ${pref.clientSession}");
      context.read(authProvider).loginMethCtrl.text =
          pref.isMobileLogin! ? pref.clientMob! : pref.clientId!;
      context
          .read(authProvider)
          .switchMobToClinent(pref.clientId!.isEmpty ? false : true);
      if (pref.deviceName!.isEmpty) {
        await context.read(authProvider).getDeviceDetails();
      }
      if (pref.clientSession!.isEmpty && pref.clientId!.isNotEmpty) {
        pref.setHideLoginOptBtn(false);
      } else {
        pref.setHideLoginOptBtn(true);
      }
      if (pref.clientSession!.isEmpty) {
        pref.setLogout(true);
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.loginScreen, (route) => false);
      } else {
        // if (pref.logoutClient == "Logout") {

        //   Navigator.pushNamedAndRemoveUntil(
        //       context, Routes.loginScreen, (route) => false,
        //       arguments: "deviceLogin");
        // } else {
        pref.setMobileLogin(true);
        await context
            .read(authProvider)
            .fetchMobileLogin(context, "", pref.clientId!, "");
        // }
      }

      // }

      // context.read(marketWatchProvider).fetchScripMaster();
    } catch (e) {
      log("faild to build --- $e");
    }
  }
}

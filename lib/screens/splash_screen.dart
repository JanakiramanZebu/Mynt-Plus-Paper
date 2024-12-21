import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../provider/auth_provider.dart';
import '../provider/network_state_provider.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/internet_widget.dart';
import '../sharedWidget/snack_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read(themeProvider).removeUsermatrial(context);
      initializeResources(context: context);
      initialRoute();
      context.read(networkStateProvider).networkStream();
      context.read(networkStateProvider).getContext(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffE5EBEC),
        body: Stack(children: [
          Center(
              child: SvgPicture.asset("assets/icon/Mynt New logo.svg",
                
                  height: 60,
                  fit: BoxFit.contain)),
          if (context.read(networkStateProvider).connectionStatus ==
              ConnectivityResult.none)
            const NoInternetScreen()
        ]));
  }

//When an application is opened, it is called and operates according to a condition.
  initialRoute() async {
    final Preferences pref = locator<Preferences>();
    try {
      print(
          "Device  Name  ${pref.deviceName!} - ${pref.clientSession} ----  ${context.read(networkStateProvider).connectionStatus} ");
      context.read(authProvider).loginMethCtrl.text = pref.clientId!;
      context
          .read(authProvider)
          .switchMobToClinent(pref.clientId!.isEmpty ? false : true);
      if (pref.deviceName!.isEmpty) {
        await context.read(authProvider).getDeviceDetails();
      }
      if (pref.clientSession!.isEmpty && pref.clientId!.isNotEmpty) {
        pref.setMobileLogin(false);
        pref.setHideLoginOptBtn(false);
      } else {
        pref.setHideLoginOptBtn(true);
      }
      if (pref.clientSession!.isEmpty) {
        pref.setLogout(true);
        pref.clientId!.isNotEmpty
            ? Navigator.pushNamedAndRemoveUntil(
                context, Routes.loginScreen, (route) => false)
            : Navigator.pushNamedAndRemoveUntil(
                context, Routes.loginScreenBanner, (route) => false);
      } else {
        pref.setMobileLogin(true);
        await context
            .read(authProvider)
            .fetchMobileLogin(context, "", pref.clientId!, "", pref.imei!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(error(context, "Something Wrong !!!"));
      log("faild to build --- $e");
    }
  }
}

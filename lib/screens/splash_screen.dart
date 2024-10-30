import 'dart:developer'; 
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../provider/auth_provider.dart';
import '../provider/network_state_provider.dart';
import '../res/res.dart';
import '../routes/route_names.dart'; 
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
     Future.delayed(const Duration(seconds: 5), ()   {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initializeResources(context: context);
      initialRoute();
      context.read(networkStateProvider).networkStream();
      context.read(networkStateProvider).getContext(context);
    });});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E3465 ) ,
     
      body: Container( height: MediaQuery.of(context).size.height,
        child: Image.asset(
        
          "assets/gif/diwali_wish.gif", 
        ),
      ),
  
     
       
   
    );
  }

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
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.loginScreen, (route) => false);
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

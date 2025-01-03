import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';

import 'functions.dart';

//  If there is no internet, it will show on the screen.

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: SvgPicture.asset("assets/icon/Mynt New logo.svg",
                            //  color: const Color(0xff0037B7),
                            height: 80,
                            width: 150,
                            fit: BoxFit.contain)),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? Color(0xffB0BEC5)
                          : Color(0xff000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )),
                  onPressed: null,
                  child: Text("Retry",
                      style: textStyle(
                          theme.isDarkMode
                              ? Color(0xff000000)
                              : Color(0xffFFFFFF),
                          15,
                          FontWeight.w500)),
                ),
              ),
              Container(
                  color: Colors.black,
                  child: const ListTile(
                      minLeadingWidth: 10,
                      leading: Padding(
                          padding: EdgeInsets.only(top: 3.5),
                          child: Icon(Icons.warning_amber_outlined,
                              size: 15, color: Colors.amber)),
                      title: Text(
                          'It seems like you are offline.Please check your network connection.',
                          style: TextStyle(fontSize: 12, color: Colors.white))))
            ],
          ),
        ),
      );
    });
  }
}

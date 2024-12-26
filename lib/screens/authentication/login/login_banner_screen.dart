import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';

class LoginBannerScreen extends StatefulWidget {
  const LoginBannerScreen({super.key});

  @override
  State<LoginBannerScreen> createState() => _LoginBannerScreenState();
}

class _LoginBannerScreenState extends State<LoginBannerScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show an alert dialog
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit Screen'),
            content: Text('Do you really want to go back?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Stay on the page
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Go back
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );

        // Return true to allow pop, false to cancel it
        return shouldPop ?? false;
      },
      child: Consumer(
        builder: (context, watch, child) {
          final theme = watch(themeProvider);
          final auth = watch(authProvider);
          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent, // Transparent AppBar
              elevation: 0, // No shadow
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                        0.7, -0.7), // Moves gradient toward the top-right
                    radius: 1.5, // Extends the gradient radius
                    colors: [
                      Color(0xFF005FEC),
                      Color(0xFF0057D8),
                      Color(0xFF004FC4),
                      Color(0xFF0047B1),
                      Color(0xFF003F9E),
                      // End color
                    ],
                    stops: [0.0, 0.3, 0.6, 0.8, 1.0], // Smooth transitions
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, bottom: 35, top: 25),
                                child: SvgPicture.asset(
                                  "assets/icon/Mynt New logo.svg",
                                  color: colors.colorWhite,
                                  width: 130,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/icon/banner_ruppee.svg",
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child:
                                SvgPicture.asset("assets/icon/dream_big.svg"),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          SvgPicture.asset(
                            "assets/icon/investwell.svg",
                          ),
                        ],
                      ),
                    ),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: colors.colorBlack,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          )),
                                      onPressed: () {
                                        theme.navigateToNewPage(context);
                                        auth.clearError();
                                        Future.delayed(
                                            Duration(milliseconds: 200), () {
                                          Navigator.pushNamed(
                                              context, Routes.loginScreen);
                                        });
                                      },
                                      child: Text("Login to MYNT",
                                          style: textStylebanner(
                                              colors.colorWhite,
                                              17,
                                              FontWeight.w500)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: colors.colorBlack,
                                          // padding:
                                          //     const EdgeInsets.symmetric(vertical: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          )),
                                      onPressed: () {
                                        launch('https://oa.mynt.in/?ref=zws');
                                      },
                                      child: Text("Open a free account",
                                          style: textStylebanner(
                                              colors.colorWhite,
                                              17,
                                              FontWeight.w500)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 60),
                                Text(
                                    "Zebu Share and Wealth Managements Pvt. Ltd.",
                                    style: textStylebanner(colors.colorWhite,
                                        12, FontWeight.w700)),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "SEBI Registration No: INZ000174634 | Research Analyst : INH200006044 | NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL : 12080400 | AMFI ARN : 113118",
                                  style: textStylebanner(
                                      colors.colorWhite, 10, FontWeight.w500),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/version_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';

class LoginBannerScreen extends StatefulWidget {
  const LoginBannerScreen({super.key});

  @override
  State<LoginBannerScreen> createState() => _LoginBannerScreenState();
}

class _LoginBannerScreenState extends State<LoginBannerScreen> {
  bool _isProcessing = false;
  bool _isLoginProcessing = false;

  Future<void> _handleLogin() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Perform login logic
      // await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Navigate to home screen if successful
      launch('https://oa.mynt.in/?ref=zws');
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleLoginToMynt(WidgetRef ref) async {
    if (_isLoginProcessing) return;
    
    setState(() => _isLoginProcessing = true);
    
    try {
      final theme = ref.read(themeProvider);
      final auth = ref.read(authProvider);
      
      theme.navigateToNewPage(context);
      auth.clearError();
      
      await Future.delayed(const Duration(milliseconds: 200));
      Navigator.pushNamed(context, Routes.loginScreen);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoginProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you really want to exit?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Stay on the page
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Go back
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldPop == true) {
          // Exit the app completely
          SystemNavigator.pop();
        }
      },
      child: Consumer(
        builder: (context, ref, child) {
          final theme = ref.watch(themeProvider);
          final auth = ref.watch(authProvider);
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
                                      onPressed: _isLoginProcessing 
                                        ? null 
                                        : () => _handleLoginToMynt(ref),
                                      child: _isLoginProcessing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text("Login to MYNT",
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
                                      onPressed:
                                          _isProcessing ? null : _handleLogin,
                                      child: _isProcessing
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            )
                                          : Text("Open a free account",
                                              style: textStylebanner(
                                                  colors.colorWhite,
                                                  17,
                                                  FontWeight.w500)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                SvgPicture.asset(
                                  'assets/icon/zebu.svg',
                                  width: 45,
                                  height: 45,
                                  color: colors.colorWhite,
                                ),
                                // Text(
                                //     "Zebu Share and Wealth Managements Pvt. Ltd.",
                                //     style: textStylebanner(colors.colorWhite,
                                //         12, FontWeight.w700)),
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
                    Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Version 3.0.2",
                            textAlign: TextAlign.center,
                            style: textStyle(
                                colors.colorWhite, 10, FontWeight.w300))),
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

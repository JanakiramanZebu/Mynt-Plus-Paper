import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/version_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import 'package:flutter/services.dart';

class LoginBannerScreen extends ConsumerStatefulWidget {
  const LoginBannerScreen({super.key});

  @override
  ConsumerState<LoginBannerScreen> createState() => _LoginBannerScreenState();
}

class _LoginBannerScreenState extends ConsumerState<LoginBannerScreen> {
  bool _isAnyProcessing = false;
  String? _activeButton;
  bool _conflictTap = false;

  Future<void> _handleLogin() async {
    if (_isAnyProcessing) return;

    if (_activeButton != null && _activeButton != 'openAccount') {
      // Conflict: other button also tapped
      setState(() {
        _conflictTap = true;
      });
      return;
    }

    setState(() {
      _isAnyProcessing = true;
      _activeButton = 'openAccount';
    });
    await Future.delayed(Duration(milliseconds: 10));
    if (_conflictTap) {
      // Reset everything
      setState(() {
        _isAnyProcessing = false;
        _activeButton = null;
        _conflictTap = false;
      });
      return;
    }

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
        setState(() {
          _isAnyProcessing = false;
          _activeButton = null;
          _conflictTap = false;
        });
      }
    }
  }

  Future<void> _handleLoginToMynt(WidgetRef ref) async {
    if (_isAnyProcessing) return;
    if (_activeButton != null && _activeButton != 'loginMynt') {
      setState(() {
        _conflictTap = true;
      });
      return;
    }
    setState(() {
      _isAnyProcessing = true;
      _activeButton = 'loginMynt';
      ref.read(authProvider).switchbackbutton(true);
    });
    await Future.delayed(Duration(milliseconds: 10));
    if (_conflictTap) {
      // Reset everything
      setState(() {
        _isAnyProcessing = false;
        _activeButton = null;
        _conflictTap = false;
      });
      return;
    }
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
        setState(() {
          _isAnyProcessing = false;
          _activeButton = null;
          _conflictTap = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        final shouldPop = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                scrollable: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                actionsPadding: const EdgeInsets.only(
                    bottom: 16, right: 16, left: 16, top: 8),
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 150));
                              Navigator.pop(context, false);
                            },
                            borderRadius: BorderRadius.circular(20),
                            splashColor: theme.isDarkMode
                                ? colors.splashColorDark
                                : colors.splashColorLight,
                            highlightColor: theme.isDarkMode
                                ? colors.splashColorDark
                                : colors.splashColorLight,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 22,
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextWidget.subText(
                            text: "Exit Screen",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 3,
                          ),
                          const SizedBox(height: 10),
                          TextWidget.subText(
                            text: "Do you really want to go back?",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 3,
                            align: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        side: BorderSide(color: colors.btnOutlinedBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: colors.primaryDark,
                      ),
                      child: TextWidget.titleText(
                        text: "Yes",
                        theme: theme.isDarkMode,
                        color: !theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fw: 0,
                      ),
                    ),
                  ),
                ],
              );
            });

        if (shouldPop == true) {
          SystemNavigator.pop(); // Go back if user confirms
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        appBar: AppBar(
          backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(
                //   height: 80,
                // ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/icon/Mynt New logo.svg",
                        color: const Color(0xff0037B7),
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Invest in your future",
                          style: TextWidget.textStyle(
                              fontSize: 32,
                              theme: theme.isDarkMode,
                              fw: 1,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight),
                          textAlign: TextAlign.center,
                        ),
                      ),
          
                     const SizedBox(
                        height: 8,
                      ),
          
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Stock, F&O, Mutual Fund, IPO, Bond",
                          style: TextWidget.textStyle(
                              fontSize: 16,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const  SizedBox(
                        height: 44,
                      ),
          
                      // SvgPicture.asset(
                      //   "assets/icon/banner_ruppee.svg",
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20),
                      //   child: SvgPicture.asset("assets/icon/dream_big.svg"),
                      // ),
                      // const SizedBox(
                      //   height: 25,
                      // ),
                      // SvgPicture.asset(
                      //   "assets/icon/investwell.svg",
                      // ),
          
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: OutlinedButton(
                          onPressed: _isAnyProcessing ? null : _handleLogin,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                          ),
                          child:
                              _isAnyProcessing && _activeButton == 'openAccount'
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : TextWidget.titleText(
                                      text: "Open your FREE demat account",
                                      theme: false,
                                      color: const Color(0xffFFFFFF),
                                      fw: 2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: OutlinedButton(
                          onPressed: _isAnyProcessing
                              ? null
                              : () => _handleLoginToMynt(ref),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: const BorderSide(
                              color: Color(0xff0037B7),
                              width: 1,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isAnyProcessing && _activeButton == 'loginMynt'
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromARGB(255, 209, 210, 212),
                                  ),
                                )
                              : TextWidget.titleText(
                                  text: "Login with MYNT",
                                  theme: false,
                                  color: !theme.isDarkMode
                                      ? const Color(0xff0037B7)
                                      : const Color(0xffFFFFFF),
                                  fw: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Open a free account Button
          
                    // const SizedBox(height: 40),
                    // SvgPicture.asset(
                    //   'assets/icon/zebu.svg',
                    //   width: 45,
                    //   height: 45,
                    //   color: const Color(0xff0037B7),
                    // ),
                    // Text(
                    //     "Zebu Share and Wealth Managements Pvt. Ltd.",
                    //     style: textStylebanner(colors.colorWhite,
                    //         12, FontWeight.w700)),
                    const SizedBox(
                      height: 40,
                    ),
                    // TextWidget.paraText(
                    //   text: ,
                    //   theme: false,
                    //   color: const Color(0xff737373),
                    //   // fw: 3,
                    //   align: TextAlign.left,
                    // ),
                    const SizedBox(height: 3),
                    TextWidget.paraText(
                      text:
                          "Zebu, SEBI Registration No: INZ000174634 | Research Analyst : INH200006044 | NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL : 12080400 | AMFI ARN : 113118",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      // fw: 3,
                      align: TextAlign.left,
                      height: 1.8,
                    ),
                    const SizedBox(height: 10),
                    TextWidget.paraText(
                      text: "Version 3.0.2",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      // fw: 3,
                      align: TextAlign.left,
                    ),
                  ],
                ),
                // Container(
                //     margin: const EdgeInsets.only(bottom: 10),
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     child: Text("",
                //         textAlign: TextAlign.center,
                //         style: textStyle(
                //             colors.colorWhite, 10, FontWeight.w300))),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

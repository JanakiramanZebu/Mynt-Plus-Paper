import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/splash_loader.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent>
    with CodeAutoFill {
  final TextEditingController otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _start = 89;
  String resendTime = "01.29";
  String? _receivedCode = '';
  final autoFill = SmsAutoFill();
  String _appSignature = "Fetching...";

  @override
  void initState() {
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _startListeningForOtp();
    _getAppSignature();
    super.initState();
  }

  Future<void> _getAppSignature() async {
    try {
      final autoFill = SmsAutoFill();
      final signature = await autoFill.getAppSignature;
      setState(() {
        _appSignature = signature;
      });
    } catch (e) {
      setState(() {
        _appSignature = "Error: $e";
      });
    }
  }

  Future<void> _startListeningForOtp() async {
    setState(() {
      otpController.text = '';
    });
    await SmsAutoFill().listenForCode(); // Listen via SMS Retriever API
    listenForCode(); // Needed to trigger CodeAutoFill callback
  }

  @override
  void codeUpdated() {
    setState(() {
      _receivedCode = code; // `code` is provided by the mixin
      otpController.text = _receivedCode ?? '';
      print("signature ${otpController.text} $code");
    });
  }

  Preferences pref = Preferences();
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
            resendTime = formattedTime(timeInSecond: _start);
          });
        }
      },
    );
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  @override
  void dispose() {
    _timer!.cancel();
    _focusNode.dispose();
    otpController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      double screenWidth = MediaQuery.of(context).size.width;
      final auth = ref.watch(authProvider);
      final theme = ref.watch(themeProvider);
      final defaultPinThemes = PinTheme(
        width: 50,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
        ),
        textStyle: TextWidget.textStyle(fontSize: 16, theme: theme.isDarkMode),
      );
      final focusedPinTheme = defaultPinThemes.copyBorderWith(
        border: Border.all(color: const Color(0xff0037B7), width: 1),
      );
      final errorPinTheme = defaultPinThemes.copyBorderWith(
        border: Border.all(color: colors.darkred, width: 1),
        //textStyle: defaultPinThemes.textStyle?.copyWith(color: Colors.red),
      );

      final submittedPinTheme = defaultPinThemes.copyBorderWith(
        border: Border.all(color: Color(0xff0037B7), width: 2),
      );
      return auth.initLoad
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                  ),
                  child: CircularLoaderImage()))
          : Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
                backgroundColor: theme.isDarkMode
                    ? const Color(0xff000000)
                    : const Color(0xffFFFFFF),
                elevation: 0,
                centerTitle: false,
                leadingWidth: 48,
                titleSpacing: 6,
                leading: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: Colors.black.withOpacity(0.15),
                    highlightColor: Colors.black.withOpacity(0.08),
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/icon/appbarIcon/arrow-back.svg",
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : const Color(0xFF141414),
                            height: 24,
                            width: 24,
                          ),
                        )),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 5),
                    child: SvgPicture.asset(
                      assets.appLogoIcon,
                      width: 80,
                    ),
                  ),
                ],
              ),
              body: PopScope(
                canPop: true,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const CustomDragHandler(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 34),
                                TextWidget.custmText(
                                    text:
                                        "Enter the ${auth.totp ? '6-digit TOTP' : '4-digit OTP'}",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : const Color(0xFF141414),
                                    fw: 1,
                                    fs: 20),
                                const SizedBox(height: 10),
                                // if (!auth.loading || auth.totp) ...[
                                //   // Text("",
                                //   //     style: textStyles.resendOtpstyle
                                //   //         .copyWith(
                                //   //             color: colors.colorGrey)),
                                //   InkWell(
                                //     onTap: () {
                                //       showModalBottomSheet(
                                //         barrierColor: Colors.transparent,
                                //         context: context,
                                //         shape: const RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.vertical(
                                //               top: Radius.circular(16)),
                                //         ),
                                //         isScrollControlled: true,
                                //         builder: (context) => Padding(
                                //           padding: const EdgeInsets.symmetric(
                                //               horizontal: 16),
                                //           child: SingleChildScrollView(
                                //             child: Column(
                                //               mainAxisSize: MainAxisSize.min,
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const CustomDragHandler(),
                                //                 const SizedBox(height: 12),
                                //                 TextWidget.headText(
                                //                     text:
                                //                         'Enable TOTP Authentication',
                                //                     theme: theme.isDarkMode,
                                //                     fw: 2),
                                //                 const SizedBox(height: 16),
                                //                 _buildStep(
                                //                     "Login to mynt.zebuetrade.com",
                                //                     theme),
                                //                 _buildStep(
                                //                     "Click on the User menu (top-right).",
                                //                     theme),
                                //                 _buildStep("Select Settings.",
                                //                     theme),
                                //                 _buildStep(
                                //                     "Navigate to the TOTP section.",
                                //                     theme),
                                //                 _buildStep(
                                //                     "Enter the 6-digit code to verify.",
                                //                     theme),
                                //                 const SizedBox(height: 120),
                                //               ],
                                //             ),
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //     child: TextWidget.subText(
                                //         text: auth.totp
                                //             ? "Need help generating your TOTP?"
                                //             : "",
                                //         theme: false,
                                //         color: const Color(0xff737373),
                                //         fw: 3),
                                //     // const Icon(
                                //     //   Icons.info_outline,
                                //     //   size: 16,
                                //     // ),
                                //   )
                                // ]

                                // const SizedBox(height: 15),
                                // TextWidget.paraText(
                                //     text: auth.totp
                                //         ? "Enter the TOTP code from the authenticator app"
                                //         : "OTP sent to registered Mobile no and Email",
                                //     theme: false,
                                //     color: const Color(0xff666666),
                                //     fw: 0),
                                // const SizedBox(height: 15),
                                // TextWidget.titleText(
                                //     text:
                                //         "${auth.totp ? '6' : '4'} digit ${auth.totp ? 'TOTP' : 'OTP'}",
                                //     theme: false,
                                //     color: theme.isDarkMode
                                //         ? colors.colorWhite
                                //         : colors.colorBlack,
                                //     fw: 1),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Pinput(
                                      enabled: !auth.loading,
                                      autofocus: false,
                                      focusNode: _focusNode,
                                      separatorBuilder: (index) =>
                                          SizedBox(width: auth.totp ? 24 : 32),
                                      controller: otpController,
                                      length: auth.totp ? 6 : 4,
                                      defaultPinTheme: defaultPinThemes,
                                      focusedPinTheme: focusedPinTheme,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      errorPinTheme: auth.optError ==
                                              "Invalid / wrong ${auth.totp ? 'TOTP' : 'OTP'}"
                                          ? errorPinTheme
                                          : null,
                                      submittedPinTheme: auth.optError ==
                                              "Invalid / wrong ${auth.totp ? 'TOTP' : 'OTP'}"
                                          ? errorPinTheme
                                          : submittedPinTheme,
                                      pinputAutovalidateMode:
                                          PinputAutovalidateMode.onSubmit,
                                      onChanged: (value) {
                                        if (!auth.loading) {
                                          auth.validateOtp(otpController.text);
                                          auth.activeBtnOtp(otpController.text);
                                          if (value.isNotEmpty &&
                                              value.length ==
                                                  (auth.totp ? 6 : 4)) {
                                            auth.submitOtp(
                                                context, otpController.text);
                                          }
                                        }
                                      },
                                      toolbarEnabled: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (auth.optError != null) ...[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: TextWidget.captionText(
                                      text: otpController.length <=
                                                  (auth.totp ? 5 : 3) ||
                                              auth.optError ==
                                                  "Invalid / wrong ${auth.totp ? 'TOTP' : 'OTP'}" ||
                                              auth.optError ==
                                                  "${auth.totp ? 'TOTP' : 'OTP'} Verified"
                                          ? "${auth.optError}"
                                          : "",
                                      theme: false,
                                      color: auth.optError ==
                                              "${auth.totp ? 'TOTP' : 'OTP'} Verified"
                                          ? colors.ltpgreen
                                          : colors.kColorRedText,
                                      fw: 0),
                                ),
                              )
                            ] else ...[
                              const SizedBox(
                                height: 24,
                              )
                            ],
                            // const SizedBox(
                            //   height: 15,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: screenWidth,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: !theme.isDarkMode
                                ? otpController.length <= (auth.totp ? 5 : 3) ||
                                        otpController.text.isEmpty
                                    ? const Color(0xff0037B7).withOpacity(0.3)
                                    : const Color(0xff0037B7)
                                : otpController.length <= (auth.totp ? 5 : 3) ||
                                        otpController.text.isEmpty
                                    ? colors.darkGrey
                                    : colors.colorbluegrey,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                        onPressed:
                            otpController.length <= (auth.totp ? 5 : 3) ||
                                    otpController.text.isEmpty
                                ? () {}
                                : () {
                                    HapticFeedback.heavyImpact();
                                    SystemSound.play(SystemSoundType.click);

                                    auth.submitOtp(context, otpController.text);
                                  },
                        child: auth.loading
                            ? SizedBox(
                                width: 18,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: colors.colorWhite),
                              )
                            : TextWidget.titleText(
                                text: "Verify",
                                theme: false,
                                color: !theme.isDarkMode
                                    ? otpController.length <=
                                                (auth.totp ? 5 : 3) ||
                                            otpController.text.isEmpty
                                        ? const Color(0xffFFFFFF)
                                        : const Color(0xffFFFFFF)
                                    : otpController.length <=
                                                (auth.totp ? 5 : 3) ||
                                            otpController.text.isEmpty
                                        ? colors.darkGrey
                                        : colors.colorBlack,
                                fw: 2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (!auth.totp && !auth.loading)
                              ? (!auth.totp && _start == 0 && !auth.loading)
                                  ? Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          splashColor: theme.isDarkMode
                                              ? Colors.white.withOpacity(0.15)
                                              : Colors.black.withOpacity(0.15),
                                          highlightColor: theme.isDarkMode
                                              ? Colors.white.withOpacity(0.08)
                                              : Colors.black.withOpacity(0.08),
                                          onTap: () async {
                                            await Future.delayed(
                                                Duration(milliseconds: 100));
                                            SmsAutoFill().unregisterListener();
                                            otpController.text = '';
                                            _startListeningForOtp();
                                            auth.submitResendOtp(context);
                                            _start = 89;
                                            startTimer();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            child: TextWidget.subText(
                                                text: "Resend OTP",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                          )),
                                    )
                                  : TextWidget.subText(
                                      text: " $resendTime",
                                      theme: false,
                                      color: resendTime == "00 : 00"
                                          ? Colors.transparent
                                          : theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                      fw: 3)
                              : const SizedBox(),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                onTap: () async {
                                  if (!auth.loading) {
                                    // Clear the OTP field first
                                    setState(() {
                                      otpController.text = "";
                                    });

                                    // Update TOTP state
                                    await auth.setChangetotp(!auth.totp);

                                    // Trigger login with new state
                                    if (mounted) {
                                      auth.submitLogin(context, true);
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  child: TextWidget.subText(
                                      text: auth.totp
                                          ? 'Switch OTP'
                                          : 'Switch TOTP',
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 3),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
    });
  }

  Widget _buildStep(String text, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.titleText(text: "• ", theme: theme.isDarkMode, fw: 2),
          Expanded(
            child: TextWidget.titleText(
                text: text, theme: theme.isDarkMode, fw: 0),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
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
        height: 55,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffE5EBEC), width: 2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: textStyles.textFieldLabelStyle.copyWith(
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
      );
      final focusedPinTheme = defaultPinThemes.copyBorderWith(
        border: Border.all(color: colors.ltpgreen, width: 1),
      );
      final errorPinTheme = defaultPinThemes.copyBorderWith(
        border: Border.all(color: colors.darkred, width: 1),
        //textStyle: defaultPinThemes.textStyle?.copyWith(color: Colors.red),
      );

      final submittedPinTheme = defaultPinThemes.copyBorderWith(
        border: Border.all(color: colors.ltpgreen, width: 2),
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
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context)
                      .viewInsets
                      .bottom, // Padding for the keyboard
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 3,
                      ),
                      const CustomDragHandler(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Verify ${auth.totp ? 'TOTP' : 'OTP'}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        21,
                                        FontWeight.w900)),
                                InkWell(
                                  onTap: () {
                                    if (!auth.loading) {
                                      auth.setChangetotp(!auth.totp);
                                      // Navigator.pop(context);
                                      auth.submitLogin(context, true);
                                    }
                                  },
                                  child: Text(
                                      auth.totp ? 'Get OTP' : 'Enter TOTP',
                                      style: textStyles.resendOtpstyle.copyWith(
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                                auth.totp
                                    ? "Enter the TOTP code from the authenticator app"
                                    : "OTP sent to registered Mobile no and Email",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 15),
                            Text(
                                "${auth.totp ? '6' : '4'} digit ${auth.totp ? 'TOTP' : 'OTP'}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    17,
                                    FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Pinput(
                                enabled: !auth.loading,
                                autofocus: false,
                                focusNode: _focusNode,
                                separatorBuilder: (index) =>
                                    const SizedBox(width: 25),
                                controller: otpController,
                                length: auth.totp ? 6 : 4,
                                defaultPinTheme: defaultPinThemes,
                                focusedPinTheme: focusedPinTheme,
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
                                  auth.validateOtp(otpController.text);
                                  auth.activeBtnOtp(otpController.text);
                                  if (value.isNotEmpty &&
                                      value.length == (auth.totp ? 6 : 4)) {
                                    auth.submitOtp(context, otpController.text);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (auth.optError != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 10),
                          child: Text(
                            otpController.length <= (auth.totp ? 5 : 3) ||
                                    auth.optError ==
                                        "Invalid / wrong ${auth.totp ? 'TOTP' : 'OTP'}" ||
                                    auth.optError ==
                                        "${auth.totp ? 'TOTP' : 'OTP'} Verified"
                                ? "${auth.optError}"
                                : "",
                            style: textStyle(
                                auth.optError ==
                                        "${auth.totp ? 'TOTP' : 'OTP'} Verified"
                                    ? colors.ltpgreen
                                    : colors.kColorRedText,
                                10,
                                FontWeight.w500),
                          ),
                        )
                      ] else ...[
                        const SizedBox(
                          height: 24,
                        )
                      ],
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            if (!auth.totp && _start == 0 && !auth.loading)
                              InkWell(
                                onTap:
                                    //  internet
                                    //             .connectionStatus ==
                                    //         ConnectivityResult.none
                                    //     ? null
                                    //     :
                                    () {
                                  SmsAutoFill().unregisterListener();
                                  otpController.text = '';
                                  _startListeningForOtp();
                                  auth.submitResendOtp(context);
                                  _start = 89;

                                  // auth.loginotpResend(
                                  //     widget.field, widget.value, widget.password, context);

                                  startTimer();
                                },
                                child: Text("Resend OTP",
                                    style: textStyles.resendOtpstyle.copyWith(
                                        color: theme.isDarkMode
                                            ? colors.colorLightBlue
                                            : colors.colorBlue)),
                              ),
                            if (!auth.totp && !auth.loading) ...[
                              Text(" $resendTime",
                                  style: textStyles.resendOtpstyle.copyWith(
                                      color: resendTime == "00 : 00"
                                          ? Colors.transparent
                                          : theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue))
                            ] else if(!auth.loading) ...[
                              Row(
                                children: [
                                  Text("Go to User → Settings → TOTP on Web ",
                                      style: textStyles.resendOtpstyle
                                          .copyWith(color: colors.colorGrey)),
                                  InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          barrierColor: Colors.transparent,
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                          ),
                                          isScrollControlled: true,
                                          builder: (context) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const CustomDragHandler(),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    'Enable TOTP Authentication',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  _buildStep(
                                                      "Login to mynt.zebuetrade.com"),
                                                  _buildStep(
                                                      "Click on the User menu (top-right)."),
                                                  _buildStep(
                                                      "Select Settings."),
                                                  _buildStep(
                                                      "Navigate to the TOTP section."),
                                                  _buildStep(
                                                      "Enter the 6-digit code to verify."),
                                                  const SizedBox(height: 120),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "->",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: colors.colorLightBlue),
                                      )
                                      // const Icon(
                                      //   Icons.info_outline,
                                      //   size: 16,
                                      // ),
                                      )
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        width: screenWidth,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: !theme.isDarkMode
                                  ? otpController.length <=
                                              (auth.totp ? 5 : 3) ||
                                          otpController.text.isEmpty
                                      ? const Color(0xfff5f5f5)
                                      : colors.colorBlack
                                  : otpController.length <=
                                              (auth.totp ? 5 : 3) ||
                                          otpController.text.isEmpty
                                      ? colors.darkGrey
                                      : colors.colorbluegrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                          onPressed: otpController.length <=
                                      (auth.totp ? 5 : 3) ||
                                  otpController.text.isEmpty
                              //         ||
                              //     internet.connectionStatus ==
                              //         ConnectivityResult.none
                              ? () {}
                              : () {
                                  HapticFeedback.heavyImpact();
                                  SystemSound.play(SystemSoundType.click);

                                  auth.submitOtp(context, otpController.text);
                                },
                          child: auth.loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xff666666)),
                                )
                              : Text("Verify",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? otpController.length <=
                                                      (auth.totp ? 5 : 3) ||
                                                  otpController.text.isEmpty
                                              ? const Color(0xff999999)
                                              : colors.colorWhite
                                          : otpController.length <=
                                                      (auth.totp ? 5 : 3) ||
                                                  otpController.text.isEmpty
                                              ? colors.darkGrey
                                              : colors.colorBlack,
                                      15,
                                      FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
    });
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
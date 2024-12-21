import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';

class BottomSheetContent extends StatefulWidget {
  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late List<TextEditingController> _controllers;
  //final FocusNode _focusNode = FocusNode();
  final TextEditingController otpController = TextEditingController();
  Timer? _timer;
  int _start = 89;
  String resendTime = "01.29";
  @override
  void initState() {
    _controllers = List.generate(4, (_) => TextEditingController());
    startTimer();
    super.initState();
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
    for (var controller in _controllers) {
      controller.dispose(); // Dispose each controller
    }
    _timer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      // final Preferences pref = locator<Preferences>();
      double screenWidth = MediaQuery.of(context).size.width;
      final screenhight = MediaQuery.of(context).size.height;
      final auth = watch(authProvider);
      final otp = _controllers.map((controller) => controller.text).join();
      final theme = watch(themeProvider);
      return auth.initLoad
          ? Container(
              height: screenhight,
              color: Color(0xffE5EBEC),
              child: Center(
                child: SvgPicture.asset(assets.appLogoIcon,
                    // color: theme.isDarkMode
                    //     ? colors.colorWhite
                    //     : colors.logoColor,
                    height: 60,
                    fit: BoxFit.contain),
              ),
            )
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
                            Text("Verify OTP",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    21,
                                    FontWeight.w900)),
                            const SizedBox(height: 15),
                            Text("OTP sent to registered Mobile no and Email",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 15),
                            Text("4 digit OTP",
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
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          children: List.generate(4, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              width: 50,
                              height: 55,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xffE5EBEC), width: 2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                style: textStyles.textFieldLabelStyle.copyWith(
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: false),
                                //keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  // print("DDD ${auth.otpCtrl.text}");
                                  if (value.isNotEmpty && index < 3) {
                                    FocusScope.of(context).nextFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(context).previousFocus();
                                  }
                                  auth.validateOtp(otp);
                                  auth.activeBtnOtp(otp);
                                },
                                autofocus: true,
                              ),
                            );
                          }),
                        ),
                      ),
                      if (auth.optError != null) ...[
                        Padding(
                          padding: EdgeInsets.only(
                              left: otp.length <= 3 ? 16 : 0,
                              top: otp.length <= 3 ? 10 : 0),
                          child: Text(
                            otp.length <= 3 ? "${auth.optError}" : "",
                            style: textStyle(
                                colors.kColorRedText, 10, FontWeight.w500),
                          ),
                        )
                      ],
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            if (_start == 0)
                              InkWell(
                                onTap:
                                    //  internet
                                    //             .connectionStatus ==
                                    //         ConnectivityResult.none
                                    //     ? null
                                    //     :
                                    () {
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
                            Text(" $resendTime",
                                style: textStyles.resendOtpstyle.copyWith(
                                    color: resendTime == "00 : 00"
                                        ? Colors.transparent
                                        : theme.isDarkMode
                                            ? colors.colorLightBlue
                                            : colors.colorBlue))
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
                                  ? otp.length <= 3 || otp.isEmpty
                                      ? const Color(0xfff5f5f5)
                                      : colors.colorBlack
                                  : otp.length <= 3 || otp.isEmpty
                                      ? colors.darkGrey
                                      : colors.colorbluegrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                          onPressed: otp.length <= 3 || otp.isEmpty
                              //         ||
                              //     internet.connectionStatus ==
                              //         ConnectivityResult.none
                              ? () {}
                              : () {
                                  HapticFeedback.heavyImpact();
                                  SystemSound.play(SystemSoundType.click);

                                  auth.submitOtp(context, otp);
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
                                          ? otp.length <= 3 || otp.isEmpty
                                              ? const Color(0xff999999)
                                              : colors.colorWhite
                                          : otp.length <= 3 || otp.isEmpty
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
}

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late List<TextEditingController> _controllers;

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
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final Preferences pref = locator<Preferences>();
      final auth = watch(authProvider);
      final otp = _controllers.map((controller) => controller.text).join();
      final theme = watch(themeProvider);
      return WillPopScope(
        onWillPop: () async {
          pref.setLogout(false);
          auth.clearTextField();
          auth.clearError();
          FocusScope.of(context).unfocus();
          return true;
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor:
                !auth.initLoad ? Color(0xffFFFFFF) : Color(0xffE5EBEC),
            appBar: auth.initLoad
                ? null
                : AppBar(
                    backgroundColor: theme.isDarkMode
                        ? Color(0xff000000)
                        : Color(0xffFFFFFF),
                    elevation: .2,
                    centerTitle: false,
                    leadingWidth: 41,
                    titleSpacing: 6,
                    leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Icon(Icons.arrow_back_ios)
                          // SvgPicture.asset(assets.backArrow,
                          //     color:
                          //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
                          ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 5),
                        child: auth.initLoad
                            ? null
                            : SvgPicture.asset(
                                assets.appLogoIcon,
                                width: 80,
                              ),
                      ),
                    ],
                  ),
            body: SafeArea(
              child: Stack(
                children: [
                  auth.initLoad
                      ? Center(
                          child: SvgPicture.asset(assets.appLogoIcon,
                              height: 60, fit: BoxFit.contain),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Verify OTP",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  21,
                                                  FontWeight.w900)),
                                          const SizedBox(height: 15),
                                          Text(
                                              "OTP sent to registered Mobile no and Email",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  12,
                                                  FontWeight.w500)),
                                          const SizedBox(height: 15),
                                          Text("4 digit OTP",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  17,
                                                  FontWeight.w600)),
                                        ]),
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
                                                color: Color(0xffE5EBEC),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: TextField(
                                            controller: _controllers[index],
                                            maxLength: 1,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: false),
                                            //keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              counterText: "",
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              // print("DDD ${auth.otpCtrl.text}");
                                              if (value.isNotEmpty &&
                                                  index < 3) {
                                                FocusScope.of(context)
                                                    .nextFocus();
                                              } else if (value.isEmpty &&
                                                  index > 0) {
                                                FocusScope.of(context)
                                                    .previousFocus();
                                              }
                                              auth.validateOtp(otp);
                                              auth.activeBtnOtp(otp);
                                            },
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  if (auth.optError != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, top: 10),
                                      child: Text(
                                        otp.length <= 3 ||
                                                auth.optError ==
                                                    "Invalid / wrong OTP" ||
                                                auth.optError == "OTP Verified"
                                            ? "${auth.optError}"
                                            : "",
                                        style: textStyle(colors.kColorRedText,
                                            10, FontWeight.w500),
                                      ),
                                    )
                                  ],
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 15),
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
                                                style: textStyles.resendOtpstyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .colorLightBlue
                                                            : colors
                                                                .colorBlue)),
                                          ),
                                        Text(" $resendTime",
                                            style: textStyles.resendOtpstyle
                                                .copyWith(
                                                    color: theme.isDarkMode
                                                        ? colors.colorLightBlue
                                                        : colors.colorBlue))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 15),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
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
                                            strokeWidth: 2,
                                            color: Color(0xff666666)),
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
                  // if (internet.connectionStatus == ConnectivityResult.none) ...[
                  //   const NoInternetWidget()
                  // ]
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

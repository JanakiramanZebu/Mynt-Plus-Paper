import 'dart:async';

 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/auth_provider.dart'; 
import '../../../provider/thems.dart';
import '../../../res/res.dart'; 

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  int _start = 89;
  String resendTime = "01.29";
  @override
  void initState() {
    startTimer();
    super.initState();
  }

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
      final auth = watch(authProvider);
      
      final theme = watch(themeProvider);
      return WillPopScope(
        onWillPop: () async {
          auth.clearTextField();
          auth.clearError();

          return true;
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  auth.initLoad
                      ? Center(
                          child: SvgPicture.asset("assets/icon/zebulogo.svg",
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              height: 80,
                              width: 150,
                              fit: BoxFit.contain),
                        )
                      : SingleChildScrollView(
                          reverse: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child: SvgPicture.asset(assets.appLogoIcon,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      height: 60)),
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
                                      const SizedBox(height: 10),
                                      Text(
                                          "OTP sent to registered Mobile no and Email",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              12,
                                              FontWeight.w500)),
                                      const SizedBox(height: 30),
                                      Text("4 digit OTP",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w600)),
                                      TextFormField(
                                        style: textStyles.textFieldLabelStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack),
                                        controller: auth.otpCtrl,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: false),
                                        maxLength: 4,
                                        obscureText: auth.hideOtp,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          suffixIconConstraints:
                                              const BoxConstraints(
                                                  minHeight: 0, minWidth: 0),
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              auth.hiddenOtp();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: SvgPicture.asset(
                                                auth.hideOtp
                                                    ? "assets/icon/eye-off.svg"
                                                    : "assets/icon/eye.svg",
                                                color: const Color(0xff999999),
                                                width: 22,
                                              ),
                                            ),
                                          ),
                                          errorStyle: textStyle(
                                              colors.kColorRedText,
                                              10,
                                              FontWeight.w500),
                                          errorText: auth.optError,
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minHeight: 0, minWidth: 0),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.only(
                                                right: 15),
                                            child: SvgPicture.asset(
                                              "assets/keyboardicons/keybord_mobile_otp.svg",
                                              width: 20,
                                              fit: BoxFit.scaleDown,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          hintStyle: textStyle(
                                              Colors.grey, 13, FontWeight.w400),
                                          hintText:
                                              "Enter 4 digit OTP to begin",
                                           enabledBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff999999))),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff666666))),
                                        ),
                                        onChanged: (v) {
                                          auth.otpCtrl.text.replaceAll(" ", "");

                                          auth.validateOtp();
                                          auth.activeBtnOtp();
                                        },
                                      ),

                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: _start != 0 ? 12 : 0),
                                        child: Row(
                                          children: [
                                            if (_start == 0)
                                              TextButton(
                                                onPressed:
                                                //  internet
                                                //             .connectionStatus ==
                                                //         ConnectivityResult.none
                                                //     ? null
                                                //     : 
                                                    () {
                                                        auth.submitResendOtp(
                                                            context);
                                                        _start = 89;

                                                        // auth.loginotpResend(
                                                        //     widget.field, widget.value, widget.password, context);

                                                        startTimer();
                                                      },
                                                child: Text("Resend OTP",
                                                    style: textStyles
                                                        .resendOtpstyle
                                                        .copyWith(
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .colorLightBlue
                                                                : colors
                                                                    .colorBlue)),
                                              ),
                                            Text(" $resendTime",
                                                style: textStyles.resendOtpstyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .colorLightBlue
                                                            : colors.colorBlue))
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(height: 20),

                                      SizedBox(
                                        width: screenWidth,
                                        height: 44,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: !theme.isDarkMode
                                                  ? auth.isDisableOtpBtn
                                                      ? const Color(0xfff5f5f5)
                                                      : colors.colorBlack
                                                  : auth.isDisableOtpBtn
                                                      ? colors.darkGrey
                                                      : colors.colorWhite,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 13),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              )),
                                          onPressed: auth
                                                      .otpCtrl.text.isEmpty 
                                              //         ||
                                              //     internet.connectionStatus ==
                                              //         ConnectivityResult.none
                                                ? () {}
                                               : 
                                              () {
                                                  HapticFeedback.heavyImpact();
                                                  SystemSound.play(
                                                      SystemSoundType.click);
                                                  auth.submitOtp(context);
                                                },
                                          child: auth.loading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Color(
                                                              0xff666666)),
                                                )
                                              : Text("Verify",
                                                  style: textStyle(
                                                      !theme.isDarkMode
                                                          ? auth.isDisableOtpBtn
                                                              ? const Color(
                                                                  0xff999999)
                                                              : colors
                                                                  .colorWhite
                                                          : auth.isDisableOtpBtn
                                                              ? colors.darkGrey
                                                              : colors
                                                                  .colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                        ),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
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

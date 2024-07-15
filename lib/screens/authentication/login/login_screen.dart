 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../api/core/api_link.dart';
import '../../../provider/auth_provider.dart'; 
import '../../../provider/thems.dart'; 
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_form_field.dart'; 

class LoginScreen extends ConsumerWidget {
  final String routeTo;
  const LoginScreen({super.key, required this.routeTo});

  @override
  

  @override
  Widget build(BuildContext context,ScopedReader watch) {
 
      double screenWidth = MediaQuery.of(context).size.width;

      final auth = watch(authProvider);
     
      final theme = watch(themeProvider);

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          // backgroundColor:    theme.isDarkMode? colors.colorBlack:colors.colorWhite,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 50),
                      child: SvgPicture.asset(assets.appLogoIcon,
                          height: 60,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                                routeTo == "deviceLogin"
                                    ? "Welcome"
                                    : "Login to MYNT +",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    21,
                                    FontWeight.w900)),
                            if (routeTo == "deviceLogin" &&
                                ApiLinks.userName != "") ...[
                              const SizedBox(height: 10),
                              Text(ApiLinks.userName,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600))
                            ],
                            const SizedBox(height: 30),
                            Text(
                                routeTo == "deviceLogin"
                                    ? "Client ID"
                                    : auth.isMobileLogin
                                        ? "Client ID"
                                        : "Mobile Number",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600)),
                            if (routeTo == "deviceLogin")
                              const SizedBox(height: 8),
                            TextFormField(
                              style: textStyles.textFieldLabelStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                              onTap: routeTo == "deviceLogin"
                                  ? null
                                  : auth.isMobileLogin
                                      ? null
                                      : auth.getCurrentPhone,
                              controller: auth.loginMethCtrl,
                              readOnly: routeTo == "deviceLogin"
                                  ? true
                                  : false,
                              keyboardType: routeTo == "deviceLogin"
                                  ? TextInputType.text
                                  : auth.isMobileLogin
                                      ? TextInputType.text
                                      : TextInputType.datetime,
                              maxLength: routeTo == "deviceLogin"
                                  ? null
                                  : auth.isMobileLogin
                                      ? null
                                      : 10,
                              textCapitalization:
                                  routeTo == "deviceLogin"
                                      ? TextCapitalization.characters
                                      : auth.isMobileLogin
                                          ? TextCapitalization.characters
                                          : TextCapitalization.none,
                              inputFormatters: routeTo == "deviceLogin"
                                  ? [UpperCaseTextFormatter()]
                                  : auth.isMobileLogin
                                      ? [
                                          UpperCaseTextFormatter(),
                                          RemoveEmojiInputFormatter(),
                                          FilteringTextInputFormatter.deny(
                                              RegExp('[π£•₹€℅™∆√¶/.,]')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s')),
                                        ]
                                      : [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                              decoration: InputDecoration(
                                fillColor: theme.isDarkMode?colors.darkGrey: const Color(0xfff5f5f5),
                                filled: routeTo == "deviceLogin"
                                    ? true
                                    : false,
                                contentPadding: const EdgeInsets.only(top: 4),
                                errorStyle: textStyle(
                                    colors.kColorRedText, 10, FontWeight.w500),
                                errorText: auth.loginMethError,
                                prefixIconConstraints: const BoxConstraints(
                                    minHeight: 0, minWidth: 30),
                                prefixIcon: Container(
                                  margin:
                                      const EdgeInsets.only(left: 0, right: 15),
                                  child: SvgPicture.asset(
                                    routeTo == "deviceLogin"
                                        ? "assets/keyboardicons/keyboard_profile.svg"
                                        : auth.isMobileLogin
                                            ? "assets/keyboardicons/keyboard_profile.svg"
                                            : "assets/keyboardicons/keybord_mobile.svg",
                                    color: const Color(0xff666666),
                                    width: 20,
                                    // fit: BoxFit.scaleDown,
                                  ),
                                ),
                                suffix: routeTo == "deviceLogin"
                                    ? InkWell(
                                        onTap: ()async {
                                          {
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                Routes.loginScreen,
                                                arguments: "login",
                                                (route) => false);
                                         await   auth.loginMethod();
                                            FocusScope.of(context).unfocus();
                                          }
                                        },
                                        child: Text("Switch  ",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorLightBlue
                                                    : colors.colorBlue,
                                                12,
                                                FontWeight.w500)),
                                      )
                                    : null,
                                hintStyle:
                                    textStyle(Colors.grey, 13, FontWeight.w400),
                                hintText: routeTo == "deviceLogin"
                                    ? "Enter Client ID to begin"
                                    : auth.isMobileLogin
                                        ? "Enter Client ID to begin"
                                        : "Enter Mobile Number to begin",
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff999999)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff666666)),
                                ),
                              ),
                              onChanged: (v) {
                                auth.validateLogin(routeTo);
                                auth.activeBtnLogin();
                              },
                            ),
                            auth.isMobileLogin ||
                                    routeTo == "deviceLogin"
                                ? const SizedBox(height: 26)
                                : const SizedBox(height: 5),
                            Text("Password",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600)),
                            TextFormField(
                              style: textStyles.textFieldLabelStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                              textAlign: TextAlign.justify,
                              controller: auth.passCtrl,
                              decoration: InputDecoration(
                                suffixIconConstraints: const BoxConstraints(
                                    minHeight: 0, minWidth: 0),
                                suffixIcon: InkWell(
                                    onTap: () {
                                      auth.hiddenPass();
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        child: SvgPicture.asset(
                                          auth.hidePass
                                              ? "assets/icon/eye-off.svg"
                                              : "assets/icon/eye.svg",
                                          color: const Color(0xff999999),
                                          width: 22,
                                        ))),
                                prefixIconConstraints: const BoxConstraints(
                                    minHeight: 0, minWidth: 0),
                                prefixIcon: Container(
                                    margin: const EdgeInsets.only(right: 15),
                                    child: SvgPicture.asset(
                                      "assets/icon/key-01.svg",
                                      width: 22,
                                      color: const Color(0xff666666),
                                      // fit: BoxFit.scaleDown,
                                    )),
                                contentPadding: const EdgeInsets.only(top: 10),
                                hintText: "Enter Password to begin",
                                hintStyle:
                                    textStyle(Colors.grey, 13, FontWeight.w400),
                                errorStyle: textStyle(
                                    colors.kColorRedText, 10, FontWeight.w500),
                                errorText: auth.passError,
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff999999))),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff666666))),
                              ),
                              inputFormatters: [
                                RemoveEmojiInputFormatter(),
                                FilteringTextInputFormatter.deny(
                                    RegExp('[π£•₹€℅™∆√¶/,.]')),
                                FilteringTextInputFormatter.deny(RegExp(r'\s'))
                              ],
                              obscureText: auth.hidePass,
                              onChanged: (v) {
                                auth.validateLogin(routeTo);
                                auth.activeBtnLogin();
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: routeTo == "deviceLogin"
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.spaceBetween,
                              children: [
                                if (routeTo != "deviceLogin")
                                  InkWell(
                                    // style: TextButton.styleFrom(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 0, vertical: 0)),
                                    onTap: () {
                                      if (routeTo == "deviceLogin") {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Routes.loginScreen,
                                            arguments: "login",
                                            (route) => false);
                                        auth.loginMethod();
                                        FocusScope.of(context).unfocus();
                                      } else {
                                        auth.loginMethod();
                                        FocusScope.of(context).unfocus();
                                      }
                                    },

                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 4),
                                      child: Text(
                                          auth.isMobileLogin
                                              ? "Login with Mobile"
                                              : "Login with Client ID",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue,
                                              12,
                                              FontWeight.w500)),
                                    ),
                                  ),
                                InkWell(
                                    onTap: () {
                                      auth.clearError();
                                      auth.clearTextField();
                                      Navigator.pushNamed(
                                          context, Routes.forgotPass);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 4),
                                      child: Text("Forgot password?",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue,
                                              12,
                                              FontWeight.w500)),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: screenWidth,
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: !theme.isDarkMode
                                        ? auth.isDisableBtn
                                            ? const Color(0xfff5f5f5)
                                            : colors.colorBlack
                                        : auth.isDisableBtn
                                            ? colors.darkGrey
                                            : colors.colorWhite,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    )),
                                onPressed: ((auth.loginMethCtrl.text.isEmpty ||
                                            auth.passCtrl.text.isEmpty) )
                                            // ||
                                    //     internet.connectionStatus ==
                                    //         ConnectivityResult.none)
                                     ? () {}
                                      :
                                     () {
                                        HapticFeedback.heavyImpact();
                                        SystemSound.play(SystemSoundType.click);
                                        auth.submitLogin(
                                            context, routeTo);
                                      },
                                child: auth.loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xff666666)),
                                      )
                                    : Text("Continue",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? auth.isDisableBtn
                                                    ? const Color(0xff999999)
                                                    : colors.colorWhite
                                                : auth.isDisableBtn
                                                    ? colors.darkGrey
                                                    : colors.colorBlack,
                                            14,
                                            FontWeight.w500)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account yet?",
                                  style: textStyle(const Color(0xff999999), 13,
                                      FontWeight.w500),
                                ),
                                InkWell(
                                  onTap: () {
                                    launch('https://oa.mynt.in/');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(" Sign Up",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorLightBlue
                                                    : colors.colorBlue,
                                                12,
                                                FontWeight.w500)),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        SvgPicture.asset(
                                          "assets/icon/box-arrow-up-right.svg",
                                          color: theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue,
                                          width: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
          bottomNavigationBar: SizedBox(
              height: 75,
              child: Column(
                children: [
                  Text("Zebu Share and Wealth Managements Pvt. Ltd.",
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w700)),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "SEBI Registration No: INZ000174634 | Research Analyst : INH200006044 | NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL : 12080400 | AMFI ARN : 113118",
                      style: textStyle(
                          const Color(0xff999999), 10, FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )),
        ),
      );
 
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

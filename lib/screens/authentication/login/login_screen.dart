import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/splash_loader.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    double screenWidth = MediaQuery.of(context).size.width;

    final auth = watch(authProvider);
    final forpass = watch(changePasswordProvider);
    final theme = watch(themeProvider);

    Preferences pref = Preferences();
    return GestureDetector(
      onTap: () {
        //theme.removeUsermatrial(context);
        FocusScope.of(context).unfocus();
      },
      child: auth.initLoad
          ? WillPopScope(
              onWillPop: () async {
                return false;
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
                backgroundColor: theme.isDarkMode
                    ? const Color(0xff000000)
                    : const Color(0xffFFFFFF),
                elevation: 0,
                centerTitle: false,
                leadingWidth: 41,
                titleSpacing: 6,
                leading: InkWell(
                    onTap: () {
                      theme.removeUsermatrial(context);
                      Navigator.pushNamedAndRemoveUntil(
                          context, Routes.loginScreenBanner, (route) => false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Icon(Icons.arrow_back_ios,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack),
                    )),
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
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          // reverse: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          pref.clientName!.isNotEmpty &&
                                                  pref.islogOut!
                                              ? "Welcome"
                                              : "Login",
                                          style:
                                              // TextStyle(
                                              //   fontFamily: 'InterVariable',
                                              //   fontSize: 21,
                                              //   fontWeight: FontWeight.w900,
                                              // ),
                                              textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  21,
                                                  FontWeight.w900)),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                          pref.clientName!.isNotEmpty &&
                                                  pref.islogOut!
                                              ? pref.clientName!
                                              : "Every login is a step closer to your goals.",
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              // TextStyle(
                                              //   color: Color(0xff666666),
                                              //   fontFamily: 'InterVariable',
                                              //   fontSize: 12,
                                              //  // fontWeight: FontWeight.w500,
                                              // )
                                              textStyle(const Color(0xff666666),
                                                  12, FontWeight.w500)),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text("Mobile / Client ID",
                                          style:
                                              // TextStyle(
                                              //   fontFamily: 'InterVariable',
                                              //   fontSize: 17,
                                              //   fontWeight: FontWeight.w600,
                                              // )
                                              textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  17,
                                                  FontWeight.w600)),
                                      if (pref.clientName!.isNotEmpty &&
                                          pref.islogOut!)
                                        const SizedBox(height: 8),
                                      TextFormField(
                                        style: textStyles.textFieldLabelStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack),
                                        onTap: pref.isMobileLogin!
                                            ? auth.getCurrentPhone
                                            : null,
                                        controller: auth.loginMethCtrl,
                                        readOnly: pref.islogOut! &&
                                                (pref.clientId!.isNotEmpty ||
                                                    pref.clientMob!.isNotEmpty)
                                            ? true
                                            : false,
                                        // keyboardType: TextInputType.text,
                                        //maxLength: pref.isMobileLogin! ? 10 : null,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        inputFormatters: pref.islogOut!
                                            ? [UpperCaseTextFormatter()]
                                            : [
                                                UpperCaseTextFormatter(),
                                                RemoveEmojiInputFormatter(),
                                                FilteringTextInputFormatter
                                                    .deny(RegExp(
                                                        '[π£•₹€℅™∆√¶/.,]')),
                                                FilteringTextInputFormatter
                                                    .deny(RegExp(r'\s')),
                                              ],
                                        decoration: InputDecoration(
                                          fillColor: theme.isDarkMode
                                              ? colors.darkGrey
                                              : const Color(0xfff5f5f5),
                                          filled: pref.islogOut! &&
                                                  (pref.clientId!.isNotEmpty ||
                                                      pref.clientMob!
                                                          .isNotEmpty)
                                              ? true
                                              : false,
                                          contentPadding:
                                              const EdgeInsets.only(top: 4),
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minHeight: 0, minWidth: 30),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.only(
                                                left: 0, right: 15),
                                            child: SvgPicture.asset(
                                              pref.isMobileLogin!
                                                  ? "assets/keyboardicons/keybord_mobile.svg"
                                                  : "assets/keyboardicons/keyboard_profile.svg",
                                              color: const Color(0xff666666),
                                              width: 20,
                                              // fit: BoxFit.scaleDown,
                                            ),
                                          ),
                                          suffix: pref.islogOut! &&
                                                  (pref.clientId!.isNotEmpty ||
                                                      pref.clientMob!
                                                          .isNotEmpty)
                                              ? InkWell(
                                                  onTap: () async {
                                                    {
                                                      pref.setLogout(false);
                                                      pref.setHideLoginOptBtn(
                                                          true);
                                                      await auth.loginMethod();
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    }
                                                  },
                                                  child: Text("Switch  ",
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors
                                                                  .colorLightBlue
                                                              : colors
                                                                  .colorBlue,
                                                          12,
                                                          FontWeight.w500)),
                                                )
                                              : null,
                                          hintStyle: textStyle(
                                              Colors.grey, 13, FontWeight.w400),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xff999999)),
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xff666666)),
                                          ),
                                        ),
                                        onChanged: (v) {
                                          auth.validateLogin();
                                          auth.activeBtnLogin();
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      if (auth.loginMethError != null) ...[
                                        Text(
                                          "${auth.loginMethError}",
                                          style:
                                              // TextStyle(
                                              //   color: colors.kColorRedText,
                                              //   fontFamily: 'InterVariable',
                                              //   fontSize: 10,
                                              //   fontWeight: FontWeight.w500,
                                              // )
                                              textStyle(colors.kColorRedText,
                                                  10, FontWeight.w500),
                                        ),
                                      ],
                                      const SizedBox(height: 18),
                                      Text("Password",
                                          style:
                                              // TextStyle(
                                              //   fontFamily: 'InterVariable',
                                              //   fontSize: 17,
                                              //   fontWeight: FontWeight.w600,
                                              // )
                                              textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  17,
                                                  FontWeight.w600)),
                                      TextFormField(
                                        style: textStyles.textFieldLabelStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack),
                                        textAlign: TextAlign.justify,
                                        controller: auth.passCtrl,
                                        decoration: InputDecoration(
                                          suffixIconConstraints:
                                              const BoxConstraints(
                                                  minHeight: 0, minWidth: 0),
                                          suffixIcon: InkWell(
                                              onTap: () {
                                                auth.hiddenPass();
                                              },
                                              child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                                  child: SvgPicture.asset(
                                                    auth.hidePass
                                                        ? "assets/icon/eye-off.svg"
                                                        : "assets/icon/eye.svg",
                                                    color:
                                                        const Color(0xff999999),
                                                    width: 22,
                                                  ))),
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                                  minHeight: 0, minWidth: 0),
                                          prefixIcon: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 15),
                                              child: SvgPicture.asset(
                                                "assets/icon/key-01.svg",
                                                width: 22,
                                                color: const Color(0xff666666),
                                                // fit: BoxFit.scaleDown,
                                              )),
                                          contentPadding:
                                              const EdgeInsets.only(top: 10),
                                          hintStyle: textStyle(
                                              Colors.grey, 13, FontWeight.w400),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xff999999))),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xff666666))),
                                        ),
                                        inputFormatters: [
                                          RemoveEmojiInputFormatter(),
                                          FilteringTextInputFormatter.deny(
                                              RegExp('[π£•₹€℅™∆√¶/,.]')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s'))
                                        ],
                                        obscureText: auth.hidePass,
                                        onChanged: (v) {
                                          auth.validateLogin();
                                          auth.activeBtnLogin();
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      if (auth.passError != null) ...[
                                        Text(
                                          "${auth.passError}",
                                          style:
                                              // TextStyle(
                                              //   color: colors.kColorRedText,
                                              //   fontFamily: 'InterVariable',
                                              //   fontSize: 10,
                                              //   fontWeight: FontWeight.w500,
                                              // )
                                              textStyle(colors.kColorRedText,
                                                  10, FontWeight.w500),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // if (pref.hideLoginOptBtn!)
                                          InkWell(
                                              onTap: () {
                                                forpass.clearError();
                                                forpass.clearTextField();
                                                Navigator.pushNamed(
                                                    context, Routes.forgotPass);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 4),
                                                child: Text("Forgot password?",
                                                    style:
                                                        //  TextStyle(
                                                        //   color: colors.colorBlue,
                                                        //   fontFamily: 'InterVariable',
                                                        //   fontSize: 12,
                                                        //   fontWeight: FontWeight.w500,
                                                        // )
                                                        textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorLightBlue
                                                                : colors
                                                                    .colorBlue,
                                                            12,
                                                            FontWeight.w500)),
                                              )),
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
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: screenWidth,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: !theme.isDarkMode
                              ? auth.isDisableBtn
                                  ? const Color(0xfff5f5f5)
                                  : colors.colorBlack
                              : auth.isDisableBtn
                                  ? colors.darkGrey
                                  : colors.colorbluegrey,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          )),
                      onPressed: ((auth.loginMethCtrl.text.isEmpty ||
                              auth.passCtrl.text.isEmpty))
                          // ||
                          //     internet.connectionStatus ==
                          //         ConnectivityResult.none)
                          ? () {}
                          : () {
                              HapticFeedback.heavyImpact();
                              SystemSound.play(SystemSoundType.click);
                              auth.optError = "";
                              auth.submitLogin(context);
                            },
                      child: auth.loading
                          ? const SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xff666666)),
                            )
                          : Text("Continue",
                              style:
                                  // TextStyle(
                                  //     color: !theme.isDarkMode
                                  //         ? auth.isDisableBtn
                                  //             ? const Color(0xff999999)
                                  //             : colors.colorWhite
                                  //         : auth.isDisableBtn
                                  //             ? colors.darkGrey
                                  //             : colors.colorBlack,
                                  //     fontFamily: 'InterVariable',
                                  //     fontSize: 15,
                                  //     fontWeight: FontWeight.w500)
                                  textStyle(
                                      !theme.isDarkMode
                                          ? auth.isDisableBtn
                                              ? const Color(0xff999999)
                                              : colors.colorWhite
                                          : auth.isDisableBtn
                                              ? colors.darkGrey
                                              : colors.colorBlack,
                                      15,
                                      FontWeight.w500)),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(bottom: 23,top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Version 3.0.2",
                          textAlign: TextAlign.center,
                          style: textStyle(
                              const Color(0xff666666), 10, FontWeight.w300))),
                  //const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

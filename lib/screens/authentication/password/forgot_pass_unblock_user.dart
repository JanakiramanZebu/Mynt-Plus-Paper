import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
 
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_form_field.dart'; 

class ForgotPassUnblockUser extends StatefulWidget {
  const ForgotPassUnblockUser({super.key});

  @override
  State<ForgotPassUnblockUser> createState() => _ForgotPassUnblockUserState();
}

class _ForgotPassUnblockUserState extends State<ForgotPassUnblockUser> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final authForgetpassword = watch(changePasswordProvider);
        final theme = watch(themeProvider);
        double screenWidth = MediaQuery.of(context).size.width;
        return WillPopScope(
          onWillPop: () async {
            authForgetpassword.clearTextField();
            return true;
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: SvgPicture.asset(
                          assets.appLogoIcon,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.logoColor,
                          height: 60,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text("Forgot password",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      21,
                                      FontWeight.w900)),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      authForgetpassword.isMobileForgetpass
                                          ? "Client ID"
                                          : "Mobile Number",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                ],
                              ),
                              TextFormField(
                                style: textStyles.textFieldLabelStyle.copyWith(
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack),
                                controller:
                                    authForgetpassword.forGetloginMethCtrl,
                                keyboardType:
                                    authForgetpassword.isMobileForgetpass
                                        ? TextInputType.text
                                        : TextInputType.datetime,
                                maxLength: authForgetpassword.isMobileForgetpass
                                    ? null
                                    : 10,
                                textCapitalization:
                                    authForgetpassword.isMobileForgetpass
                                        ? TextCapitalization.characters
                                        : TextCapitalization.none,
                                inputFormatters: authForgetpassword
                                        .isMobileForgetpass
                                    ? [
                                        UpperCaseTextFormatter(),
                                        RemoveEmojiInputFormatter(),
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[π£•₹€℅™∆√¶/]')),
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'\s')),
                                      ]
                                    : [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(top: 4),
                                  errorStyle: textStyle(colors.kColorRedText,
                                      10, FontWeight.w500),
                                  errorText: authForgetpassword.forgetpassError,
                                  prefixIconConstraints: const BoxConstraints(
                                      minHeight: 0, minWidth: 30),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(
                                        left: 0, right: 15),
                                    child: SvgPicture.asset(
                                      authForgetpassword.isMobileForgetpass
                                          ? "assets/keyboardicons/keyboard_profile.svg"
                                          : "assets/keyboardicons/keybord_mobile.svg",
                                      color: const Color(0xff666666),
                                      width: 20,
                                      // fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  hintStyle: textStyle(
                                      Colors.grey, 13, FontWeight.w400),
                                  hintText:
                                      authForgetpassword.isMobileForgetpass
                                          ? "Enter Client ID"
                                          : "Enter Mobile Numer",
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
                                  authForgetpassword.validateForgetpassWord();
                                  authForgetpassword.activateFrogetbtn();
                                },
                              ),
                              authForgetpassword.isMobileForgetpass
                                  ? const SizedBox(height: 26)
                                  : const SizedBox(height: 6),
                              InkWell(
                                // style: TextButton.styleFrom(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 0, vertical: 0)),
                                onTap: () {
                                  authForgetpassword.forgetMethod();
                                  FocusScope.of(context).unfocus();
                                },

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 10),
                                  child: Text(
                                      authForgetpassword.isMobileForgetpass
                                          ? "Switch to Mobile"
                                          : "Switch to Client ID",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorLightBlue
                                              : colors.colorBlue,
                                          12,
                                          FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                  width: screenWidth,
                                  height: 44,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: !theme.isDarkMode
                                              ? authForgetpassword
                                                      .isDisableforgetbtn
                                                  ? const Color(0xfff5f5f5)
                                                  : colors.colorBlack
                                              : authForgetpassword
                                                      .isDisableforgetbtn
                                                  ? colors.darkGrey
                                                  : colors.colorbluegrey,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          )),
                                      onPressed: authForgetpassword
                                              .forGetloginMethCtrl.text.isEmpty
                                          ? () {}
                                          : () {
                                              authForgetpassword
                                                  .submitForgetPassword(
                                                      context);
                                            },
                                      child: authForgetpassword.loading
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
                                                      ? authForgetpassword
                                                              .isDisableforgetbtn
                                                          ? const Color(
                                                              0xff999999)
                                                          : colors.colorWhite
                                                      : authForgetpassword
                                                              .isDisableforgetbtn
                                                          ? colors.darkGrey
                                                          : colors.colorBlack,
                                                  14,
                                                  FontWeight.w500)))),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle:
          TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
}

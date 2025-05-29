import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../utils/no_emoji_inputformatter.dart';

class ForgotPassUnblockUser extends StatefulWidget {
  const ForgotPassUnblockUser({super.key});

  @override
  State<ForgotPassUnblockUser> createState() => _ForgotPassUnblockUserState();
}

class _ForgotPassUnblockUserState extends State<ForgotPassUnblockUser> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authForgetpassword = ref.watch(changePasswordProvider);
        final auth = ref.watch(authProvider);
        final theme = ref.watch(themeProvider);
        double screenWidth = MediaQuery.of(context).size.width;
        return PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return; // If system handled back, do nothing

            FocusScope.of(context).unfocus();
            authForgetpassword.clearTextField();
            Navigator.of(context).pop(); // Proceed with back navigation
          },

          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor:
                    theme.isDarkMode ? Color(0xff000000) : Color(0xffFFFFFF),
                elevation: 0,
                centerTitle: false,
                leadingWidth: 41,
                titleSpacing: 6,
                leading: InkWell(
                  onTap: () {
                    auth.clearError();
                    Navigator.pop(context);
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Icon(Icons.arrow_back_ios,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
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
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                          // authForgetpassword.isMobileForgetpass
                                          //     ? "Client ID"
                                          //     : "Mobile Number",
                                          "Mobile / Client ID",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              17,
                                              FontWeight.w600)),
                                    ],
                                  ),
                                  TextFormField(
                                    style: textStyles.textFieldLabelStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack),
                                    controller:
                                        authForgetpassword.forGetloginMethCtrl,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                      NoEmojiInputFormatter(),
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[π£•₹€℅™∆√¶/]')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s')),
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.only(top: 4),
                                      errorStyle: textStyle(
                                          colors.kColorRedText,
                                          10,
                                          FontWeight.w500),
                                      errorText:
                                          authForgetpassword.forgetpassError,
                                      prefixIconConstraints:
                                          const BoxConstraints(
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
                                        ),
                                      ),
                                      hintStyle: textStyle(
                                          Colors.grey, 13, FontWeight.w400),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff999999)),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff666666)),
                                      ),
                                    ),
                                    onChanged: (v) {
                                      authForgetpassword
                                          .validateForgetpassWord();
                                      authForgetpassword.activateFrogetbtn();
                                    },
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        width: screenWidth,
                        height: 46,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: !theme.isDarkMode
                                    ? authForgetpassword.isDisableforgetbtn
                                        ? const Color(0xfff5f5f5)
                                        : colors.colorBlack
                                    : authForgetpassword.isDisableforgetbtn
                                        ? colors.darkGrey
                                        : colors.colorbluegrey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                            onPressed: authForgetpassword
                                    .forGetloginMethCtrl.text.isEmpty
                                ? () {}
                                : () {
                                    authForgetpassword
                                        .submitForgetPassword(context);
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
                                                ? const Color(0xff999999)
                                                : colors.colorWhite
                                            : authForgetpassword
                                                    .isDisableforgetbtn
                                                ? colors.darkGrey
                                                : colors.colorBlack,
                                        15,
                                        FontWeight.w500)))),
                  ],
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
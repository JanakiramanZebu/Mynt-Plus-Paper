import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../utils/no_emoji_inputformatter.dart';

class ForgotPassUnblockUser extends StatefulWidget {
  const ForgotPassUnblockUser({super.key});

  @override
  State<ForgotPassUnblockUser> createState() => _ForgotPassUnblockUserState();
}

class _ForgotPassUnblockUserState extends State<ForgotPassUnblockUser> {
  bool _isProcessing = false;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleContinue(
      ChangePasswordProvider authForgetpassword) async {
    if (_isProcessing ||
        authForgetpassword.forGetloginMethCtrl.text.isEmpty ||
        authForgetpassword.loading) return;

    setState(() => _isProcessing = true);

    try {
      await authForgetpassword.submitForgetPassword(context);
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authForgetpassword = ref.watch(changePasswordProvider);
        final auth = ref.watch(authProvider);
        final theme = ref.watch(themeProvider);
        double screenWidth = MediaQuery.of(context).size.width;
        return PopScope(
          canPop: false, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return; // If system handled back, do nothing
            FocusScope.of(context).unfocus();
            auth.clearError();
            auth.clearTextField();
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
                leadingWidth: 48,
                titleSpacing: 0,
                leading: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      splashColor: Colors.black.withOpacity(0.15),
                      highlightColor: Colors.black.withOpacity(0.08),
                      customBorder: const CircleBorder(),
                      onTap: () {
                        auth.clearError();
                        auth.clearTextField();
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 37),
                            TextWidget.heroText(
                                text: "Forgot password",
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                fw: 1),
                            const SizedBox(height: 24),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //         // authForgetpassword.isMobileForgetpass
                            //         //     ? "Client ID"
                            //         //     : "Mobile Number",
                            //         "Mobile / Client ID",
                            //         style: textStyle(
                            //             theme.isDarkMode
                            //                 ? colors.colorWhite
                            //                 : colors.colorBlack,
                            //             17,
                            //             FontWeight.w600)),
                            //   ],
                            // ),
                            TextFormField(
                              focusNode: focusNode,
                              style: TextWidget.textStyle(
                                fontSize: 16,
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                               
                                height: 1.3,
                              ),
                              controller:
                                  authForgetpassword.forGetloginMethCtrl,
                              readOnly:
                                  (_isProcessing || authForgetpassword.loading)
                                      ? true
                                      : false,
                              maxLength: 10,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffFFFFFF),
                                labelText: "Mobile / Client ID",

                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                labelStyle: TextWidget.textStyle(
                                  fontSize: 14,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  fw: 3,
                                ),
                                floatingLabelStyle: TextWidget.textStyle(
                                    fontSize: 16,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    fw: 3),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDBDBDB), width: 1),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDBDBDB), width: 1),
                                ),
                                counterText: "",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 12),

                                // prefixIconConstraints: const BoxConstraints(
                                //     minHeight: 0, minWidth: 30),
                                // prefixIcon: Container(
                                //   margin:
                                //       const EdgeInsets.only(left: 0, right: 15),
                                //   child: SvgPicture.asset(
                                //     authForgetpassword.isMobileForgetpass
                                //         ? "assets/keyboardicons/keyboard_profile.svg"
                                //         : "assets/keyboardicons/keybord_mobile.svg",
                                //     color: const Color(0xff666666),
                                //     width: 20,
                                //   ),
                                // ),
                                // hintStyle: TextWidget.textStyle(
                                //     color: Colors.grey,
                                //     fontSize: 13,
                                //     fw: 00,
                                //     theme: false),
                                // enabledBorder: UnderlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: focusNode.hasFocus
                                //           ? Colors.transparent
                                //           : const Color(0xff999999)),
                                // ),
                                // focusedBorder: const UnderlineInputBorder(
                                //   borderSide:
                                //       BorderSide(color: Color(0xff666666)),
                                // ),
                              ),
                              onChanged: (v) {
                                authForgetpassword.validateForgetpassWord();
                                authForgetpassword.activateFrogetbtn();
                              },
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                authForgetpassword.forgetpassError != null
                                    ? TextWidget.captionText(
                                        text:
                                            "${authForgetpassword.forgetpassError}",
                                        theme: false,
                                        color: colors.kColorRedText,
                                        fw: 0)
                                    : const SizedBox(),
                                TextWidget.captionText(
                                    text:
                                        "${authForgetpassword.forGetloginMethCtrl.text.length}/10",
                                    theme: theme.isDarkMode,
                                    fw: 0),
                              ],
                            )
                          ]),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 13),
                        width: screenWidth,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: !theme.isDarkMode
                                  ? authForgetpassword.isDisableforgetbtn
                                      ? const Color(0xFF0037B7).withOpacity(0.3)
                                      : colors.primaryLight
                                  : authForgetpassword.isDisableforgetbtn
                                      ?  const Color(0xFF002A8F).withOpacity(0.3)
                                      : colors.primaryDark,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              )),
                          onPressed: () {
                            authForgetpassword.validateForgetpassWord();
                            _handleContinue(authForgetpassword);
                          },
                          child: (_isProcessing || authForgetpassword.loading)
                              ? SizedBox(
                                  width: 18,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: colors.colorWhite),
                                )
                              : TextWidget.titleText(
                                  text: "Reset",
                                  theme: false,
                                  color: !theme.isDarkMode
                                      ? authForgetpassword.isDisableforgetbtn
                                          ? const Color(0xffFFFFFF)
                                          : const Color(0xffFFFFFF)
                                      : authForgetpassword.isDisableforgetbtn
                                          ? colors.darkGrey
                                          : colors.colorBlack,
                                  fw: 2),
                        )),
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

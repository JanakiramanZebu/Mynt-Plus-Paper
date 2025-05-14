import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_form_field.dart';

class ForgotPassUnblockUser extends StatefulWidget {
  const ForgotPassUnblockUser({super.key});

  @override
  State<ForgotPassUnblockUser> createState() => _ForgotPassUnblockUserState();
}

class _ForgotPassUnblockUserState extends State<ForgotPassUnblockUser> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final authForgetpassword = watch(changePasswordProvider);
        final auth = watch(authProvider);
        final theme = watch(themeProvider);
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
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
                                      Text("Reset Password",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              24,
                                              FontWeight.w900)),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Enter your registered mobile number or client ID to receive a temporary password via SMS and email.",
                                        style: textStyle(
                                          const Color(0xff666666),
                                          14,
                                          FontWeight.w500
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme.isDarkMode 
                                              ? Colors.black.withOpacity(0.3) 
                                              : Colors.grey.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: theme.isDarkMode 
                                                ? Colors.grey.withOpacity(0.3) 
                                                : Colors.grey.withOpacity(0.1),
                                            width: 1.0
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Mobile / Client ID",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    17,
                                                    FontWeight.w600)),
                                            const SizedBox(height: 10),
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
                                                RemoveEmojiInputFormatter(),
                                                FilteringTextInputFormatter.deny(
                                                    RegExp('[π£•₹€℅™∆√¶/]')),
                                                FilteringTextInputFormatter.deny(
                                                    RegExp(r'\s')),
                                              ],
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                                fillColor: theme.isDarkMode ? Colors.black38 : Colors.white,
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.3),
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                errorStyle: textStyle(
                                                    colors.kColorRedText,
                                                    10,
                                                    FontWeight.w500),
                                                errorText:
                                                    authForgetpassword.forgetpassError,
                                                prefixIconConstraints:
                                                    const BoxConstraints(
                                                        minHeight: 0, minWidth: 40),
                                                prefixIcon: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8, right: 8),
                                                  child: Icon(
                                                    authForgetpassword.isMobileForgetpass
                                                        ? Icons.person
                                                        : Icons.smartphone,
                                                    color: theme.isDarkMode
                                                        ? colors.colorLightBlue
                                                        : colors.colorBlue,
                                                    size: 20,
                                                  ),
                                                ),
                                                hintText: "Enter Mobile Number or Client ID",
                                                hintStyle: textStyle(
                                                    Colors.grey, 13, FontWeight.w400),
                                              ),
                                              onChanged: (v) {
                                                authForgetpassword
                                                    .validateForgetpassWord();
                                                authForgetpassword.activateFrogetbtn();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          width: screenWidth,
                          height: 50,
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
                                  ? null
                                  : () {
                                      HapticFeedback.mediumImpact();
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
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Reset Password",
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
                                                FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: !theme.isDarkMode
                                              ? authForgetpassword.isDisableforgetbtn
                                                  ? const Color(0xff999999)
                                                  : colors.colorWhite
                                              : authForgetpassword.isDisableforgetbtn
                                                  ? colors.darkGrey
                                                  : colors.colorBlack,
                                        )
                                      ],
                                    ))),
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

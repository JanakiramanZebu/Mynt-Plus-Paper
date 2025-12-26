import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/change_password_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';

class ChangePass extends ConsumerStatefulWidget {
  final String isChangePass;
  const ChangePass({super.key, required this.isChangePass});

  @override
  ConsumerState<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends ConsumerState<ChangePass> {
  late FocusNode focusNode;
  late FocusNode focusNode1;
  late FocusNode focusNode2;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
    focusNode1 = FocusNode();
    focusNode1.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
    focusNode2 = FocusNode();
    focusNode2.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final changepassword = ref.watch(changePasswordProvider);
    // final loginAuth = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Center(
        child: Padding(
          padding: getResponsiveWidth(context) == 600
              ? const EdgeInsets.symmetric(vertical: 30.0)
              : const EdgeInsets.only(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14), // rounded corners
              border: Border.all(
                color: Colors.grey.shade300, // border color
                width: 0.3, // border width
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // shadow color
                  blurRadius: 4, // how soft the shadow is
                  offset: const Offset(0, 4), // shadow position
                ),
              ],
            ),
            width: getResponsiveWidth(context), // de

            child: Scaffold(
              appBar: AppBar(
                backgroundColor:
                    theme.isDarkMode ? const Color(0xff000000) : const Color(0xffFFFFFF),
                elevation: 0,
                centerTitle: false,
                leadingWidth: 48,
                titleSpacing: 6,
                leading: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: Colors.black.withOpacity(0.15),
                      highlightColor: Colors.black.withOpacity(0.08),
                      onTap: () {
                        Navigator.pop(context);
                        changepassword.changePassMethod();
                      },
                      child: Container(
                        width: 55,
                        height: 55,
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
              body: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return; // If system handled back, do nothing
                  changepassword.changePassMethod();
                  Navigator.of(context).pop();
                },
                child: SingleChildScrollView(
                  reverse: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 29.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.heroText(
                                  text: "Choose your Password",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  fw: 2),
                              const SizedBox(
                                height: 25,
                              ),
                              TextFormField(
                                focusNode: focusNode1,
                                readOnly: changepassword.loading ? true : false,
                                style: TextWidget.textStyle(
                                  fontSize: 16,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  height: 1.3,
                                ),
                                obscureText: changepassword.hideoldpassword,
                                controller: changepassword.oldPassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  labelText: widget.isChangePass == "Yes"
                                      ? "Old Password"
                                      : "Generated Password",
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
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                                .withOpacity(0.2)
                                            : const Color(0xffDBDBDB),
                                        width: 1),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                                .withOpacity(0.2)
                                            : const Color(0xffDBDBDB),
                                        width: 1),
                                  ),
                                  counterText: "",
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 14),
                                  suffixIconConstraints: const BoxConstraints(
                                      minHeight: 0, minWidth: 0),
                                  suffixIcon: Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      splashColor:
                                          Colors.black.withOpacity(0.15),
                                      highlightColor:
                                          Colors.black.withOpacity(0.08),
                                      onTap: () {
                                        changepassword.hiddeoldpasswords();
                                        changepassword.activateChangePass();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        child: SvgPicture.asset(
                                          changepassword.hideoldpassword
                                              ? "assets/icon/eye-off.svg"
                                              : "assets/icon/eye.svg",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          width: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onChanged: (v) {
                                  changepassword.validateOldPassword();
                                  changepassword.activateChangePass();
                                },
                              ),
                              const SizedBox(height: 5),
                              changepassword.oldPasswordError != null
                                  ? TextWidget.captionText(
                                      text:
                                          "${changepassword.oldPasswordError}",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.lossDark
                                          : colors.lossLight,
                                      fw: 0)
                                  : const SizedBox(),
                              const SizedBox(height: 20),
                              TextFormField(
                                focusNode: focusNode2,
                                style: TextWidget.textStyle(
                                  fontSize: 16,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  height: 1.3,
                                ),
                                readOnly: changepassword.loading ? true : false,
                                obscureText: changepassword.hidenewpassword,
                                controller: changepassword.newPassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  labelText: "New Password",
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                  labelStyle: TextWidget.textStyle(
                                    fontSize: 14,
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    height: 1.3,
                                  ),
                                  floatingLabelStyle: TextWidget.textStyle(
                                      fontSize: 16,
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      fw: 3),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                                .withOpacity(0.2)
                                            : const Color(0xffECEDEE),
                                        width: 1.5),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                                .withOpacity(0.2)
                                            : const Color(0xffECEDEE),
                                        width: 1.5),
                                  ),
                                  counterText: "",
                                  suffixIconConstraints: const BoxConstraints(
                                      minHeight: 0, minWidth: 0),
                                  suffixIcon: Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      splashColor:
                                          Colors.black.withOpacity(0.15),
                                      highlightColor:
                                          Colors.black.withOpacity(0.08),
                                      onTap: () {
                                        changepassword.hiddenewpasswords();
                                        changepassword.activateChangePass();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        child: SvgPicture.asset(
                                          changepassword.hidenewpassword
                                              ? "assets/icon/eye-off.svg"
                                              : "assets/icon/eye.svg",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          width: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 14),
                                ),
                                onChanged: (v) {
                                  changepassword.validateNewPassword();
                                  changepassword.activateChangePass();
                                },
                              ),
                              const SizedBox(height: 5),
                              changepassword.newPasswordError != null
                                  ? TextWidget.captionText(
                                      text:
                                          "${changepassword.newPasswordError}",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.lossDark
                                          : colors.lossLight,
                                      fw: 0)
                                  : const SizedBox(),
                              const SizedBox(height: 30),
                              SizedBox(
                                  width: screenWidth,
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: !theme.isDarkMode
                                                ? changepassword
                                                        .isDisableChangepassbtn
                                                    ? colors.primaryLight
                                                        .withOpacity(0.5)
                                                    : colors.primaryLight
                                                : changepassword
                                                        .isDisableChangepassbtn
                                                    ? colors.primaryDark
                                                        .withOpacity(0.5)
                                                    : colors.primaryDark,
                                            side: BorderSide.none,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 13),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            )),
                                        onPressed: changepassword
                                                    .userIdController
                                                    .text
                                                    .isEmpty ||
                                                changepassword
                                                    .oldPassword.text.isEmpty ||
                                                changepassword
                                                    .newPassword.text.isEmpty ||
                                                changepassword.loading
                                            ? () {
                                                changepassword
                                                    .validateOldPassword();
                                                changepassword
                                                    .validateNewPassword();
                                              }
                                            : () {
                                                changepassword
                                                    .submitChangePass(context);
                                              },
                                        child: changepassword.loading
                                            ? SizedBox(
                                                width: 18,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            colors.colorWhite),
                                              )
                                            : TextWidget.titleText(
                                                text: "Set New Password",
                                                theme: false,
                                                color: !theme.isDarkMode
                                                    ? changepassword
                                                            .isDisableChangepassbtn
                                                        ? colors.colorWhite
                                                            .withOpacity(0.5)
                                                        : colors.colorWhite
                                                    : changepassword
                                                            .isDisableChangepassbtn
                                                        ? colors.colorWhite
                                                            .withOpacity(0.5)
                                                        : colors.colorWhite,
                                                fw: 2)),
                                  )),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

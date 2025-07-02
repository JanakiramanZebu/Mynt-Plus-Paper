import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cus_list_widget.dart';
import '../../../sharedWidget/custom_text_form_field.dart';

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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.isDarkMode ? Color(0xff000000) : Color(0xffFFFFFF),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text("Client ID",
                        //     style: textStyle(
                        //         theme.isDarkMode
                        //             ? colors.colorWhite
                        //             : colors.colorBlack,
                        //         14,
                        //         FontWeight.w600)),
                        TextWidget.heroText(
                            text: "Choose your Password",
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            fw: 1),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Container(
                        //   padding: const EdgeInsets.all(8),
                        //   color: const Color(0xfff5f5f5).withOpacity(0.8),
                        //   child: TextWidget.titleText(
                        //       text: changepassword.userIdController.text,
                        //       theme: false,
                        //       color: theme.isDarkMode
                        //           ? colors.colorWhite
                        //           : colors.colorBlack,
                        //       fw: 1),
                        // ),

                        const SizedBox(
                          height: 25,
                        ),

                        // TextFormField(
                        //   focusNode: focusNode,
                        //   readOnly: true,
                        //   textCapitalization: TextCapitalization.characters,
                        //   inputFormatters: [UpperCaseTextFormatter()],
                        //   style: TextWidget.textStyle(
                        //     fontSize: 16,
                        //     theme: theme.isDarkMode,
                        //     color: theme.isDarkMode
                        //         ? colors.colorWhite
                        //         : colors.colorBlack,
                        //     fw: 0,
                        //   ),
                        //   controller: changepassword.userIdController,
                        //   decoration: InputDecoration(
                        //     labelText: "Client ID",
                        //     border: const OutlineInputBorder(
                        //         borderSide: BorderSide.none),
                        //     // isDense: true,
                        //     floatingLabelBehavior: FloatingLabelBehavior.auto,
                        //     labelStyle: TextWidget.textStyle(
                        //         fontSize: 14,
                        //         theme: theme.isDarkMode,
                        //         color: theme.isDarkMode
                        //             ? colors.colorWhite
                        //             : colors.colorBlack,
                        //         fw: 0),
                        //     floatingLabelStyle: TextWidget.textStyle(
                        //         fontSize: 16,
                        //         theme: theme.isDarkMode,
                        //         color: theme.isDarkMode
                        //             ? colors.colorWhite
                        //             : colors.colorBlack,
                        //         fw: 0),
                        //     counterText: "",
                        //     // fillColor: theme.isDarkMode
                        //     //     ? colors.darkGrey
                        //     //     : const Color(0xfff5f5f5),
                        //     // filled: true,
                        //     // errorStyle: textStyle(
                        //     //     colors.kColorRedText, 10, FontWeight.w500),
                        //     // errorText: changepassword.userIdChangepassError,

                        //     // prefixIconConstraints:
                        //     //     const BoxConstraints(minHeight: 0, minWidth: 0),
                        //     // prefixIcon: Container(
                        //     //   margin: const EdgeInsets.only(right: 15),
                        //     //   child: SvgPicture.asset(
                        //     //     "assets/keyboardicons/keyboard_profile.svg",
                        //     //     color: const Color(0xff666666),
                        //     //     width: 22,
                        //     //     fit: BoxFit.scaleDown,
                        //     //   ),
                        //     // ),
                        //     contentPadding:
                        //         const EdgeInsets.symmetric(vertical: 5),
                        //     hintStyle:
                        //         textStyle(Colors.grey, 13, FontWeight.w400),
                        //     // hintText: "Enter client Id",
                        //     // enabledBorder: UnderlineInputBorder(
                        //     //   borderSide: BorderSide(
                        //     //       color: focusNode.hasFocus
                        //     //           ? Colors.transparent
                        //     //           : const Color(0xff999999)),
                        //     // ),
                        //     // focusedBorder: const UnderlineInputBorder(
                        //     //   borderSide: BorderSide(color: Color(0xff666666)),
                        //     // ),
                        //   ),
                        //   onChanged: (v) {
                        //     changepassword.validateChangePassword();
                        //     changepassword.activateChangePass();
                        //   },
                        // ),

                        // Container(
                        //     height: 1,
                        //     color: focusNode.hasFocus
                        //         ? Colors.black
                        //         : const Color(0xff666666)),
                        // const SizedBox(height: 5),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     changepassword.userIdChangepassError != null
                        //         ? TextWidget.captionText(
                        //             text: "${changepassword.userIdChangepassError}",
                        //             theme: false,
                        //             color: colors.kColorRedText,
                        //             fw: 0)
                        //         : const SizedBox(),
                        //     Text(
                        //       "${changepassword.userIdController.text.length}/10",
                        //       style: textStyle(Colors.black, 10, FontWeight.w500),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 20),
                        // Text(
                        //  widget.isChangePass == "Yes"
                        //       ? "Old Password"
                        //       : "Generated Password",
                        //     style: textStyle(
                        //         theme.isDarkMode
                        //             ? colors.colorWhite
                        //             : colors.colorBlack,
                        //         14,
                        //         FontWeight.w600)),
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
                            fillColor: const Color(0xffFFFFFF),
                            labelText: widget.isChangePass == "Yes"
                                ? "Old Password"
                                : "Generated Password",
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                            // errorStyle: textStyle(
                            //     colors.kColorRedText, 10, FontWeight.w500),
                            // errorText: changepassword.oldPasswordError,
                            // prefixIconConstraints:
                            //     const BoxConstraints(minHeight: 0, minWidth: 0),
                            // prefixIcon: Container(
                            //   margin: const EdgeInsets.only(right: 15),
                            //   child: SvgPicture.asset(
                            //     "assets/icon/key-01.svg",
                            //     color: const Color(0xff666666),
                            //     width: 22,
                            //     fit: BoxFit.scaleDown,
                            //   ),
                            // ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 14),
                            suffixIconConstraints:
                                const BoxConstraints(minHeight: 0, minWidth: 0),
                            suffixIcon: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: Colors.black.withOpacity(0.15),
                                highlightColor: Colors.black.withOpacity(0.08),
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
                                    color: const Color(0xff999999),
                                    width: 22,
                                  ),
                                ),
                              ),
                            ),
                            // hintText: widget.isChangePass == "Yes"
                            //     ? "Enter Old Password"
                            //     : "Enter Generated Password",
                            // enabledBorder: UnderlineInputBorder(
                            //   borderSide: BorderSide(
                            //       color: focusNode1.hasFocus
                            //           ? Colors.transparent
                            //           : const Color(0xff999999)),
                            // ),
                            // focusedBorder: const UnderlineInputBorder(
                            //   borderSide: BorderSide(color: Color(0xff666666)),
                            // ),
                          ),
                          onChanged: (v) {
                            changepassword.validateOldPassword();
                            changepassword.activateChangePass();
                          },
                        ),
                        const SizedBox(height: 5),
                        changepassword.oldPasswordError != null
                            ? TextWidget.captionText(
                                text: "${changepassword.oldPasswordError}",
                                theme: false,
                                color: colors.kColorRedText,
                                fw: 0)
                            : const SizedBox(),
                        const SizedBox(height: 20),
                        // Text("New Password",
                        //     style: textStyle(
                        //         theme.isDarkMode
                        //             ? colors.colorWhite
                        //             : colors.colorBlack,
                        //         14,
                        //         FontWeight.w600)),
                        TextFormField(
                          focusNode: focusNode2,
                          style: TextWidget.textStyle(
                            fontSize: 16,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            // fw: 3,
                            height: 1.3,
                          ),
                          readOnly: changepassword.loading ? true : false,
                          obscureText: changepassword.hidenewpassword,
                          controller: changepassword.newPassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xffFFFFFF),
                            labelText: "New Password",
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            labelStyle: TextWidget.textStyle(
                              fontSize: 16,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              // fw: 3,
                              height: 1.3,
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
                                  color: Color(0xffECEDEE), width: 1.5),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffECEDEE), width: 1.5),
                            ),
                            counterText: "",
                            // errorStyle: textStyle(
                            //     colors.kColorRedText, 10, FontWeight.w500),
                            // errorText: changepassword.newPasswordError,
                            // prefixIconConstraints:
                            //     const BoxConstraints(minHeight: 0, minWidth: 0),
                            // prefixIcon: Container(
                            //   margin: const EdgeInsets.only(right: 15),
                            //   child: SvgPicture.asset(
                            //     "assets/icon/key-01.svg",
                            //     color: const Color(0xff666666),
                            //     width: 22,
                            //     fit: BoxFit.scaleDown,
                            //   ),
                            // ),
                            suffixIconConstraints:
                                const BoxConstraints(minHeight: 0, minWidth: 0),
                            suffixIcon: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: Colors.black.withOpacity(0.15),
                                highlightColor: Colors.black.withOpacity(0.08),
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
                                    color: const Color(0xff999999),
                                    width: 22,
                                  ),
                                ),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 14),

                            // hintText: "Enter New Password",
                            // enabledBorder: UnderlineInputBorder(
                            //   borderSide: BorderSide(
                            //       color: focusNode2.hasFocus
                            //           ? Colors.transparent
                            //           : const Color(0xff999999)),
                            // ),
                            // focusedBorder: const UnderlineInputBorder(
                            //   borderSide: BorderSide(color: Color(0xff666666)),
                            // ),
                          ),
                          onChanged: (v) {
                            changepassword.validateNewPassword();
                            changepassword.activateChangePass();
                          },
                        ),
                        const SizedBox(height: 5),
                        changepassword.newPasswordError != null
                            ? TextWidget.captionText(
                                text: "${changepassword.newPasswordError}",
                                theme: false,
                                color: colors.kColorRedText,
                                fw: 0)
                            : const SizedBox(),
                        const SizedBox(height: 30),
                        SizedBox(
                            width: screenWidth,
                            height: 44,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: !theme.isDarkMode
                                          ? changepassword.isDisableChangepassbtn
                                              ? const Color(0xff0037B7)
                                                  .withOpacity(0.3)
                                              : const Color(0xff0037B7)
                                          : changepassword.isDisableChangepassbtn
                                              ? colors.darkGrey
                                              : colors.colorbluegrey,
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      )),
                                  onPressed: changepassword
                                              .userIdController.text.isEmpty ||
                                          changepassword
                                              .oldPassword.text.isEmpty ||
                                          changepassword
                                              .newPassword.text.isEmpty ||
                                          changepassword.loading
                                      ? () {
                                          changepassword.validateOldPassword();
                                          changepassword.validateNewPassword();
                                        }
                                      : () {
                                          changepassword
                                              .submitChangePass(context);
                                        },
                                  child: changepassword.loading
                                      ? SizedBox(
                                          width: 18,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colors.colorWhite),
                                        )
                                      : TextWidget.subText(
                                          text: "Set New Password",
                                          theme: false,
                                          color: !theme.isDarkMode
                                              ? changepassword
                                                      .isDisableChangepassbtn
                                                  ? const Color(0xffFFFFFF)
                                                  : const Color(0xffFFFFFF)
                                              : changepassword
                                                      .isDisableChangepassbtn
                                                  ? colors.darkGrey
                                                  : colors.colorBlack,
                                          fw: 2)),
                            )),
                        // const SizedBox(height: 50),
                        // const Padding(
                        //   padding: EdgeInsets.all(12.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       ListWidgets(text: "Password atleast 7 character."),
                        //       SizedBox(height: 8),
                        //       ListWidgets(text: "Have at least one digit."),
                        //       SizedBox(height: 8),
                        //       ListWidgets(
                        //           text: "Have at least one uppercase,lowercase."),
                        //       SizedBox(height: 8),
                        //       ListWidgets(
                        //           text:
                        //               "Have atleast one special character amoung #'/ \$-*@."),
                        //     ],
                        //   ),
                        // )
                      ]),
                ),
              ],
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

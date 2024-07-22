import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';  
import '../../../provider/change_password_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cus_list_widget.dart';
import '../../../sharedWidget/custom_text_form_field.dart'; 

class ChangePass extends ConsumerWidget {
  final String isChangePass;
  const ChangePass({super.key, required this.isChangePass});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    double screenWidth = MediaQuery.of(context).size.width;
    final changepassword = watch(changePasswordProvider);
    // final loginAuth = watch(authProvider);
    final theme = watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
              changepassword.changePassMethod();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: SvgPicture.asset(assets.backArrow,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
            ),
          ),
          title: Text("Change Password",
              style: textStyles.appBarTitleTxt.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ))),
      body: SingleChildScrollView(
        reverse: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Client ID",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly:   true,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [UpperCaseTextFormatter()],
                      style: textStyles.textFieldLabelStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack),
                      controller: changepassword.userIdController,
                      decoration: InputDecoration(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xfff5f5f5),
                        filled: true,
                        errorStyle: textStyle(
                            colors.kColorRedText, 10, FontWeight.w500),
                        errorText: changepassword.userIdChangepassError,
                        prefixIconConstraints:
                            const BoxConstraints(minHeight: 0, minWidth: 0),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: SvgPicture.asset(
                            "assets/keyboardicons/keyboard_profile.svg",
                            color: const Color(0xff666666),
                            width: 22,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(top: 5),
                        hintStyle: textStyle(Colors.grey, 13, FontWeight.w400),
                        hintText: "Enter client Id to begin",
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff999999)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666666)),
                        ),
                      ),
                      onChanged: (v) {
                        changepassword.validateChangePassword();
                        changepassword.activateChangePass();
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                        isChangePass == "Yes"
                            ? "Old Password"
                            : "Generated Password",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    TextFormField(
                      style: textStyles.textFieldLabelStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack),
                      obscureText: changepassword.hideoldpassword,
                      controller: changepassword.oldPassword,
                      decoration: InputDecoration(
                        errorStyle: textStyle(
                            colors.kColorRedText, 10, FontWeight.w500),
                        errorText: changepassword.oldPasswordError,
                        prefixIconConstraints:
                            const BoxConstraints(minHeight: 0, minWidth: 0),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: SvgPicture.asset(
                            "assets/icon/key-01.svg",
                            color: const Color(0xff666666),
                            width: 22,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(top: 12),
                        suffixIconConstraints:
                            const BoxConstraints(minHeight: 0, minWidth: 0),
                        suffixIcon: InkWell(
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
                        hintStyle: textStyle(Colors.grey, 13, FontWeight.w400),
                        hintText: isChangePass == "Yes"
                            ? "Enter Old Password to begin"
                            : "Enter Generated Password to begin",
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff999999)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666666)),
                        ),
                      ),
                      onChanged: (v) {
                        changepassword.validateChangePassword();
                        changepassword.activateChangePass();
                      },
                    ),
                    const SizedBox(height: 20),
                    Text("New Password",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                    TextFormField(
                      style: textStyles.textFieldLabelStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack),
                      obscureText: changepassword.hidenewpassword,
                      controller: changepassword.newPassword,
                      decoration: InputDecoration(
                        errorStyle: textStyle(
                            colors.kColorRedText, 10, FontWeight.w500),
                        errorText: changepassword.newPasswordError,
                        prefixIconConstraints:
                            const BoxConstraints(minHeight: 0, minWidth: 0),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: SvgPicture.asset(
                            "assets/icon/key-01.svg",
                            color: const Color(0xff666666),
                            width: 22,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        suffixIconConstraints:
                            const BoxConstraints(minHeight: 0, minWidth: 0),
                        suffixIcon: InkWell(
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
                        contentPadding: const EdgeInsets.only(top: 12),
                        hintStyle: textStyle(Colors.grey, 13, FontWeight.w400),
                        hintText: "Enter New Password to begin",
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff999999)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666666)),
                        ),
                      ),
                      onChanged: (v) {
                        changepassword.validateChangePassword();
                        changepassword.activateChangePass();
                      },
                    ),
                    const SizedBox(height: 30),


                     SizedBox(
                                        width: screenWidth,
                                        height: 44,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: !theme.isDarkMode
                                ? changepassword.isDisableChangepassbtn
                                    ? const Color(0xfff5f5f5)
                                    : colors.colorBlack
                                : changepassword.isDisableChangepassbtn
                                    ? colors.darkGrey
                                    : colors.colorbluegrey,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 13),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              )),
                                          onPressed: changepassword.userIdController.text.isEmpty ||
                                    changepassword.oldPassword.text.isEmpty ||
                                    changepassword.newPassword.text.isEmpty
                                              ? () {}
                                              : () {
                                                  changepassword.submitChangePass(context);
                                                },
                                          child:  changepassword.loading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Color(
                                                              0xff666666)),
                                                )
                                              : Text("Continue",
                                                  style: textStyle(
                                                       !theme.isDarkMode
                                          ? changepassword.isDisableChangepassbtn
                                              ? const Color(0xff999999)
                                              : colors.colorWhite
                                          : changepassword.isDisableChangepassbtn
                                              ? colors.darkGrey
                                              : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500))
                                        )
                                      ),
                   
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListWidgets(text: "Password atleast 7 character."),
                          SizedBox(height: 8),
                          ListWidgets(text: "Have at least one digit."),
                          SizedBox(height: 8),
                          ListWidgets(
                              text: "Have at least one uppercase,lowercase."),
                          SizedBox(height: 8),
                          ListWidgets(
                              text:
                                  "Have atleast one special character amoung #'/ \$-*@."),
                        ],
                      ),
                    )
                  ]),
            ),
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

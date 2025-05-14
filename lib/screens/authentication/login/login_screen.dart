import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/version_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/splash_loader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _showPassword = false;
  
  @override
  void initState() {
    context.read(versionProvider).checkVersion(context);
    context.read(authProvider).setChangetotp(true);
    _checkBiometricAvailability();
    
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    
    _animationController.forward();
    super.initState();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkBiometricAvailability() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException catch (_) {
      _canCheckBiometrics = false;
    }
    setState(() {});
  }
  
  Future<void> _authenticateWithBiometrics(AuthProvider auth) async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login to your account',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (authenticated && auth.loginMethCtrl.text.isNotEmpty) {
        // If user is authenticated and a previous login ID exists, proceed with login
        auth.submitLogin(context, false);
      }
    } on PlatformException catch (_) {
      // Handle authentication errors
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Preferences pref = Preferences();
    return Consumer(builder: ((context, ScopedReader watch, _) {
      final auth = watch(authProvider);
      final forpass = watch(changePasswordProvider);
      final theme = watch(themeProvider);
      final ledgerprovider = context.read(ledgerProvider);

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: auth.initLoad
            ? PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;
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
                        Navigator.pushNamedAndRemoveUntil(context,
                            Routes.loginScreenBanner, (route) => false);
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
                body: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SingleChildScrollView(
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
                                                  ? "Welcome Back"
                                                  : "Login",
                                              style:
                                                  textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      24,
                                                      FontWeight.w900)),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                              pref.clientName!.isNotEmpty &&
                                                      pref.islogOut!
                                                  ? pref.clientName!
                                                  : "Every login brings you closer to your financial goals.",
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  textStyle(
                                                      const Color(0xff666666),
                                                      14,
                                                      FontWeight.w500)),
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          Text("Mobile / Client ID",
                                              style:
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
                                                        pref.clientMob!
                                                            .isNotEmpty)
                                                ? true
                                                : false,
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
                                                      (pref.clientId!
                                                              .isNotEmpty ||
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
                                                ),
                                              ),
                                              suffix: pref.islogOut! &&
                                                      (pref.clientId!
                                                              .isNotEmpty ||
                                                          pref.clientMob!
                                                              .isNotEmpty)
                                                  ? InkWell(
                                                      onTap: () async {
                                                        {
                                                          pref.setLogout(false);
                                                          pref.setHideLoginOptBtn(
                                                              true);
                                                          await auth
                                                              .loginMethod();
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                        }
                                                      },
                                                      child: Text("Switch Account",
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
                                              hintStyle: textStyle(Colors.grey,
                                                  13, FontWeight.w400),
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
                                                  textStyle(colors.kColorRedText,
                                                      10, FontWeight.w500),
                                            ),
                                          ],
                                          const SizedBox(height: 18),
                                          Text("Password",
                                              style:
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
                                                    setState(() {
                                                      _showPassword = !_showPassword;
                                                    });
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
                                                        color: const Color(
                                                            0xff999999),
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
                                                    color:
                                                        const Color(0xff666666),
                                                  )),
                                              contentPadding:
                                                  const EdgeInsets.only(top: 10),
                                              hintStyle: textStyle(Colors.grey,
                                                  13, FontWeight.w400),
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
                                                  textStyle(colors.kColorRedText,
                                                      10, FontWeight.w500),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              
                                              InkWell(
                                                  onTap: () {
                                                    forpass.clearError();
                                                    forpass.clearTextField();
                                                    Navigator.pushNamed(context,
                                                        Routes.forgotPass);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 4),
                                                    child: Text(
                                                        "Forgot password?",
                                                        style:
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
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                              ? null
                              : () {
                                  HapticFeedback.mediumImpact();
                                  SystemSound.play(SystemSoundType.click);
                                  auth.optError = "";
                                  auth.submitLogin(context, false);
                                  ledgerprovider.setterfornullallSwitch = null;
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
                          margin: const EdgeInsets.only(bottom: 23),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Version 3.0.2",
                              textAlign: TextAlign.center,
                              style: textStyle(
                                  const Color(0xff666666), 10, FontWeight.w300))),
                    ],
                  ),
                ),
              ),
      );
    }));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

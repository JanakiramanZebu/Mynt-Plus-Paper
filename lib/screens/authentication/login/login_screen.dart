import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../locator/preference.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/change_password_provider.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/version_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/splash_loader.dart';
import '../../../utils/no_emoji_inputformatter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isProcessing = false;
  late FocusNode focusNode;
  late FocusNode focusNode1;

  @override
  void initState() {
    ref.read(versionProvider).checkVersion(context);
    ref.read(authProvider).setChangetotp(true);
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
    focusNode1 = FocusNode();
    focusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    focusNode1.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final auth = ref.read(authProvider);
    final ledgerprovider = ref.read(ledgerProvider);
    auth.validateLogin();
    auth.validatePass();

    if (_isProcessing ||
        auth.loginMethCtrl.text.isEmpty ||
        auth.passCtrl.text.isEmpty) return;
    if (auth.loginMethError != "" || auth.passError != "") return;

    setState(() => _isProcessing = true);

    try {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);

      auth.optError = "";
      await auth.submitLogin(context, false);
      ledgerprovider.setterfornullallSwitch = null;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleBackNavigation(BuildContext context, Preferences pref,
      AuthProvider auth, UserProfileProvider userProfile, WidgetRef ref) async {
    final theme = ref.watch(themeProvider);
    if (pref.islogOut! ||
        auth.switchback == true &&
            (pref.clientId!.isEmpty ||
                pref.clientId!.isNotEmpty ||
                pref.clientMob!.isEmpty ||
                pref.clientMob!.isNotEmpty)) {
      // This path is for logged out users with saved credentials
      theme.removeUsermatrial(context);
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.loginScreenBanner, (route) => false);
    } else {
      // This path is for when we need to switch between accounts
      // Note: Previous issue was caused by inconsistent navigation stack between app bar back button
      // and system back button in the OTP screen
      int activeIndex = auth.loggedMobile
          .indexWhere((element) => element.clientId == pref.clientId);
      if (activeIndex == -1) return;

      // Show loading indicator
      userProfile.profilePageloader(true);

      try {
        // Set client information
        await pref.setClientId(auth.loggedMobile[activeIndex].clientId);
        await pref.setClientMob(auth.loggedMobile[activeIndex].mobile);
        await pref.setClientSession(auth.loggedMobile[activeIndex].sesstion);
        await pref.setClientName(auth.loggedMobile[activeIndex].userName);
        await pref.setImei(auth.loggedMobile[activeIndex].imei);
        await pref.setMobileLogin(true);

        // Fetch account data
        await ref.read(authProvider).fetchMobileLogin(
            context,
            "",
            auth.loggedMobile[activeIndex].clientId,
            "switchAc",
            auth.loggedMobile[activeIndex].imei,
            true);

        // Reset and restart websocket connection
        ref.read(websocketProvider).closeSocket(true);
        ref.read(websocketProvider).changeconnectioncount();

        // Navigate to profile tab
        ref.read(indexListProvider).bottomMenu(4, context);

        // Wait for a short time to ensure data is loaded
        await Future.delayed(const Duration(milliseconds: 200));

        // Remove loading indicator after everything is done
        if (context.mounted) {
          userProfile.profilePageloader(false);
        }
      } catch (e) {
        // Handle any errors during the process
        print("Error restoring user data: $e");
        if (context.mounted) {
          userProfile.profilePageloader(false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Preferences pref = Preferences();
    return Consumer(builder: ((context, WidgetRef ref, _) {
      final auth = ref.watch(authProvider);
      final forpass = ref.watch(changePasswordProvider);
      final theme = ref.watch(themeProvider);
      final ledgerprovider = ref.read(ledgerProvider);
      final portfolio = ref.watch(portfolioProvider);
      final orders = ref.watch(orderProvider);
      final userProfile = ref.watch(userProfileProvider);

      return GestureDetector(
        onTap: () {
          //theme.removeUsermatrial(context);
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
                    child: const CircularLoaderImage()))
            : PopScope(
                canPop: false,
                // pref.islogOut! &&
                //               (pref.clientId!.isNotEmpty ||
                //                   pref.clientMob!.isNotEmpty) ? false : true,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;
                  await _handleBackNavigation(
                      context, pref, auth, userProfile, ref);
                },
                child: Scaffold(
                  appBar: AppBar(
                    forceMaterialTransparency: true,
                    backgroundColor: theme.isDarkMode
                        ? const Color(0xff000000)
                        : const Color(0xffFFFFFF),
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
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          onTap: () async {
                            await _handleBackNavigation(
                                context, pref, auth, userProfile, ref);
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
                    // title: TextWidget.headText(
                    //     text: pref.clientName!.isNotEmpty && pref.islogOut!
                    //         ? "Welcome"
                    //         : "Login",
                    //     theme: false,
                    //     color: theme.isDarkMode
                    //         ? colors.colorWhite
                    //         : const Color(0xFF141414),
                    //     fw: 2),
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
                        child: SingleChildScrollView(
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
                                      pref.islogOut! &&
                                              (pref.clientId!.isNotEmpty ||
                                                  pref.clientMob!.isNotEmpty)
                                          ? SizedBox.shrink()
                                          : Column(
                                              children: [
                                                const SizedBox(height: 30),
                                                TextWidget.custmText(
                                                    text: "Sign in with MYNT",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 1,
                                                    fs: 20),
                                              ],
                                            ),
                                      const SizedBox(height: 8),
                                      if (pref.islogOut! &&
                                          (pref.clientId!.isNotEmpty ||
                                              pref.clientMob!.isNotEmpty)) ...[
                                        // const SizedBox(height: 24),
                                        Center(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                          .withOpacity(0.1)
                                                      : const Color(
                                                          0xFFF1F3F8), // light gray background
                                                  border: Border.all(
                                                    color: Color(
                                                        0xFF0037B7), // blue border
                                                    width:
                                                        1.5, // adjust thickness to match the image
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    pref.clientName!.isNotEmpty
                                                        ? pref.clientName!
                                                            .split(' ')
                                                            .map((e) => e[0])
                                                            .take(2)
                                                            .join('')
                                                        : '',
                                                    style: TextWidget.textStyle(
                                                        fontSize: 24,
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : const Color(
                                                                0xff0037B7),
                                                        theme: theme.isDarkMode,
                                                        fw: 2),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              TextWidget.custmText(
                                                text: pref.clientName ?? '',
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 2,
                                                fs: 20,
                                              ),
                                              const SizedBox(height: 6),
                                              TextWidget.custmText(
                                                text: pref.clientId ?? '',
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 1,
                                                fs: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                      ],
                                      // const SizedBox(
                                      //   height: 15,
                                      // ),
                                      // Text("Mobile / Client ID",
                                      //     style:
                                      //         // TextStyle(
                                      //         //   fontFamily: 'InterVariable',
                                      //         //   fontSize: 17,
                                      //         //   fontWeight: FontWeight.w600,
                                      //         // )
                                      //         textStyle(
                                      // theme.isDarkMode
                                      //     ? colors.colorWhite
                                      //     : colors.colorBlack,
                                      //             17,
                                      //             FontWeight.w600)),

                                      pref.islogOut! &&
                                              (pref.clientId!.isNotEmpty ||
                                                  pref.clientMob!.isNotEmpty)
                                          ? SizedBox.shrink()
                                          : Column(
                                              children: [
                                                const SizedBox(height: 18),
                                                if (pref.clientName!
                                                        .isNotEmpty &&
                                                    pref.islogOut!)
                                                  const SizedBox(height: 8),
                                                TextFormField(
                                                  controller:
                                                      auth.loginMethCtrl,
                                                  focusNode: focusNode,
                                                  readOnly: pref.islogOut! &&
                                                          (pref.clientId!
                                                                  .isNotEmpty ||
                                                              pref.clientMob!
                                                                  .isNotEmpty) ||
                                                      (_isProcessing ||
                                                          auth.loading),
                                                  maxLength: 10,
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .characters,
                                                  inputFormatters: [
                                                    UpperCaseTextFormatter(),
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'[a-zA-Z0-9]')),
                                                  ],
                                                  style: TextWidget.textStyle(
                                                    fontSize: 16,
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,

                                                    // height: 1.5,
                                                  ),
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: pref.islogOut! &&
                                                            (pref.clientId!
                                                                    .isNotEmpty ||
                                                                pref.clientMob!
                                                                    .isNotEmpty)
                                                        ? theme.isDarkMode
                                                            ? colors.colorBlack
                                                            : const Color(
                                                                0xffEDEDED)
                                                        : !theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack,
                                                    labelText: pref.islogOut! &&
                                                            (pref.clientId!
                                                                    .isNotEmpty ||
                                                                pref.clientMob!
                                                                    .isNotEmpty)
                                                        ? null
                                                        : "Mobile / Client ID",
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .auto,
                                                    labelStyle:
                                                        TextWidget.textStyle(
                                                      fontSize: 14,
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      fw: 3,
                                                    ),
                                                    floatingLabelStyle:
                                                        TextWidget.textStyle(
                                                            fontSize: 16,
                                                            theme: theme
                                                                .isDarkMode,
                                                            color: theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            fw: 3),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                                  .withOpacity(
                                                                      0.2)
                                                              : Color(
                                                                  0xffDBDBDB),
                                                          width: 1),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                                  .withOpacity(
                                                                      0.2)
                                                              : Color(
                                                                  0xffDBDBDB),
                                                          width: 1),
                                                    ),
                                                    counterText: "",
                                                    contentPadding: pref
                                                                .islogOut! &&
                                                            (pref.clientId!
                                                                    .isNotEmpty ||
                                                                pref.clientMob!
                                                                    .isNotEmpty)
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5,
                                                            vertical: 18)
                                                        : const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5,
                                                            vertical: 12),
                                                  ),
                                                  onTap: pref.isMobileLogin!
                                                      ? auth.getCurrentPhone
                                                      : null,
                                                  onChanged: (v) {
                                                    auth.validateLogin();
                                                    auth.activeBtnLogin();
                                                  },
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    auth.loginMethError != null
                                                        ? TextWidget.captionText(
                                                            text:
                                                                "${auth.loginMethError}",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .lossDark
                                                                : colors
                                                                    .lossLight,
                                                            fw: 0)
                                                        : const SizedBox(),
                                                    TextWidget.captionText(
                                                        text:
                                                            "${auth.loginMethCtrl.text.length}/10",
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        theme: theme.isDarkMode,
                                                        fw: 0),
                                                  ],
                                                ),
                                              ],
                                            ),
                                      const SizedBox(height: 10),
                                      // Text("Password",
                                      //     style:
                                      //         // TextStyle(
                                      //         //   fontFamily: 'InterVariable',
                                      //         //   fontSize: 17,
                                      //         //   fontWeight: FontWeight.w600,
                                      //         // )
                                      //         textStyle(
                                      //             theme.isDarkMode
                                      //                 ? colors.colorWhite
                                      //                 : colors.colorBlack,
                                      //             17,
                                      //             FontWeight.w600)),

                                      TextFormField(
                                        controller: auth.passCtrl,
                                        focusNode: focusNode1,
                                        obscureText: auth.hidePass,
                                        readOnly:
                                            (_isProcessing || auth.loading)
                                                ? true
                                                : false,
                                        textAlign: TextAlign.start,
                                        style: TextWidget.textStyle(
                                          fontSize: 16,
                                          theme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "Password",
                                          filled: true,
                                          fillColor: theme.isDarkMode
                                              ? colors.colorBlack
                                              : const Color(0xFFFFFFFF),
                                          labelStyle: TextWidget.textStyle(
                                              fontSize: 14,
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              fw: 3),
                                          floatingLabelStyle:
                                              TextWidget.textStyle(
                                                  fontSize: 16,
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  fw: 3),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.auto,
                                          counterText: '',
                                          suffixIconConstraints:
                                              const BoxConstraints(
                                                  minHeight: 0, minWidth: 0),
                                          suffixIcon: Material(
                                            color: Colors.transparent,
                                            shape: const CircleBorder(),
                                            clipBehavior: Clip.hardEdge,
                                            child: InkWell(
                                              customBorder:
                                                  const CircleBorder(),
                                              splashColor: Colors.black
                                                  .withOpacity(0.15),
                                              highlightColor: Colors.black
                                                  .withOpacity(0.08),
                                              onTap: auth.hiddenPass,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                child: SvgPicture.asset(
                                                  auth.hidePass
                                                      ? "assets/icon/eye-off.svg"
                                                      : "assets/icon/eye.svg",
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                                  width: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                        .withOpacity(0.2)
                                                    : Color(0xffDBDBDB),
                                                width: 1),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                        .withOpacity(0.2)
                                                    : Color(0xffDBDBDB),
                                                width: 1),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 12),
                                          hintStyle: TextWidget.textStyle(
                                              fontSize: 12,
                                              theme: theme.isDarkMode,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              fw: 3),
                                        ),
                                        inputFormatters: [
                                          NoEmojiInputFormatter(),
                                          FilteringTextInputFormatter.deny(
                                              RegExp('[π£•₹€℅™∆√¶/,]')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s')),
                                        ],
                                        onChanged: (v) {
                                          auth.validatePass();
                                          auth.activeBtnLogin();
                                        },
                                      ),

                                      // Container(
                                      //     height: 1,
                                      //     color: focusNode1.hasFocus
                                      //         ? Colors.black
                                      //         : const Color(0xff666666)),
                                      const SizedBox(height: 5),
                                      if (auth.passError != null) ...[
                                        TextWidget.captionText(
                                            text: "${auth.passError}",
                                            theme: false,
                                            color: theme.isDarkMode
                                                ? colors.lossDark
                                                : colors.lossLight,
                                            fw: 0)
                                      ],
                                    ]),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                width: screenWidth,
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: auth.isDisableBtn &&
                                              (auth.loginMethCtrl.text
                                                      .isEmpty ||
                                                  auth.passCtrl.text.isEmpty)
                                          ? theme.isDarkMode
                                              ? colors.primaryDark
                                                  .withOpacity(0.5)
                                              : colors.primaryLight
                                                  .withOpacity(0.5)
                                          : theme.isDarkMode
                                              ? colors.primaryDark
                                              : colors.primaryLight,
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      )),
                                  onPressed: () {
                                    _handleContinue();
                                  },
                                  child: (_isProcessing || auth.loading)
                                      ? SizedBox(
                                          width: 18,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colors.colorWhite),
                                        )
                                      : TextWidget.titleText(
                                          text: "Login",
                                          theme: false,
                                          color: !theme.isDarkMode
                                              ? auth.isDisableBtn
                                                  ? colors.colorWhite
                                                      .withOpacity(0.5)
                                                  : colors.colorWhite
                                              : auth.isDisableBtn
                                                  ? colors.colorWhite
                                                      .withOpacity(0.5)
                                                  : colors.colorWhite,
                                          fw: 2),
                                ),
                              ),
                              const SizedBox(height: 17),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // if (pref.hideLoginOptBtn!)
                                    pref.islogOut! &&
                                            (pref.clientId!.isNotEmpty ||
                                                pref.clientMob!.isNotEmpty)
                                        ? Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              // borderRadius: BorderRadius.circular(8),
                                              splashColor: theme.isDarkMode
                                                  ? Colors.white
                                                      .withOpacity(0.15)
                                                  : Colors.black
                                                      .withOpacity(0.15),
                                              highlightColor: theme.isDarkMode
                                                  ? Colors.white
                                                      .withOpacity(0.08)
                                                  : Colors.black
                                                      .withOpacity(0.08),
                                              onTap: () async {
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 150));
                                                pref.setLogout(false);
                                                pref.setHideLoginOptBtn(true);
                                                await auth.loginMethod();
                                                FocusScope.of(context)
                                                    .unfocus();
                                                auth.switchbackbutton(true);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                child: TextWidget.subText(
                                                    text: "Switch account",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          // borderRadius: BorderRadius.circular(8),
                                          splashColor: theme.isDarkMode
                                              ? Colors.white.withOpacity(0.15)
                                              : Colors.black.withOpacity(0.15),
                                          highlightColor: theme.isDarkMode
                                              ? Colors.white.withOpacity(0.08)
                                              : Colors.black.withOpacity(0.08),
                                          onTap: _isProcessing || auth.loading
                                              ? null
                                              : () async {
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 150));
                                                  forpass.clearError();
                                                  forpass.clearTextField();
                                                  Navigator.pushNamed(context,
                                                      Routes.forgotPass);
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            child: TextWidget.subText(
                                                text: "Forgot password?",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Container(
                      //     margin: const EdgeInsets.only(bottom: 23, top: 10),
                      //     padding: const EdgeInsets.symmetric(horizontal: 16),
                      //     child: Text("Version 3.0.2",
                      //         textAlign: TextAlign.center,
                      //         style: textStyle(const Color(0xff666666), 10,
                      //             FontWeight.w300))),
                      //const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      );
    }));
  }
}

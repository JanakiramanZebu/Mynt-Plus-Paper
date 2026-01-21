import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/sharedWidget/custom_text_form_field.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../../locator/preference.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/change_password_provider.dart';
import '../../../../provider/index_list_provider.dart';
import '../../../../provider/ledger_provider.dart';


import '../../../../provider/thems.dart';
import '../../../../provider/user_profile_provider.dart';
import '../../../../provider/version_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/splash_loader.dart';
import '../../../../utils/no_emoji_inputformatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';


class LoginScreenWeb extends ConsumerStatefulWidget {
  const LoginScreenWeb({super.key});

  @override
  ConsumerState<LoginScreenWeb> createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends ConsumerState<LoginScreenWeb> {
  bool _isProcessing = false;
  late FocusNode focusNode;
  late FocusNode focusNode1;
  bool _showForgotPassword = false;
  bool _showOtpScreen = false;
  
  // OTP Timer Logic
  Timer? _timer;
  int _start = 89;
  String resendTime = "01.29";

  void startTimer() {
    _timer?.cancel();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_start == 0) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _timer = null;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _start--;
              resendTime = formattedTime(timeInSecond: _start);
            });
          }
        }
      },
    );
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
    focusNode1 = FocusNode();
    focusNode1.addListener(_onFocusChange);
    
    // Defer context-dependent operations to avoid holding context reference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(versionProvider).checkVersion(context);
        ref.read(authProvider).setChangetotp(true);
      }
    });
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {}); // Rebuild when focus changes
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    focusNode.removeListener(_onFocusChange);
    focusNode1.removeListener(_onFocusChange);
    focusNode.dispose();
    focusNode1.dispose();
    _timer?.cancel();
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
      
      // Pass preventNavigation: true so we can handle the UI switch locally
      await auth.submitLogin(context, false, preventNavigation: true);
      
      // If the API call was successful and we have a mobile login response that indicates success/OTP sent
      if (auth.mobileLogin != null && 
          auth.mobileLogin!.stat == "Ok" && 
          (auth.mobileLogin!.msg == "otp sended" || 
           auth.mobileLogin!.msg == "otp sended, already logged in another device" ||
           // If TOTP is enabled, msg might differ or be null, but stat is Ok
           (auth.totp && (auth.mobileLogin!.msg != null || auth.mobileLogin!.msg == null)))) {
            
        if (mounted) {
           setState(() {
             _showOtpScreen = true;
             _start = 89;
             resendTime = "01.29";
           });
           startTimer();
        }
      }
      
      ledgerprovider.setterfornullallSwitch = null;
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleBackNavigation(BuildContext context, Preferences pref,
      AuthProvider auth, UserProfileProvider userProfile, WidgetRef ref) async {
    if (!mounted) return;
    
    final theme = ref.watch(themeProvider);
    if (pref.islogOut! ||
        auth.switchback == true &&
            (pref.clientId!.isEmpty ||
                pref.clientId!.isNotEmpty ||
                pref.clientMob!.isEmpty ||
                pref.clientMob!.isNotEmpty)) {
      // This path is for logged out users with saved credentials
      if (mounted) {
        theme.removeUsermatrial(context);
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.loginScreenBanner, (route) => false);
      }
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

        // Calendar PnL cache cleared automatically when switching accounts
        ref.read(ledgerProvider).clearCalendarPnLData();

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
        if (mounted && context.mounted) {
          userProfile.profilePageloader(false);
        }
      } catch (e) {
        // Handle any errors during the process
        print("Error restoring user data: $e");
        if (mounted && context.mounted) {
          userProfile.profilePageloader(false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Preferences pref = Preferences();
    return Consumer(builder: ((context, WidgetRef ref, _) {
      final auth = ref.watch(authProvider);
      final forpass = ref.watch(changePasswordProvider);
      final theme = ref.watch(themeProvider);
      final userProfile = ref.watch(userProfileProvider);

      if (auth.initLoad) {
        return Scaffold(
          backgroundColor:
              theme.isDarkMode ? MyntColors.searchBgDark : MyntColors.searchBg,
          body: const Center(child: CircularLoaderImage()),
        );
      }

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor:
              theme.isDarkMode ? MyntColors.searchBgDark : Colors.white,
          body: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: getResponsiveWidth(context),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? MyntColors.searchBgDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: theme.isDarkMode
                                ? MyntColors.dividerDark
                                : Colors.grey.shade300,
                            width: 0.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset(
                              assets.appLogoIcon,
                              width: 100,
                              height: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Welcome Text
                          Text(
                            "Welcome to Zebu",
                            style: MyntWebTextStyles.titlesub(
                              
                              context,
                              color: MyntColors.textSecondary,
                              darkColor: MyntColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Main Heading
                          Text(
                            "Login to MYNT",
                            style: webText(
                              context,
                              size: 22,
                              weight: FontWeight.w900,
                              color: MyntColors.textPrimary,
                              darkColor: MyntColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form Fields
                          // Form Fields
                          // Form Fields
                          if (_showOtpScreen) ...[
                            // OTP Screen UI
                            
                            // Mobile / Client ID Display (Read Only)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mobile / Client ID",
                                    style: MyntWebTextStyles.caption(
                                        context,
                                        color: MyntColors.textSecondary,
                                        darkColor: MyntColors.textSecondaryDark
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        auth.loginMethCtrl.text,
                                        style: MyntWebTextStyles.title(
                                            context,
                                            fontWeight: MyntFonts.medium
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _showOtpScreen = false;
                                            _timer?.cancel();
                                          });
                                        },
                                        child: Text(
                                          "Change",
                                          style: MyntWebTextStyles.body(
                                              context,
                                              fontWeight: MyntFonts.bold,
                                              color: MyntColors.primary
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 1, color: MyntColors.divider),
                                ],
                            ),
                            
                            const SizedBox(height: 20),

                            // OTP Input Field
                            TextFormField(
                               controller: auth.otpCtrl,
                               // focusNode: focusNode, 
                               readOnly: _isProcessing || auth.loading,
                               maxLength: auth.totp ? 6 : 4,
                               keyboardType: TextInputType.number,
                               textInputAction: TextInputAction.done,
                               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                               style: MyntWebTextStyles.title(
                                 context,
                                 fontWeight: MyntFonts.medium,
                                 color: MyntColors.textPrimary,
                                 darkColor: MyntColors.textPrimaryDark,
                               ),
                               decoration: InputDecoration(
                                 filled: false,
                                 labelText: "Enter ${auth.totp ? '6' : '4'} digit ${auth.totp ? 'TOTP' : 'OTP'}",
                                 floatingLabelBehavior: FloatingLabelBehavior.auto,
                                 labelStyle: MyntWebTextStyles.head(
                                   context,
                                   fontWeight: MyntFonts.regular,
                                   color: MyntColors.textSecondary,
                                   darkColor: MyntColors.textSecondaryDark,
                                 ),
                                 enabledBorder: const UnderlineInputBorder(
                                   borderSide: BorderSide(
                                       color: MyntColors.divider, width: 1),
                                 ),
                                 focusedBorder: const UnderlineInputBorder(
                                   borderSide: BorderSide(
                                       color: MyntColors.primary, width: 1),
                                 ),
                                 counterText: "",
                                 contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                 // Timer / Resend Display inside decoration? Or separate? 
                                 // Layout request shows "Resend in 117" on the right. 
                                 
                                 suffix: (!auth.totp && _start > 0) 
                                     ? Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.end,
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                            Text("Resend", style: MyntWebTextStyles.caption(context, color: MyntColors.textSecondary)),
                                            Text("in $_start", style: MyntWebTextStyles.caption(context, color: MyntColors.textSecondary, fontWeight: FontWeight.bold)),
                                         ],
                                       )
                                     : (!auth.totp && _start == 0)
                                        ? InkWell(
                                            onTap: () async {
                                                if (!mounted) return;
                                                setState(() {
                                                  _start = 89;
                                                  startTimer();
                                                });
                                                auth.submitResendOtp(context);
                                            },
                                            child: Text("Resend OTP", style: MyntWebTextStyles.caption(context, color: MyntColors.primary, fontWeight: FontWeight.bold)),
                                          )
                                        : null
                               ),
                               onChanged: (v) {
                                  auth.validateOtp(v);
                                  auth.activeBtnOtp(v);
                                  
                                  // Auto-submit if length is sufficient
                                  if (!_isProcessing && !auth.loading) {
                                    if (auth.totp && v.length == 6) {
                                      auth.submitOtp(context, v);
                                    } else if (!auth.totp && v.length == 4) {
                                      auth.submitOtp(context, v);
                                    }
                                  }
                               },
                               onFieldSubmitted: (v) {
                                  auth.submitOtp(context, v);
                               },
                            ),
                            
                            const SizedBox(height: 5),
                            if (auth.optError != null && auth.optError!.isNotEmpty)
                              Text(
                                "${auth.optError}",
                                style: MyntWebTextStyles.para(
                                  context,
                                  color: (auth.optError!.contains("Verified") || auth.optError == "OTP Verified") 
                                     ? MyntColors.profit 
                                     : MyntColors.loss,
                                  darkColor: (auth.optError!.contains("Verified") || auth.optError == "OTP Verified") 
                                     ? MyntColors.profitDark 
                                     : MyntColors.lossDark,
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Continue Button (OTP Submit)
                            SizedBox(
                               height: 48,
                               child: ElevatedButton(
                                 onPressed: (_isProcessing || auth.loading)
                                     ? null
                                     : () => auth.submitOtp(context, auth.otpCtrl.text),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: MyntColors.primary,
                                   disabledBackgroundColor:
                                       MyntColors.primary.withOpacity(0.6),
                                   shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(6)),
                                   elevation: 0,
                                 ),
                                 child: (_isProcessing || auth.loading)
                                     ? const SizedBox(
                                         height: 20,
                                         width: 20,
                                         child: CircularProgressIndicator(
                                             color: Colors.white, strokeWidth: 2))
                                     : Text(
                                         "Continue",
                                         style: MyntWebTextStyles.title(
                                           context,
                                           fontWeight: MyntFonts.bold,
                                           color: Colors.white,
                                         ),
                                       ),
                               ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Switch TOTP/OTP
                            InkWell(
                                onTap: () async {
                                  if (!auth.loading) {
                                    auth.otpCtrl.clear();
                                    await auth.setChangetotp(!auth.totp);
                                    // Make sure to call submitLogin again if switching modes requires re-triggering init logic, 
                                    // but usually switching toggle just changes validation logic unless API requires specific flag for next step.
                                    // Based on provider, we might re-trigger login to get correct OTP/TOTP flow if backend needs it.
                                    if (mounted) {
                                       await auth.submitLogin(context, false, preventNavigation: true);
                                    }
                                  }
                                },
                                child: Text(
                                  auth.totp ? "Enter OTP" : "Enter TOTP", // Toggle text logic
                                  style: MyntWebTextStyles.body(
                                    context,
                                    fontWeight: MyntFonts.bold,
                                    color: MyntColors.primary,
                                  ),
                                ),
                            ),

                          ] else if (_showForgotPassword) ...[
                             // Forgot Password Form (Inlined)
                             TextFormField(
                               controller: forpass.forGetloginMethCtrl,
                               focusNode: focusNode,
                               readOnly: _isProcessing || forpass.loading,
                               maxLength: 10,
                               textCapitalization: TextCapitalization.characters,
                               textInputAction: TextInputAction.done,
                               inputFormatters: [
                                  UpperCaseTextFormatter(),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]')),
                               ],
                               style: MyntWebTextStyles.title(
                                 context,
                                 fontWeight: MyntFonts.medium,
                                 color: MyntColors.textPrimary,
                                 darkColor: MyntColors.textPrimaryDark,
                               ),
                               decoration: InputDecoration(
                                 filled: false,
                                 labelText: "Mobile / Client ID",
                                 floatingLabelBehavior: FloatingLabelBehavior.auto,
                                 labelStyle: MyntWebTextStyles.head(
                                   context,
                                   fontWeight: MyntFonts.regular,
                                   color: MyntColors.textSecondary,
                                   darkColor: MyntColors.textSecondaryDark,
                                 ),
                                 enabledBorder: const UnderlineInputBorder(
                                   borderSide: BorderSide(
                                       color: MyntColors.divider, width: 1),
                                 ),
                                 focusedBorder: const UnderlineInputBorder(
                                   borderSide: BorderSide(
                                       color: MyntColors.primary, width: 1),
                                 ),
                                 counterText: "",
                                 contentPadding:
                                     const EdgeInsets.symmetric(vertical: 8),
                               ),
                               onChanged: (v) {
                                  forpass.validateForgetpassWord();
                                  forpass.activateFrogetbtn();
                               },
                               onFieldSubmitted: (_) {
                                  forpass.submitForgetPassword(context);
                               },
                             ),
                             const SizedBox(height: 5),
                             if (forpass.forgetpassError != null &&
                                 forpass.forgetpassError!.isNotEmpty)
                               Text(
                                 "${forpass.forgetpassError}",
                                 style: MyntWebTextStyles.para(
                                   context,
                                   color: MyntColors.loss,
                                   darkColor: MyntColors.lossDark,
                                 ),
                               ),
                             
                             const SizedBox(height: 32),

                             // Continue Button
                             SizedBox(
                               height: 48,
                               child: ElevatedButton(
                                 onPressed: (forpass.loading)
                                     ? null
                                     : () => forpass.submitForgetPassword(context),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: MyntColors.primary,
                                   disabledBackgroundColor:
                                       MyntColors.primary.withOpacity(0.6),
                                   shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(6)),
                                   elevation: 0,
                                 ),
                                 child: (forpass.loading)
                                     ? const SizedBox(
                                         height: 20,
                                         width: 20,
                                         child: CircularProgressIndicator(
                                             color: Colors.white, strokeWidth: 2))
                                     : Text(
                                         "Continue",
                                         style: MyntWebTextStyles.title(
                                           context,
                                           fontWeight: MyntFonts.bold,
                                           color: Colors.white,
                                         ),
                                       ),
                               ),
                             ),
                             const SizedBox(height: 24),
                             
                             // Back to Login Button
                             Align(
                               alignment: Alignment.centerLeft, // Left aligned as per image? Or Center? Image shows left.
                               child: InkWell(
                                 onTap: () {
                                    setState(() {
                                      _showForgotPassword = false;
                                      forpass.clearError();
                                      forpass.clearTextField();
                                    });
                                 },
                                 child: Text(
                                    "Back to login",
                                    style: MyntWebTextStyles.body(
                                      context,
                                      fontWeight: MyntFonts.bold,
                                      color: MyntColors.primary,
                                    ),
                                 ),
                               ),
                             ),

                          ] else if (pref.islogOut! &&
                              (pref.clientId!.isNotEmpty ||
                                  pref.clientMob!.isNotEmpty)) ...[
                            // Saved Account UI
                            Builder(
                              builder: (context) {
                                if (auth.loginMethCtrl.text.isEmpty) {
                                  auth.loginMethCtrl.text = pref.clientId ?? "";
                                }
                                return Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyntColors.listItemBg,
                                          border: Border.all(
                                            color: MyntColors.primary,
                                            width: 1.5,
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
                                            style: MyntWebTextStyles.head(
                                              context,
                                              fontWeight: MyntFonts.bold,
                                              color: MyntColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        pref.clientName ?? '',
                                        style: MyntWebTextStyles.head(
                                          context,
                                          fontWeight: MyntFonts.bold,
                                          color: MyntColors.textPrimary,
                                          darkColor: MyntColors.textPrimaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        pref.clientId ?? '',
                                        style: MyntWebTextStyles.title(
                                          context,
                                          fontWeight: MyntFonts.semiBold,
                                          color: MyntColors.textPrimary,
                                          darkColor: MyntColors.textPrimaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            )
                          ] else ...[
                            // Login Form - User ID Input
                            TextFormField(
                              controller: auth.loginMethCtrl,
                              focusNode: focusNode,
                              readOnly: _isProcessing || auth.loading,
                              maxLength: 10,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                              ],
                              style: MyntWebTextStyles.title(
                                context,
                                fontWeight: MyntFonts.medium,
                                color: MyntColors.textPrimary,
                                darkColor: MyntColors.textPrimaryDark,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                labelText: "Mobile / Client ID",
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                labelStyle: MyntWebTextStyles.head(
                                  context,
                                  fontWeight: MyntFonts.regular,
                                  color: MyntColors.textSecondary,
                                  darkColor: MyntColors.textSecondaryDark,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyntColors.divider, width: 1),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyntColors.primary, width: 1),
                                ),
                                counterText: "",
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onTap: pref.isMobileLogin!
                                  ? auth.getCurrentPhone
                                  : null,
                              onChanged: (v) {
                                auth.validateLogin();
                                auth.activeBtnLogin();
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(focusNode1);
                              },
                            ),
                            const SizedBox(height: 5),
                            if (auth.loginMethError != null &&
                                auth.loginMethError!.isNotEmpty)
                              Text(
                                "${auth.loginMethError}",
                                style: MyntWebTextStyles.para(
                                  context,
                                  color: MyntColors.loss,
                                  darkColor: MyntColors.lossDark,
                                ),
                              ),
                          ],
                          
                          // Password and Actions (Only Show if NOT in Forgot Password Mode)
                          if (!_showForgotPassword && !_showOtpScreen) ...[
                            const SizedBox(height: 20),
                            
                            // Password Input (Always Visible)
                            TextFormField(
                              controller: auth.passCtrl,
                              focusNode: focusNode1,
                              obscureText: auth.hidePass,
                              readOnly: _isProcessing || auth.loading,
                              textInputAction: TextInputAction.done,
                              style: MyntWebTextStyles.title(
                                context,
                                fontWeight: MyntFonts.medium,
                                color: MyntColors.textPrimary,
                                darkColor: MyntColors.textPrimaryDark,
                              ),
                              decoration: InputDecoration(
                                labelText: "Password",
                                filled: false,
                                labelStyle: MyntWebTextStyles.head(
                                  context,
                                  fontWeight: MyntFonts.regular,
                                  color: MyntColors.textSecondary,
                                  darkColor: MyntColors.textSecondaryDark,
                                ),
                                suffixIcon: InkWell(
                                  onTap: auth.hiddenPass,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      auth.hidePass
                                          ? "assets/icon/eye-off.svg"
                                          : "assets/icon/eye.svg",
                                      color: theme.isDarkMode
                                          ? MyntColors.textSecondaryDark
                                          : MyntColors.textSecondary,
                                      width: 20,
                                    ),
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyntColors.divider, width: 1),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyntColors.primary, width: 1),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                              inputFormatters: [
                                NoEmojiInputFormatter(),
                                FilteringTextInputFormatter.deny(
                                    RegExp('[π£•₹€℅™∆√¶/,]')),
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              onChanged: (v) {
                                auth.validatePass();
                                auth.activeBtnLogin();
                              },
                              onFieldSubmitted: (_) {
                                if (!_isProcessing && !auth.loading) {
                                  _handleContinue();
                                }
                              },
                            ),
                            const SizedBox(height: 5),
                            if (auth.passError != null &&
                                auth.passError!.isNotEmpty)
                              Text(
                                "${auth.passError}",
                                style: MyntWebTextStyles.para(
                                  context,
                                  color: MyntColors.loss,
                                  darkColor: MyntColors.lossDark,
                                ),
                              ),
                            const SizedBox(height: 32),

                            // Login Button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (_isProcessing || auth.loading)
                                    ? null
                                    : _handleContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyntColors.primary,
                                  disabledBackgroundColor:
                                      MyntColors.primary.withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  elevation: 0,
                                ),
                                child: (_isProcessing || auth.loading)
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2))
                                    : Text(
                                        "Login",
                                        style: MyntWebTextStyles.title(
                                          context,
                                          fontWeight: MyntFonts.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Actions Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left Logic: Switch Account (if saved) OR Forgot Password (if new)
                                if (pref.islogOut! &&
                                    (pref.clientId!.isNotEmpty ||
                                        pref.clientMob!.isNotEmpty))
                                  InkWell(
                                    onTap: () async {
                                      pref.setLogout(false);
                                      pref.setHideLoginOptBtn(true);
                                      // Clear controller
                                      auth.loginMethCtrl.clear(); 
                                      auth.passCtrl.clear();
                                      await auth.loginMethod();
                                      auth.switchbackbutton(true);
                                    },
                                    child: Text(
                                      "Switch account",
                                      style: MyntWebTextStyles.para(
                                        context,
                                        fontWeight: MyntFonts.bold,
                                        color: MyntColors.primary,
                                      ),
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showForgotPassword = true;
                                        forpass.clearError();
                                        forpass.clearTextField();
                                      });
                                    },
                                    child: Text(
                                      "Forgot password",
                                      style: MyntWebTextStyles.para(
                                        context,
                                        fontWeight: MyntFonts.bold,
                                        color: MyntColors.primary,
                                      ),
                                    ),
                                  ),

                                // Right Logic: Forgot Password (if saved) OR Empty (if new)
                                if (pref.islogOut! &&
                                    (pref.clientId!.isNotEmpty ||
                                        pref.clientMob!.isNotEmpty))
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showForgotPassword = true;
                                        forpass.clearError();
                                        forpass.clearTextField();
                                      });
                                    },
                                    child: Text(
                                      "Forgot password",
                                      style: MyntWebTextStyles.para(
                                        context,
                                        fontWeight: MyntFonts.bold,
                                        color: MyntColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Sign Up Link
                          Center(
                            child: InkWell(
                              onTap: () {
                                launch('https://oa.mynt.in/?ref=zws');
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account yet? ",
                                  style: MyntWebTextStyles.body(
                                    context,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: "Sign Up",
                                        style: MyntWebTextStyles.body(
                                          context,
                                          fontWeight: MyntFonts.bold,
                                          color: MyntColors.primary,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Footer
                          Text(
                            "Zebu Share and Wealth Managements Pvt. Ltd.",
                            style: MyntWebTextStyles.body(
                              context,
                              fontWeight: MyntFonts.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "SEBI Registration No: INZ000174634 | NSE : 13179 | BSE : 6550 | MCX : 55730 | CDSL : 12080400 | AMFI ARN : 113118 | Research Analyst : INH200006044",
                              style: MyntWebTextStyles.para(
                                context,
                                color: MyntColors.textSecondary,
                                darkColor: MyntColors.textSecondaryDark,
                              ).copyWith(height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }));
  }
}

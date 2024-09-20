import 'dart:async';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';

import '../locator/preference.dart';
import '../models/auth_model/change_pass_model.dart';
import '../models/auth_model/forgot_pass_model.dart';
import '../models/auth_model/logged_mobile_model.dart';
import '../models/auth_model/login_otp.dart';
import '../models/auth_model/login_otp_verify.dart';
import '../models/auth_model/logout_model.dart';
import '../models/auth_model/mobile_login_model.dart';
import '../models/auth_model/mobile_otp_model.dart';
import '../models/auth_model/validate_seesion_model.dart';
import '../models/profile_model/client_detail_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/risk_disclosure_bottom_sheet.dart';
import '../sharedWidget/snack_bar.dart';
import 'change_password_provider.dart';
import 'core/default_change_notifier.dart';
import 'fund_provider.dart';
import 'index_list_provider.dart';
import 'market_watch_provider.dart';
import 'order_provider.dart';
import 'portfolio_provider.dart';
import 'user_profile_provider.dart';

final authProvider = ChangeNotifierProvider((ref) => AuthProvider(ref.read));

class AuthProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;
  final TextEditingController loginMethCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();

  String? loginMethError, passError, optError;

  bool _isMobileLogin = false;
  bool _isonTapMobile = true;
  bool _isDisableBtn = true;
  bool _hidePass = true;
  bool _isDisableOtpBtn = true;
  bool _hideOtp = true;

  String _logoutMsg = "";
  String get logoutMsg => _logoutMsg;

  List<LoggedMobile> _loggedMobile = [];

  List<LoggedMobile> get loggedMobile => _loggedMobile;
  bool get isMobileLogin => _isMobileLogin;
  bool get isDisableBtn => _isDisableBtn;
  bool get hidePass => _hidePass;
  bool get hideOtp => _hideOtp;
  bool get isDisableOtpBtn => _isDisableOtpBtn;

  LoginOtp? _loginOtp;
  LoginOtp? get loginOtp => _loginOtp;

//
  String mobile_client = "";
  MobileLoginModel? _mobileLogin;
  MobileLoginModel? get mobileLogin => _mobileLogin;
  MobileOtpModel? _mobileOtp;
  MobileOtpModel? get mobileOtp => _mobileOtp;
//
  LoginOtpVerify? _loginOtpVerify;
  LoginOtpVerify? get loginOtpVerify => _loginOtpVerify;

  ClientDetailModel? _clientDetailModel;
  ClientDetailModel? get clientDetailModel => _clientDetailModel;
  String deviveInfo = "";
  LogoutModel? _logoutModel;
  LogoutModel? get logoutModel => _logoutModel;
  ChangePasswordModel? _changepasswordmodel;
  ChangePasswordModel? get changepasswordmodel => _changepasswordmodel;

  ForgetPasswordModel? _forgetPasswordModel;
  ForgetPasswordModel? get forgetPasswordModel => _forgetPasswordModel;

  Map<String, dynamic> _deviceData = <String, dynamic>{};
  Map<String, dynamic> get deviceInfo => _deviceData;

  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  ValidateSession? _validateSession;
  ValidateSession? get validSession => _validateSession;

  bool _addUser = false;
  bool get addUser => _addUser;

  addClient(bool val) {
    _addUser = true;
    notifyListeners();
  }

  loginMethod() {
    _isMobileLogin = !_isMobileLogin;

    pref.setMobileLogin(!pref.isMobileLogin!);

    _isDisableBtn = true;
    clearError();
    clearTextField();
    notifyListeners();
  }

  switchMobToClinent(bool val) {
    _isMobileLogin = val;
    notifyListeners();
  }

  activeBtnLogin() {
    if (validateLogin()) {
      _isDisableBtn = false;
    } else {
      _isDisableBtn = true;
    }
    notifyListeners();
  }

  activeBtnOtp() {
    if (validateOtp()) {
      _isDisableOtpBtn = false;
    } else {
      _isDisableOtpBtn = true;
    }
    notifyListeners();
  }

  hiddenPass() {
    _hidePass = !_hidePass;
    notifyListeners();
  }

  hiddenOtp() {
    _hideOtp = !_hideOtp;
    notifyListeners();
  }

  void clearError() {
    loginMethError = null;
    passError = null;
    notifyListeners();
  }

  void clearTextField() {
    otpCtrl.clear();
    loginMethCtrl.clear();
    passCtrl.clear();
    notifyListeners();
  }

  Future<void> getDeviceDetails() async {
    Map<String, dynamic>? deviceData = <String, dynamic>{};

    try {
      deviceData = switch (defaultTargetPlatform) {
        TargetPlatform.android =>
          _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo),
        TargetPlatform.iOS =>
          _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
        TargetPlatform.fuchsia => null,
        TargetPlatform.linux => null,
        TargetPlatform.macOS => null,
        TargetPlatform.windows => null
      };
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    _deviceData = deviceData!;

    log("deviveInfo $_deviceData");

    deviveInfo = defaultTargetPlatform == TargetPlatform.android
        ? "${_deviceData['brand']}-${_deviceData['model']}-${_deviceData['id']}"
        : "${_deviceData['model']}-${_deviceData['name']}-${_deviceData['identifierForVendor']}";

    pref.setDeviceName(deviveInfo);
    notifyListeners();
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'brand': build.brand,
      'id': build.id,
      'model': build.model
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'model': data.model,
      'identifierForVendor': data.identifierForVendor
    };
  }

  bool validateLogin() {
    clearError();
    if (loginMethCtrl.text.trim().isEmpty) {
      loginMethError = !pref.isMobileLogin!
          ? "Please enter client Id"
          : "Please enter mobile";
    } else if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(loginMethCtrl.text)) {
      loginMethError =
          !pref.isMobileLogin! ? null : "Please enter a valid mobile";
    }
    if (passCtrl.text.trim().isEmpty) {
      passError = "Please enter the Password";
    }
    notifyListeners();
    return loginMethError == null && passError == null;
  }

  bool validateOtp() {
    if (otpCtrl.text.length <= 3) {
      optError = "Please enter 4 digit OTP";
    } else {
      optError = null;
    }

    return optError == null;
  }

  submitLogin(BuildContext context) {
    // if (routeTo == "deviceLogin") {
    //   _isMobileLogin = true;
    // }
    if (validateLogin()) {
      fetchMobileLogin(
          context, passCtrl.text, loginMethCtrl.text.toUpperCase(), "");
    }
  }

  submitOtp(BuildContext context) {
    if (validateOtp()) {
      fetchMobileOtp(context, otpCtrl.text);
    }
  }

  submitResendOtp(BuildContext context) {
    resendOtp(context, passCtrl.text, loginMethCtrl.text.toUpperCase());
  }

  fetchMobileLogin(BuildContext context, String password, String mobileRclint,
      String s) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      toggleLoadingOn(true);
      _mobileLogin = await api.getMobileLogin(
          uniqueId: pref.deviceName!,
          mobileRclient: mobileRclint,
          password: password,
          context: context);
      // final localstorage = await SharedPreferences.getInstance();

      if (_mobileLogin!.stat == "Ok" && s.isNotEmpty) {
        Navigator.pop(context);
      }

      if (_mobileLogin!.stat == "Ok" &&
          (_mobileLogin!.msg == "otp sended" ||
              _mobileLogin!.msg ==
                  "otp sended, already logged in another device")) {
        otpCtrl.clear();
        mobile_client = mobileRclint;
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'The OTP is sent via email and SMS'));
        _isDisableBtn = true;

        Navigator.pushNamed(context, Routes.loginOtpVerify);
      } else if (_mobileLogin!.emsg ==
          "Invalid Input : User Blocked due to multiple wrong attempts") {
        ref(changePasswordProvider).userIdController.text =
            "${_mobileLogin!.clientid}";
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, _mobileLogin!.emsg!));
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushNamed(context, Routes.forgotPass);
        });
      } else if (_mobileLogin!.emsg == "Invalid Input : Change Password" ||
          _mobileLogin!.emsg == "Invalid Input : Password Expired") {
        ref(changePasswordProvider).userIdController.text =
            "${_mobileLogin!.clientid}";
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, _mobileLogin!.emsg!));
        Navigator.pushNamed(context, Routes.changePass, arguments: "No");
      } else if (_mobileLogin!.emsg ==
          "Your mobile registered in multiple accounts, Please login with client ID") {
        loginMethod();
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
            "Multiple accounts linked to your mobile no. Login with Client ID"));
      } else if (_mobileLogin!.emsg == "mobile_unique not valid") {
        if (s.isNotEmpty) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
            "This user id logged in another device, Please login again"));
        _isDisableBtn = true;
        pref.setHideLoginOptBtn(false);
        clearError();
        clearTextField();
        pref.setLogout(true);
        ref(indexListProvider).bottomMenu(1);
        loginMethCtrl.text =
            pref.isMobileLogin! ? pref.clientMob! : pref.clientId!;
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.loginScreen, (route) => false);
      } else if (_mobileLogin!.apitoken != null && _mobileLogin!.stat == "Ok") {
        clearError();
        clearTextField();

        pref.setClientId("${_mobileLogin!.clientid}");
        pref.setClientMob("${_mobileLogin!.mobile}");
        pref.setClientSession("${_mobileLogin!.apitoken}");
        pref.setClientName("${_mobileLogin!.name}");
        pref.setApiToken("${_mobileLogin!.token}");

        List<LoggedMobile> currentUser = [
          LoggedMobile(
              clientId: pref.clientId!,
              mobile: pref.clientMob!,
              sesstion: pref.clientSession!,
              userName: pref.clientName!)
        ];
        _loggedMobile = await getLocalData();

        await setLocalData(_loggedMobile, currentUser);

        _loggedMobile = await getLocalData();

        await deviceAuth(context, s);
      } else if (password.isEmpty &&
          _mobileLogin!.emsg == "Invalid Input : Wrong Password") {
        _isDisableBtn = true;
        clearError();
        clearTextField();
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.loginScreen, arguments: "login", (route) => false);
      } else if (_mobileLogin!.emsg == "") {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, _mobileLogin!.emsg!));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, _mobileLogin!.emsg!));
      }
      notifyListeners();
    } catch (e) {
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }

  resendOtp(BuildContext context, String password, String mobileRclint) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      toggleLoadingOn(true);
      _mobileLogin = await api.getMobileLogin(
          uniqueId: pref.deviceName!,
          mobileRclient: mobileRclint,
          password: password,
          context: context);
      otpCtrl.clear();
      _isDisableOtpBtn = true;
      if (_mobileLogin!.stat == "Ok" &&
          (_mobileLogin!.msg == "otp sended" ||
              _mobileLogin!.msg ==
                  "otp sended, already logged in another device")) {
        mobile_client = mobileRclint;
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, 'The OTP is re-sent via SMS and email.'));
        // _isDisableBtn = true;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, _mobileLogin!.emsg!));
      }
      notifyListeners();
    } catch (e) {
      print(e);
    } finally {
      toggleLoadingOn(false);
    }
  }

  fetchMobileOtp(BuildContext context, String otp) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      toggleLoadingOn(true);
      _mobileOtp = await api.getMobileOtp(
          uniqueId: pref.deviceName!,
          mobileRclient: mobile_client,
          otp: otp,
          context: context);

      // final localstorage = await SharedPreferences.getInstance();
      if (_mobileOtp!.stat == "Ok") {
        _isDisableBtn = true;
        clearError();
        clearTextField();

        pref.setClientId("${_mobileOtp!.clientid}");
        pref.setClientMob("${_mobileOtp!.mobile}");
        pref.setClientSession("${_mobileOtp!.apitoken}");
        pref.setClientName("${_mobileOtp!.name}");
        pref.setApiToken("${_mobileOtp!.token}");

        List<LoggedMobile> currentUser = [
          LoggedMobile(
              clientId: pref.clientId!,
              mobile: pref.clientMob!,
              sesstion: pref.clientSession!,
              userName: pref.clientName!)
        ];
        _loggedMobile = await getLocalData();

        await setLocalData(_loggedMobile, currentUser);

        _loggedMobile = await getLocalData();
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, 'OTP Verified'));
        await deviceAuth(context, "");

        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
            context, _mobileOtp!.emsg!.replaceAll("Invalid Input :", "* ")));
      }
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future<void> setLocalData(
      List<LoggedMobile> list, List<LoggedMobile> currentUser) async {
    List<LoggedMobile> uniqueList = [];
    list.add(currentUser[0]);

    Set<String> uniqueCombos = <String>{};
    for (var element in list.reversed) {
      String combo = '${element.clientId}-${element.mobile}';

      if (!uniqueCombos.contains(combo)) {
        uniqueCombos.add(combo);
        uniqueList.add(element);
      }
    }

    final List<String> jsonList =
        uniqueList.map((obj) => obj.toJson()).toList();

    pref.setLoggedClientList(jsonList);
  }

  // Retrieve a list of objects from shared preferences
  Future<List<LoggedMobile>> getLocalData() async {
    List<String>? jsonList = pref.loggedClient;

    if (jsonList != null) {
      return jsonList
          .map((jsonString) => LoggedMobile.fromJson(jsonString))
          .toList();
    } else {
      return [];
    }
  }

  fetchLogout(BuildContext context) async {
    try {
      _logoutModel = await api.getLogout();
      if (_logoutModel!.stat == "Ok") {
        ConstantName.timer!.cancel();

        // _logoutMsg = "Logout";
        // _isMobileLogin = true;
        // localstorage.setString("logout", _logoutMsg);
        pref.clearClientSession();
        pref.setLogout(true); pref.setHideLoginOptBtn(false);
        ref(indexListProvider).bottomMenu(1);
        loginMethCtrl.text =
            pref.isMobileLogin! ? pref.clientMob! : pref.clientId!;
        notifyListeners();
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'Logged out'));

        Navigator.of(context).pop();
        ref(websocketProvider).closeSocket();
        ref(websocketProvider).websockConn(false);
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.loginScreen, (route) => false);
      }
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    }
  }

  getCurrentPhone() async {
    if (_isonTapMobile) {
      if (loginMethCtrl.text.toString().isEmpty) {
        try {
          final autoFill = SmsAutoFill();
          final phone = await autoFill.hint;

          _isonTapMobile = false;
 
          if (phone == null) {
            loginMethCtrl.text = "";
          } else if (phone.contains('+91')) {
            loginMethCtrl.text = phone.substring(3);
          } else {
            loginMethCtrl.text = phone.toString();
          }
          notifyListeners();
          validateLogin();

          activeBtnLogin();
        } catch (e) {
          print('Failed to get mobile number because of: $e');
        }
      }
    }
  }

  Future<void> deviceAuth(BuildContext context, String s) async {
    final localAuth = LocalAuthentication();

    try {
      bool authenticated = await localAuth.authenticate(
          localizedReason: 'Authenticate to access the app',
          options: const AuthenticationOptions(
              useErrorDialogs: false, stickyAuth: true, biometricOnly: false));

      if (authenticated) {
        print('bioAuth - User authenticated successfully');

        initialLoadMethods(context, s);
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titleTextStyle: textStyles.appBarTitleTxt,
              contentTextStyle: textStyles.menuTxt,
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              scrollable: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text("Confirmation"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Authentication is reqired to proceed further!")
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () => deviceAuth(context, s),
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: ref(themeProvider).isDarkMode
                            ? colors.colorbluegrey
                            : colors.colorBlack,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )),
                    child: Text("Proceed", style: textStyles.btnText)),
              ],
            );
          },
        );
        // Navigator.pushNamedAndRemoveUntil(
        //     context, Routes.loginScreen, arguments: "login", (route) => false);
        print('bioAuth - Authentication failed');
      }
      // } else {
      //   print('bioAuth Biometrics not available on this device');
      // }
    }
    // catch (e) {

    //   print('Error: $e');
    // }

    on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                titleTextStyle: textStyles.appBarTitleTxt,
                contentTextStyle: textStyles.menuTxt,
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
                scrollable: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: const Text("Confirmation"),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Authentication is reqired to proceed further!")
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () => deviceAuth(context, s),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: ref(themeProvider).isDarkMode
                              ? colors.colorbluegrey
                              : colors.colorBlack,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          )),
                      child: Text("Proceed", style: textStyles.btnText)),
                ],
              );
            },
          );
        } else {
          initialLoadMethods(context, s);
        }
      } else if (e.code == auth_error.notEnrolled) {
        // print("bioAuth - - ${e.code}");
        // ...
      } else {
        // ...
        // print("bioAuth - --  -${e.code}");
      }

      // print("bioAuth - ${e.code}");
    }
    notifyListeners();
  }

  AuthProvider(this.ref);

  initialLoadMethods(BuildContext context, String s) async {
    try {
      initLaod(true);
      ConstantName.timer =
          Timer.periodic(const Duration(seconds: 1), (timer) {});
      ConstantName.timer!.cancel();
      await ref(indexListProvider).bottomMenu(s.isEmpty ? 1 : 4);
      // ref(websocketProvider).websockConn(false);
      if(s.isNotEmpty ){
        ref(websocketProvider).closeSocket();
      }

        if(pref.clientSession!.isNotEmpty ){
        ref(websocketProvider).closeSocket();
      }

      // await ref(stocksProvide).defaultSectorThemematicData();
      // await ref(indexListProvider).fetchDefTopIndex(context);
      // await ref(stocksProvide)
      //     .fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
      // await ref(stocksProvide)
      //     .fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
      // await ref(stocksProvide).fetchCorporateAction();

      // await ref(stocksProvide).fetchIndicesAdvdec();
      // await ref(stocksProvide).fetchStockMonitor("NSE",
      //     ref(stocksProvide).slectBaskt, ref(stocksProvide).slectFilterCont);
      // await ref(stocksProvide).getNews();

      // if (pref.islogIn!) {


      
      await ref(indexListProvider).checkSession(context);
      await ref(marketWatchProvider).changeWlName("", "No");
      _logoutMsg = "";

      if (ref(indexListProvider).checkSess!.stat == "Ok") {
         ref(indexListProvider).fetchNotifyMsg();
        ref(portfolioProvider).changeTabIndex(0);
      
        await ref(portfolioProvider).fetchHoldings(context, "");

        await ref(indexListProvider).getDeafultIndexList(context);
        await ref(marketWatchProvider).fetchMWList(context);
   ref(userProfileProvider).fetchUserDetail(
            context );
         ref(portfolioProvider).fetchPositionBook(context, false);
        ref(orderProvider).fetchOrderBook(context, false);
          ref(orderProvider).fetchTradeBook(context);

         ref(orderProvider).fetchGTTOrderBook(context, "initLoad");
  print("object -------");
        if (s.isEmpty) {


            print("object  dsgfv -------");
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.homeScreen, (route) => false);
          // if (pref.islogIn!) {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              backgroundColor: const Color(0xffffffff),
              isDismissible: false,
              enableDrag: false,
              showDragHandle: false,
              useSafeArea: false,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: const RiskDisclousreBottomSheet());
              });
        }
        {
          await ref(fundProvider).fetchFunds(context);
        }
      }
      // }
      // ConstantName.timer!.cancel();

      // }
    } finally {
      initLaod(false);
    }
  }

  ifSessionExpired(BuildContext context) {
    pref.clearClientSession();
    pref.setLogout(true);
    ref(indexListProvider).bottomMenu(1);

    pref.setHideLoginOptBtn(false);
    pref.clearClientSession();
    ConstantName.sessCheck = false;
    loginMethCtrl.text = pref.isMobileLogin! ? pref.clientMob! : pref.clientId!;
    ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context, "Session Expired,Kindly login Again!"));
    ConstantName.timer!.cancel();

    ref(websocketProvider).closeSocket();
    ref(websocketProvider).websockConn(false);
    Navigator.pushNamedAndRemoveUntil(
        context, Routes.loginScreen, (route) => false);
  }
}

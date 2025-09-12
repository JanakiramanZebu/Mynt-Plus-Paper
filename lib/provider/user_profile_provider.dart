import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/user_detail_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'shocase_provider.dart';
import '../models/profile_model/qr_login_res.dart';

final userProfileProvider =
    ChangeNotifierProvider((ref) => UserProfileProvider(ref));

class UserProfileProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;

  UserDetailModel? _userDetailModel;
  UserDetailModel? get userDetailModel => _userDetailModel;

  QrLoginResponces? _qrLoginesponces;
  QrLoginResponces? get qrloginres => _qrLoginesponces;

  final FToast _fToast = FToast();
  FToast get fToast => _fToast;

  List _settingMenu = [];
  List get settingmenu => _settingMenu;

  final List _socialMedaiIcons = [
    {"icon": assets.facebook, "link": "https://www.facebook.com/zebuetrade/"},
    {"icon": assets.twitterX, "link": "https://twitter.com/zebuetrade?lang=en"},
    {
      "icon": assets.youtube,
      "link": "https://www.youtube.com/channel/UCKbEVG1fH1TwkNDe6OM-zxg"
    },
    {"icon": assets.insta, "link": "https://www.instagram.com/zebu_official/"},
    {"icon": assets.pintrest, "link": "https://in.pinterest.com/ZebuMarketing/"}
  ];
  List get socialMedaiIcons => _socialMedaiIcons;

  List _profileMenu = [];

  final List _accountMenu = [
    {"title": "Personal Info", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Bank", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Demat", "trailing": "assets/profile/greater_arrow.svg"},
    {
      "title": "Trading Preference",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Margin Trading Facility (MTF)",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {"title": "Annual Income", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Nominee", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Family Account", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Closure", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Form Download", "trailing": "assets/profile/greater_arrow.svg"},
  ];

  final List _reporttMenu = [
    {
      "Subtitle": "P&L Insights",
      "title": "Access P&L reports by date for better insights.",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "View & Track Financial Transactions",
      "Subtitle": "Ledger",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Monitor Your Investment Portfolio",
      "Subtitle": "Holdings",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Track Open & Closed Trading Positions",
      "Subtitle": "Positions - (Beta)",
      // "trailing": "assets/profile/ex-link.svg"
      "trailing": "assets/profile/greater_arrow.svg"
    },
    // {
    //   "title": "Positions - (Beta)",
    //   "trailing": "assets/profile/greater_arrow.svg"
    // },
    {
      "title": "Analyze Trading Profit & Loss",
      "Subtitle": "Profit and Loss",
      "trailing": "assets/profile/greater_arrow.svg"
    },

    {
      "title": "Generate Tax Reports & P&L for Filing",
      "Subtitle": "Tax P&L",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Access Trade History & Contract Notes",
      "Subtitle": "Tradebook/Contract",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Download reports as PDFs for easy access",
      "Subtitle": "Downloads",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    // cop action
    // {
    //   "title": "View & Manage Corporate Announcements",
    //   "Subtitle": "Corporate Action",
    //   "trailing": "assets/profile/greater_arrow.svg"
    // },
    {
      "title": "View & Manage Corporate Announcements",
      "Subtitle": "CA Events",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Manage Pledge & Unpledged Securities",
      "Subtitle": "Pledge & Unpledge",
      "trailing": "assets/profile/greater_arrow.svg"
    },

    // {"title": "Pledge & Unpledge", "trailing": "assets/profile/greater_arrow.svg"}
  ];

  List get profileMenu => _profileMenu;
  List get accountMenu => _accountMenu;
  List get reporttMenu => _reporttMenu;

  ClientDetailModel? _clientDetailModel;
  ClientDetailModel? get clientDetailModel => _clientDetailModel;
  UserProfileProvider(this.ref);

  bool _userloader = false;
  bool get userloader => _userloader;

  bool _showchartof = false;
  bool get showchartof => _showchartof;

  bool _onloadshowchartof = false;
  bool get onloadshowchartof => _onloadshowchartof;

  Key _webViewKey = UniqueKey();
  Key get webViewKey => _webViewKey;

  setChartdialog(bool value) {
    _showchartof = value;
    notifyListeners();
  }

  setonloadChartdialog(bool value) {
    if (value == true && !_onloadshowchartof) {
      _webViewKey = UniqueKey();
    }
    _onloadshowchartof = value;
    notifyListeners();
  }

  // Method to clear all user data when switching accounts
  void clearUserData() {
    _userDetailModel = null;
    _clientDetailModel = null;
    _showchartof = false;
    _onloadshowchartof = false;
    _userloader = false;
    _webViewKey = UniqueKey();
    notifyListeners();
  }

  profilePageloader(bool value) {
    _userloader = value;
    notifyListeners();
  }

  bool _profileloader = false;
  bool get profileloader => _profileloader;

  profileloaderfun(bool value) {
    _profileloader = value;
    print("profileloader: $value");
    notifyListeners();
  }

// Fetching data from the api and stored in a variable

  Future fetchUserDetail(BuildContext context) async {
    try {
      // toggleLoadingOn(true);
      _userDetailModel = await api.getUserDetail();

      if (_userDetailModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _userDetailModel!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
      return _userDetailModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API User Detail", "Error": "$e"});
      notifyListeners();
    } finally {
      // toggleLoadingOn(false);
    }
  }
// Fetching data from the api and stored in a variable

  Future fetchClientDetail(BuildContext context) async {
    try {
      _clientDetailModel = await api.getClientDetail();

      if (_clientDetailModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }
      notifyListeners();
      return _clientDetailModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Client Detail", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

// Assinging value

  fetchsetting() {
    _settingMenu = [
      {
        "title": "API Key",
        "subTitle": "Generate & Manage API Key for Secure Trading",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "TOTP",
        "subTitle": "Enable Two-Factor Authentication (TOTP)",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Freeze Account",
        "subTitle": "Temporarily disabling access",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Change Password",
        "subTitle": "Update Your Account Password Securely",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Theme",
        "subTitle": "Customize Theme & Interface Settings",
        "leading": "assets/icon/theme_icon.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Log",
        "subTitle": "View Account & Trading Logs",
        "leading": "assets/profile/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Order Preference",
        "subTitle": "Set Trading Order Preferences",
        "leading": "assets/profile/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
    ];
    notifyListeners();
    return settingmenu;
  }

// Assigning value

  fetchprofilemenu() {
    _profileMenu = [
      {
        "title": "Fund",
        "subTitle": "Deposit & Withdraw Funds",
        "leading": "assets/profileimage/wallet.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).fundcase,
        "case": "Click here to view the fund information page."
      },
      {
        "title": "My Account",
        "subTitle": "Account Settings & Profile Management",
        "leading": "assets/profileimage/user_logo.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).accountcase,
        "case": "Click here to view the account page."
      },
      {
        "title": "Reports",
        "subTitle": "Trading & Financial Reports",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).reportcase,
        "case": "Click here to view the report page."
      },
      // {
      //   "title": "Verified P&L",
      //   "subTitle": "Verified P&L",
      //   "leading": "assets/profileimage/verifiedpl.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": "",
      //   "case": "Click here to view the Verified P&L page."
      // },
      {
        "title": "Corporate Action",
        "subTitle": "Track Corporate Events & Actions",
        "leading": "assets/profileimage/coa_edited.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).corporateactioncase,
        "case": "Click here to view the Corporate Action page."
      },
      // {
      //   "title": "CA Events",
      //   "subTitle": "CA Event",
      //   "leading": "assets/profileimage/caevent.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": "",
      //   "case": "Click here to view the Corporate Action page."
      // },
      // {
      //   "title": "Pledge & Unpledge",
      //   "subTitle": "Pledge & Unpledge",
      //   "leading": "assets/profileimage/pledge.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref.read(showcaseProvide).pledgeunpcase,
      //   "case": "Click here to view the Pledge & Unpledge page."
      // },
      {
        "title": "IPO",
        "subTitle": "Apply & Invest in IPOs",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view the IPO."
      },
      {
        "title": "Mutual Fund",
        "subTitle": "Explore & Invest in Mutual Funds",
        "leading": "assets/icon/mf_icon.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view theMutual Fund."
      },
      {
        "title": "Bonds",
        "subTitle": "Explore & Invest in Bonds",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view the Log message."
      },
      {
        "title": "OptionZ",
        "subTitle": "Trade in Advanced Derivatives with OptionZ",
        "leading": "assets/profileimage/pledge.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).pledgeunpcase,
        "case": "Click here to view the OptionZ."
      },
      //  {
      //   "title": "KRA",
      //   "subTitle": "KRA",
      //   "leading": "assets/profileimage/pledge.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref.read(showcaseProvide).pledgeunpcase,
      //   "case": "Click here to view the Pledge & Unpledge page."
      // },
      {
        "title": "Refer",
        "subTitle": "Refer your family and friends",
        "leading": "assets/profileimage/Referal_Incentive.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).apikeycase,
        "case": "Click here to Refer your family and friends."
      },
      {
        "title": "Settings",
        "subTitle": "Manage Security, API, & Account Preferences",
        "leading": "assets/profileimage/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).logcase,
        "case": "Click here to view Settings."
      },
      {
        "title": "Rate Us",
        "subTitle": "Share Your Feedback & Experience.",
        "leading": "assets/icon/appbarIcon/star.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).notificationcase,
        "case": "Click here to Share your experience!."
      },
      {
        "title": "Notification",
        "subTitle": "Manage Alerts & Notifications",
        "leading": "assets/icon/appbarIcon/bell.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).notificationcase,
        "case": "Click here to view the notification."
      },
      {
        "title": "Need Help?",
        "subTitle": "Contact us, Follow us",
        "leading": "assets/profile/headphones.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to Contact us, Follow us."
      },
      /////
      // {
      //   "title": "Bonds",
      //   "subTitle": "Bonds",
      //   "leading": "assets/profileimage/reports.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": "",
      //   "case": "Click here to view the Log message."
      // },
    ];
    return profileMenu;
  }

// Fetching data from the api and stored in a variable

  Future fetchQR(BuildContext context, String unquiid, String loginfsrc,
      MobileScannerController camera) async {
    try {
      _qrLoginesponces = await api.getqr(unquiid, loginfsrc);
      if (_qrLoginesponces!.msg == "logged in") {
        showResponsiveSuccess(context, "${_qrLoginesponces!.msg}");
        Navigator.pop(context);
        Navigator.pop(context);
        camera.stop();
      } else {
        showResponsiveWarningMessage(context, "${_qrLoginesponces!.emsg}");
        Navigator.pop(context);
        camera.start();
      }
    } catch (e) {
      notifyListeners();
    } finally {}
  }

// Fetching data from the api and stored in a variable

  Future fetchFreezeAc(BuildContext context) async {
    try {
      final res = await api.getaFreezeAc();
      Map data = jsonDecode(res.body);

      if (data["stat"] == "Ok") {
        await fetchBlockAc(context);
      } else {
        showResponsiveWarningMessage(context, data["emsg"].toString());
      }
    } catch (e) {
      notifyListeners();
    } finally {}
  }

// Fetching data from the api and stored in a variable

  Future fetchBlockAc(BuildContext context) async {
    try {
      final res = await api.getaBlockAc();
      Map data = jsonDecode(res.body);

      if (data["stat"] == "Ok") {
        ConstantName.timer!.cancel();

        pref.clearClientSession();
        pref.setLogout(true);
        ref.read(indexListProvider).bottomMenu(1, context);
        ref.read(authProvider).loginMethCtrl.text =
            pref.isMobileLogin! ? pref.clientMob! : pref.clientId!;
        notifyListeners();

        Navigator.of(context).pop();
        // ref.read(websocketProvider).closeSocket();
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.loginScreen, (route) => false);
          }
          showResponsiveSuccess(context, 'The Account has been deactivated');
        });
      } else {
        showResponsiveWarningMessage(context, data["emsg"].toString());
      }
    } catch (e) {
      notifyListeners();
    } finally {}
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/user_detail_model.dart';
import '../res/res.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'fund_provider.dart';
import 'index_list_provider.dart';
import 'market_watch_provider.dart';
import 'order_provider.dart';
import 'portfolio_provider.dart';
import 'shocase_provider.dart';
// import 'thems.dart';

final userProfileProvider =
    ChangeNotifierProvider((ref) => UserProfileProvider(ref.read));

class UserProfileProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;

  UserDetailModel? _userDetailModel;
  UserDetailModel? get userDetailModel => _userDetailModel;

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
    {"title": "Profile Info", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Bank", "trailing": "assets/profile/greater_arrow.svg"},
    {
      "title": "Depository Participant",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {"title": "Closure", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Segments", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Annual Income", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Nominee", "trailing": "assets/profile/greater_arrow.svg"}
  ];

  final List _reporttMenu = [
    {"title": "Ledger", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Holdings", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Profit & Loss", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Tax P&L", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Trade", "trailing": "assets/profile/greater_arrow.svg"}
  ];

  List get profileMenu => _profileMenu;
  List get accountMenu => _accountMenu;
  List get reporttMenu => _reporttMenu;

  ClientDetailModel? _clientDetailModel;
  ClientDetailModel? get clientDetailModel => _clientDetailModel;
  UserProfileProvider(this.ref);

  Future fetchUserDetail(BuildContext context, String ueserId, String session,
      String toRoute) async {
    try {
      toggleLoadingOn(true);
      _userDetailModel = await api.getUserDetail(ueserId, session);

      if (_userDetailModel!.stat == "Ok") {
        // await ref(marketWatchProvider).changeWlName("");
        // if (toRoute == "preLoginDecive") {
        //   await ref(portfolioProvider).fetchHoldings(context, "");

        //   await ref(marketWatchProvider).fetchMWList(context);

        //   await ref(indexListProvider).getDeafultIndexList(context);
        //   await ref(portfolioProvider).fetchPositionBook(context, false);
        //   await ref(orderProvider).fetchOrderBook(context, false);
        //   await ref(orderProvider).fetchTradeBook(context);

        //   await ref(orderProvider).fetchGTTOrderBook(context, "initLoad");
        //   Navigator.pushNamedAndRemoveUntil(
        //       context, Routes.homeScreen, (route) => false);
        // }
        if (toRoute == "switchAcc") {
          Navigator.pop(context);

          ref(fundProvider).fetchFunds(context);
          await ref(portfolioProvider).fetchHoldings(context, "");

          await ref(marketWatchProvider).fetchMWList(context);

          await ref(indexListProvider).getDeafultIndexList(context);
          await ref(portfolioProvider).fetchPositionBook(context, false);
          await ref(orderProvider).fetchOrderBook(context, false);
          await ref(orderProvider).fetchTradeBook(context);

          await ref(orderProvider).fetchGTTOrderBook(context, "initLoad");
        }
      } else {
        if (_userDetailModel!.emsg ==
                "Session Expired :  Invalid Session Key" &&
            _userDetailModel!.stat == "Not_Ok") {
          ref(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
      return _userDetailModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API User Detail", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchClientDetail(BuildContext context) async {
    try {
      _clientDetailModel = await api.getClientDetail();

      if (_clientDetailModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }
      notifyListeners();
      return _clientDetailModel;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "API Client Detail", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  fetchsetting() {
    _settingMenu = [
      {
        "title": "API Key",
        "subTitle": "API Key",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Change Password",
        "subTitle": "Change Password",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      // {
      //   "title": "Theme",
      //   "subTitle": ref(themeProvider).deviceTheme,
      //   "leading": "assets/icon/theme_icon.svg",
      //   "trailing": "assets/profile/greater_arrow.svg"
      // },
      {
        "title": "Log",
        "subTitle": "Log message",
        "leading": "assets/profile/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
    ];
    notifyListeners();
    return settingmenu;
  }

  fetchprofilemenu() {
    _profileMenu = [
      {
        "title": "Fund",
        "subTitle": "Add Fund, Withdraw",
        "leading": "assets/profileimage/wallet.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).fundcase,
        "case": "Click here to view the fund information page."
      },
      {
        "title": "My Account",
        "subTitle": "Profile Details, Bank Accounts",
        "leading": "assets/profileimage/user_logo.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).accountcase,
        "case": "Click here to view the account page."
      },
      {
        "title": "Reports",
        "subTitle": "Ledger, Holdings, Profit&Loss",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).reportcase,
        "case": "Click here to view the report page."
      },
      {
        "title": "Corporate Action",
        "subTitle": "Corporate Action",
        "leading": "assets/profileimage/coa_edited.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).corporateactioncase,
        "case": "Click here to view the Corporate Action page."
      },
      {
        "title": "Pledge & Unpledge",
        "subTitle": "Pledge & Unpledge  ",
        "leading": "assets/profileimage/pledge.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).pledgeunpcase,
        "case": "Click here to view the Pledge & Unpledge page."
      },
      {
        "title": "Refer",
        "subTitle": "Refer your family and friends",
        "leading": "assets/profileimage/Referal_Incentive.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).apikeycase,
        "case": "Click here to view the Change Password page."
      },
      {
        "title": "Settings",
        "subTitle": "API key, Change Password, Log",
        "leading": "assets/profileimage/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).logcase,
        "case": "Click here to view the Log message."
      },
      {
        "title": "Notification",
        "subTitle": "Message, Exchange Status",
        "leading": "assets/icon/appbarIcon/bell.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref(showcaseProvide).notificationcase,
        "case": "Click here to view the Log message."
      },
      {
        "title": "Need Help?",
        "subTitle": "Contact us, Follow us",
        "leading": "assets/profile/headphones.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view the Log message."
      },
      // {
      //   "title": "API Key",
      //   "subTitle": "API Key",
      //   "leading": "assets/icon/key-01.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref(showcaseProvide).apikeycase,
      //   "case": "Click here to view the Change Password page."
      // },
      // {
      //   "title": "Change Password",
      //   "subTitle": "Change Password",
      //   "leading": "assets/icon/key-01.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref(showcaseProvide).changepasswordcase,
      //   "case": "Click here to view the Change Password page."
      // },
      // {
      //   "title": "App Tutorial",
      //   "subTitle": "Comming soon",
      //   "leading": "assets/icon/moon.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref(showcaseProvide).apptour,
      //   "case": "Click here to start the App tour."
      // },
      // {
      //   "title": "Theme",
      //   "subTitle": "Theme mode",
      //   "leading": "assets/icon/moon.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref(showcaseProvide).theamcase,
      //   "case": "Click here to view the Theme page."
      // },
      // {
      //   "title": "Log",
      //   "subTitle": "Log message",
      //   "leading": "assets/profile/privacy_settings.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref(showcaseProvide).logcase,
      //   "case": "Click here to view the Log message."
      // },
      // {
      //   "title": "Stocks",
      //   "subTitle": "Stocks Screen",
      //   "leading": "assets/profile/privacy_settings.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref(showcaseProvide).stokscase,
      //   "case": "Click here to view the Stocks page."
      // }
    ];
    return profileMenu;
  }
}

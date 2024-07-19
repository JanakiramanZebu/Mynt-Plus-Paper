 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/notification_model/broker_message_model.dart';
import '../models/notification_model/exchange_message_model.dart';
import '../models/notification_model/exchange_status_model.dart'; 
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final notificationprovider =
    ChangeNotifierProvider((ref) => NotificationProvider(ref.read));

class NotificationProvider extends DefaultChangeNotifier {
    final Preferences pref = locator<Preferences>();
  final api = locator<ApiExporter>();
  final Reader ref;
  NotificationProvider(this.ref);

  List<ExchangeMessageModel>? _exchangemessage;
  List<ExchangeMessageModel>? get exchangemessage => _exchangemessage;

  List<ExchangeStatusModel>? _exchangestatus;
  List<ExchangeStatusModel>? get exchangestatus => _exchangestatus;

  List<BrokerMessage>? _brokermsg;
  List<BrokerMessage>? get brokermsg => _brokermsg;

  /////TAB CONTROLLER
  late TabController notifytab;
  List<Tab> _notifyTabName = [
    const Tab(text: "Message"),
    const Tab(text: "Exchange Message"),
  ];
  List<Tab> get notifyTabName => _notifyTabName;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  changeTabIndex(int index) {
    _selectedTab = index;
  }

  tabSize() {
    _notifyTabName = [
      Tab(
        child: Text(
            "Message (${_brokermsg![0].stat == "Not_Ok" ? "0" : _brokermsg!.length})"),
      ),
      Tab(
          child: Text(
              "Exchange Message (${_exchangemessage![0].stat == "Not_Ok" ? "0" : _exchangemessage!.length})")),
    ];

    notifyListeners();
  }

  Future fetchexchagemsg(BuildContext context) async {
    
    try {
      _exchangemessage = await api.getexchmsg();
      if (_exchangemessage![0].emsg ==
          "Session Expired :  Invalid Session Key") {
         ref(authProvider). ifSessionExpired(  context);
      } else {
        ConstantName.sessCheck = true;
      }
      notifyListeners();
      return _exchangemessage;
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "Exch msg", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  // Future fetchexchagestatus(BuildContext context) async {
  //   final localstorage = await SharedPreferences.getInstance();
  //   try {
  //     _exchangestatus = await api.getexchstatus();
  //     // print("------------------------------------> ${_exchangestatus!.length}");
  //     // print(
  //     //     "------------------------------------> ${_exchangestatus![0].description}");
  //     if (_exchangestatus![0].emsg ==
  //         "Session Expired :  Invalid Session Key") {
  //       ref(authProvider).loginMethCtrl.text =
  //           localstorage.getString("userId") ?? "";
  //       Navigator.pushNamedAndRemoveUntil(
  //           context,
  //           Routes.loginScreen,
  //           arguments: "deviceLogin",
  //           (route) => false);
  //     }
  //     tabSize();
  //     notifyListeners();
  //     return _exchangestatus;
  //   } catch (e) {
  //     ref(indexListProvider)
  //         .logError
  //         .add({"type": "Exchange status", "Error": "$e"});
  //     notifyListeners();
  //   } finally {}
  // }

  Future fetchbrokermsg(BuildContext context) async {
    
    try {
      _brokermsg = await api.getbrokermsg();
      // print("------------------------------------> ${_brokermsg!.length}");
      // print("------------------------------------> ${_brokermsg![0].emsg}");
      if (_brokermsg![0].emsg == "Session Expired :  Invalid Session Key") {
         ref(authProvider). ifSessionExpired(  context);
      } else {
        ConstantName.sessCheck = true;
      }
      tabSize();
      notifyListeners();
      return _brokermsg;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "Broker msg", "Error": "$e"});
      notifyListeners();
    } finally {}
  }
}

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart'; 
import '../locator/preference.dart';
import '../models/profile_model/apikeymodel.dart';
import '../models/profile_model/generateapikey_model.dart';
import '../routes/route_names.dart'; 
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';


final apikeyprovider =
    ChangeNotifierProvider((ref) => ApikeyProvider(ref.read));


class ApikeyProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();  final Preferences pref = locator<Preferences>();
  final Reader ref;
  ApikeyProvider(this.ref);


  Apikeymodel? _apikeyres;
  Apikeymodel? get apikeyres => _apikeyres;


  GenerateApikeyModel? _generateApikey;
  GenerateApikeyModel? get generateApikey => _generateApikey;


  Future fetchapikey(BuildContext context) async {
    final localstorage = await SharedPreferences.getInstance();
    try {
      _apikeyres = await api.getapikey();
       ConstantName.sessCheck=true;
      if (_apikeyres!.emsg == "Session Expired :  Invalid Session Key" &&
          _apikeyres!.stat == "Not_Ok") {
                  pref .clearClientSession();
             ConstantName.sessCheck=false;
        ref(authProvider).loginMethCtrl.text =
            localstorage.getString("userId") ?? "";
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
            context, _apikeyres!.emsg!.replaceAll("Invalid Input :", "* ")));
        Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginScreen,
            arguments: "deviceLogin",
            (route) => false);
      }
      notifyListeners();
      return _apikeyres;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "Fetch API", "Error": "$e"});
      notifyListeners();
    } finally {}
  }


  Future fetchregenerateapikey(BuildContext context, String month) async {
    try {
      final localstorage = await SharedPreferences.getInstance();
      _generateApikey = await api.regenerateapikey(month);
        ConstantName.sessCheck=true;
      if (_generateApikey!.emsg == "Session Expired :  Invalid Session Key" &&
          _generateApikey!.stat == "Not_Ok") {             pref .clearClientSession();
             ConstantName.sessCheck=false;
        ref(authProvider).loginMethCtrl.text =
            localstorage.getString("userId") ?? "";
        ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
            _generateApikey!.emsg!.replaceAll("Invalid Input :", "* ")));
        Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginScreen,
            arguments: "deviceLogin",
            (route) => false);
      }
      notifyListeners();
      return _generateApikey;
    } catch (e) {
      ref(indexListProvider)
          .logError
          .add({"type": "Regenerate API", "Error": "$e"});
      notifyListeners();
    } finally {
      //_
    }
  }
}






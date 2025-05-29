import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/auth_model/totp_model.dart';
import '../models/profile_model/apikeymodel.dart';
import '../models/profile_model/generateapikey_model.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final apikeyprovider =
    ChangeNotifierProvider((ref) => ApikeyProvider(ref));

class ApikeyProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;
  ApikeyProvider(this.ref);

  Apikeymodel? _apikeyres;
  Apikeymodel? get apikeyres => _apikeyres;

  GenerateApikeyModel? _generateApikey;
  GenerateApikeyModel? get generateApikey => _generateApikey;

  TotpKey? _totpKey;
  TotpKey? get totpkey => _totpKey;

  bool _hidePass = true;
  bool get hidePass => _hidePass;

  hiddenPass() {
    _hidePass = !_hidePass;
    print("object ::: $_hidePass");
    notifyListeners();
  }

// Fetching data from the api and stored in a variable

  Future fetchapikey(BuildContext context) async {
    try {
      _apikeyres = await api.getapikey();
      ConstantName.sessCheck = true;
      if (_apikeyres!.emsg == "Session Expired :  Invalid Session Key" &&
          _apikeyres!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _apikeyres;
    } catch (e) {
      ref.read(indexListProvider).logError.add({"type": "Fetch API", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

// Fetching data from the api and stored in a variable
  Future fetchregenerateapikey(BuildContext context, String month) async {
    try {
      _generateApikey = await api.regenerateapikey(month);
      ConstantName.sessCheck = true;
      if (_generateApikey!.emsg == "Session Expired :  Invalid Session Key" &&
          _generateApikey!.stat == "Not_Ok") {
        ref.read(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _generateApikey;
    } catch (e) {
      ref.read(indexListProvider)
          .logError
          .add({"type": "Regenerate API", "Error": "$e"});
      notifyListeners();
    } finally {
      //_
    }
  }

  fetchTotp() async {
    _totpKey = await api.getTotp(false);
    if (_totpKey?.pwd == "") {
      _totpKey = await api.getTotp(true);
    }
  }
}

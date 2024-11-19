import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/profile_model/apikeymodel.dart';
import '../models/profile_model/generateapikey_model.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final apikeyprovider =
    ChangeNotifierProvider((ref) => ApikeyProvider(ref.read));

class ApikeyProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;
  ApikeyProvider(this.ref);

  Apikeymodel? _apikeyres;
  Apikeymodel? get apikeyres => _apikeyres;

  GenerateApikeyModel? _generateApikey;
  GenerateApikeyModel? get generateApikey => _generateApikey;

// Fetching data from the api and stored in a variable

  Future fetchapikey(BuildContext context) async {
    try {
      _apikeyres = await api.getapikey();
      ConstantName.sessCheck = true;
      if (_apikeyres!.emsg == "Session Expired :  Invalid Session Key" &&
          _apikeyres!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }
      notifyListeners();
      return _apikeyres;
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "Fetch API", "Error": "$e"});
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
        ref(authProvider).ifSessionExpired(context);
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

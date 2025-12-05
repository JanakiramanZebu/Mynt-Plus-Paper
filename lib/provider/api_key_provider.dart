import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/auth_model/totp_model.dart';
import '../models/profile_model/apikeymodel.dart';
import '../models/profile_model/generateapikey_model.dart';
import '../models/profile_model/generatenewapikey_model.dart';
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

  GenerateNewApiKeyModel? _generateApikeyNew;
  GenerateNewApiKeyModel? get generateApikeyNew => _generateApikeyNew;

  TotpKey? _totpKey;
  TotpKey? get totpkey => _totpKey;

  bool _hidePass = true;
  bool get hidePass => _hidePass;

  // Form Controllers
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _primaryIpController = TextEditingController();
  final TextEditingController _backupIpController = TextEditingController();
  
  TextEditingController get urlController => _urlController;
  TextEditingController get primaryIpController => _primaryIpController;
  TextEditingController get backupIpController => _backupIpController;

  // Form Variables
  bool _isHighFrequency = false;
  bool _hideSecret = true;
  String? _generatedSecretCode;

  bool get isHighFrequency => _isHighFrequency;
  bool get hideSecret => _hideSecret;
  String? get generatedSecretCode => _generatedSecretCode;

  hiddenPass() {
    _hidePass = !_hidePass;
    print("object ::: $_hidePass");
    notifyListeners();
  }

  // Form Methods
  void toggleSecretVisibility() {
    _hideSecret = !_hideSecret;
    notifyListeners();
  }

  void setHighFrequency(bool value) {
    _isHighFrequency = value;
    notifyListeners();
  }

  void populateFormFields() {
    if (_generateApikeyNew != null) {
      // If user has existing data (STAT = "Ok"), pre-fill the fields
      if (_generateApikeyNew!.stat == "Ok") {
        _urlController.text = _generateApikeyNew!.redirectUrl;
        if (_generateApikeyNew!.ipAddresses.isNotEmpty) {
          _primaryIpController.text = _generateApikeyNew!.ipAddresses.first.ipAddress;
        }
        if (_generateApikeyNew!.ipAddresses.length > 1) {
          _backupIpController.text = _generateApikeyNew!.ipAddresses[1].ipAddress;
        }
      } else {
        // If user has no data (STAT = "Not_Ok"), clear fields for new entry
        _urlController.clear();
        _primaryIpController.clear();
        _backupIpController.clear();
      }
    }
  }

  // Generate a random secret code that changes on each refresh
  String generateSecretCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(32, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Generate new secret code for existing API key (when user clicks regenerate)
  void generateNewSecretCode() {
    print("=== REGENERATING SECRET CODE ===");
    print("Before: URL=${_urlController.text}, PrimaryIP=${_primaryIpController.text}, BackupIP=${_backupIpController.text}");
    _generatedSecretCode = generateSecretCode();
    print("After: URL=${_urlController.text}, PrimaryIP=${_primaryIpController.text}, BackupIP=${_backupIpController.text}");
    print("New Secret Code: $_generatedSecretCode");
    notifyListeners();
  }

  void clearFormFields() {
    _urlController.clear();
    _primaryIpController.clear();
    _backupIpController.clear();
    _isHighFrequency = false;
    _hideSecret = true;
    notifyListeners();
  }

  // Validation Methods

  @override
  void dispose() {
    _urlController.dispose();
    _primaryIpController.dispose();
    _backupIpController.dispose();
    super.dispose();
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

Future fetchgenerateapikey(BuildContext context, String month) async {
    try {
      _generateApikey = await api.generateapikeynewuser(month);
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


// neww

  Future fetchgenerateapikeynew(BuildContext context) async {
    try {
      _generateApikeyNew = await api.getapikeynew();
      
      // If no existing data (STAT = "Not_Ok"), generate a new secret code and create new model with client ID from prefs
      if (_generateApikeyNew != null && _generateApikeyNew!.stat != "Ok") {
        _generatedSecretCode = generateSecretCode();
        // Create new model instance with hardcoded client ID for now
        _generateApikeyNew = GenerateNewApiKeyModel(
          stat: _generateApikeyNew!.stat,
          appKey: "${pref.clientId ?? ""}_U", 
          displayName: "${pref.clientId ?? ""} API Key", // Default display name for new API key
          secretCode: _generateApikeyNew!.secretCode,
          redirectUrl: _generateApikeyNew!.redirectUrl,
          ipAddresses: _generateApikeyNew!.ipAddresses,
          exchangeAlgos: _generateApikeyNew!.exchangeAlgos,
          userIds: [UserIdEntry(userId: pref.clientId ?? "")], // Default user ID for new API key
        );
      } else {
        _generatedSecretCode = null; // Use existing secret code
      }
      
      populateFormFields(); // Populate form fields when data is loaded
      notifyListeners();
      return _generateApikeyNew;
    } catch (e) {
      ref.read(indexListProvider)
          .logError
          .add({"type": "Generate API", "Error": "$e"});
      notifyListeners();
    }
  }


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

  Future<GenerateNewApiKeyModel?> submitApiKeyNew({
    required String appKey,
    required String secretCode,
    required String redirectUrl,
    required String displayName,
    required List<String> ipAddresses,
    required List<String> userIds,
  }) async {
    try {
      _generateApikeyNew = await api.submitApiKeyNew(
        appKey: appKey,
        secretCode: secretCode,
        redirectUrl: redirectUrl,
        displayName: displayName,
        ipAddresses: ipAddresses,
        userIds: userIds,
      );
      
      notifyListeners();
        return _generateApikeyNew;
    } catch (e) {
      rethrow;
    }
  }
}

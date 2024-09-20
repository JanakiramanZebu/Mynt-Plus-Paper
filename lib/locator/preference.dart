import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _prefInstance;

  Future<void> init() async {
    _prefInstance = await SharedPreferences.getInstance();
  }

  Future clearLocalPref() async {
    await _prefInstance?.clear();
  }

  Future clearClientSession() async {
    await _prefInstance?.remove(_clientSession);
  }
  // setters

  Future setTheme(bool theme) async {
    await _prefInstance!.setBool(_userTheme, theme);
  }

  Future setMobileLogin(bool isMobile) async =>
      await _prefInstance!.setBool(_ismobileLogin, isMobile);

  Future setLogout(bool isLogout) async =>
      await _prefInstance!.setBool(_isLogout, isLogout);

  Future setHideLoginOptBtn(bool isHide) async =>
      await _prefInstance!.setBool(_hideLoginOptBtn, isHide);

  Future setAppTheme(String theme) async {
    await _prefInstance!.setString(_userAppTheme, theme);
  }

  Future setDeviceName(String deviceName) async {
    await _prefInstance!.setString(_deviceName, deviceName);
  }

// SET Cleint Details

  Future setClientId(String id) async =>
      await _prefInstance!.setString(_clientId, id);
  Future setClientSession(String session) async =>
      await _prefInstance!.setString(_clientSession, session);
  Future setApiToken(String session) async =>
      await _prefInstance!.setString(_apiToken, session);
  Future setClientName(String name) async =>
      await _prefInstance!.setString(_clientName, name);
  Future setClientMob(String mob) async =>
      await _prefInstance!.setString(_clientMob, mob);
  // Future setLogoutClient(String logout) async =>
  //     await _prefInstance!.setString(_logOutClient, logout);
  Future setLoggedClientList(List<String> clients) async =>
      await _prefInstance!.setStringList(_clientList, clients);

  // getters

  bool? get userTheme => _prefInstance?.getBool(_userTheme);
  bool? get isMobileLogin => _prefInstance?.getBool(_ismobileLogin) ?? true;
  bool? get islogOut => _prefInstance?.getBool(_isLogout) ?? false;
  bool? get hideLoginOptBtn =>
      _prefInstance?.getBool(_hideLoginOptBtn) ?? false;

  String? get userAppTheme =>
      _prefInstance?.getString(_userAppTheme) ?? "System Default";

  // String? get logoutClient => _prefInstance?.getString(_logOutClient) ?? "";
  String? get deviceName => _prefInstance?.getString(_deviceName) ?? "";

// GET Cleint Details
  String? get clientId => _prefInstance?.getString(_clientId) ?? "";
  String? get clientSession => _prefInstance?.getString(_clientSession) ?? "";
  String? get token => _prefInstance?.getString(_apiToken) ?? "";
  String? get clientMob => _prefInstance?.getString(_clientMob) ?? "";
  String? get clientName => _prefInstance?.getString(_clientName) ?? "";

  List<String>? get loggedClient =>
      _prefInstance?.getStringList(_clientList) ?? [];

  // Orders

  Future setBasketScrip(String scrips) async =>
      await _prefInstance!.setString(_basketScrips, scrips);
  Future setBasketList(String scrips) async =>
      await _prefInstance!.setString(_basketList, scrips);

  String? get bsktScrips => _prefInstance?.getString(_basketScrips) ?? "";

  String? get bsktList => _prefInstance?.getString(_basketList) ?? "";
}

const String _userTheme = 'userTheme';
const String _userAppTheme = 'userAppTheme';

// const String _logOutClient = 'logOutClient';
const String _isLogout = "isLogout";
const String _deviceName = 'deviceName';
const String _ismobileLogin = 'ismobileLogin';

const String _hideLoginOptBtn = 'hideLoginOptBtn';

// Cleint Details
const String _clientId = 'clientId';
const String _clientSession = 'clientSession';
const String _apiToken = 'apiToken';

const String _clientMob = 'clientMob';
const String _clientName = 'clientName';
const String _clientList = 'clientList';

const String _basketList = 'basketList';
const String _basketScrips = 'basketScrips';

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
  Future setImei(String val) async =>
      await _prefInstance!.setString(_imei, val);
  Future setClientMob(String mob) async =>
      await _prefInstance!.setString(_clientMob, mob);
  // Future setLogoutClient(String logout) async =>
  //     await _prefInstance!.setString(_logOutClient, logout);
  Future setLoggedClientList(List<String> clients) async =>
      await _prefInstance!.setStringList(_clientList, clients);

  //// ORDER BOOK FILTER
  Future setOBScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isObScripName, isselect);

  Future setOBPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isObPrice, isselect);

  Future setOBtime(bool isselect) async =>
      await _prefInstance!.setBool(_isTime, isselect);

  Future setOBqty(bool isselect) async =>
      await _prefInstance!.setBool(_isObQuantity, isselect);

  Future setOBproduct(bool isselect) async =>
      await _prefInstance!.setBool(_isProduct, isselect);

  //// ORDER BOOK GTT FILTER
  Future setGTTScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isGttScripName, isselect);

  Future setGTTPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isGttPrice, isselect);

  Future setGTTtime(bool isselect) async =>
      await _prefInstance!.setBool(_isGttTime, isselect);

  Future setGTTqty(bool isselect) async =>
      await _prefInstance!.setBool(_isGttQuantity, isselect);

  Future setGTTproduct(bool isselect) async =>
      await _prefInstance!.setBool(_isGttProduct, isselect);

//// MARKET WATCH FILTER
  Future setMWScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isMWScripName, isselect);

  Future setMWPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isMWPrice, isselect);

  Future setMWPerchnage(bool isselect) async =>
      await _prefInstance!.setBool(_isMWPrechange, isselect);

//// Holding Filter
  Future setScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isScripName, isselect);

  Future setPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isPrice, isselect);

  Future setqty(bool isselect) async =>
      await _prefInstance!.setBool(_isQuantity, isselect);

  Future setPerchnage(bool isselect) async =>
      await _prefInstance!.setBool(_isPrechange, isselect);

  Future setInvestby(bool isselect) async =>
      await _prefInstance!.setBool(_isInvest, isselect);
//// Mf Filter
  Future setMfScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isMfScripName, isselect);

  Future setMfPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isMfPrice, isselect);

  Future setMfqty(bool isselect) async =>
      await _prefInstance!.setBool(_isMfQuantity, isselect);

  Future setMfPerchnage(bool isselect) async =>
      await _prefInstance!.setBool(_isMfPrechange, isselect);

  Future setMfInvestby(bool isselect) async =>
      await _prefInstance!.setBool(_isMfInvest, isselect);

//// POSTION Filter
  Future setPosScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isPosScripName, isselect);

  Future setPosPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isPosPrice, isselect);

  Future setPosqty(bool isselect) async =>
      await _prefInstance!.setBool(_isPosQuantity, isselect);

  Future setPosPerchnage(bool isselect) async =>
      await _prefInstance!.setBool(_isPosPrechange, isselect);

  Future setPostion(bool isselect) async =>
      await _prefInstance!.setBool(_isPostion, isselect);

  //// PENDING ALERT FILTER
  Future setPAScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isPAScripName, isselect);

  Future setPAPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isPAPrice, isselect);

  Future setPAPriceAlert(bool isselect) async =>
      await _prefInstance!.setBool(_isPApricealert, isselect);

  //// TRADE BOOK FILTER
  Future setTbScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isTbScripName, isselect);

  Future setTbPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isTbPrice, isselect);

  Future setTbBuyOrSell(bool isselect) async =>
      await _prefInstance!.setBool(_isTbBuyorSell, isselect);

  Future setTbTime(bool isselect) async =>
      await _prefInstance!.setBool(_isTbTime, isselect);

  //// SIP  FILTER
  Future setSipScrip(bool isselect) async =>
      await _prefInstance!.setBool(_isSipScripName, isselect);

  Future setSipPrice(bool isselect) async =>
      await _prefInstance!.setBool(_isSipPrice, isselect);

  Future setSipChange(bool isselect) async =>
      await _prefInstance!.setBool(_isSipPerchange, isselect);

  Future setSipDate(bool isselect) async =>
      await _prefInstance!.setBool(_isSipDate, isselect);

  /// ORDER BOOK Filter
  bool? get isObScripname => _prefInstance?.getBool(_isObScripName) ?? true;
  bool? get isObPrice => _prefInstance?.getBool(_isObPrice) ?? true;
  bool? get isObqty => _prefInstance?.getBool(_isObQuantity) ?? true;
  bool? get isObtime => _prefInstance?.getBool(_isTime) ?? true;
  bool? get isObProduct => _prefInstance?.getBool(_isProduct) ?? true;

  /// ORDER BOOK GTT Filter
  bool? get isGttScripname => _prefInstance?.getBool(_isGttScripName) ?? true;
  bool? get isGttPrice => _prefInstance?.getBool(_isGttPrice) ?? true;
  bool? get isGttqty => _prefInstance?.getBool(_isGttQuantity) ?? true;
  bool? get isGtttime => _prefInstance?.getBool(_isGttTime) ?? true;
  bool? get isGttProduct => _prefInstance?.getBool(_isGttProduct) ?? true;

  /// MARKET WATCH Filter
  bool? get isMWScripname => _prefInstance?.getBool(_isMWScripName) ?? true;
  bool? get isMWPrice => _prefInstance?.getBool(_isMWPrice) ?? true;
  bool? get isMWPerchang => _prefInstance?.getBool(_isMWPrechange) ?? true;

  /// Holdings Filter
  bool? get isScripname => _prefInstance?.getBool(_isScripName) ?? true;
  bool? get isPrice => _prefInstance?.getBool(_isPrice) ?? true;
  bool? get isQuantity => _prefInstance?.getBool(_isQuantity) ?? true;
  bool? get isPerchang => _prefInstance?.getBool(_isPrechange) ?? true;
  bool? get isInvestby => _prefInstance?.getBool(_isInvest) ?? true;

  ////// MF Filter
  bool? get isMfScripname => _prefInstance?.getBool(_isMfScripName) ?? true;
  bool? get isMfQuantity => _prefInstance?.getBool(_isMfQuantity) ?? true;
  bool? get isMfPrice => _prefInstance?.getBool(_isMfPrice) ?? true;
  bool? get isMfPerchang => _prefInstance?.getBool(_isMfPrechange) ?? true;
  bool? get isMfInvestby => _prefInstance?.getBool(_isMfInvest) ?? true;

  ////// Postion Filter
  bool? get isPosScripname => _prefInstance?.getBool(_isPosScripName) ?? true;
  bool? get isPosQuantity => _prefInstance?.getBool(_isPosQuantity) ?? true;
  bool? get isPosPrice => _prefInstance?.getBool(_isPosPrice) ?? true;
  bool? get isPosPerchang => _prefInstance?.getBool(_isPosPrechange) ?? true;
  bool? get isPostion => _prefInstance?.getBool(_isPostion) ?? true;

  /// PENDING ALERT FILTER
  bool? get isPAScripname => _prefInstance?.getBool(_isPAScripName) ?? true;
  bool? get isPAPrice => _prefInstance?.getBool(_isPAPrice) ?? true;
  bool? get isPAPricealert => _prefInstance?.getBool(_isPApricealert) ?? true;

  /// TRADE BOOK FILTER
  bool? get isTBScripname => _prefInstance?.getBool(_isTbScripName) ?? true;
  bool? get isTBPrice => _prefInstance?.getBool(_isTbPrice) ?? true;
  bool? get isTBBuyorSell => _prefInstance?.getBool(_isTbBuyorSell) ?? true;
  bool? get isTBTime => _prefInstance?.getBool(_isTbTime) ?? true;

  /// SIP FILTER
  bool? get isSipScripname => _prefInstance?.getBool(_isSipScripName) ?? true;
  bool? get isSipPrice => _prefInstance?.getBool(_isSipPrice) ?? true;
  bool? get isSipChange => _prefInstance?.getBool(_isSipPerchange) ?? true;
  bool? get isSipDate => _prefInstance?.getBool(_isSipDate) ?? true;

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
  String? get imei => _prefInstance?.getString(_imei) ?? "";

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
const String _imei = 'imei';

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

////MARKET WATCH Filter
const String _isMWScripName = "isMWScripName";
const String _isMWPrice = "isMWPrice";
const String _isMWPrechange = "isMWPrechange";

////Holdings Filter
const String _isScripName = "isScripName";
const String _isPrice = "isPrice";
const String _isQuantity = "isQuantity";
const String _isPrechange = "isPrechange";
const String _isInvest = "isInvest";

///MF FILTER
const String _isMfScripName = "isMfScripName";
const String _isMfPrice = "isMfPrice";
const String _isMfQuantity = "isMfQuantity";
const String _isMfPrechange = "isMfPrechange";
const String _isMfInvest = "isMfInvest";

///POSTION FILTER
const String _isPosScripName = "isPosScripName";
const String _isPosPrice = "isPosPrice";
const String _isPosQuantity = "isPosQuantity";
const String _isPosPrechange = "isPosPrechange";
const String _isPostion = "isPostion";

////OREDER BOOK FILTER
const String _isObScripName = "isObScripName";
const String _isObPrice = "isObPrice";
const String _isObQuantity = "isObQuantity";
const String _isTime = "isTime";
const String _isProduct = "isProduct";

////OREDER BOOK GTT FILTER
const String _isGttScripName = "isgttScripName";
const String _isGttPrice = "isgttPrice";
const String _isGttQuantity = "isgttQuantity";
const String _isGttTime = "isgttTime";
const String _isGttProduct = "isgttProduct";

////PENDING ALERT FILTER
const String _isPAScripName = "ispaScripName";
const String _isPAPrice = "ispaPrice";
const String _isPApricealert = "ispapricealert";

////TRADE BOOK FILTER
const String _isTbScripName = "isTbScripName";
const String _isTbPrice = "isTbPrice";
const String _isTbBuyorSell = "isTbBuyorSell";
const String _isTbTime = "isTbTime";

////SIP FILTER
const String _isSipScripName = "isSipScripName";
const String _isSipPrice = "isSipPrice";
const String _isSipPerchange = "isSipPerchange";
const String _isSipDate = "isSipDate";

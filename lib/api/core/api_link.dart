class ApiLinks {
  static String source = "MOB";
  // static String userID = "ZVK0106";
  // static String session = "";
  static String wsURL = 'wss://go.mynt.in/NorenWS/';
  static String otp = "";
  static String userName = "";
  static bool showAppTutorial = true;
// GO MYNT

  String get goMyntURL => "https://go.mynt.in/NorenWClient";
  String get newsurl => "https://be.mynt.in/news";

  ///generate api key
  String get apiKey => '$goMyntURL/RequestApiKey';
  String get generateapiKey => '$goMyntURL/UserApiKeyRenReq';

  // Notification service
  String get exchStatus => '$goMyntURL/ExchStatus';
  String get exchMsg => '$goMyntURL/ExchMsg';
  String get brokermsg => '$goMyntURL/GetBrokerMsg';

  ////Set Alert
  String get setAlert => '$goMyntURL/SetAlert';
  String get cancelAlert => '$goMyntURL/CancelAlert';
  String get pendingalert => '$goMyntURL/GetPendingAlert';
  String get modifyalert => '$goMyntURL/ModifyAlert';

// Market watxhlist

  String get watchList => '$goMyntURL/MWList';
  String get preDefinedMWList => '$goMyntURL/PreDefinedMWList';
  // String get preDefinedMarketWatchScrip => '$goMyntURL/PreDefinedMW';
  String get marketWatchScrip => '$goMyntURL/MarketWatch';
  String get securityInfo => '$goMyntURL/GetSecurityInfo';
  String get getQuotes => '$goMyntURL/GetQuotes';
  String get getLinkedScrip => '$goMyntURL/GetLinkedScrips';
  String get optionChain => '$goMyntURL/GetOptionChain';
  String get deleteMWScrips => '$goMyntURL/DeleteMultiMWScrips';
  String get addMWScrips => '$goMyntURL/AddMultiScripsToMW';
  String get searchScrip => '$goMyntURL/SearchScrip';
  String get technicalData => '$goMyntURL/GetTechnicals';

// Market Index

  String get marketIndex => '$goMyntURL/GetIndexList';

// Profile

  String get userDetail => '$goMyntURL/UserDetails';
  String get clientDetail => '$goMyntURL/ClientDetails';

// Trade data

  String get getPosition => '$goMyntURL/PositionBook';
  String get getHoldings => '$goMyntURL/Holdings';
  String get getMFHoldings => '$goMyntURL/GetMFSSHoldInfo';
  String get getQuotesMF => '$goMyntURL/GetQuotesMF';

  String get getOrder => '$goMyntURL/OrderBook';
  String get positionConvert => '$goMyntURL/ProductConversion';
  String get orderHistory => '$goMyntURL/SingleOrdHist';
  String get sipOrderBook => '$goMyntURL/SipOrderBook';
  String get multiLegOrderBook => '$goMyntURL/MultiLegOrderBook';
  String get tradeBook => '$goMyntURL/TradeBook';
  String get cancleSiporder => '$goMyntURL/CancelSipOrder';
  String get pendingGttorder => '$goMyntURL/GetPendingGTTOrder';
  String get cancelGTTOrder => '$goMyntURL/CancelGTTOrder';

// Order

  String get orderMargin => '$goMyntURL/GetOrderMargin';
  String get exitSNOOrder => '$goMyntURL/ExitSNOOrder';

  String get getBrokerage => '$goMyntURL/GetBrokerage';
  String get placeOrder => '$goMyntURL/PlaceOrder';
  String get cancelOrder => '$goMyntURL/CancelOrder';
  String get placeGTTOrder => '$goMyntURL/PlaceGTTOrder';
  String get placeOCOOrder => '$goMyntURL/PlaceOCOOrder';
  String get modifyGTTOrder => '$goMyntURL/ModifyGTTOrder';
  String get modifyOCOOrder => '$goMyntURL/ModifyOCOOrder';
  String get mdifyOrder => '$goMyntURL/ModifyOrder';
// Fund

  String get getHsToken => '$goMyntURL/GetHsToken';
  String get getlimits => '$goMyntURL/Limits';

// Logout

  String get logout => '$goMyntURL/Logout';

// Local

  String get mainBaseURL => 'https://copy.mynt.in';

  // String get mobileLogin => '$mainBaseURL/mobile_login';
  String get mobileLogin => '$mainBaseURL/MobileLogin';

  String get mobileOtp => '$mainBaseURL/otp_verify';

  String get loginOtp => '$mainBaseURL/otp_send_Tv';
  String get loginOtpVerify => '$mainBaseURL/otp_verify';
  String get deviceLogin => '$mainBaseURL/device_login';
  String get validateSession => '$mainBaseURL/validate_session';

  String get forgetPassword => '$mainBaseURL/ForgetPassword';

  String get myntchangePassword => '$mainBaseURL/ChangePass';

  String get placeSipOrder => '$mainBaseURL/PlaceSipOrder';

  String get preDefdMWatchScrip => '$mainBaseURL/PreDefinedMW';
  String get getAllIndx => '$mainBaseURL/GetIndexList';

  // Scrip Overview

  // String get scripOverviewUrl => 'http://192.168.5.142:5000';

  // String get fundamental => '$scripOverviewUrl/stockFundamentalDetails';
  // String get stockHoldings => '$scripOverviewUrl/stockHoldings';
  // String get preDefWLscrip => '$scripOverviewUrl/PreDefinedMW';

  String get scripOverviewUrl1 => 'http://192.168.5.209:5005';

  String get mainBaseURL1 => 'http://192.168.5.82:5000';
  // String get mainBaseURL1 => 'http://192.168.5.83:5000';
  String get getClientTrades => '$mainBaseURL1/getClientTrades';

  // Stock data URL

  String stockUrl = "https://v3.mynt.in";

  // String tradeAction = "https://v3.mynt.in/equity/getadindicesAdvdec";

  String get fundamentalDetail => '$stockUrl/equity/stockFundamentalDetails';
  String get topListStock => '$stockUrl/equity/TopList';
  String get getGlobalIndex => '$stockUrl/equity/getGlobalIndex';

  String get getadindices => '$stockUrl/equity/getadindices';
  String get getadindicesAdvdec => '$stockUrl/equity/getadindicesAdvdec';

  String get getCorporateAction => '$stockUrl/ipo/getCorporateAction';
  String get getStockMonitor => '$stockUrl/equity/GetContentList';

  /// Qr Scanner
  String get getQrScanner => '$mainBaseURL/QRMobileReq';

  ///ipo///
  String get ipomainBaseURL => 'https://v3.mynt.in/ipo';
  String get smeipos => "$ipomainBaseURL/getcurrentSMEIPOdetails";
  String get mainstreamipo => "$ipomainBaseURL/getcurrentIPOdetails";
  String get ipoperformance => "$ipomainBaseURL/ipo_performer?year=2024";
  String get placeipoorder => "$ipomainBaseURL/addIPOtoPortfolio";
  String get ipoorderbook => "$ipomainBaseURL/orderbookIPODetails";
  //hdfc mainurl//
  String get hdfcmainurl => 'https://fundapi.mynt.in/hdfc/upi';
  String get hdfcupicheck => '$hdfcmainurl/checkClientVPA';
  //fund urlss///
  String get viewupiid => 'https://fundapi.mynt.in/withdraw/view_upi_id';

// Bonds
  String get bondBaseURL => 'https://besim.zebull.in';
  String get getSGB => "$bondBaseURL/getcurrentSGBdetails";
  String get getGSec => "$bondBaseURL/getcurrentNCB_Gsecdetails";
  String get getTBill => "$bondBaseURL/getcurrentNCB_TBilldetails";
  String get getSDL => "$bondBaseURL/getcurrentNCB_SDLdetails";

  String get ledgerBaseURL => 'https://rekycbe.mynt.in';
  String get getLedgerBal => "$ledgerBaseURL/all_ledger_balance";
}

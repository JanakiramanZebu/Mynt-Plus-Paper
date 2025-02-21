class ApiLinks {
// UAT----

  // String get goMyntURL => "https://uat.mynt.in/NorenWClient";
  // static String wsURL = 'wss://uat.mynt.in/NorenWSMob/';

  static String source = "MOB";
  static String otp = "";
  static String userName = "";
  static bool showAppTutorial = true;

// GO MYNT-----

  String get goMyntURL => "https://go.mynt.in/NorenWClient";
  static String wsURL = 'wss://go.mynt.in/NorenWS/';
  String get newsurl => "https://be.mynt.in/news";

  ///generate api key
  String get apiKey => '$goMyntURL/RequestApiKey';
  String get generateapiKey => '$goMyntURL/UserApiKeyRenReq';
  String get totp => "$goMyntURL/GetSecretKey";

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
  String get watchListrename => '$goMyntURL/RenameMW';

  // Cams
  String get goCamsURL => "https://rekycbe.mynt.in/portfolio";
  String get getCames => '$goCamsURL/broker_dateils_get';
  String get getCamesauth => '$goCamsURL/login/auth';

// Market Index

  String get marketIndex => '$goMyntURL/GetIndexList';

// Profile

  String get userDetail => '$goMyntURL/UserDetails';
  String get clientDetail => '$goMyntURL/ClientDetails';
  String get freezeAccount => '$goMyntURL/FreezeAccount';
  String get blockAcct => '$goMyntURL/BlockAcct';

// Trade data

  String get getPosition => '$goMyntURL/PositionBook';
  String get getHoldings => '$goMyntURL/Holdings';
  String get getMFHoldings => '$goMyntURL/GetMFSSHoldInfo';
  String get getQuotesMF => '$goMyntURL/GetQuotesMF';

  String get getOrder => '$goMyntURL/OrderBook';
  String get positionConvert => '$goMyntURL/ProductConversion';
  String get orderHistory => '$goMyntURL/SingleOrdHist';
  String get modifySipOrder => '$goMyntURL/ModifySipOrder';
  String get sipOrderBook => '$goMyntURL/SipOrderBook';
  String get multiLegOrderBook => '$goMyntURL/MultiLegOrderBook';
  String get tradeBook => '$goMyntURL/TradeBook';
  String get cancleSiporder => '$goMyntURL/CancelSipOrder';
  String get pendingGttorder => '$goMyntURL/GetPendingGTTOrder';
  String get cancelGTTOrder => '$goMyntURL/CancelGTTOrder';
  String get basketMargin => '$goMyntURL/GetBasketMargin';

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

// Local Server ---------

  // UAT-----

  // String get mainBaseURL => 'https://copy.mynt.in/uat';

  String get mainBaseURL => 'https://copy.mynt.in';

  String get mobileLogin => '$mainBaseURL/MobileLogin';

  String get mobileOtp => '$mainBaseURL/otp_verify';

  String get loginOtp => '$mainBaseURL/otp_send_Tv';
  String get loginOtpVerify => '$mainBaseURL/otp_verify';
  String get deviceLogin => '$mainBaseURL/device_login';
  String get validateSession => '$mainBaseURL/validate_session';

  String get forgetPassword => '$mainBaseURL/ForgetPassword';

  String get myntchangePassword => '$mainBaseURL/ChangePass';

  String get placeSipOrder => '$goMyntURL/PlaceSipOrder';

  String get preDefdMWatchScrip => '$mainBaseURL/PreDefinedMW';
  String get getAllIndx => '$mainBaseURL/GetIndexList';

  // Position Group
  String get positionGrp => '$mainBaseURL/Getpositiongrp';
  String get creatGrpName => '$mainBaseURL/Createpositiongrp';
  String get addSymbolGrp => '$mainBaseURL/addsymbolpositiongrp';
  String get delpositiongrpName => '$mainBaseURL/Deletepositiongrp';
  String get delpositiongrpSym => '$mainBaseURL/removesymbolpositiongrp';

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

  String dashBoardURL = "https://v3.mynt.in";

  // String tradeAction = "https://v3.mynt.in/equity/getadindicesAdvdec";

  String get fundamentalDetail =>'$dashBoardURL/equity/stockFundamentalDetails';
  String get topListStock => '$dashBoardURL/equity/TopList';
  String get getGlobalIndex => '$dashBoardURL/equity/getGlobalIndex';
  String get getadindices => '$dashBoardURL/equity/getadindices';
  String get getadindicesAdvdec => '$dashBoardURL/equity/getadindicesAdvdec';
  String get getCorporateAction => '$dashBoardURL/ipo/getCorporateAction';
  String get getStockMonitor => '$dashBoardURL/equity/GetContentList';

  /// Qr Scanner
  String get getQrScanner => '$mainBaseURL/QRMobileReq';

  ///ipo///
  String get ipourlendpoint =>"${dashBoardURL}/ipo/";
  String get dashboardipos => "${ipourlendpoint}IpoDashboard";
  String get smeipos => "${ipourlendpoint}getcurrentSMEIPOdetails";
  String get mainstreamipo => "${ipourlendpoint}getcurrentIPOdetails";
  String get ipoperformance => "${ipourlendpoint}ipo_performer?year=2024";
  String get placeipoorder => "${ipourlendpoint}addIPOtoPortfolio";
  String get ipoorderbook => "${ipourlendpoint}orderbookIPODetails";
  String get iposinglepage => "${ipourlendpoint}get_single_ipo_data_new";
  String get ipoprecloseurl => "${ipourlendpoint}precloseipo";


// Mutual Fund
  String get bestMf => "$dashBoardURL/mf/z_data_1";
  String get mfCategoryList => "$dashBoardURL/mf/getCategoryschemes";
  String get mfCategoryListData => "$dashBoardURL/mf/get_title_values";
  String get mfCategoryTypes => "$dashBoardURL/mf/getCategoryType";
  String get masterMF => "$dashBoardURL/mf/master_file_datas";
  String get nfoMF => "https://v3.mynt.in/mf/NFO_datas";
  String get searchMF => "https://v3.mynt.in/mf/mfsearch";
  String get mfWatchlist => "$dashBoardURL/mf/watchlist_for_mobile";
  String get factSheetData => "$dashBoardURL/mf/getFactSheetData";
  String get navGraph => "$dashBoardURL/mf/getNavGraph";
  String get factSheetGraph => "$dashBoardURL/mf/getFactSheetGraph";
  String get schemePeers => "$dashBoardURL/mf/getSchemePeers";
  String get postRollingReturn => "$dashBoardURL/mf/postRollingReturn";
  String get bankDetail => "$dashBoardURL/mf/client_bank_details";
  String get mfSip => "$dashBoardURL/mf/sip_values";
  String get mandateDetail => "$dashBoardURL/mf/mandate_details";
  String get lumpsumOrder => "$dashBoardURL/mf/lumsum_purchase";
  String get lumpsumOrderbook => "$dashBoardURL/mf/mf_orderbook";
  String get mandatecreate => "$dashBoardURL/mf/mandate_creation";
  String get mfXSiporder=> "$dashBoardURL/mf/xsip_purchase";
  String get mfXsipcancleRes => "$dashBoardURL/mf/reasons";
  String get mfxsipcancel => "$dashBoardURL/mf/xsip_cancel";
  // String get mfallpayment => "https://v3.mynt.in/mf//all_payment";
  String get mfallpayment => "$dashBoardURL/mf/lumsum_purchase_mob";
  String get topSchemes => "$dashBoardURL/mf/getTopschemes";
  String get redemption => "$dashBoardURL/mf/lumsum_redemption_mob";

  


  String get mainfund => 'https://fundapi.mynt.in/api';
  String get clientcheck => '$mainfund/client_check';
  String get bankcheck => '$mainfund/bank_check';

  ///withdraw
  String get fundUpiIdView => 'https://fundapi.mynt.in/withdraw/upi_id_view';
  String get withdraw => 'https://fundapi.mynt.in/withdraw/payout';
  String get paymentwithdraw => 'https://fundapi.mynt.in/withdraw/payment';
  String get withdrawstatus => 'https://fundapi.mynt.in/withdraw/status';

  String fundvalidatetoken = "https://rekycbe.mynt.in/autho/validate_session";

  /////
  String get upimainfund => 'https://fundapi.mynt.in';
  String get fundpayment => "$upimainfund/hdfc/upi/UPItransactionRequest";
  String get fundUpiStatus => "$upimainfund/hdfc/upi/MobileUPIstatus";

  //hdfc mainurl//
  String get hdfcmainurl => 'https://fundapi.mynt.in/hdfc/upi';
  String get verifyUPI => '$hdfcmainurl/checkClientVPA';
  String get moneytransction => '$hdfcmainurl/transactionRequest';
  String get tranctiontstatus => '$hdfcmainurl/paymentstatus';

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

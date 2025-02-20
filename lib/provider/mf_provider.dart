import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/mf_model/best_mf_list_model.dart';
import '../models/mf_model/best_mf_model.dart';
import '../models/mf_model/mandate_detail_model.dart';
import '../models/mf_model/mf_all_payment_model.dart';
import '../models/mf_model/mf_bank_detail_model.dart';
import '../models/mf_model/mf_category_list_model.dart';
import '../models/mf_model/mf_categorytype_model.dart';
import '../models/mf_model/mf_create_mandate.dart';
import '../models/mf_model/mf_factsheet_data_model.dart';
import '../models/mf_model/mf_factsheet_graph.dart';
import '../models/mf_model/mf_lumpsum_order.dart';
import '../models/mf_model/mf_nav_graph_model.dart';
import '../models/mf_model/mf_nfo_model.dart';
import '../models/mf_model/mf_orderbook_lumpsum_model.dart';
import '../models/mf_model/mf_scheme_peers_model.dart';
import '../models/mf_model/mf_search_model.dart';
import '../models/mf_model/mf_sip_model.dart';
import '../models/mf_model/mf_watch_list.dart';
import '../models/mf_model/mf_x_sip_order_responces.dart';
import '../models/mf_model/mf_xsip_cancle_resone_res.dart';
import '../models/mf_model/mutual_fundmodel.dart';
import '../models/mf_model/top_schemes_model.dart';
import '../models/mf_model/x_sip_cancel_order_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/functions.dart';
import '../sharedWidget/snack_bar.dart';
import 'core/default_change_notifier.dart';

final mfProvider = ChangeNotifierProvider((ref) => MFProvider(ref.read));

class MFProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;
  MFProvider(this.ref);

  MFFactSheetDataModel? _factSheetDataModel;
  MFFactSheetDataModel? get factSheetDataModel => _factSheetDataModel;
  MFSchemePeers? _schemePeers;
  MFSchemePeers? get schemePeers => _schemePeers;
  MFFactSheetGraph? _sheetGraph;
  MFFactSheetGraph? get sheetGraph => _sheetGraph;
  MFNavGraph? _navGraph;
  MFNavGraph? get navGraph => _navGraph;

  VerifyUPIModel? _verifyUPIModel;
  VerifyUPIModel? get verifyUPIModel => _verifyUPIModel;

  MfPlaceOrderResponces? _mfPlaceOrderResponces;
  MfPlaceOrderResponces? get mfPlaceOrderResponces => _mfPlaceOrderResponces;

  BestMFModel? _bestMFModel;
  BestMFModel? get bestMFModel => _bestMFModel;

  MFCategoryList? _mfCategoryList;
  MFCategoryList? get mfCategoryList => _mfCategoryList;

  BestMFListModel? _bestMFList;
  BestMFListModel? get bestMFList => _bestMFList;

  MFCategoryType? _mfCategoryTypes;
  MFCategoryType? get mfCategoryTypes => _mfCategoryTypes;

  MutualFundModel? _mutualFundModel;
  MutualFundModel? get mutualFundModel => _mutualFundModel;

  MfSIPModel? _mfSIPModel;
  MfSIPModel? get mfSIPModel => _mfSIPModel;
  MandateDetailModel? _mandateDetailModel;
  MandateDetailModel? get mandateDetailModel => _mandateDetailModel;

  List<MandateDetails>? _mandateData = [];
  List<MandateDetails>? get mandateData => _mandateData;

  List<MutualFundList>? _mutualFundList = [];
  List<MutualFundList>? get mutualFundList => _mutualFundList;

  List _paymentMethod = [];

  List get paymentMethod => _paymentMethod;

  NFODataModel? _mfNFOList;
  NFODataModel? get mfNFOList => _mfNFOList;

  List<MutualFundList>? _mutualFundtopsearch = [];
  List<MutualFundList>? get mutualFundtopsearch => _mutualFundtopsearch;

  List<MutualFundList>? _mutualFundcommonsearch;
  List<MutualFundList>? get mutualFundcommonsearch => _mutualFundcommonsearch;

  List<MutualFundList>? _mutualFundsearchdata = [];
  List<MutualFundList>? get mutualFundsearchdata => _mutualFundsearchdata;

  List<TopSchemesModelData>? _topSchemesdata = [];
  List<TopSchemesModelData>? get topSchemesdata => _topSchemesdata;

  List<MutualFundList>? _mfWatchlist = [];
  List<MutualFundList>? get mfWatchlist => _mfWatchlist;

  List<MutualFundList>? _topmutualfund = [];
  List<MutualFundList>? get topmutualfund => _topmutualfund;

  List<MutualFundList>? _equityMf = [];
  List<MutualFundList>? get equityMf => _equityMf;
  List<MutualFundList>? _hybridMf = [];
  List<MutualFundList>? get hybridMf => _hybridMf;
  List<MutualFundList>? _debutMf = [];
  List<MutualFundList>? get debutMf => _debutMf;
  List<MutualFundList>? _otherMf = [];
  List<MutualFundList>? get otherMf => _otherMf;
  List<MutualFundList>? _solutionOMf = [];
  List<MutualFundList>? get solutionOMf => _solutionOMf;

  List<MutualFundList>? _filteredMf = [];
  List<MutualFundList>? get filteredMf => _filteredMf;

  List<MFCategory> _mfCategorys = [];
  List<MFCategory> get mfCategorys => _mfCategorys;

  List<String>? _subCat = [];
  List<String>? get subCat => _subCat;

  List<String>? _uniqueList = [];
  List<String>? get uniqueList => _uniqueList;

  List<String>? _amc = [];
  List<String>? get amc => _amc;

  List<String>? _amcfilter = [];
  List<String>? get amcfilter => _amcfilter;

  List<double>? _schmemin = [];
  List<double>? get schmemin => _schmemin;

  List<int>? _schmeminfilter = [];
  List<int>? get schmeminfilter => _schmeminfilter;

  List<String>? _aum = [];
  List<String>? get aum => _aum;

  bool? _isFiltered = false;
  bool? get isFiltered => _isFiltered;

  bool? _singleloader = false;
  bool? get  singleloader => _singleloader ;

  RangeValues _currentRangeValues = const RangeValues(0, 11);
  RangeValues get currentRangeValues => _currentRangeValues;

  TextEditingController invAmt = TextEditingController();
  TextEditingController upiId = TextEditingController();
  TextEditingController installmentAmt = TextEditingController();
  String? invAmtError, upiError, installmentAmtError, invDurationError = "";

  
  int? _activeTab = 0;
  int? get activeTab => _activeTab;

  mfExTabchange(int tab) {
    _activeTab = tab;
    notifyListeners();
  }

  updateRange(RangeValues values, String start, String end) {
    _currentRangeValues = values;
    print("object  $start $end");

    notifyListeners();
  }

  String _paymentName = "";

  String get paymentName => _paymentName;
  BankDetailsModel? _bankDetailsModel;
  UPIDetailsModel? _upiDetailsModel;
  UPIDetailsModel? get upiDetailsModel => _upiDetailsModel;
  BankDetailsModel? get bankDetailsModel => _bankDetailsModel;

  String _sipDuration = "";

  bool _isInitalPay = false;
  bool get isInitalPay => _isInitalPay;

  String _accNum = "";

  String get accNum => _accNum;

  String _ifsc = "";

  String get ifsc => _ifsc;

  String _bankname = "";

  String get bankname => _bankname;

  List<BankData>? _bankData = [];
  List<BankData>? get bankData => _bankData;

  int get startValue => _schmeminfilter![_currentRangeValues.start.round()];
  int get endValue => _schmeminfilter![_currentRangeValues.end.round()];

  List<String>? _aumfilter = [];
  List<String>? get aumfilter => _aumfilter;

  String _mfCategory = "Top Mutual Funds";
  String get mfCategory => _mfCategory;

  String _bestmfselected = "";
  String get bestmfselected => _bestmfselected;

  MFWatchlistModel? _mfWatchlistModel;
  MFWatchlistModel? get mfWatchlistModel => _mfWatchlistModel;

  MFOrderBookModel? _mfLumpSumOrderbook;
  MFOrderBookModel? get mflumpsumorderbook => _mfLumpSumOrderbook;

  MfCreateMandateModel? _createMandateModel;
  MfCreateMandateModel? get createMandateModel => _createMandateModel;

  XsipOrderResponces? _xsipOrderResponces;
  XsipOrderResponces? get xsipOrderResponces => _xsipOrderResponces;

  XsipOrderCancleResone? _xsipOrderCancleResone;
  XsipOrderCancleResone? get xsipOrderCancleResone => _xsipOrderCancleResone;

  XsipOrderCancleResponces? _xsipOrderCancleResponces;
  XsipOrderCancleResponces? get xsipOrderCancleResponces =>
      _xsipOrderCancleResponces;

  AllPaymentMfModel? _allPaymentMfModel;
  AllPaymentMfModel? get allPaymentMfModel => _allPaymentMfModel;

  List<MutualFundList>? _bestmfFilter = [];
  List<MutualFundList>? get bestmfFilter => _bestmfFilter;

  // List<MutualFundList>? _bestmfList = [];
  // List<MutualFundList>? get bestmfList => _bestmfList;
  bool? _isportfolio = false;
  bool? get isportfolio => _isportfolio;

  setPortfolioIs(bool value) {
    _isportfolio = value;
    notifyListeners();
  }

  setInitialPay(bool value) {
    _isInitalPay = value;
    notifyListeners();
  }

  final List _bestMFListStatic = [
    {
      "funds": "46 funds",
      "image": "assets/explore/loan.svg",
      "subtitle": "Build wealth and save taxes",
      "title": "Save taxes"
    },
    {
      "funds": "90 funds",
      "image": "assets/explore/transactions.svg",
      "subtitle": "Stable income and growth",
      "title": "Equity + Debt"
    },
    {
      "funds": "56 funds",
      "image": "assets/explore/goldcoin.svg",
      "subtitle": "Hybrid of active and passive",
      "title": "Smart beta"
    },
    {
      "funds": "120 funds",
      "image": "assets/explore/globe.svg",
      "subtitle": "Diversify your portfolio globally",
      "title": "International funds"
    }
  ];

  List get bestMFListStatic => _bestMFListStatic;

  final List _mFCategoryTypesStatic = [
    {
      "dataIcon": 'assets/explore/equity.png',
      "description":
          "Invest primarily in stocks. High risk, high return potential.",
      "title": "Equity",
      "sub": []
    },
    {
      "dataIcon": 'assets/explore/coins.png',
      "description":
          "Invest in bonds and fixed-income securities. Lower risk, stable returns.",
      "title": "Fixed Income",
      "sub": []
    },
    {
      "dataIcon": 'assets/explore/hybrid.png',
      "description": "Mix of equity and debt to balance risk and return.",
      "title": "Hybrid",
      "sub": []
    },
    {
      "dataIcon": 'assets/explore/gold.png',
      "description":
          "Invest in gold and related securities. Hedge against inflation.",
      "title": "Gold",
      "sub": []
    },
    {
      "dataIcon": 'assets/explore/solution.png',
      "description":
          "Financial goals include retirement planning, funding a child's education, and etc.",
      "title": "Solution",
      "sub": []
    }
  ];

  List get mFCategoryTypesStatic => _mFCategoryTypesStatic;

  // makefalse(String isn) {
  //   int index = _topmutualfund!.indexWhere((element) => element.iSIN == isn);
  //   if (index != -1) {
  //     _topmutualfund![index].isAdd = false;
  //   } else {
  //     print("Value not found");
  //   }

  //   if(_isFiltered!){
  //     for (var watchListMf in _mfWatchlist!) {
  //         _filteredMf!.where((m) => m.iSIN == watchListMf.iSIN).forEach((m) => m.isAdd = true);
  //       }
  //   }

  //   notifyListeners();
  // }

  //  maketrue(String isn) {
  //   int index = _topmutualfund!.indexWhere((element) => element.iSIN == isn);
  //   if (index != -1) {
  //     _topmutualfund![index].isAdd = true;
  //   } else {
  //     print("Value not found");
  //   }

  //   notifyListeners();
  // }

  // updateFilteredMF(range){

  //   _filteredMf = _mutualFundList!
  //     .where((content) {
  //       return _subcatselected.contains(content.sCHEMESUBCATEGORY);}).toList();
  //   if(_amcselected.isNotEmpty){
  //   _filteredMf = _subcatselected.isEmpty ? _mutualFundList!
  //     .where((content) {return _amcselected.contains(content.aMCCode!.toLowerCase().replaceAll('mf', '').replaceAll('_', ' '));}).toList() : _filteredMf!
  //     .where((content) {return _amcselected.contains(content.aMCCode!.toLowerCase().replaceAll('mf', '').replaceAll('_', ' '));}).toList();
  //   }
  //   if(range != false){
  //    _filteredMf = _subcatselected.isEmpty && _amcselected.isEmpty ? _mutualFundList!
  //     .where((content) {double value = double.parse(content.minimumPurchaseAmount!);
  //   return value >= startValue && value <= endValue;}).toList() : _filteredMf!
  //     .where((content) {double value = double.parse(content.minimumPurchaseAmount!);
  //   return value >= startValue && value <= endValue;}).toList();
  //   }
  //   _isFiltered = true;
  //     if(_subcatselected.isEmpty & _amcselected.isEmpty & !range){
  //       _isFiltered = false;
  //     }
  //     for (var watchListMf in _mfWatchlist!) {
  //         _filteredMf!.where((m) => m.iSIN == watchListMf.iSIN).forEach((m) => m.isAdd = true);
  //       }
  //   notifyListeners();
  // }

  // bestmfEmpty(String val) {
  //   _bestmfselected = val;
  //   notifyListeners();
  // }

  // filterItem(String title) {
  //   _bestmfselected = title;
  //   _bestmfFilter = _bestmfList!.where((item) {
  //     bool isT = item.schemeName!.contains("GROWTH");
  //     if (isT) {
  //       if (title == "Save taxes") {
  //         return item.sCHEMECATEGORY!.toUpperCase().contains("EQUITY") &&
  //             item.sCHEMESUBCATEGORY!.toUpperCase().contains("ELSS");
  //       } else if (title == "Low-cost index funds") {
  //         return item.sCHEMECATEGORY!.toUpperCase().contains("OTHER") &&
  //             item.sCHEMESUBCATEGORY!.toUpperCase().contains("INDEX FUNDS") &&
  //             double.parse(item.minimumPurchaseAmount.toString()).toInt() <
  //                 5000;
  //       } else if (title == "Smart beta") {
  //         return item.sCHEMECATEGORY!.toUpperCase().contains("OTHER") &&
  //             item.sCHEMESUBCATEGORY!.toUpperCase().contains("INDEX FUNDS") &&
  //             item.schemeType!.toUpperCase().contains("EQUITY") &&
  //             double.parse(item.minimumPurchaseAmount.toString()).toInt() <
  //                 5000;
  //       } else if (title == "Equity + Debt") {
  //         return item.sCHEMECATEGORY!.toUpperCase().contains("HYBRID") &&
  //             (item.sCHEMESUBCATEGORY!.contains(
  //                     "Dynamic Asset Allocation or Balanced Advantage") ||
  //                 item.sCHEMESUBCATEGORY!.contains("Balanced Hybrid Fund"));
  //       } else if (title == "Alternatives to bank FDs") {
  //         return item.sCHEMECATEGORY!.toUpperCase().contains('DEBT') &&
  //             item.sCHEMESUBCATEGORY!.toUpperCase().contains('LIQUID');
  //       }
  //     }

  //     return false;
  //   }).toList();

  //   notifyListeners();
  // }

  List _mfReturnsGridview = [];

  List get mfReturnsGridview => _mfReturnsGridview;

  bool? _mfPlaceorderload = true;
  bool? get mfPlaceorderload => _mfPlaceorderload;

  String _comYear = "10 Years";
  String get comYear => _comYear;

  final List _compYears = [
    {"yearName": "10 Years", "year": "10Year"},
    {"yearName": "5 Years", "year": "5Year"},
    {"yearName": "3 Years", "year": "3Year"},
    {"yearName": "2 Years", "year": "2Year"},
    {"yearName": "1 Year", "year": "1Year"}
  ];

  List get comYears => _compYears;

  //  MF SIP

  // TextEditingController instalmentAmt = TextEditingController();

  final TextEditingController mfsearchcontroller = TextEditingController();

  TextEditingController invDuration = TextEditingController();
  String _freqName = "";
  String _dates = "1";
  String get freqName => _freqName;
  String get dates => _dates;

  String _xsipvalue = "";
  String get xsipvalue => _xsipvalue;

  String _xsipcaseno = "";
  String get xsipcaseno => _xsipcaseno;

  List<String> _dateList = [];
  List<String> get dateList => _dateList;
  String _insAmt = "0.00";
  String get insAmt => _insAmt;

  List mfOrderTpyes = ["Lumpsum", "Monthly SIP"]; //["Lumpsum"];
  String _mfOrderTpye = "Lumpsum";
  String get mfOrderTpye => _mfOrderTpye;

  List mfOrderbookfilters = ["All", "Lumpsum", "X-SIP", "Redeem"];
  String _mfOrderbookfilter = "All";
  String get mfOrderbookfilter => _mfOrderbookfilter;

  String _mandateId = "";
  String get mandateId => _mandateId;

  String _mandateStatus = "";
  String get mandateStatus => _mandateStatus;

  List<String> _subcatselected = [];
  List<String> get subcatselected => _subcatselected;

  List<String> _amcselected = [];
  List<String> get amcselected => _amcselected;

  String _aumselected = "";
  String get aumselected => _aumselected;

  bool? _mfloader = false;
  bool? get mfloader => _mfloader;

  bool _showSearch = false;
  bool get showSearch => _showSearch;

  int _shoew = 10;
  int get shoew => _shoew;

  int _minpurchase = 0;
  int get minpurchase => _minpurchase;

  int _bestshoew = 10;
  int get bestshoew => _bestshoew;

  // selectedSubCat(String value) {
  //   // _subcatselected = value;
  //   if (_subcatselected.contains(value)) {
  //     _subcatselected.remove(value); // Deselect the item
  //   } else {
  //     _subcatselected.add(value); // Select the item
  //   }
  //   print("value $_subcatselected");
  //   notifyListeners();
  // }

  // selectedminamt(int value) {
  //   _minpurchase = value;
  //   print("value $_minpurchase");
  //   notifyListeners();
  // }

  // selectedamc(String value) {
  //   // _amcselected = value;
  //   if (_amcselected.contains(value)) {
  //     _amcselected.remove(value); // Deselect the item
  //   } else {
  //     _amcselected.add(value); // Select the item
  //   }
  //   print("value $_amcselected");
  //   notifyListeners();
  // }

  // bestshowmore(int value) {
  //   _bestmfFilter!.length > _bestshoew
  //       ? _bestshoew += value
  //       : _bestshoew += (_bestmfFilter!.length - _bestshoew);
  //   notifyListeners();
  // }

  // showmore(int value) {
  //   _topmutualfund!.length > _shoew
  //       ? _shoew += value
  //       : _shoew += (_topmutualfund!.length - _shoew);
  //   // print(
  //   //     " overall length ${_mutualFundList!.length} object ${_mutualFundList!.length > _shoew ? _shoew : _shoew += (_mutualFundList!.length - _shoew)}");
  //   notifyListeners();
  // }

  showOpenSearch(bool value) {
    _showSearch = value;
    if (!_showSearch) {
      _mutualFundtopsearch = [];
      mfsearchcontroller.clear();
    }
    notifyListeners();
  }

  chngPayName(String val) {
    _paymentName = val;
    notifyListeners();
  }

  commonsearch() {
    _mutualFundsearchdata = [];
    mfsearchcontroller.clear();

    notifyListeners();
  }

  clearopenoreder() {
    mfsearchcontroller.clear();
    _mutualFundtopsearch = [];
    _mutualFundsearchdata!.clear();
    notifyListeners();
  }

  // bestmfSearch(String value, BuildContext context) {
  //   if (value.length > 1) {
  //     _mutualFundtopsearch = [];
  //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //     _mutualFundtopsearch = _bestmfFilter!.where((element) {
  //       final symbol = element.schemeName!.toUpperCase();
  //       // final companyname = element.companyName!.toUpperCase();
  //       // final status = element.reponseStatus!.toUpperCase();
  //       // final investedvalue = element.bidDetail![0].amount!.toUpperCase();
  //       return
  //           //companyname.contains(value.toUpperCase()) ||
  //           //     status.contains(value.toUpperCase()) ||
  //           //     investedvalue.contains(value.toUpperCase()) ||
  //           symbol.contains(value.toUpperCase());
  //     }).toList();
  //     if (_bestmfFilter!.isEmpty) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(warningMessage(context, 'No Data Found'));
  //     } else {
  //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //     }
  //   } else {
  //     _mutualFundtopsearch = [];
  //   }
  //   notifyListeners();
  // }

  // mfSearch(String value, BuildContext context) {
  //   if (value.length > 1) {
  //     _mutualFundtopsearch = [];
  //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //     _mutualFundtopsearch = _mutualFundList!.where((element) {
  //       final symbol = element.schemeName!.toUpperCase();
  //       // final companyname = element.companyName!.toUpperCase();
  //       // final status = element.reponseStatus!.toUpperCase();
  //       // final investedvalue = element.bidDetail![0].amount!.toUpperCase();
  //       return
  //           //companyname.contains(value.toUpperCase()) ||
  //           //     status.contains(value.toUpperCase()) ||
  //           //     investedvalue.contains(value.toUpperCase()) ||
  //           symbol.contains(value.toUpperCase());
  //     }).toList();
  //     if (_mutualFundtopsearch!.isEmpty) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(warningMessage(context, 'No Data Found'));
  //     } else {
  //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //     }
  //   } else {
  //     _mutualFundtopsearch = [];
  //   }
  //   notifyListeners();
  // }

  chngMandate(String val) {
    _mandateId = val;
    if(val != "Lumpsum"){
    var indx = _mandateData!.indexWhere((f) => f.mandateId == val);
    _mandateStatus = _mandateData![indx].status!;
    print("${_mandateData![indx].mandateId}, ${_mandateData![indx].status}");
    }
    
    notifyListeners();
  }

  chngOrderType(String val) {
    _mfOrderTpye = val;
    notifyListeners();
  }

  chngComYear(String year, String yearName, String isin) async {
    _comYear = yearName;
    await fetchSchemePeer(isin, year);
    notifyListeners();
  }

  chngOrderFilter(String val) {
    _mfOrderbookfilter = val;

    notifyListeners();
  }

  chngFrequency(String val) {
    _freqName = val;
    if (_mfSIPModel!.data!.isNotEmpty) {
      for (var element in _mfSIPModel!.data!) {
        if (element.sIPFREQUENCY == _freqName) {
          if (_freqName == "DAILY") {
            _dateList = [];
          } else {
            _dateList = element.sIPDATES!.replaceAll("\"", "").split(',');
          }
          invDuration.text = "${element.sIPMINIMUMINSTALLMENTNUMBERS}";
          _sipDuration = "${element.sIPMINIMUMINSTALLMENTNUMBERS}";
          // _insAmt = "${element.sIPMINIMUMINSTALLMENTNUMBERS ?? 0.00}";
        }
      }
    }
    notifyListeners();
  }

  chngxsip(
    String val,
  ) {
    _xsipvalue = val;
    _xsipcaseno = _xsipOrderCancleResone!.data!
        .firstWhere((reason) => reason.reasonName == val)
        .id
        .toString();
    print("object ${_xsipcaseno}");
    notifyListeners();
  }

  chngMFCategory(String val) {
    _mfCategory = val;
    if (_mfCategory == "Equity Funds") {
      _topmutualfund = _equityMf;
      _shoew = 0;
    } else if (_mfCategory == "Debt Funds") {
      _topmutualfund = _debutMf;
      _shoew = 0;
    } else if (_mfCategory == "Hybrid Funds") {
      _topmutualfund = _hybridMf;
      _shoew = 0;
    } else if (_mfCategory == "Solution Oriented Funds") {
      _topmutualfund = _solutionOMf;
      _shoew = 0;
    } else if (_mfCategory == "Top Mutual Funds") {
      _topmutualfund = _mutualFundModel!.mutualFundList;
      _shoew = 0;
    } else if (val == "out") {
      _topmutualfund = _mutualFundModel!.mutualFundList;
      _shoew = 10;
    } else {
      _shoew = 0;
      _topmutualfund = _otherMf;
    }

    for (var watchListMf in _mfWatchlist!) {
      for (var masterMf in _mutualFundList!) {
        if (watchListMf.iSIN == masterMf.iSIN) {
          masterMf.isAdd = true;
        }
      }
    }
    _mutualFundList!.sort((a, b) {
      return double.parse(b.aUM.toString() == "null" || b.aUM!.isEmpty
              ? "0.00"
              : b.aUM.toString())
          .compareTo(double.parse(a.aUM.toString() == "null" || a.aUM!.isEmpty
              ? "0.00"
              : a.aUM.toString()));
    });

    notifyListeners();
  }

  Future fetchmfCommonsearch(String value, BuildContext context) async {
    try {
      var mutualFundsearch = await api.getSearchMf(value);
      _mutualFundsearchdata = mutualFundsearch.data ?? [];
      for (var masterMf in _mfWatchlist!) {
        _mutualFundsearchdata!
            .where((m) => m.iSIN == masterMf.iSIN)
            .forEach((m) => m.isAdd = true);
      }
      var search = "";
      for (var i = 0; i < _mutualFundsearchdata!.length; i++) {
        search = "${_mutualFundsearchdata![i].fSchemeName}";
      }
      notifyListeners();
      print("object ${search}");
    } catch (e) {
      print("SEARCH ERROR :: $e");
    }
  }

  Future fetchmfNFO(BuildContext context) async {
    try {
      _mfNFOList = await api.getNFOData();
      print("NFO list ${_mfNFOList!.nfoList}");
      notifyListeners();
    } catch (e) {
      print("NFO ERROR :: $e");
    }
  }

  Future fetchTopSchemes() async {
    try {
      var topSchemesdata = await api.getTopSchemes();
      if (topSchemesdata.msg != "") {
        _topSchemesdata = topSchemesdata.data;
        log("TopSchemesModel ${_topSchemesdata![0]}");
      }
    } catch (e) {
      print("top schemes error $e");
    }
  }

  // Future fetchMasterMF() async {
  //   try {
  //     _mfloader = true;
  //     _topmutualfund = [];
  //     _equityMf = [];
  //     _debutMf = [];
  //     _hybridMf = [];
  //     _solutionOMf = [];
  //     _otherMf = [];
  //     _mutualFundList = [];
  //     _mfCategorys = [];
  //     _mutualFundModel ??= await api.getMasterMF();
  //     _bestMFModel ?? await fetchBestMF();
  //     // await fetchBestMF();
  //     _mfCategory = "Top Mutual Funds";
  //     if (_mutualFundModel!.stat == "Ok") {
  //       for (var element in _mutualFundModel!.mutualFundList!) {
  //         if (element.sCHEMECATEGORY == "Equity Scheme ") {
  //           _equityMf!.add(element);
  //         } else if (element.sCHEMECATEGORY == "Debt Scheme ") {
  //           _debutMf!.add(element);
  //         } else if (element.sCHEMECATEGORY == "Hybrid Scheme ") {
  //           _hybridMf!.add(element);
  //         } else if (element.sCHEMECATEGORY == "Solution Oriented Scheme ") {
  //           _solutionOMf!.add(element);
  //         } else {
  //           _otherMf!.add(element);
  //         }
  //       }
  //       _mutualFundList = _mutualFundModel!.mutualFundList;
  //       _topmutualfund = _mutualFundModel!.mutualFundList;
  //       _bestmfList = _mutualFundModel!.mutualFundList;

  //       for (var element in _bestmfList!) {
  //         _subCat?.add(element.sCHEMESUBCATEGORY.toString());
  //         _amc?.add(element.aMCCode.toString());
  //         _schmemin!
  //             .add(double.parse(element.minimumPurchaseAmount.toString()));
  //         _aum!.add(element.aUM.toString());
  //       }
  //       for (var watchListMf in _mfWatchlist!) {
  //         for (var masterMf in _mutualFundList!) {
  //           if (watchListMf.iSIN == masterMf.iSIN) {
  //             masterMf.isAdd = true;
  //           }
  //         }
  //       }
  //       _uniqueList = _subCat!
  //           .where((item) => item.trim().isNotEmpty)
  //           .toSet()
  //           .toList()
  //         ..sort();

  //       _amcfilter = _amc!
  //           .map((fund) =>
  //               fund.toLowerCase().replaceAll('mf', '').replaceAll('_', ' '))
  //           .toSet()
  //           .toList();

  //       _schmeminfilter =
  //           _schmemin!.map((item) => item.toInt()).toSet().toList()..sort();
  //       _aumfilter = _aum!.map((item) => item).toSet().toList()..sort();

  //       print("object $_schmeminfilter");
  //       _topmutualfund!.sort((a, b) {
  //         return double.parse(b.aUM.toString() == "null" || b.aUM!.isEmpty
  //                 ? "0.00"
  //                 : b.aUM.toString())
  //             .compareTo(double.parse(
  //                 a.aUM.toString() == "null" || a.aUM!.isEmpty
  //                     ? "0.00"
  //                     : a.aUM.toString()));
  //       });
  //     }
  //     _mfCategorys.add(MFCategory(
  //         name: "Top Mutual Funds",
  //         length: "${_topmutualfund!.length > 100 ? 100 : null} Funds"));

  //     _mfCategorys.add(MFCategory(
  //         name: "Equity Funds", length: "${_equityMf!.length} Funds"));

  //     _mfCategorys.add(
  //         MFCategory(name: "Debt Funds", length: "${_debutMf!.length} Funds"));

  //     _mfCategorys.add(MFCategory(
  //         name: "Hybrid Funds", length: "${_hybridMf!.length} Funds"));

  //     _mfCategorys.add(MFCategory(
  //         name: "Solution Oriented Funds",
  //         length: "${_solutionOMf!.length} Funds"));

  //     _mfCategorys.add(
  //         MFCategory(name: "Other Funds", length: "${_otherMf!.length} Funds"));

  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint("$e");
  //   } finally {
  //     _mfloader = false;
  //   }
  // }

  Future fetchBestMF() async {
    try {
      _bestMFModel = await api.getBestMF();
      if (_bestMFModel!.stat == "Ok") {
        for (var watchListMf in _bestMFModel!.bestMFList!) {
          _bestMFListStatic
              .where((m) => m['title'] == watchListMf.title)
              .forEach((m) => m['funds'] = watchListMf.counts);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMFBestList(String type) async {
    try {
      _bestMFList = await api.getMFBestListData(type);
      print("_bestMFList $_mfCategoryList");
      for (var m in _bestMFList!.bestMFList!) {
        m.isAdd =
            _mfWatchlist!.any((watchListMf) => watchListMf.iSIN == m.iSIN);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMFCategoryList(String type, String subtype) async {
    try {
      _mfCategoryList = await api.getMFCategoryList(type, subtype);
      print("_mfCategoryList $_mfCategoryList");
      // if (_bestMFModel!.stat == "Ok") {
      //   for (var watchListMf in _bestMFModel!.bestMFList!) {
      //     _bestMFListStatic
      //         .where((m) => m['title'] == watchListMf.title)
      //         .forEach((m) => m['funds'] = watchListMf.counts);
      //   }
        for (var masterMf in _mfWatchlist!) {
          _mfCategoryList!.data!
              .where((m) => m.iSIN == masterMf.iSIN)
              .forEach((m) => m.isAdd = true);
        }
      // }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMFCategoryType() async {
    _mfCategoryTypes = await api.getMFCategoryTypes();
    //  print("_mfCategoryTypes ${_mfCategoryTypes!.data![0]}");
    for (var watchListMf in _mfCategoryTypes!.data!) {
      _mFCategoryTypesStatic
          .where((m) => m['title'] == watchListMf.type)
          .forEach((m) => m['sub'] = watchListMf.sub);
    }
    print("_mfCategoryTypes $_mFCategoryTypesStatic");
    notifyListeners();
  }

  Future fetchFactSheet(String isin) async {
    try {
      _singleloader = true;
      Map trailingReturns = {};
      _mfReturnsGridview = [];
      _comYear = "10 Years";
      var stopwatch = Stopwatch()..start();
      _factSheetDataModel = await api.getMFFactSheetData(isin);
      stopwatch.stop(); // Stop timer

      log('Time taken 1: ${stopwatch.elapsedMilliseconds} ms');
      stopwatch = Stopwatch()..start();
      if (_factSheetDataModel!.stat == "Ok") {
        trailingReturns =
            _factSheetDataModel!.data!.benchmarkTrailingReturn!.toJson();

        _mfReturnsGridview.add({
          "duration": "3MonthBenchMarkReturn",
          "durName": "3 Month",
          "return": "",
          "value": double.parse(_factSheetDataModel!.data!.d3Month ?? "0.00")
              .toStringAsFixed(2)
        });
        _mfReturnsGridview.add({
          "duration": "6MonthBenchMarkReturn",
          "durName": "6 Month",
          "return": "",
          "value": double.parse(_factSheetDataModel!.data!.d6Month ?? "0.00")
              .toStringAsFixed(2)
        });
        _mfReturnsGridview.add({
          "duration": "1YearBenchMarkReturn",
          "durName": "1 Year",
          "return": "",
          "value": double.parse(_factSheetDataModel!.data!.d1Year ?? "0.00")
              .toStringAsFixed(2)
        });
        _mfReturnsGridview.add({
          "duration": "3YearBenchMarkReturn",
          "durName": "3 Year",
          "return": "",
          "value": double.parse(_factSheetDataModel!.data!.d3Year ?? "0.00")
              .toStringAsFixed(2)
        });
        _mfReturnsGridview.add({
          "duration": "5YearBenchMarkReturn",
          "durName": "5 Year",
          "return": "",
          "value": double.parse(_factSheetDataModel!.data!.d5Year ?? "0.00")
              .toStringAsFixed(2)
        });
        _mfReturnsGridview.add({
          "duration": "10YearBenchMarkReturn",
          "durName": "10 Year",
          "return": "",
          "value": double.parse(_factSheetDataModel!.data!.d10Year ?? "0.00")
              .toStringAsFixed(2)
        });

        for (var element in _mfReturnsGridview) {
          for (var returns in trailingReturns.entries) {
            if (element['duration'] == returns.key) {
              element['return'] =
                  double.parse(returns.value ?? "0.00").toStringAsFixed(2);
            }
          }
        }
        List splitOverview =
            _factSheetDataModel!.data!.overview!.split("The portfolio");
        factSheetDataModel!.data!.overview1 = "${splitOverview[0]}";
        factSheetDataModel!.data!.overview2 =
            "The portfolio${splitOverview[1]}";
      }
      stopwatch.stop(); // Stop timer

      log('Time taken 2: ${stopwatch.elapsedMilliseconds} ms');
      stopwatch = Stopwatch()..start();
      await fetchFactSheetGraph(isin);
      stopwatch.stop(); // Stop timer

      log('Time taken 3: ${stopwatch.elapsedMilliseconds} ms');
      stopwatch = Stopwatch()..start();
      await fetchSchemePeer(isin, "10Year");
      stopwatch.stop(); // Stop timer

      log('Time taken 4: ${stopwatch.elapsedMilliseconds} ms');
      stopwatch = Stopwatch()..start();
      _navGraph = await api.getMFNavGraph(isin);
      stopwatch.stop(); // Stop timer

      log('Time taken 5: ${stopwatch.elapsedMilliseconds} ms');

      if (_navGraph!.stat == "Ok") {
      } else {}

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }finally{

_singleloader = false;

    }
       
notifyListeners();
  }

  Future fetchSchemePeer(String isin, String comYear) async {
    try {
      _schemePeers = await api.getMFSchemePeer(isin, comYear);

      if (_schemePeers!.stat == "Ok") {
        for (var element in _schemePeers!.topSchemes!) {
          if (comYear == "10Year") {
            element.yearPer = "${element.d10Year}";
            element.yearName = "10Yr";
          } else if (comYear == "5Year") {
            element.yearPer = "${element.d5Year}";
            element.yearName = "5Yr";
          } else if (comYear == "3Year") {
            element.yearPer = "${element.d3Year}";
            element.yearName = "3Yr";
          } else if (comYear == "2Year") {
            element.yearPer = "${element.d2Year}";
            element.yearName = "2Yr";
          } else {
            element.yearPer = "${element.d1Year}";
            element.yearName = "1Yr";
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchFactSheetGraph(String isin) async {
    try {
      _sheetGraph = await api.getMFFactSheetGraph(isin);

      if (_sheetGraph!.stat == "Ok") {}
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchcommonsearchWadd(
      String isin, String isAdd, BuildContext context, bool bool) async {
    try {
      _mfWatchlist = [];
      _mfWatchlistModel = await api.getMFWatchlistsearch(isin, isAdd);
      if (_mfWatchlistModel!.stat == "Ok") {
        _mfWatchlist = _mfWatchlistModel!.scripts ?? [];
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //log("SSSSSSSSSSSSS ${_mfWatchlistModel!.msg.toString()}");
        if (isAdd == "add") {
          ScaffoldMessenger.of(context).showSnackBar(successMessage(
              context, "Stock was Added to Mutual fund watchlist"));
        } else if (isAdd == "delete") {
          ScaffoldMessenger.of(context).showSnackBar(successMessage(
              context, "Stock was Removed from Mutual fund watchlist"));
        }

        // if (bool) {
        //   _mutualFundList = _mfWatchlist;
        // }

        for (var watchListMf in _mfWatchlist!) {
          _mutualFundList!
              .where((m) => m.iSIN == watchListMf.iSIN)
              .forEach((m) => m.isAdd = true);
          _mutualFundsearchdata!
              .where((m) => m.iSIN == watchListMf.iSIN)
              .forEach((m) => m.isAdd = true);
        }
      } else {
        _mfWatchlist = [];
        if (_mfWatchlistModel!.msg == "script exists") {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "${_mfWatchlistModel!.msg}"));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMFWatchlist(String isin, String isAdd, BuildContext context,
      bool bool, String val) async {
    try {
      // _mfWatchlist = [];
      toggleLoadingOn(true);

      _mfWatchlistModel = await api.getMFWatchlist(isin, isAdd);
      if (_mfWatchlistModel!.stat == "Ok") {
        _mfWatchlist = _mfWatchlistModel!.scripts ?? [];
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //log("SSSSSSSSSSSSS ${_mfWatchlistModel!.msg.toString()}");
        if (isAdd == "add") {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "MF was Added to Mutual fund watchlist"));
        } else if (isAdd == "delete") {
          ScaffoldMessenger.of(context).showSnackBar(successMessage(
              context, "MF was Removed from Mutual fund watchlist"));
        }

        // if (bool) {
        //   print("object $bool");
        //   _mutualFundList = _mfWatchlist;
        // }

        // for (var watchListMf in _mfWatchlist!) {
        //   print("object 1");
        //   for (var masterMf in _mutualFundList!) {
        //     print("object 2");
        //     if (watchListMf.iSIN == masterMf.iSIN) {
        //       print("object 3");
        //       masterMf.isAdd = true;
        //     }
        //   }
        // }
        if (_mfWatchlist!.isNotEmpty) {
          if (_mutualFundList != null) {
          for (var m in _mutualFundList!) {
            m.isAdd =
                _mfWatchlist!.any((watchListMf) => watchListMf.iSIN == m.iSIN);
          }
          }
          if (_bestMFList != null) {
          for (var m in _bestMFList!.bestMFList!) {
            m.isAdd =
                _mfWatchlist!.any((watchListMf) => watchListMf.iSIN == m.iSIN);
          }
          }
          if (_mutualFundtopsearch != null) {
          for (var m in _mutualFundtopsearch!) {
            m.isAdd =
                _mfWatchlist!.any((watchListMf) => watchListMf.iSIN == m.iSIN);
          }
          }
          if (_mfCategoryList!.data != null) {
          for (var m in _mfCategoryList!.data!) {
            m.isAdd =
                _mfWatchlist!.any((watchListMf) => watchListMf.iSIN == m.iSIN);
          }
          }
        } 
        
        // else {
        //   for (var m in _mutualFundList!) {
        //     m.isAdd = false;
        //   }

        //   for (var m in _bestMFList!.bestMFList!) {
        //     m.isAdd = false;
        //   }
        //   for (var m in _mutualFundtopsearch!) {
        //     m.isAdd = false;
        //   }

        //   for (var m in mfCategoryList!.data!) {
        //     m.isAdd = false;
        //   }
        // }
      } else {
        // _mfWatchlist = [];
        if (_mfWatchlistModel!.msg == "script exists") {
          ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "${_mfWatchlistModel!.msg}"));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("rererer $e");
      toggleLoadingOn(false);
    }
  }

  Future fetchMFSipData(String isin, String schemeCode) async {
    try {
      _dateList = [];
      _mfSIPModel = await api.getMFSip(isin, schemeCode);

      if (_mfSIPModel!.stat == "Ok") {
        if (_mfSIPModel!.data!.isNotEmpty) {
          _freqName = "${_mfSIPModel!.data![0].sIPFREQUENCY}";

          installmentAmt.text =
              "${_mfSIPModel!.data![0].sIPMINIMUMINSTALLMENTAMOUNT}";
          invDuration.text =
              "${_mfSIPModel!.data![0].sIPMINIMUMINSTALLMENTNUMBERS}";
              _sipDuration = "${_mfSIPModel!.data![0].sIPMINIMUMINSTALLMENTNUMBERS}";
          

          if (_freqName == "MONTHLY" || _freqName == "QUARTERLY") {
            _dateList =
                _mfSIPModel!.data![0].sIPDATES!.replaceAll("\"", "").split(',');

            _dates = _dateList[0];
          } else {
            _dates = _dateList[0];
          }

          _insAmt =
              "${_mfSIPModel!.data![0].sIPMINIMUMINSTALLMENTAMOUNT ?? 0.00}";
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMFMandateDetail() async {
    try {
      _mandateData = [];
      _mandateDetailModel = await api.getMandateDetail();

      if (_mandateDetailModel!.stat == "Ok") {
        _mandateData = _mandateDetailModel!.data!.mandateDetails ?? [];

        _mandateId = _mandateData![0].mandateId!;
        _mandateStatus = _mandateData![0].status!;

      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMfPlaceorder(MfPlaceOrderInput placeorderinput,
      BuildContext context, String upiId) async {
    try {
      // _mfPlaceOrderResponces = await api.getLumpSumOrder(placeorderinput);
      // if (_mfPlaceOrderResponces?.stat == "Ok" &&
      //     _mfPlaceOrderResponces?.orderNumber != null) {
      fetchAllPayment(
          context,
          "${_mfPlaceOrderResponces?.orderNumber}",
          placeorderinput.amount,
          accNum,
          ifsc,
          bankname,
          paymentName == "UPI" ? "UPI" : "NET BANKING",
          "",
          "",
          upiId,
          placeorderinput.schemecode);

      // } else {
      //   ref(fundProvider).paymentName == "UPI"
      //       ? ScaffoldMessenger.of(context).showSnackBar(successMessage(
      //           context, '${_mfPlaceOrderResponces!.responseMessage}'))
      //       : null;
      // }
    } catch (e) {
      log("Failed to Place MF order :: ${e.toString()}");
      notifyListeners();
    }
  }

  Future fetchMfOrderbook(BuildContext context) async {
    try {
      _mfLumpSumOrderbook = await api.getorderbook();
      
    } catch (e) {
      log("Failed to fetchMfOrderbook :: ${e.toString()}");
      notifyListeners();
    }
  }

  Future fetchVerifyUpi(
    BuildContext context,
    String upiId,
    MfPlaceOrderInput input,
  ) async {
    try {
      toggleLoadingOn(true);
      if (upiId != "") {
        _verifyUPIModel = await api.getVerifyUpi(upiId, "123456");
        if (_verifyUPIModel!.data!.verifiedVPAStatus1 == "Available" ||
            _verifyUPIModel!.data!.verifiedVPAStatus2 == "Available") {
          fetchMfPlaceorder(input, context, upiId);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(warningMessage(context, 'Invalid UPI ID'));
        }
      } else {
        fetchMfPlaceorder(input, context, upiId);
      }

      //log("HDFC BANK $_upiIdValidationModel");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");

      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchCreateMandate(BuildContext context, String amount,
      String startDate, String endDate) async {
    try {
      _createMandateModel =
          await api.getCreateMandate(amount, startDate, endDate);

      if (_createMandateModel?.mandate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "${_createMandateModel!.error}"));
      } else {
        fetchMFMandateDetail();
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_createMandateModel!.resp}"));
      }
      print(
          "object ${_createMandateModel!.error} ${_createMandateModel!.url1} ::${_createMandateModel!.mandate}");
    } catch (e) {
      log("Failed to Create Mandate :: ${e.toString()}");
      notifyListeners();
    }
  }

  Future fetchXsipPlaceOrder(
      BuildContext context,
      String schemecode,
      String startDate,
      String freqtype,
      String amt,
      String noofinstallment,
      String enddate,
      String mandateId) async {
    try {
      _xsipOrderResponces = await api.getXsipPurchase(schemecode, startDate,
          freqtype, amt, noofinstallment, endDate, mandateId);

      if (_xsipOrderResponces?.stat == 'OK') {
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_xsipOrderResponces!.responseMessage}"));
        fetchAllPayment(
            context,
            "${_mfPlaceOrderResponces?.orderNumber}",
            amt,
            accNum,
            ifsc,
            bankname,
            paymentName == "UPI" ? "UPI" : "NET BANKING",
            "",
            "",
            upiId.text,
            schemecode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "${_xsipOrderResponces!.responseMessage}"));
      }
      print("object ${_xsipOrderResponces!.responseMessage} ");
    } catch (e) {
      log("Failed to Place X-sip :: ${e.toString()}");
      notifyListeners();
    }
  }

  Future fetchXsipcancelResone() async {
    try {
      _xsipOrderCancleResone = await api.getXsipCancleResone();
      _xsipvalue = "${_xsipOrderCancleResone!.data![0].reasonName}";
      _xsipcaseno = "${_xsipOrderCancleResone!.data![0].id}";
      print("object ${_xsipOrderCancleResone?.data![0].id}");
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchXsipcancel(BuildContext context, String xsipregno,
      String internalrefno, String caseno, String remarks) async {
    try {
      _xsipOrderCancleResponces =
          await api.getxsipCancle(xsipregno, internalrefno, caseno, remarks);

      if (_xsipOrderCancleResponces?.stat == "Not Ok") {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            warningMessage(context, "${_xsipOrderCancleResponces!.emsg}"));
      } else {}
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  // Future fetchAllPayment(
  //     BuildContext context,
  //     String orderNumber,
  //     String totalAmt,
  //     String accno,
  //     String ifsc,
  //     String bankname,
  //     String paymentMethod,
  //     String internalrefno,
  //     String mandateId,
  //     String upi) async {
  //   try {
  //     _allPaymentMfModel = await api.getmfallpayment(orderNumber, totalAmt,
  //         accno, ifsc, bankname, paymentMethod, internalrefno, mandateId, upi);
  //     if (_allPaymentMfModel?.stat == "Not Ok") {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           warningMessage(context, "${_allPaymentMfModel!.emsg}"));
  //     } else if(_allPaymentMfModel?.stat == "Ok") {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           successMessage(context, "${_allPaymentMfModel!.msg}"));
  //           Navigator.pushNamed(
  //                     context,
  //                     Routes.mf,
  //                   );
  //     }
  //     else if(_allPaymentMfModel?.type == "NET BANKING"){
  //       launch("https://v3.mynt.in/mf${_allPaymentMfModel!.file}");
  //     }

  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint("ALL MF ERROR $e");
  //   }
  // }

  Future fetchAllPayment(
      BuildContext context,
      String orderNumber,
      String totalAmt,
      String accno,
      String ifsc,
      String bankname,
      String paymentMethod,
      String internalrefno,
      String mandateId,
      String upi,
      String schemeCode) async {
    _allPaymentMfModel = await api.getmfallpayment(
        orderNumber,
        totalAmt,
        accno,
        ifsc,
        bankname,
        paymentMethod,
        internalrefno,
        mandateId,
        upi,
        schemeCode);
    if (_allPaymentMfModel?.stat == "Not Ok") {
      ScaffoldMessenger.of(context)
          .showSnackBar(warningMessage(context, "${_allPaymentMfModel!.emsg}"));
    } else if (_allPaymentMfModel?.stat == "Ok" &&
        _allPaymentMfModel?.type == "NET BANKING") {
      Navigator.pop(context);
      launch("https://v3.mynt.in/mf${_allPaymentMfModel!.file}");
    } else if (_allPaymentMfModel?.stat == "Ok") {
      if (_allPaymentMfModel?.type == "UPI") {
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_allPaymentMfModel!.payment_msg}"));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "${_allPaymentMfModel!.msg}"));
        Navigator.pushNamed(
          context,
          Routes.mf,
        );
      }
    }
    fetchMfOrderbook(context);
  }

  List<DropdownMenuItem<String>> addFrqDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _mfSIPModel!.data!) {
      menuItems.addAll([
        DropdownMenuItem<String>(
            value: item.sIPFREQUENCY.toString(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                    "${item.sIPFREQUENCY![0]}${item.sIPFREQUENCY!.substring(1).toLowerCase()}",
                    style: textStyle(
                        const Color(0xff000000), 13, FontWeight.w500)))),
        if (item != _mfSIPModel!.data!.last)
          const DropdownMenuItem<String>(enabled: false, child: Divider())
      ]);
    }
    return menuItems;
  }

  List<double> frqCustHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_mfSIPModel!.data!.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> addDateDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _dateList) {
      menuItems.addAll([
        DropdownMenuItem<String>(
            value: item.toString(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(item.toString(),
                    style: textStyle(
                        const Color(0xff000000), 13, FontWeight.w500)))),
        if (item != _dateList.last)
          const DropdownMenuItem<String>(enabled: false, child: Divider())
      ]);
    }
    return menuItems;
  }

  List<double> dateCustHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_dateList.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> xsipDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _xsipOrderCancleResone!.data!) {
      menuItems.addAll([
        DropdownMenuItem<String>(
            value: item.reasonName.toString(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text("${item.reasonName!}",
                    style: textStyle(
                        const Color(0xff000000), 13, FontWeight.w500)))),
        if (item != _xsipOrderCancleResone!.data!.last)
          const DropdownMenuItem<String>(enabled: false, child: Divider())
      ]);
    }
    return menuItems;
  }

  List<double> xsipCustHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_xsipOrderCancleResone!.data!.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  DateTime _curDate = DateTime.now();
  DateTime get curDate => _curDate;

  DateTime? _endsDate;
  DateTime? get endsDate => _endsDate;
  DateTime? _pickedStartDate;
  DateTime? get pickedStartDate => _pickedStartDate;

  String _startDate = "";
  String get startDate => _startDate;
  String _endDate = "";
  String get endDate => _endDate;

  getCurrentDate() {
    _curDate = DateTime.now();
    _pickedStartDate = null;

    _startDate = "${_curDate.day}/${_curDate.month}/${_curDate.year}";
    _endsDate = DateTime(_curDate.year + 30, _curDate.month, _curDate.day - 1);
    _endDate = "${_endsDate!.day}/${_endsDate!.month}/${_endsDate!.year}";
    notifyListeners();
  }

  changeStartDate(date) {
    _dates = date;
    notifyListeners();
  }

  datePickerStart(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        currentDate: _pickedStartDate ?? _curDate,
        context: context,
        initialDate: _pickedStartDate ?? _curDate,
        firstDate: _curDate,
        lastDate: DateTime(_curDate.year + 200));
    if (picked != null) {
      _pickedStartDate = picked;
      _startDate =
          "${_pickedStartDate!.day}/${_pickedStartDate!.month}/${_pickedStartDate!.year}";
      _endsDate = DateTime(_pickedStartDate!.year + 30, _pickedStartDate!.month,
          _pickedStartDate!.day - 1);
      _endDate = "${_endsDate!.day}/${_endsDate!.month}/${_endsDate!.year}";
    }
    notifyListeners();
  }

  datePickerEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        currentDate: _endsDate,
        initialDate: _endsDate,
        firstDate:
            DateTime(_curDate.year, _curDate.month + 2, _curDate.day - 1),
        lastDate: DateTime(_curDate.year + 200));
    if (picked != null) {
      _endsDate = picked;
      _endDate = "${_endsDate!.day}/${_endsDate!.month}/${_endsDate!.year}";
    }
    notifyListeners();
  }

  List<DropdownMenuItem<String>> mandateDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _mandateData!) {
      menuItems.addAll([
        DropdownMenuItem<String>(
            value: item.mandateId.toString(),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("${item.mandateId}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyle(colors.colorBlack, 14,
                                        FontWeight.w500)),
                                const SizedBox(
                                  width: 10,
                                ),
                                item.status == "REJECTED"
                                    ? SvgPicture.asset(assets.cancelledIcon)
                                    : item.status == "APPROVED"
                                        ? SvgPicture.asset(assets.completedIcon)
                                        : SvgPicture.asset(assets.warningIcon)
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text("Reg date: ${item.regnDate}",
                                style: textStyle(
                                    colors.colorGrey, 12, FontWeight.w500))
                          ]),
                      Text("${double.parse(item.amount!).ceil()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              textStyle(colors.colorBlack, 14, FontWeight.w500))
                    ]))),
        if (item != _mandateData!.last)
          const DropdownMenuItem<String>(enabled: false, child: Divider())
      ]);
    }
    return menuItems;
  }

  List<double> mandateHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_mandateData!.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(50);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  chngBankAcc(String val) {
    _accNum = val;
    _ifsc = _bankDetailsModel!.data!
        .firstWhere((reason) => reason.bankAcNo == val)
        .iFSCCode
        .toString();
    _bankname = _bankDetailsModel!.data!
        .firstWhere((reason) => reason.bankAcNo == val)
        .bankName
        .toString();
    notifyListeners();
  }

  List<DropdownMenuItem<String>> addBankDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _bankData!) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item.bankAcNo.toString(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item.bankName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            textStyle(colors.colorBlack, 14, FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text("*******${item.bankAcNo!.substring(8)}",
                        style:
                            textStyle(colors.colorGrey, 12, FontWeight.w500)),
                  ],
                ),
              )),
          //If it's last item, we will not add Divider after it.
          if (item != _bankData!.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  // set Dropdown item height
  List<double> getBankCustItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_bankData!.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(50);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  // Fetching data from the api and stored in a variable
  Future fetchUpiDetail() async {
    try {
      _paymentMethod = [];
      _upiDetailsModel = await api.getUPI();

      if (_upiDetailsModel!.stat == "Ok") {
        _paymentMethod.add("UPI");
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  // Fetching data from the api and stored in a variable
  Future fetchBankDetail() async {
    upiId.text = "";
    try {
      _bankDetailsModel = await api.getBankDetail();
      _bankData = [];
      if (_bankDetailsModel!.stat == "Ok") {
        _paymentMethod.add("Net banking");
        _bankData = _bankDetailsModel!.data ?? [];
        if (_bankData!.isNotEmpty) {
          _accNum = "${_bankData![0].bankAcNo}";
          _ifsc = "${bankData![0].iFSCCode}";
          _bankname = "${bankData![0].bankName}";
        }
      }

      if (_upiDetailsModel!.stat == "Ok" || _bankDetailsModel!.stat == "Ok") {
        _paymentName = _paymentMethod[0];

        if (_paymentName == "UPI") {
          upiId.text = "${_upiDetailsModel!.data![0].upiId}";
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  List<DropdownMenuItem<String>> addDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _paymentMethod) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item.toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    item.toString(),
                    style:
                        textStyle(const Color(0xff000000), 13, FontWeight.w500),
                  ))),
          //If it's last item, we will not add Divider after it.
          if (item != _paymentMethod.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> getCustItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_paymentMethod.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  bool isValidUpiId(MutualFundList mfData) {
    print("Change made");
    final RegExp upiRegex =
        RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$', caseSensitive: false);
    if (mfOrderTpye == "Lumpsum") {
      if (invAmt.text.isEmpty) {
        invAmtError = "Please enter Investment amount";
      } else if (double.parse(invAmt.text) <
          double.parse(mfData.minimumPurchaseAmount!)) {
        invAmtError =
            "Investment amount should not be less than ${mfData.minimumPurchaseAmount!}";
      }
      else{
        invAmtError = "";
      }
    } else {
      if (invAmt.text.isEmpty) {
        invAmtError = "Please enter Investment amount";
      } else if (double.parse(invAmt.text) <
          double.parse(mfData.minimumPurchaseAmount!) && isInitalPay) {
        invAmtError =
            "Investment amount should not be less than ${mfData.minimumPurchaseAmount!}";
      }
      else{
        invAmtError = "";
      }


      if (installmentAmt.text.isEmpty) {
        installmentAmtError = "Please enter Installment amount";
      } else if (double.parse(installmentAmt.text) <
          double.parse(mfData.minimumPurchaseAmount!)) {
        installmentAmtError =
            "Installment amount should not be less than ${mfData.minimumPurchaseAmount!}";
      }
      else{
        installmentAmtError = "";
      }

    }

    if (upiId.text.isEmpty) {
      upiError = "Please enter UPI ID";
    }
    else if (!upiRegex.hasMatch(upiId.text)) {
      upiError = "Please enter valid UPI ID";
    }
    else{
      upiError = "";
    }

    if (invDuration.text.isEmpty) {
      invDurationError = "Please enter Investment duration";
    }
    else if (double.parse(invDuration.text) < double.parse(_sipDuration)) {
      invDurationError = "Installment Duration should not be less than $_sipDuration";
    }
    else{
      invDurationError = "";
    }
    notifyListeners();
    return invAmtError == "" &&
        upiError == "" &&
        installmentAmtError == "" && invDurationError == "";
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/mf_model/best_mf_model.dart';
import '../models/mf_model/mandate_detail_model.dart';
import '../models/mf_model/mf_bank_detail_model.dart';
import '../models/mf_model/mf_factsheet_data_model.dart';
import '../models/mf_model/mf_factsheet_graph.dart';
import '../models/mf_model/mf_nav_graph_model.dart';
import '../models/mf_model/mf_scheme_peers_model.dart';
import '../models/mf_model/mf_sip_model.dart';
import '../models/mf_model/mf_watch_list.dart';
import '../models/mf_model/mutual_fundmodel.dart';
import '../res/res.dart';
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

  BestMFModel? _bestMFModel;
  BestMFModel? get bestMFModel => _bestMFModel;

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

  List<MutualFundList>? _mfWatchlist = [];
  List<MutualFundList>? get mfWatchlist => _mfWatchlist;

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

  List<MFCategory> _mfCategorys = [];
  List<MFCategory> get mfCategorys => _mfCategorys;

  String _mfCategory = "Top Mutual Funds";
  String get mfCategory => _mfCategory;
  MFWatchlistModel? _mfWatchlistModel;
  MFWatchlistModel? get mfWatchlistModel => _mfWatchlistModel;

  List _mfReturnsGridview = [];

  List get mfReturnsGridview => _mfReturnsGridview;

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

  TextEditingController instalmentAmt = TextEditingController();

  TextEditingController invDuration = TextEditingController();
  String _freqName = "";
  String _dates = "1";
  String get freqName => _freqName;
  String get dates => _dates;
  List<String> _dateList = [];
  List<String> get dateList => _dateList;
  String _insAmt = "0.00";
  String get insAmt => _insAmt;

  List mfOrderTpyes = ["Lumpsum", "Monthly SIP"];
  String _mfOrderTpye = "Lumpsum";
  String get mfOrderTpye => _mfOrderTpye;

  String _mandateId = "";
  String get mandateId => _mandateId;
  chngMandate(String val) {
    _mandateId = val;
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
          _insAmt = "${element.sIPMINIMUMINSTALLMENTNUMBERS ?? 0.00}";
        }
      }
    }
    notifyListeners();
  }

  chngMFCategory(String val) {
    _mfCategory = val;
    if (_mfCategory == "Equity Funds") {
      _mutualFundList = _equityMf;
    } else if (_mfCategory == "Debt Funds") {
      _mutualFundList = _debutMf;
    } else if (_mfCategory == "Hybrid Funds") {
      _mutualFundList = _hybridMf;
    } else if (_mfCategory == "Solution Oriented Funds") {
      _mutualFundList = _solutionOMf;
    } else if (_mfCategory == "Top Mutual Funds") {
      _mutualFundList = _mutualFundModel!.mutualFundList;
    } else {
      _mutualFundList = _otherMf;
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

  Future fetchMasterMF() async {
    try {
      _equityMf = [];
      _debutMf = [];
      _hybridMf = [];
      _solutionOMf = [];
      _otherMf = [];
      _mutualFundList = [];
      _mfCategorys = [];
      _mutualFundModel ??= await api.getMasterMF();
      _bestMFModel ?? await fetchBestMF();
      await fetchBestMF();
      _mfCategory = "Top Mutual Funds";
      if (_mutualFundModel!.stat == "Ok") {
        for (var element in _mutualFundModel!.mutualFundList!) {
          if (element.sCHEMECATEGORY == "Equity Scheme ") {
            _equityMf!.add(element);
          } else if (element.sCHEMECATEGORY == "Debt Scheme ") {
            _debutMf!.add(element);
          } else if (element.sCHEMECATEGORY == "Hybrid Scheme ") {
            _hybridMf!.add(element);
          } else if (element.sCHEMECATEGORY == "Solution Oriented Scheme ") {
            _solutionOMf!.add(element);
          } else {
            _otherMf!.add(element);
          }
        }
        _mutualFundList = _mutualFundModel!.mutualFundList;

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
              .compareTo(double.parse(
                  a.aUM.toString() == "null" || a.aUM!.isEmpty
                      ? "0.00"
                      : a.aUM.toString()));
        });
      }
      _mfCategorys.add(MFCategory(
          name: "Top Mutual Funds",
          length:
              "${_mutualFundList!.length > 100 ? 100 : _mutualFundList!.length} Funds"));

      _mfCategorys.add(MFCategory(
          name: "Equity Funds", length: "${_equityMf!.length} Funds"));

      _mfCategorys.add(
          MFCategory(name: "Debt Funds", length: "${_debutMf!.length} Funds"));

      _mfCategorys.add(MFCategory(
          name: "Hybrid Funds", length: "${_hybridMf!.length} Funds"));

      _mfCategorys.add(MFCategory(
          name: "Solution Oriented Funds",
          length: "${_solutionOMf!.length} Funds"));

      _mfCategorys.add(
          MFCategory(name: "Other Funds", length: "${_otherMf!.length} Funds"));
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchBestMF() async {
    try {
      _bestMFModel = await api.getBestMF();
      if (_bestMFModel!.stat == "Ok") {
        for (var element in _bestMFModel!.bestMFList!) {
          if (element.title == "Save taxes") {
            element.icon = assets.loan;
          } else if (element.title == "Low-cost index funds") {
            element.icon = assets.percentage;
          } else if (element.title == "Smart beta") {
            element.icon = assets.goldCoin;
          } else if (element.title == "Equity + Debt") {
            element.icon = assets.transaction;
          } else {
            element.icon = assets.globe;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchFactSheet(String isin) async {
    try {
      Map trailingReturns = {};
      _mfReturnsGridview = [];
      _comYear = "10 Years";
      _factSheetDataModel = await api.getMFFactSheetData(isin);

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

      await fetchFactSheetGraph(isin);
      await fetchSchemePeer(isin, "10Year");
      _navGraph = await api.getMFNavGraph(isin);

      if (_navGraph!.stat == "Ok") {
      } else {}

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
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

  Future fetchMFWatchlist(MutualFundList? scipt, String isAdd,
      BuildContext context, bool bool) async {
    try {
      _mfWatchlist = [];
      _mfWatchlistModel = await api.getMFWatchlist(scipt, isAdd);
      if (_mfWatchlistModel!.stat == "Ok") {
        _mfWatchlist = _mfWatchlistModel!.scripts ?? [];
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (isAdd == "add") {
          ScaffoldMessenger.of(context).showSnackBar(successMessage(
              context, "Stock was Added to Mutual fund watchlist"));
        } else if (isAdd == "delete") {
          ScaffoldMessenger.of(context).showSnackBar(successMessage(
              context, "Stock was Removed to Mutual fund watchlist"));
        }
        if (bool) {
          _mutualFundList = _mfWatchlist;
        }

        for (var watchListMf in _mfWatchlist!) {
          for (var masterMf in _mutualFundList!) {
            if (watchListMf.iSIN == masterMf.iSIN) {
              masterMf.isAdd = true;
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchMFSipData(String isin, String schemeCode) async {
    try {
      _dateList = [];
      _mfSIPModel = await api.getMFSip(isin, schemeCode);

      if (_mfSIPModel!.stat == "Ok") {
        if (_mfSIPModel!.data!.isNotEmpty) {
          _freqName = "${_mfSIPModel!.data![0].sIPFREQUENCY}";

          instalmentAmt.text =
              "${_mfSIPModel!.data![0].sIPMINIMUMINSTALLMENTAMOUNT}";
          invDuration.text =
              "${_mfSIPModel!.data![0].sIPMINIMUMINSTALLMENTNUMBERS}";

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
      }
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchVerifyUpi(
    BuildContext context,
    String upiId,
  ) async {
    try {
      toggleLoadingOn(true);
      _verifyUPIModel = await api.getVerifyUpi(upiId, "123456");
      if (_verifyUPIModel!.data!.verifiedVPAStatus1 == "Available" ||
          _verifyUPIModel!.data!.verifiedVPAStatus2 == "Available") {
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'Invalid UPI ID'));
      }

      //log("HDFC BANK $_upiIdValidationModel");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");

      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
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
                            Text("${item.mandateId}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(
                                    colors.colorBlack, 14, FontWeight.w500)),
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
}

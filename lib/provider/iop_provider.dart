// ignore_for_file: use_build_context_synchronously\
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/ipo_model/ipo_details_model.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../models/ipo_model/ipo_mainstream_model.dart';
import '../models/ipo_model/ipo_order_book_model.dart';
import '../models/ipo_model/ipo_order_res_model.dart';
import '../models/ipo_model/ipo_performance_model.dart';
import '../models/ipo_model/ipo_place_order_model.dart';
import '../models/ipo_model/ipo_sme_model.dart';
import '../models/mf_model/mf_bank_detail_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/snack_bar.dart';
import 'core/default_change_notifier.dart';
import 'package:intl/intl.dart';

final ipoProvide = ChangeNotifierProvider((ref) => IPOProvider(ref.read));

class IPOProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();

  late TabController ipoTab;

  final TextEditingController quantity = TextEditingController();
  final TextEditingController bidprice = TextEditingController();

  bool _isActiveMainStream = true;
  bool get isActiveMainStream => _isActiveMainStream;

  bool _isActiveSME = true;
  bool get isActiveSME => _isActiveSME;

  final Reader ref;

  void activeMainStreamBtn(bool val) {
    _isActiveMainStream = val;
    // log("$_isActiveMainStream");
    notifyListeners();
  }

  void activeSMEBtn(bool val) {
    _isActiveSME = val;
    // log("$_isActiveSME");
    notifyListeners();
  }

  IPOProvider(this.ref);

  // List<IPOOrderBookModel>? _orderBookModel;
  // List<IPOOrderBookModel>? get orderBookModel => _orderBookModel;

  final TextEditingController viewupiid = TextEditingController();
  final TextEditingController performancesearchcontroller =
      TextEditingController();
  final TextEditingController openOrderController = TextEditingController();

  late TabController tabCtrl;

  VerifyUPIModel? _upiIdValidationModel;
  VerifyUPIModel? get upiIdValidationModel => _upiIdValidationModel;

  SmeIpoModel? _smeIpoModel;
  SmeIpoModel? get smeIpoModel => _smeIpoModel;

  MainStreamIpoModel? _mainStreamIpoModel;
  MainStreamIpoModel? get mainStreamIpoModel => _mainStreamIpoModel;

  IpoPerformanceModel? _ipoPerformanceModel;
  IpoPerformanceModel? get ipoPerformanceModel => _ipoPerformanceModel;

  List<IpoScrip>? _performancesearch = [];
  List<IpoScrip>? get performancesearch => _performancesearch;

  List<IpoScrip>? _filterperformance = [];
  List<IpoScrip>? get filterperformance => _filterperformance;

  IpoOrderResponcesModel? _ipoOrderResponcesModel;
  IpoOrderResponcesModel? get ipoOrderResponcesModel => _ipoOrderResponcesModel;

  IpoOrderBookModel? _iposubcategory;
  IpoOrderBookModel? get iposubcategory => _iposubcategory;

  List<IpoOrderBookModel>? _ipoOrderBookModel;
  List<IpoOrderBookModel>? get ipoOrderBookModel => _ipoOrderBookModel;

  List<IpoOrderBookModel>? _iposearch = [];
  List<IpoOrderBookModel>? get iposearch => _iposearch;

  List<IpoOrderBookModel>? _openorder = [];
  List<IpoOrderBookModel>? get openorder => _openorder;

  List<IpoOrderBookModel>? _closeorder = [];
  List<IpoOrderBookModel>? get closeorder => _closeorder;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  String timemessage = "";
  String get timeMessage => timemessage;

  double _maxUPIAmt = 0.00;
  double get maxUPIAmt => _maxUPIAmt;

  bool _showSearch = false;
  bool get showSearch => _showSearch;

  String? _numbers = "";
  String? get numbers => _numbers;

  String? _maxValue = "";
  String? get maxValue => _maxValue;

  List<String> _stringList = [];
  List<String> get stringList => _stringList;

  List<Tab> _orderTabName = [];
  List<Tab> get orderTabName => _orderTabName;

  tabSize() {
    _orderTabName = [
      Tab(text: "Current & Upcoming"),
      Tab(text: "Closed IPO’s"),
    ];

    notifyListeners();
  }

  showOpenSearch(bool value) {
    _showSearch = value;
    if (!_showSearch) {
      _ipoOrderBookModel = [];
    }
    notifyListeners();
  }

  clearopenoreder() {
    openOrderController.clear();
    _iposearch = [];
    notifyListeners();
  }

  clearPerformanceSearch() {
    performancesearchcontroller.clear();
    _performancesearch = [];
    notifyListeners();
  }

  openOrderSearch(String value, BuildContext context) {
    if (value.length > 1) {
      _iposearch = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _iposearch = _openorder!.where((element) {
        final symbol = element.symbol!.toUpperCase();
        final companyname = element.companyName!.toUpperCase();
        final status = element.reponseStatus!.toUpperCase();
        final investedvalue = element.bidDetail![0].amount!.toUpperCase();
        // final date =
        //     ipodateres(element.responseDatetime.toString()).toUpperCase();
        return companyname.contains(value.toUpperCase()) ||
            status.contains(value.toUpperCase()) ||
            investedvalue.contains(value.toUpperCase()) ||
            symbol.contains(value.toUpperCase());
      }).toList();
      if (_iposearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _iposearch = [];
    }
    notifyListeners();
  }

  searchperformance(String value, BuildContext context) {
    if (value.length > 1) {
      _performancesearch = [];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _performancesearch = _ipoPerformanceModel!.data!
          .where((element) =>
              element.companyName!.toUpperCase().contains(value.toUpperCase()))
          .toList();
      if (_performancesearch!.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, 'No Data Found'));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } else {
      _performancesearch = [];
    }
    notifyListeners();
  }

  smedatesort(List<SMEIPO> data) {
    try {
      data.sort((a, b) {
        final DateFormat dateFormat = DateFormat("MMMM d, yyyy");
        DateTime dateA = dateFormat.parse(a.biddingStartDate.toString());
        DateTime dateB = dateFormat.parse(b.biddingStartDate.toString());
        return dateB.compareTo(dateA);
      }); // Sort by date
    } catch (e) {
    } 
  }

  sortIPOListByDate(List<IpoScrip> data) {
    try {
      data.sort((a, b) {
        final DateFormat dateFormat = DateFormat("MMMM d, yyyy");
        DateTime dateA = dateFormat.parse(a.listedDate.toString());
        DateTime dateB = dateFormat.parse(b.listedDate.toString());
        return dateB.compareTo(dateA);
      }); // Sort by date
    } catch (e) {
    } 
  }

  changeTabIndex(
    int index,
  ) {
    _selectedTab = index;
    notifyListeners();
  }

  changeIpoIndex(int index, BuildContext context) {
    _selectedTab = index;
    notifyListeners();
  }

  validateCurrentTime() {
    String message = "";
    final now = DateTime.now();
    final int currentMinutes = now.hour * 60 + now.minute;
    const int startMinutes = 10 * 60; // 10:00 AM
    const int endMinutes = 17 * 60; // 5:00 PM

    if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
      message = "Time";
    } else {
      message =
          "IPO window is open from 10:00 AM till 05:00 PM on trading days.";
    }
    timemessage = message;

    notifyListeners();
  }

  smecutoffprice(IpoDetails addIpo, SMEIPO smeipo) {
    addIpo.biderrortext = "";
    addIpo.isChecked = !addIpo.isChecked;
    addIpo.isChecked == true
        ? addIpo.bidpricecontroller.text =
            ("${double.parse(smeipo.maxPrice!).toInt()}")
        : addIpo.bidpricecontroller.text =
            "${double.parse(smeipo.minPrice!).toInt()}";
    addIpo.isChecked == true
        ? addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice = double.parse(smeipo.maxPrice!).toInt() *
                (int.parse(addIpo.qualityController.text))
        : addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice = double.parse(smeipo.minPrice!).toInt() *
                (int.parse(addIpo.qualityController.text));
    notifyListeners();
  }

  smebidpriceOnChange(
      String value, IpoDetails addIpo, bool ischecked, SMEIPO smeipo) {
    addIpo.bidpricecontroller.text = value;
    addIpo.bidpricecontroller.text.isEmpty
        ? addIpo.requriedprice = 0
        : addIpo.requriedprice = (int.parse(addIpo.bidpricecontroller.text) *
                int.parse(addIpo.qualityController.text))
            .toInt();
    if (addIpo.bidpricecontroller.text.isEmpty ||
        addIpo.bidpricecontroller.text == "0") {
      addIpo.biderrortext = addIpo.bidpricecontroller.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
      ischecked = false;
    } else if ((int.parse(addIpo.bidpricecontroller.text)) >
            double.parse(smeipo.maxPrice.toString()).toInt() ||
        (int.parse(addIpo.bidpricecontroller.text)) <
            double.parse(smeipo.minPrice.toString()).toInt()) {
      addIpo.biderrortext =
          "Your bit price ranges between ₹${double.parse(smeipo.minPrice!).toInt()}-₹${double.parse(smeipo.maxPrice!).toInt()}";
      ischecked = false;
    } else {
      addIpo.biderrortext = "";
    }
    notifyListeners();
  }

  smequantityOnchange(String value, IpoDetails addIpo, SMEIPO smeipo,
      bool ischecked, double maxUPIAmt) {
    addIpo.qualityController.text = value;
    addIpo.qualityController.text.isEmpty
        ? addIpo.requriedprice = 0
        : addIpo.requriedprice = (int.parse(addIpo.qualityController.text) *
                int.parse(addIpo.bidpricecontroller.text))
            .toInt();
    addIpo.isChecked == true
        ? addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice = double.parse(smeipo.maxPrice!).toInt() *
                (int.parse(addIpo.qualityController.text))
        : addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice = double.parse(smeipo.minPrice!).toInt() *
                (int.parse(addIpo.qualityController.text));
    if (addIpo.qualityController.text.isEmpty ||
        addIpo.qualityController.text == "0") {
      addIpo.qualityerrortext = addIpo.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
      addIpo.requriedprice = 0;
      ischecked = false;
      notifyListeners();
    } else if ((int.parse(addIpo.qualityController.text)) <
        int.parse(smeipo.minBidQuantity.toString()).toInt()) {
      addIpo.qualityerrortext =
          "Minimum Bid quantity is ${smeipo.minBidQuantity.toString()} only ";
      ischecked = false;
    } else if (addIpo.requriedprice > maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else {
      addIpo.qualityerrortext = "";
    }
    notifyListeners();
  }

  smequantityminusfunction(
      IpoDetails addIpo, bool ischecked, SMEIPO smeipo, double maxUPIAmt) {
    if (addIpo.qualityController.text.isNotEmpty) {
      addIpo.qualityController.text =
          (int.parse(addIpo.qualityController.text) - addIpo.lotsize)
              .toString();
      addIpo.isChecked == true
          ? addIpo.requriedprice = double.parse(smeipo.maxPrice!).toInt() *
              (int.parse(addIpo.qualityController.text))
          : addIpo.requriedprice = double.parse(smeipo.minPrice!).toInt() *
              (int.parse(addIpo.qualityController.text));
    }
    if (addIpo.qualityController.text.isEmpty ||
        addIpo.qualityController.text == "0") {
      addIpo.qualityerrortext = addIpo.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
    } else if (addIpo.requriedprice > maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else {
      addIpo.qualityerrortext = "";
    }
    notifyListeners();
  }

  smequalityplusefunction(
      IpoDetails addIpo, bool ischecked, SMEIPO smeipo, double maxUPIAmt) {
    if (addIpo.qualityController.text.isNotEmpty) {
      addIpo.qualityController.text =
          (int.parse(addIpo.qualityController.text) + addIpo.lotsize)
              .toString();
      addIpo.isChecked == true
          ? addIpo.requriedprice = double.parse(smeipo.maxPrice!).toInt() *
              (int.parse(addIpo.qualityController.text))
          : addIpo.requriedprice = double.parse(smeipo.minPrice!).toInt() *
              (int.parse(addIpo.qualityController.text));
    }
    if (addIpo.qualityController.text.isEmpty ||
        addIpo.qualityController.text == "0") {
      addIpo.qualityerrortext = addIpo.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
    } else if (addIpo.requriedprice > maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else {
      addIpo.qualityerrortext = "";
    }
    notifyListeners();
  }

  ipoOrdervalidation(
      IpoDetails addIpo,
      double maxUPIAmt,
      bool ischecked,
      FundProvider upiid,
      BuildContext context,
      Function(FundProvider upiid) ipoplaceorder) {
    if (addIpo.requriedprice > maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else if (addIpo.bidpricecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, "*Bid Price Value is required"));
      ischecked = false;
    } else if (upiid.viewupiid.text.isEmpty) {
      ischecked = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(warningMessage(context, '* UPI ID cannot be empty'));
    } else if (!RegExp(r'^[\w.-]+@[\w]+$').hasMatch(upiid.viewupiid.text)) {
      ischecked = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(warningMessage(context, 'Invalid UPI ID format'));
    } else {
      ipoplaceorder(upiid);
    }
    notifyListeners();
  }

  categoryOnChange(IpoDetails addIpo, double maxUPIAmt, bool ischecked) {
    if (addIpo.requriedprice > maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else {
      addIpo.qualityerrortext = "";
      ischecked = false;
    }
    notifyListeners();
  }

  qualityplusefunction(
      IpoDetails addIpo, bool ischecked, IPOProvider ipo, MainIPO mainstream) {
    if (addIpo.qualityController.text.isNotEmpty) {
      addIpo.qualityController.text =
          (int.parse(addIpo.qualityController.text) + addIpo.lotsize)
              .toString();
      addIpo.isChecked == true
          ? addIpo.requriedprice = double.parse(mainstream.maxPrice!).toInt() *
              (int.parse(addIpo.qualityController.text))
          : addIpo.requriedprice = double.parse(mainstream.minPrice!).toInt() *
              (int.parse(addIpo.qualityController.text));
    }
    if (addIpo.qualityController.text.isEmpty ||
        addIpo.qualityController.text == "0") {
      addIpo.qualityerrortext = addIpo.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
    } else if (addIpo.requriedprice > ipo.maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else {
      addIpo.qualityerrortext = "";
    }

    notifyListeners();
  }

  quantityminusfunction(
      IpoDetails addIpo, bool ischecked, IPOProvider ipo, MainIPO mainstream) {
    if (addIpo.qualityController.text.isNotEmpty) {
      addIpo.qualityController.text =
          (int.parse(addIpo.qualityController.text) - addIpo.lotsize)
              .toString();
      addIpo.isChecked == true
          ? addIpo.requriedprice = double.parse(mainstream.maxPrice!).toInt() *
              (int.parse(addIpo.qualityController.text))
          : addIpo.requriedprice = double.parse(mainstream.minPrice!).toInt() *
              (int.parse(addIpo.qualityController.text));
    }
    if (addIpo.qualityController.text.isEmpty ||
        addIpo.qualityController.text == "0") {
      addIpo.qualityerrortext = addIpo.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
    } else if (addIpo.requriedprice > ipo.maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else if ((int.parse(addIpo.qualityController.text)) <
        int.parse(mainstream.minBidQuantity.toString()).toInt()) {
      addIpo.qualityerrortext =
          "Minimum Bid quantity is ${mainstream.minBidQuantity.toString()} only ";
    } else {
      addIpo.qualityerrortext = "";
    }
    notifyListeners();
  }

  quantityOnchange(IpoDetails addIpo, bool ischecked, IPOProvider ipo,
      String value, MainIPO mainstream) {
    addIpo.qualityController.text = value;
    addIpo.isChecked == true
        ? addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice =
                double.parse(mainstream.maxPrice!).toInt() *
                    (int.parse(addIpo.qualityController.text))
        : addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice =
                double.parse(mainstream.minPrice!).toInt() *
                    (int.parse(addIpo.qualityController.text));
    addIpo.qualityController.text.isEmpty
        ? addIpo.requriedprice = 0
        : addIpo.requriedprice = (int.parse(addIpo.qualityController.text) *
                int.parse(addIpo.bidpricecontroller.text))
            .toInt();

    if (addIpo.qualityController.text.isEmpty ||
        addIpo.qualityController.text == "0") {
      addIpo.qualityerrortext = addIpo.qualityController.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
      addIpo.requriedprice = 0;
      ischecked = false;
    } else if (addIpo.requriedprice > ipo.maxUPIAmt) {
      addIpo.qualityerrortext =
          "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
      ischecked = false;
    } else if ((int.parse(addIpo.qualityController.text)) <
        int.parse(mainstream.minBidQuantity.toString()).toInt()) {
      addIpo.qualityerrortext =
          "Minimum Bid quantity is ${mainstream.minBidQuantity.toString()} only ";
      ischecked = false;
    } else {
      addIpo.qualityerrortext = "";
    }
    notifyListeners();
  }

  bidpricefunction(
      IpoDetails addIpo, MainIPO mainstream, String value, bool ischecked) {
    addIpo.bidpricecontroller.text = value;
    addIpo.bidpricecontroller.text.isEmpty
        ? addIpo.requriedprice = 0
        : addIpo.requriedprice = (int.parse(addIpo.bidpricecontroller.text) *
                int.parse(addIpo.qualityController.text.toString()))
            .toInt();
    if (addIpo.bidpricecontroller.text.isEmpty ||
        addIpo.bidpricecontroller.text == "0") {
      addIpo.biderrortext = addIpo.bidpricecontroller.text.isEmpty
          ? "* Value is required"
          : "Value cannot be 0";
      addIpo.requriedprice = 0;
    } else if ((int.parse(addIpo.bidpricecontroller.text)) >
            double.parse(mainstream.maxPrice.toString()).toInt() ||
        (int.parse(addIpo.bidpricecontroller.text)) <
            double.parse(mainstream.minPrice.toString()).toInt()) {
      addIpo.biderrortext =
          "Your bit price ranges between ₹${double.parse(mainstream.minPrice!).toInt()}-₹${double.parse(mainstream.maxPrice!).toInt()}";
      ischecked = false;
    } else {
      addIpo.biderrortext = "";
    }
    notifyListeners();
  }

  cutoffprice(
    bool isChecked,
    IpoDetails addIpo,
    MainIPO mainstream,
  ) {
    addIpo.biderrortext = "";
    addIpo.isChecked = !addIpo.isChecked;
    addIpo.isChecked == true
        ? addIpo.bidpricecontroller.text =
            ("${double.parse(mainstream.maxPrice!).toInt()}")
        : addIpo.bidpricecontroller.text =
            "${double.parse(mainstream.minPrice!).toInt()}";
    addIpo.isChecked == true
        ? addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice =
                double.parse(mainstream.maxPrice!).toInt() *
                    (int.parse(addIpo.qualityController.text))
        : addIpo.qualityController.text.isEmpty
            ? addIpo.qualityController.text = ""
            : addIpo.requriedprice =
                double.parse(mainstream.minPrice!).toInt() *
                    (int.parse(addIpo.qualityController.text));
    notifyListeners();
  }

  smeipocategory() {
    ipoCategory = [];
    try {
      toggleLoadingOn(true);
      for (var element in smeIpoModel!.sMEIPO!) {
        for (var i = 0; i < element.subCategorySettings!.length; i++) {
          if (element.subCategorySettings![i].allowUpi!) {
            if (element.subCategorySettings![i].subCatCode == "IND" &&
                element.subCategorySettings![i].caCode == "RETAIL") {
              ipoCategory.add({
                "subCatCode": "Individual",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            } else if (element.subCategorySettings![i].subCatCode == "EMP") {
              ipoCategory.add({
                "subCatCode": "Employee",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            } else if (element.subCategorySettings![i].subCatCode == "SHA") {
              ipoCategory.add({
                "subCatCode": "Shareholder",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            } else if (element.subCategorySettings![i].subCatCode == "POL") {
              ipoCategory.add({
                "subCatCode": "Policyholder",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            }
          }
        }
      }
      final seen = <String>{};
      ipoCategory = ipoCategory.where((map) {
        // Create a unique key string for each map
        final key = map.entries.map((e) => '${e.key}:${e.value}').join(',');
        if (seen.contains(key)) {
          return false;
        } else {
          seen.add(key);
          return true;
        }
      }).toList();
      ipoCategoryvalue = ipoCategory[0]["subCatCode"];
      _maxUPIAmt = double.parse(ipoCategory[0]["upiLimit"]);
      notifyListeners();
    } catch (e) {
    } finally {
      toggleLoadingOn(false);
    }
  }

  mainipocategory(String type) async {
    try {
      toggleLoadingOn(true);
      ipoCategory = [];
      for (var element in mainStreamIpoModel!.mainIPO!) {
        for (var i = 0; i < element.subCategorySettings!.length; i++) {
          if (element.subCategorySettings![i].allowUpi!) {
            if (element.subCategorySettings![i].subCatCode == "IND" &&
                element.subCategorySettings![i].caCode == "RETAIL") {
              ipoCategory.add({
                "subCatCode": "Individual",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            } else if (element.subCategorySettings![i].subCatCode == "EMP") {
              ipoCategory.add({
                "subCatCode": "Employee",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            } else if (element.subCategorySettings![i].subCatCode == "SHA") {
              ipoCategory.add({
                "subCatCode": "Shareholder",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            } else if (element.subCategorySettings![i].subCatCode == "POL") {
              ipoCategory.add({
                "subCatCode": "Policyholder",
                "upiLimit": "${element.subCategorySettings![i].maxUpiLimit}"
              });
            }
          }
        }
      }
      final seen = <String>{};
      ipoCategory = ipoCategory.where((map) {
        // Create a unique key string for each map
        final key = map.entries.map((e) => '${e.key}:${e.value}').join(',');
        if (seen.contains(key)) {
          return false;
        } else {
          seen.add(key);
          return true;
        }
      }).toList();
      ipoCategoryvalue = ipoCategory[0]["subCatCode"];
      _maxUPIAmt = double.parse(ipoCategory[0]["upiLimit"]);

      notifyListeners();
    } catch (e) {
    } finally {
      toggleLoadingOn(false);
    }
    notifyListeners();
  }

  policyfunction(bool ischecked, IpoDetails addIpo, double maxUPIAmt,
      BuildContext context) {
    ischecked = !ischecked;
    if (addIpo.requriedprice > maxUPIAmt) {
      ScaffoldMessenger.of(context).showSnackBar(warningMessage(context,
          "Maximum investment upto ₹${double.parse(maxUPIAmt.toString()).toInt()} only "));

      ischecked = false;
    } else if (addIpo.bidpricecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          warningMessage(context, "*Bid Price Value is required"));
      ischecked = false;
    }
    notifyListeners();
  }

  upiIDvalidation(String value, FundProvider upiid, String upierrortext) {
    upiid.viewupiid.text = value;
    if (upiid.viewupiid.text.isEmpty) {
      upierrortext = "* UPI ID cannot be empty";
    } else if (!RegExp(r'^[\w.-]+@[\w]+$')
        .hasMatch(upiid.viewupiid.text = value)) {
      upierrortext = 'Invalid UPI ID format';
    } else {
      upierrortext = '';
    }
    notifyListeners();
  }

  List<double> getCustomItemsHeight(List numofList) {
    List<double> itemsHeights = [];
    for (var i = 0; i < (numofList.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  modifyipocategory() {
    ipoCategory = [];
    for (var element = 0; element < ipoOrderBookModel!.length; element++) {
      for (var settings = 0;
          settings < ipoOrderBookModel![element].subcategorysettings!.length;
          settings++) {
        if (ipoOrderBookModel![element]
                .subcategorysettings![settings]
                .allowUpi ==
            true) {
          if (ipoOrderBookModel![element]
                      .subcategorysettings![settings]
                      .subCatCode ==
                  "IND" &&
              ipoOrderBookModel![element]
                      .subcategorysettings![settings]
                      .caCode ==
                  "RETAIL") {
            ipoCategory.add({
              "subCatCode": "Individual",
              "upiLimit":
                  "${ipoOrderBookModel![element].subcategorysettings![settings].maxUpiLimit}"
            });
          } else if (ipoOrderBookModel![element]
                  .subcategorysettings![settings]
                  .subCatCode ==
              "EMP") {
            ipoCategory.add({
              "subCatCode": "Employee",
              "upiLimit":
                  "${ipoOrderBookModel![element].subcategorysettings![settings].maxUpiLimit}"
            });
          } else if (ipoOrderBookModel![element]
                  .subcategorysettings![settings]
                  .subCatCode ==
              "SHA") {
            ipoCategory.add({
              "subCatCode": "Shareholder",
              "upiLimit":
                  "${ipoOrderBookModel![element].subcategorysettings![settings].maxUpiLimit}"
            });
          } else if (ipoOrderBookModel![element]
                  .subcategorysettings![settings]
                  .subCatCode ==
              "POL") {
            ipoCategory.add({
              "subCatCode": "Policyholder",
              "upiLimit":
                  "${ipoOrderBookModel![element].subcategorysettings![settings].maxUpiLimit}"
            });
          }
        }
      }
    }

    final seen = <String>{};
    ipoCategory = ipoCategory.where((map) {
      // Create a unique key string for each map
      final key = map.entries.map((e) => '${e.key}:${e.value}').join(',');
      if (seen.contains(key)) {
        return false;
      } else {
        seen.add(key);
        return true;
      }
    }).toList();
    ipoCategoryvalue = ipoCategory[0]["subCatCode"];
    _maxUPIAmt = double.parse(ipoCategory[0]["upiLimit"]);
    notifyListeners();
  }

  List ipoCategory = [];

  String ipoCategoryvalue = "";
  String get ipoCategorys => ipoCategoryvalue;

  chngCategoryType(String val) async {
    for (var element in ipoCategory) {
      if (val == element['subCatCode']) {
        _maxUPIAmt = double.parse(element['upiLimit']);
      }
    }

    ipoCategoryvalue = val;
    notifyListeners();
  }

  List<DropdownMenuItem<String>> addDividerSubCategory(List numofList) {
    List<DropdownMenuItem<String>> menuItems = [];
    for (var item in numofList) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
              value: item["subCatCode"].toString(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(item["subCatCode"].toString()))),
          //If it's last item, we will not add Divider after it.
          if (item != numofList.last)
            DropdownMenuItem<String>(
              enabled: false,
              child: Divider(
                color: colors.colorDivider,
              ),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<Tab> _ipotabs = [
    const Tab(text: "Open order"),
    const Tab(text: "Close order"),
  ];
  List<Tab> get ipotabs => _ipotabs;

  ipotab() {
    _ipotabs = [
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text("Open Order (${_openorder!.length})"),
          ])),
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text("Close Order  (${_closeorder!.length})"),
          ]))
    ];
    notifyListeners();
  }

  ordersplit() {
    _openorder = [];
    _closeorder = [];
    _maxValue = "";
    _stringList = [];
    try {
      togglefundLoadingOn(true);

      for (var element in _ipoOrderBookModel!) {
        if (element.reponseStatus == 'new success' ||
            element.reponseStatus == 'pending') {
          _openorder!.add(element);
          _openorder!.sort((a, b) => a.companyName!.compareTo(b.companyName!));
        } else {
          _closeorder!.add(element);
          _closeorder!.sort((a, b) => a.companyName!.compareTo(b.companyName!));
        }
      }
    } catch (e) {
    } finally {
      togglefundLoadingOn(false);
    }

    notifyListeners();
  }

//// API CALLS
  Future getipoorderbookmodel(bool isTrue) async {
    try {
      togglefundLoadingOn(isTrue ? true : false);
      _ipoOrderBookModel = await api.fetchipoorderbook();
      ordersplit();
      //  print("IPO RES ORDERBOOK ::: ${_ipoOrderBookModel![0].bidDetail![0].amount}");
      notifyListeners();
      return _ipoOrderBookModel;
    } catch (e) {
      print("IPOs ORDERBOOK error:: $e");
    } finally {
      togglefundLoadingOn(false);
    }
  }

  Future fetchupiidvalidation(BuildContext context, String upiId, String accno,
      MenuData menudata, List<IposBid> iposbids, String iposupiid) async {
    try {
      toggleLoadingOn(true);
      _upiIdValidationModel = await api.getVerifyUpi(upiId, accno);
      if (_upiIdValidationModel!.data!.verifiedVPAStatus1 == "Available" ||
          _upiIdValidationModel!.data!.verifiedVPAStatus2 == "Available") {
        getipoplaceorder(context, menudata, iposbids, iposupiid);
        getipoorderbookmodel(true);
        ipotab();
        Navigator.pushNamed(context, Routes.ipoorderbook);
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

  Future getipoplaceorder(BuildContext context, MenuData menudata,
      List<IposBid> iposbids, String iposupiid) async {
    try {
      toggleLoad(true);

      _ipoOrderResponcesModel =
          await api.fetchipoplaceorder(menudata, iposbids, iposupiid);
      getipoorderbookmodel(true);
      ipotab();

      ScaffoldMessenger.of(context).showSnackBar(
          successMessage(context, '${_ipoOrderResponcesModel!.msg}'));

      return _ipoOrderResponcesModel;
    } catch (e) {
      print("IPOs placeorder error:: $e");
      notifyListeners();
    } finally {
      toggleLoad(false);
    }
  }

  Future getipoperfomance(int year) async {
    try {
      toggleLoadingOn(true);
      _ipoPerformanceModel = await api.fetchipoperfomance(year);
      notifyListeners();
      return _ipoPerformanceModel;
    } catch (e) {
      print("IPOs Perfomance error:: $e");
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future getmainstreamipo() async {
    try {
      toggleLoadingOn(true);
      _mainStreamIpoModel = await api.fetchmainstreamoipo();
      getipoorderbookmodel(true);
      notifyListeners();

      return _mainStreamIpoModel;
    } catch (e) {
      //print("MainStream IPOs error:: $e");
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future getSmeIpo() async {
    try {
      toggleLoadingOn(true);
      _smeIpoModel = await api.fetchsmeipo();
      
      tabSize();
      notifyListeners();
      return _smeIpoModel;
    } catch (e) {
      print("SME IPOs error:: $e");
    } finally {
      toggleLoadingOn(false);
    }
  }
}

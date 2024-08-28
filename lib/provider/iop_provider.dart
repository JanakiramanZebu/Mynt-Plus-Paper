// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../sharedWidget/snack_bar.dart';
import 'core/default_change_notifier.dart';

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
    log("$_isActiveMainStream");
    notifyListeners();
  }

  void activeSMEBtn(bool val) {
    _isActiveSME = val;
    log("$_isActiveSME");
    notifyListeners();
  }

  IPOProvider(this.ref);

  // List<IPOOrderBookModel>? _orderBookModel;
  // List<IPOOrderBookModel>? get orderBookModel => _orderBookModel;

  final TextEditingController viewupiid = TextEditingController();

 

  SmeIpoModel? _smeIpoModel;
  SmeIpoModel? get smeIpoModel => _smeIpoModel;

  MainStreamIpoModel? _mainStreamIpoModel;
  MainStreamIpoModel? get mainStreamIpoModel => _mainStreamIpoModel;

  IpoPerformanceModel? _ipoPerformanceModel;
  IpoPerformanceModel? get ipoPerformanceModel => _ipoPerformanceModel;

  IpoOrderResponcesModel? _ipoOrderResponcesModel;
  IpoOrderResponcesModel? get ipoOrderResponcesModel => _ipoOrderResponcesModel;

  List<IpoOrderBookModel>? _ipoOrderBookModel;
  List<IpoOrderBookModel>? get ipoOrderBookModel => _ipoOrderBookModel;

  List<IpoOrderBookModel>? _openorder = [];
  List<IpoOrderBookModel>? get openorder => _openorder;

  List<IpoOrderBookModel>? _closeorder = [];
  List<IpoOrderBookModel>? get closeorder => _closeorder;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  double _maxUPIAmt = 0.00;

  double get maxUPIAmt => _maxUPIAmt;
  changeTabIndex(int index) {
    _selectedTab = index;
  }

VerifyUPIModel? _verifyUPIModel;
VerifyUPIModel? get verifyUPIModel=>_verifyUPIModel;

  // smeipocategory() {
  //   for (var main = 0; main < smeIpoModel!.sMEIPO!.length; main++) {
  //     for (var i = 0;
  //         i < smeIpoModel!.sMEIPO![main].subCategorySettings!.length;
  //         i++) {
  //       if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].allowUpi ==
  //           true) {
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //                 "IND" &&
  //             smeIpoModel!.sMEIPO![main].subCategorySettings![i].caCode ==
  //                 "RETAIL") {
  //           ipoCategory.add("Individual");
  //         }
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //             "EMP") {
  //           ipoCategory.add("Employee");
  //         }
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //             "SHA") {
  //           ipoCategory.add("Shareholder");
  //         }
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //             "POL") {
  //           ipoCategory.add("Policyholder");
  //         }
  //       }
  //     }
  //     ipoCategoryvalue = ipoCategory[0];
  //   }
  //   notifyListeners();
  // }

  mainipocategory() {
    ipoCategory = [];

for (var element in  mainStreamIpoModel!.mainIPO!) {
  for (var i = 0; i < element.subCategorySettings!.length; i++) {
      if (element.subCategorySettings![i].allowUpi!  ) {
          print("  log ${element.subCategorySettings![i].subCatCode} ${element.subCategorySettings![i]..allowUpi}");

          if (element.subCategorySettings![i].subCatCode ==
                  "IND" &&
          element.subCategorySettings![i].caCode ==
                  "RETAIL") {
            ipoCategory.add({
              "subCatCode": "Individual",
              "upiLimit":
                  "${element.subCategorySettings![i].maxUpiLimit}"
            });
          } else if (element.subCategorySettings![i].subCatCode ==
              "EMP") {
            ipoCategory.add({
              "subCatCode": "Employee",
              "upiLimit":
                  "${element.subCategorySettings![i].maxUpiLimit}"
            });
          } else if (element.subCategorySettings![i].subCatCode ==
              "SHA") {
            ipoCategory.add({
              "subCatCode": "Shareholder",
              "upiLimit":
                  "${element.subCategorySettings![i].maxUpiLimit}"
            });
          } else if (element.subCategorySettings![i].subCatCode ==
              "POL") {
            ipoCategory.add({
              "subCatCode": "Policyholder",
              "upiLimit":
                  "${element.subCategorySettings![i].maxUpiLimit}"
            });
          }
  }
}}

    // for (var main = 0; main < mainStreamIpoModel!.mainIPO!.length; main++) {
    //   for (var i = 0;
    //       i < mainStreamIpoModel!.mainIPO![main].subCategorySettings!.length;
    //       i++) {
    //     if (mainStreamIpoModel!
    //             .mainIPO![main].subCategorySettings![i].allowUpi!  ) {

    //                 print("  log ${mainStreamIpoModel!
    //               .mainIPO![main].subCategorySettings![i].subCatCode}");
    //       if (mainStreamIpoModel!
    //                   .mainIPO![main].subCategorySettings![i].subCatCode ==
    //               "IND" &&
    //           mainStreamIpoModel!
    //                   .mainIPO![main].subCategorySettings![i].caCode ==
    //               "RETAIL") {
    //         ipoCategory.add({
    //           "subCatCode": "Individual",
    //           "upiLimit":
    //               "${mainStreamIpoModel!.mainIPO![main].subCategorySettings![i].maxUpiLimit}"
    //         });
    //       } else if (mainStreamIpoModel!
    //               .mainIPO![main].subCategorySettings![i].subCatCode ==
    //           "EMP") {
    //         ipoCategory.add({
    //           "subCatCode": "Employee",
    //           "upiLimit":
    //               "${mainStreamIpoModel!.mainIPO![main].subCategorySettings![i].maxUpiLimit}"
    //         });
    //       } else if (mainStreamIpoModel!
    //               .mainIPO![main].subCategorySettings![i].subCatCode ==
    //           "SHA") {
    //         ipoCategory.add({
    //           "subCatCode": "Shareholder",
    //           "upiLimit":
    //               "${mainStreamIpoModel!.mainIPO![main].subCategorySettings![i].maxUpiLimit}"
    //         });
    //       } else if (mainStreamIpoModel!
    //               .mainIPO![main].subCategorySettings![i].subCatCode ==
    //           "POL") {
    //         ipoCategory.add({
    //           "subCatCode": "Policyholder",
    //           "upiLimit":
    //               "${mainStreamIpoModel!.mainIPO![main].subCategorySettings![i].maxUpiLimit}"
    //         });
    //       }
    //     }
        
    //     else{
    //       print("  sdf ${mainStreamIpoModel!
    //               .mainIPO![main].subCategorySettings![i].subCatCode}");
    //     }
    //   }
    // }

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

    log(" sdf $ipoCategory");
    ipoCategoryvalue = ipoCategory[0]["subCatCode"];
    _maxUPIAmt = double.parse(ipoCategory[0]["upiLimit"]);
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

  List ipoCategory = [];

  String ipoCategoryvalue = "";
  String get ipoCategorys => ipoCategoryvalue;

  // maxprice(int length) {
  //   for (var main = 0; main < length; main++) {
  //     for (var i = 0;
  //         i < smeIpoModel!.sMEIPO![main].subCategorySettings!.length;
  //         i++) {
  //       if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].allowUpi ==
  //           true) {
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //                 "IND" &&
  //             smeIpoModel!.sMEIPO![main].subCategorySettings![i].caCode ==
  //                 "RETAIL") {
  //           ipoCategory.add(smeIpoModel!
  //               .sMEIPO![main].subCategorySettings![i].maxUpiLimit
  //               .toString());
  //         }
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //             "EMP") {
  //           ipoCategory.add(smeIpoModel!
  //               .sMEIPO![main].subCategorySettings![i].maxUpiLimit
  //               .toString());
  //         }
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //             "SHA") {
  //           ipoCategory.add(smeIpoModel!
  //               .sMEIPO![main].subCategorySettings![i].maxUpiLimit
  //               .toString());
  //         }
  //         if (smeIpoModel!.sMEIPO![main].subCategorySettings![i].subCatCode ==
  //             "POL") {
  //           ipoCategory.add(smeIpoModel!
  //               .sMEIPO![main].subCategorySettings![i].maxUpiLimit
  //               .toString());
  //         }
  //       }
  //       for (var i = 0; i < ipoCategory.length; i++) {
  //         print(ipoCategory[i]);
  //       }
  //     }

  //     ipoCategoryvalue = ipoCategory[0];
  //   }
  // }

  chngPeersType(String val) async {
for (var element in ipoCategory) {
  
  if (val==element['subCatCode']) {
    _maxUPIAmt=double.parse(element['upiLimit']);

    print("$_maxUPIAmt");
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
  }

  ordersplit() {
    _openorder = [];
    _closeorder = [];
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
    notifyListeners();
  }

  Future getipoorderbookmodel() async {
    try {
      _ipoOrderBookModel = await api.fetchipoorderbook();
      ordersplit();
      return _ipoOrderBookModel;
    } catch (e) {
      print("IPOs ORDERBOOK error:: $e");
    }
  }

  Future fetchVerifyUpi(BuildContext context, String upiId, String accno,
      MenuData menudata, List<IposBid> iposbids, String iposupiid) async {
    try {
      toggleLoadingOn(true);
    _verifyUPIModel = await api.getVerifyUpi(upiId, accno);
      if (_verifyUPIModel!.data!.verifiedVPAStatus1 == "Available" ||
          _verifyUPIModel!.data!.verifiedVPAStatus2 == "Available") {
        getipoplaceorder(context, menudata, iposbids, iposupiid);
        getipoorderbookmodel();
        ipotab();
        // Navigator.pushNamed(context, Routes.ipoorderbook);
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, '${_ipoOrderResponcesModel!.msg}'));
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
      getipoorderbookmodel();
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
      _ipoPerformanceModel = await api.fetchipoperfomance(year);
      notifyListeners();
      return _ipoPerformanceModel;
    } catch (e) {
      print("IPOs Perfomance error:: $e");
    }
  }

  Future getmainstreamipo() async {
    try {
      _mainStreamIpoModel = await api.fetchmainstreamoipo();
      notifyListeners();
      print(_mainStreamIpoModel!.msg);
      return _mainStreamIpoModel;
    } catch (e) {
      print("MainStream IPOs error:: $e");
    }
  }

  Future getSmeIpo() async {
    try {
      _smeIpoModel = await api.fetchsmeipo();
      notifyListeners();
      return _smeIpoModel;
    } catch (e) {
      print("SME IPOs error:: $e");
    }
  }
}

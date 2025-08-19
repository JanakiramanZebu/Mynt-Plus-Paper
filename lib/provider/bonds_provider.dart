import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:mynt_plus/models/bonds_model/bonds_place_order_details_model.dart';
import 'package:mynt_plus/models/bonds_model/place_order_response_model.dart';
// import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/routes/route_names.dart';
// import 'package:mynt_plus/screens/bonds/bonds_orderbook_screen/bonds_order_book_main_screen.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/bonds_model/all_bonds_list_model.dart';
import '../models/bonds_model/govt_bonds_model.dart';
import '../models/bonds_model/ledger_bal_model.dart';
import '../models/bonds_model/sovereign_gold_bonds_model.dart';
import '../models/bonds_model/state_bonds_model.dart';
import '../models/bonds_model/treasury_bonds_model.dart';
import 'core/default_change_notifier.dart';
import 'stocks_provider.dart';

final bondsProvider = ChangeNotifierProvider((ref) => BondsProvider(ref));

class BondsProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;
  BondsProvider(this.ref);

  PlacedBondOrderResp? _bondOrderResponcesModel;

  bool _isBondPlaceOrderBtnActive = false;
  bool get isBondPlaceOrderBtnActive => _isBondPlaceOrderBtnActive;

  set setisBondPlaceOrderBtnActiveValue(bool value) {
    _isBondPlaceOrderBtnActive = value;
  }
// int bondsSelectedTab = 0;

  Map<String, dynamic> _selectedBondTab = {
    "Aimgpath": "",
    // "imgpath": assets.exportIcon,
    "title": "Govt. bonds",
    "index": 0,
  };
  Map<String, dynamic> get selectedBondTab => _selectedBondTab;

  set setSelectedBondTab(Map<String, dynamic> selectedTab) {
    _selectedBondTab = selectedTab;
  }

  // GovtBonds? _govtBonds;
  // TreasuryBonds? _treasuryBonds;
  // StateBonds? _stateBonds;

  // SovereignGoldBonds? _sovereignGoldBonds;

  bool _bondsMyBidsload = true;
  bool get bondsMyBidsload => _bondsMyBidsload;

  GovtBonds? _govtBonds;
  GovtBonds? get govtBonds => _govtBonds;

  TreasuryBonds? _treasuryBonds;
  TreasuryBonds? get treasuryBonds => _treasuryBonds;

  StateBonds? _stateBonds;
  StateBonds? get stateBonds => _stateBonds;

  SovereignGoldBonds? _sovereignGoldBonds;
  SovereignGoldBonds? get sovereignGoldBonds => _sovereignGoldBonds;

  LedgerBalModel? _ledgerBalModel;
  LedgerBalModel? get ledgerBalModel => _ledgerBalModel;

  List<BondsOrderBookModel>? _bondsOrderBook;
  List<BondsOrderBookModel>? get bondsOrderBook => _bondsOrderBook;

  List<BondsOrderBookModel>? _openOrderBook;
  List<BondsOrderBookModel>? get openOrderBook => _openOrderBook;

  List<BondsOrderBookModel>? _closeOrderBook;
  List<BondsOrderBookModel>? get closeOrderBook => _closeOrderBook;

  List<BondsList>? _bondsList = [];
  List<BondsList>? get bondsList => _bondsList;

  final TextEditingController _unitValueCtrl = TextEditingController();
  TextEditingController get unitValueCtrl => _unitValueCtrl;

  final TextEditingController _bondscommonsearchcontroller =
      TextEditingController();
  TextEditingController get bondscommonsearchcontroller =>
      _bondscommonsearchcontroller;

  // Expose setter to update search text programmatically (e.g., from dashboard)
  void setBondsSearchQuery(String value) {
    _bondscommonsearchcontroller.text = value;
    notifyListeners();
  }

  clearCommonBondsSearch() {
    // _bondscommonsearchcontroller.text = "";
    ref.read(stocksProvide).searchController.clear();
    _bondsCommonSearchList = [];
    notifyListeners();
  }

  List<BondsList> _bondsCommonSearchList = [];
  List<BondsList> get bondsCommonSearchList => _bondsCommonSearchList;

  searchCommonBonds(String SearchBond, BuildContext context) {
    _bondsCommonSearchList = [];
    if (SearchBond.isNotEmpty) {
      _bondsCommonSearchList = _bondsList!
          .where((element) =>
              element.symbol!.toUpperCase().contains(SearchBond.toUpperCase()))
          .toList();
    }
    notifyListeners();
  }

  // Filter bonds open/close order books by current search text for "My Bids"
  List<BondsOrderBookModel> filterOpenOrdersBySearch() {
    final query = _bondscommonsearchcontroller.text.trim().toLowerCase();
    final list = openOrderBook ?? [];
    if (query.isEmpty) return list;
    return list.where((o) {
      final symbol = (o.symbol ?? '').toLowerCase();
      return symbol.contains(query);
    }).toList();
  }

  List<BondsOrderBookModel> filterCloseOrdersBySearch() {
    final query = _bondscommonsearchcontroller.text.trim().toLowerCase();
    final list = closeOrderBook ?? [];
    if (query.isEmpty) return list;
    return list.where((o) {
      final symbol = (o.symbol ?? '').toLowerCase();
      return symbol.contains(query);
    }).toList();
  }

// bonds.ledgerBalModel!.total
// ======= Bonds Place Order Validation Functions ===================

  bool checkSufficientLedgerBal(BondDetails bondDetails) {
    bool status = false;
    try {
      if (double.parse(_ledgerBalModel!.total!) >=
          bondDetails.minrequriedprice) {
        status = true;
      } else {
        status = false;
      }
    } catch (e) {}
    return status;
  }

  checkForErrorsInBondPlaceOrder(BondDetails bondDetails) {
    bool status = false;
    if (bondDetails.quantityerrortext.isEmpty &&
        bondDetails.biderrortext.isEmpty) {
      status = true;
    } else {
      status = false;
    }

    return status;
  }

  bondValidateController(BondDetails bondDetails) {
    if (bondDetails.quantityController.text.isEmpty ||
        bondDetails.quantityController.text == "0") {
      bondDetails.quantityerrortext =
          bondDetails.quantityController.text.isEmpty
              ? "* Value is required"
              : "Value cannot be 0";
      setisBondPlaceOrderBtnActiveValue = false;
    } else if (double.parse(bondDetails.quantityController.text) <
        (bondDetails.lotsize)) {
      bondDetails.quantityerrortext =
          "Minimum Lot Size is ₹${(bondDetails.lotsize).toString()}";
      setisBondPlaceOrderBtnActiveValue = false;
    } else if (bondDetails.minrequriedprice > bondDetails.maxrequriedprice) {
      bondDetails.quantityerrortext =
          "Maximum investment upto ₹${bondDetails.maxrequriedprice.toString()} only ";
      setisBondPlaceOrderBtnActiveValue = false;
    } else if (double.parse(bondDetails.quantityController.text) %
            bondDetails.lotsize !=
        0) {
      bondDetails.quantityerrortext =
          "Quantity must be a multiple of ${bondDetails.lotsize}";
      setisBondPlaceOrderBtnActiveValue = false;
    } else {
      bondDetails.minrequriedprice =
          double.parse(bondDetails.quantityController.text).toInt() *
              int.parse(bondDetails.bidpricecontroller.text);
      bondDetails.quantityerrortext = "";
      setisBondPlaceOrderBtnActiveValue = true;
      if (!checkSufficientLedgerBal(bondDetails)) {
        bondDetails.ledgerBalErrorText =
            "Insufficient balance, Add fund  ₹${(bondDetails.minrequriedprice - double.parse(_ledgerBalModel?.total ?? "0.00")).ceil().toString()} ";
      } else {
        bondDetails.ledgerBalErrorText = "";
      }
    }
    notifyListeners();
  }

  addQuantity(BondDetails bondDetails) {
    if (bondDetails.quantityController.text.isNotEmpty) {
      var currentQuantity =
          double.parse(bondDetails.quantityController.text).toInt();
      var newQuantity = currentQuantity + bondDetails.lotsize;
      // Ensure we don't exceed max quantity
      if (newQuantity <=
          bondDetails.maxrequriedprice / double.parse(bondDetails.bidprice)) {
        bondDetails.quantityController.text = newQuantity.toString();
      }
    } else {
      // If empty, start with minimum lot size
      bondDetails.quantityController.text = bondDetails.lotsize.toString();
    }
    notifyListeners();
    bondValidateController(bondDetails);
  }

  substractQuantity(BondDetails bondDetails) {
    if (bondDetails.quantityController.text.isNotEmpty) {
      var currentQuantity =
          double.parse(bondDetails.quantityController.text).toInt();
      var newQuantity = currentQuantity - bondDetails.lotsize;
      // Ensure we don't go below minimum lot size
      if (newQuantity >= bondDetails.lotsize) {
        bondDetails.quantityController.text = newQuantity.toString();
      }
    }
    notifyListeners();
    bondValidateController(bondDetails);
  }

  quantityOnchange(BondDetails bondDetails, String value) {
    if (value.isNotEmpty) {
      try {
        var quantity = double.parse(value).toInt();
        // Only update if the value has actually changed to avoid cursor jumping
        if (bondDetails.quantityController.text != quantity.toString()) {
          // Store current cursor position
          int cursorPosition =
              bondDetails.quantityController.selection.baseOffset;

          // Update the text
          bondDetails.quantityController.text = quantity.toString();

          // Restore cursor position if it was within the text length
          if (cursorPosition <= quantity.toString().length) {
            bondDetails.quantityController.selection =
                TextSelection.fromPosition(
              TextPosition(offset: cursorPosition),
            );
          }
        }
        bondDetails.minrequriedprice =
            (quantity * int.parse(bondDetails.bidpricecontroller.text)).toInt();
      } catch (e) {
        // If not a valid number, don't update
        return;
      }
    } else {
      bondDetails.quantityController.text = "";
      bondDetails.minrequriedprice = 0;
    }
    notifyListeners();
    bondValidateController(bondDetails);
  }

// ======= End of Bonds Place Order Validation Functions ===================

  ordersplit() {
    _openOrderBook = [];
    _closeOrderBook = [];

    try {
      togglefundLoadingOn(true);

      for (var element in _bondsOrderBook ?? []) {
        if ((element.reponseStatus == 'success' &&
                element.orderStatus != "CS") ||
            element.reponseStatus == 'pending') {
          _openOrderBook!.add(element);
          // _openorder!.sort((a, b) => a.companyName!.compareTo(b.companyName!));
        } else {
          _closeOrderBook!.add(element);
          // _closeorder!.sort((a, b) => a.companyName!.compareTo(b.companyName!));
        }
      }
      _openOrderBook?.sort((b, a) {
        try {
          // Handle empty or null responseDatetime
          if (a.responseDatetime == null ||
              a.responseDatetime.toString().isEmpty) {
            return 1; // Put items with null/empty datetime at the end
          }
          if (b.responseDatetime == null ||
              b.responseDatetime.toString().isEmpty) {
            return -1; // Put items with null/empty datetime at the end
          }

          DateTime dateA = DateTime.parse(a.responseDatetime.toString());
          DateTime dateB = DateTime.parse(b.responseDatetime.toString());
          return dateA.compareTo(dateB); // Newest first (descending order)
        } catch (e) {
          print("Error parsing datetime in openOrderBook sort: $e");
          return 0; // Keep original order if parsing fails
        }
      });
      _closeOrderBook?.sort((b, a) {
        try {
          // Handle empty or null responseDatetime
          if (a.responseDatetime == null ||
              a.responseDatetime.toString().isEmpty) {
            return 1; // Put items with null/empty datetime at the end
          }
          if (b.responseDatetime == null ||
              b.responseDatetime.toString().isEmpty) {
            return -1; // Put items with null/empty datetime at the end
          }

          DateTime dateA = DateTime.parse(a.responseDatetime.toString());
          DateTime dateB = DateTime.parse(b.responseDatetime.toString());
          return dateA.compareTo(dateB); // Newest first (descending order)
        } catch (e) {
          print("Error parsing datetime in closeOrderBook sort: $e");
          return 0; // Keep original order if parsing fails
        }
      });
      print("ordersplit :: Open Orders (${_openOrderBook?.length}):");
      for (var order in _openOrderBook ?? []) {
        print(order.toJson());
      }

      print("ordersplit :: Close Orders (${_closeOrderBook?.length}):");
      for (var order in _closeOrderBook ?? []) {
        print(order.toJson());
      }
    } catch (e) {
      print("ordersplit :: ${e}");
    } finally {
      togglefundLoadingOn(false);
    }

    notifyListeners();
  }

  // changeBondTab(int val) {
  //   _selectedBondTab = tablistitems[val];
  //   if (val == 0) {
  //     _bondsList = _govtBonds!.ncbGSec ?? [];
  //   } else if (val == 1) {
  //     _bondsList = _treasuryBonds!.ncbTBill ?? [];
  //   } else if (val == 2) {
  //     _bondsList = _stateBonds!.ncbSDL ?? [];
  //   } else if (val == 3) {
  //     _bondsList = _sovereignGoldBonds!.ncbSGB ?? [];
  //   }  else {
  //      _bondsList = _bondsOrderBook ;
  //   }

  //   print("Bonds Length ${_bondsList!.length}");
  //   notifyListeners();
  // }

// =============== Fetch Bond Data From API ======================

  Future fetchAllBonds() async {
    try {
      _bondsList = [];
      await fetchGovtBonds();
      await fetchTreassuryBonds();
      await fetchStateBonds();
      await fetchGoldBonds();
      await fetchBondsOrderBook();

      // Combine all types of bonds into bondsList
      if (_govtBonds?.ncbGSec != null) {
        _bondsList!.addAll(_govtBonds!.ncbGSec!);
      }
      if (_treasuryBonds?.ncbTBill != null) {
        _bondsList!.addAll(_treasuryBonds!.ncbTBill!);
      }
      if (_stateBonds?.ncbSDL != null) {
        _bondsList!.addAll(_stateBonds!.ncbSDL!);
      }
      if (_sovereignGoldBonds?.ncbSGB != null) {
        _bondsList!.addAll(_sovereignGoldBonds!.ncbSGB!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchGovtBonds() async {
    try {
      _govtBonds = await api.getGovtBondApi();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching bonds: $e");
    }
  }

  Future fetchTreassuryBonds() async {
    try {
      _treasuryBonds = await api.getTreasuryBondApi();
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchStateBonds() async {
    try {
      _stateBonds = await api.getStateBondApi();
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchGoldBonds() async {
    try {
      _sovereignGoldBonds = await api.getGoldBondApi();
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchLedgerBal() async {
    try {
      _ledgerBalModel = await api.getLedgerBalApi();

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchBondsOrderBook() async {
    try {
      _bondsMyBidsload = true;
      _bondsOrderBook = await api.getBondsOrderBookApi();
      // _bondsOrderBook.bondsOrderBook.forEach()
      // print("fetchBondsOrderBook called :: $_bondsOrderBook. ");
      print(
          "fetchBondsOrderBook called :: ${_bondsOrderBook?.length} orders fetched.");
      ordersplit();
      notifyListeners();
    } catch (e) {
      print("fetchBondsOrderBook :: $e ");
    } finally {
      _bondsMyBidsload = false;
    }
  }

  Future validateClientLedgertoPlaceOrder(BuildContext context) async {
    try {
      toggleLoadingOn(true);
      await fetchLedgerBal();

      // if (_ledgerBalModel != null) {

      //   getipoplaceorder(context, menudata, iposbids, iposupiid);
      //   getipoorderbookmodel(true);

      //   _upierror = "";
      //   _upivalid = false;
      //   Navigator.pop(context);
      //   Navigator.pop(context);
      //   Navigator.pushNamed(context, Routes.bondorderbook);
      // } else {
      //   _upivalid = true;
      //   _upierror = "Invalid UPI ID";
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(warningMessage(context, 'Invalid UPI ID'));
      // }

      //log("HDFC BANK $_upiIdValidationModel");
    } catch (e) {
      log("Failed to fetch bank Data:: ${e.toString()}");
    } finally {
      toggleLoadingOn(false);
    }
    notifyListeners();
  }

  Future placeBondOrder(
      BuildContext context, Map<String, dynamic> bondOrderData) async {
    try {
      toggleLoad(true);
      String symbol = bondOrderData["symbol"];
      int investmentValue = bondOrderData["investmentValue"];
      int price = bondOrderData["price"];
      _bondOrderResponcesModel =
          await api.placeBondOrderApi(symbol, investmentValue, price);
      fetchBondsOrderBook();

      ScaffoldMessenger.of(context).showSnackBar(
          _bondOrderResponcesModel!.status == "success"
              ? successMessage(
                  context, _bondOrderResponcesModel!.orderStatusResponse!)
              : error(context, _bondOrderResponcesModel!.reason!));
      Navigator.pop(context);
      // Navigator.pushReplacementNamed(context, Routes.bonds, arguments: 1);
      // return _ipoOrderResponcesModel;
    } catch (e) {
      print("bonds placeorder error:: $e");
    } finally {
      toggleLoad(false);
    }
    notifyListeners();
  }

  Future cancelBondOrder(
      BuildContext context, Map<String, dynamic> bondOrderData) async {
    try {
      toggleLoad(true);
      _bondsMyBidsload = true;
      String symbol = bondOrderData["symbol"];
      String investmentValue = bondOrderData["investmentValue"];
      int price = bondOrderData["price"];
      String clientApplicationNumber = bondOrderData["clientApplicationNumber"];
      String orderNumber = bondOrderData["orderNumber"];

      print('Cancel API call initiated with bondOrderData: $bondOrderData');
      _bondOrderResponcesModel = await api.cancelBondOrderApi(
          symbol, investmentValue, price, clientApplicationNumber, orderNumber);
      print('Cancel API response: ${_bondOrderResponcesModel?.toJson()}');
      await fetchBondsOrderBook();
      print('Updated bonds order book fetched successfully.');
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(successMessage(
          context, _bondOrderResponcesModel!.orderStatusResponse ?? ""));

      // Navigator.pop(context);
      // Navigator.pushNamed(context, Routes.bondsorderbook);
      // return _ipoOrderResponcesModel;
    } catch (e) {
      print("bonds cancelBondOrder error:: $e");
    } finally {
      toggleLoad(false);
      _bondsMyBidsload = false;
    }
    notifyListeners();
  }
}

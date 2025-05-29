import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_book_model/gtt_order_book.dart';
import '../models/order_book_model/order_book_model.dart';
import '../sharedWidget/enums.dart';
import 'core/default_change_notifier.dart';
import 'market_watch_provider.dart';

final ordInputProvider =
    ChangeNotifierProvider((ref) => OrderInputProvider(ref));

class OrderInputProvider extends DefaultChangeNotifier {
  final Ref ref;

// Repeat order

  TextEditingController prcCtrl = TextEditingController();
  TextEditingController triggerPriceCtrl = TextEditingController();
  TextEditingController mktProtCtrl = TextEditingController();
  TextEditingController qtyCrl = TextEditingController();
  TextEditingController discQtyCtrl = TextEditingController();
  TextEditingController stopLossCtrl = TextEditingController();
  TextEditingController targetCtrl = TextEditingController();
  TextEditingController trailingTickCtrl = TextEditingController();

  String _orderName = "Regular";
  String get orderName => _orderName;

  final List _orderNames = ["Regular", "Cover", "Bracket"];
  List get orderNames => _orderNames;

  String _priceName = "Limit";
  String get priceName => _priceName;

  final List _priceNames = ["Limit", "Market", "SL Limit", "SL MKT"];
  List get priceNames => _priceNames;

  String _validityName = "DAY";
  String get validityName => _validityName;

  final List<String> _validityNames = ["DAY", "IOC", "EOS"];
  List<String> get validityNames => _validityNames;

  String priceVal = "0.00";

  // Change order Validaity(Day/Ioc)
  chngeValidity(String val) {
    _validityName = val;
    notifyListeners();
  }

  // Change order type
  chngOrderName(String val) {
    _orderName = val;
    notifyListeners();
  }

  // Change order Price type

  chngPriceName(String val) {
    _priceName = val;
    notifyListeners();
  }

  InvestType _investType = InvestType.intraday;
  InvestType get investType => _investType;

  String _ordType = "C";
  String get orderType => _ordType;

  String _ocoOrdType = "C";
  String get ocoOrderType => _ocoOrdType;

  String _prcType = "LMT";
  String get prcType => _prcType;

  OrderInputProvider(this.ref);

// Change investment type based on condition
  chngInvesType(InvestType val, String orderType) {
    if (orderType == "PlcOrder" || orderType == "GTT") {
      _investType = val;
      if (val == InvestType.intraday) {
        _ordType = "I";
      } else if (val == InvestType.delivery) {
        _ordType = "C";
      } else {
        _ordType = "M";
      }
    } else {
      _ocoInvestType = val;

      if (val == InvestType.intraday) {
        _ocoOrdType = "I";
      } else if (val == InvestType.delivery) {
        _ocoOrdType = "C";
      } else {
        _ocoOrdType = "M";
      }
    }

    notifyListeners();
  }

  chngOrderType(String val) {
    if (val == "Cover") {
      _ordType = "H";
    } else if (val == "Bracket") {
      _ordType = "B";
    } else {
      _ordType = "F";
    }
    notifyListeners();
    log("val $_ordType");
  }

// This method for retrieving information from the order book to place orders again
  getOrderData(OrderBookModel data) {
    qtyCrl.text = "${data.qty}";
    prcCtrl.text = "${data.prc}";
    triggerPriceCtrl.text = data.trgprc ?? "";
    mktProtCtrl.text = data.mktProtection ?? "5";
    discQtyCtrl.text = data.dscqty ?? "0";
    stopLossCtrl.text = data.blprc ?? "";
    trailingTickCtrl.text = data.trailprc ?? "";
    if (data.sPrdtAli == "MIS" ||
        data.sPrdtAli == "CNC" ||
        data.sPrdtAli == "NRML") {
      _orderName = "Regular";
      if (data.prd == "C") {
        _ordType = "C";
        _investType = InvestType.delivery;
      } else if (data.prd == "I") {
        _ordType = "I";
        _investType = InvestType.intraday;
      } else {
        _ordType = "M";
        _investType = InvestType.carryForward;
      }
    } else if (data.sPrdtAli == "CO") {
      _orderName = "Cover";
    } else {
      _orderName = "Bracket";
    }

    if (data.prctyp == "LMT") {
      _priceName = "Limit";
    } else if (data.prctyp == "MKT") {
      _priceName = "Market";
    } else if (data.prctyp == "SL-LMT") {
      _priceName = "SL Limit";
    } else {
      _priceName = "SL MKT";
    }

    if (_priceName == "Market" || _priceName == "SL MKT") {
      prcCtrl.text = "Market";

      double ltp = (double.parse("${data.ltp}") *
              double.parse(mktProtCtrl.text.isEmpty ? "0" : mktProtCtrl.text)) /
          100;

      if (data.trantype == "B") {
        priceVal =
            (double.parse("${data.ltp ?? 0.00}") + ltp).toStringAsFixed(2);
      } else {
        priceVal =
            (double.parse("${data.ltp ?? 0.00}") - ltp).toStringAsFixed(2);
      }
      double result = double.parse(priceVal) + (double.parse("${data.ti}") / 2);
      result -= result % double.parse("${data.ti}");

      if (result >=
          double.parse(
              "${ref.read(marketWatchProvider).scripInfoModel!.uc ?? 0.00}")) {
        priceVal = "${ref.read(marketWatchProvider).scripInfoModel!.uc}";
      } else if (result <=
          double.parse(
              "${ref.read(marketWatchProvider).scripInfoModel!.lc ?? 0.00}")) {
        priceVal = "${ref.read(marketWatchProvider).scripInfoModel!.lc}";
      } else {
        priceVal = result.toStringAsFixed(2);
      }
    } else {
      prcCtrl.text = "${data.prc}";

      priceVal = prcCtrl.text;
    }
    chngPriceType(_priceName, "${data.exch}");

    notifyListeners();
  }

// Change price type Based on condition
  chngPriceType(String val, String exch) {
    if (val == "Limit") {
      _prcType = "LMT";
    } else if (val == "Market") {
      _prcType = "MKT";
      // _prcType = (exch == "MCX" || exch == "BSE") ? "MKT" : "LMT";
    } else if (val == "SL Limit") {
      _prcType = "SL-LMT";
    } else {
      _prcType = "SL-MKT";
      // _prcType = (exch == "MCX" || exch == "BSE") ? "SL-MKT" : "SL-LMT";
    }
    log(_prcType);
    notifyListeners();
  }

  // GTT ORDER INPUT

  String _ait = "LTP_B_O";
  String get ait => _ait;

  TextEditingController _priceCtrl = TextEditingController();
  TextEditingController get priceCtrl => _priceCtrl;

  TextEditingController _ocoPriceCtrl = TextEditingController();
  TextEditingController get ocoPriceCtrl => _ocoPriceCtrl;

  TextEditingController _qtyCtrl = TextEditingController();
  TextEditingController get qtyCtrl => _qtyCtrl;

  TextEditingController _ocoQtyCtrl = TextEditingController();
  TextEditingController get ocoQtyCtrl => _ocoQtyCtrl;

// OCO
  final TextEditingController _val1Ctrl = TextEditingController();
  TextEditingController get val1Ctrl => _val1Ctrl;

  final TextEditingController _val2Ctrl = TextEditingController();
  TextEditingController get val2Ctrl => _val2Ctrl;

  final TextEditingController _trgPrcCtrl = TextEditingController();
  TextEditingController get trgPrcCtrl => _trgPrcCtrl;

  final TextEditingController _ocoTrgPrcCtrl = TextEditingController();
  TextEditingController get ocoTrgPrcCtrl => _ocoTrgPrcCtrl;

  final TextEditingController _reMarksCtrl = TextEditingController();
  TextEditingController get reMarksCtrl => _reMarksCtrl;

  final List<String> _prcTypes = ["Limit", "Market", "SL Limit", "SL MKT"];
  List<String> get prcTypes => _prcTypes;
  String _actPrcType = "Limit";
  String get actPrcType => _actPrcType;

  String _actOcoPrcType = "Limit";
  String get actOcoPrcType => _actOcoPrcType;

  String _ocoPrcType = "LMT";
  String get ocoPrcType => _ocoPrcType;

  InvestType _ocoInvestType = InvestType.intraday;
  InvestType get ocoInvestType => _ocoInvestType;

  bool _disableGTTCond = false;

  bool get disableGTTCond => _disableGTTCond;

  final List<String> _alertTypes = [
    "LTP",
    "Perc. Change",
    "ATP",
    "OI",
    "TOI",
    "Volume"
  ];
  List<String> get alertTypes => _alertTypes;
  String _actAlert = "LTP";
  String get actAlert => _actAlert;

  final List<String> _condTypes = ["Less", "Greater"];
  List<String> get condTypes => _condTypes;
  String _actCond = "Less";
  String get actCond => _actCond;

  updatePrcCtrl(String prc, qty) {
    _priceCtrl = TextEditingController(text: prc);
    _qtyCtrl = TextEditingController(text: qty);
    notifyListeners();
  }

  updateOcoPrcQtyCtrl(String prc, String qty) {
    _ocoPriceCtrl = TextEditingController(text: prc);

    _ocoQtyCtrl = TextEditingController(text: qty);
    notifyListeners();
  }

  chngAlert(String val) {
    _actAlert = val;
    if (_actAlert == "LTP" && _actCond == "Less") {
      _ait = "LTP_B_O";
    }
    if (_actAlert == "LTP" && _actCond == "Greater") {
      _ait = "LTP_A_O";
    }
    if (_actAlert == "Perc. Change" && _actCond == "Less") {
      _ait = "CH_PER_B_O";
    }
    if (_actAlert == "Perc. Change" && _actCond == "Greater") {
      _ait = "CH_PER_A_O";
    }
    if (_actAlert == "ATP" && _actCond == "Less") {
      _ait = "ATP_B_O";
    }
    if (_actAlert == "ATP" && _actCond == "Greater") {
      _ait = "ATP_A_O";
    }
    if (_actAlert == "OI" && _actCond == "Less") {
      _ait = "OI_B_O";
    }
    if (_actAlert == "OI" && _actCond == "Greater") {
      _ait = "OI_A_O";
    }
    if (_actAlert == "TOI" && _actCond == "Less") {
      _ait = "TOI_B_O";
    }
    if (_actAlert == "TOI" && _actCond == "Greater") {
      _ait = "TOI_A_O";
    }
    if (_actAlert == "Volume" && _actCond == "Less") {
      _ait = "VOLUME_B_O";
    }
    if (_actAlert == "Volume" && _actCond == "Greater") {
      _ait = "VOLUME_A_O";
    }

    notifyListeners();
  }

  chngCond(String val) {
    _actCond = val;
    notifyListeners();
  }

  chngGTTPriceType(String val) {
    _actPrcType = val;
    if (val == "Limit") {
      _prcType = "LMT";
    } else if (val == "Market") {
      _prcType = "MKT";
    } else if (val == "SL Limit") {
      _prcType = "SL-LMT";
    } else {
      _prcType = "SL-MKT";
    }
    log(_prcType);
    notifyListeners();
  }

  chngOCOPriceType(String val) {
    _actOcoPrcType = val;
    if (val == "Limit") {
      _ocoPrcType = "LMT";
    } else if (val == "Market") {
      _ocoPrcType = "MKT";
    } else if (val == "SL Limit") {
      _ocoPrcType = "SL-LMT";
    } else {
      _ocoPrcType = "SL-MKT";
    }

    notifyListeners();
  }

// Clear all text field value on Gtt order
  clearTextField() {
    _reMarksCtrl.clear();
    _ocoTrgPrcCtrl.clear();
    _trgPrcCtrl.clear();
    _val2Ctrl.clear();
    _val1Ctrl.clear();
    _ocoQtyCtrl.clear();
    _qtyCtrl.clear();
    _ocoPriceCtrl.clear();
    _priceCtrl.clear();
    notifyListeners();
  }

  disableCondGTT(bool val) {
    _disableGTTCond = val;
    notifyListeners();
  }
// This method for retrieving information from the GTT order book to Modify the order

  getModifyData(GttOrderBookModel gttOrderBook) {
    _reMarksCtrl.text = "${gttOrderBook.remarks}";
    if (gttOrderBook.placeOrderParams != null) {
      if (gttOrderBook.placeOrderParams!.prctyp == "LMT") {
        _actPrcType = "Limit";
      } else if (gttOrderBook.placeOrderParams!.prctyp == "MKT") {
        _actPrcType = "Market";
      } else if (gttOrderBook.placeOrderParams!.prctyp == "SL-LMT") {
        _actPrcType = "SL Limit";
      } else {
        _actPrcType = "SL MKT";
      }
      if (gttOrderBook.placeOrderParams!.prd == "C") {
        _ordType = "C";
        _investType = InvestType.delivery;
      } else if (gttOrderBook.placeOrderParams!.prd == "I") {
        _ordType = "I";
        _investType = InvestType.intraday;
      } else {
        _ordType = "M";
        _investType = InvestType.carryForward;
      }
      _priceCtrl.text = "${gttOrderBook.placeOrderParams!.prc}";
      _qtyCtrl.text = "${gttOrderBook.placeOrderParams!.qty}";
      _trgPrcCtrl.text = "${gttOrderBook.placeOrderParams!.trgprc}";
    }
    if (gttOrderBook.placeOrderParamsLeg2 != null) {
      disableCondGTT(true);
      if (gttOrderBook.placeOrderParamsLeg2!.prctyp == "LMT") {
        _actOcoPrcType = "Limit";
      } else if (gttOrderBook.placeOrderParamsLeg2!.prctyp == "MKT") {
        _actOcoPrcType = "Market";
      } else if (gttOrderBook.placeOrderParamsLeg2!.prctyp == "SL-LMT") {
        _actOcoPrcType = "SL Limit";
      } else {
        _actOcoPrcType = "SL MKT";
      }

      if (gttOrderBook.placeOrderParamsLeg2!.prd == "C") {
        _ocoOrdType = "C";
        _ocoInvestType = InvestType.delivery;
      } else if (gttOrderBook.placeOrderParamsLeg2!.prd == "I") {
        _ocoOrdType = "I";
        _ocoInvestType = InvestType.intraday;
      } else {
        _ocoOrdType = "M";
        _ocoInvestType = InvestType.carryForward;
      }

      _ocoPriceCtrl.text = "${gttOrderBook.placeOrderParamsLeg2!.prc}";
      _ocoQtyCtrl.text = "${gttOrderBook.placeOrderParamsLeg2!.qty}";
      _ocoTrgPrcCtrl.text = "${gttOrderBook.placeOrderParamsLeg2!.trgprc}";
    } else {
      disableCondGTT(false);
    }

    if (gttOrderBook.oivariable!.isNotEmpty) {
      _val1Ctrl.text = "${gttOrderBook.oivariable![0].d}";
      if (gttOrderBook.placeOrderParamsLeg2 != null) {
        _val2Ctrl.text = "${gttOrderBook.oivariable![1].d}";
      }
    }

    _ait = gttOrderBook.aiT!;
    if (_ait == "LTP_B_O") {
      _actAlert == "LTP";
      _actCond == "Less";
    }
    if (_ait == "LTP_A_O") {
      _actAlert == "LTP";
      _actCond == "Greater";
    }
    if (_ait == "CH_PER_B_O") {
      _actAlert == "Perc. Change";
      _actCond == "Less";
    }
    if (_ait == "CH_PER_A_O") {
      _actAlert == "Perc. Change";
      _actCond == "Greater";
    }
    if (_ait == "ATP_B_O") {
      _actAlert == "ATP";
      _actCond == "Less";
    }
    if (_ait == "ATP_A_O") {
      _actAlert == "ATP";
      _actCond == "Greater";
    }
    if (_ait == "OI_B_O") {
      _actAlert == "OI";
      _actCond == "Less";
    }
    if (_ait == "OI_A_O") {
      _actAlert == "OI";
      _actCond == "Greater";
    }
    if (_ait == "TOI_B_O") {
      _actAlert == "TOI";
      _actCond == "Less";
    }
    if (_ait == "TOI_A_O") {
      _actAlert == "TOI";
      _actCond == "Greater";
    }
    if (_ait == "VOLUME_B_O") {
      _actAlert == "Volume";
      _actCond == "Less";
    }
    if (_ait == "VOLUME_A_O") {
      _actAlert == "Volume";
      _actCond == "Greater";
    }
    notifyListeners();
  }
}

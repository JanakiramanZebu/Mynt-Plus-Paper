import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/index_list_provider.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/indices/index_list_model.dart';
import '../models/json_model/strategy_model.dart';
import '../models/marketwatch_model/market_watch_scrip_model.dart';
import '../models/marketwatch_model/opt_chain_model.dart';
import '../models/order_book_model/order_book_model.dart';
import '../models/order_book_model/place_order_model.dart';
import '../res/res.dart';
import 'core/default_change_notifier.dart';
import 'market_watch_provider.dart';
import 'order_provider.dart';

final optStrategyProvider =
    ChangeNotifierProvider((ref) => OptionStrategyProvider(ref.read));

class OptionStrategyProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;

  OptionStrategyProvider(this.ref);
  StrategyJosnModel? _strategyData;
  StrategyJosnModel? get strategyData => _strategyData;
  final List<IndexValue> _optionIndex = [
    IndexValue(idxname: "NIFTY", token: "26000", exch: "NSE", tsym: "Nifty 50"),
    IndexValue(
        idxname: "BANK NIFTY", token: "26009", exch: "NSE", tsym: "Nifty Bank"),
    IndexValue(
        idxname: "FIN NIFTY",
        token: "26037",
        exch: "NSE",
        tsym: "Nifty Fin Service"),
    IndexValue(
        idxname: "MIDCP NIFTY",
        token: "26074",
        exch: "NSE",
        tsym: "NIFTY MID SELECT"),
    IndexValue(idxname: "SENSEX", token: "1", exch: "BSE", tsym: "SENSEX"),
    IndexValue(
        idxname: "CRUDE OIL", token: "294", exch: "MCX", tsym: "CRUDEOIL"),
    IndexValue(
        idxname: "NATURAL GAS", token: "401", exch: "MCX", tsym: "NATURALGAS"),
    IndexValue(idxname: "GOLD", token: "114", exch: "MCX", tsym: "GOLD")
  ];
  List<IndexValue> get optionIndex => _optionIndex;

  String _selectedOptName = "NIFTY";
  String get selectedOptName => _selectedOptName;

  String _selectedTK = "26000";
  String get selectedTK => _selectedTK;

  String _selectBtn = "Option";
  String get selectBtn => _selectBtn;
  List optBtns = [
    {"btnName": "Option", "imgPath": assets.optChainIcon},
    {"btnName": "Chart", "imgPath": assets.charticon}
  ];

  String _strgName = "Bullish";
  String get stratagyName => _strgName;

  String _strgOptName = "Long call";
  String get strgOptName => _strgOptName;
  ChartArgs? _chartArgs;
  ChartArgs? get chartArgs => _chartArgs;

  List<OptionValues> _optStrgyStrike = [];
  List<OptionValues> get optStrgyStrike => _optStrgyStrike;

  chngBtn(String val) {
    _selectBtn = val;
    notifyListeners();
  }

  chngeOptionName(String val, BuildContext context) async {
    _selectedOptName = val;
    _selectBtn = "Option";
    for (var element in _optionIndex) {
      if (val == element.idxname) {
        _selectedTK = element.token!;
        _chartArgs = ChartArgs(
            exch: element.exch!,
            tsym: '${element.tsym}',
            token: '${element.token}');

        await ref(marketWatchProvider)
            .fetchScripQuote("${element.token}", "${element.exch}", context);
        await ref(marketWatchProvider)
            .fetchLinkeScrip("${element.token}", "${element.exch}", context);

        await ref(marketWatchProvider).fetchOPtionChain(
            context: context,
            exchange: ref(marketWatchProvider).optionExch!,
            numofStrike: '10',
            strPrc: ref(marketWatchProvider).optionStrPrc,
            tradeSym: ref(marketWatchProvider).selectedTradeSym!.toUpperCase());
      }
    }
    notifyListeners();
  }

  List<double> getCustomItemsHeight() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (_optionIndex.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  List<DropdownMenuItem<String>> addDividers() {
    List<DropdownMenuItem<String>> menuItems = [];

    for (var item in _optionIndex) {
      menuItems.addAll([
        DropdownMenuItem<String>(
            value: item.idxname,
            child: Text(
              item.idxname.toString(),
            )),
        //If it's last item, we will not add Divider after it.
        if (item != _optionIndex.last)
          DropdownMenuItem<String>(
              enabled: false,
              child: Divider(
                  color: ref(themeProvider).isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider))
      ]);
    }
    return menuItems;
  }

  Future fetchStrategyJson() async {
    try {
      _strategyData = await api.getStrategyJson();
      notifyListeners();
    } catch (e) {
      log("$e");
    }
  }

  strgStikeSelection(String strgName, String optionName) {
    _strgOptName = optionName;
    _strgName = strgName;
    _optStrgyStrike = [];

    if (strgName == "Bullish") {
      for (var element in _strategyData!.bullish!) {
        if (optionName == element.name) {
          for (var item in element.data!) {
            if (item.typeof == "ITM") {
              if (item.type == "CE") {
                ref(marketWatchProvider)
                    .optChainCallUP[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";
                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainCallUP[item.letselection!]);
              } else {
                ref(marketWatchProvider)
                    .optChainPutUp[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(
                    ref(marketWatchProvider).optChainPutUp[item.letselection!]);
              }
            } else {
              if (item.type == "CE") {
                ref(marketWatchProvider)
                    .optChainCallDown[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainCallDown[item.letselection!]);
              } else {
                ref(marketWatchProvider)
                    .optChainPutDown[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainPutDown[item.letselection!]);
              }
            }
          }
        }
      }
    } else if (strgName == "Bearish") {
      for (var element in _strategyData!.bearish!) {
        if (optionName == element.name) {
          for (var item in element.data!) {
            if (item.typeof == "ITM") {
              if (item.type == "CE") {
                ref(marketWatchProvider)
                    .optChainCallUP[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";
                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainCallUP[item.letselection!]);
              } else {
                ref(marketWatchProvider)
                    .optChainPutUp[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(
                    ref(marketWatchProvider).optChainPutUp[item.letselection!]);
              }
            } else {
              if (item.type == "CE") {
                ref(marketWatchProvider)
                    .optChainCallDown[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainCallDown[item.letselection!]);
              } else {
                ref(marketWatchProvider)
                    .optChainPutDown[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainPutDown[item.letselection!]);
              }
            }
          }
        }
      }
    } else {
      for (var element in _strategyData!.neutral!) {
        if (optionName == element.name) {
          for (var item in element.data!) {
            if (item.typeof == "ITM") {
              if (item.type == "CE") {
                ref(marketWatchProvider)
                    .optChainCallUP[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";
                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainCallUP[item.letselection!]);
              } else {
                ref(marketWatchProvider)
                    .optChainPutUp[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(
                    ref(marketWatchProvider).optChainPutUp[item.letselection!]);
              }
            } else {
              if (item.type == "CE") {
                ref(marketWatchProvider)
                    .optChainCallDown[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainCallDown[item.letselection!]);
              } else {
                ref(marketWatchProvider)
                    .optChainPutDown[item.letselection!]
                    .transType = item.action == "BUY" ? "B" : "S";

                _optStrgyStrike.add(ref(marketWatchProvider)
                    .optChainPutDown[item.letselection!]);
              }
            }
          }
        }
      }
    }
    notifyListeners();
    print("Stategy ${_optStrgyStrike.length}");
  }

  optionStrategyOrderPlace(BuildContext context) async {
    if (_optStrgyStrike.isNotEmpty) {
      for (var element in _optStrgyStrike) {
        PlaceOrderInput placeOrderInput = PlaceOrderInput(
            amo: "",
            blprc: '',
            bpprc: '',
            dscqty: "0",
            exch: element.exch!,
            prc: element.lp!,
            prctype: "MKT",
            prd: "M",
            qty: element.ls!,
            ret: "DAY",
            trailprc: '',
            trantype: element.transType!,
            trgprc: "",
            tsym: element.tsym!,
            mktProt: '',
            channel: '');
        await ref(orderProvider).slicePlaceOrder(context, placeOrderInput);
      }

      List<OrderBookModel> _orderBookModel =
          await ref(orderProvider).fetchOrderBook(context, true);
      if (_orderBookModel.isNotEmpty) {
        if (_orderBookModel[0].stat != "Not_Ok") {
          ref(indexListProvider).bottomMenu(3, context);
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.click);

          Navigator.pop(context);
        }
      }
    }
  }
}

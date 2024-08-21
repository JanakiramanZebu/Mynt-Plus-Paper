import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/profile_model/fund_detial_model.dart';
import '../models/profile_model/hs_token_model.dart';
import '../models/profile_model/option_z_model.dart';
import '../routes/route_names.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final fundProvider = ChangeNotifierProvider((ref) => FundProvider(ref.read));

class FundProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  FundDetailModel? _fundDetailModel;
  FundDetailModel? get fundDetailModel => _fundDetailModel;
  final FToast _fToast = FToast();
  FToast get fToast => _fToast;
  GetHsTokenModel? _getHsTokenModel;
  final List _margin = [];
  final List _utlization = [];
  List get margin => _margin;
  List get utlization => _utlization;
  final Reader ref;

  List _listOfCredits = [];
  List get listOfCredits => _listOfCredits;
  List _listOfUsedMrgn = [];
  List get listOfUsedMrgn => _listOfUsedMrgn;

  OptionZmodel? _optionZmodel;
  OptionZmodel? get optionZmodel => _optionZmodel;

  FundProvider(this.ref);

  GetHsTokenModel? get fundHstoken => _getHsTokenModel;

  bool _showMrgnnBreakup = false;
  bool get showMrgnBreakup => _showMrgnnBreakup;

  eDis(BuildContext context) {
    var enCodePass = utf8.encode(
        'sLoginId=${fundHstoken!.uid}&sAccountId=${fundHstoken!.actid}&prd=C&token=${fundHstoken!.hstk}&sBrokerId=ZEBU&open=edis');
    var base64Pass = base64Url.encode(enCodePass);

    Navigator.pushNamed(context, Routes.edis, arguments: base64Pass);
    'sLoginId=${fundHstoken!.uid}&token=${fundHstoken!.hstk}';

    // launch("https://go.mynt.in/NorenEdis/NonPoaHoldings/?$base64Pass");
  }

  optionZ(BuildContext context) async {
    var enCodePass = utf8.encode(
        'sLoginId=${pref.clientId}&sAccountId=${pref.clientId}&token=${fundHstoken!.hstk}&sBrokerId=ZEBU');
    var base64Pass = base64Url.encode(enCodePass);
    await fetchOptionZ(base64Pass, context);
  }

  Future fetchOptionZ(String key, BuildContext context) async {
    try {
      _optionZmodel = await api.getaOptionZ(key);
      if (_optionZmodel!.stat == "Ok") {
        Navigator.pushNamed(context, Routes.optionZWebView,
            arguments: optionZmodel!.url);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, "${_optionZmodel!.emsg}"));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future fetchHstoken(BuildContext context) async {
    try {
      toggleLoadingOn(true);

      final GetHsTokenModel data = await api.getHsToken();
      _getHsTokenModel = data;
      ConstantName.sessCheck = true;
      if (_getHsTokenModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _getHsTokenModel!.stat == "Not_Ok") {
        ref(authProvider).ifSessionExpired(context);
      }
    } catch (e) {
      log("Failed to fetch Profile Data:: ${e.toString()}");
      ref(indexListProvider)
          .logError
          .add({"type": "API HS Token", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future fetchFunds(BuildContext context) async {
    try {
      _listOfCredits = [];
      _listOfUsedMrgn = [];
      _fundDetailModel = await api.getFunds();

      if (_fundDetailModel!.emsg == "Session Expired :  Invalid Session Key") {
        ref(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
        double cash = double.parse(_fundDetailModel!.cash ?? "0.00");
        double payin = double.parse(_fundDetailModel!.payin ?? "0.00");
        double payout = double.parse(_fundDetailModel!.payout ?? "0.00");
        double brkcollamt =
            double.parse(_fundDetailModel!.brkcollamt ?? "0.00");
        double unclearedcash =
            double.parse(_fundDetailModel!.unclearedcash ?? "0.00");
        double auxDaycash =
            double.parse(_fundDetailModel!.auxDaycash ?? "0.00");
        double auxBrkcollamt =
            double.parse(_fundDetailModel!.auxBrkcollamt ?? "0.00");
        double auxUnclearedcash =
            double.parse(_fundDetailModel!.auxUnclearedcash ?? "0.00");
        double daycash = double.parse(_fundDetailModel!.daycash ?? "0.00");

        if (cash != 0.00) {
          _listOfCredits.add({"value": "$cash", "name": "Opening Balance"});
        }
        if (payin != 0.00) {
          _listOfCredits.add({"value": "$payin", "name": "Payin"});
        }
        if (payout != 0.00) {
          _listOfCredits.add({"value": "$payout", "name": "Payout"});
        }
        if (brkcollamt != 0.00) {
          _listOfCredits
              .add({"value": "$brkcollamt", "name": "Broker Collateral"});
        }
        if (unclearedcash != 0.00) {
          _listOfCredits
              .add({"value": "$unclearedcash", "name": "Uncleared Cash"});
        }
        if (auxDaycash != 0.00) {
          _listOfCredits.add({"value": "$auxDaycash", "name": "Aux Day Cash"});
        }
        if (auxBrkcollamt != 0.00) {
          _listOfCredits.add(
              {"value": "$auxBrkcollamt", "name": "Aux Broker collateral"});
        }
        if (auxUnclearedcash != 0.00) {
          _listOfCredits.add(
              {"value": "$auxUnclearedcash", "name": "Aux Uncleared Cash"});
        }
        if (daycash != 0.00) {
          _listOfCredits.add({"value": "$daycash", "name": "Day Cash"});
        }

        fundDetailModel!.totCredit = (cash +
                payin +
                payout +
                brkcollamt +
                unclearedcash +
                auxDaycash +
                auxBrkcollamt +
                auxUnclearedcash +
                daycash)
            .toStringAsFixed(2);

        double utilizedMrgn = 0.00;
        double span = double.parse(_fundDetailModel!.span ?? "0.00");
        double expo = double.parse(_fundDetailModel!.expo ?? "0.00");
        double addmrg = double.parse(_fundDetailModel!.addmrg ?? "0.00");
        double urmtom = double.parse(_fundDetailModel!.urmtom ?? "0.00");
        double premium = double.parse(_fundDetailModel!.premium ?? "0.00");
        double brokerage = double.parse(_fundDetailModel!.brokerage ?? "0.00");

        if (span != 0.00) {
          _listOfUsedMrgn.add({"value": "$span", "name": "Span"});
        }
        if (expo != 0.00) {
          _listOfUsedMrgn.add({"value": "$expo", "name": "Exposure"});
        }
        if (addmrg != 0.00) {
          _listOfUsedMrgn
              .add({"value": "$addmrg", "name": "Additional Margin"});
        }
        if (premium != 0.00) {
          _listOfUsedMrgn.add({"value": "$premium", "name": "Option Premium"});
        }
        if (brokerage != 0.00) {
          _listOfUsedMrgn
              .add({"value": "$brokerage", "name": "Unrealized Expenses"});
        }

        utilizedMrgn = span + expo + addmrg;
        if (!urmtom.isNegative && urmtom != 0.00) {
          utilizedMrgn += urmtom;

          _listOfUsedMrgn.add({"value": "$urmtom", "name": "Unrealized MTM"});
        }

        utilizedMrgn = double.parse(fundDetailModel!.marginused ?? "0.00");
        fundDetailModel!.utilizedMrgn = utilizedMrgn.toStringAsFixed(2);

        fundDetailModel!.avlMrg =
            (double.parse(fundDetailModel!.totCredit ?? "0.00") - utilizedMrgn)
                .toStringAsFixed(2);
        double avlMrgnPer = ((double.parse(fundDetailModel!.avlMrg ?? "0.00") /
                double.parse(fundDetailModel!.totCredit ?? "0.00")) *
            100);

        fundDetailModel!.avlMrgPercentage =
            (avlMrgnPer.isNaN ? 0.00 : avlMrgnPer).toStringAsFixed(2);
      }
      notifyListeners();

      return _fundDetailModel;
    } catch (e) {
      print(e);
      ref(indexListProvider).logError.add({"type": "API Funds", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

  showMrgBreak() {
    _showMrgnnBreakup = !_showMrgnnBreakup;
    notifyListeners();
  }
}

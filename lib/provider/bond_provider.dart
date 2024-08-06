import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/core/api_export.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/bonds_data/bond_lists.dart';
import '../models/bonds_data/govt_bonds.dart';
import '../models/bonds_data/ledger_bal_model.dart';
import '../models/bonds_data/sovereign_gold_bonds.dart';
import '../models/bonds_data/state_bond.dart';
import '../models/bonds_data/treasury_bonds.dart';
import '../res/res.dart';
import 'core/default_change_notifier.dart';

final bondProvider = ChangeNotifierProvider((ref) => BondProvider(ref.read));

class BondProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Reader ref;
  BondProvider(this.ref);

  List<Map> bondTypes = [
    {"type": "Government Bonds", "image": assets.govtBond},
    {"type": "Sovereign Gold Bonds", "image": assets.sgbBond},
    {"type": "Tax Free Bonds", "image": assets.taxBond}
  ];

  List topBonds = [
    "Govt. Bonds",
    "Treasury Bonds",
    "State Bonds",
    "Sovereign Gold Bonds",
  ];

  String _topBond = "Govt. Bonds";
  String get topBond => _topBond;

  GovtBond? _govtBond;
  TreasuryBond? _treasuryBond;
  StateBonds? _stateBond;
  SovereignGoldBonds? _sovereignGoldBonds;

  LedgerBalModel? _ledgerBalModel;
  LedgerBalModel? get ledgerBalModel=> _ledgerBalModel;

  List<BondLists>? _bondLists = [];

  List<BondLists>? get bondLists => _bondLists;

  TextEditingController _unitValueCtrl = TextEditingController();
  TextEditingController get unitValueCtrl => _unitValueCtrl;

  int _minUnit = 0;
  int _maxUnit = 0;

  int get minUnit => _minUnit;
  int get maxUnit => _maxUnit;

  changeUnits(BondLists bondData) {
    _minUnit = (int.parse(bondData.lotSize ?? "0") /
            double.parse(bondData.faceValue ?? "0"))
        .ceil();
    _maxUnit = (int.parse(bondData.maxQuantity ?? "0") /
            double.parse(bondData.faceValue ?? "0"))
        .ceil();

    _unitValueCtrl.text = "$_minUnit";
    print(" qty $_maxUnit $_minUnit");
    notifyListeners();
  }

  changeBondType(String val) {
    _topBond = val;
    if (val == "Govt. Bonds") {
      _bondLists = _govtBond!.nCBGsec ?? [];
    } else if (val == "Treasury Bonds") {
      _bondLists = _treasuryBond!.nCBTBill ?? [];
    } else if (val == "State Bonds") {
      _bondLists = _stateBond!.nCBSDL ?? [];
    } else {
      _bondLists = _sovereignGoldBonds!.sGB ?? [];
    }

    print("Bonds Length ${_bondLists!.length}");
    notifyListeners();
  }

  Future fetchGovtBonds() async {
    try {
      _topBond = "Govt. Bonds";
      _bondLists = [];
      _govtBond = await api.getGovtBond();
      _bondLists = _govtBond!.nCBGsec ?? [];
      await fetchTreassuryBonds();
      await fetchStateBonds();
      await fetchGoldBonds();
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchTreassuryBonds() async {
    try {
      _treasuryBond = await api.getTreasuryBond();

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchStateBonds() async {
    try {
      _stateBond = await api.getStateBond();

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future fetchGoldBonds() async {
    try {
      _sovereignGoldBonds = await api.getGoldBond();

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }
Future fetchLedgerBal() async {
    try {
    _ledgerBalModel = await api.getLedgerBal();

      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  
}

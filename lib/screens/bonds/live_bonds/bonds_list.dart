// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/govt_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/sovereign_gold_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/state_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/treasury_bonds.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/stocks_provider.dart';

class BondsListScreen extends StatelessWidget {
  const BondsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      final devHeight = MediaQuery.of(context).size.height;

      return SingleChildScrollView(
        child: Column(
          children: [
            _buildContent(bonds, devHeight, ref),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BondsProvider bonds, double devHeight, WidgetRef ref) {
    // Check if there's a search query
    if (ref.watch(stocksProvide).searchController.text.isNotEmpty) {
      return _buildSearchResults(bonds, devHeight);
    }

    // Safe null checks for all bond types
    final bool isEmpty = _isBondsDataEmpty(bonds);

    if (isEmpty) {
      return _buildEmptyState(devHeight);
    }

    return const Column(
      children: [
        GovtBondsScreen(),
        TreasuryBondsScreen(),
        StateBondsScreen(),
        SovereignGoldBondsScreen(),
        // SizedBox(height: 24),
        // SizedBox(height: 80),
      ],
    );
  }

  bool _isBondsDataEmpty(BondsProvider bonds) {
    // Safe null checks for all bond types
    final govtBondsEmpty = bonds.govtBonds?.ncbGSec?.isEmpty ?? true;
    final treasuryBondsEmpty = bonds.treasuryBonds?.ncbTBill?.isEmpty ?? true;
    final stateBondsEmpty = bonds.stateBonds?.ncbSDL?.isEmpty ?? true;
    final sovereignBondsEmpty = bonds.sovereignGoldBonds?.ncbSGB?.isEmpty ?? true;

    return govtBondsEmpty && 
           treasuryBondsEmpty && 
           stateBondsEmpty && 
           sovereignBondsEmpty;
  }

  Widget _buildSearchResults(BondsProvider bonds, double devHeight) {
    if (bonds.bondsCommonSearchList.isEmpty) {
      return _buildNoSearchResults(devHeight);
    }

    // Safe null checks for filtering bonds by type
    final hasGovtBonds = bonds.bondsCommonSearchList
        .any((bond) => bonds.govtBonds?.ncbGSec?.contains(bond) == true);
    final hasTreasuryBonds = bonds.bondsCommonSearchList
        .any((bond) => bonds.treasuryBonds?.ncbTBill?.contains(bond) == true);
    final hasStateBonds = bonds.bondsCommonSearchList
        .any((bond) => bonds.stateBonds?.ncbSDL?.contains(bond) == true);
    final hasSovereignBonds = bonds.bondsCommonSearchList.any(
        (bond) => bonds.sovereignGoldBonds?.ncbSGB?.contains(bond) == true);

    return Column(
      children: [
        if (hasGovtBonds) const GovtBondsScreen(),
        if (hasTreasuryBonds) const TreasuryBondsScreen(),
        if (hasStateBonds) const StateBondsScreen(),
        if (hasSovereignBonds) const SovereignGoldBondsScreen(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNoSearchResults(double devHeight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 225),
        child: SizedBox(
          height: devHeight - 140,
          child: const Column(
            children: [
              NoDataFound(
                title: "No Results Found",
                subtitle: "Try searching with different keywords",
                primaryEnabled: false,
                secondaryEnabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double devHeight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 225),
        child: SizedBox(
          height: devHeight - 140,
          child: const Column(
            children: [
              NoDataFound(
                title: "No Bonds Found",
                subtitle: "",
                primaryEnabled: false,
                secondaryEnabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

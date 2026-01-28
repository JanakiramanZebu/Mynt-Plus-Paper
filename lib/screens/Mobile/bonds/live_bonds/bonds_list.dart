// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/screens/Mobile/bonds/live_bonds/govt_bonds.dart';
import 'package:mynt_plus/screens/Mobile/bonds/live_bonds/sovereign_gold_bonds.dart';
import 'package:mynt_plus/screens/Mobile/bonds/live_bonds/state_bonds.dart';
import 'package:mynt_plus/screens/Mobile/bonds/live_bonds/treasury_bonds.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import 'package:mynt_plus/screens/Mobile/bonds/live_bonds/bonds_table_web.dart';
import 'package:mynt_plus/screens/web/bonds/bond_order_popup_web.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';

import '../../../../provider/stocks_provider.dart';

class BondsListScreen extends StatelessWidget {
  const BondsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      final devHeight = MediaQuery.of(context).size.height;

      final bool isEmpty = _isBondsDataEmpty(bonds);

      if (isEmpty) {
        return _buildEmptyState();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          // Web View: Show Table (No SingleChildScrollView wrapper)
          if (constraints.maxWidth > 600) {
            final List<dynamic> allBonds = [];
            if (bonds.govtBonds?.ncbGSec != null) allBonds.addAll(bonds.govtBonds!.ncbGSec!);
            if (bonds.treasuryBonds?.ncbTBill != null) allBonds.addAll(bonds.treasuryBonds!.ncbTBill!);
            if (bonds.stateBonds?.ncbSDL != null) allBonds.addAll(bonds.stateBonds!.ncbSDL!);
            if (bonds.sovereignGoldBonds?.ncbSGB != null) allBonds.addAll(bonds.sovereignGoldBonds!.ncbSGB!);

            return BondsTableWeb(
              bondsData: allBonds,
              searchQuery: bonds.bondscommonsearchcontroller.text,
              bondType: 'All',
              onApplyTap: (bond) {
                // Convert to BondsList if needed and show order popup
                if (bond is BondsList) {
                  showBondOrderPopup(context, bond);
                } else {
                  // Try to convert from dynamic
                  try {
                    final bondsList = BondsList.fromJson(bond.toJson());
                    showBondOrderPopup(context, bondsList);
                  } catch (e) {
                    // Handle error silently
                  }
                }
              },
            );
          } 
          
          // Mobile View: Existing List with ScrollView wrapper
          else {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                   _buildContentMobile(bonds, devHeight, ref),
                ],
              ),
            );
          }
        },
      );
    });
  }

  Widget _buildContentMobile(BondsProvider bonds, double devHeight, WidgetRef ref) {
    if (ref.watch(stocksProvide).searchController.text.isNotEmpty) {
      return _buildSearchResults(bonds, devHeight);
    }

    return const Column(
      children: [
        GovtBondsScreen(),
        TreasuryBondsScreen(),
        StateBondsScreen(),
        SovereignGoldBondsScreen(),
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

  Widget _buildEmptyState() {
    return const Center(
      child: NoDataFound(
        title: "No Bonds Found",
        subtitle: "There are no bond listings for today.",
        primaryEnabled: false,
        secondaryEnabled: false,
      ),
    );
  }
}

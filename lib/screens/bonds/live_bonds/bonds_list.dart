// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/bonds/bonds_order_screen/orderscreenbottompage.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/govt_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/sovereign_gold_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/state_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/treasury_bonds.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class BondsListScreen extends StatelessWidget {
  const BondsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final bonds = watch(bondsProvider);
      // final mainstreamipo = watch(ipoProvide);
      // List<BondsList>? bondsList = bonds.bondsList;
      // final upi = watch(transcationProvider);
      final theme = watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;
      return SingleChildScrollView(
        child: Column(
          children: [
            bonds.govtBonds!.ncbGSec!.isEmpty &&
                    bonds.treasuryBonds!.ncbTBill!.isEmpty &&
                    bonds.stateBonds!.ncbSDL!.isEmpty &&
                    bonds.sovereignGoldBonds!.ncbSGB!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 225),
                      child: Container(
                        height: dev_height - 140,
                        child: const Column(
                          children: [
                            NoDataFound(),
                          ],
                        ),
                      ),
                    ),
                  )
                : const GovtBondsScreen(),
            const TreasuryBondsScreen(),
            const StateBondsScreen(),
            const SovereignGoldBondsScreen(),
            const SizedBox(
              height: 24,
            )
          ],
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

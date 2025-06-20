// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/bonds/bonds_order_screen/orderscreenbottompage.dart';

class SovereignGoldBondsScreen extends StatelessWidget {
  const SovereignGoldBondsScreen({super.key});

  // Static constants for better performance
  static const EdgeInsets _itemPadding = EdgeInsets.all(16);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 5);
  static const double _badgeBorderRadius = 4.0;
  static const double _buttonHeight = 30.0;
  static const double _buttonBorderRadius = 50.0;
  static const double _nameMaxWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      final theme = ref.watch(themeProvider);
      
      if (bonds.sovereignGoldBonds?.ncbSGB?.isEmpty ?? true) {
        return const SizedBox();
      }
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBondsList(context, bonds, theme),
          _buildDivider(theme),
        ],
      );
    });
  }
  
  Widget _buildBondsList(BuildContext context, BondsProvider bonds, ThemesProvider theme) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildBondItem(context, bonds, theme, index),
      itemCount: bonds.sovereignGoldBonds!.ncbSGB!.length,
      separatorBuilder: (context, index) => _buildDivider(theme),
    );
  }
  
  Widget _buildBondItem(BuildContext context, BondsProvider bonds, ThemesProvider theme, int index) {
    final bond = bonds.sovereignGoldBonds!.ncbSGB![index];
    
    return InkWell(
      onTap: () => _showOrderBottomSheet(context, bonds, bond),
      child: Padding(
        padding: _itemPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBondHeader(bond, theme),
            const SizedBox(height: 8),
            _buildBondFooter(context, bonds, bond, theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBondHeader(dynamic bond, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _nameMaxWidth,
              child: Text(
                bond.name!,
                overflow: TextOverflow.ellipsis,
                style: _textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600
                ),
              ),
            ),
            const SizedBox(height: 4),
            _buildBondTypeBadge(theme),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBondTypeBadge(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.isDarkMode
          ? colors.colorGrey.withOpacity(.3)
          : const Color.fromARGB(78, 136, 137, 211),
        borderRadius: BorderRadius.circular(_badgeBorderRadius),
      ),
      child: Text(
        "SGB",
        style: _textStyle(const Color(0xff666666), 10, FontWeight.w500),
      ),
    );
  }
  
  Widget _buildBondFooter(BuildContext context, BondsProvider bonds, dynamic bond, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildClosingDate(bond, theme),
        _buildApplyButton(context, bonds, bond, theme),
      ],
    );
  }
  
  Widget _buildClosingDate(dynamic bond, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Closes on",
          style: _textStyle(const Color(0xff666666), 10, FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '${bond.biddingEndDate!.substring(5, 11)}',
          style: _textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500
          ),
        ),
      ],
    );
  }
  
  Widget _buildApplyButton(BuildContext context, BondsProvider bonds, dynamic bond, ThemesProvider theme) {
    return SizedBox(
      height: _buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, _buttonHeight),
          elevation: 0,
          padding: _buttonPadding,
          backgroundColor: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
        ),
        onPressed: () => _showOrderBottomSheet(context, bonds, bond),
        child: bonds.loading
          ? const SizedBox(
              width: 18,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff666666)
              ),
            )
          : Text(
              'Apply',
              style: _textStyle(
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                12,
                FontWeight.w500
              ),
            ),
      ),
    );
  }
  
  Widget _buildDivider(ThemesProvider theme) {
    return Divider(
      height: 0,
      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
    );
  }
  
  Future<void> _showOrderBottomSheet(BuildContext context, BondsProvider bonds, dynamic bond) async {
    await bonds.fetchLedgerBal();
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BondOrderScreenbottomPage(
          bondInfo: bond,
        ),
      ),
    );
  }

  TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

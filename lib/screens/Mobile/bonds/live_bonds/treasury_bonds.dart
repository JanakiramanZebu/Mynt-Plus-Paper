// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/Mobile/bonds/bonds_order_screen/orderscreenbottompage.dart';

import '../../../../provider/stocks_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/list_divider.dart';

class TreasuryBondsScreen extends StatefulWidget {
  const TreasuryBondsScreen({super.key});

  @override
  State<TreasuryBondsScreen> createState() => _TreasuryBondsScreenState();
}

class _TreasuryBondsScreenState extends State<TreasuryBondsScreen> {
  // Flag to prevent multiple bottom sheets from opening
  bool _isBottomSheetOpen = false;

  // Static constants for better performance
  static const EdgeInsets _itemPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _buttonPadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 5);
  static const double _badgeBorderRadius = 4.0;
  static const double _buttonHeight = 30.0;
  static const double _buttonBorderRadius = 50.0;
  static const double _nameMaxWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final bonds = ref.watch(bondsProvider);
      final theme = ref.watch(themeProvider);

      if (bonds.treasuryBonds?.ncbTBill?.isEmpty ?? true) {
        return const SizedBox();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBondsList(context, bonds, theme, ref),
          _buildDivider(theme),
        ],
      );
    });
  }

  Widget _buildBondsList(BuildContext context, BondsProvider bonds,
      ThemesProvider theme, WidgetRef ref) {
    // Safe null checks for bonds data
    final treasuryBonds = bonds.treasuryBonds?.ncbTBill;
    if (treasuryBonds == null || treasuryBonds.isEmpty) {
      return const SizedBox();
    }

    // Filter bonds based on search query
    List<dynamic> filteredBonds = treasuryBonds;
    if (ref.watch(stocksProvide).searchController.text.isNotEmpty) {
      filteredBonds = treasuryBonds
          .where((bond) => bonds.bondsCommonSearchList.contains(bond))
          .toList();
    }

    // if (filteredBonds.isEmpty) {
    //   return const SizedBox();
    // }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildBondItem(
          getResponsiveWidth(context),
          context,
          bonds,
          theme,
          index,
          filteredBonds),
      itemCount: filteredBonds.length,
      separatorBuilder: (context, index) => ListDivider(),
    );
  }

  Widget _buildBondItem(
      double responsiveWidth,
      BuildContext context,
      BondsProvider bonds,
      ThemesProvider theme,
      int index,
      List<dynamic> filteredBonds) {
    final bond = filteredBonds[index];

    return InkWell(
      onTap: () => _showOrderBottomSheet(responsiveWidth, context, bonds, bond),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildBondHeader(bond, theme)),
                _buildApplyButton(responsiveWidth, context, bonds, bond, theme),
              ],
            ),
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
        SizedBox(
          width: _nameMaxWidth,
          child: TextWidget.subText(
            text: bond.name!,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
        // const SizedBox(height: 4),
        // _buildBondTypeBadge(theme),
        // if (bond.yield != '') _buildYieldInfo(bond, theme),
      ],
    );
  }

  Widget _buildYieldInfo(dynamic bond, ThemesProvider theme) {
    return Row(
      children: [
        TextWidget.paraText(
          text: '${bond.yield}%',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        TextWidget.paraText(
          text: "Indicative Yield",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      ],
    );
  }

  Widget _buildBondFooter(BuildContext context, BondsProvider bonds,
      dynamic bond, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildClosingDate(bond, theme),
        if (bond.yield != '') _buildYieldInfo(bond, theme),
      ],
    );
  }

  Widget _buildClosingDate(dynamic bond, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.paraText(
          text: "T-Bill",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          // w500
        ),
        TextWidget.paraText(
          text: "- Closes on ",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
        const SizedBox(height: 4),
        TextWidget.paraText(
          text: '${bond.biddingEndDate!.substring(5, 11)}',
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      ],
    );
  }

  Widget _buildApplyButton(double responsiveWidth, BuildContext context,
      BondsProvider bonds, dynamic bond, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor:
            theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
        highlightColor:
            theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
        onTap: () =>
            _showOrderBottomSheet(responsiveWidth, context, bonds, bond),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Center(
            child: bonds.loading
                ? const SizedBox(
                    width: 18,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xff666666),
                    ),
                  )
                : TextWidget.subText(
                    text: 'Apply',
                    color: theme.isDarkMode
                        ? colors.secondaryDark
                        : colors.secondaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
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

  Future<void> _showOrderBottomSheet(double responsiveWidth,
      BuildContext context, BondsProvider bonds, dynamic bond) async {
    // Prevent opening multiple bottom sheets
    if (_isBottomSheetOpen) return;

    _isBottomSheetOpen = true;
    await bonds.fetchLedgerBal();
    responsiveWidth == 600
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.3, // set your desired width here
                  child: BondOrderScreenbottomPage(
                    bondInfo: bond,
                  ),
                ),
              );
            },
          )
        : showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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

          _isBottomSheetOpen = false;
    // showModalBottomSheet(
    //   isScrollControlled: true,
    //   useSafeArea: true,
    //   isDismissible: true,
    //   shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    //   context: context,
    //   builder: (context) => Container(
    //     padding: EdgeInsets.only(
    //       bottom: MediaQuery.of(context).viewInsets.bottom,
    //     ),
    //     child: BondOrderScreenbottomPage(
    //       bondInfo: bond,
    //     ),
    //   ),
    // );
  }
}

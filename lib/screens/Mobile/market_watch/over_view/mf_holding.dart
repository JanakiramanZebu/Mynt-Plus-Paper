import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';

class MutualFundholdings extends ConsumerStatefulWidget {
  const MutualFundholdings({super.key});

  @override
  ConsumerState<MutualFundholdings> createState() => _MutualFundholdingsState();
}

class _MutualFundholdingsState extends ConsumerState<MutualFundholdings> {
  bool _showAllFunds = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final shareHoldings = ref.watch(marketWatchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const SizedBox(height: 10),
        TextWidget.heroText(
            text: "Mutual Funds Holding Trend",
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            theme: theme.isDarkMode,
            fw: 1),
        const SizedBox(height: 3),
        TextWidget.paraText(
            text:
                "In last 3 months, mutual fund holding of the company has almost stayed constant",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0),
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.titleText(
                    text: "Stocks",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1),
                SizedBox(
                  width: 200,
                  // height: 40,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: shareHoldings.selctedmfHold,
                      menuItemStyleData: const MenuItemStyleData(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        height: 40,
                      ),
                      buttonStyleData: ButtonStyleData(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.colorBlue),
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        // maxHeight: 200,
                        // padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: theme.isDarkMode
                              ? const Color(0xFF121212)
                              : const Color(0xFFF1F3F8),
                        ),
                        offset: const Offset(-6, -6),
                      ),
                      style: TextWidget.textStyle(
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fontSize: 16,
                        fw: 0,
                      ),
                      hint: TextWidget.subText(
                        text: shareHoldings.selctedmfHold,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                      ),
                      items: shareHoldings
                          .addDividersAfterStock(shareHoldings.mfHoldType),
                      onChanged: (value) async {
                        shareHoldings.chngMfHold("$value");
                      },
                    ),
                  ),
                )
              ],
            )),
        const SizedBox(height: 10),
        ],
       ),),
        shareHoldings.fundamentalData!.mFholdings!.isEmpty
            ? const Center(child: NoDataFound())
            : _buildMFList(shareHoldings, theme)
      ],
    );
  }

  // Build MF List with sorting and View All functionality
  Widget _buildMFList(MarketWatchProvider shareHoldings, ThemesProvider theme) {
    final mfHoldings = shareHoldings.fundamentalData!.mFholdings!;
    final selectedType = shareHoldings.selctedmfHold;

    // Sort funds based on selected type
    List<dynamic> sortedFunds = List.from(mfHoldings);
    sortedFunds.sort((a, b) {
      double aValue, bValue;

      switch (selectedType) {
        case "AUM":
          aValue = double.tryParse(a.mfAum?.toString() ?? '0') ?? 0.0;
          bValue = double.tryParse(b.mfAum?.toString() ?? '0') ?? 0.0;
          break;
        case "Mkt cap held%":
          aValue = double.tryParse(a.marketCapHeld?.toString() ?? '0') ?? 0.0;
          bValue = double.tryParse(b.marketCapHeld?.toString() ?? '0') ?? 0.0;
          break;
        case "Weight%":
        default:
          aValue =
              double.tryParse(a.mfHoldingPercent?.toString() ?? '0') ?? 0.0;
          bValue =
              double.tryParse(b.mfHoldingPercent?.toString() ?? '0') ?? 0.0;
          break;
      }

      return bValue.compareTo(aValue); // Descending order
    });

    // Show top 5 or all funds based on state
    final displayFunds =
        _showAllFunds ? sortedFunds : sortedFunds.take(5).toList();
    final showViewAll = sortedFunds.length > 5;

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayFunds.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider);
          },
          itemBuilder: (BuildContext context, int index) {
            final fund = displayFunds[index];
            return ListTile(
              dense: false,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 232,
                      child: TextWidget.subText(
                        align: TextAlign.start,
                        text: "${fund.mutualFund}",
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: TextWidget.titleText(
                  text: selectedType == "AUM"
                      ? double.parse("${fund.mfAum ?? 0.00}").toStringAsFixed(2)
                      : "${double.parse("${selectedType == "Mkt cap held%" ? fund.marketCapHeld : fund.mfHoldingPercent ?? 0.00}").toStringAsFixed(2)}%",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0),
            );
          },
        ),

        // View All / Show Less button
        if (showViewAll)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllFunds = !_showAllFunds;
                    });
                  },
                  child: TextWidget.subText(
                    text: _showAllFunds ? "Show Less" : "View All",
                    //  (${sortedFunds.length} funds)
                    theme: theme.isDarkMode,
                    fw: 2,
                    color: colors.colorBlue,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

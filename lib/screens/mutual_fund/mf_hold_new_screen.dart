import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../portfolio_screens/holdings/filter_scrip_bottom_sheet.dart';
import 'mf_filter_bottom_sheet.dart';
import 'mf_hold_singlepage.dart';

class MfHoldNewScreen extends ConsumerWidget {
  const MfHoldNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);
    final showSearch = mfData.showMfHoldingSearch;
    final searchText = mfData.mfHoldingSearchController.text;
    
    // Get the appropriate list based on search state
    final items = showSearch && searchText.isNotEmpty
        ? (mfData.mfHoldingSearchItems ?? [])
        : (mfData.mfholdingnew?.data ?? []);

    // Check if user has any holdings data at all
    final hasHoldingsData = mfData.mfholdingnew?.data != null && 
                           mfData.mfholdingnew!.data!.isNotEmpty;

    return TransparentLoaderScreen(
      isLoading: mfData.holdstatload ?? false,
      child: Scaffold(
                body: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh logic here if needed
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      behavior: HitTestBehavior.opaque,
                      child: hasHoldingsData 
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Summary container
                                Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Invested amount column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.subText(
                                          text: "Invested",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                        const SizedBox(height: 4),
                                        TextWidget.subText(
                                          text:
                                              "${_formatValue(mfData.mfholdingnew?.summary?.invested)}",
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ],
                                    ),
                
                                    // Returns column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        TextWidget.subText(
                                          text: "Returns",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            TextWidget.subText(
                                                text: _formatValue(mfData
                                                    .mfholdingnew?.summary?.absReturnValue),
                                                color: _getColorBasedOnValue(
                                                  mfData
                                                      .mfholdingnew?.summary?.absReturnValue,
                                                  theme,
                                                ),
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.subText(
                                          text: "Current Value",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                        const SizedBox(height: 4),
                                        TextWidget.subText(
                                          text:
                                              "${mfData.mfholdingnew?.summary?.currentValue ?? "0.00"}",
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        TextWidget.subText(
                                          text: "Percentage",
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                        const SizedBox(height: 4),
                                        TextWidget.subText(
                                          text:
                                              " ${_formatValue(mfData.mfholdingnew?.summary?.absReturnPercent?.toString())}%",
                                          color: _getColorBasedOnValue(
                                            mfData.mfholdingnew?.summary?.absReturnPercent
                                                ?.toString(),
                                                theme,
                                          ),
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                
                          // Search and sort container (hidden when search is active)
                          if (!showSearch)
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 5, bottom: 8),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        decoration: BoxDecoration(
                                         color: theme.isDarkMode
                        ? colors.searchBgDark
                        : colors.searchBg,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Row(
                                                children: [
                                                  // Search icon that shows search container when clicked
                                                  Material(
                                                    color: Colors.transparent,
                                                    shape: const CircleBorder(),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: InkWell(
                                                      customBorder: const CircleBorder(),
                                                      splashColor: theme.isDarkMode
                                                          ? colors.splashColorDark
                                                          : colors.splashColorLight,
                                                      highlightColor: theme.isDarkMode
                                                          ? colors.highlightDark
                                                          : colors.highlightLight,
                                                      onTap: () {
                                                        Future.delayed(
                                                            const Duration(milliseconds: 150),
                                                            () async {
                                                          mfData.setMfHoldingSearch(true);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: SvgPicture.asset(
                                                          assets.searchIcon,
                                                         color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                                          width: 20,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Material(
                                                    color: Colors.transparent,
                                                    shape: const CircleBorder(),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: InkWell(
                                                      customBorder: const CircleBorder(),
                                                      splashColor: theme.isDarkMode
                                                          ? colors.splashColorDark
                                                          : colors.splashColorLight,
                                                      highlightColor: theme.isDarkMode
                                                          ? colors.highlightDark
                                                          : colors.highlightLight,
                                                      onTap: () async {
                                                        Future.delayed(
                                                            const Duration(milliseconds: 150),
                                                            () async {
                                                          await showModalBottomSheet(
                                                            useSafeArea: true,
                                                            isScrollControlled: true,
                                                            shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top: Radius.circular(16)),
                                                            ),
                                                            context: context,
                                                            builder: (context) =>
                                                                const MFFilterBottomSheet(),
                                                          );
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: SvgPicture.asset(
                                                          assets.filterLinesDark,
                                                          width: 18,
                                                      color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                
                          // Search container (shown conditionally when search icon is clicked)
                          if (showSearch)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              child: SizedBox(
                                height: 40,
                                child: TextFormField(
                                  autofocus: true,
                                  controller: mfData.mfHoldingSearchController,
                                 style: TextWidget.textStyle(
                                          fontSize: 16,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                        ),
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                   hintStyle: TextWidget.textStyle(
                                            fontSize: 14,
                                            theme: theme.isDarkMode,
                                           color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                          fw: 0,
                                          ),
                                    fillColor: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                                    filled: true,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset(
                                        assets.searchIcon,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                        width: 20,
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                    suffixIcon: Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        splashColor: theme.isDarkMode
                                            ? colors.splashColorDark
                                            : colors.splashColorLight,
                                        highlightColor: theme.isDarkMode
                                            ? colors.highlightDark
                                            : colors.highlightLight,
                                        onTap: () {
                                          mfData.clearMfHoldingSearch();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            assets.removeIcon,
                                            fit: BoxFit.scaleDown,
                                            color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                            width: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // Keep search active even when text is empty
                                    // Only perform search when there's text
                                    if (value.isNotEmpty) {
                                      mfData.mfHoldingSearch(value, context);
                                    } else {
                                      // Clear search results but keep search container open
                                      mfData.mfHoldingSearch("", context);
                                    }
                                  },
                                ),
                              ),
                            ),
                
                                // Show appropriate UI based on data state
                                _buildListContent(context, theme.isDarkMode, mfData, showSearch, searchText, items, theme),
                              ],
                            )
                          : const SizedBox(
                              height: 400,
                              child: Center(child: NoDataFound()),
                            ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildListContent(BuildContext context, bool isDarkMode, MFProvider mfData, bool showSearch, String searchText, List items, ThemesProvider theme) {
    // Show "No Data Found" when search is active with text and no results
    if (showSearch && searchText.isNotEmpty && items.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }

    // If items is empty but we're here, it means we have holdings data but search/filter resulted in empty
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int idx) {
        final index = idx ~/ 2;

        // Return divider for odd indices
        if (idx.isOdd) {
          return const ListDivider();
        }

        final item = items[index];
        if (item == null) return const SizedBox();

        return InkWell(
          onTap: () {
            if (item.iSIN != null) {
              // Fetch data first
              mfData.fetchmfholdsingpage("${item.iSIN}");

              // Show modal with data
              showModalBottomSheet(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                isDismissible: true,
                enableDrag: false,
                useSafeArea: true,
                context: context,
                builder: (context) => Container(
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const mfholdsinlepage()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + NAV
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextWidget.subText(
                        // align: TextAlign.start,
                        text: item.name ?? "Unknown Fund",
                        color: isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        theme: isDarkMode,
                        fw: 0,
                      ),
                    ),

                    Row(
                      children: [
                        TextWidget.titleText(
                            align: TextAlign.start,
                            text: "${item.profitLoss ?? "0.00"}",
                            color: _getColorBasedOnValue(
                                item.profitLoss.toString(), theme),
                            textOverflow: TextOverflow.ellipsis,
                            theme: isDarkMode,
                            fw: 0),
                      ],
                    )

                    // NAVV
                  ],
                ),
                const SizedBox(height: 8),

                // Exchange badge
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     TextWidget.paraText(
                //         align: TextAlign.start,
                //         text: "NSE",
                //         color: theme.isDarkMode
                //             ? colors.textSecondaryDark
                //             : colors.textSecondaryLight,
                //         textOverflow: TextOverflow.ellipsis,
                //         theme: theme.isDarkMode,
                //         fw: 3),
                //   ],
                // ),

                // const SizedBox(height: 4),

                // Divider(
                //   height: 12,
                //   thickness: 0.4,
                //   color: theme.isDarkMode
                //       ? colors.darkColorDivider
                //       : colors.colorDivider,
                // ),

                // const SizedBox(height: 4),

                // Units + Gain/Loss
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextWidget.paraText(
                            align: TextAlign.start,
                            text: "UNITS ",
                            color: isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: isDarkMode,
                            fw: 0),
                        TextWidget.paraText(
                            align: TextAlign.start,
                            text:
                                "${item.avgQty ?? 0} @ ${item.avgNav ?? "0.00"}",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0), 
                      ],
                    ),
                    Row(
                      children: [
                        TextWidget.paraText(
                            align: TextAlign.start,
                            text:
                                "(${(double.tryParse(item.changeprofitLoss.toString()) ?? 0.0).toStringAsFixed(2)}%)",
                            color: _getColorBasedOnValue(
                                item.changeprofitLoss.toString(), theme),
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Invested + Current
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextWidget.paraText(
                            // align: TextAlign.start,
                            text: "INV ",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0),
                        TextWidget.paraText(
                            // align: TextAlign.start,
                            text: "${item.investedValue ?? "0.00"}",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0),
                      ],
                    ),
                    Row(
                      children: [
                        TextWidget.paraText(
                            // align: TextAlign.start,
                            text: " NAV ",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0),
                        TextWidget.paraText(
                            // align: TextAlign.start,
                            text: "${item.curNav ?? "0.00"}",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     TextWidget.paraText(
                    //         // align: TextAlign.start,
                    //         text:  "Cur: ",
                    //         color: theme.isDarkMode
                    //             ? colors.textSecondaryDark
                    //             : colors.textSecondaryLight,
                    //         textOverflow: TextOverflow.ellipsis,
                    //         theme: theme.isDarkMode,
                    //         fw: 3),
                    //     TextWidget.paraText(
                    //         // align: TextAlign.start,
                    //         text:
                    //              "₹${item.currentValue ?? "0.00"}",
                    //         color: theme.isDarkMode
                    //             ? colors.textSecondaryDark
                    //             : colors.textSecondaryLight,
                    //         textOverflow: TextOverflow.ellipsis,
                    //         theme: theme.isDarkMode,
                    //         fw: 3),

                    //   ],
                    // ),
                  ],
                ),

                // const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      itemCount: items.length * 2 - 1,
    );
  }

  // Helper method to check if data is empty or has an error
  // bool _isEmptyOrErrorState(MFProvider mfData) {
  //   return mfData.mfholdingnew?.stat == "Not Ok" ||
  //       mfData.mfholdingnew?.msg == "No Data Found";
  // }

  // Helper method to safely format values
  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  // Helper method to determine color based on value
  Color _getColorBasedOnValue(String? valueStr, ThemesProvider theme) {
    final value = double.tryParse(valueStr ?? "0") ?? 0;
    return value >= 0 ? theme.isDarkMode ? colors.profitDark : colors.profitLight : theme.isDarkMode ? colors.lossDark : colors.lossLight;
  }
}

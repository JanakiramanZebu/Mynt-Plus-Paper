import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import 'mf_stock_detail_screen.dart';

class MFWatchlistScreen extends ConsumerStatefulWidget {
  const MFWatchlistScreen({super.key});

  @override
  ConsumerState<MFWatchlistScreen> createState() => _MFWatchlistScreenState();
}

class _MFWatchlistScreenState extends ConsumerState<MFWatchlistScreen> {
  String selectedReturn = '3Y Returns'; // Track selected return period

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);
    final mfData = ref.watch(mfProvider);

    // Sort the list based on selected return period
    final sortedList = mfData.mfWatchlist?.toList();
    if (sortedList != null) {
      sortedList.sort((a, b) {
        String? aValue, bValue;

        switch (selectedReturn) {
          case '1Y Returns':
            aValue = a.oneYearData;
            bValue = b.oneYearData;
            break;
          case '3Y Returns':
            aValue = a.tHREEYEARDATA;
            bValue = b.tHREEYEARDATA;
            break;
          case '5Y Returns':
            aValue = a.fIVEYEARDATA;
            bValue = b.fIVEYEARDATA;
            break;
          default:
            aValue = a.tHREEYEARDATA;
            bValue = b.tHREEYEARDATA;
        }

        final aDouble = double.tryParse(aValue ?? '0.00') ?? 0.00;
        final bDouble = double.tryParse(bValue ?? '0.00') ?? 0.00;
        return bDouble.compareTo(aDouble); // Sort in descending order
      });
    }

    return Scaffold(
      body: TransparentLoaderScreen(
        isLoading: mfData.bestmfloader ?? false,
        child: sortedList?.isEmpty ?? true
            ? const Center(child: NoDataFound())
            : Column(
                children: [
                  _buildHeader(theme),
                  Expanded(
                    child: ListView.separated(
                      // padding: const EdgeInsets.all(8),
                      itemCount: sortedList?.length ?? 0,
                      separatorBuilder: (_, __) => const ListDivider(),
                      itemBuilder: (BuildContext context, int index) {
                        final item = sortedList?[index];
                        if (item == null) return const SizedBox.shrink();

                        return _buildListItem(
                            context, item, theme, mfData, selectedReturn);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    return Container(
      // color:
      //     theme.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F8),
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 16, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.paraText(
            align: TextAlign.left,
            text: 'Funds',
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
          ),
          PopupMenuButton<String>(
             color: theme.isDarkMode
                              ? colors.searchBgDark
                              : colors.searchBg,
            onSelected: (value) {
              setState(() {
                selectedReturn = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: '1Y Returns',
                  child: TextWidget.paraText(
                    text: '1Y Returns',
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 3,
                  )),
              PopupMenuItem(
                  value: '3Y Returns',
                  child: TextWidget.paraText(
                    text: '3Y Returns',
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 3,
                  )),
              PopupMenuItem(
                  value: '5Y Returns',
                  child: TextWidget.paraText(
                    text: '5Y Returns',
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 3,
                  )),
            ],
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                 splashColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(0.15)
                                            : Colors.black.withOpacity(0.15),
                                        highlightColor: theme.isDarkMode
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextWidget.paraText(
                    align: TextAlign.right,
                    text: selectedReturn,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 3,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item,
      ThemesProvider theme, dynamic mfData, String selectedReturn) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            splashColor: theme.isDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.15),
            highlightColor: theme.isDarkMode
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            onLongPress: () async {
              try {
                final isin = item.iSIN;
                if (isin != null) {
                  await mfData.fetchMFWatchlist(
                    isin,
                    "delete",
                    context,
                    true,
                    "watch",
                  );
                } else {
                  showResponsiveErrorMessage(
                      context, "Missing fund information");
                }
              } catch (e) {
                showResponsiveErrorMessage(
                    context, "Error updating watchlist: ${e.toString()}");
              }
            },
            onTap: () async {
              try {
                mfData.loaderfun();
                final isin = item.iSIN;
                if (isin != null) {
                  await mfData.fetchFactSheet(isin);
                  await mfData.fetchmatchisan(isin);
                  // Navigator.pushNamed(
                  //   context,
                  //   Routes.mfStockDetail,
                  //   arguments: item,
                  // );
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
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: MFStockDetailScreen(mfStockData: item)),
                  );
                } else {
                  showResponsiveErrorMessage(
                      context, "Missing fund information");
                }
              } catch (e) {
                showResponsiveErrorMessage(
                    context, "Error loading fund details: ${e.toString()}");
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              dense: false,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
                ),
              ),
              title: Container(
                margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextWidget.subText(
                  text: item.mfsearchnamename ?? "Unknown Scheme",
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  theme: theme.isDarkMode,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 18,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      TextWidget.paraText(
                        text: "${item.type ?? "Unknown"}",
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        theme: false,
                      ),
                      // const SizedBox(width: 4),
                      // TextWidget.paraText(
                      //   text: "${item.schemeType ?? "Unknown"}",
                      //   textOverflow: TextOverflow.ellipsis,
                      //   maxLines: 1,
                      //   color: theme.isDarkMode
                      //       ? colors.textSecondaryDark
                      //       : colors.textSecondaryLight,
                      //   theme: false,
                      // ),
                    ],
                  ),
                ),
              ),
              trailing: TextWidget.subText(
                align: TextAlign.right,
                text: _formatReturns(_getReturnValue(item, selectedReturn)),
                color: colors.colorBlack,
                // _getReturnColor(item.tHREEYEARDATA, theme.isDarkMode)
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
              ),
            )));
  }

  String _getReturnValue(dynamic item, String selectedReturn) {
    switch (selectedReturn) {
      case '1Y Returns':
        return item.oneYearData ?? "0.00";
      case '3Y Returns':
        return item.tHREEYEARDATA ?? "0.00";
      case '5Y Returns':
        return item.fIVEYEARDATA ?? "0.00";
      default:
        return item.tHREEYEARDATA ?? "0.00";
    }
  }

  String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty) {
      return "0.00%";
    }
    return "$returns%";
  }

  Color _getReturnColor(String? returns, bool isDarkMode) {
    if (returns == null || returns.isEmpty) {
      return isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }

    try {
      final value = double.parse(returns);
      return value >= 0 ? Colors.green : Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }
}















// Container(
//           decoration: BoxDecoration(
//             border: Border.symmetric(
//               vertical: BorderSide(
//                 color: theme.isDarkMode
//                     ? colors.darkGrey
//                     : const Color(0xffEEF0F2),
//                 width: 0,
//               ),
//             ),
//           ),
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: CircleAvatar(
//                       backgroundImage: NetworkImage(
//                         "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextWidget.subText(
//                                                     align: TextAlign.right,
//                                                     text: item.schemeName ?? "Unknown Scheme",
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textPrimaryDark:
//                                                          colors.textPrimaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                         
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: SizedBox(
//                             height: 18,
//                             child: ListView(
//                               scrollDirection: Axis.horizontal,
//                               children: [
//                                 TextWidget.paraText(
//                                   fw: 3,
//                                   text: "${item.type ?? "Unknown"}",
//                                   textOverflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                   color: theme.isDarkMode
//                                       ? colors.textSecondaryDark
//                                       : colors.textSecondaryLight,
//                                   theme: false,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 5),
//                                   child: TextWidget.paraText(
//                                     fw: 3,
//                                     text: "${item.schemeType ?? "Unknown"}",
//                                     textOverflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                     color: theme.isDarkMode
//                                         ? colors.textSecondaryDark
//                                         : colors.textSecondaryLight,
//                                     theme: false,
//                                   ),
                                  
                                  
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   TextWidget.titleText(
//                                                     align: TextAlign.right,
//                                                     text: _formatReturns(item.tHREEYEARDATA),
//                                                     color: _getReturnColor(item.tHREEYEARDATA,theme.isDarkMode)
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                  
//                 ],
//               ),
             
//             ],
//           ),
//         ),
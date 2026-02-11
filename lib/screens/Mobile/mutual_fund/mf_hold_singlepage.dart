// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/ipo_time_line.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
// import '../../../sharedWidget/loader_ui.dart';
import '../../../sharedWidget/loader_ui.dart';
import '../mutual_fund_old/cancle_xsip_resone.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';
import '../mutual_fund/mf_cancel_alert.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import 'mf_stock_detail_screen.dart';

class mfholdsinlepage extends StatefulWidget {
  final bool isAllMf;
  const mfholdsinlepage({super.key, this.isAllMf = false});
  @override
  State<mfholdsinlepage> createState() => _mfholdsinlepage();
}

class _mfholdsinlepage extends State<mfholdsinlepage>
    with SingleTickerProviderStateMixin {
  // Helper method to safely format values
  String _formatValue(String? value) {
    return (value == null || value.isEmpty) ? "0.00" : value;
  }

  // Helper method to determine color based on value
  Color _getColorBasedOnValue(String? valueStr, ThemesProvider theme) {
    final value = double.tryParse(valueStr ?? "0") ?? 0;
    return value >= 0 ? theme.isDarkMode ? colors.profitDark : colors.profitLight : theme.isDarkMode ? colors.lossDark : colors.lossLight;
  }

  // Helper method to safely convert value to string (handles both String and double)
  String _safeToString(dynamic value) {
    if (value == null) return "0.00";
    if (value is String) return value.isEmpty ? "0.00" : value;
    if (value is double || value is int) return value.toString();
    return value.toString();
  }

  // Helper method to get item values from different data types
  String _getItemValue(dynamic item, String field) {
    if (item == null) return field == 'name' ? "Unknown Fund" : "0.00";

    try {
      switch (field) {
        case 'name':
          // AllMfModel uses sCRIPNAME, regular uses name
          // Backend will send properly formatted names, so return as is
          if (widget.isAllMf) {
            // For AllMfModel, check sCRIPNAME first
            if (item.sCRIPNAME != null && item.sCRIPNAME.toString().trim().isNotEmpty) {
              return item.sCRIPNAME.toString().trim();
            }
            if (item.name != null && item.name.toString().trim().isNotEmpty) {
              return item.name.toString().trim();
            }
          } else {
            // For regular model, use name as is (My MF)
            if (item.name != null && item.name.toString().trim().isNotEmpty) {
              return item.name.toString().trim();
            }
            try {
              if (item.sCRIPNAME != null && item.sCRIPNAME.toString().trim().isNotEmpty) {
                return item.sCRIPNAME.toString().trim();
              }
            } catch (e) {
              // sCRIPNAME doesn't exist on regular model, ignore
            }
          }
          return "Unknown Fund";
        case 'avgQty':
          // AllMfModel uses totalUnits (double) or nSOHQTY (String), regular uses avgQty (String)
          if (widget.isAllMf) {
            if (item.totalUnits != null) {
              return item.totalUnits.toString();
            }
            if (item.nSOHQTY != null && item.nSOHQTY.toString().trim().isNotEmpty) {
              return item.nSOHQTY.toString().trim();
            }
            if (item.avgQty != null && item.avgQty.toString().trim().isNotEmpty) {
              return item.avgQty.toString().trim();
            }
          } else {
            if (item.avgQty != null && item.avgQty.toString().trim().isNotEmpty) {
              return item.avgQty.toString().trim();
            }
            try {
              if (item.totalUnits != null) {
                return item.totalUnits.toString();
              }
              if (item.nSOHQTY != null && item.nSOHQTY.toString().trim().isNotEmpty) {
                return item.nSOHQTY.toString().trim();
              }
            } catch (e) {
              // These properties don't exist on regular model, ignore
            }
          }
          return "0";
        case 'profitLoss':
          // AllMfModel uses double, regular uses String
          return _safeToString(item.profitLoss);
        case 'changeprofitLoss':
          // AllMfModel uses double, regular uses String
          final value = item.changeprofitLoss;
          if (value == null) return "0.00";
          if (value is double) return value.toStringAsFixed(2);
          if (value is int) return value.toString();
          return _safeToString(value);
        case 'avgNav':
          // AllMfModel uses double, regular uses String
          return _safeToString(item.avgNav);
        case 'curNav':
          // AllMfModel uses double, regular uses String
          return _safeToString(item.curNav);
        case 'investedValue':
          // AllMfModel uses double, regular uses String
          return _safeToString(item.investedValue);
        case 'currentValue':
          // AllMfModel uses double, regular uses String
          return _safeToString(item.currentValue);
        default:
          return "0.00";
      }
    } catch (e) {
      return field == 'name' ? "Unknown Fund" : "0.00";
    }
  }

  MutualFundList _convertHoldingToMutualFundList(dynamic holdingData) {
    final fundName = _getItemValue(holdingData, 'name');
    
    // AllMfModel uses sCRIPSYMBOL, regular model uses sCHEMECODE
    String? schemeCode;
    if (widget.isAllMf) {
      schemeCode = holdingData.sCRIPSYMBOL;
    } else {
      schemeCode = holdingData.sCHEMECODE;
    }
    
    // AllMfModel doesn't have minRedemptionQty, so handle it safely
    String? minRedemptionQty;
    try {
      minRedemptionQty = holdingData.minRedemptionQty;
    } catch (e) {
      // minRedemptionQty doesn't exist on AllMfModel, ignore
      minRedemptionQty = null;
    }
    
    return MutualFundList(
      iSIN: holdingData.iSIN,
      schemeCode: schemeCode,
      schemeName: fundName,
      name: fundName,
      mfsearchnamename: fundName,
      aMCCode: holdingData.iSIN?.substring(0, 4), // Extract AMC code from ISIN
      type: "Equity", // Default type
      subtype: "Growth", // Default subtype
      aUM: "0", // Default AUM
      nETASSETVALUE: _getItemValue(holdingData, 'curNav'),
      minimumRedemptionQty: minRedemptionQty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mfdata = ref.watch(mfProvider);

      // Check if data is available
      final hasData = mfdata.holssinglelist != null &&
          mfdata.holssinglelist!.isNotEmpty &&
          mfdata.holssinglelist![0] != null;

      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            border: Border(
              top: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              left: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              right: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
            ),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.88,
            maxChildSize: 0.88,
            builder: (context, scrollController) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  controller: scrollController,
                  child: hasData
                      ? _buildHoldingDetails(context, theme, mfdata)
                      : const Center(child: NoDataFound(
                          secondaryEnabled: false,
                        )),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  // Extracted method to build holding details
  Widget _buildHoldingDetails(
      BuildContext context, ThemesProvider theme, MFProvider mfdata) {
    final data = mfdata.holssinglelist![0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // const SizedBox(width: 0),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomDragHandler(),
                              Material(
                                color: Colors.transparent,
                                // shape: const CircleBorder(),
                                child: InkWell(
                                  splashColor: theme.isDarkMode
                                      ? colors.splashColorDark
                                      : colors.splashColorLight,
                                  highlightColor: theme.isDarkMode
                                      ? colors.highlightDark
                                      : colors.highlightLight,
                                  onTap: () async {
                                    await Future.delayed(
                                        const Duration(milliseconds: 150));
                                    try {
                                      final isin = data.iSIN;
                                      if (isin != null) {
                                        mfdata.loaderfun();
                                        await mfdata.fetchFactSheet(isin);
                                        mfdata.fetchmatchisan(isin);

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
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                              ),
                                              child: MFStockDetailScreen(
                                                  mfStockData:
                                                      _convertHoldingToMutualFundList(
                                                          data))),
                                        );
                                      } else {
                                        successMessage(
                                                context,
                                                "Missing fund information");
                                      }
                                    } catch (e) {
                                      successMessage(context,
                                              "Error loading fund details: ${e.toString()}");
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: TextWidget.titleText(
                                              // align: TextAlign.start,
                                              text: _getItemValue(data, 'name'),
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              maxLines: 2,
                                              fw: 1),
                                        ),
                                        SvgPicture.asset(
                                          assets.rightarrowcur,
                                          width: 20,
                                          height: 20,
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Only show redeem button for "My MF", not for "All MF"
          if (!widget.isAllMf)
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        mfdata.recdemevalu();
                        Navigator.pushNamed(
                          context,
                          Routes.redeemNewBottomSheet,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.6)
                            : colors.btnBg,
                        // foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        side: theme.isDarkMode
                            ? null
                            : BorderSide(
                                color: colors.primaryLight,
                                width: 1,
                              ),
                        minimumSize: Size(double.infinity, 45), // height: 48
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: TextWidget.subText(
                          align: TextAlign.right,
                          text: "Redeem",
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.primaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          fw: 2),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          rowOfInfoData(
            "Returns",
            "${_getItemValue(data, 'profitLoss')} (${_getItemValue(data, 'changeprofitLoss')}%)",
            theme,
            valueColor: _getColorBasedOnValue(_getItemValue(data, 'profitLoss'), theme),
          ),

          // Units and Avg Price
          rowOfInfoData(
            "Units",
            _getItemValue(data, 'avgQty'),
            theme,
          ),

          rowOfInfoData(
            "Avg Price",
            _getItemValue(data, 'avgNav'),
            theme,
          ),

          rowOfInfoData(
            "NAV",
            _getItemValue(data, 'curNav'),
            theme,
          ),

          // Pledged Units and Current NAV
          rowOfInfoData(
            "Pledged Units",
            // "${data.pLEDGEQTY ?? '0'}",
            "0",

            theme,
          ),

          rowOfInfoData(
            "Current",
            _getItemValue(data, 'currentValue'),
            theme,
          ),

          // Invested and Current Value
          rowOfInfoData(
            "Invested",
            _getItemValue(data, 'investedValue'),
            theme,
          ),

          // const SizedBox(height: 12),
          // Divider(
          //   color: theme.isDarkMode
          //       ? colors.darkColorDivider
          //       : colors.colorDivider,
          //   thickness: 1.0,
          // ),

          // const Spacer(),

          // Redeem button
          // SafeArea(
          //   child: Row(
          //     children: [
          //       Expanded(
          //         flex: 6,
          //         child: SizedBox(
          //           width: double.infinity,
          //           child: ElevatedButton(
          //             onPressed: () {
          //               _showBottomSheet(
          //                 context,
          //                 RedemptionBottomScreenNew(),
          //               );
          //               mfdata.recdemevalu();
          //             },
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.white,
          //               foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          //               side: const BorderSide(
          //                 color: Color.fromARGB(255, 0, 0, 0),
          //                 width: 1,
          //               ),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20),
          //               ),
          //             ),
          //             child: const Text(
          //               "Redeem",
          //               style: TextStyle(
          //                 color: Color.fromARGB(255, 0, 0, 0),
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Column rowOfInfoData(String title1, String value1, ThemesProvider theme,
      {Color? valueColor}) {
    return Column(children: [
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              // align: TextAlign.right,
              text: title1,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 0),
          TextWidget.subText(
              align: TextAlign.right,
              text: value1,
              color: valueColor ??
                  (theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight),
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 0),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
        thickness: 0,
        color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
      )
    ]);
  }

  void _showBottomSheet(BuildContext context, Widget BottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BottomSheet));
  }
}

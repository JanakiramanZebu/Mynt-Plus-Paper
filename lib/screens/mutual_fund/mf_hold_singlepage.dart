// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_timeline.dart';
import 'package:mynt_plus/screens/mutual_fund/redeem_new_bottomsheet.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/ipo_time_line.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
// import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/loader_ui.dart';
import '../mutual_fund_old/cancle_xsip_resone.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';
import '../mutual_fund/mf_cancel_alert.dart';

class mfholdsinlepage extends StatefulWidget {
  const mfholdsinlepage({super.key});
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
  Color _getColorBasedOnValue(String? valueStr) {
    final value = double.tryParse(valueStr ?? "0") ?? 0;
    return value >= 0 ? Colors.green : Colors.red;
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

      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leadingWidth: 41,
            titleSpacing: 6,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            title: Text("Holding details",
                style: textStyles.appBarTitleTxt.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                )),
          ),
          body: Stack(children: [
            TransparentLoaderScreen(
              isLoading: mfdata.bestmfloader ?? false,
              child: hasData
                  ? _buildHoldingDetails(context, theme, mfdata)
                  : const Center(child: Text("No holding data available")),
            )
          ]));
    });
  }

  // Extracted method to build holding details
  Widget _buildHoldingDetails(
      BuildContext context, ThemesProvider theme, MFProvider mfdata) {
    final data = mfdata.holssinglelist![0];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
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
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget.titleText(
                                          align: TextAlign.start,
                                          text: data.name ?? "Unknown Fund",
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          maxLines: 2,
                                          fw: 0),
                                      const SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "₹ ${_formatValue(data.profitLoss)} ",
                                            style: textStyle(
                                              _getColorBasedOnValue(
                                                  data.profitLoss),
                                              14,
                                              FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "(${(double.tryParse(data.profitLoss ?? '0') ?? 0).toStringAsFixed(2)}%)",
                                            style: textStyle(
                                              _getColorBasedOnValue(
                                                  data.profitLoss),
                                              14,
                                              FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 6,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showBottomSheet(
                        context,
                        RedemptionBottomScreenNew(),
                      );
                      mfdata.recdemevalu();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: colors.btnBg,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      side: BorderSide(
                        color: colors.btnOutlinedBorder,
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
                            ? colors.primaryDark
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

          // Units and Avg Price
          rowOfInfoData(
            "Units",
            "${data.avgQty ?? '0'}",
            theme,
          ),
          const SizedBox(height: 12),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            thickness: 1.0,
          ),
          const SizedBox(height: 12),

          rowOfInfoData(
            "Avg Price",
            "${data.avgNav ?? '0'}",
            theme,
          ),
          const SizedBox(height: 12),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            thickness: 1.0,
          ),
          const SizedBox(height: 12),

          // Pledged Units and Current NAV
          rowOfInfoData(
            "Pledged Units",
            // "${data.pLEDGEQTY ?? '0'}",
            "0",

            theme,
          ),
          const SizedBox(height: 12),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            thickness: 1.0,
          ),
          const SizedBox(height: 12),

          rowOfInfoData(
            "Current NAV",
            "${data.currentValue ?? '0'}",
            theme,
          ),

          const SizedBox(height: 12),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            thickness: 1.0,
          ),
          const SizedBox(height: 12),

          // Invested and Current Value
          rowOfInfoData(
            "Invested",
            "₹ ${data.investedValue ?? '0'}",
            theme,
          ),
          const SizedBox(height: 12),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            thickness: 1.0,
          ),
          const SizedBox(height: 12),

           

          // const SizedBox(height: 12),
          // Divider(
          //   color: theme.isDarkMode
          //       ? colors.darkColorDivider
          //       : colors.colorDivider,
          //   thickness: 1.0,
          // ),

          const Spacer(),

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

  Row rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      TextWidget.subText(
          align: TextAlign.right,
          text: title1,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          fw: 3),
      TextWidget.subText(
          align: TextAlign.right,
          text: value1,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          fw: 3),
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

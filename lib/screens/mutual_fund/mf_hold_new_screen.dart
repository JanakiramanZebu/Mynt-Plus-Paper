import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'mf_hold_singlepage.dart';

class MfHoldNewScreen extends ConsumerWidget {
  const MfHoldNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    return Scaffold(
      body: TransparentLoaderScreen(
        isLoading: mfData.holdstatload ?? false,
        child: Column(
          children: [
            // Summary container
            Container(
              padding: const EdgeInsets.all(16),
              // decoration: BoxDecoration(
              //   color: theme.isDarkMode
              //       ? const Color(0xffB5C0CF).withOpacity(.15)
              //       : const Color(0xffF1F3F8),
              // ),
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
                          ),
                          const SizedBox(height: 4),
                          TextWidget.subText(
                            text:
                                "${_formatValue(mfData.mfholdingnew?.summary?.invested)}",
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
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
                          ),
                          const SizedBox(height: 4),
                          TextWidget.subText(
                            text:
                                "${mfData.mfholdingnew?.summary?.currentValue ?? "0.00"}",
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
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
                          ),
                          const SizedBox(height: 4),
                           TextWidget.subText(
                                text:
                                    " ${_formatValue(mfData.mfholdingnew?.summary?.absReturnPercent?.toString())}%",
                                color: _getColorBasedOnValue(
                                  mfData.mfholdingnew?.summary?.absReturnPercent
                                      ?.toString(),
                                ),
                                theme: theme.isDarkMode,
                              ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Show appropriate UI based on data state

            Expanded(
              child: ListView.separated(
                // padding: const EdgeInsets.symmetric(horizontal: ),
                itemCount: mfData.mfholdingnew?.data?.length ?? 0,
                separatorBuilder: (_, __) => const ListDivider(),
                itemBuilder: (BuildContext context, int index) {
                  // Safely get item or return empty widget if null
                  final item = mfData.mfholdingnew?.data?[index];
                  if (item == null) return const SizedBox();

                  // Get formatted values with null safety
                  // final val = item.current ?? '0.00';

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
                                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                ),
                              ),

                              Row(
                                children: [
                                  TextWidget.titleText(
                                      align: TextAlign.start,
                                      text: "${item.profitLoss ?? "0.00"}",
                                      color: _getColorBasedOnValue(
                                          item.profitLoss.toString()),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
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
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
                                  TextWidget.paraText(
                                      align: TextAlign.start,
                                      text:
                                          "${item.avgQty ?? 0} @ ${item.avgNav ?? "0.00"}",
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
                                ],
                              ),
                              Row(
                                children: [
                                  TextWidget.paraText(
                                      align: TextAlign.start,
                                      text:
                                          "(${(double.tryParse(item.changeprofitLoss.toString()) ?? 0.0).toStringAsFixed(2)}%)",
                                      color: _getColorBasedOnValue(
                                          item.changeprofitLoss.toString()),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
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
                                      fw: 3),
                                  TextWidget.paraText(
                                      // align: TextAlign.start,
                                      text: "${item.investedValue ?? "0.00"}",
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
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
                                      fw: 3),
                                  TextWidget.paraText(
                                      // align: TextAlign.start,
                                      text: "${item.curNav ?? "0.00"}",
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 3),
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
              ),
            ),
          ],
        ),
      ),
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
  Color _getColorBasedOnValue(String? valueStr) {
    final value = double.tryParse(valueStr ?? "0") ?? 0;
    return value >= 0 ? colors.profit : colors.loss;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/Mobile/desk_reports/bottom_sheets/holdings_inner_detail.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';

import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/no_data_found.dart';

class HoldingScreen extends StatelessWidget {
  final String ddd;
  const HoldingScreen({super.key, required this.ddd});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final socketDatas = ref.watch(websocketProvider).socketDatas;
      final ledgerData = ref.watch(ledgerProvider);

      // Pre-calculate summary values outside of build components
      final summaryData = _calculateSummaryData(ledgerData, socketDatas);

      Future<void> refresh() async {
        await ledgerData.getCurrentDate('else');
        ledgerData.fetchholdingsData(ledgerData.today, context);
      }

      return Scaffold(
        appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: InkWell(
            onTap: () {
              ledgerData.falseloader('holdings');
            },
            child: const CustomBackBtn(),
          ),
          elevation: 0.2,
          title: TextWidget.heroText(
              text: "Holdings",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: TransparentLoaderScreen(
            isLoading: ledgerData.holdingsloading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryHeader(screenWidth, theme, summaryData),
                ledgerData.holdingsAllData?.holdings == null
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: NoDataFound(),
                      ))
                    : Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              ledgerData.holdingsAllData?.holdings?.length ?? 0,
                          itemBuilder: (context, index) {
                            final holdingItem = _processHoldingItem(
                                ledgerData.holdingsAllData!.holdings![index],
                                socketDatas,
                                theme);

                            return _buildHoldingItem(
                                context, holdingItem, index, ledgerData, theme);
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Process holding data with all calculations outside the build method
  Map<String, dynamic> _processHoldingItem(
      Map<String, dynamic> item, Map socketDatas, dynamic theme) {
    final processedItem = Map<String, dynamic>.from(item);
    final token = item['Token'];
    final net = num.tryParse(item['NET'].toString()) ?? 0;
    final buyPrice = num.tryParse(item['buy_price'].toString()) ?? 0;

    num livePrice = 0;

    // Determine live price from socket or nav data
    if (token != null &&
        token.toString().isNotEmpty &&
        socketDatas.containsKey(token)) {
      livePrice =
          num.tryParse(socketDatas[token]?['lp']?.toString() ?? '0') ?? 0;
      processedItem['ltp'] = "${socketDatas[token]?['lp'] ?? 0.00}";
      processedItem['ltpch'] = "${socketDatas[token]?['pc'] ?? 0.00}";
    } else {
      livePrice = num.tryParse(item['nav_price'].toString()) ?? 0;
      processedItem['ltp'] = livePrice.toString();
      processedItem['ltpch'] = "${socketDatas[token]?['pc'] ?? 0.00}";
    }

    // Calculate P&L data
    if (buyPrice > 0) {
      final pnl = ((livePrice * net) - (buyPrice * net));
      processedItem['pnl'] = pnl.toStringAsFixed(2);
      processedItem['pnlch'] =
          ((pnl / (buyPrice * net)) * 100).toStringAsFixed(2);
    } else {
      processedItem['pnl'] = "0";
      processedItem['pnlch'] = "0";
    }

    // Pre-calculate investment and current values
    processedItem['investment'] = (buyPrice * net).toStringAsFixed(2);
    processedItem['current'] = (livePrice * net).toStringAsFixed(2);

    return processedItem;
  }

  // Calculate summary data for the portfolio
  Map<String, dynamic> _calculateSummaryData(
      dynamic ledgerData, Map socketDatas) {
    double currentVal = 0.0;
    double pnlStat = 0.0;

    if (ledgerData.holdingsAllData != null) {
      final holdings = ledgerData.holdingsAllData?.holdings;
      if (holdings != null) {
        for (var item in holdings) {
          final token = item['Token'];
          final net = num.tryParse(item['NET'].toString()) ?? 0;
          final buyPrice = num.tryParse(item['buy_price'].toString()) ?? 0;

          num livePrice = 0;

          if (token != null &&
              token.toString().isNotEmpty &&
              socketDatas.containsKey(token)) {
            livePrice =
                num.tryParse(socketDatas[token]?['lp']?.toString() ?? '0') ?? 0;
          } else {
            livePrice = num.tryParse(item['nav_price'].toString()) ?? 0;
          }

          currentVal += livePrice * net;
          if (buyPrice > 0) {
            pnlStat += ((livePrice * net) - (buyPrice * net));
          }
        }
      }
    }

    return {
      'currentValue': currentVal,
      'pnl': pnlStat,
      'totalInvested': ledgerData.holdingsAllData?.totalInvested,
    };
  }

  // Build the summary header widget
  Widget _buildSummaryHeader(
      double screenWidth, dynamic theme, Map<String, dynamic> summaryData) {
    final currentVal = summaryData['currentValue'];
    final pnl = summaryData['pnl'];
    final totalInvested = summaryData['totalInvested'];

    // Calculate percentage only if we have valid data
    String pnlPercentage = '0.00';
    if (totalInvested != null &&
        totalInvested.toString() != 'null' &&
        num.tryParse(totalInvested.toString()) != 0) {
      pnlPercentage = ((pnl / num.tryParse(totalInvested.toString())!) * 100)
          .toStringAsFixed(2);
    }

    return Container(
        width: screenWidth,
        decoration: BoxDecoration(
            color: theme.isDarkMode
                ? const Color(0xffB5C0CF).withOpacity(.15)
                : const Color(0xffF1F3F8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                        text: "Total Investment",
                        color: const Color(0xFF696969),
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextWidget.titleText(
                          text: totalInvested == null ||
                                  totalInvested.toString() == 'null'
                              ? "0.00"
                              : "₹ $totalInvested",
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          fw: 1),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                          text: "Current Value    ",
                          color: const Color(0xFF696969),
                          theme: theme.isDarkMode,
                          fw: 0),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextWidget.titleText(
                            text: "₹ ${currentVal.toStringAsFixed(2)}",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            color: currentVal > 0
                                ? Colors.green
                                : currentVal < 0
                                    ? Colors.red
                                    : theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                            fw: 1),
                      )
                    ],
                  ),
                ),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWidget.subText(
                      align: TextAlign.right,
                      text: "Total P&L    ",
                      color: const Color(0xFF696969),
                      theme: theme.isDarkMode,
                      fw: 0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextWidget.titleText(
                            color: pnl > 0
                                ? Colors.green
                                : pnl < 0
                                    ? Colors.red
                                    : theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                            text: "₹ ${pnl.toStringAsFixed(2)}",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextWidget.subText(
                            text: "($pnlPercentage%)",
                            color: pnl > 0
                                ? Colors.green
                                : pnl < 0
                                    ? Colors.red
                                    : theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                            theme: theme.isDarkMode,
                            fw: 0),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ));
  }

  // Build an individual holding item
  Widget _buildHoldingItem(BuildContext context, Map<String, dynamic> item,
      int index, dynamic ledgerData, dynamic theme) {
    final ltp = item['ltp'];
    final ltpch = item['ltpch'];
    final pnl = item['pnl'];
    final pnlch = item['pnlch'];
    final symbolName = item['SCRIP_SYMBOL'];
    final segType = item['seg_type'];
    final qty = item['NET'];
    final buyPrice = item['buy_price'];
    final investment = item['investment'];
    final current = item['current'];

    final ltpColor = (double.tryParse(ltpch) ?? 0) > 0
        ? Colors.green
        : (double.tryParse(ltpch) ?? 0) < 0
            ? Colors.red
            : Colors.black;

    final pnlColor = (num.tryParse(pnl) ?? 0) > 0
        ? Colors.green
        : (num.tryParse(pnl) ?? 0) < 0
            ? Colors.red
            : theme.isDarkMode
                ? colors.colorWhite
                : colors.colorBlack;

    return InkWell(
      onTap: () {
        _showBottomSheet(
            context,
            HoldingInnerDetails(
                data: ledgerData.holdingsAllData!.holdings![index]));
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                          text: symbolName,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          theme: theme.isDarkMode,
                          fw: 1),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CustomExchBadge(exch: segType),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          TextWidget.subText(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : const Color(0xFF696969),
                              text: "LTP : ",
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              fw: 0),
                          TextWidget.subText(
                              text: "₹$ltp",
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              fw: 0),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: TextWidget.paraText(
                            text: "($ltpch %)",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            color: ltpColor,
                            fw: 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: Color.fromARGB(255, 212, 212, 212),
            thickness: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 2.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextWidget.subText(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0xFF696969),
                        text: "Qty : ",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    TextWidget.subText(
                        text: "$qty @ ₹$buyPrice",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ],
                ),
                Row(
                  children: [
                    TextWidget.subText(
                        text: "₹$pnl",
                        color: pnlColor,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    TextWidget.paraText(
                        color: pnlColor,
                        text: " ($pnlch%)",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextWidget.subText(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0xFF696969),
                        text: "Inv : ",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    TextWidget.subText(
                        text: "₹ $investment",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ],
                ),
                Row(
                  children: [
                    TextWidget.subText(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0xFF696969),
                        text: "Cur : ",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    TextWidget.subText(
                        text: "₹$current",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: theme.isDarkMode
                ? const Color(0xffB5C0CF).withOpacity(.15)
                : const Color(0xffF1F3F8),
            thickness: 7.0,
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
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
            child: bottomSheet));
  }
}

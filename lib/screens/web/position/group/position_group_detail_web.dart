import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_exch_badge.dart';
import '../../../../sharedWidget/scrip_info_btns.dart';

class PositionGroupDetail extends ConsumerWidget {
  final Map<String, dynamic> positionData;
  const PositionGroupDetail({super.key, required this.positionData});

  // Get color for P&L values
  Color _getPnlColor(String? value, BuildContext context) {
    if (value == null || value == "null" || value == "0.00") {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }
    if (value.startsWith("-")) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    }
    return resolveThemeColor(context,
        dark: MyntColors.profitDark, light: MyntColors.profit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(portfolioProvider);

    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};

        // Update position data with real-time values
        if (socketDatas.containsKey(positionData['token'])) {
          final lp = socketDatas["${positionData['token']}"]['lp']?.toString();
          final pc = socketDatas["${positionData['token']}"]['pc']?.toString();
          final chng =
              socketDatas["${positionData['token']}"]['chng']?.toString();

          if (lp != null && lp != "null") {
            positionData['lp'] = lp;
          }

          if (pc != null && pc != "null") {
            positionData['perChange'] = pc;
          }

          if (chng != null && chng != "null") {
            positionData['chng'] = chng;
          }

          // Calculate P&L or MTM based on latest price
          if (positionData['avgPrc'] != null &&
              positionData['netqty'] != null) {
            final avgPrice =
                double.tryParse(positionData['avgPrc']?.toString() ?? "0.0") ??
                    0.0;
            final qty =
                int.tryParse(positionData['netqty']?.toString() ?? "0") ?? 0;
            final ltp =
                double.tryParse(positionData['lp']?.toString() ?? "0.0") ?? 0.0;

            if (avgPrice > 0 && qty != 0 && ltp > 0) {
              final pnl = (ltp - avgPrice) * qty;
              positionData['profitNloss'] = pnl.toStringAsFixed(2);
              positionData['mTm'] = pnl.toStringAsFixed(2);
            }
          }
        }

        return Scaffold(
            appBar: AppBar(
                elevation: .2,
                centerTitle: false,
                leadingWidth: 41,
                titleSpacing: 6,
                leading: const CustomBackBtn(),
                title: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${positionData['symbol']}",
                                  style: MyntWebTextStyles.title(
                                    context,
                                    color: primaryColor,
                                    fontWeight: MyntFonts.semiBold,
                                  ),
                                ),
                                Text(
                                  " ${positionData['option']} ",
                                  overflow: TextOverflow.ellipsis,
                                  style: MyntWebTextStyles.body(
                                    context,
                                    color: primaryColor,
                                    fontWeight: MyntFonts.medium,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${positionData['lp']}",
                              style: MyntWebTextStyles.title(
                                context,
                                color: primaryColor,
                                fontWeight: MyntFonts.semiBold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(children: [
                                CustomExchBadge(
                                    exch: "${positionData['exch']}"),
                                Text(
                                  "  ${positionData['expDate']}",
                                  style: MyntWebTextStyles.para(
                                    context,
                                    color: secondaryColor,
                                    fontWeight: MyntFonts.semiBold,
                                  ),
                                ),
                              ]),
                              Text(
                                "${double.parse("${positionData['chng'] ?? 0.00} ").toStringAsFixed(2)} (${positionData['perChange'] ?? 0.00}%)",
                                style: MyntWebTextStyles.para(
                                  context,
                                  color: _getPnlColor(
                                      positionData['chng']?.toString(),
                                      context),
                                  fontWeight: MyntFonts.medium,
                                ),
                              ),
                            ])
                      ]),
                )),
            body: ListView(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: resolveThemeColor(context,
                                dark: const Color(0xff666666)
                                    .withValues(alpha: 0.2),
                                light: const Color(0xff999999)
                                    .withValues(alpha: 0.2))),
                        child: Text(
                          "${positionData['s_prdt_ali']}",
                          style: MyntWebTextStyles.para(
                            context,
                            color: secondaryColor,
                            fontWeight: MyntFonts.semiBold,
                          ),
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          positions.isNetPnl ? "P&L" : "MTM",
                          style: MyntWebTextStyles.para(
                            context,
                            color: secondaryColor,
                            fontWeight: MyntFonts.medium,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (positions.isNetPnl) ...[
                              Text(
                                "${positionData['profitNloss'] ?? positionData['rpnl']}",
                                style: MyntWebTextStyles.titlesub(
                                  context,
                                  color: _getPnlColor(
                                      (positionData['profitNloss'] ??
                                              positionData['rpnl'])
                                          ?.toString(),
                                      context),
                                  fontWeight: MyntFonts.semiBold,
                                ),
                              )
                            ] else ...[
                              Text(
                                "${positionData['mTm']}",
                                style: MyntWebTextStyles.titlesub(
                                  context,
                                  color: _getPnlColor(
                                      positionData['mTm']?.toString(), context),
                                  fontWeight: MyntFonts.semiBold,
                                ),
                              )
                            ]
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ScripInfoBtns(
                  exch: '${positionData['exch']}',
                  token: '${positionData['token']}',
                  insName: '',
                  tsym: '${positionData['tysm']}'),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Position details",
                          style: MyntWebTextStyles.title(
                            context,
                            color: primaryColor,
                            fontWeight: MyntFonts.semiBold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          leftLabel: "Price",
                          leftValue: "${positionData['dayavgprc'] ?? 0.00}",
                          rightLabel: "Net Qty",
                          rightValue: "${positionData['netqty'] ?? 0}",
                          isHeader: true,
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        _buildDetailRow(
                          context,
                          leftLabel: "Day Buy Avg",
                          leftValue: "${positionData['daybuyavgprc'] ?? 0.00}",
                          rightLabel: "Day Buy Qty",
                          rightValue: "${positionData['daybuyqty'] ?? 0}",
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        _buildDetailRow(
                          context,
                          leftLabel: "Day Sell Avg",
                          leftValue: "${positionData['daysellavgprc'] ?? 0.00}",
                          rightLabel: "Day Sell Qty",
                          rightValue: "${positionData['daysellqty'] ?? 0}",
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        _buildDetailRow(
                          context,
                          leftLabel: "CF Buy Avg",
                          leftValue: "${positionData['cfbuyavgprc'] ?? 0.00}",
                          rightLabel: "CF Buy Qty",
                          rightValue: "${positionData['cfbuyqty'] ?? 0}",
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        _buildDetailRow(
                          context,
                          leftLabel: "CF Sell Avg",
                          leftValue: "${positionData['cfsellavgprc'] ?? 0.00}",
                          rightLabel: "CF Sell Qty",
                          rightValue: "${positionData['cfsellqty'] ?? 0}",
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        const SizedBox(height: 4),
                        _buildSingleDetailRow(
                          context,
                          label: "Net Buy Value",
                          value: "${positionData['totbuyamt'] ?? 0.00}",
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        _buildSingleDetailRow(
                          context,
                          label: "Net Sell Value",
                          value: "${positionData['totsellamt'] ?? 0.00}",
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                        _buildSingleDetailRow(
                          context,
                          label: "Net Value",
                          value: (double.parse(
                                      "${positionData['totbuyamt'] ?? 0.00}") +
                                  double.parse(
                                      "${positionData['totsellamt'] ?? 0.00}"))
                              .toStringAsFixed(2),
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          dividerColor: dividerColor,
                        ),
                      ])),
            ]),
            bottomNavigationBar: positionData['s_prdt_ali'] == "BO" ||
                    positionData['s_prdt_ali'] == "CO"
                ? null
                : BottomAppBar(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const CircularNotchedRectangle(),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        Expanded(
                          child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                  color: MyntColors.profit,
                                  borderRadius: BorderRadius.circular(32)),
                              width: MediaQuery.of(context).size.width,
                              child: InkWell(
                                onTap: () async {
                                  await ref
                                      .read(marketWatchProvider)
                                      .fetchScripInfo(
                                          "${positionData['token']}",
                                          '${positionData['exch']}',
                                          context,
                                          true);
                                  Navigator.pop(context);
                                  OrderScreenArgs orderArgs = OrderScreenArgs(
                                      exchange: '${positionData['exch']}',
                                      tSym: '${positionData['tsym']}',
                                      isExit: false,
                                      token: "${positionData['token']}",
                                      transType: true,
                                      prd: "${positionData['prd']}",
                                      lotSize: positionData['netqty'],
                                      ltp: positionData['lp'],
                                      perChange:
                                          positionData['perChange'] ?? "0.00",
                                      orderTpye: '',
                                      holdQty: '${positionData['netqty']}',
                                      isModify: false,
                                      raw: {});

                                  Navigator.pushNamed(
                                      context, Routes.placeOrderScreen,
                                      arguments: {
                                        "orderArg": orderArgs,
                                        "scripInfo": ref
                                            .read(marketWatchProvider)
                                            .scripInfoModel!,
                                        "isBskt": ""
                                      });
                                },
                                child: Center(
                                    child: Text(
                                  "Add More",
                                  style: MyntWebTextStyles.body(
                                    context,
                                    color: MyntColors.textWhite,
                                    fontWeight: MyntFonts.semiBold,
                                  ),
                                )),
                              )),
                        ),
                        if (positionData['qty'] != "0" && !positions.isDay) ...[
                          const SizedBox(width: 12),
                          Expanded(
                              child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                      color: MyntColors.loss,
                                      borderRadius: BorderRadius.circular(32)),
                                  width: MediaQuery.of(context).size.width,
                                  child: InkWell(
                                    onTap: () async {
                                      await ref
                                          .read(marketWatchProvider)
                                          .fetchScripInfo(
                                              "${positionData['token']}",
                                              '${positionData['exch']}',
                                              context,
                                              true);
                                      Navigator.pop(context);
                                      OrderScreenArgs orderArgs =
                                          OrderScreenArgs(
                                              exchange:
                                                  '${positionData['exch']}',
                                              tSym: '${positionData['tsym']}',
                                              isExit: false,
                                              token:
                                                  "${positionData['token']}",
                                              transType: int.parse(positionData[
                                                          'netqty']!) <
                                                      0
                                                  ? true
                                                  : false,
                                              lotSize: positionData['netqty'],
                                              ltp: positionData['lp'],
                                              perChange:
                                                  positionData['perChange'] ??
                                                      "0.00",
                                              orderTpye: '',
                                              holdQty:
                                                  '${positionData['netqty']}',
                                              isModify: false,
                                              raw: {});

                                      Navigator.pushNamed(
                                          context, Routes.placeOrderScreen,
                                          arguments: {
                                            "orderArg": orderArgs,
                                            "scripInfo": ref
                                                .read(marketWatchProvider)
                                                .scripInfoModel!,
                                            "isBskt": ""
                                          });
                                    },
                                    child: Center(
                                        child: Text(
                                      "Exit",
                                      style: MyntWebTextStyles.body(
                                        context,
                                        color: MyntColors.textWhite,
                                        fontWeight: MyntFonts.semiBold,
                                      ),
                                    )),
                                  )))
                        ]
                      ]),
                    )));
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    bool isHeader = false,
    required Color primaryColor,
    required Color secondaryColor,
    required Color dividerColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style: isHeader
                      ? MyntWebTextStyles.body(context,
                          color: primaryColor, fontWeight: MyntFonts.semiBold)
                      : MyntWebTextStyles.para(context,
                          color: secondaryColor, fontWeight: MyntFonts.medium),
                ),
                const SizedBox(height: 2),
                Text(
                  leftValue,
                  style: MyntWebTextStyles.body(
                    context,
                    color: primaryColor,
                    fontWeight: isHeader ? MyntFonts.semiBold : MyntFonts.medium,
                  ),
                ),
                const SizedBox(height: 2),
                Divider(color: dividerColor),
              ],
            ),
          ),
          const SizedBox(width: 27),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style: isHeader
                      ? MyntWebTextStyles.body(context,
                          color: primaryColor, fontWeight: MyntFonts.semiBold)
                      : MyntWebTextStyles.para(context,
                          color: secondaryColor, fontWeight: MyntFonts.medium),
                ),
                const SizedBox(height: 2),
                Text(
                  rightValue,
                  style: MyntWebTextStyles.body(
                    context,
                    color: primaryColor,
                    fontWeight: isHeader ? MyntFonts.semiBold : MyntFonts.medium,
                  ),
                ),
                const SizedBox(height: 2),
                Divider(color: dividerColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color primaryColor,
    required Color secondaryColor,
    required Color dividerColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MyntWebTextStyles.body(
            context,
            color: primaryColor,
            fontWeight: MyntFonts.medium,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: MyntWebTextStyles.body(
            context,
            color: primaryColor,
            fontWeight: MyntFonts.medium,
          ),
        ),
        const SizedBox(height: 2),
        Divider(color: dividerColor),
        const SizedBox(height: 4),
      ],
    );
  }
}

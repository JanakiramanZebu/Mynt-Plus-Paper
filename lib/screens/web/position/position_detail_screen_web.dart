import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/marketwatch_model/get_quotes.dart';

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../utils/responsive_navigation.dart';
import 'convert_position_dialogue_web.dart';

class PositionDetailScreenWeb extends ConsumerStatefulWidget {
  final PositionBookModel positionList;
  const PositionDetailScreenWeb({super.key, required this.positionList});

  @override
  ConsumerState<PositionDetailScreenWeb> createState() => _PositionDetailScreenWebState();
}

class _PositionDetailScreenWebState extends ConsumerState<PositionDetailScreenWeb> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final positions = ref.watch(portfolioProvider);
        final theme = ref.watch(themeProvider);
        final marketwatch = ref.watch(marketWatchProvider);

        return StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};

            DepthInputArgs depthArgs = DepthInputArgs(
              exch: widget.positionList.exch ?? "",
              token: widget.positionList.token ?? "",
              tsym: widget.positionList.tsym ?? '',
              instname: marketwatch.getQuotes?.instname ?? "",
              symbol: widget.positionList.symbol ?? '',
              expDate: widget.positionList.expDate ?? '',
              option: widget.positionList.option ?? '',
            );

            // Create a copy of position data for real-time updates
            PositionBookModel updatedPosition = widget.positionList;

            // Update position data with real-time values if available
            if (socketDatas.containsKey(widget.positionList.token)) {
              final lp = socketDatas["${widget.positionList.token}"]['lp']?.toString();
              final pc = socketDatas["${widget.positionList.token}"]['pc']?.toString();
              final chng = socketDatas["${widget.positionList.token}"]['chng']?.toString();
              final close = socketDatas["${widget.positionList.token}"]['c']?.toString();

              if (lp != null && lp != "null") {
                updatedPosition.lp = lp;
              }

              if (pc != null && pc != "null") {
                updatedPosition.perChange = pc;
              }

              if (chng != null && chng != "null") {
                updatedPosition.chng = chng;
              }

              // Calculate MTM/PNL values based on updated data
              if (updatedPosition.lp != null && updatedPosition.netqty != null) {
                final ltp = double.tryParse(updatedPosition.lp ?? "0.0") ?? 0.0;
                final qty = int.tryParse(updatedPosition.netqty ?? "0") ?? 0;
                final avgPrice = double.tryParse(updatedPosition.avgPrc ?? "0.0") ?? 0.0;

                if (ltp > 0 && qty != 0 && avgPrice > 0) {
                  final pnl = (ltp - avgPrice) * qty;
                  updatedPosition.profitNloss = pnl.toStringAsFixed(2);
                  updatedPosition.mTm = pnl.toStringAsFixed(2);
                }

                // Calculate change value if needed
                if ((updatedPosition.chng == null ||
                        updatedPosition.chng == "null" ||
                        updatedPosition.chng == "0" ||
                        updatedPosition.chng == "0.00") &&
                    ltp > 0 &&
                    close != null &&
                    close != "null") {
                  final closePrice = double.tryParse(close) ?? 0.0;
                  if (closePrice > 0) {
                    updatedPosition.chng = (ltp - closePrice).toStringAsFixed(2);
                  }
                }
              }
            }

            return Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                ),
              ),
              child: Column(
                children: [
                  // Header with close button
                  _buildHeader(theme),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Symbol and Price Section
                          _buildSymbolSection(theme, marketwatch, updatedPosition, depthArgs),
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          _buildActionButtons(theme, marketwatch, ref, updatedPosition),
                          const SizedBox(height: 24),
                          
                          // Convert Position Button
                          _buildConvertPositionButton(theme, updatedPosition),
                          const SizedBox(height: 24),
                          
                          // P&L/MTM Section
                          _buildPnLSection(theme, positions, updatedPosition),
                          const SizedBox(height: 24),
                          
                          // Details Section
                          _buildDetailsSection(theme, positions, updatedPosition),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Position Details',
            style: TextWidget.textStyle(
              fontSize: 18,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider marketwatch, PositionBookModel position, DepthInputArgs depthArgs) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(),
      child: InkWell(
        customBorder: RoundedRectangleBorder(),
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.1) : colors.primaryLight.withOpacity(0.1),
        highlightColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.2) : colors.primaryLight.withOpacity(0.2),
        onTap: () async {
          Navigator.pop(context);
          await marketwatch.scripdepthsize(false);
          await marketwatch.calldepthApis(context, depthArgs, "");
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol and Exchange
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${position.symbol?.replaceAll("-EQ", "")} ${position.expDate} ${position.option} ",
                    style: TextWidget.textStyle(
                      fontSize: 20,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      fw: 3,
                    ),
                  ),
                  CustomExchBadge(exch: "${position.exch}"),
                ],
              ),
              const SizedBox(height: 16),
              
              // Price and Change
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${position.lp}",
                          style: TextWidget.textStyle(
                            fontSize: 24,
                            theme: theme.isDarkMode,
                            color: (position.lp == "null" || position.lp == null) ||
                                    position.lp == "0.00"
                                ? theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight
                                : position.chng?.startsWith("-") ?? false
                                    ? theme.isDarkMode
                                        ? colors.lossDark
                                        : colors.lossLight
                                    : theme.isDarkMode
                                        ? colors.profitDark
                                        : colors.profitLight,
                            fw: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${double.parse("${position.chng ?? 0.00}").toStringAsFixed(2)} (${position.perChange ?? 0.00}%)",
                          style: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                            fw: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemesProvider theme, MarketWatchProvider marketwatch, WidgetRef ref, PositionBookModel position) {
    if (position.sPrdtAli == "BO" || position.sPrdtAli == "CO") {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (position.qty != "0" && !ref.read(portfolioProvider).isDay) ...[
          Expanded(
            child: _buildActionButton(
              "Exit",
              false,
              theme,
              () async {
                await marketwatch.fetchScripInfo(
                  "${position.token}",
                  '${position.exch}',
                  context,
                  true,
                );
                Navigator.pop(context);
                OrderScreenArgs orderArgs = OrderScreenArgs(
                  exchange: '${position.exch}',
                  tSym: '${position.tsym}',
                  isExit: true,
                  token: "${position.token}",
                  transType: int.parse(position.netqty!) < 0 ? true : false,
                  prd: '${position.prd}',
                  lotSize: position.netqty,
                  ltp: position.lp,
                  perChange: position.perChange ?? "0.00",
                  orderTpye: '',
                  holdQty: '${position.netqty}',
                  isModify: false,
                  raw: {},
                );

                ResponsiveNavigation.toPlaceOrderScreen(
                  context: context,
                  arguments: {
                    "orderArg": orderArgs,
                    "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
                    "isBskt": "",
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              "Add",
              true,
              theme,
              () async {
                await marketwatch.fetchScripInfo(
                  "${position.token}",
                  '${position.exch}',
                  context,
                  true,
                );
                int lotsize = int.parse(ref.read(marketWatchProvider).scripInfoModel!.ls.toString());
                Navigator.pop(context);
                OrderScreenArgs orderArgs = OrderScreenArgs(
                  exchange: '${position.exch}',
                  tSym: '${position.tsym}',
                  isExit: false,
                  token: "${position.token}",
                  transType: int.parse(position.netqty!) < 0 ? false : true,
                  prd: '${position.prd}',
                  lotSize: lotsize.toString(),
                  ltp: position.lp,
                  perChange: position.perChange ?? "0.00",
                  orderTpye: '',
                  holdQty: '${position.netqty}',
                  isModify: false,
                  raw: {},
                );

                ResponsiveNavigation.toPlaceOrderScreen(
                  context: context,
                  arguments: {
                    "orderArg": orderArgs,
                    "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
                    "isBskt": "",
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback onPressed) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? colors.primaryLight
              : (theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.6)
                  : colors.btnBg),
          foregroundColor: isPrimary
              ? colors.colorWhite
              : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
          side: isPrimary
              ? null
              : BorderSide(
                  color: colors.primaryLight,
                  width: 1,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextWidget.textStyle(
            fontSize: 14,
            theme: false,
            color: isPrimary ? colors.colorWhite : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
            fw: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildConvertPositionButton(ThemesProvider theme, PositionBookModel position) {
    if (position.qty == "0") {
      return const SizedBox.shrink();
    }

    return Center(
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConvertPositionDialogueWeb(convertPosition: position);
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colors.btnOutlinedBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assets.convertpositionicon,
                width: 16,
                height: 16,
                color: colors.btnOutlinedBorder,
              ),
              const SizedBox(width: 8),
              Text(
                "Convert Position",
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: false,
                  color: colors.primaryLight,
                  fw: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPnLSection(ThemesProvider theme, PortfolioProvider positions, PositionBookModel position) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            positions.isNetPnl ? "P&L" : "MTM",
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 3,
            ),
          ),
          Text(
            positions.isNetPnl
                ? "${position.profitNloss ?? position.rpnl}"
                : "${position.mTm}",
            style: TextWidget.textStyle(
              fontSize: 18,
              theme: false,
              color: _getPnLColor(positions, theme, position),
              fw: 3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPnLColor(PortfolioProvider positions, ThemesProvider theme, PositionBookModel position) {
    String value = positions.isNetPnl
        ? (position.profitNloss ?? position.rpnl ?? "0.00")
        : (position.mTm ?? "0.00");

    if (value.startsWith("-")) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else if (value == "0.00") {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    } else {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    }
  }

  Widget _buildDetailsSection(ThemesProvider theme, PortfolioProvider positions, PositionBookModel position) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Position Details',
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 3,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            "Net Qty",
            "${((int.tryParse(position.netqty.toString()) ?? 0) / (position.exch == 'MCX' ? (int.tryParse(position.ls.toString()) ?? 1) : 1)).toInt()}",
            theme,
          ),
          _buildInfoRow(
            "Avg Price",
            "${position.netupldprc ?? 0.00}",
            theme,
          ),
          _buildInfoRow(
            "Product",
            "${position.sPrdtAli ?? ""}",
            theme,
          ),
          _buildInfoRow(
            "Buy Qty ( Day / CF )",
            "${((int.tryParse(position.daybuyqty.toString()) ?? 0) / (position.exch == 'MCX' ? (int.tryParse(position.ls.toString()) ?? 1) : 1)).toInt()} / ${position.cfbuyqty}",
            theme,
          ),
          _buildInfoRow(
            "Sell Qty ( Day / CF )",
            "${((int.tryParse(position.daysellqty.toString()) ?? 0) / (position.exch == 'MCX' ? (int.tryParse(position.ls.toString()) ?? 1) : 1)).toInt()} / ${position.cfsellqty}",
            theme,
          ),
          _buildInfoRow(
            "Buy Avg prc ( Day / CF )",
            "${position.daybuyavgprc ?? 0.00} / ${position.cfbuyavgprc}",
            theme,
          ),
          _buildInfoRow(
            "Sell Avg prc ( Day / CF )",
            "${position.daysellavgprc ?? 0.00} / ${position.cfsellavgprc}",
            theme,
          ),
          _buildInfoRow(
            "Actual Avg Price",
            "${position.upldprc ?? 0.00}",
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: false,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              fw: 2,
            ),
          ),
          Text(
            value,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: false,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 2,
            ),
          ),
        ],
      ),
    );
  }
}

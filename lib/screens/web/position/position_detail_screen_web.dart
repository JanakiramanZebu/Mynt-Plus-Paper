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
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
 
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
              width: 700,
              // decoration: BoxDecoration(
              //   color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              //   borderRadius: BorderRadius.circular(16),
              //   border: Border.all(
              //     color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              //   ),
              // ),
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button


                  Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                    ),
                  ),
                ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          _buildSymbolSection(theme, marketwatch, updatedPosition, depthArgs),
                                        // const SizedBox(height: 24),
                        
                        Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.15)
                            : Colors.black.withOpacity(.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.08)
                            : Colors.black.withOpacity(.08),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                
                  
                   // Content
                   Flexible(
                     fit: FlexFit.loose,
                     child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Symbol and Price Section
                        
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: _buildPnLSection(theme, positions, updatedPosition),
                          ),
                          // Action Buttons
                          // _buildActionButtons(theme, marketwatch, ref, updatedPosition),
                          
                          // Convert Position Button
                          // _buildConvertPositionButton(theme, updatedPosition),
                          
                          // P&L/MTM Section
                          
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



  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider marketwatch, PositionBookModel position, DepthInputArgs depthArgs) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(),
      child: InkWell(
        customBorder: RoundedRectangleBorder(),
        borderRadius: BorderRadius.circular(0),
        splashColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.1) : colors.primaryLight.withOpacity(0.1),
        highlightColor: theme.isDarkMode ? colors.primaryDark.withOpacity(0.2) : colors.primaryLight.withOpacity(0.2),
        onTap: () async {
          Navigator.pop(context);
          await marketwatch.scripdepthsize(false);
          await marketwatch.calldepthApis(context, depthArgs, "");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol and Exchange
            Row(
              children: [
                Text(
                  "${position.symbol?.replaceAll("-EQ", "")} ${position.expDate} ${position.option} ",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 4),
                 Text(
                               "${position.exch}",
                               style: WebTextStyles.dialogTitle(
                                 isDarkTheme: theme.isDarkMode,
                                 color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                               ),
                             ),
              ],
            ),
            const SizedBox(height: 8),
           
            
              Row(
                children: [
                  Text(
                      "${position.lp}",
                      style: WebTextStyles.title(
                        isDarkTheme: theme.isDarkMode,
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
                        fontWeight: WebFonts.medium,
                      ),
                    ),
                    const SizedBox(width: 8), 

                     Text(
                  "${double.parse("${position.chng ?? 0.00}").toStringAsFixed(2)} (${position.perChange ?? 0.00}%)",
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    fontWeight: WebFonts.medium,
                  ),
                ),
                ],
              ),          
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemesProvider theme, MarketWatchProvider marketwatch, WidgetRef ref, PositionBookModel position) {
    if (position.sPrdtAli == "BO" || position.sPrdtAli == "CO") {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
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
      ),
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback onPressed) {
    return SizedBox(
      height: 40,
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
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: WebTextStyles.buttonXs(
            isDarkTheme: theme.isDarkMode,
            color: isPrimary ? colors.colorWhite : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
            fontWeight: WebFonts.semiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildConvertPositionButton(ThemesProvider theme, PositionBookModel position) {
    if (position.qty == "0") {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                borderRadius: BorderRadius.circular(5),
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
                    style: WebTextStyles.buttonXs(
                      isDarkTheme: theme.isDarkMode,
                      color: colors.primaryLight,
                      fontWeight: WebFonts.semiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPnLSection(ThemesProvider theme, PortfolioProvider positions, PositionBookModel position) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              positions.isNetPnl ? "P&L" : "MTM",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                fontWeight: WebFonts.medium,
              ),
            ),
            const SizedBox(height: 6),
             Text(
          positions.isNetPnl
              ? "${position.profitNloss ?? position.rpnl}"
              : "${position.mTm}",
          style: WebTextStyles.head(
            isDarkTheme: theme.isDarkMode,
            color: _getPnLColor(positions, theme, position),
            fontWeight: WebFonts.medium,
          ),
        ),
          ],
        ),
       
      ],
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
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column - First 4 items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.isDarkMode
                  ? WebDarkColors.divider
                  : WebColors.divider,
            ),
            // Right column - Last 4 items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
             color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

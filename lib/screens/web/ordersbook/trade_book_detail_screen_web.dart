import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order_book_model/trade_book_model.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../models/order_book_model/order_book_model.dart';

class TradeBookDetailScreenWeb extends ConsumerStatefulWidget {
  final TradeBookModel tradeData;

  const TradeBookDetailScreenWeb({
    super.key,
    required this.tradeData,
  });

  @override
  ConsumerState<TradeBookDetailScreenWeb> createState() => _TradeBookDetailScreenWebState();
}

class _TradeBookDetailScreenWebState extends ConsumerState<TradeBookDetailScreenWeb>
    with SingleTickerProviderStateMixin {
  late TradeBookModel _tradeData;
  late AnimationController _animationController;

  // Track processing states
  bool _isProcessingBuy = false;
  bool _isProcessingSell = false;

  @override
  void initState() {
    super.initState();
    // Make a copy of the trade data to avoid modifying the original
    _tradeData = _copyTradeData(widget.tradeData);

    // Set up animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Socket subscription is now handled by StreamBuilder
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Create a copy of the TradeBookModel to avoid modifying the original
  TradeBookModel _copyTradeData(TradeBookModel original) {
    final copy = TradeBookModel();
    copy.token = original.token;
    copy.exch = original.exch;
    copy.tsym = original.tsym;
    copy.symbol = original.symbol;
    copy.expDate = original.expDate;
    copy.option = original.option;
    copy.ltp = original.ltp;
    copy.perChange = original.perChange;
    copy.change = original.change;
    copy.trantype = original.trantype;
    copy.qty = original.qty;
    copy.avgprc = original.avgprc;
    copy.sPrdtAli = original.sPrdtAli;
    copy.norenordno = original.norenordno;
    copy.norentm = original.norentm;
    copy.flqty = original.flqty;
    copy.flprc = original.flprc;
    copy.flid = original.flid;
    copy.fltm = original.fltm;
    copy.prc = original.prc;
    copy.prcftr = original.prcftr;
    copy.fillshares = original.fillshares;
    copy.ls = original.ls;
    copy.ti = original.ti;
    copy.pp = original.pp;
    copy.exchTm = original.exchTm;
    copy.exchordid = original.exchordid;
    copy.dname = original.dname;
    copy.stat = original.stat;
    copy.emsg = original.emsg;
    copy.uid = original.uid;
    copy.actid = original.actid;
    copy.prctyp = original.prctyp;
    copy.ret = original.ret;
    copy.prd = original.prd;
    return copy;
  }

  // Helper method to check if a value is valid
  bool _isValidValue(String? value) {
    return value != null &&
        value != "null" &&
        value != "0" &&
        value != "0.0" &&
        value != "0.00";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(themeProvider);
        final marketwatch = ref.watch(marketWatchProvider);

        return StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};

            // Create a copy of trade data for real-time updates
            TradeBookModel updatedTradeData = _tradeData;

            // Update trade data with real-time values if available
            if (socketDatas.containsKey(_tradeData.token)) {
              final lp = socketDatas["${_tradeData.token}"]['lp']?.toString();
              final pc = socketDatas["${_tradeData.token}"]['pc']?.toString();
              final chng = socketDatas["${_tradeData.token}"]['chng']?.toString();

              if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
                updatedTradeData.ltp = lp;
              }

              if (pc != null && pc != "null" && pc != "0" && pc != "0.00") {
                updatedTradeData.perChange = pc;
              }

              if (chng != null && chng != "null") {
                updatedTradeData.change = chng;
              }
            }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 700,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Fixed Header
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
                    _buildSymbolSection(theme, marketwatch, updatedTradeData),
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
                      // Trade Value Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _buildTradeValueSection(theme, updatedTradeData),
                      ),
                      
                      // Trade Details Section
                      _buildTradeDetailsSection(theme, updatedTradeData),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            'Trade Details',
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

  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider marketwatch, TradeBookModel displayData) {
    DepthInputArgs depthArgs = DepthInputArgs(
      exch: displayData.exch ?? "",
      token: displayData.token ?? "",
      tsym: marketwatch.getQuotes?.tsym ?? '',
      instname: marketwatch.getQuotes?.instname ?? "",
      symbol: marketwatch.getQuotes?.symbol ?? '',
      expDate: marketwatch.getQuotes?.expDate ?? '',
      option: marketwatch.getQuotes?.option ?? '',
    );

    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(),
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
                  "${displayData.symbol?.replaceAll("-EQ", "") ?? ''} ${displayData.expDate ?? ''} ${displayData.option ?? ''} ",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "${displayData.exch}",
                  style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Price and Change
            Row(
              children: [
                Text(
                  displayData.ltp ?? displayData.prc ?? '0.00',
                  style: WebTextStyles.title(
                    isDarkTheme: theme.isDarkMode,
                    color: (displayData.change == "null" || displayData.change == null) ||
                            displayData.change == "0.00"
                        ? theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight
                        : (displayData.change?.startsWith("-") == true || displayData.perChange?.startsWith("-") == true)
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
                  "${(double.tryParse(displayData.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${displayData.perChange ?? '0.00'}%)",
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
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

  Widget _buildActionButtons(ThemesProvider theme, MarketWatchProvider marketwatch, TradeBookModel displayData) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            "Exit",
            false,
            theme,
            _isProcessingSell ? null : () => _handleSell(displayData),
            _isProcessingSell,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            "Add",
            true,
            theme,
            _isProcessingBuy ? null : () => _handleBuy(displayData),
            _isProcessingBuy,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, bool isPrimary, ThemesProvider theme, VoidCallback? onPressed, bool isLoading) {
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
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? colors.colorWhite : (theme.isDarkMode ? colors.colorWhite : colors.primaryLight),
                  ),
                ),
              )
            : Text(
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

  Widget _buildTradeValueSection(ThemesProvider theme, TradeBookModel displayData) {
    final tradeValue = _calculateTradeValue(displayData);
    final isProfit = tradeValue >= 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "Trade Value",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                fontWeight: WebFonts.medium,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "₹${tradeValue.toStringAsFixed(2)}",
              style: WebTextStyles.head(
                isDarkTheme: theme.isDarkMode,
                color: isProfit
                    ? theme.isDarkMode
                        ? colors.profitDark
                        : colors.profitLight
                    : theme.isDarkMode
                        ? colors.lossDark
                        : colors.lossLight,
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTradeDetailsSection(ThemesProvider theme, TradeBookModel displayData) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Transaction Type", displayData.trantype == "B" ? "Buy" : "Sell", theme),
                  _buildInfoRow("Quantity", displayData.qty ?? '0', theme),
                  _buildInfoRow("Price", displayData.avgprc ?? '0.00', theme),
                  _buildInfoRow("Product", displayData.sPrdtAli ?? '-', theme),
                  _buildInfoRow("Order Number", displayData.norenordno ?? '-', theme),
                  _buildInfoRow("Trade Time", displayData.norentm ?? "-", theme),
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
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Fill Quantity", displayData.flqty ?? '0', theme),
                  _buildInfoRow("Fill Price", displayData.flprc ?? '0.00', theme),
                  _buildInfoRow("Fill ID", displayData.flid ?? '-', theme),
                  _buildInfoRow("Fill Time", displayData.fltm ?? "-", theme),
                  _buildInfoRow("Fill Shares", displayData.fillshares ?? '0', theme),
                  _buildInfoRow("Product Type", displayData.prctyp ?? '-', theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, ThemesProvider theme, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: valueColor ?? (theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTradeValue(TradeBookModel tradeData) {
    try {
      final qty = double.tryParse(tradeData.qty?.toString() ?? "0") ?? 0.0;
      final price = double.tryParse(tradeData.avgprc?.toString() ?? "0") ?? 0.0;
      return qty * price;
    } catch (e) {
      return 0.0;
    }
  }

  // Action handlers
  Future<void> _handleBuy(TradeBookModel tradeData) async {
    if (_isProcessingBuy) return;

    try {
      setState(() {
        _isProcessingBuy = true;
      });

      final wsProvider = ref.read(websocketProvider);
      final mwProvider = ref.read(marketWatchProvider);

      wsProvider.establishConnection(
          channelInput: "${tradeData.exch}|${tradeData.token}#",
          task: "t",
          context: context);

      await mwProvider.fetchScripInfo(
          "${tradeData.token}", '${tradeData.exch}', context, true);

      if (!mounted) return;

      final OrderScreenArgs orderArgs = OrderScreenArgs(
          exchange: '${tradeData.exch}',
          tSym: '${tradeData.tsym}',
          token: '',
          transType: true,
          prd: '${tradeData.sPrdtAli}',
          lotSize: '1',
          orderTpye: "${tradeData.sPrdtAli}",
          isExit: false,
          ltp: '${tradeData.ltp}',
          perChange: '${tradeData.perChange}',
          holdQty: '',
          isModify: false,
          raw: {});

      if (mwProvider.scripInfoModel != null) {
        ResponsiveNavigation.toPlaceOrderScreen(context: context, arguments: {
          "orderArg": orderArgs,
          "scripInfo": mwProvider.scripInfoModel!,
          "isBskt": ""
        }).then((_) {
          if (mounted) {
            setState(() {
              _isProcessingBuy = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingBuy = false;
        });
      }
    }
  }

  Future<void> _handleSell(TradeBookModel tradeData) async {
    if (_isProcessingSell) return;

    try {
      setState(() {
        _isProcessingSell = true;
      });

      final wsProvider = ref.read(websocketProvider);
      final mwProvider = ref.read(marketWatchProvider);

      wsProvider.establishConnection(
          channelInput: "${tradeData.exch}|${tradeData.token}#",
          task: "t",
          context: context);

      await mwProvider.fetchScripInfo(
          "${tradeData.token}", '${tradeData.exch}', context, true);

      if (!mounted) return;

      final OrderScreenArgs orderArgs = OrderScreenArgs(
          exchange: '${tradeData.exch}',
          tSym: '${tradeData.tsym}',
          token: '',
          transType: false,
          lotSize: '1',
          isExit: true,
          ltp: '${tradeData.ltp}',
          perChange: '${tradeData.perChange}',
          orderTpye: "${tradeData.sPrdtAli}",
          holdQty: "${tradeData.qty ?? 0}",
          isModify: false,
          raw: {});

      if (mwProvider.scripInfoModel != null) {
        ResponsiveNavigation.toPlaceOrderScreen(context: context, arguments: {
          "orderArg": orderArgs,
          "scripInfo": mwProvider.scripInfoModel!,
          "isBskt": ""
        }).then((_) {
          if (mounted) {
            setState(() {
              _isProcessingSell = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingSell = false;
        });
      }
    }
  }
}

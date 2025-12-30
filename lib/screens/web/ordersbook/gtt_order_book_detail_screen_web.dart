import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/screens/web/ordersbook/modify_gtt_web.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../models/order_book_model/gtt_order_book.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';

class GttOrderBookDetailScreenWeb extends ConsumerStatefulWidget {
  final GttOrderBookModel gttOrder;

  const GttOrderBookDetailScreenWeb({
    super.key,
    required this.gttOrder,
  });

  @override
  ConsumerState<GttOrderBookDetailScreenWeb> createState() => _GttOrderBookDetailScreenWebState();
}

class _GttOrderBookDetailScreenWebState extends ConsumerState<GttOrderBookDetailScreenWeb>
    with SingleTickerProviderStateMixin {
  late GttOrderBookModel _gttOrder;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _gttOrder = _copyGttOrderData(widget.gttOrder);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  GttOrderBookModel _copyGttOrderData(GttOrderBookModel original) {
    final copy = GttOrderBookModel();
    copy.stat = original.stat;
    copy.emsg = original.emsg;
    copy.aiT = original.aiT;
    copy.alId = original.alId;
    copy.tsym = original.tsym;
    copy.exch = original.exch;
    copy.token = original.token;
    copy.remarks = original.remarks;
    copy.validity = original.validity;
    copy.norentm = original.norentm;
    copy.pp = original.pp;
    copy.ls = original.ls;
    copy.ti = original.ti;
    copy.brkname = original.brkname;
    copy.actid = original.actid;
    copy.trantype = original.trantype;
    copy.prctyp = original.prctyp;
    copy.qty = original.qty;
    copy.prc = original.prc;
    copy.c = original.c;
    copy.prd = original.prd;
    copy.ordersource = original.ordersource;
    copy.placeOrderParams = original.placeOrderParams;
    copy.placeOrderParamsLeg2 = original.placeOrderParamsLeg2;
    copy.d = original.d;
    copy.oivariable = original.oivariable;
    copy.symbol = original.symbol;
    copy.expDate = original.expDate;
    copy.option = original.option;
    copy.ltp = original.ltp;
    copy.open = original.open;
    copy.high = original.high;
    copy.close = original.close;
    copy.low = original.low;
    copy.change = original.change;
    copy.perChange = original.perChange;
    copy.gttOrderCurrentStatus = original.gttOrderCurrentStatus;
    copy.ordDate = original.ordDate;
    return copy;
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

            GttOrderBookModel updatedGttOrder = _gttOrder;

            if (socketDatas.containsKey(_gttOrder.token)) {
              final lp = socketDatas["${_gttOrder.token}"]['lp']?.toString();
              final pc = socketDatas["${_gttOrder.token}"]['pc']?.toString();
              final chng = socketDatas["${_gttOrder.token}"]['chng']?.toString();

              if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
                updatedGttOrder.ltp = lp;
              }

              if (pc != null && pc != "null" && pc != "0" && pc != "0.00") {
                updatedGttOrder.perChange = pc;
              }

              if (chng != null && chng != "null") {
                updatedGttOrder.change = chng;
              }
            }

            return Dialog(
               backgroundColor: Colors.transparent,
              child: Container(
               width: 500,           
                decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(5),
        ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [

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
                       _buildSymbolSection(theme, marketwatch, updatedGttOrder),
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
                          
                            
                            // Action Buttons
                            // _buildActionButtons(theme, updatedGttOrder, marketwatch),
                            // const SizedBox(height: 24),
                            
                            // Order Parameters Section
                            _buildOrderParametersSection(theme, updatedGttOrder),
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
            'GTT Order Details',
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

  Widget _buildSymbolSection(ThemesProvider theme, MarketWatchProvider marketwatch, GttOrderBookModel displayData) {
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
                  "${displayData.symbol?.replaceAll("-EQ", "").toUpperCase() ?? ''} ${displayData.expDate ?? ''} ${displayData.option ?? ''} ",
                 style: WebTextStyles.dialogTitle(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                ),

                 const SizedBox(width: 4),
                Text(
                  displayData.exch ?? '',
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
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    theme: false,
                    color: (displayData.change == "null" || displayData.change == null) || displayData.change == "0.00"
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
                    fw: 1,
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

  Widget _buildActionButtons(ThemesProvider theme, GttOrderBookModel gttOrder, MarketWatchProvider marketwatch) {
    return Row(
      children: [
        Expanded(
          child: _buildCancelOrderButton(theme, gttOrder),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModifyOrderButton(theme, gttOrder, marketwatch),
        ),
      ],
    );
  }

  Widget _buildCancelOrderButton(ThemesProvider theme, GttOrderBookModel gttOrder) {
    return SizedBox(
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.6) : colors.primaryLight,
            width: 1,
          ),
          color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.6) : colors.btnBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () async {
              if (ref.read(orderProvider).loading) return;
              
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    backgroundColor: theme.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF1F3F8),
                    titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    scrollable: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
                    insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () async {
                                  await Future.delayed(const Duration(milliseconds: 150));
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                                highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget.subText(
                              text: "${_gttOrder.tsym?.replaceAll("-EQ", "")} ${_gttOrder.expDate ?? ''} ${_gttOrder.option ?? ''}",
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                              fw: 3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: TextWidget.subText(
                              text: "Do you want to Cancel this order?",
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                              fw: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            await ref.read(orderProvider).cancelGttOrder(
                              "${_gttOrder.alId}",
                              context,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 45),
                            side: BorderSide(color: colors.btnOutlinedBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: colors.primaryDark,
                          ),
                          child: TextWidget.titleText(
                            text: "Cancel",
                            color: colors.colorWhite,
                            theme: theme.isDarkMode,
                            fw: 2,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Center(
              child: ref.read(orderProvider).loading
                  ? SizedBox(
                      width: 18,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.isDarkMode ? colors.colorWhite : colors.primaryDark,
                      ),
                    )
                  : Text(
                      "Cancel Order",
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode ? colors.colorWhite : colors.primaryLight,
                        fw: 2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModifyOrderButton(ThemesProvider theme, GttOrderBookModel gttOrder, MarketWatchProvider marketwatch) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: colors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () async {
              await marketwatch.fetchScripInfo(
                "${gttOrder.token}",
                "${gttOrder.exch}",
                context,
              );
              
              if (!mounted) return;
              
              Navigator.pop(context);
              
              ModifyGttWeb.showDraggable(
                context: context,
                gttOrderBook: _gttOrder,
                scripInfo: marketwatch.scripInfoModel!,
              );
            },
            child: Center(
              child: Text(
                "Modify Order",
                style: TextWidget.textStyle(
                  fontSize: 14,
                  theme: theme.isDarkMode,
                  color: colors.colorWhite,
                  fw: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderParametersSection(ThemesProvider theme, GttOrderBookModel displayData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayData.placeOrderParams != null) ...[
          _buildInfoRow(
            "${displayData.placeOrderParams?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger",
            displayData.oivariable?.isNotEmpty == true ? "${displayData.oivariable?.first.d}" : displayData.d ?? "-",
            theme,
          ),
          _buildInfoRow(
            "Product",
            displayData.placeOrderParams?.prd == "C"
                ? "CNC"
                : displayData.placeOrderParams?.prd == "I"
                    ? "MIS"
                    : displayData.placeOrderParams?.prd == "M"
                        ? "NRML"
                        : "-",
            theme,
          ),
          _buildInfoRow(
            "Order Type",
            "${displayData.placeOrderParams?.prctyp}",
            theme,
          ),
          _buildInfoRow(
            "Qty",
            "${displayData.placeOrderParams?.qty}",
            theme,
          ),
          _buildInfoRow(
            "Price",
            displayData.placeOrderParams?.prctyp == "MKT" ? "MKT" : "${displayData.placeOrderParams?.prc}",
            theme,
          ),
        ],
        if (displayData.placeOrderParamsLeg2 != null) ...[
          const SizedBox(height: 24),
          Text(
            "${displayData.placeOrderParamsLeg2?.trantype == 'B' ? 'Buy' : 'Sell'} Trigger @ ${displayData.oivariable?.isNotEmpty == true ? displayData.oivariable?.last.d ?? '' : '-'}",
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            "Product",
            displayData.placeOrderParamsLeg2?.prd == "C"
                ? "CNC"
                : displayData.placeOrderParamsLeg2?.prd == "I"
                    ? "MIS"
                    : displayData.placeOrderParamsLeg2?.prd == "M"
                        ? "NRML"
                        : "-",
            theme,
          ),
          _buildInfoRow(
            "Order Type",
            "${displayData.placeOrderParamsLeg2?.prctyp}",
            theme,
          ),
          _buildInfoRow( 
            "Qty",
            "${displayData.placeOrderParamsLeg2?.qty}",
            theme,
          ),
          _buildInfoRow(
            "Price",
            displayData.placeOrderParamsLeg2?.prctyp == "MKT" ? "MKT" : "${displayData.placeOrderParamsLeg2?.prc}",
            theme,
          ),
        ],
        if (displayData.remarks != null && displayData.remarks != "") ...[
          const SizedBox(height: 24),
          Text(
            "Remarks",
            style: TextWidget.textStyle(
              fontSize: 16,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${displayData.remarks}",
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 0,
            ),
          ),
        ],
      ],
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
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


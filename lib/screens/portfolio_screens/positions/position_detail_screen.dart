import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/screens/market_watch/futures/future_screen.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../market_watch/scrip_depth_info.dart';
import 'convert_position_dialogue.dart';

class PositionDetailScreen extends ConsumerStatefulWidget {
  final PositionBookModel positionList;
  const PositionDetailScreen({super.key, required this.positionList});

  @override
  ConsumerState<PositionDetailScreen> createState() =>
      _PositionDetailScreenState();
}

class _PositionDetailScreenState extends ConsumerState<PositionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 400) {
          Navigator.of(context).pop();
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.05,
        maxChildSize: 0.99,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, _) {
              final positions = ref.watch(portfolioProvider);
              final theme = ref.read(themeProvider);
              final marketwatch = ref.watch(marketWatchProvider);

              DepthInputArgs depthArgs = DepthInputArgs(
                  exch: widget.positionList.exch ?? "",
                  token: widget.positionList.token ?? "",
                  tsym: marketwatch.getQuotes!.tsym ?? '',
                  instname: marketwatch.getQuotes!.instname ?? "",
                  symbol: marketwatch.getQuotes!.symbol ?? '',
                  expDate: marketwatch.getQuotes!.expDate ?? '',
                  option: marketwatch.getQuotes!.option ?? '');

              return StreamBuilder<Map>(
                stream: ref.watch(websocketProvider).socketDataStream,
                builder: (context, snapshot) {
                  final socketDatas = snapshot.data ?? {};

                  // Update position data with real-time values if available
                  if (socketDatas.containsKey(widget.positionList.token)) {
                    final lp = socketDatas["${widget.positionList.token}"]['lp']
                        ?.toString();
                    final pc = socketDatas["${widget.positionList.token}"]['pc']
                        ?.toString();
                    final chng = socketDatas["${widget.positionList.token}"]
                            ['chng']
                        ?.toString();
                    final close = socketDatas["${widget.positionList.token}"]
                            ['c']
                        ?.toString();

                    if (lp != null && lp != "null") {
                      widget.positionList.lp = lp;
                    }

                    if (pc != null && pc != "null") {
                      widget.positionList.perChange = pc;
                    }

                    if (chng != null && chng != "null") {
                      widget.positionList.chng = chng;
                    }

                    // Calculate MTM/PNL values based on updated data
                    if (widget.positionList.lp != null &&
                        widget.positionList.netqty != null) {
                      final ltp =
                          double.tryParse(widget.positionList.lp ?? "0.0") ??
                              0.0;
                      final qty =
                          int.tryParse(widget.positionList.netqty ?? "0") ?? 0;
                      final avgPrice = double.tryParse(
                              widget.positionList.avgPrc ?? "0.0") ??
                          0.0;

                      if (ltp > 0 && qty != 0 && avgPrice > 0) {
                        final pnl = (ltp - avgPrice) * qty;
                        widget.positionList.profitNloss =
                            pnl.toStringAsFixed(2);
                        widget.positionList.mTm = pnl.toStringAsFixed(2);
                      }

                      // Calculate change value if needed
                      if ((widget.positionList.chng == null ||
                              widget.positionList.chng == "null" ||
                              widget.positionList.chng == "0" ||
                              widget.positionList.chng == "0.00") &&
                          ltp > 0 &&
                          close != null &&
                          close != "null") {
                        final closePrice = double.tryParse(close) ?? 0.0;
                        if (closePrice > 0) {
                          widget.positionList.chng =
                              (ltp - closePrice).toStringAsFixed(2);
                        }
                      }
                    }
                  }

                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Container(
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  const CustomDragHandler(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        Material(
                                          color: Colors.transparent,
                                          shape: const BeveledRectangleBorder(),
                                          child: InkWell(
                                            customBorder:
                                                const BeveledRectangleBorder(),
                                            splashColor: theme.isDarkMode
                                                ? colors.splashColorDark
                                                : colors.splashColorLight,
                                            highlightColor: theme.isDarkMode
                                                ? colors.highlightDark
                                                : colors.highlightLight,
                                            onTap: () async {
                                              await marketwatch
                                                  .scripdepthsize(true);
                                              await marketwatch.calldepthApis(
                                                  context, depthArgs, "");
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextWidget.headText(
                                                          text:
                                                              "${widget.positionList.symbol?.replaceAll("-EQ", "")} ${widget.positionList.expDate} ${widget.positionList.option} ",
                                                          fw: 0,
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textPrimaryDark
                                                              : colors
                                                                  .textPrimaryLight,
                                                          theme: false,
                                                        ),
                                                        // TextWidget.subText(
                                                        //   text:
                                                        //       "${widget.positionList.expDate}",
                                                        //   fw: 3,
                                                        //   color: theme.isDarkMode
                                                        //       ?  colors
                                                        //           .textPrimaryDark
                                                        //       : colors
                                                        //           .textPrimaryLight,
                                                        //   theme: false,
                                                        // ),
                                                        // TextWidget.subText(
                                                        //   text:
                                                        //       "${widget.positionList.option} ",
                                                        //   fw: 3,
                                                        //   color: theme.isDarkMode
                                                        //       ?  colors
                                                        //           .textPrimaryDark
                                                        //       : colors
                                                        //           .textPrimaryLight,
                                                        //   theme: false,
                                                        //   textOverflow:
                                                        //       TextOverflow
                                                        //           .ellipsis,
                                                        // ),
                                                        CustomExchBadge(
                                                            exch:
                                                                "${widget.positionList.exch}"),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    TextWidget.titleText(
                                                      text:
                                                          "${widget.positionList.lp}",
                                                      fw: 3,
                                                      color: (widget.positionList
                                                                          .lp ==
                                                                      "null" ||
                                                                  widget.positionList
                                                                          .lp ==
                                                                      null) ||
                                                              widget.positionList
                                                                      .lp ==
                                                                  "0.00"
                                                          ? colors
                                                              .textSecondaryLight
                                                          : widget.positionList
                                                                      .chng
                                                                      ?.startsWith(
                                                                          "-") ??
                                                                  false
                                                              ? theme.isDarkMode
                                                                  ? colors
                                                                      .lossDark
                                                                  : colors
                                                                      .lossLight
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .profitDark
                                                                  : colors
                                                                      .profitLight,
                                                      theme: false,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    TextWidget.paraText(
                                                      text:
                                                          "${double.parse("${widget.positionList.chng ?? 0.00}").toStringAsFixed(2)} (${widget.positionList.perChange ?? 0.00}%)",
                                                      fw: 3,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      // (widget.positionList
                                                      //                     .chng ==
                                                      //                 "null" ||
                                                      //             widget.positionList
                                                      //                     .chng ==
                                                      //                 null) ||
                                                      //         widget.positionList
                                                      //                 .chng ==
                                                      //             "0.00"
                                                      //     ? colors.ltpgrey
                                                      //     : widget.positionList
                                                      //                 .chng!
                                                      //                 .startsWith(
                                                      //                     "-") ||
                                                      //             widget
                                                      //                 .positionList
                                                      //                 .perChange!
                                                      //                 .startsWith(
                                                      //                     "-")
                                                      //         ? colors.darkred
                                                      //         : colors
                                                      //             .ltpgreen,
                                                      theme: false,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      height: 45,
                                                      width: 26,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7),
                                                      child: SvgPicture.asset(
                                                        assets.rightarrowcur,
                                                        width: 12,
                                                        height: 12,
                                                        color: colors.iconColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 4),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        if (widget.positionList.sPrdtAli !=
                                                "BO" &&
                                            widget.positionList.sPrdtAli !=
                                                "CO")
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (widget.positionList.qty !=
                                                      "0" &&
                                                  !positions.isDay) ...[
                                                Expanded(
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: theme.isDarkMode
                                                            ? colors.colorGrey
                                                            : colors
                                                                .primaryLight,
                                                      ),
                                                      color: const Color(
                                                          0xffF1F3F8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      shape:
                                                          const BeveledRectangleBorder(),
                                                      child: InkWell(
                                                        customBorder:
                                                            const BeveledRectangleBorder(),
                                                        splashColor: theme
                                                                .isDarkMode
                                                            ? colors
                                                                .splashColorDark
                                                            : colors
                                                                .splashColorLight,
                                                        highlightColor: theme
                                                                .isDarkMode
                                                            ? colors
                                                                .highlightDark
                                                            : colors
                                                                .highlightLight,
                                                        onTap: () async {
                                                          await ref
                                                              .read(
                                                                  marketWatchProvider)
                                                              .fetchScripInfo(
                                                                "${widget.positionList.token}",
                                                                '${widget.positionList.exch}',
                                                                context,
                                                                true,
                                                              );
                                                          Navigator.pop(
                                                              context);
                                                          OrderScreenArgs
                                                              orderArgs =
                                                              OrderScreenArgs(
                                                            exchange:
                                                                '${widget.positionList.exch}',
                                                            tSym:
                                                                '${widget.positionList.tsym}',
                                                            isExit: true,
                                                            token:
                                                                "${widget.positionList.token}",
                                                            transType: int.parse(widget
                                                                        .positionList
                                                                        .netqty!) <
                                                                    0
                                                                ? true
                                                                : false,
                                                            prd:
                                                                '${widget.positionList.prd}',
                                                            lotSize: widget
                                                                .positionList
                                                                .netqty,
                                                            ltp: widget
                                                                .positionList
                                                                .lp,
                                                            perChange: widget
                                                                    .positionList
                                                                    .perChange ??
                                                                "0.00",
                                                            orderTpye: '',
                                                            holdQty:
                                                                '${widget.positionList.netqty}',
                                                            isModify: false,
                                                            raw: {},
                                                          );

                                                          Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .placeOrderScreen,
                                                              arguments: {
                                                                "orderArg":
                                                                    orderArgs,
                                                                "scripInfo": ref
                                                                    .read(
                                                                        marketWatchProvider)
                                                                    .scripInfoModel!,
                                                                "isBskt": "",
                                                              });
                                                        },
                                                        child: Center(
                                                          child: TextWidget
                                                              .subText(
                                                            text: "Exit",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .primaryDark
                                                                : colors
                                                                    .primaryLight,
                                                            fw: 0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                              ],
                                              if (widget.positionList.qty !=
                                                      "0" &&
                                                  !positions.isDay) ...[
                                                Expanded(
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          colors.primaryLight,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      // border: Border.all(
                                                      //   color: colors
                                                      //       .btnOutlinedBorder,
                                                      //   width: 1,
                                                      // ),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      shape:
                                                          const BeveledRectangleBorder(),
                                                      child: InkWell(
                                                        customBorder:
                                                            const BeveledRectangleBorder(),
                                                        splashColor: theme
                                                                .isDarkMode
                                                            ? colors
                                                                .splashColorDark
                                                            : colors
                                                                .splashColorLight,
                                                        highlightColor: theme
                                                                .isDarkMode
                                                            ? colors
                                                                .highlightDark
                                                            : colors
                                                                .highlightLight,
                                                        onTap: () async {
                                                          await ref
                                                              .read(
                                                                  marketWatchProvider)
                                                              .fetchScripInfo(
                                                                "${widget.positionList.token}",
                                                                '${widget.positionList.exch}',
                                                                context,
                                                                true,
                                                              );
                                                          int lotsize = int.parse(ref
                                                              .read(
                                                                  marketWatchProvider)
                                                              .scripInfoModel!
                                                              .ls
                                                              .toString());
                                                          Navigator.pop(
                                                              context);
                                                          OrderScreenArgs
                                                              orderArgs =
                                                              OrderScreenArgs(
                                                            exchange:
                                                                '${widget.positionList.exch}',
                                                            tSym:
                                                                '${widget.positionList.tsym}',
                                                            isExit: false,
                                                            token:
                                                                "${widget.positionList.token}",
                                                            transType: int.parse(widget
                                                                        .positionList
                                                                        .netqty!) <
                                                                    0
                                                                ? false
                                                                : true,
                                                            prd:
                                                                '${widget.positionList.prd}',
                                                            lotSize: lotsize
                                                                .toString(),
                                                            ltp: widget
                                                                .positionList
                                                                .lp,
                                                            perChange: widget
                                                                    .positionList
                                                                    .perChange ??
                                                                "0.00",
                                                            orderTpye: '',
                                                            holdQty:
                                                                '${widget.positionList.netqty}',
                                                            isModify: false,
                                                            raw: {},
                                                          );

                                                          Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .placeOrderScreen,
                                                              arguments: {
                                                                "orderArg":
                                                                    orderArgs,
                                                                "scripInfo": ref
                                                                    .read(
                                                                        marketWatchProvider)
                                                                    .scripInfoModel!,
                                                                "isBskt": "",
                                                              });
                                                        },
                                                        child: Center(
                                                          child: TextWidget
                                                              .subText(
                                                            text: "Add",
                                                            theme: false,
                                                            color: colors
                                                                .colorWhite,
                                                            fw: 0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                            // ],
                                          ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                  // ScripInfoBtns(
                                  //   exch: '${widget.positionList.exch}',
                                  //   token: '${widget.positionList.token}',
                                  //   insName: '',
                                  //   tsym: '${widget.positionList.tsym}',
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              shape:
                                                  const BeveledRectangleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const BeveledRectangleBorder(),
                                                splashColor: theme.isDarkMode
                                                    ? colors.splashColorDark
                                                    : colors.splashColorLight,
                                                highlightColor: theme.isDarkMode
                                                    ? colors.highlightDark
                                                    : colors.highlightLight,
                                                onTap: () {
                                                  if (widget.positionList.qty !=
                                                      "0") {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ConvertPositionDialogue(
                                                            convertPosition: widget
                                                                .positionList);
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Center(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        assets
                                                            .convertpositionicon,
                                                        width: 14,
                                                        height: 14,
                                                        color: colors
                                                            .btnOutlinedBorder,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      TextWidget.subText(
                                                        text:
                                                            "Convert Position",
                                                        fw: 2,
                                                        color:
                                                            colors.primaryLight,
                                                        theme: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 25),
                                        // const SizedBox(height: 10),
                                        // TextWidget.titleText(
                                        //   text: "Details",
                                        //   color: theme.isDarkMode
                                        //       ? colors.colorWhite
                                        //       : const Color(0xff666666),
                                        //   fw: 1,
                                        //   theme: false,
                                        // ),
                                        // const SizedBox(height: 24),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget.subText(
                                              text: positions.isNetPnl
                                                  ? "P&L"
                                                  : "MTM",
                                              fw: 3,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              theme: false,
                                            ),
                                            if (positions.isNetPnl)
                                              TextWidget.titleText(
                                                text:
                                                    "${widget.positionList.profitNloss ?? widget.positionList.rpnl}",
                                                theme: false,
                                                color: widget.positionList
                                                            .profitNloss !=
                                                        null
                                                    ? widget.positionList
                                                            .profitNloss!
                                                            .startsWith("-")
                                                        ? theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight
                                                        : widget.positionList
                                                                    .profitNloss ==
                                                                "0.00"
                                                            ? colors
                                                                .textSecondaryLight
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .successDark
                                                                : colors
                                                                    .successLight
                                                    : widget.positionList.rpnl!
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : widget.positionList
                                                                    .rpnl ==
                                                                "0.00"
                                                            ? colors
                                                                .textSecondaryLight
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .successDark
                                                                : colors
                                                                    .successLight,
                                                fw: 3,
                                              )
                                            else
                                              TextWidget.titleText(
                                                text:
                                                    "${widget.positionList.mTm}",
                                                color: widget.positionList.mTm!
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : widget.positionList.mTm ==
                                                            "0.00"
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen,
                                                fw: 3,
                                                theme: false,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                            thickness: 0,
                                            color: theme.isDarkMode
                                                ? colors.dividerDark
                                                : colors.dividerLight),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Net Qty",
                                            "${((int.tryParse(widget.positionList.netqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Avg Price",
                                            "${widget.positionList.netupldprc ?? 0.00}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Product",
                                            "${widget.positionList.sPrdtAli ?? ""}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Buy Qty ( Day / CF )",
                                            "${((int.tryParse(widget.positionList.daybuyqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()} / ${widget.positionList.cfbuyqty}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Sell Qty ( Day / CF )",
                                            "${((int.tryParse(widget.positionList.daysellqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()} / ${widget.positionList.cfsellqty}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Buy Avg prc ( Day / CF )",
                                            "${widget.positionList.daybuyavgprc ?? 0.00} / ${widget.positionList.cfbuyavgprc}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Sell Avg prc ( Day / CF )",
                                            "${widget.positionList.daysellavgprc ?? 0.00} / ${widget.positionList.cfsellavgprc}",
                                            theme),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Actual Avg Price",
                                            "${widget.positionList.upldprc ?? 0.00}",
                                            theme),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
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
        },
      ),
    );
  }

  Widget _buildInfoRow(String title1, String value1, ThemesProvider theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              text: title1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
          TextWidget.subText(
              text: value1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 3),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0)
    ]);
  }
}

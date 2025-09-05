import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/chart_provider.dart';
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
              final depthData = ref.watch(marketWatchProvider).getQuotes!;
              final scripInfo = ref.watch(marketWatchProvider);
              final userProfile = ref.watch(userProfileProvider);

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
                        children: <Widget>[
                          const CustomDragHandler(),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Material(
                                              color: Colors
                                                  .transparent, // Important to allow splash visibility
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                splashColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.15)
                                                    : Colors.black
                                                        .withOpacity(0.15),
                                                highlightColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.08)
                                                    : Colors.black
                                                        .withOpacity(0.08),
                                                onTap: () async {
                                                  await scripInfo
                                                      .chngDephBtn("Overview");

                                                  if (!mounted) return;

                                                  await Navigator.pushNamed(
                                                    context,
                                                    Routes.setAlertScreen,
                                                    arguments: {
                                                      "depthdata": depthData,
                                                      "wlvalue": depthArgs,
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle),
                                                  child: SvgPicture.asset(
                                                    assets.bellIcon,
                                                    width: 18,
                                                    height: 18,
                                                    color: Color(0xFF0037B7),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextWidget.titleText(
                                              text:
                                                  "${widget.positionList.symbol}",
                                              fw: 0,
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              theme: false,
                                            ),
                                            // CustomExchBadge(
                                            //     exch:
                                            //         "${widget.positionList.exch}"),
                                            TextWidget.subText(
                                              text:
                                                  "  ${widget.positionList.expDate}",
                                              fw: 3,
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : const Color(0xff666666),
                                              theme: false,
                                            ),
                                            TextWidget.subText(
                                              text:
                                                  " ${widget.positionList.option} ",
                                              fw: 3,
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : const Color(0xff666666),
                                              theme: false,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 6),
                                    child: Column(
                                      // mainAxisAlignment:
                                      //     widget.positionList.sPrdtAli == "BO" ||
                                      //             widget.positionList.sPrdtAli ==
                                      //                 "CO" ||
                                      //             widget.positionList.sPrdtAli ==
                                      //                 "MTF"
                                      //         ? MainAxisAlignment.start
                                      //         : MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.titleText(
                                              text: "${widget.positionList.lp}",
                                              fw: 1,
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              theme: false,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            TextWidget.paraText(
                                              text:
                                                  "${double.parse("${widget.positionList.chng ?? 0.00}").toStringAsFixed(2)} (${widget.positionList.perChange ?? 0.00}%)",
                                              fw: 0,
                                              color: (widget.positionList
                                                                  .chng ==
                                                              "null" ||
                                                          widget.positionList
                                                                  .chng ==
                                                              null) ||
                                                      widget.positionList
                                                              .chng ==
                                                          "0.00"
                                                  ? colors.ltpgrey
                                                  : widget.positionList.chng!
                                                              .startsWith(
                                                                  "-") ||
                                                          widget.positionList
                                                              .perChange!
                                                              .startsWith("-")
                                                      ? colors.darkred
                                                      : colors.ltpgreen,
                                              theme: false,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (widget.positionList.sPrdtAli !=
                                                "BO" &&
                                            widget.positionList.sPrdtAli !=
                                                "CO")
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xffFF1717),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: InkWell(
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
                                                      Navigator.pop(context);
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
                                                        lotSize:
                                                            lotsize.toString(),
                                                        ltp: widget
                                                            .positionList.lp,
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
                                                      child: TextWidget.subText(
                                                        text: "Add More",
                                                        theme: false,
                                                        color: const Color(
                                                            0xffFFFFFF),
                                                        fw: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // if (widget.positionList.qty !=
                                              //         "0" &&
                                              //     !positions.isDay) ...[
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: theme.isDarkMode
                                                          ? colors.colorGrey
                                                          : const Color(
                                                              0xff0037B7),
                                                    ),
                                                    color:
                                                        const Color(0xffF1F3F8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: InkWell(
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
                                                      Navigator.pop(context);
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
                                                            .positionList.lp,
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
                                                      child: TextWidget.subText(
                                                        text: "Exit",
                                                        theme: false,
                                                        color: const Color(
                                                            0xff0037B7),
                                                        fw: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            // ],
                                          ),
                                        const SizedBox(height: 16),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextWidget.paraText(
                                              text: positions.isNetPnl
                                                  ? "P&L"
                                                  : "MTM",
                                              fw: 0,
                                              color: const Color(0xff0037B7),
                                              theme: false,
                                            ),
                                            const SizedBox(height: 6),
                                            if (positions.isNetPnl)
                                              TextWidget.headText(
                                                text:
                                                    "${widget.positionList.profitNloss ?? widget.positionList.rpnl}",
                                                theme: false,
                                                color: widget.positionList
                                                            .profitNloss !=
                                                        null
                                                    ? widget.positionList
                                                            .profitNloss!
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : widget.positionList
                                                                    .profitNloss ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen
                                                    : widget.positionList.rpnl!
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : widget.positionList
                                                                    .rpnl ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen,
                                                fw: 0,
                                              )
                                            else
                                              TextWidget.headText(
                                                text:
                                                    "${widget.positionList.mTm}",
                                                color: widget.positionList.mTm!
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : widget.positionList.mTm ==
                                                            "0.00"
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen,
                                                fw: 0,
                                                theme: false,
                                              ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  // ScripInfoBtns(
                                  //   exch: '${widget.positionList.exch}',
                                  //   token: '${widget.positionList.token}',
                                  //   insName: '',
                                  //   tsym: '${widget.positionList.tsym}',
                                  // ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // const SizedBox(height: 10),
                                        // TextWidget.titleText(
                                        //   text: "Position details",
                                        //   color: theme.isDarkMode
                                        //       ? colors.colorWhite
                                        //       : colors.colorBlack,
                                        //   fw: 1,
                                        //   theme: false,
                                        // ),
                                        const SizedBox(height: 25),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextWidget.paraText(
                                                      text: "NET QTY",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${((int.tryParse(widget.positionList.netqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  const SizedBox(height: 8),
                                                  TextWidget.paraText(
                                                      text: "BUY QTY",
                                                      theme: false,
                                                      color: const Color(
                                                          0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${((int.tryParse(widget.positionList.daybuyqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  const SizedBox(height: 8),
                                                  TextWidget.paraText(
                                                      text: "SELL QTY",
                                                      theme: false,
                                                      fw: 0,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666)),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${((int.tryParse(widget.positionList.daysellqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  const SizedBox(height: 8),
                                                  TextWidget.paraText(
                                                      text: "CARRY FORWARD QTY",
                                                      theme: false,
                                                      fw: 0,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666)),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text: (int.tryParse(widget
                                                                          .positionList
                                                                          .cfbuyqty ??
                                                                      "0") ??
                                                                  0) >
                                                              0
                                                          ? "${widget.positionList.cfbuyqty}"
                                                          : (int.tryParse(widget
                                                                              .positionList
                                                                              .cfsellqty ??
                                                                          "0") ??
                                                                      0) >
                                                                  0
                                                              ? "-${widget.positionList.cfsellqty}"
                                                              : "0",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 27),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextWidget.paraText(
                                                      text: "AVG PRICE",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${widget.positionList.dayavgprc ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  const SizedBox(height: 8),
                                                  TextWidget.paraText(
                                                      text: "BUY PRICE",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${widget.positionList.daybuyavgprc ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  const SizedBox(height: 8),
                                                  TextWidget.paraText(
                                                      text: "SELL PRICE",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${widget.positionList.daysellavgprc ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  const SizedBox(height: 8),
                                                  TextWidget.paraText(
                                                      text: "PRODUCT",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  TextWidget.subText(
                                                      text:
                                                          "${widget.positionList.sPrdtAli}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD)),
                                                  // // TextWidget.subText(
                                                  // //     text: "Net Qty",
                                                  // //     theme: false,
                                                  // //     color: theme.isDarkMode
                                                  // //         ? colors.colorWhite
                                                  // //         : colors.colorBlack,
                                                  // //     fw: 1),
                                                  // // const SizedBox(height: 2),
                                                  // // TextWidget.subText(
                                                  // //     text:
                                                  // //         "${((int.tryParse(widget.positionList.netqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                                  // //     theme: false,
                                                  // //     color: theme.isDarkMode
                                                  // //         ? colors.colorWhite
                                                  // //         : colors.colorBlack,
                                                  // //     fw: 1),
                                                  // const SizedBox(height: 2),
                                                  // Divider(
                                                  //     color: theme.isDarkMode
                                                  //         ? colors
                                                  //             .darkColorDivider
                                                  //         : colors
                                                  //             .colorDivider),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // if ((widget.positionList.netqty !=
                                            //         "0") &&
                                            //     (widget.positionList
                                            //                 .sPrdtAli ==
                                            //             "MIS" ||
                                            //         widget.positionList
                                            //                 .sPrdtAli ==
                                            //             "CNC" ||
                                            //         widget.positionList
                                            //                 .sPrdtAli ==
                                            //             "NRML"))
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ConvertPositionDialogue(
                                                        convertPosition: widget
                                                            .positionList);
                                                  },
                                                );
                                              },
                                              child: TextWidget.subText(
                                                text: "Convert Position",
                                                fw: 0,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : const Color(0xff0037B7),
                                                theme: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : const Color(0xffDDDDDD)),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  assets.chart,
                                                  color: Color(0xFF0037B7),
                                                  width: 16,
                                                  height: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                InkWell(
                                                  onTap: () async {
                                                    scripInfo.setChartScript(
                                                        widget.positionList
                                                                .exch ??
                                                            "",
                                                        widget.positionList
                                                                .token ??
                                                            "",
                                                        widget.positionList
                                                                .tsym ??
                                                            "");
                                                    Navigator.pop(context);
                                                    final chartArgs = ChartArgs(
                                                      exch: widget.positionList.exch ?? "",
                                                      tsym: widget.positionList.tsym ?? "",
                                                      token: widget.positionList.token ?? "",
                                                    );
                                                    ref.read(chartProvider.notifier).showChart(chartArgs);
                                                  },
                                                  child: TextWidget.subText(
                                                    text: "Chart",
                                                    fw: 0,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : const Color(
                                                            0xff0037B7),
                                                    theme: false,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            if (scripInfo.getOptionawait(
                                                widget.positionList.exch ?? "",
                                                widget.positionList.token ??
                                                    "")) ...[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    assets.options,
                                                    color: Color(0xFF0037B7),
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  InkWell(
                                                    onTap: () async {
                                                      if (widget.positionList
                                                                  .exch ==
                                                              "NFO" ||
                                                          (widget.positionList
                                                                      .exch ==
                                                                  "MCX" &&
                                                              widget.positionList
                                                                      .option ==
                                                                  "OPTFUT")) {
                                                        await marketwatch.fetchStikePrc(
                                                            "${marketwatch.getQuotes!.undTk}",
                                                            "${marketwatch.getQuotes!.undExch}",
                                                            context);
                                                      }

                                                      // Set up the option script data
                                                      marketwatch.setOptionScript(
                                                          context,
                                                          widget.positionList
                                                                  .exch ??
                                                              "",
                                                          widget.positionList
                                                                  .token ??
                                                              "",
                                                          widget.positionList
                                                                  .tsym ??
                                                              "");

                                                      // Wait a small amount of time to ensure data is processed
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  100));

                                                      // Navigate to option chain screen
                                                      Navigator.pop(context);
                                                      Navigator.pushNamed(
                                                          context,
                                                          Routes.optionChain,
                                                          arguments: depthArgs);
                                                    },
                                                    child: TextWidget.subText(
                                                      text: "Option",
                                                      fw: 0,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff0037B7),
                                                      theme: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              const SizedBox.shrink(),
                                            ],
                                          ],
                                        ),
                                        if (scripInfo.getOptionawait(
                                            widget.positionList.exch ?? "",
                                            widget.positionList.token ??
                                                "")) ...[
                                          const SizedBox(height: 16),
                                          Divider(
                                              color: theme.isDarkMode
                                                  ? colors.darkColorDivider
                                                  : const Color(0xffDDDDDD)),
                                        ] else ...[
                                          const SizedBox.shrink(),
                                        ],

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: InkWell(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         const MarketDepthScreen(),
                                              //   ),
                                              // );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextWidget.subText(
                                                    text: "Market Depth",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : const Color(
                                                            0xff666666),
                                                    fw: 0),
                                                const SizedBox(height: 16),
                                                SvgPicture.asset(
                                                  assets.rightarrowcur,
                                                  color: Color(0xff777777),
                                                  width: 16,
                                                  height: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : const Color(0xffDDDDDD)),
                                        if (scripInfo.fut!.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: InkWell(
                                              onTap: () async {
                                                // If expanding, load futures data
                                                await scripInfo.requestWSFut(
                                                    context: context,
                                                    isSubscribe: true);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                          color: theme.isDarkMode
                                                              ? colors
                                                                  .colorBlack
                                                              : colors
                                                                  .colorWhite,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6)),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SvgPicture.asset(
                                                                    assets
                                                                        .dInfo,
                                                                    color: colors
                                                                        .colorBlue),
                                                                TextWidget.paraText(
                                                                    text:
                                                                        " Long press to add ${scripInfo.wlName}'s Watchlist",
                                                                    color: colors
                                                                        .colorBlue,
                                                                    theme: theme
                                                                        .isDarkMode,
                                                                    fw: 0)
                                                              ]),
                                                          const FutureScreen(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Futures",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : const Color(
                                                              0xff666666),
                                                      fw: 0),
                                                  const SizedBox(height: 16),
                                                  SvgPicture.asset(
                                                    assets.rightarrowcur,
                                                    color: Color(0xff777777),
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                              color: theme.isDarkMode
                                                  ? colors.darkColorDivider
                                                  : const Color(0xffDDDDDD)),
                                        ] else ...[
                                          const SizedBox.shrink(),
                                        ],
                                        (scripInfo.fundamentalData != null &&
                                                scripInfo
                                                        .fundamentalData?.msg !=
                                                    "no data found")
                                            ? Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16.0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        if (scripInfo
                                                                    .fundamentalData ==
                                                                null ||
                                                            scripInfo
                                                                    .fundamentalData
                                                                    ?.msg ==
                                                                "no data found") {
                                                          await scripInfo
                                                              .fetchFundamentalData(
                                                                  tradeSym:
                                                                      "${widget.positionList.exch}:${widget.positionList.tsym}");
                                                        }

                                                        if (!mounted) return;

                                                        if (scripInfo
                                                                    .fundamentalData !=
                                                                null &&
                                                            scripInfo
                                                                    .fundamentalData
                                                                    ?.msg !=
                                                                "no data found") {
                                                          // Reset state before navigation
                                                          await scripInfo
                                                              .chngDephBtn(
                                                                  "Overview");

                                                          await Navigator
                                                              .pushNamed(
                                                            context,
                                                            Routes
                                                                .fundamentalDetail,
                                                            arguments: {
                                                              "wlValue":
                                                                  depthArgs,
                                                              "depthData":
                                                                  depthData,
                                                            },
                                                          );
                                                          // Navigator.push(
                                                          //   context,
                                                          //   MaterialPageRoute(
                                                          //     builder: (context) =>
                                                          //         const MarketDepthScreen(),
                                                          //   ),
                                                          // );
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          TextWidget.subText(
                                                              text:
                                                                  "Fundamentals",
                                                              theme: false,
                                                              color: theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : const Color(
                                                                      0xff666666),
                                                              fw: 0),
                                                          const SizedBox(
                                                              height: 16),
                                                          SvgPicture.asset(
                                                            assets
                                                                .rightarrowcur,
                                                            color: const Color(
                                                                0xff777777),
                                                            width: 16,
                                                            height: 16,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : const Color(
                                                              0xffDDDDDD))
                                                ],
                                              )
                                            : const SizedBox.shrink(),

                                        // const SizedBox(height: 4),
                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       child: Column(
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           TextWidget.paraText(
                                        //               text: "CF Buy Avg",
                                        //               theme: false,
                                        //               color: const Color(
                                        //                   0xff666666),
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           TextWidget.subText(
                                        //               text:
                                        //                   "${widget.positionList.cfbuyavgprc ?? 0.00}",
                                        //               theme: false,
                                        //               color: theme.isDarkMode
                                        //                   ? colors.colorWhite
                                        //                   : colors.colorBlack,
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           Divider(
                                        //               color: theme.isDarkMode
                                        //                   ? colors
                                        //                       .darkColorDivider
                                        //                   : colors
                                        //                       .colorDivider),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //     const SizedBox(width: 27),
                                        //     Expanded(
                                        //       child: Column(
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           TextWidget.paraText(
                                        //               text: "CF Buy Qty",
                                        //               theme: false,
                                        //               color: const Color(
                                        //                   0xff666666),
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           TextWidget.subText(
                                        //               text:
                                        //                   "${((int.tryParse(widget.positionList.cfbuyqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                        //               theme: false,
                                        //               color: theme.isDarkMode
                                        //                   ? colors.colorWhite
                                        //                   : colors.colorBlack,
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           Divider(
                                        //               color: theme.isDarkMode
                                        //                   ? colors
                                        //                       .darkColorDivider
                                        //                   : colors
                                        //                       .colorDivider),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        // const SizedBox(height: 4),
                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       child: Column(
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           TextWidget.paraText(
                                        //               text: "CF Sell Avg",
                                        //               theme: false,
                                        //               color: const Color(
                                        //                   0xff666666),
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           TextWidget.subText(
                                        //               text:
                                        //                   "${widget.positionList.cfsellavgprc ?? 0.00}",
                                        //               theme: false,
                                        //               color: theme.isDarkMode
                                        //                   ? colors.colorWhite
                                        //                   : colors.colorBlack,
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           Divider(
                                        //               color: theme.isDarkMode
                                        //                   ? colors
                                        //                       .darkColorDivider
                                        //                   : colors
                                        //                       .colorDivider),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //     const SizedBox(width: 27),
                                        //     Expanded(
                                        //       child: Column(
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           TextWidget.paraText(
                                        //               text: "CF Sell Qty",
                                        //               theme: false,
                                        //               color: const Color(
                                        //                   0xff666666),
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           TextWidget.subText(
                                        //               text:
                                        //                   "${((int.tryParse(widget.positionList.cfsellqty.toString()) ?? 0) / (widget.positionList.exch == 'MCX' ? (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}",
                                        //               theme: false,
                                        //               color: theme.isDarkMode
                                        //                   ? colors.colorWhite
                                        //                   : colors.colorBlack,
                                        //               fw: 0),
                                        //           const SizedBox(height: 2),
                                        //           Divider(
                                        //               color: theme.isDarkMode
                                        //                   ? colors
                                        //                       .darkColorDivider
                                        //                   : colors
                                        //                       .colorDivider),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        // const SizedBox(height: 4),
                                        // TextWidget.subText(
                                        //     text: "Net Buy Value",
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // TextWidget.subText(
                                        //     text:
                                        //         "${widget.positionList.totbuyamt ?? 0.00}",
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // Divider(
                                        //     color: theme.isDarkMode
                                        //         ? colors.darkColorDivider
                                        //         : colors.colorDivider),
                                        // const SizedBox(height: 4),
                                        // TextWidget.subText(
                                        //     text: "Net Sell Value",
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // TextWidget.subText(
                                        //     text:
                                        //         "${widget.positionList.totsellamt ?? 0.00}",
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // Divider(
                                        //     color: theme.isDarkMode
                                        //         ? colors.darkColorDivider
                                        //         : colors.colorDivider),
                                        // const SizedBox(height: 4),
                                        // TextWidget.subText(
                                        //     text: "Net Value",
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // TextWidget.subText(
                                        //     text: (double.parse(
                                        //                 "${widget.positionList.totbuyamt ?? 0.00}") +
                                        //             double.parse(
                                        //                 "${widget.positionList.totsellamt ?? 0.00}"))
                                        //         .toStringAsFixed(2),
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // Divider(
                                        //     color: theme.isDarkMode
                                        //         ? colors.darkColorDivider
                                        //         : colors.colorDivider),
                                        // const SizedBox(height: 4),
                                        // TextWidget.subText(
                                        //     text: "Act Avg Price",
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
                                        // const SizedBox(height: 2),
                                        // TextWidget.subText(
                                        //     text: (double.parse(
                                        //             "${widget.positionList.upldprc ?? 0.00}"))
                                        //         .toStringAsFixed(2),
                                        //     theme: false,
                                        //     color: theme.isDarkMode
                                        //         ? colors.colorWhite
                                        //         : colors.colorBlack,
                                        //     fw: 0),
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
}

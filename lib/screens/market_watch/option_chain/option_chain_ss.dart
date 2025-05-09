import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import 'cur_strike_price.dart';
import 'opt_chain_call_list.dart';
import 'opt_chain_put_list.dart';
import 'strike_price_list_card.dart';

class OptionChainSS extends StatefulWidget {
  final DepthInputArgs wlValue;
  // final String isBasket;

  const OptionChainSS({
    super.key,
    required this.wlValue,
    // required this.isBasket
  });

  @override
  State<OptionChainSS> createState() => _OptionChainSSState();
}

class _OptionChainSSState extends State<OptionChainSS> {
  String regtoken = "";

  final ScrollController _controller = ScrollController();
  late SwipeActionController swipecontroller;
  @override
  void initState() {
    regtoken = widget.wlValue.token;
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'Stock details OC',
      screenClass: 'Option chain',
    );

    swipecontroller = SwipeActionController(selectedIndexPathsChangeCallback:
        (changedIndexPaths, selected, currentCount) {
      setState(() {});
    });
    super.initState();
    Future.microtask(() {
      context.read(marketWatchProvider).loadDefaultTabs();
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read(marketWatchProvider).scrollToSelectedTab(true));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          // if (didPop) return;
          Navigator.pop(context);
          await context
              .read(marketWatchProvider)
              .calldepthApis(context, widget.wlValue, "");
          await context
              .read(marketWatchProvider)
              .requestWSOptChain(context: context, isSubscribe: false);
          await context.read(websocketProvider).establishConnection(
                channelInput: "${widget.wlValue.exch}|${widget.wlValue.token}",
                task: "ud",
                context: context,
              );
        },
        child: Consumer(builder: (context, ScopedReader watch, _) {
          final depthData = watch(marketWatchProvider).getQuotes!;
          final scripInfo = watch(marketWatchProvider);
          final theme = context.read(themeProvider);

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.chevron_left, size: 38),
                  onPressed: () async {
                    final wsProvider = context.read(websocketProvider);
                    final currentContext =
                        context; 
                    Navigator.pop(context);
                    await scripInfo.calldepthApis(
                        currentContext, depthData, "");
                    await scripInfo.requestWSOptChain(
                        context: currentContext, isSubscribe: false);
                    await wsProvider.establishConnection(
                      channelInput:
                          "${widget.wlValue.exch}|${widget.wlValue.token}",
                      task: "ud",
                      context: currentContext,
                    );
                  }),
              leadingWidth: 32,
              toolbarHeight: 40,
              elevation: 0,
              title: _buildTopBar(scripInfo, theme),
            ),
            body: SafeArea(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            right: 3, left: 16, top: 10, bottom: 8),
                        child: SizedBox(
                            height: 32,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                controller: _controller,
                                itemBuilder: (context, index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? scripInfo.selectedExpDate! ==
                                                    scripInfo.sortDate[index]
                                                ? const Color(0xffF1F3F8)
                                                : const Color(0xffB5C0CF)
                                                    .withOpacity(.15)
                                            : scripInfo.selectedExpDate! ==
                                                    scripInfo.sortDate[index]
                                                ? const Color(0xff000000)
                                                : const Color(0xffF1F3F8),
                                        borderRadius:
                                            BorderRadius.circular(98)),
                                    child: InkWell(
                                        onTap: () async {
                                          if (scripInfo.sortDate.length <= 12) {
                                            _controller.animateTo(
                                                scripInfo.sortDate.length <= 4
                                                    ? index * 40
                                                    : index * 100,
                                                duration:
                                                    const Duration(seconds: 1),
                                                curve: Curves.fastOutSlowIn);
                                          } else {
                                            _controller.animateTo(index * 112,
                                                duration:
                                                    const Duration(seconds: 1),
                                                curve: Curves.fastOutSlowIn);
                                          }

                                          for (var i = 0;
                                              i < scripInfo.optExp!.length;
                                              i++) {
                                            if (scripInfo.sortDate[index] ==
                                                scripInfo.optExp![i].exd) {
                                              scripInfo.selecTradSym(
                                                  "${scripInfo.optExp![i].tsym}");
                                              scripInfo.optExch(
                                                  "${scripInfo.optExp![i].exch}");
                                            }
                                          }
                                          scripInfo.selecexpDate(
                                              scripInfo.sortDate[index]);

                                          await context
                                              .read(marketWatchProvider)
                                              .fetchOPtionChain(
                                                  context: context,
                                                  exchange:
                                                      scripInfo.optionExch!,
                                                  numofStrike:
                                                      scripInfo.numStrike,
                                                  strPrc:
                                                      scripInfo.optionStrPrc,
                                                  tradeSym: scripInfo
                                                      .selectedTradeSym!);
                                        },
                                        child: Text(
                                            scripInfo.sortDate[index]
                                                .replaceAll("-", " "),
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? Color(scripInfo
                                                                .selectedExpDate! ==
                                                            scripInfo
                                                                .sortDate[index]
                                                        ? 0xff000000
                                                        : 0xffffffff)
                                                    : Color(scripInfo
                                                                .selectedExpDate! ==
                                                            scripInfo
                                                                .sortDate[index]
                                                        ? 0xffffffff
                                                        : 0xff000000),
                                                12.5,
                                                FontWeight.w500))),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(width: 8);
                                },
                                shrinkWrap: true,
                                itemCount: scripInfo.sortDate.length))),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 36,
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffFAFBFF),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("OI",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      13,
                                      FontWeight.w500)),
                              Text("  Call LTP   ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      13,
                                      FontWeight.w500)),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            useSafeArea: true,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(
                                                    top: Radius.circular(16))),
                                            context: context,
                                            builder: (context) => Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: theme.isDarkMode
                                                        ? colors.colorBlack
                                                        : colors.colorWhite,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color:
                                                              Color(0xff999999),
                                                          blurRadius: 4.0,
                                                          offset:
                                                              Offset(2.0, 0.0))
                                                    ]),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const CustomDragHandler(),
                                                      Text(
                                                          "Select Number of Strike",
                                                          style: textStyles
                                                              .appBarTitleTxt
                                                              .copyWith(
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack)),
                                                      const SizedBox(height: 6),
                                                      Flexible(
                                                          child: ListView
                                                              .separated(
                                                                  physics:
                                                                      const ClampingScrollPhysics(),
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return ListTile(
                                                                        onTap:
                                                                            () async {
                                                                          scripInfo
                                                                              .selecNumStrike(scripInfo.numStrikes[index]);
                                                                          await context.read(marketWatchProvider).fetchOPtionChain(
                                                                              context: context,
                                                                              exchange: scripInfo.optionExch!,
                                                                              numofStrike: scripInfo.numStrikes[index],
                                                                              strPrc: scripInfo.optionStrPrc,
                                                                              tradeSym: scripInfo.selectedTradeSym!);
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                0),
                                                                        dense:
                                                                            true,
                                                                        title: Text(
                                                                            scripInfo.numStrikes[index],
                                                                            style: textStyle(
                                                                                scripInfo.numStrike == scripInfo.numStrikes[index] && theme.isDarkMode
                                                                                    ? colors.colorLightBlue
                                                                                    : scripInfo.numStrike == scripInfo.numStrikes[index]
                                                                                        ? colors.colorBlue
                                                                                        : colors.colorGrey,
                                                                                14,
                                                                                scripInfo.numStrike == scripInfo.numStrikes[index] ? FontWeight.w600 : FontWeight.w500)),
                                                                        trailing: SvgPicture.asset(theme.isDarkMode
                                                                            ? scripInfo.numStrike == scripInfo.numStrikes[index]
                                                                                ? assets.darkActProductIcon
                                                                                : assets.darkProductIcon
                                                                            : scripInfo.numStrike == scripInfo.numStrikes[index]
                                                                                ? assets.actProductIcon
                                                                                : assets.productIcon));
                                                                  },
                                                                  separatorBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return const ListDivider();
                                                                  },
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: scripInfo
                                                                      .numStrikes
                                                                      .length))
                                                    ])));
                                      },
                                      child: Row(children: [
                                        Text("${scripInfo.numStrike} ",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorLightBlue
                                                    : colors.colorBlue,
                                                13,
                                                FontWeight.w500)),
                                        Text("Strike",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorLightBlue
                                                    : colors.colorBlue,
                                                13,
                                                FontWeight.w500)),
                                        Icon(Icons.arrow_drop_down,
                                            color: theme.isDarkMode
                                                ? colors.colorLightBlue
                                                : colors.colorBlue,
                                            size: 20)
                                      ]))),
                              Text("  Put LTP   ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      13,
                                      FontWeight.w500)),
                              Text("OI",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      13,
                                      FontWeight.w500))
                            ])),
                    if (scripInfo.isPreDefWLs != "Yes")
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xffe3f2fd),
                              borderRadius: BorderRadius.circular(6)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(assets.dInfo,
                                    color: colors.colorBlue),
                                Text(
                                    " Long press to add ${scripInfo.wlName}'s Watchlist",
                                    style: textStyle(
                                        colors.colorBlue, 12, FontWeight.w500))
                              ])),
                    Expanded(
                        child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(children: [
                        if (scripInfo.isLoad || scripInfo.scripDepthloader) ...[
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xff0037B7)))
                        ] else ...[
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                  children: (scripInfo
                                              .optChainCallUP.isNotEmpty &&
                                          scripInfo.optChainPutUp.isNotEmpty)
                                      ? <Widget>[
                                          Flexible(
                                            child: OptChainCallList(
                                                swipe: swipecontroller,
                                                callData:
                                                    scripInfo.optChainCallUP,
                                                isCallUp: true),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: StrikePriceListCard(
                                                strike:
                                                    scripInfo.optChainCallUP,
                                                isCallUp: true),
                                          ),
                                          Flexible(
                                            child: OptChainPutList(
                                                putData:
                                                    scripInfo.optChainPutUp,
                                                isPutUp: true),
                                          )
                                        ]
                                      : [])),
                          CurStrkprice(
                              token:
                                  depthData.undTk ?? depthData.token ?? "0.00"),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                                children: (scripInfo
                                            .optChainCallDown.isNotEmpty &&
                                        scripInfo.optChainPutDown.isNotEmpty)
                                    ? [
                                        Flexible(
                                          child: OptChainCallList(
                                              swipe: swipecontroller,
                                              callData:
                                                  scripInfo.optChainCallDown,
                                              isCallUp: false),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: StrikePriceListCard(
                                              strike:
                                                  scripInfo.optChainCallDown,
                                              isCallUp: false),
                                        ),
                                        Flexible(
                                          child: OptChainPutList(
                                              putData:
                                                  scripInfo.optChainPutDown,
                                              isPutUp: false),
                                        )
                                      ]
                                    : []),
                          )
                        ]
                      ]),
                    )),
                    if (!scripInfo.scripDepthloader &&
                        scripInfo.getQuotes?.instname != "UNDIND" &&
                        scripInfo.getQuotes?.instname != "COM")
                      scripInfo.actDeptBtn == "Set Alert"
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: theme.isDarkMode
                                              ? colors.darkColorDivider
                                              : colors.colorDivider))),
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                      onTap: () async {
                                        await placeOrderInput(scripInfo,
                                            context, depthData, true);
                                      },
                                      child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: const Color(0xff43A833),
                                              borderRadius:
                                                  BorderRadius.circular(108)),
                                          child: Center(
                                              child: Text("BUY",
                                                  style: textStyle(
                                                      const Color(0XFFFFFFFF),
                                                      16,
                                                      FontWeight.w600)))),
                                    )),
                                    const SizedBox(width: 18),
                                    Expanded(
                                        child: InkWell(
                                            onTap: () async {
                                              await placeOrderInput(scripInfo,
                                                  context, depthData, false);
                                            },
                                            child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: colors.darkred,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            108)),
                                                child: Center(
                                                    child: Text("SELL",
                                                        style: textStyle(
                                                            const Color(
                                                                0XFFFFFFFF),
                                                            16,
                                                            FontWeight
                                                                .w600))))))
                                  ])),
                  ]),
            ),
          );
        }));
  }

  Widget _buildTopBar(MarketWatchProvider tvChart, theme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // IconButton(
          //   padding: const EdgeInsets.all(0),
          //   icon: SvgPicture.asset(assets.backArrow,
          //       color: theme.isDarkMode
          //           ? colors.colorWhite
          //           : colors.colorBlack), // Back icon
          //   onPressed: () async {
          //     await context.read(marketWatchProvider).chngDephBtn("Overview");
          //     await context
          //         .read(marketWatchProvider)
          //         .requestWSOptChain(context: context, isSubscribe: false);
          //     await context.read(websocketProvider).establishConnection(
          //           channelInput:
          //               "${widget.wlValue.exch}|${widget.wlValue.token}",
          //           task: "ud",
          //           context: context,
          //         );
          //     Navigator.of(context).pop();
          //   },
          // ),
          Expanded(
            child: ListView.separated(
              controller: tvChart.scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 0),
              itemCount:
                  tvChart.optionTabs.length, // List of tabs (tokens/symbols)
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final last = tvChart.optionTabs.first;
                final tab = tvChart.optionTabs[index];
                final isSelected = tab.token == tvChart.oactiveTab?.token;
                return InkWell(
                  onTap: () async {
                    tvChart.setOptionScript(context, tab.exch.toString(),
                        tab.token.toString(), tab.tsym.toString());
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Chip(
                    visualDensity:
                        const VisualDensity(vertical: -4, horizontal: 0),
                    labelPadding: const EdgeInsets.only(right: 0),
                    padding: index > 1
                        ? const EdgeInsets.only(left: 16)
                        : const EdgeInsets.symmetric(horizontal: 8),
                    label: Text(
                      tab.tsym,
                      style: textStyle(
                        theme.isDarkMode
                            ? Color(isSelected ? 0xff000000 : 0xffffffff)
                            : Color(isSelected ? 0xffffffff : 0xff000000),
                        12,
                        FontWeight.w500,
                      ),
                    ),
                    backgroundColor: theme.isDarkMode
                        ? (isSelected
                            ? const Color(0xffffffff)
                            : const Color(0xff000000))
                        : (isSelected
                            ? const Color(0xff000000)
                            : const Color(0xffffffff)),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: theme.isDarkMode
                            ? (!isSelected
                                ? colors.colorWhite
                                : colors.colorBlack)
                            : (isSelected
                                ? colors.colorWhite
                                : colors.colorBlack),
                      ),
                    ),
                    deleteIcon: index > 1
                        ? Icon(
                            Icons.close,
                            size: 16,
                            color: theme.isDarkMode
                                ? Color(isSelected ? 0xff000000 : 0xffffffff)
                                : Color(isSelected ? 0xffffffff : 0xff000000),
                          )
                        : null,
                    onDeleted: index > 1
                        ? () async {
                            tvChart.removeChartTab(tab, true);
                            if (tvChart.oactiveTab?.token == tab.token) {
                              await tvChart.fetchScripQuoteIndex(
                                  last.token, last.exch, context);
                              tvChart.setChartScript(
                                  last.exch, last.token, last.tsym);
                            }
                          }
                        : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              },
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            icon:
                // Text("+",
                //     style: textStyle(
                //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //         32,
                //         FontWeight.normal)),
                Icon(Icons.add_circle_outline,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
            onPressed: () async {
              Navigator.pushNamed(
                context,
                Routes.searchScrip,
                arguments: "Option||Is",
              );
              // userProfile.setChartdialog(false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    await context.read(marketWatchProvider).fetchScripInfo(
        widget.wlValue.token, widget.wlValue.exch, context, true);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: widget.wlValue.exch,
        tSym: widget.wlValue.tsym,
        isExit: false,
        token: widget.wlValue.token,
        transType: transType,
        lotSize: depthData.ls,
        ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});
    Navigator.pop(ctx);
    Navigator.pushNamed(ctx, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ctx.read(marketWatchProvider).scripInfoModel!,
      "isBskt": ""
    });
  }
}

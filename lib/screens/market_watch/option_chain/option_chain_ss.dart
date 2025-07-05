import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import 'cur_strike_price.dart';
import 'opt_chain_call_list.dart';
import 'opt_chain_put_list.dart';
import 'strike_price_list_card.dart';

class OptionChainSS extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  // final String isBasket;

  const OptionChainSS({
    super.key,
    required this.wlValue,
    // required this.isBasket
  });

  @override
  ConsumerState<OptionChainSS> createState() => _OptionChainSSState();
}

class _OptionChainSSState extends ConsumerState<OptionChainSS> {
  String regtoken = "";
  bool showPriceView = true; // true for Price, false for OI

  final ScrollController _controller = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final GlobalKey _strikePriceKey = GlobalKey();

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
      ref.read(marketWatchProvider).loadDefaultTabs();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollToCurrentStrikePrice();
      });
    });
  }

  void _scrollToCurrentStrikePrice() {
    // Use a longer delay to ensure the widget tree is fully built and laid out
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_strikePriceKey.currentContext != null) {
        Scrollable.ensureVisible(
          _strikePriceKey.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        // If context not found on first try, attempt once more with longer delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          if (_strikePriceKey.currentContext != null) {
            Scrollable.ensureVisible(
              _strikePriceKey.currentContext!,
              alignment: 0.5,
              duration: const Duration(milliseconds: 300),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await ref
            .read(marketWatchProvider)
            .calldepthApis(context, widget.wlValue, "");
        await ref
            .read(marketWatchProvider)
            .requestWSOptChain(context: context, isSubscribe: false);
        await ref.read(websocketProvider).establishConnection(
              channelInput: "${widget.wlValue.exch}|${widget.wlValue.token}",
              task: "ud",
              context: context,
            );
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Consumer(builder: (context, ref, _) {
            final theme = ref.read(themeProvider);
            return Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.grey.withOpacity(0.4),
                highlightColor: Colors.grey.withOpacity(0.2),
                onTap: () async {
                  // Add delay for visual feedback
                  await Future.delayed(const Duration(milliseconds: 150));
                  
                  final wsProvider = ref.read(websocketProvider);
                  final scripInfo = ref.read(marketWatchProvider);
                  final currentContext = context;
                  Navigator.pop(context);
                  await scripInfo.calldepthApis(
                      currentContext, scripInfo.getQuotes!, "");
                  await scripInfo.requestWSOptChain(
                      context: currentContext, isSubscribe: false);
                  await wsProvider.establishConnection(
                    channelInput:
                        "${widget.wlValue.exch}|${widget.wlValue.token}",
                    task: "ud",
                    context: currentContext,
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 18,
                    color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  ),
                ),
              ),
            );
          }),
          leadingWidth: 48,
          toolbarHeight: 40,
          elevation: 0,
          title: _NewAppBarTitle(
            wlValue: widget.wlValue,
            showPriceView: showPriceView,
            onToggleView: () async {
              // Add delay for visual feedback
              await Future.delayed(const Duration(milliseconds: 150));
              setState(() {
                showPriceView = !showPriceView;
              });
            },
            scrollToStrikePrice: _scrollToCurrentStrikePrice,
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Column headers
              _ColumnHeaders(
                scrollToStrikePrice: _scrollToCurrentStrikePrice,
                showPriceView: showPriceView,
              ),

              // Pre-defined watchlist info banner (conditional)
              _PreDefinedWatchlistBanner(),

              // Option chain data - main content
              _OptionChainContent(
                strikePriceKey: _strikePriceKey,
                mainScrollController: _mainScrollController,
                swipecontroller: swipecontroller,
                showPriceView: showPriceView,
              ),

              // Buy/Sell buttons (conditional)
              _ActionButtons(wlValue: widget.wlValue),
            ],
          ),
        ),
      ),
    );
  }
}

// New App Bar Title with Symbol, Expiry Dropdown, and Search with Price/OI toggle
class _NewAppBarTitle extends ConsumerWidget {
  final DepthInputArgs wlValue;
  final bool showPriceView;
  final VoidCallback onToggleView;
  final VoidCallback scrollToStrikePrice;

  const _NewAppBarTitle({
    Key? key,
    required this.wlValue,
    required this.showPriceView,
    required this.onToggleView,
    required this.scrollToStrikePrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    return Row(
      children: [
        // Symbol Name and Expiry Dropdown
        Expanded(
          flex: 0,
          child: Row(
            children: [
              TextWidget.subText(
                text: wlValue.tsym.toUpperCase(),
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,

                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: scripInfo.selectedExpDate,
                  isExpanded: false,
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                    size: 18,
                  ),
                  style: TextWidget.textStyle(
                    fontSize: 14,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                  ),
                  items: scripInfo.sortDate.map((String date) {
                    return DropdownMenuItem<String>(
                      value: date,
                      child: TextWidget.subText(
                        text: date.replaceAll("-", " "),
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      for (var i = 0; i < scripInfo.optExp!.length; i++) {
                        if (newValue == scripInfo.optExp![i].exd) {
                          scripInfo
                              .selecTradSym("${scripInfo.optExp![i].tsym}");
                          scripInfo.optExch("${scripInfo.optExp![i].exch}");
                        }
                      }
                      scripInfo.selecexpDate(newValue);

                      await ref.read(marketWatchProvider).fetchOPtionChain(
                          context: context,
                          exchange: scripInfo.optionExch!,
                          numofStrike: scripInfo.numStrike,
                          strPrc: scripInfo.optionStrPrc,
                          tradeSym: scripInfo.selectedTradeSym!);

                      Future.delayed(const Duration(milliseconds: 300), () {
                        scrollToStrikePrice();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Price/OI Toggle Button
        Material(
          color: Colors.transparent, // Important to allow ripple to show
          child: InkWell(
            borderRadius:
                BorderRadius.circular(4), // Optional: match container shape
            splashColor: theme.isDarkMode
                ? colors.splashColorDark
                : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: onToggleView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TextWidget.subText(
                text: showPriceView ? "Price" : "OI",
                color: theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight,
                theme: theme.isDarkMode,
              ),
            ),
          ),
        ),

        const SizedBox(width: 4),

        // Search Icon
        InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.isDarkMode
              ? colors.splashColorDark
              : colors.splashColorLight,
          highlightColor:
              theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
          onTap: () async {
            // Add delay for visual feedback
            await Future.delayed(const Duration(milliseconds: 150));
            
            Navigator.pushNamed(
              context,
              Routes.searchScrip,
              arguments: "Option||Replace",
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              assets.searchIcon,
              width: 18,
              height: 18,
            ),
          ),
        )
      ],
    );
  }
}

// Helper function to avoid duplicating the showStrikeCountSelector code
void _showStrikeCountSelector(
    BuildContext context,
    WidgetRef ref,
    MarketWatchProvider scripInfo,
    ThemesProvider theme,
    VoidCallback scrollToStrikePrice) {
  showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      context: context,
      builder: (context) => Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
                TextWidget.titleText(
                    text: "Select Number of Strike",
                    theme: theme.isDarkMode,
                    fw: 1),
                const SizedBox(height: 6),
                Flexible(
                    child: ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () async {
                                scripInfo.selecNumStrike(
                                    scripInfo.numStrikes[index]);

                                // First close the modal
                                Navigator.pop(context);

                                // Then fetch data with the new strike count
                                await ref
                                    .read(marketWatchProvider)
                                    .fetchOPtionChain(
                                        context: context,
                                        exchange: scripInfo.optionExch!,
                                        numofStrike:
                                            scripInfo.numStrikes[index],
                                        strPrc: scripInfo.optionStrPrc,
                                        tradeSym: scripInfo.selectedTradeSym!);

                                // Use a longer delay to ensure data is loaded and widgets are built
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  if (context.mounted) {
                                    // Use the callback to main screen's scroll method
                                    scrollToStrikePrice();
                                  }
                                });
                              },
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              dense: true,
                              title: TextWidget.subText(
                                  text: scripInfo.numStrikes[index],
                                  color: scripInfo.numStrike ==
                                              scripInfo.numStrikes[index] &&
                                          theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : scripInfo.numStrike ==
                                              scripInfo.numStrikes[index]
                                          ? colors.colorBlue
                                          : colors.colorGrey,
                                  theme: theme.isDarkMode,
                                  fw: scripInfo.numStrike ==
                                          scripInfo.numStrikes[index]
                                      ? 1
                                      : 0),
                              trailing: SvgPicture.asset(theme.isDarkMode
                                  ? scripInfo.numStrike ==
                                          scripInfo.numStrikes[index]
                                      ? assets.darkActProductIcon
                                      : assets.darkProductIcon
                                  : scripInfo.numStrike ==
                                          scripInfo.numStrikes[index]
                                      ? assets.actProductIcon
                                      : assets.productIcon));
                        },
                        separatorBuilder: (context, index) {
                          return const ListDivider();
                        },
                        shrinkWrap: true,
                        itemCount: scripInfo.numStrikes.length))
              ])));
}

// Widget for column headers - updated to ConsumerWidget
class _ColumnHeaders extends ConsumerWidget {
  final VoidCallback scrollToStrikePrice;
  final bool showPriceView;

  const _ColumnHeaders({
    Key? key,
    required this.scrollToStrikePrice,
    required this.showPriceView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    return RepaintBoundary(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 36,
          color: colors.colorWhite,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //  TextWidget.paraText(
            //           text: showPriceView ? "Call Price" : "Call OI",
            //           theme: theme.isDarkMode,
            //           fw: 0),

            TextWidget.subText(
                text: showPriceView ? "  Call Price   " : "  Call OI   ",
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                theme: theme.isDarkMode,
                ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InkWell(
                    onTap: () {
                      _showStrikeCountSelector(
                          context, ref, scripInfo, theme, scrollToStrikePrice);
                    },
                    child: Row(children: [
                      TextWidget.subText(
                          text: "${scripInfo.numStrike} ",
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          ),
                      TextWidget.subText(
                          text: "Strike",
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          ),
                      Icon(Icons.arrow_drop_down,
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight, size: 20)
                    ]))),

            TextWidget.subText(
                text: showPriceView ? "Put Price" : "Put OI",
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                theme: theme.isDarkMode,
                ),

            //  TextWidget.paraText(
            //           text: "OI",

            //           theme: theme.isDarkMode,
            //           fw: 0),
          ])),
    );
  }
}

// Widget for predefined watchlist banner (conditional)
class _PreDefinedWatchlistBanner extends ConsumerWidget {
  const _PreDefinedWatchlistBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);

    if (scripInfo.isPreDefWLs == "Yes") {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xffe3f2fd),
              borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
            TextWidget.captionText(
                text: " Long press to add Watchlist / Swipe to Trade",
                color: colors.secondaryLight,
                theme: false,
                ),
          ])),
    );
  }
}

// Widget for the main option chain content
class _OptionChainContent extends ConsumerWidget {
  final GlobalKey strikePriceKey;
  final ScrollController mainScrollController;
  final SwipeActionController swipecontroller;
  final bool showPriceView;

  const _OptionChainContent({
    Key? key,
    required this.strikePriceKey,
    required this.mainScrollController,
    required this.swipecontroller,
    required this.showPriceView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final depthData = scripInfo.getQuotes!;

    // Determine if data is fully loaded
    final bool isLoading = scripInfo.isLoad ||
        scripInfo.scripDepthloader ||
        scripInfo.optChainCallUP.isEmpty ||
        scripInfo.optChainPutUp.isEmpty ||
        scripInfo.optChainCallDown.isEmpty ||
        scripInfo.optChainPutDown.isEmpty;

    if (isLoading) {
      // Create a timeout to handle cases where loading gets stuck
      return FutureBuilder(
          future: Future.delayed(const Duration(seconds: 5)),
          builder: (context, snapshot) {
            // If the timeout completes and we're still loading, show a retry option
            if (snapshot.connectionState == ConnectionState.done) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget.subText(
                        text: "Data loading is taking longer than expected",
                        color: Color(0xff666666),
                        theme: false,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Reset loading state
                          ref.read(marketWatchProvider).singlePageloader(true);

                          // Retry fetching data
                          if (scripInfo.oactiveTab != null) {
                            ref.read(marketWatchProvider).setOptionScript(
                                  context,
                                  scripInfo.oactiveTab!.exch.toString(),
                                  scripInfo.oactiveTab!.token.toString(),
                                  scripInfo.oactiveTab!.tsym.toString(),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0037B7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: TextWidget.paraText(
                            text: "Retry",
                            color: Colors.white,
                            theme: false,
                            fw: 0),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show loading indicator while waiting
            return const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xff0037B7))));
          });
    }

    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: mainScrollController,
        child: Column(children: [
          RepaintBoundary(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OptChainCallList(
                        swipe: swipecontroller,
                        callData: scripInfo.optChainCallUP,
                        isCallUp: false,
                        showPriceView: showPriceView,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: StrikePriceListCard(
                        strike: scripInfo.optChainCallUP, isCallUp: false),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: OptChainPutList(
                        putData: scripInfo.optChainPutUp,
                        isPutUp: false,
                        showPriceView: showPriceView,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: CurStrkprice(
                key: strikePriceKey,
                token: depthData.undTk ?? depthData.token ?? "0.00"),
          ),
          RepaintBoundary(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: OptChainCallList(
                      swipe: swipecontroller,
                      callData: scripInfo.optChainCallDown,
                      isCallUp: false,
                      showPriceView: showPriceView,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: StrikePriceListCard(
                        strike: scripInfo.optChainCallDown, isCallUp: false),
                  ),
                  Flexible(
                    child: OptChainPutList(
                      putData: scripInfo.optChainPutDown,
                      isPutUp: false,
                      showPriceView: showPriceView,
                    ),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

// Widget for the buy/sell action buttons
class _ActionButtons extends ConsumerWidget {
  final DepthInputArgs wlValue;

  const _ActionButtons({
    Key? key,
    required this.wlValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final depthData = scripInfo.getQuotes!;
    final theme = ref.read(themeProvider);

    // Determine if we should show buttons
    if (scripInfo.scripDepthloader ||
        depthData.instname == "UNDIND" ||
        depthData.instname == "COM" ||
        scripInfo.actDeptBtn == "Set Alert") {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider))),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: InkWell(
              onTap: () async {
                await _placeOrderInput(context, ref, wlValue, depthData, true);
              },
              child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: TextWidget.subText(
                        text: "BUY",
                          color: colors.colorWhite,
                        theme: theme.isDarkMode,
                        fw: 2),
                  )),
            )),
            const SizedBox(width: 18),
            Expanded(
                child: InkWell(
                    onTap: () async {
                      await _placeOrderInput(
                          context, ref, wlValue, depthData, false);
                    },
                    child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: colors.tertiary,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                          child: TextWidget.subText(
                              text: "SELL",
                              color: colors.colorWhite,
                              theme: theme.isDarkMode,
                              fw: 2),
                        ))))
          ])),
    );
  }
}

// Global helper function
Future<void> _placeOrderInput(BuildContext context, WidgetRef ref,
    DepthInputArgs wlValue, GetQuotes depthData, bool transType) async {
  await ref
      .read(marketWatchProvider)
      .fetchScripInfo(wlValue.token, wlValue.exch, context, true);

  OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: wlValue.exch,
      tSym: wlValue.tsym,
      isExit: false,
      token: wlValue.token,
      transType: transType,
      lotSize: depthData.ls,
      ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
      perChange: depthData.pc ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: {});

  Navigator.pop(context);
  Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
    "orderArg": orderArgs,
    "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
    "isBskt": ""
  });
}

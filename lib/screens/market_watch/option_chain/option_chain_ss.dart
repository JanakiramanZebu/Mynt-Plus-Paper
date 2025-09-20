import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/portfolio_provider.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';
import 'cur_strike_price.dart';
import 'opt_chain_call_list.dart';
import 'opt_chain_put_list.dart';
import 'strike_price_list_card.dart';
import '../../order_book/basket/create_basket.dart';

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
  bool isBasketMode = false; // true for Basket mode, false for normal mode

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

    // Import the classes to reset global max OI
    // Reset global max OI values when opening option chain
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset both call and put global max OI values
      if (kDebugMode) {
        print("=== OPTION CHAIN INIT: Resetting Global Max OI ===");
      }

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
  void dispose() {
    if (kDebugMode) {
      print("=== OPTION CHAIN DISPOSE ===");
    }
    super.dispose();
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
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
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
            isBasketMode: isBasketMode,
            onToggleView: () async {
              // Add delay for visual feedback
              await Future.delayed(const Duration(milliseconds: 150));
              setState(() {
                showPriceView = !showPriceView;
              });
            },
            onToggleBasketMode: () async {
              // Add delay for visual feedback
              await Future.delayed(const Duration(milliseconds: 150));

              // Show the basket bottom sheet

              setState(() {
                isBasketMode = !isBasketMode;
              });

              // Load basket data when enabling basket mode
              if (isBasketMode) {
                final orderProv = ref.read(orderProvider);
                await orderProv.getBasketName();

                // If there's a selected basket, ensure WebSocket subscription
                if (orderProv.selectedBsktName.isNotEmpty) {
                  await orderProv.chngBsktName(orderProv.selectedBsktName,
                      context, true // isOpt = true to prevent navigation
                      );
                }
              }
            },
            scrollToStrikePrice: _scrollToCurrentStrikePrice,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Column headers
                  _ColumnHeaders(
                    scrollToStrikePrice: _scrollToCurrentStrikePrice,
                    showPriceView: showPriceView,
                    onToggleView: () async {
                      await Future.delayed(const Duration(milliseconds: 150));
                      setState(() {
                        showPriceView = !showPriceView;
                      });
                    },
                  ),

                  // Pre-defined watchlist info banner (conditional)
                  _PreDefinedWatchlistBanner(),

                  // Option chain data - main content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isBasketMode ? 200 : 0),
                      child: _OptionChainContent(
                        strikePriceKey: _strikePriceKey,
                        mainScrollController: _mainScrollController,
                        swipecontroller: swipecontroller,
                        showPriceView: showPriceView,
                        isBasketMode: isBasketMode,
                      ),
                    ),
                  ),

                  // Buy/Sell buttons are hidden in option chain screen
                ],
              ),

              if (isBasketMode)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BasketBottomSheet(),
                ),

              // Backdrop is handled by showModalBottomSheet

              // Basket bottom sheet is now shown via showModalBottomSheet in the callback
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
  final bool isBasketMode;
  final VoidCallback onToggleView;
  final VoidCallback onToggleBasketMode;
  final VoidCallback scrollToStrikePrice;

  const _NewAppBarTitle({
    Key? key,
    required this.wlValue,
    required this.showPriceView,
    required this.isBasketMode,
    required this.onToggleView,
    required this.onToggleBasketMode,
    required this.scrollToStrikePrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    return Row(
      children: [
        // Symbol Name and Expiry Dropdown
        Row(
          children: [
            TextWidget.titleText(
              text: wlValue.symbol.toUpperCase().replaceAll("-EQ", ""),
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              fw: 1,
            ),
            const SizedBox(width: 8),
            Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: scripInfo.selectedExpDate,
                  isExpanded: false,
                  isDense: true,
                  dropdownColor: theme.isDarkMode 
                      ? colors.colorBlack
                      : colors.colorWhite,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color:
                        theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                        fw: 0,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      for (var i = 0; i < scripInfo.optExp!.length; i++) {
                        if (newValue == scripInfo.optExp![i].exd) {
                          scripInfo.selecTradSym("${scripInfo.optExp![i].tsym}");
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
            ),
          ],
        ),

        const Spacer(),

        // Price/OI Toggle Button
        // Material(
        //   color: Colors.transparent, // Important to allow ripple to show
        //   child: InkWell(
        //     borderRadius:
        //         BorderRadius.circular(4), // Optional: match container shape
        //     splashColor: theme.isDarkMode
        //         ? colors.splashColorDark
        //         : colors.splashColorLight,
        //     highlightColor:
        //         theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
        //     onTap: onToggleView,
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //       child: TextWidget.subText(
        //         text: showPriceView ? "Price" : "OI",
        //         color: theme.isDarkMode
        //             ? colors.secondaryDark
        //             : colors.secondaryLight,
        //         theme: theme.isDarkMode,
        //       ),
        //     ),
        //   ),
        // ),

        const SizedBox(width: 4),

        // Basket Toggle Icon
        InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.isDarkMode
              ? colors.splashColorDark
              : colors.splashColorLight,
          highlightColor:
              theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
          onTap: onToggleBasketMode,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              isBasketMode
                  ? Icons.shopping_basket
                  : Icons.shopping_basket_outlined,
              size: 22,
              color: isBasketMode
                  ?  colors.primaryLight
                  : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
            ),
          ),
        ),

        // const SizedBox(width: 4),

        // // Search Icon
        // InkWell(
        //   borderRadius: BorderRadius.circular(20),
        //   splashColor: theme.isDarkMode
        //       ? colors.splashColorDark
        //       : colors.splashColorLight,
        //   highlightColor:
        //       theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
        //   onTap: () async {
        //     // Add delay for visual feedback
        //     await Future.delayed(const Duration(milliseconds: 150));

        //     Navigator.pushNamed(
        //       context,
        //       Routes.searchScrip,
        //       arguments: "Option||Replace",
        //     );
        //   },
        //   child: Padding(
        //     padding: const EdgeInsets.all(8),
        //     child: SvgPicture.asset(
        //       assets.searchIcon,
        //       width: 18,
        //       height: 18,
        //     ),
        //   ),
        // )
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
      builder: (context) => SafeArea(
        child: Container(
             decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
            ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
        
           
          ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const CustomDragHandler(),
                  Padding(
                     padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.titleText(
                            text: "Select Number of Strike",
                            color :  theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
                            fw: 1),
                             Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(20),
                              splashColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.15),
                              highlightColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.08),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 22,
                                  color: colors.colorGrey,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                     Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      height: 0,
                    ),
                  Flexible(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ])),
      ));
}

// Widget for column headers - updated to ConsumerWidget
class _ColumnHeaders extends ConsumerWidget {
  final VoidCallback scrollToStrikePrice;
  final bool showPriceView;
  final VoidCallback onToggleView;

  const _ColumnHeaders({
    Key? key,
    required this.scrollToStrikePrice,
    required this.showPriceView,
    required this.onToggleView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripInfo = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    return RepaintBoundary(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 36,
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // Left arrow icon
            Material(
              color: Colors.transparent,
              // shape: const CircleBorder(),
              child: InkWell(
                onTap: onToggleView,
                borderRadius: BorderRadius.circular(5),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextWidget.subText(
                    text: showPriceView
                        ? "  <> Call Price   "
                        : "  <> Call OI   ",
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 0,
                  ),
                ),
              ),
            ),

            // Call Price / Call OI

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    _showStrikeCountSelector(
                        context, ref, scripInfo, theme, scrollToStrikePrice);
                  },
                  borderRadius: BorderRadius.circular(5),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(children: [
                        TextWidget.subText(
                          text: "${scripInfo.numStrike} ",
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        TextWidget.subText(
                          text: "Strike",
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            size: 20)
                      ])),
                ),
              ),
            ),
            // Put Price / Put OI

            Material(
              color: Colors.transparent,
              // shape: const CircleBorder(),
              child: InkWell(
                onTap: onToggleView,
                borderRadius: BorderRadius.circular(5),
                splashColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                highlightColor: theme.isDarkMode
                    ? colors.splashColorDark
                    : colors.splashColorLight,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextWidget.subText(
                    text: showPriceView ? "<> Put Price" : "<> Put OI",
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 0,
                  ),
                ),
              ),
            )
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
    final theme = ref.read(themeProvider);

    if (scripInfo.isPreDefWLs == "Yes") {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.primaryDark.withOpacity(0.3) : colors.primaryLight.withOpacity(0.3),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
            TextWidget.paraText(
              text: " Long press to add Watchlist / Swipe to Trade",
              color: theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
              theme: false,
              fw: 0,
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
  final bool isBasketMode;

  const _OptionChainContent({
    Key? key,
    required this.strikePriceKey,
    required this.mainScrollController,
    required this.swipecontroller,
    required this.showPriceView,
    required this.isBasketMode,
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
              return Center(
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
              );
            }

            // Show loading indicator while waiting
            return const Center(
                child: CircularProgressIndicator(color: Color(0xff0037B7)));
          });
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: mainScrollController,
      child: Column(children: [
        RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                      isBasketMode: isBasketMode,
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
                      isBasketMode: isBasketMode,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: OptChainCallList(
                    swipe: swipecontroller,
                    callData: scripInfo.optChainCallDown,
                    isCallUp: false,
                    showPriceView: showPriceView,
                    isBasketMode: isBasketMode,
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
                    isBasketMode: isBasketMode,
                  ),
                )
              ],
            ),
          ),
        )
      ]),
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

  // Get the updated scripInfo after fetchScripInfo to ensure we have the correct lot size
  final scripInfoModel = ref.read(marketWatchProvider).scripInfoModel!;

  OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: wlValue.exch,
      tSym: wlValue.tsym,
      isExit: false,
      token: wlValue.token,
      transType: transType,
      // Use lot size from the updated scripInfoModel instead of potentially stale depthData
      lotSize: scripInfoModel.ls ?? depthData.ls,
      ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
      perChange: depthData.pc ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      // Pass lot size in raw data as backup
      raw: {"correctLotSize": scripInfoModel.ls ?? depthData.ls});

  Navigator.pop(context);
  Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
    "orderArg": orderArgs,
    "scripInfo": scripInfoModel,
    "isBskt": "Basket"
  });
}

// Enhanced Basket Bottom Sheet Widget with full BasketScripList functionality
class _BasketBottomSheet extends ConsumerStatefulWidget {
  const _BasketBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<_BasketBottomSheet> createState() => _BasketBottomSheetState();
}

class _BasketBottomSheetState extends ConsumerState<_BasketBottomSheet>
    with TickerProviderStateMixin {
  double _sheetHeight = 260.0;
  final double _minHeight = 260.0;
  late double _maxHeight;
  bool _isExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxHeight = MediaQuery.of(context).size.height * 0.8;
  }

  @override
  void initState() {
    super.initState();
    // Ensure WebSocket subscriptions are established when basket bottom sheet is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureBasketWebSocketSubscription();
    });
  }

  void _ensureBasketWebSocketSubscription() async {
    final orderProv = ref.read(orderProvider);
    // if (kDebugMode) {
    //   print("=== BASKET WEBSOCKET DEBUG ===");
    //   print("Selected basket: ${orderProv.selectedBsktName}");
    //   print("Basket items count: ${orderProv.bsktScripList.length}");
    //   print("Basket items: ${orderProv.bsktScripList.map((item) => "${item['tsym']}|${item['token']}").join(', ')}");
    //   print("==============================");
    // }

    if (orderProv.selectedBsktName.isNotEmpty &&
        orderProv.bsktScripList.isNotEmpty) {
      // Re-establish WebSocket subscription for current basket to ensure live updates
      await orderProv.chngBsktName(orderProv.selectedBsktName, context, true);

      if (kDebugMode) {
        print(
            "WebSocket subscription refreshed for basket: ${orderProv.selectedBsktName}");
      }
    }
  }

  /// Checks if the basket contains scripts from multiple exchanges
  bool _hasMultipleExchanges(List scriptList) {
    if (scriptList.isEmpty) return false;

    // Extract all exchanges from the basket scripts
    Set<String> exchanges = {};
    for (var script in scriptList) {
      if (script['exch'] != null) {
        exchanges.add(script['exch'].toString());
      }
    }

    // If there's more than one unique exchange, return true
    return exchanges.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final orderProv = ref.watch(orderProvider);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _sheetHeight =
              (_sheetHeight - details.delta.dy).clamp(_minHeight, _maxHeight);
        });
      },
      onPanEnd: (details) {
        // Calculate the threshold height (30% of max height)
        double thresholdHeight = _maxHeight * 0.3;

        setState(() {
          if (_sheetHeight < thresholdHeight) {
            // Snap to minimum if below threshold
            _sheetHeight = _minHeight;
            _isExpanded = false;
          } else {
            // Keep the sheet at the current height where user released it
            // Don't force snap to max - respect user's intended position
            _isExpanded = _sheetHeight >
                _maxHeight * 0.7; // Update expanded state based on position
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _sheetHeight,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
           border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

        ),
        child: Column(
          children: [
            // Fixed header section
            const CustomDragHandler(),

            // Header with current basket name and action icons
            _buildBasketHeader(theme, orderProv),
            ListDivider(),

            // Scrollable content section
            if (orderProv.selectedBsktName.isNotEmpty &&
                orderProv.bsktScripList.isNotEmpty)
              _buildMarginsSection(theme, orderProv),
            // Content

            orderProv.bsktList.isEmpty
                ? _buildCreateBasketView(theme, orderProv)
                : _buildBasketContent(theme, orderProv),

            // Exchange validation warning (if needed)

            // Place Order Button (if basket has items and is valid)

            if (orderProv.bsktScripList.isNotEmpty &&
                _hasMultipleExchanges(orderProv.bsktScripList))
              _buildMultiExchangeWarning(),
            if (orderProv.selectedBsktName.isNotEmpty &&
                orderProv.bsktScripList.isNotEmpty)
              _buildPlaceOrderButton(theme, orderProv),
          ],
        ),
      ),
    );
  }

  Widget _buildBasketHeader(ThemesProvider theme, OrderProvider orderProv) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.titleText(
                  text: orderProv.selectedBsktName.isNotEmpty
                      ? orderProv.selectedBsktName
                      : "No Basket Selected",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
                const SizedBox(height: 4),
                if (orderProv.selectedBsktName.isNotEmpty)
                  TextWidget.subText(
                    text: "${orderProv.bsktScripList.length} items",
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 0,
                  ),
              ],
            ),
          ),
          Row(
            children: [
              // Switch basket icon
              if (orderProv.bsktList.length > 1)
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () async {
                      await Future.delayed(Duration(milliseconds: 100));
                      _showBasketSelector(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.swap_horiz,
                        size: 24,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),

              // Refresh basket margin icon
              if (orderProv.selectedBsktName.isNotEmpty &&
                  orderProv.bsktScripList.isNotEmpty)
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () async {
                      await Future.delayed(Duration(milliseconds: 100));
                      await orderProv.fetchBasketMargin();
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    highlightColor: theme.isDarkMode
                        ? colors.splashColorDark
                        : colors.splashColorLight,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.refresh,
                        size: 22,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),

              // Add basket icon

              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    await Future.delayed(Duration(milliseconds: 100));
                    _showCreateBasket(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarginsSection(ThemesProvider theme, OrderProvider orderProv) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: "Pre Trade Margin",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
              ),
              const SizedBox(height: 6),
              TextWidget.subText(
                text: orderProv.bsktScripList.isEmpty ||
                        orderProv.bsktOrderMargin == null
                    ? "0.00"
                    : (double.parse(orderProv.bsktOrderMargin!.marginused ?? '0.00') - double.parse(orderProv.bsktOrderMargin!.marginusedprev ?? '0.00')).toStringAsFixed(2),
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWidget.subText(
                text: "Post Trade Margin",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
              ),
              const SizedBox(height: 6),
              TextWidget.titleText(
                text: orderProv.bsktScripList.isEmpty ||
                        orderProv.bsktOrderMargin == null
                    ? "0.00"
                    : (double.parse(orderProv.bsktOrderMargin!.marginusedtrade ?? '0.00') - double.parse(orderProv.bsktOrderMargin!.marginusedprev ?? '0.00')).toStringAsFixed(2),
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiExchangeWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.loss,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget.paraText(
            text: "Basket should contain orders of only 1 segment",
            theme: false,
            color: colors.colorWhite,
            fw: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBasketView(
      ThemesProvider theme, OrderProvider orderProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SvgPicture.asset(assets.noDatafound,
                  color: Color(0xff777777)),
              const SizedBox(height: 2),
              Text("No Data Found",
                  style:
                      textStyle(const Color(0xff777777), 15, FontWeight.w500)),
              //       SizedBox(height: 16),
              // TextWidget.subText(
              //   text: "No baskets found",
              //   theme: theme.isDarkMode,
              //   color: colors.colorGrey,
              // ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showCreateBasket(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: TextWidget.subText(
                  text: "Create Basket",
                  color: colors.colorWhite,
                  theme: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasketContent(
      ThemesProvider theme, OrderProvider orderProvider) {
    // If no basket is selected, show basket selector
    if (orderProvider.selectedBsktName.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assets.noDatafound,
                color: Color(0xff777777),
              ),
              const SizedBox(height: 2),
              TextWidget.subText(
                  text: "No Basket Selected",
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                  theme: theme.isDarkMode),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showBasketSelector(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryLight,
                  minimumSize: const Size(0, 45),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: TextWidget.subText(
                  text: "Choose Basket",
                  color: colors.colorWhite,
                  theme: false,
                  fw: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If basket is selected but empty
    if (orderProvider.bsktScripList.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assets.noDatafound,
                color: Color(0xff777777),
              ),
              const SizedBox(height: 2),
              TextWidget.subText(
                text: "Basket is empty",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
              ),
              const SizedBox(height: 8),
              TextWidget.subText(
                text: "Tap on options above to add them to basket",
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
                theme: theme.isDarkMode,
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};

        // Check if we have socket data and need to update
        if (snapshot.hasData && socketDatas.isNotEmpty) {
          bool updated = false;

          // Update basket script list with real-time values
          for (var script in orderProvider.bsktScripList) {
            final token = script['token']?.toString();
            if (token != null && socketDatas.containsKey(token)) {
              final lp = socketDatas[token]['lp']?.toString();
              final pc = socketDatas[token]['pc']?.toString();

              if (lp != null && lp != "null") {
                if (script['lp']?.toString() != lp) {
                  script['lp'] = lp;
                  updated = true;
                }
              }

              if (pc != null && pc != "null") {
                if (script['pc']?.toString() != pc) {
                  script['pc'] = pc;
                  updated = true;
                }
              }
            }
          }

          // Force a refresh if we have updates
          if (updated) {
            // Update in the next frame to avoid rebuild conflicts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                // This will trigger a rebuild with the new values
                orderProvider.notifyBasketUpdates();
              }
            });
          }
        }

        return Expanded(
          child: SingleChildScrollView(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderProvider.bsktScripList.length,
              separatorBuilder: (_, __) => const ListDivider(),
              itemBuilder: (context, index) {
                final script = orderProvider.bsktScripList[index];

                // Process script data for display
                if (script['exch'] == "BFO" && script["dname"] != "null") {
                  List<String> splitVal = script["dname"].toString().split(" ");
                  script['symbol'] = splitVal[0];
                  script['expDate'] = "${splitVal[1]} ${splitVal[2]}";
                  script['option'] = splitVal.length > 4
                      ? "${splitVal[3]} ${splitVal[4]}"
                      : splitVal[3];
                } else {
                  Map spilitSymbol = spilitTsym(value: "${script['tsym']}");
                  script['symbol'] = "${spilitSymbol["symbol"]}";
                  script['expDate'] = "${spilitSymbol["expDate"]}";
                  script['option'] = "${spilitSymbol["option"]}";
                }

                return InkWell(
                  onTap: () =>
                      _handleBasketItemTap(index, script, orderProvider),
                  onLongPress: () =>
                      _deleteScript(index, script, orderProvider),
                  child: _buildScriptCard(theme, script, index),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildScriptCard(ThemesProvider theme, Map script, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                    text:
                        "${script['symbol'].toString().replaceAll("-EQ", "")}",
                    theme: theme.isDarkMode,
                    textOverflow: TextOverflow.ellipsis,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  TextWidget.subText(
                    text: " ${script['expDate']} ",
                    theme: theme.isDarkMode,
                    textOverflow: TextOverflow.ellipsis,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  TextWidget.subText(
                    text: " ${script['option']} ",
                    theme: theme.isDarkMode,
                    textOverflow: TextOverflow.ellipsis,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 0,
                  ),
                ],
              ),
              if (script['orderStatus'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getItemStatusColor(script['orderStatus'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    // border: Border.all(
                    //     color: _getItemStatusColor(script['orderStatus'])),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWidget.paraText(
                        text: _getItemStatusText(script['orderStatus']),
                        theme: theme.isDarkMode,
                        color: _getItemStatusColor(script['orderStatus']),
                        fw: 0,
                      ),
                      if (script['avgPrice'] != null)
                        TextWidget.paraText(
                          text: " @ ₹${script['avgPrice']}",
                          theme: theme.isDarkMode,
                          color: _getItemStatusColor(script['orderStatus']),
                          fw: 0,
                        ),
                      // Add navigation hint for placed orders
                      if (_isOrderPlaced(script['orderStatus'])) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: _getItemStatusColor(script['orderStatus']),
                          size: 10,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // CustomExchBadge(exch: "${script["exch"]}"),

                  TextWidget.paraText(
                    text:
                        "${script["exch"]} - ${script["ordType"]} - ${script["prctype"]} - ${formatToTimeOnly(script["date"])}",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ],
              ),
              Row(
                children: [
                  TextWidget.paraText(
                    text: " LTP ${script['lp']?.toString() ?? "0.00"}",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ],
              ),
              // TextWidget.paraText(
              //   text: " (${script['pc']?.toString() ?? "0.00"}%)",
              //   theme: false,
              //   color: script['pc']?.toString().startsWith("-") ?? false
              //       ? colors.darkred
              //       : script['pc']?.toString() == "0.00"
              //           ? colors.ltpgrey
              //           : colors.ltpgreen,
              //   fw: 0,
              // ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.paraText(
                    text: script["trantype"] == "S" ? "SELL" : "BUY",
                    theme: false,
                    color: script["trantype"] == "S"
                        ? colors.lossLight
                        : colors.primaryLight,
                    fw: 0,
                  ),
                  const SizedBox(width: 8),
                  TextWidget.paraText(
                    text: "${script["dscqty"]}/${script["qty"]}",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                ],
              ),
              if (script["prctype"] != "MKT")
                Row(
                  children: [
                    TextWidget.paraText(
                      text: "${script['prc'] ?? 0.00}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ],
                ),
            ],
          ),
          // Order Status Display (if available)

          // Show rejection reason separately if needed
          if (script['rejectionReason'] != null &&
              script['orderStatus'] == 'failed')
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.darkred.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colors.darkred),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colors.darkred,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextWidget.captionText(
                      text: script['rejectionReason'],
                      theme: theme.isDarkMode,
                      color: colors.darkred,
                      textOverflow: TextOverflow.ellipsis,
                      fw: 0,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(ThemesProvider theme, OrderProvider orderProv) {
    final hasMultipleExchanges = _hasMultipleExchanges(orderProv.bsktScripList);
    final basketStatus =
        orderProv.basketOverallStatus[orderProv.selectedBsktName] ?? '';
    final isBasketPlaced = orderProv.isBasketPlaced(orderProv.selectedBsktName);

    // Show order status if basket has been placed
    if (isBasketPlaced) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Order Status Display
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(12),
            //   margin: const EdgeInsets.only(bottom: 8),
            //   decoration: BoxDecoration(
            //     color: _getStatusColor(basketStatus).withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: _getStatusColor(basketStatus)),
            //   ),
            //   child: Column(
            //     children: [
            //       // Row(
            //       //   mainAxisAlignment: MainAxisAlignment.center,
            //       //   children: [
            //       //     Icon(
            //       //       _getStatusIcon(basketStatus),
            //       //       color: _getStatusColor(basketStatus),
            //       //       size: 16,
            //       //     ),
            //       //     const SizedBox(width: 8),
            //       //     TextWidget.subText(
            //       //       text: _getStatusText(basketStatus),
            //       //       theme: theme.isDarkMode,
            //       //       color: _getStatusColor(basketStatus),
            //       //       fw: 1,
            //       //     ),
            //       //   ],
            //       // ),
            //       if (basketStatus == 'partially_placed' || basketStatus == 'partially_completed')
            //         const SizedBox(height: 4),
            //       if (basketStatus == 'partially_placed' || basketStatus == 'partially_completed')
            //         TextWidget.subText(
            //           text: _getPartialStatusDetails(orderProv),
            //           theme: theme.isDarkMode,
            //           color: colors.colorGrey,
            //         ),
            //     ],
            //   ),
            // ),
            // Reset Button

            SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    orderProv
                        .resetBasketOrderTracking(orderProv.selectedBsktName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            "Basket reset. You can place orders again."),
                        backgroundColor: colors.profit,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  label: TextWidget.subText(
                    text: "Reset Orders",
                    theme: false,
                    color: colors.primary,
                    fw: 2,
                  ),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 45),
                      side: BorderSide(
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                      ),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                )),
          ],
        ),
      );
    }

    // Original place order button
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: hasMultipleExchanges
              ? Colors.grey
              : (theme.isDarkMode ? colors.primaryDark : colors.primaryLight),
          borderRadius: BorderRadius.circular(5),
        ),
        child: InkWell(
          onTap: hasMultipleExchanges
              ? null

              // () {
              //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //       content: const Text(
              //         "Cannot place order: Basket should contain orders from only 1 segment",
              //       ),
              //       backgroundColor: colors.darkred,
              //       duration: const Duration(seconds: 3),
              //     ));
              //   }
              : basketStatus == 'placing'
                  ? null // Disable button while placing
                  : () async {
                      await orderProv.placeBasketOrder(context,
                          navigateToOrderBook: false);
                    },
          child: Center(
            child: basketStatus == 'placing'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.colorWhite),
                      ),
                      const SizedBox(width: 8),
                      TextWidget.subText(
                        text: "Placing...",
                        theme: false,
                        color: colors.colorWhite,
                        fw: 2,
                      ),
                    ],
                  )
                : TextWidget.subText(
                    text: "Place Order",
                    theme: false,
                    color: hasMultipleExchanges
                        ? Colors.white
                        : (colors.colorWhite),
                    fw: 2,
                  ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'placing':
        return colors.colorBlue;
      case 'placed':
      case 'completed':
        return colors.ltpgreen;
      case 'partially_placed':
      case 'partially_completed':
      case 'partially_filled':
        return colors.pending;
      case 'failed':
        return colors.darkred;
      default:
        return colors.colorGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'placing':
        return Icons.schedule;
      case 'placed':
      case 'completed':
        return Icons.check_circle;
      case 'partially_placed':
      case 'partially_completed':
      case 'partially_filled':
        return Icons.warning;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'placing':
        return 'Placing Orders...';
      case 'placed':
        return 'Orders Placed Successfully';
      case 'completed':
        return 'All Orders Completed';
      case 'partially_placed':
        return 'Partially Placed';
      case 'partially_completed':
        return 'Partially Completed';
      case 'partially_filled':
        return 'Partially Filled';
      case 'failed':
        return 'Order Placement Failed';
      default:
        return 'Unknown Status';
    }
  }

  String _getPartialStatusDetails(OrderProvider orderProv) {
    final orderIds = orderProv.basketOrderIds[orderProv.selectedBsktName] ?? [];
    final totalOrders = orderProv.bsktScripList.length;
    final successfulOrders = orderIds.length;

    if (orderIds.isNotEmpty) {
      return '$successfulOrders of $totalOrders orders processed';
    }
    return '';
  }

  // Helper methods for individual item status indicators
  Color _getItemStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return colors.colorBlue;
      case 'complete':
        return colors.ltpgreen;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return colors.loss;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return colors.pending;
      default:
        return colors.colorGrey;
    }
  }

  IconData _getItemStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Icons.send;
      case 'complete':
        return Icons.check_circle;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return Icons.cancel;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return Icons.schedule;
      default:
        return Icons.info_outline;
    }
  }

  String _getItemStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return 'PLACED';
      case 'complete':
        return 'EXECUTED';
      case 'rejected':
        return 'REJECTED';
      case 'canceled':
        return 'CANCELLED';
      case 'failed':
        return 'FAILED';
      case 'open':
        return 'OPEN';
      case 'partial':
        return 'PARTIALLY FILLED';
      case 'trigger_pending':
        return 'TRIGGER PENDING';
      default:
        return status.toUpperCase(); // Show actual status from order book
    }
  }

  // Handle tap on basket items - navigate to order book if placed, edit if not placed
  void _handleBasketItemTap(
      int index, Map script, OrderProvider orderProvider) {
    String? orderStatus = script['orderStatus'];

    // If order is placed/completed/etc, navigate to order book
    if (orderStatus != null && _isOrderPlaced(orderStatus)) {
      // _navigateToOrderBook(orderProvider, orderStatus);
    } else {
      // If order not placed yet, allow editing
      _editScript(index, script, orderProvider);
    }
  }

  // Check if order is placed (any status other than null or initial states)
  bool _isOrderPlaced(String status) {
    return !['pending', 'draft', 'preparing'].contains(status.toLowerCase());
  }

  // Navigate to order book in portfolio screen
  void _navigateToOrderBook(OrderProvider orderProvider, String orderStatus) {
    Navigator.pop(context);
    Navigator.pop(context);
    ref.read(indexListProvider).bottomMenu(2, context);
    ref.read(portfolioProvider).changeTabIndex(2);

    // print("orderStatusboi: $orderStatus");

    if (orderStatus == 'COMPLETE' || orderStatus == 'REJECTED') {
      orderProvider.changeTabIndex(1, context);
    } else {
      orderProvider.changeTabIndex(0, context);
    }

    // Show success message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: const Text("Navigating to Order Book to view order details"),
    //     backgroundColor: colors.ltpgreen,
    //     duration: const Duration(seconds: 2),
    //   ),
    // );
  }

  void _editScript(int index, Map script, OrderProvider orderProv) async {
    await ref.read(marketWatchProvider).fetchScripInfo(
          "${script['token']}",
          '${script['exch']}',
          context,
          true,
        );

    script['index'] = index;
    script['prctyp'] = script['prctype'];

    // **FIX: Ensure prd field is correctly preserved for basket edit**
    // The prd field should already be correct from when the item was saved to basket
    // Only set prd if it's missing, but don't overwrite existing correct values
    if (script['prd'] == null || script['prd'].toString().isEmpty) {
      // Fallback mapping from ordType to prd if prd is missing
      final ordType = script['ordType']?.toString();
      if (ordType == 'MIS') {
        script['prd'] = 'I'; // Intraday
      } else if (ordType == 'CNC') {
        script['prd'] = 'C'; // Delivery
      } else if (ordType == 'NRML') {
        script['prd'] = 'M'; // Carryforward
      }
    }

    // Ensure lp and pc values are not null for OrderScreenArgs
    final ltp = script['lp']?.toString() ?? "0.00";
    final perChange = script['pc']?.toString() ?? "0.00";

    OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: '${script['exch']}',
      tSym: '${script['tsym']}',
      isExit: false,
      token: "${script['token']}",
      transType: script['trantype'] == 'B' ? true : false,
      lotSize: ref.read(marketWatchProvider).scripInfoModel?.ls.toString(),
      ltp: ltp,
      perChange: perChange,
      orderTpye: '',
      holdQty: '',
      isModify: true,
      // **FIX: Set prd field in OrderScreenArgs for proper order type initialization**
      prd: script['prd']?.toString(),
      raw: script,
    );

    Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
      "isBskt": 'BasketEdit'
    });
  }

  void _deleteScript(int index, Map script, OrderProvider orderProv) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = ref.read(themeProvider);
        return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF1F3F8),
          titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          scrollable: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          actionsPadding:
              const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextWidget.subText(
                            text:
                                "Are you sure you want to delete this basket Scrip ${script['symbol']?.toString().replaceAll("-EQ", "")}",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                            align: TextAlign.center),
                      ]))
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await orderProv.removeBsktScrip(
                      index, orderProv.selectedBsktName);
                  await orderProv.fetchBasketMargin();
                  Navigator.pop(context);
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
                  text: "Yes",
                  theme: theme.isDarkMode,
                  color: colors.colorWhite,
                  fw: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateBasket(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const CreateBasket(),
    ).then((_) async {
      // Refresh basket data after creating basket
      await ref.read(orderProvider).getBasketName();

      // Ensure WebSocket subscriptions are refreshed
      _ensureBasketWebSocketSubscription();
    });
  }

  String formatToTimeOnly(String rawDate) {
    try {
      final dateTime = DateFormat("dd MMM yyyy, hh:mm a").parse(rawDate);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return ''; // or return rawDate if you want fallback
    }
  }

  void _showBasketSelector(BuildContext context) {
    final orderProv = ref.read(orderProvider);
    final theme = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      // isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),

        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const CustomDragHandler(),
              // const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: "Select Basket",
                      theme: ref.read(themeProvider).isDarkMode,
                      color: ref.read(themeProvider).isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                    ListDivider(),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () async {
                          await Future.delayed(const Duration(milliseconds: 150));
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: ref.read(themeProvider).isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: ref.read(themeProvider).isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: colors.colorGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: ref.read(themeProvider).isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
                height: 0,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: orderProv.bsktList.length,
                  separatorBuilder: (_, __) => const ListDivider(),
                  itemBuilder: (context, index) {
                    final basket = orderProv.bsktList[index];
                    final basketName = basket['bsketName'].toString();
                    final isDark = ref.read(themeProvider).isDarkMode;
          
                    return ListTile(
                      minLeadingWidth: 25,
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            assets.basketdashboard,
                            color: isDark
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                          ),
                        ],
                      ),
                      title: Container(
                        margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.1,
                        ),
                        child: TextWidget.subText(
                          text: basketName,
                          theme: isDark,
                          color: isDark
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          fw: 0,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextWidget.paraText(
                          text: "${basket['curLength']} / ${basket['max']} items",
                          theme: isDark,
                          textOverflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          color: ref.read(themeProvider).isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                      ),
                      trailing: basketName == orderProv.selectedBsktName
                          ? Icon(Icons.check, color: colors.ltpgreen)
                          : null,
                      onTap: () async {
                        await orderProv.chngBsktName(basketName, context, true);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          
              // ...orderProv.bsktList.map<Widget>((basket) {
              //   final basketName = basket['bsketName'].toString();
              //   return ListTile(
              //     title: TextWidget.subText(
              //       text: basketName,
              //       theme: ref.read(themeProvider).isDarkMode,
              //       color: ref.read(themeProvider).isDarkMode
              //           ? colors.colorWhite
              //           : colors.colorBlack,
              //     ),
              //     subtitle: TextWidget.paraText(
              //       text: "${basket['curLength']} / ${basket['max']} items",
              //       theme: ref.read(themeProvider).isDarkMode,
              //       color: colors.colorGrey,
              //     ),
              //     trailing: basketName == orderProv.selectedBsktName
              //         ? Icon(Icons.check, color: colors.ltpgreen)
              //         : null,
              //     onTap: () async {
              //       await orderProv.chngBsktName(basketName, context, true);
              //       Navigator.pop(context);
              //     },
              //   );
              // }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

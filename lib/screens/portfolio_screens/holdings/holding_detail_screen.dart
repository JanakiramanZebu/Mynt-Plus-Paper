import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/portfolio_model/holdings_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/alert_dialogue.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/scrip_info_btns.dart';
import '../../authentication/password/forgot_pass_unblock_user.dart';
import '../../market_watch/futures/future_screen.dart';
import '../../market_watch/scrip_depth_info.dart';

// Create a wrapper for ScripDepthInfo with custom configuration
class ScripDepthInfoWithHoldingConfig extends StatelessWidget {
  final DepthInputArgs wlValue;
  final String isBasket;
  final bool isFromHolding;

  const ScripDepthInfoWithHoldingConfig({
    Key? key,
    required this.wlValue,
    required this.isBasket,
    this.isFromHolding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScripDepthInfo(
      wlValue: wlValue,
      isBasket: isBasket,
    );
  }
}

// Create a wrapper for ScripInfoBtns with navigation lock
class ScripInfoButtonsWithLock extends StatefulWidget {
  final String exch;
  final String token;
  final String insName;
  final String tsym;

  const ScripInfoButtonsWithLock({
    Key? key,
    required this.exch,
    required this.token,
    required this.insName,
    required this.tsym,
  }) : super(key: key);

  @override
  State<ScripInfoButtonsWithLock> createState() =>
      _ScripInfoButtonsWithLockState();
}

class _ScripInfoButtonsWithLockState extends State<ScripInfoButtonsWithLock> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return ScripInfoBtns(
      exch: widget.exch,
      token: widget.token,
      insName: widget.insName,
      tsym: widget.tsym,
      navigationLock: (Function callback) async {
        if (_isNavigating) return;

        try {
          setState(() {
            _isNavigating = true;
          });

          await callback();
        } finally {
          // Reset the navigation lock after a delay
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isNavigating = false;
                });
              }
            });
          }
        }
      },
    );
  }
}

class HoldingDetailScreen extends ConsumerStatefulWidget {
  final ExchTsym exchTsym;
  final HoldingsModel holdingData;

  const HoldingDetailScreen(
      {Key? key, required this.exchTsym, required this.holdingData})
      : super(key: key);

  @override
  ConsumerState<HoldingDetailScreen> createState() =>
      _HoldingDetailScreenState();
}

class _HoldingDetailScreenState extends ConsumerState<HoldingDetailScreen>
    with SingleTickerProviderStateMixin {
  // Track if user has scrolled
  bool _hasScrolled = false;
  StreamSubscription? _socketSubscription;
  late ExchTsym _exchTsym;
  late HoldingsModel _holdingData;

  // Track touch events to prevent multiple button presses
  bool _isProcessingBuy = false;
  bool _isProcessingSell = false;

  // Added for optimization
  bool _isInitialized = false;
  bool _isLoading = true;

  // State variables for expandable sections
  bool _isMarketDepthExpanded = false;
  bool _isFuturesExpanded = false;

  // Add animation controller for smooth transitions
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Make copies of the data to avoid modifying the original objects
    _exchTsym = _copyExchTsym(widget.exchTsym);
    _holdingData = widget.holdingData;

    // Set up animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Don't pre-load data here - moved to didChangeDependencies
    setState(() {
      _isLoading = true;
    });
  }

  bool _didInitDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only run this once
    if (!_didInitDependencies) {
      _didInitDependencies = true;

      // Use a microtask to ensure widget is fully mounted
      Future.microtask(() {
        if (mounted) {
          _preLoadData();
        }
      });
    }
  }

  // Pre-load data to avoid flickering
  Future<void> _preLoadData() async {
    if (!mounted) return;

    // Get the latest socket data for this token immediately
    final wsProvider =
        ProviderScope.containerOf(context).read(websocketProvider);
    final socketData = wsProvider.socketDatas[_exchTsym.token];

    if (socketData != null) {
      // Update with initial socket data
      final lp = socketData['lp']?.toString();
      final pc = socketData['pc']?.toString();
      final chng = socketData['chng']?.toString();
      final c = socketData['c']?.toString();

      if (lp != null && lp != "null") {
        _exchTsym.lp = lp;
      }

      if (pc != null && pc != "null") {
        _exchTsym.perChange = pc;
      }

      if (chng != null && chng != "null") {
        _exchTsym.change = chng;
      }

      if (c != null && c != "null") {
        _exchTsym.close = c;
      }

      _updateProfitLossValues();
    }

    // Set up socket subscription only after initial data is set
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _setupSocketSubscription();
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Create a copy of the ExchTsym to avoid modifying the original
  ExchTsym _copyExchTsym(ExchTsym original) {
    final copy = ExchTsym();
    copy.token = original.token;
    copy.exch = original.exch;
    copy.tsym = original.tsym;
    copy.lp = original.lp;
    copy.perChange = original.perChange;
    copy.change = original.change;
    copy.close = original.close;
    copy.profitNloss = original.profitNloss;
    copy.pNlChng = original.pNlChng;
    copy.ls = original.ls;
    return copy;
  }

  // Set up the socket subscription
  void _setupSocketSubscription() {
    if (!mounted) return;

    try {
      final wsProvider =
          ProviderScope.containerOf(context).read(websocketProvider);

      _socketSubscription = wsProvider.socketDataStream.listen((socketData) {
        if (!mounted) return;

        final data = socketData[_exchTsym.token];
        if (data != null) {
          // Update with incremental socket data
          setState(() {
            final lp = data['lp']?.toString();
            final pc = data['pc']?.toString();
            final chng = data['chng']?.toString();

            if (_isValidValue(lp)) _exchTsym.lp = lp;
            if (_isValidValue(pc)) _exchTsym.perChange = pc;
            if (_isValidValue(chng)) _exchTsym.change = chng;

            _updateProfitLossValues();
          });
        }
      });
    } catch (e) {
      print("Error setting up socket subscription: $e");
    }
  }

  // Helper method to check if a value is valid
  bool _isValidValue(String? value) {
    return value != null &&
        value != "null" &&
        value != "0" &&
        value != "0.0" &&
        value != "0.00";
  }

  // Calculate profit and loss values
  void _updateProfitLossValues() {
    final ltp = double.tryParse(_exchTsym.lp ?? "0.0") ?? 0.0;
    final qty = _holdingData.currentQty ?? 0;
    final avgPrice = double.tryParse(_holdingData.upldprc ?? "0.0") ?? 0.0;

    if (ltp > 0 && qty > 0 && avgPrice > 0) {
      // Current value
      _holdingData.currentValue = (ltp * qty).toStringAsFixed(2);

      // Profit/Loss
      final pnl = (ltp - avgPrice) * qty;
      _exchTsym.profitNloss = pnl.toStringAsFixed(2);

      // P&L Percentage
      if (avgPrice > 0) {
        final pnlPerc = (pnl / (avgPrice * qty)) * 100;
        _exchTsym.pNlChng = pnlPerc.toStringAsFixed(2);
      }
    }
  }

  // Handle buy button click
  Future<void> _handleBuy() async {
    if (_isProcessingBuy) return;

    try {
      setState(() {
        _isProcessingBuy = true;
      });

      final wsProvider =
          ProviderScope.containerOf(context).read(websocketProvider);
      final mwProvider =
          ProviderScope.containerOf(context).read(marketWatchProvider);

      wsProvider.establishConnection(
          channelInput: "${_exchTsym.exch}|${_exchTsym.token}#",
          task: "t",
          context: context);

      await mwProvider.fetchScripInfo(
          "${_exchTsym.token}", '${_exchTsym.exch}', context, true);

      if (!mounted) return;

      final OrderScreenArgs orderArgs = OrderScreenArgs(
          exchange: '${_exchTsym.exch}',
          tSym: '${_exchTsym.tsym}',
          token: '',
          transType: true,
          prd: '${_holdingData.prd}',
          lotSize: '${_exchTsym.ls}',
          orderTpye: "${_holdingData.sPrdtAli}",
          isExit: false,
          ltp: '${_exchTsym.lp}',
          perChange: '${_exchTsym.perChange}',
          holdQty: '',
          isModify: false,
          raw: {});

      if (mwProvider.scripInfoModel != null) {
        Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
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

  // Handle sell button click
  Future<void> _handleSell() async {
    if (_isProcessingSell) return;

    try {
      setState(() {
        _isProcessingSell = true;
      });

      if (_holdingData.saleableQty == 0) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialogue(
                scripName: "${_exchTsym.tsym}",
                exch: "${_exchTsym.exch}",
                content:
                    'You are unable to exit because there are no sellable quantity.',
              );
            }).then((_) {
          if (mounted) {
            setState(() {
              _isProcessingSell = false;
            });
          }
        });
        return;
      }

      final wsProvider =
          ProviderScope.containerOf(context).read(websocketProvider);
      final mwProvider =
          ProviderScope.containerOf(context).read(marketWatchProvider);

      wsProvider.establishConnection(
          channelInput: "${_exchTsym.exch}|${_exchTsym.token}#",
          task: "t",
          context: context);

      await mwProvider.fetchScripInfo(
          "${_exchTsym.token}", '${_exchTsym.exch}', context, true);

      if (!mounted) return;

      final OrderScreenArgs orderArgs = OrderScreenArgs(
          exchange: '${_exchTsym.exch}',
          tSym: '${_exchTsym.tsym}',
          token: '',
          transType: false,
          lotSize: '${_exchTsym.ls}',
          isExit: true,
          ltp: '${_exchTsym.lp}',
          perChange: '${_exchTsym.perChange}',
          orderTpye: "${_holdingData.sPrdtAli}",
          holdQty: "${_holdingData.saleableQty ?? 0}",
          isModify: false,
          raw: {});

      if (mwProvider.scripInfoModel != null) {
        Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
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

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final scripInfo = ref.watch(marketWatchProvider);
    final depthData = ref.watch(marketWatchProvider).getQuotes;
    final userProfile = ref.watch(userProfileProvider);
    final ledgerdate = ref.watch(ledgerProvider);
    final value = ledgerdate.pledgeandunpledge?.data?.isNotEmpty == true
        ? ledgerdate.pledgeandunpledge!.data![0]
        : null;

    DepthInputArgs depthArgs = DepthInputArgs(
        exch: _exchTsym.exch ?? "",
        token: _exchTsym.token ?? "",
        tsym: scripInfo.getQuotes?.tsym ?? '',
        instname: scripInfo.getQuotes?.instname ?? "",
        symbol: scripInfo.getQuotes?.symbol ?? '',
        expDate: scripInfo.getQuotes?.expDate ?? '',
        option: scripInfo.getQuotes?.option ?? '');

    // Show loading state during initial load
    // if (_isLoading) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       elevation: .2,
    //       leadingWidth: 41,
    //       titleSpacing: 6,
    //       leading: const CustomBackBtn(),
    //       shadowColor:
    //           theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
    //       title: TextWidget.titleText(
    //           text: "${_exchTsym.tsym}", theme: theme.isDarkMode, fw: 1),
    //     ),
    //     body: const Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.99,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xff999999),
                      blurRadius: 4.0,
                      offset: Offset(2.0, 0.0))
                ]),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  // Scrollable section that includes the header
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification) {
                          setState(() {
                            _hasScrolled =
                                scrollNotification.metrics.pixels > 0;
                          });
                        }
                        return true;
                      },
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Header section (previously fixed, now part of scrollable content)
                          Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorWhite,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              boxShadow: _hasScrolled
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                const CustomDragHandler(),
                                // clickable part of the header
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    // borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      // Add delay for visual feedback
                                      await Future.delayed(
                                          const Duration(milliseconds: 150));

                                      await scripInfo.chngDephBtn("Overview");
                                      scripInfo.scripdepthsize(true);
                                      showModalBottomSheet(
                                          barrierColor:
                                              Colors.black.withOpacity(0.3),
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          isDismissible: true,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(16))),
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) =>
                                              ScripDepthInfoWithHoldingConfig(
                                                  wlValue: depthArgs,
                                                  isBasket: '',
                                                  isFromHolding: true));
                                    },
                                    splashColor: theme.isDarkMode
                                        ? Colors.white.withOpacity(0.15)
                                        : Colors.black.withOpacity(0.15),
                                    highlightColor: theme.isDarkMode
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.black.withOpacity(0.08),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextWidget.headText(
                                                          text:
                                                              "${_exchTsym.tsym?.replaceAll("-EQ", "").toUpperCase() ?? ''} ",
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textPrimaryDark
                                                              : colors
                                                                  .textPrimaryLight,
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 0),
                                                      const SizedBox(height: 6),
                                                      FadeTransition(
                                                        opacity:
                                                            _animationController,
                                                        child: TextWidget.titleText(
                                                            text: "${_exchTsym.lp != "null" ? _exchTsym.lp ?? _exchTsym.close ?? 0.00 : '0.00'}",
                                                            color: (_exchTsym.change == "null" || _exchTsym.change == null) || _exchTsym.change == "0.00"
                                                                ? colors.textSecondaryLight
                                                                : (_exchTsym.change?.startsWith("-") == true || _exchTsym.perChange?.startsWith("-") == true)
                                                                    ? theme.isDarkMode
                                                                        ? colors.lossDark
                                                                        : colors.lossLight
                                                                    : theme.isDarkMode
                                                                        ? colors.successDark
                                                                        : colors.successLight,
                                                            theme: false,
                                                            fw: 3),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      TextWidget.paraText(
                                                          text:
                                                              "${(double.tryParse(_exchTsym.change ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(_exchTsym.perChange ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                              : colors
                                                                  .textSecondaryLight,
                                                          theme: false,
                                                          fw: 3)
                                                    ]),
                                                Row(
                                                  children: [
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
                                          ]),
                                    ),
                                  ),
                                ),

                                // Add More and Exit buttons
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      colors.btnOutlinedBorder,
                                                  width: 1,
                                                ),
                                                color: colors.btnBg,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Material(
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
                                                onTap: _isProcessingBuy
                                                    ? null
                                                    : _handleBuy,
                                                child: Center(
                                                  child: _isProcessingBuy
                                                      ? SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    colors
                                                                        .secondary),
                                                          ),
                                                        )
                                                      : TextWidget.subText(
                                                          text: "Add",
                                                          theme: false,
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .primaryDark
                                                              : colors
                                                                  .primaryLight,
                                                          fw: 1),
                                                ),
                                              ),
                                            )),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: colors
                                                        .btnOutlinedBorder,
                                                    width: 1,
                                                  ),
                                                  color: colors.btnBg,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Material(
                                                color: Colors.transparent,
                                                shape:
                                                    const BeveledRectangleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const BeveledRectangleBorder(),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.highlightDark
                                                      : colors.highlightLight,
                                                  onTap: _isProcessingSell
                                                      ? null
                                                      : _handleSell,
                                                  child: Center(
                                                    child: _isProcessingSell
                                                        ? SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      colors
                                                                          .secondary),
                                                            ),
                                                          )
                                                        : TextWidget.subText(
                                                            text: "Exit",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .primaryDark
                                                                : colors
                                                                    .primaryLight,
                                                            fw: 1),
                                                  ),
                                                ),
                                              )))
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          onTap: () async {
                                            if (ledgerdate.pledgeandunpledge ==
                                                null) {
                                              await ledgerdate
                                                  .getCurrentDate("pandu");
                                              ledgerdate.fetchpledgeandunpledge(
                                                  context);
                                            }
                                            Navigator.pushNamed(
                                                context, Routes.pledgeandun,
                                                arguments: "DDDDD");
                                          },
                                          splashColor: theme.isDarkMode
                                              ? colors.splashColorDark
                                              : colors.splashColorLight,
                                          highlightColor: theme.isDarkMode
                                              ? colors.highlightDark
                                              : colors.highlightLight,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextWidget.subText(
                                                    text: "Pledge/Unpledge",
                                                    color: colors
                                                        .btnOutlinedBorder,
                                                    theme: false,
                                                    fw: 0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget.subText(
                                              text: "P&L",
                                              theme: false,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                              fw: 3),

                                          // Animate P&L changes
                                          FadeTransition(
                                            opacity: _animationController,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextWidget.titleText(
                                                    text:
                                                        "${_exchTsym.profitNloss}",
                                                    theme: false,
                                                    color: _exchTsym.profitNloss
                                                                ?.startsWith(
                                                                    "-") ==
                                                            true
                                                        ? theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight
                                                        : theme.isDarkMode
                                                            ? colors.successDark
                                                            : colors
                                                                .successLight,
                                                    fw: 3),
                                                SizedBox(height: 4),
                                                TextWidget.subText(
                                                    text:
                                                        " (${_exchTsym.pNlChng})%",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 3),
                                              ],
                                            ),
                                          ),
                                        ])),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Divider(
                                thickness: 1,
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                          ),

                          // Details section
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                data(
                                    "Non POA / Sell",
                                    "${_holdingData.saleableQty ?? 0}/${_holdingData.npoadqty ?? 0}",
                                    theme),
                                data("Avg Price",
                                    "${_holdingData.upldprc ?? 0}", theme),
                                data(
                                    "Product",
                                    _holdingData.sPrdtAli != "null"
                                        ? "${_holdingData.sPrdtAli}"
                                        : "CNC",
                                    theme),
                                data(
                                    "Invested",
                                    "${_holdingData.invested == "0.00" ? _exchTsym.close ?? 0.00 : _holdingData.invested ?? 0.00}",
                                    theme),
                                data(
                                    "Current",
                                    (int.parse("${_holdingData.currentQty ?? 0}") *
                                            double.parse(
                                                _exchTsym.lp?.toString() ??
                                                    "0.0"))
                                        .toStringAsFixed(2),
                                    theme),
                                if (_holdingData.btstqty != "0") ...[
                                  data("T1 Qty", "${_holdingData.btstqty ?? 0}",
                                      theme),
                                ],
                                if (_holdingData.rpnl != null &&
                                    _holdingData.rpnl != "0") ...[
                                  data("Realised P&L",
                                      "${_holdingData.rpnl ?? 0}", theme),
                                ],
                                // value.initiated == "0" &&
                                //         value.status == 'Ok' &&
                                //         (double.parse(value.nSOHQTY.toString())
                                //                     .toInt()) +
                                //                 (double.parse(
                                //                         value.sOHQTY.toString())
                                //                     .toInt()) !=
                                data(
                                    "Pledged Qty",
                                    "${value?.dummvalue != 'null' ? "${value?.dummvalue!} /" : ''} ${(double.parse(value!.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())}",
                                    theme),
                                // : const SizedBox.shrink(),
                              ]),
                        ], // Close ListView children
                      ),
                    ),
                  ),
                ], // Close Column children
              ),
            ),
          );
        });
  }

  // Helper methods to determine when to show sections
  bool _shouldShowConditionalSection() {
    // Add logic similar to scrip_depth_info.dart
    // For now, show for equity instruments
    return _exchTsym.exch == 'NSE' || _exchTsym.exch == 'BSE';
  }

  // Market Depth expandable section
  Widget _buildMarketDepthSection(ThemesProvider theme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              onTap: () async {
                // Add delay for visual feedback
                await Future.delayed(const Duration(milliseconds: 150));

                // Toggle market depth expansion
                setState(() {
                  _isMarketDepthExpanded = !_isMarketDepthExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.show_chart,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                              text: "Market Depth",
                              theme: theme.isDarkMode,
                              fw: 1),
                          const SizedBox(height: 2),
                          TextWidget.paraText(
                              text: "View bid/ask orders and market depth",
                              color: const Color(0xff666666),
                              theme: theme.isDarkMode,
                              fw: 0),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isMarketDepthExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xff666666),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Expandable Market Depth Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isMarketDepthExpanded
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      TextWidget.paraText(
                          text: "Market depth data would be displayed here",
                          color: const Color(0xff666666),
                          theme: theme.isDarkMode,
                          fw: 0),
                      const SizedBox(height: 8),
                      TextWidget.paraText(
                          text: "Bid/Ask orders, quantities, and prices",
                          color: const Color(0xff666666),
                          theme: theme.isDarkMode,
                          fw: 0),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Futures expandable section
  Widget _buildFuturesSection(ThemesProvider theme, scripInfo) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              onTap: () async {
                // Add delay for visual feedback
                await Future.delayed(const Duration(milliseconds: 150));
                await scripInfo.requestWSFut(
                    context: context, isSubscribe: true);
                // Toggle futures expansion
                setState(() {
                  _isFuturesExpanded = !_isFuturesExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.trending_up,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                              text: "Futures", theme: theme.isDarkMode, fw: 1),
                          const SizedBox(height: 2),
                          TextWidget.paraText(
                              text: "View futures contracts and data",
                              color: const Color(0xff666666),
                              theme: theme.isDarkMode,
                              fw: 0),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isFuturesExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xff666666),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Expandable Futures Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isFuturesExpanded
              ? const FutureScreen()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Fundamentals navigation section
  Widget _buildFundamentalsSection(ThemesProvider theme, scripInfo, depthData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          onTap: () async {
            DepthInputArgs depthArgs = DepthInputArgs(
                exch: _exchTsym.exch ?? "",
                token: _exchTsym.token ?? "",
                tsym: scripInfo.getQuotes?.tsym ?? '',
                instname: scripInfo.getQuotes?.instname ?? "",
                symbol: scripInfo.getQuotes?.symbol ?? '',
                expDate: scripInfo.getQuotes?.expDate ?? '',
                option: scripInfo.getQuotes?.option ?? '');
            // Add delay for visual feedback
            await Future.delayed(const Duration(milliseconds: 150));

            if (scripInfo.fundamentalData == null ||
                scripInfo.fundamentalData?.msg == "no data found") {
              await scripInfo.fetchFundamentalData(
                  tradeSym: "${_exchTsym.exch}:${_exchTsym.tsym}");
            }

            if (!mounted) return;

            if (scripInfo.fundamentalData != null &&
                scripInfo.fundamentalData?.msg != "no data found") {
              // Reset state before navigation
              await scripInfo.chngDephBtn("Overview");

              await Navigator.pushNamed(
                context,
                Routes.fundamentalDetail,
                arguments: {
                  "wlValue": depthArgs,
                  "depthData": depthData,
                },
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? const Color(0xffB5C0CF).withOpacity(.15)
                        : const Color(0xffF1F3F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.analytics_outlined,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                          text: "Fundamentals", theme: theme.isDarkMode, fw: 1),
                      const SizedBox(height: 2),
                      TextWidget.paraText(
                          text: "View fundamental analysis and ratios",
                          color: const Color(0xff666666),
                          theme: theme.isDarkMode,
                          fw: 0),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xff666666),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding data(String name, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                  text: name,
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0),
              TextWidget.subText(
                  text: value,
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            thickness: 1,
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/marketwatch_model/get_quotes.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/screens/web/market_watch/scrip_depth_info_web.dart';
import 'package:mynt_plus/screens/web/market_watch/tv_chart/webview_chart.dart';
import 'package:mynt_plus/screens/web/market_watch/options/option_chain_ss_web.dart';
import 'package:mynt_plus/screens/web/market_watch/search_dialog_web.dart';
import 'package:mynt_plus/screens/web/market_watch/set_alert_web.dart';
import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../utils/responsive_navigation.dart';
import '../../../../provider/websocket_provider.dart';

class ChartWithDepthWeb extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  final String isBasket;

  const ChartWithDepthWeb(
      {super.key, required this.wlValue, this.isBasket = ""});

  @override
  ConsumerState<ChartWithDepthWeb> createState() => _ChartWithDepthWebState();
}

class _ChartWithDepthWebState extends ConsumerState<ChartWithDepthWeb>
    with TickerProviderStateMixin {
  String? _loadedToken;
  TabController? _tabController;
  VoidCallback?
      _tabControllerListener; // Store listener reference for proper cleanup
  int _selectedTabIndex = 0; // 0 for Overview, 1 for Chart, 2 for Options
  bool _isBasketMode = false; // Track basket mode from OptionChainSSWeb
  VoidCallback? _toggleBasketModeCallback; // Callback to toggle basket mode
  BuildContext? _storedContext; // Store context for cleanup in dispose
  ProviderContainer? _storedContainer; // Store container for cleanup in dispose
  // bool _isDepthVisible = false; // Controlled by wlValue.showDepthInitially

  @override
  void initState() {
    super.initState();
    // Store context and container for later use in dispose
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _storedContext = context;
        try {
          _storedContainer = ProviderScope.containerOf(context, listen: false);
        } catch (e) {
          // Container might not be available yet
        }
        // Subscribe to depth data for Overview tab (default tab)
        // Pass context and scrip info to trigger WebSocket depth subscription (task "d")
        final mw = ref.read(marketWatchProvider);
        // Only subscribe if depth should be visible (Overview tab is default)
        // The initial tab is 0 (Overview) unless it's an option
        final initialTabIsOverview = !widget.wlValue.isOption;
        if (initialTabIsOverview || mw.isDepthVisible) {
          mw.setIsDepthVisibleWeb(
            true,
            context: context,
            exch: widget.wlValue.exch,
            token: widget.wlValue.token,
            tsym: widget.wlValue.tsym,
          );
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChartWithDepthWeb oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if isOption flag changed (even for the same scrip)
    if (oldWidget.wlValue.isOption != widget.wlValue.isOption) {
      if (_tabController != null) {
        // Options tab is now at index 2 (Overview=0, Chart=1, Options=2)
        final targetIndex = widget.wlValue.isOption ? 2 : 0;
        if (_tabController!.index != targetIndex) {
          _tabController!.animateTo(targetIndex);
        }
      }
    }

    if (oldWidget.wlValue.token != widget.wlValue.token ||
        oldWidget.wlValue.exch != widget.wlValue.exch) {
      // Reset depth subscription for new scrip when scrip changes
      // Delay provider modification until after build phase completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final mw = ref.read(marketWatchProvider);
          // If on Overview tab, re-subscribe to depth for the new scrip
          final isOverviewTab = (_tabController?.index ?? 0) == 0;
          if (isOverviewTab || mw.isDepthVisible) {
            mw.setIsDepthVisibleWeb(
              true,
              context: context,
              exch: widget.wlValue.exch,
              token: widget.wlValue.token,
              tsym: widget.wlValue.tsym,
            );
          }
        }
      });

      Future.microtask(() async {
        await _ensureDataLoaded(force: true);

        // If Options tab is active when scrip changes, prepare options for new scrip
        // Options tab is now at index 2 (Overview=0, Chart=1, Options=2)
        final mw = ref.read(marketWatchProvider);
        final hasOptions =
            mw.getOptionawait(widget.wlValue.exch, widget.wlValue.token);
        if (hasOptions && (_tabController?.index ?? 0) == 2) {
          mw.setOptionScript(context, widget.wlValue.exch, widget.wlValue.token,
              widget.wlValue.tsym);
        }
      });
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing to prevent memory leaks
    if (_tabController != null && _tabControllerListener != null) {
      _tabController!.removeListener(_tabControllerListener!);
      _tabControllerListener = null;
    }
    _tabController?.dispose();
    _tabController = null;

    // Unsubscribe from depth data using stored container (ref is not available in dispose)
    if (_storedContainer != null) {
      try {
        final mw = _storedContainer!.read(marketWatchProvider);
        if (_storedContext != null && _storedContext!.mounted) {
          mw.unsubscribeFromDepthData(context: _storedContext);
        } else {
          // Context not mounted, but still try to unsubscribe without context
          mw.unsubscribeFromDepthData(context: _storedContext);
        }
      } catch (e) {
        // Depth will be cleaned up when scrip changes anyway
        print(
            '⚠️ [ChartWithDepthWeb] Error unsubscribing from depth in dispose: $e');
      }
    }

    super.dispose();
  }

  Future<void> _ensureDataLoaded({bool force = false}) async {
    final mw = ref.read(marketWatchProvider);
    final currentToken = mw.getQuotes?.token?.toString();
    final targetToken = widget.wlValue.token;

    if (force || _loadedToken != targetToken || currentToken != targetToken) {
      // Only load if it's a different scrip - calldepthApis handles duplicate prevention internally
      mw.scripdepthsize(false);
      await mw.calldepthApis(context, widget.wlValue, "");
      // Keep chart in sync with the same scrip
      mw.setChartScript(
          widget.wlValue.exch, widget.wlValue.token, widget.wlValue.tsym);
      _loadedToken = targetToken;
    }
  }

  void _setupTabControllerIfNeeded({required bool hasOptions}) {
    // Tab structure:
    // - hasOptions: [Overview, Chart, Options] (3 tabs)
    // - !hasOptions: [Overview, Chart] (2 tabs)
    final targetLength = hasOptions ? 3 : 2;

    if (_tabController == null || _tabController!.length != targetLength) {
      // Remove old listener before disposing to prevent memory leaks
      if (_tabController != null && _tabControllerListener != null) {
        _tabController!.removeListener(_tabControllerListener!);
        _tabControllerListener = null;
      }
      _tabController?.dispose();
      // Initial index: Options tab is at index 2 when hasOptions
      final initialIndex = widget.wlValue.isOption && hasOptions ? 2 : 0;
      _tabController = TabController(
          length: targetLength, vsync: this, initialIndex: initialIndex);
      _selectedTabIndex = _tabController!.index;
      // Store listener reference for proper cleanup
      _tabControllerListener = () {
        // Update UI when tab changes (for search icon visibility)
        if (mounted) {
          setState(() {
            _selectedTabIndex = _tabController!.index;
          });
          // Handle depth visibility based on tab
          final mw = ref.read(marketWatchProvider);
          if (_tabController!.index == 0) {
            // Overview tab: show depth and subscribe to depth WebSocket (task "d")
            mw.setIsDepthVisibleWeb(
              true,
              context: context,
              exch: widget.wlValue.exch,
              token: widget.wlValue.token,
              tsym: widget.wlValue.tsym,
            );
          } else if (_tabController!.index == 1) {
            // Chart tab: hide depth
            mw.setIsDepthVisibleWeb(false, context: context);
          }
        }
        // Options tab is now at index 2
        if (hasOptions &&
            _tabController!.index == 2 &&
            _tabController!.indexIsChanging == false) {
          // Prepare option chain data when switching to Options tab
          final mw = ref.read(marketWatchProvider);
          mw.setOptionScript(context, widget.wlValue.exch, widget.wlValue.token,
              widget.wlValue.tsym);
        }
      };
      _tabController!.addListener(_tabControllerListener!);
    }
  }

  Future<void> _placeOrderInput(
      BuildContext ctx, GetQuotes? depthData, bool transType) async {
    if (depthData == null) return;

    await ref.read(marketWatchProvider).fetchScripInfo(
        widget.wlValue.token, widget.wlValue.exch, context, true);

    // Use lot size from scripInfoModel if available, otherwise use depthData
    final lotSize = depthData.ls?.isNotEmpty == true
        ? depthData.ls
        : ref.read(marketWatchProvider).scripInfoModel?.ls.toString();

    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: widget.wlValue.exch,
        tSym: widget.wlValue.tsym,
        isExit: false,
        token: widget.wlValue.token,
        transType: transType,
        lotSize: lotSize,
        ltp: "${depthData.lp ?? depthData.c ?? 0.00}",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {});

    ResponsiveNavigation.toPlaceOrderScreen(
      context: ctx,
      arguments: {
        "orderArg": orderArgs,
        "scripInfo": ref.read(marketWatchProvider).scripInfoModel!,
        "isBskt": widget.isBasket
      },
    );
  }

  void _showStrikesDropdown(BuildContext context, MarketWatchProvider mw) {
    final numStrikes = mw.numStrikes;
    final numStrike = mw.numStrike;

    shadcn.showPopover(
      context: context,
      alignment: Alignment.bottomCenter,
      offset: const Offset(0, 4),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(context).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(popoverContext).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 150,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: numStrikes.map((String value) {
                    final isSelected = value == numStrike;
                    return _buildStrikeMenuItem(
                      popoverContext,
                      value,
                      isSelected,
                      () async {
                        shadcn.closeOverlay(popoverContext);
                        mw.selecNumStrike(value);
                        await mw.fetchOPtionChain(
                          context: popoverContext,
                          exchange: mw.optionExch!,
                          numofStrike: value,
                          strPrc: mw.optionStrPrc,
                          tradeSym: mw.selectedTradeSym!,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrikeMenuItem(
    BuildContext context,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: resolveThemeColor(
          context,
          dark: MyntColors.rippleDark,
          light: MyntColors.rippleLight,
        ),
        highlightColor: resolveThemeColor(
          context,
          dark: MyntColors.highlightDark,
          light: MyntColors.highlightLight,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: isActive ? MyntFonts.semiBold : MyntFonts.medium,
                    color: isActive
                        ? resolveThemeColor(
                            context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary,
                          )
                        : resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.check,
                  size: 18,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mw = ref.watch(marketWatchProvider);
    final hasOptions =
        mw.getOptionawait(widget.wlValue.exch, widget.wlValue.token);
    final depthData = mw.getQuotes;
    _setupTabControllerIfNeeded(hasOptions: hasOptions);

    return Container(
      color: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Header - Full Width
          Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: shadcn.Theme.of(context).colorScheme.card,
                        border: Border(
                          bottom: BorderSide(
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.dividerDark,
                              light: MyntColors.divider,
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Tabs
                          _buildSegmentedControl(context, hasOptions),
                          const Spacer(),
                          // Right side: Buy/Sell/Alert/Sidebar icons
                          if (widget.wlValue.instname != "UNDIND" &&
                              widget.wlValue.instname != "COM") ...[
                            // Buy button
                            SizedBox(
                              width: 70,
                              height: 32,
                              child: MyntButton(
                                label: "Buy",
                                size: MyntButtonSize.small,
                                backgroundColor: resolveThemeColor(
                                    context,
                                    dark: MyntColors.primary,
                                    light: MyntColors.primary),
                                textColor: Colors.white,
                                onPressed: () async {
                                  await _placeOrderInput(context, depthData, true);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sell button
                            SizedBox(
                              width: 70,
                              height: 32,
                              child: MyntButton(
                                label: "Sell",
                                size: MyntButtonSize.small,
                                backgroundColor: resolveThemeColor(
                                    context,
                                    dark: MyntColors.tertiary,
                                    light: MyntColors.tertiary),
                                textColor: Colors.white,
                                onPressed: () async {
                                  await _placeOrderInput(context, depthData, false);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Create Alert icon
                            Tooltip(
                              message: "Set Alert",
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: resolveThemeColor(
                                    context,
                                    dark: MyntColors.rippleDark,
                                    light: MyntColors.rippleLight,
                                  ),
                                  highlightColor: resolveThemeColor(
                                    context,
                                    dark: MyntColors.highlightDark,
                                    light: MyntColors.highlightLight,
                                  ),
                                  onTap: () {
                                    if (depthData == null) return;
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext dialogContext) {
                                        return SetAlertWeb(
                                          depthdata: depthData,
                                          wlvalue: widget.wlValue,
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.notifications_none_outlined,
                                      size: 20,
                                      color: resolveThemeColor(
                                        context,
                                        dark: MyntColors.iconDark,
                                        light: MyntColors.icon,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Sidebar toggle icon
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              splashColor: resolveThemeColor(
                                context,
                                dark: MyntColors.rippleDark,
                                light: MyntColors.rippleLight,
                              ),
                              highlightColor: resolveThemeColor(
                                context,
                                dark: MyntColors.highlightDark,
                                light: MyntColors.highlightLight,
                              ),
                              onTap: () {
                                ref
                                    .read(marketWatchProvider)
                                    .setIsDepthVisibleWeb(
                                      !mw.isDepthVisible,
                                      context: context,
                                    );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  mw.isDepthVisible
                                      ? Icons.view_sidebar
                                      : Icons.view_sidebar_outlined,
                                  size: 20,
                                  color: mw.isDepthVisible
                                      ? resolveThemeColor(context,
                                          dark: MyntColors.primaryDark,
                                          light: MyntColors.primary)
                                      : resolveThemeColor(context,
                                          dark: MyntColors.iconDark,
                                          light: MyntColors.icon),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Secondary Header (Options-specific controls) - Only visible when Options tab is active
                    if (hasOptions && _selectedTabIndex == 2)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: shadcn.Theme.of(context).colorScheme.card,
                          border: Border(
                            bottom: BorderSide(
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.dividerDark,
                                light: MyntColors.divider,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Symbol name + LTP + Price change (Options only)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${(depthData?.symname ?? depthData?.symbol ?? depthData?.tsym ?? widget.wlValue.symbol).replaceAll('-EQ', '').toUpperCase()}${depthData?.expDate ?? widget.wlValue.expDate} ${depthData?.option ?? widget.wlValue.option} ",
                                  overflow: TextOverflow.ellipsis,
                                  style: MyntWebTextStyles.symbol(
                                    context,
                                    fontWeight: MyntFonts.medium,
                                    darkColor: MyntColors.textPrimaryDark,
                                    lightColor: MyntColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StreamBuilder<Map>(
                                  stream: ref
                                      .read(websocketProvider)
                                      .socketDataStream,
                                  builder: (context, snapshot) {
                                    final socketDatas = snapshot.data ?? {};
                                    final currentToken =
                                        depthData?.token?.toString() ??
                                            widget.wlValue.token;
                                    String ltp =
                                        depthData?.lp ?? depthData?.c ?? '0.00';
                                    String ch = depthData?.chng ?? '0.00';
                                    String pc = depthData?.pc ?? '0.00';
                                    if (socketDatas.containsKey(currentToken)) {
                                      final s = socketDatas[currentToken];
                                      ltp = "${s['lp'] ?? s['c'] ?? ltp}";
                                      ch = "${s['chng'] ?? ch}";
                                      pc = "${s['pc'] ?? pc}";
                                    }
                                    final ltpStr = (double.tryParse(ltp) ?? 0)
                                        .toStringAsFixed(2);
                                    final chVal = double.tryParse(ch) ?? 0;
                                    final pcVal = double.tryParse(pc) ?? 0;
                                    final chStr = chVal.toStringAsFixed(2);
                                    final pcStr = pcVal.toStringAsFixed(2);
                                    final isUp = pcVal >= 0;

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          ltpStr,
                                          style: MyntWebTextStyles.price(
                                            context,
                                            fontWeight: MyntFonts.medium,
                                            color: isUp
                                                ? resolveThemeColor(context,
                                                    dark: MyntColors.profitDark,
                                                    light: MyntColors.profit)
                                                : resolveThemeColor(context,
                                                    dark: MyntColors.lossDark,
                                                    light: MyntColors.loss),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "$chStr ($pcStr%)",
                                          style: MyntWebTextStyles.priceChange(
                                            context,
                                            fontWeight: MyntFonts.medium,
                                            darkColor:
                                                MyntColors.textPrimaryDark,
                                            lightColor: MyntColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            // Expiry date selector
                            Builder(
                              builder: (buttonContext) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    splashColor: resolveThemeColor(
                                      context,
                                      dark: MyntColors.rippleDark,
                                      light: MyntColors.rippleLight,
                                    ),
                                    highlightColor: resolveThemeColor(
                                      context,
                                      dark: MyntColors.highlightDark,
                                      light: MyntColors.highlightLight,
                                    ),
                                    onTap: () {
                                      _showExpiryDatePopup(buttonContext, mw);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: resolveThemeColor(
                                            context,
                                            dark: MyntColors.dividerDark,
                                            light: MyntColors.divider,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            mw.selectedExpDate
                                                    ?.replaceAll("-", " ") ??
                                                '',
                                            style: MyntWebTextStyles.body(
                                              context,
                                              fontWeight: MyntFonts.medium,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 16,
                                            color: resolveThemeColor(
                                              context,
                                              dark: MyntColors.iconDark,
                                              light: MyntColors.icon,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            // Strikes dropdown
                            Builder(
                              builder: (buttonContext) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    splashColor: resolveThemeColor(
                                      context,
                                      dark: MyntColors.rippleDark,
                                      light: MyntColors.rippleLight,
                                    ),
                                    highlightColor: resolveThemeColor(
                                      context,
                                      dark: MyntColors.highlightDark,
                                      light: MyntColors.highlightLight,
                                    ),
                                    onTap: () {
                                      _showStrikesDropdown(buttonContext, mw);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: resolveThemeColor(
                                            context,
                                            dark: MyntColors.dividerDark,
                                            light: MyntColors.divider,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${mw.numStrike} Strike",
                                            style: MyntWebTextStyles.body(
                                              context,
                                              fontWeight: MyntFonts.medium,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 16,
                                            color: resolveThemeColor(
                                              context,
                                              dark: MyntColors.iconDark,
                                              light: MyntColors.icon,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            // Basket mode icon
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: resolveThemeColor(
                                  context,
                                  dark: MyntColors.rippleDark,
                                  light: MyntColors.rippleLight,
                                ),
                                highlightColor: resolveThemeColor(
                                  context,
                                  dark: MyntColors.highlightDark,
                                  light: MyntColors.highlightLight,
                                ),
                                onTap: () {
                                  _toggleBasketModeCallback?.call();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    _isBasketMode
                                        ? Icons.shopping_basket
                                        : Icons.shopping_basket_outlined,
                                    size: 18,
                                    color: _isBasketMode
                                        ? MyntColors.primary
                                        : resolveThemeColor(
                                            context,
                                            dark: MyntColors.iconDark,
                                            light: MyntColors.icon,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Search icon
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: resolveThemeColor(
                                  context,
                                  dark: MyntColors.rippleDark,
                                  light: MyntColors.rippleLight,
                                ),
                                highlightColor: resolveThemeColor(
                                  context,
                                  dark: MyntColors.highlightDark,
                                  light: MyntColors.highlightLight,
                                ),
                                onTap: () {
                                  // Open search dialog for options
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.search,
                                    size: 18,
                                    color: resolveThemeColor(
                                      context,
                                      dark: MyntColors.iconDark,
                                      light: MyntColors.icon,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          // Content area below headers
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Chart/Options area - 100% when depth hidden, 70% when visible
                Expanded(
                  flex: mw.isDepthVisible ? 7 : 1,
                  child: (hasOptions && _selectedTabIndex == 2)
                      ? OptionChainSSWeb(
                          wlValue: widget.wlValue,
                          onBasketModeChanged: (bool isBasketMode) {
                            setState(() {
                              _isBasketMode = isBasketMode;
                            });
                          },
                          onToggleCallbackReady:
                              (VoidCallback toggleCallback) {
                            setState(() {
                              _toggleBasketModeCallback = toggleCallback;
                            });
                          },
                        )
                      : ChartScreenWebViews(
                          chartArgs: ChartArgs(
                            exch: widget.wlValue.exch,
                            tsym: widget.wlValue.tsym,
                            token: widget.wlValue.token,
                          ),
                        ),
                ),
                // Divider between chart and depth (only when depth is visible)
                if (mw.isDepthVisible)
                  Container(
                    width: 1,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.dividerDark,
                      light: MyntColors.divider,
                    ),
                  ),
                // Depth/Overview area - 30% (only when visible)
                if (mw.isDepthVisible)
                  Expanded(
                    flex: 3,
                    child: ScripDepthInfoWeb(
                      wlValue: widget.wlValue,
                      isBasket: widget.isBasket,
                      onClose: () {
                        mw.setIsDepthVisibleWeb(false);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExpiryDatePopup(BuildContext context, MarketWatchProvider mw) {
    shadcn.showPopover(
      context: context,
      alignment: Alignment.bottomCenter,
      offset: const Offset(0, 4),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(context).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(context).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 200,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: mw.sortDate.map((date) {
                      return _buildExpiryMenuItem(
                        popoverContext,
                        date,
                        mw,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiryMenuItem(
    BuildContext context,
    String date,
    MarketWatchProvider mw,
  ) {
    final isSelected = date == mw.selectedExpDate;
    final primaryColor = resolveThemeColor(
      context,
      dark: MyntColors.primaryDark,
      light: MyntColors.primary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          shadcn.closeOverlay(context);
          if (date != mw.selectedExpDate) {
            for (var i = 0; i < (mw.optExp?.length ?? 0); i++) {
              if (date == mw.optExp![i].exd) {
                mw.selecTradSym("${mw.optExp![i].tsym}");
                mw.optExch("${mw.optExp![i].exch}");
              }
            }
            mw.selecexpDate(date);

            await mw.fetchOPtionChain(
              context: this.context,
              exchange: mw.optionExch!,
              numofStrike: mw.numStrike,
              strPrc: mw.optionStrPrc,
              tradeSym: mw.selectedTradeSym!,
            );
          }
        },
        splashColor: resolveThemeColor(
          context,
          dark: MyntColors.rippleDark,
          light: MyntColors.rippleLight,
        ),
        highlightColor: resolveThemeColor(
          context,
          dark: MyntColors.highlightDark,
          light: MyntColors.highlightLight,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  date.replaceAll("-", " "),
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight:
                        isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                    color: isSelected
                        ? primaryColor
                        : resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 26,
                child: isSelected
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check,
                            size: 18,
                            color: primaryColor,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context, bool hasOptions) {
    // Tab structure: [Overview, Chart] or [Overview, Chart, Options]
    final tabs = hasOptions
        ? ['Overview', 'Chart', 'Options']
        : ['Overview', 'Chart'];
    final theme = shadcn.Theme.of(context);
    final isDark = isDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 0; index < tabs.length; index++) ...[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (mounted && _selectedTabIndex != index) {
                  if (_tabController != null) {
                    _tabController!.animateTo(index);
                  }
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  // Handle depth visibility based on tab
                  final mw = ref.read(marketWatchProvider);
                  if (index == 0) {
                    // Overview tab: show depth
                    mw.setIsDepthVisibleWeb(true, context: context);
                  } else if (index == 1) {
                    // Chart tab: hide depth
                    mw.setIsDepthVisibleWeb(false, context: context);
                  }
                  // Prepare option chain data when switching to Options tab (index 2)
                  if (hasOptions && index == 2) {
                    mw.setOptionScript(context, widget.wlValue.exch,
                        widget.wlValue.token, widget.wlValue.tsym);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == index
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: null,
                ),
                child: Text(
                  tabs[index],
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: _selectedTabIndex == index
                        ? MyntFonts.semiBold
                        : MyntFonts.medium,
                  ).copyWith(
                    color: _selectedTabIndex == index
                        ? theme.colorScheme.foreground
                        : theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          if (index < tabs.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

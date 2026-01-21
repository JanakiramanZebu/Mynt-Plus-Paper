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
import 'package:mynt_plus/res/res.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
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
  int _selectedTabIndex = 0; // 0 for Chart, 1 for Options
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
        ref
            .read(marketWatchProvider)
            .setIsDepthVisibleWeb(ref.read(marketWatchProvider).isDepthVisible);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChartWithDepthWeb oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if isOption flag changed (even for the same scrip)
    if (oldWidget.wlValue.isOption != widget.wlValue.isOption) {
      if (_tabController != null) {
        final targetIndex = widget.wlValue.isOption ? 1 : 0;
        if (_tabController!.index != targetIndex) {
          _tabController!.animateTo(targetIndex);
        }
      }
    }

    if (oldWidget.wlValue.token != widget.wlValue.token ||
        oldWidget.wlValue.exch != widget.wlValue.exch) {
      // Reset depth visibility based on incoming args when scrip changes
      // Delay provider modification until after build phase completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(marketWatchProvider)
            .setIsDepthVisibleWeb(ref.read(marketWatchProvider).isDepthVisible);
      });

      Future.microtask(() async { 
        // await _ensureDataLoaded(force: true);

        // If Options tab is active when scrip changes, prepare options for new scrip
        final mw = ref.read(marketWatchProvider);
        final hasOptions =
            mw.getOptionawait(widget.wlValue.exch, widget.wlValue.token);
        if (hasOptions && (_tabController?.index ?? 0) == 1) {
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
    if (!hasOptions) {
      // Remove listener before disposing to prevent memory leaks
      if (_tabController != null && _tabControllerListener != null) {
        _tabController!.removeListener(_tabControllerListener!);
        _tabControllerListener = null;
      }
      _tabController?.dispose();
      _tabController = null;
      return;
    }
    if (_tabController == null || _tabController!.length != 2) {
      // Remove old listener before disposing to prevent memory leaks
      if (_tabController != null && _tabControllerListener != null) {
        _tabController!.removeListener(_tabControllerListener!);
        _tabControllerListener = null;
      }
      _tabController?.dispose();
      _tabController = TabController(
          length: 2,
          vsync: this,
          initialIndex: widget.wlValue.isOption ? 1 : 0);
      _selectedTabIndex = _tabController!.index;
      // Store listener reference for proper cleanup
      _tabControllerListener = () {
        // Update UI when tab changes (for search icon visibility)
        if (mounted) {
          setState(() {
            _selectedTabIndex = _tabController!.index;
          });
        }
        if (_tabController!.index == 1 &&
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
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chart area - 100% when depth hidden, 70% when visible
              Expanded(
                flex: mw.isDepthVisible ? 7 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: Left 50% scrip title, Right 50% tabs (when available)
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ${depthData?.exch ?? widget.wlValue.exch}
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
                                // PERF FIX: ref.read() for stream
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
                          ),
                          // Search icon - only show for Chart tab (when no tabs or Chart tab is active)
                          if (_tabController == null ||
                              _tabController!.index == 0) ...[
                            const SizedBox(width: 12),
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
                                  mw.requestMWScrip(
                                      context: context, isSubscribe: false);
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel:
                                        MaterialLocalizations.of(context)
                                            .modalBarrierDismissLabel,
                                    barrierColor: resolveThemeColor(
                                      context,
                                      dark: MyntColors.modalBarrierDark,
                                      light: MyntColors.modalBarrierLight,
                                    ),
                                    transitionDuration:
                                        const Duration(milliseconds: 200),
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return SearchDialogWeb(
                                        wlName: mw.wlName,
                                        isBasket: "Chart||Is",
                                      );
                                    },
                                    transitionBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final curvedAnimation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      );

                                      return FadeTransition(
                                        opacity: curvedAnimation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                                  begin: 0.95, end: 1.0)
                                              .animate(curvedAnimation),
                                          child: child,
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    assets.searchIcon1,
                                    width: 16,
                                    height: 16,
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
                          if (hasOptions &&
                              _tabController != null &&
                              _selectedTabIndex == 1) ...[
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
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
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 18,
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
                            const SizedBox(width: 4),
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
                            // Search Icon
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
                                  mw.requestMWScrip(
                                      context: context, isSubscribe: false);
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel:
                                        MaterialLocalizations.of(context)
                                            .modalBarrierDismissLabel,
                                    barrierColor: resolveThemeColor(
                                      context,
                                      dark: MyntColors.modalBarrierDark,
                                      light: MyntColors.modalBarrierLight,
                                    ),
                                    transitionDuration:
                                        const Duration(milliseconds: 200),
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return SearchDialogWeb(
                                        wlName: mw.wlName,
                                        isBasket: "Option||Is",
                                      );
                                    },
                                    transitionBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final curvedAnimation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      );

                                      return FadeTransition(
                                        opacity: curvedAnimation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                                  begin: 0.95, end: 1.0)
                                              .animate(curvedAnimation),
                                          child: child,
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    assets.searchIcon1,
                                    width: 16,
                                    height: 16,
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
                          if (hasOptions) ...[
                            const SizedBox(width: 12),
                            _buildSegmentedControl(context),
                          ],
                          const SizedBox(width: 12),
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
                    // Content area
                    Expanded(
                      child: hasOptions && _tabController != null
                          ? _selectedTabIndex == 0
                              ? ChartScreenWebViews(
                                  chartArgs: ChartArgs(
                                    exch: widget.wlValue.exch,
                                    tsym: widget.wlValue.tsym,
                                    token: widget.wlValue.token,
                                  ),
                                )
                              : OptionChainSSWeb(
                                  wlValue: widget.wlValue,
                                  onBasketModeChanged: (bool isBasketMode) {
                                    setState(() {
                                      _isBasketMode = isBasketMode;
                                    });
                                  },
                                  onToggleCallbackReady:
                                      (VoidCallback toggleCallback) {
                                    setState(() {
                                      _toggleBasketModeCallback =
                                          toggleCallback;
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
                  ],
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

  Widget _buildSegmentedControl(BuildContext context) {
    final tabs = ['Chart', 'Options'];
    final currentTheme = shadcn.Theme.of(context);
    final isDark = isDarkMode(context);

    // Create a new ColorScheme based on the default, but with custom primary color
    final baseColorScheme = isDark
        ? shadcn.ColorSchemes.darkDefaultColor
        : shadcn.ColorSchemes.lightDefaultColor;

    // Create custom ColorScheme with theme-appropriate primary color
    final primaryColor = resolveThemeColor(
      context,
      dark: MyntColors.primaryDark,
      light: MyntColors.primary,
    );
    final customColorScheme = baseColorScheme.copyWith(
      primary: () => primaryColor,
    );

    return shadcn.Theme(
      data: shadcn.ThemeData(
        colorScheme: customColorScheme,
        radius: currentTheme.radius,
      ),
      child: shadcn.TabList(
        index: _selectedTabIndex,
        onChanged: (value) {
          if (_tabController != null) {
            _tabController!.animateTo(value);
          }
          setState(() {
            _selectedTabIndex = value;
          });
          // Prepare option chain data when switching to Options tab
          if (value == 1) {
            final mw = ref.read(marketWatchProvider);
            mw.setOptionScript(context, widget.wlValue.exch,
                widget.wlValue.token, widget.wlValue.tsym);
          }
        },
        children: [
          for (int index = 0; index < tabs.length; index++)
            shadcn.TabItem(
              child: Builder(
                builder: (context) {
                  final isActive = index == _selectedTabIndex;
                  return Text(
                    tabs[index],
                    style: MyntWebTextStyles.body(
                      context,
                      fontWeight: isActive ? MyntFonts.bold : MyntFonts.medium,
                      color: isActive
                          ? resolveThemeColor(
                              context,
                              dark: MyntColors.primaryDark,
                              light: MyntColors.primary,
                            )
                          : resolveThemeColor(
                              context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary,
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

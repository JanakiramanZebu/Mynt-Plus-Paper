import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/marketwatch_model/get_quotes.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/screens/web/market_watch/scrip_depth_info_web.dart';
import 'package:mynt_plus/screens/web/market_watch/tv_chart/webview_chart.dart';
import 'package:mynt_plus/screens/web/market_watch/options/option_chain_ss_web.dart';
import 'package:mynt_plus/screens/web/market_watch/search_dialog_web.dart';
import 'package:mynt_plus/res/res.dart';
import '../../../../provider/websocket_provider.dart';

class ChartWithDepthWeb extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  final String isBasket;

  const ChartWithDepthWeb({super.key, required this.wlValue, this.isBasket = ""});

  @override
  ConsumerState<ChartWithDepthWeb> createState() => _ChartWithDepthWebState();
}

class _ChartWithDepthWebState extends ConsumerState<ChartWithDepthWeb> with TickerProviderStateMixin {
  String? _loadedToken;
  TabController? _tabController;
  int _selectedTabIndex = 0; // 0 for Chart, 1 for Options
  bool _isBasketMode = false; // Track basket mode from OptionChainSSWeb
  VoidCallback? _toggleBasketModeCallback; // Callback to toggle basket mode
  // bool _isDepthVisible = false; // Controlled by wlValue.showDepthInitially

  @override
  void initState() {
    super.initState();
    // Ensure depth + chart data is loaded for the selected scrip
    Future.microtask(() async {
      await _ensureDataLoaded();
    });
    ref.read(marketWatchProvider).setIsDepthVisibleWeb(ref.read(marketWatchProvider).isDepthVisible);
  }

  @override
  void didUpdateWidget(covariant ChartWithDepthWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wlValue.token != widget.wlValue.token ||
        oldWidget.wlValue.exch != widget.wlValue.exch) {
      // Reset depth visibility based on incoming args when scrip changes
     ref.read(marketWatchProvider).setIsDepthVisibleWeb(ref.read(marketWatchProvider).isDepthVisible);
      
      Future.microtask(() async {
        await _ensureDataLoaded(force: true);

        // If Options tab is active when scrip changes, prepare options for new scrip
        final mw = ref.read(marketWatchProvider);
        final hasOptions = mw.getOptionawait(widget.wlValue.exch, widget.wlValue.token);
        if (hasOptions && (_tabController?.index ?? 0) == 1) {
          mw.setOptionScript(context, widget.wlValue.exch, widget.wlValue.token, widget.wlValue.tsym);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _ensureDataLoaded({bool force = false}) async {
    final mw = ref.read(marketWatchProvider);
    final currentToken = mw.getQuotes?.token?.toString();
    final targetToken = widget.wlValue.token;

    if (force || _loadedToken != targetToken || currentToken != targetToken) {
      mw.scripdepthsize(false);
      await mw.calldepthApis(context, widget.wlValue, "");
      // Keep chart in sync with the same scrip
      mw.setChartScript(widget.wlValue.exch, widget.wlValue.token, widget.wlValue.tsym);
      _loadedToken = targetToken;
    }
  }

  void _setupTabControllerIfNeeded({required bool hasOptions}) {
    if (!hasOptions) {
      _tabController?.dispose();
      _tabController = null;
      return;
    }
    if (_tabController == null || _tabController!.length != 2) {
      _tabController?.dispose();
      _tabController = TabController(length: 2, vsync: this);
      _tabController!.addListener(() {
        // Update UI when tab changes (for search icon visibility)
        if (mounted) {
          setState(() {
            _selectedTabIndex = _tabController!.index;
          });
        }
        if (_tabController!.index == 1 && _tabController!.indexIsChanging == false) {
          // Prepare option chain data when switching to Options tab
          final mw = ref.read(marketWatchProvider);
          mw.setOptionScript(context, widget.wlValue.exch, widget.wlValue.token, widget.wlValue.tsym);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mw = ref.watch(marketWatchProvider);
    final hasOptions = mw.getOptionawait(widget.wlValue.exch, widget.wlValue.token);
    final depthData = mw.getQuotes;
    _setupTabControllerIfNeeded(hasOptions: hasOptions);

    return Container(
      color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? WebDarkColors.navBackground : WebColors.navBackground,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.isDarkMode ? WebDarkColors.navDivider : WebColors.navDivider,
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
                                Text(
                                  "${(depthData?.symname ?? depthData?.symbol ?? depthData?.tsym ?? widget.wlValue.symbol).replaceAll('-EQ', '').toUpperCase()}${depthData?.expDate ?? widget.wlValue.expDate} ${depthData?.option ?? widget.wlValue.option} ${depthData?.exch ?? widget.wlValue.exch}",
                                  overflow: TextOverflow.ellipsis,
                                  style: WebTextStyles.sub(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                                    fontWeight: WebFonts.medium,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StreamBuilder<Map>(
                                  stream: ref.watch(websocketProvider).socketDataStream,
                                  builder: (context, snapshot) {
                                    final socketDatas = snapshot.data ?? {};
                                    final currentToken = depthData?.token?.toString() ?? widget.wlValue.token;
                                    String ltp = depthData?.lp ?? depthData?.c ?? '0.00';
                                    String ch = depthData?.chng ?? '0.00';
                                    String pc = depthData?.pc ?? '0.00';
                                    if (socketDatas.containsKey(currentToken)) {
                                      final s = socketDatas[currentToken];
                                      ltp = "${s['lp'] ?? s['c'] ?? ltp}";
                                      ch = "${s['chng'] ?? ch}";
                                      pc = "${s['pc'] ?? pc}";
                                    }
                                    final ltpStr = (double.tryParse("$ltp") ?? 0).toStringAsFixed(2);
                                    final chVal = double.tryParse("$ch") ?? 0;
                                    final pcVal = double.tryParse("$pc") ?? 0;
                                    final chStr = chVal.toStringAsFixed(2);
                                    final pcStr = pcVal.toStringAsFixed(2);
                                    final isUp = pcVal >= 0;
          
                                    return Row(
                                      children: [
                                        Text(
                                          ltpStr,
                                          style: WebTextStyles.sub(
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                                            fontWeight: WebFonts.medium,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "$chStr (${pcStr}%)",
                                          style: WebTextStyles.sub(
                                            isDarkTheme: theme.isDarkMode,
                                            color: isUp
                                                ? (theme.isDarkMode ? WebDarkColors.success : WebColors.success)
                                                : (theme.isDarkMode ? WebDarkColors.error : WebColors.error),
                                            fontWeight: WebFonts.medium,
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
                          if (_tabController == null || _tabController!.index == 0) ...[
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                onTap: () {
                                  mw.requestMWScrip(context: context, isSubscribe: false);
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    builder: (BuildContext context) {
                                      return SearchDialogWeb(
                                        wlName: mw.wlName,
                                        isBasket: "Chart||Is",
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
                                    color: theme.isDarkMode
                                        ? WebDarkColors.iconSecondary
                                        : WebColors.iconSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          // Options header row - only show for Options tab (symbol + dropdown + basket + search)
                          if (hasOptions && _tabController != null && _selectedTabIndex == 1) ...[
                            // const SizedBox(width: 12),
                            // Symbol Name and Expiry Dropdown
                            Row(
                              children: [
                                // Text(
                                //   (depthData?.tsym ?? widget.wlValue.tsym).toUpperCase(),
                                //   style: WebTextStyles.sub(
                                //     isDarkTheme: theme.isDarkMode,
                                //     color: theme.isDarkMode
                                //         ? WebDarkColors.textPrimary
                                //         : WebColors.textPrimary,
                                //     fontWeight: WebFonts.medium,
                                //   ),
                                // ),
                                // const SizedBox(width: 8),
                                Builder(
                                  builder: (context) => Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showExpiryDropdown(context, mw, theme),
                                      borderRadius: BorderRadius.circular(5),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: theme.isDarkMode
                                                ? WebDarkColors.divider
                                                : WebColors.divider,
                                            // width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              mw.selectedExpDate?.replaceAll("-", " ") ?? '',
                                              style: WebTextStyles.bodySmall(
                                                isDarkTheme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? WebDarkColors.textPrimary
                                                    : WebColors.textPrimary,
                                                fontWeight: WebFonts.medium,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              size: 20,
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.iconSecondary
                                                  : WebColors.iconSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            // const Spacer(),
                            // Basket Toggle Icon
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
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
                                        ? WebColors.primary
                                        : (theme.isDarkMode 
                                            ? WebDarkColors.iconSecondary 
                                            : WebColors.iconSecondary),
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
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
                                onTap: () {
                                  mw.requestMWScrip(context: context, isSubscribe: false);
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    builder: (BuildContext context) {
                                      return SearchDialogWeb(
                                        wlName: mw.wlName,
                                        isBasket: "Option||Is",
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
                                    color: theme.isDarkMode
                                        ? WebDarkColors.iconSecondary
                                        : WebColors.iconSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          // Depth toggle icon
                          const SizedBox(width: 12),        
                          if (hasOptions)
                            _buildSegmentedControl(theme),
                          // Depth toggle chevron icon - with proper spacing
                          if (hasOptions) ...[
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                onTap: () {
                                  ref.read(marketWatchProvider).setIsDepthVisibleWeb(!mw.isDepthVisible);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    mw.isDepthVisible ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                                    size: 20,
                                    color: mw.isDepthVisible
                                        ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                                        : (theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                  onToggleCallbackReady: (VoidCallback toggleCallback) {
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
                  ],
                ),
              ),
              // Divider between chart and depth (only when depth is visible)
              if (mw.isDepthVisible)
                Container(
                  width: 1,
                  color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
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

  Widget _buildSegmentedControl(ThemesProvider theme) {
    final tabs = ['Chart', 'Options'];

    return SizedBox(
      height: 45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < tabs.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildSegmentedTab(
                tabs[index],
                index,
                _selectedTabIndex == index,
                theme,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab(
    String title,
    int index,
    bool isSelected,
    ThemesProvider theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          if (_tabController != null) {
            _tabController!.animateTo(index);
          }
          setState(() {
            _selectedTabIndex = index;
          });
          // Prepare option chain data when switching to Options tab
          if (index == 1) {
            final mw = ref.read(marketWatchProvider);
            mw.setOptionScript(context, widget.wlValue.exch, widget.wlValue.token, widget.wlValue.tsym);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showExpiryDropdown(BuildContext context, MarketWatchProvider mw, ThemesProvider theme) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      items: mw.sortDate.map((String date) {
        final isSelected = date == mw.selectedExpDate;
        return PopupMenuItem<String>(
          value: date,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 200, // Fixed width
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                date.replaceAll("-", " "),
                style: WebTextStyles.bodySmall(
                  isDarkTheme: theme.isDarkMode,
                  color: isSelected
                      ? (theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary)
                      : (theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).then((value) async {
      if (value != null) {
        for (var i = 0; i < (mw.optExp?.length ?? 0); i++) {
          if (value == mw.optExp![i].exd) {
            mw.selecTradSym("${mw.optExp![i].tsym}");
            mw.optExch("${mw.optExp![i].exch}");
          }
        }
        mw.selecexpDate(value);

        await mw.fetchOPtionChain(
          context: context,
          exchange: mw.optionExch!,
          numofStrike: mw.numStrike,
          strPrc: mw.optionStrPrc,
          tradeSym: mw.selectedTradeSym!,
        );
      }
    });
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/marketwatch_model/get_quotes.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:mynt_plus/screens/web/market_watch/scrip_depth_info_web.dart';
import 'package:mynt_plus/screens/web/market_watch/tv_chart/webview_chart.dart';
import 'package:mynt_plus/screens/web/market_watch/options/option_chain_ss_web.dart';
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
              // Chart area - 100% when depth hidden, 75% when visible
              Expanded(
                flex: mw.isDepthVisible ? 3 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: Left 50% scrip title, Right 50% tabs (when available)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                  "${widget.wlValue.symbol.replaceAll('-EQ', '').toUpperCase()}${widget.wlValue.expDate} ${widget.wlValue.option} ${widget.wlValue.exch}",
                                  overflow: TextOverflow.ellipsis,
                                  style: WebTextStyles.title(
                                    isDarkTheme: theme.isDarkMode,
                                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                                    fontWeight: WebFonts.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StreamBuilder<Map>(
                                  stream: ref.watch(websocketProvider).socketDataStream,
                                  builder: (context, snapshot) {
                                    final socketDatas = snapshot.data ?? {};
                                    String ltp = depthData?.lp ?? depthData?.c ?? '0.00';
                                    String ch = depthData?.chng ?? '0.00';
                                    String pc = depthData?.pc ?? '0.00';
                                    if (socketDatas.containsKey(widget.wlValue.token)) {
                                      final s = socketDatas[widget.wlValue.token];
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
                                            fontWeight: WebFonts.bold,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "$chStr (${pcStr}%)",
                                          style: WebTextStyles.para(
                                            isDarkTheme: theme.isDarkMode,
                                            color: isUp
                                                ? (theme.isDarkMode ? WebDarkColors.success : WebColors.success)
                                                : (theme.isDarkMode ? WebDarkColors.error : WebColors.error),
                                            fontWeight: WebFonts.bold,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Depth toggle icon
                          const SizedBox(width: 12),        
                          if (hasOptions)
                            Container(
                              width: 260,
                              height: 45,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? WebDarkColors.navBackground
                                    : WebColors.navBackground,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                labelColor:  WebDarkColors.textPrimary,
                                labelStyle: const TextStyle(
                                  fontWeight: WebFonts.bold,
                                  fontSize: WebFonts.subSize,
                                ),
                                unselectedLabelColor: theme.isDarkMode
                                    ? WebDarkColors.textSecondary
                                    : WebColors.textSecondary,
                                unselectedLabelStyle: const TextStyle(
                                  fontWeight: WebFonts.bold,
                                  fontSize: WebFonts.subSize,
                                ),
                                indicator: BoxDecoration(
                                  color: WebColors.primary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                indicatorPadding:
                                    const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                tabs: const [
                                  Tab(text: 'Chart'),
                                  Tab(text: 'Options'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Content area
                    Expanded(
                      child: hasOptions && _tabController != null
                          ? TabBarView(
                              controller: _tabController,
                              children: [
                                ChartScreenWebViews(
                                  chartArgs: ChartArgs(
                                    exch: widget.wlValue.exch,
                                    tsym: widget.wlValue.tsym,
                                    token: widget.wlValue.token,
                                  ),
                                ),
                                OptionChainSSWeb(wlValue: widget.wlValue),
                              ],
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
              // Depth/Overview area - 25% (only when visible)
              if (mw.isDepthVisible)
                Expanded(
                  flex: 1,
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
          Positioned(
                   top: 3,
                   right: !mw.isDepthVisible ? 0 : 375,
                   child: InkWell(
                     customBorder: const RoundedRectangleBorder(
                       borderRadius: BorderRadius.only(
                         topLeft: Radius.circular(0),
                         bottomLeft: Radius.circular(0),
                       ),
                     ),
                     // splashColor: mw.isDepthVisible ? (theme.isDarkMode ? Colors.white : Colors.black).withOpacity(.15) : null,
                     // highlightColor: mw.isDepthVisible ? (theme.isDarkMode ? Colors.white : Colors.black).withOpacity(.08) : null,
                     onTap: () {
                       ref.read(marketWatchProvider).setIsDepthVisibleWeb(!mw.isDepthVisible);
                     },
                     child: Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Icon(
                         mw.isDepthVisible ? Icons.chevron_right : Icons.chevron_left,
                         size:30,
                         color: mw.isDepthVisible
                             ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                             : (theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary),
                       ),
                     ),
                   ),
                 ),
        ],
      ),
    );
  }
}



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

  @override
  void initState() {
    super.initState();
    // Ensure depth + chart data is loaded for the selected scrip
    Future.microtask(() async {
      await _ensureDataLoaded();
    });
  }

  @override
  void didUpdateWidget(covariant ChartWithDepthWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wlValue.token != widget.wlValue.token ||
        oldWidget.wlValue.exch != widget.wlValue.exch) {
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
    _setupTabControllerIfNeeded(hasOptions: hasOptions);

    return Container(
      color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart area - 75%
          Expanded(
            flex: 3,
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
                        child: Text(
                          "${widget.wlValue.symbol.replaceAll('-EQ', '').toUpperCase()}${widget.wlValue.expDate} ${widget.wlValue.option} ${widget.wlValue.exch}",
                          overflow: TextOverflow.ellipsis,
                          style: WebTextStyles.title(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                      ),
                      if (hasOptions)
                        SizedBox(
                          width: 260,
                          height: 30,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                            unselectedLabelColor: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                            indicatorColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                            indicatorWeight: 2,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
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
          // Divider between chart and depth
          Container(
            width: 1,
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
          // Depth/Overview area - 25%
          Expanded(
            flex: 1,
            child: ScripDepthInfoWeb(
              wlValue: widget.wlValue,
              isBasket: widget.isBasket,
            ),
          ),
        ],
      ),
    );
  }
}



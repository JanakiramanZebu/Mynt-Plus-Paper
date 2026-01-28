import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/stocks_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/explore_model/stocks_model/toplist_stocks.dart';
import 'dart:async';
import 'market_watch/index/index_bottom_sheet_web.dart';
import 'trade_action_screen_web.dart';
import '../../../routes/route_names.dart';
import '../../../utils/custom_navigator.dart';

class DashboardScreenWeb extends ConsumerStatefulWidget {
  const DashboardScreenWeb({super.key});

  @override
  ConsumerState<DashboardScreenWeb> createState() => _DashboardScreenWebState();
}

class _DashboardScreenWebState extends ConsumerState<DashboardScreenWeb> {
  final ScrollController _indexScrollController = ScrollController();
  final ScrollController _tradeActionScrollController = ScrollController();
  // WebSocket subscription for live position updates
  StreamSubscription? _positionSocketSubscription;
  // WebSocket subscription for live holdings updates
  StreamSubscription? _holdingsSocketSubscription;
  // Flag to prevent accessing ref after disposal (race condition with stream callbacks)
  bool _isDisposed = false;
  // Throttle holdings updates
  DateTime _lastHoldingsUpdate = DateTime.now();
  static const Duration _holdingsUpdateInterval = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    // Note: Data fetching is handled by _handleDashboardTap() in customizable_split_home_screen.dart
    // This prevents duplicate API calls when dashboard button is clicked
    // WebSocket bodyscription is handled by WebbodyscriptionManager
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final indexProvider = ref.read(indexListProvider);

      // Get top indices for dashboard (8 specific indices) if not already fetched
      // This ensures tokens are available for WebbodyscriptionManager
      // Only fetch if not already available to avoid duplicate calls
      if (indexProvider.topIndicesForDashboard == null) {
        await indexProvider.getTopIndicesForDashboard(context);
        if (!mounted) return;
      }

      // Fetch MF holdings for the dashboard portfolio tab using the same API as holdings tab
      // This avoids race condition with the old fetchMFHoldings API which can cause double data
      await ref.read(mfProvider).fetchmfholdingnew();
      if (!mounted) return;

      // Trade action data is fetched by _handleDashboardTap() before this screen is shown
      // No need to fetch here to avoid duplicate TopList API calls

      // Set up WebSocket subscription for live position updates
      _setupPositionSocketSubscription();
      // Set up WebSocket subscription for live holdings updates
      _setupHoldingsSocketSubscription();

      // Calculate holdings totals on initial load to ensure correct values
      final portfolio = ref.read(portfolioProvider);
      if (portfolio.holdingsModel != null && portfolio.holdingsModel!.isNotEmpty) {
        portfolio.pnlHoldCal();
      }
    });
  }

  void _setupPositionSocketSubscription() {
    if (!mounted) return;
    final websocket = ref.read(websocketProvider);
    // Store provider reference at setup time - the provider itself doesn't get
    // disposed when widget disposes, only the widget's ref access becomes invalid
    final portfolio = ref.read(portfolioProvider);

    _positionSocketSubscription =
        websocket.socketDataStream.listen((socketDatas) {
      // Check if widget is disposed before processing
      if (_isDisposed) return;

      // Get positions fresh from stored provider reference (not from ref)
      final positions = portfolio.postionBookModel ?? [];

      if (positions.isEmpty) return;

      bool needsUpdate = false;

      for (var position in positions) {
        if (socketDatas.containsKey(position.token)) {
          final socketData = socketDatas[position.token];

          // Update LTP if valid
          final lp = socketData['lp']?.toString();
          if (lp != null && lp != "null" && lp != position.lp) {
            position.lp = lp;
            needsUpdate = true;
          }
        }
      }

      // Recalculate totals when price data changes
      if (needsUpdate) {
        portfolio.positionCal(portfolio.isDay);
      }
    });
  }

  void _setupHoldingsSocketSubscription() {
    if (!mounted) return;
    final websocket = ref.read(websocketProvider);
    final portfolio = ref.read(portfolioProvider);

    _holdingsSocketSubscription = websocket.socketDataStream.listen((socketDatas) {
      if (_isDisposed || !mounted) return;

      final holdings = portfolio.holdingsModel ?? [];
      if (holdings.isEmpty || socketDatas.isEmpty) return;

      // Throttle updates to avoid excessive rebuilds
      final now = DateTime.now();
      if (now.difference(_lastHoldingsUpdate) < _holdingsUpdateInterval) return;

      bool needsUpdate = false;

      // Check if any holdings tokens have updates
      for (var holding in holdings) {
        if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
          final token = holding.exchTsym![0].token;
          if (token != null && socketDatas.containsKey(token)) {
            needsUpdate = true;
            break;
          }
        }
      }

      // Call pnlHoldCal() which calculates all totals and calls notifyListeners()
      if (needsUpdate) {
        _lastHoldingsUpdate = now;
        portfolio.pnlHoldCal();
      }
    });
  }

  @override
  void dispose() {
    // Set disposed flag FIRST to prevent stream callbacks from accessing ref
    _isDisposed = true;
    // Cancel WebSocket subscriptions
    _positionSocketSubscription?.cancel();
    _holdingsSocketSubscription?.cancel();

    // Note: WebbodyscriptionManager handles unbodyscription automatically
    // when screen is replaced or removed via updateActiveScreen()
    // No need to unbodyscribe here to avoid double calls

    _indexScrollController.dispose();
    _tradeActionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indexProvider = ref.watch(indexListProvider);

    return Scaffold(
      backgroundColor: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopIndicesSection(context, indexProvider),
              const SizedBox(height: 32),
              // Dashboard cards section (Holdings, Position, Orders, Margins)
              _buildDashboardCardsSection(context),
              const SizedBox(height: 32),
              // Today's trade action section
              _buildTodaysTradeActionSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCardsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildPortfolioCard(context, constraints.maxWidth);
      },
    );
  }

  Widget _buildPortfolioCard(BuildContext context, double width) {
    return Consumer(
      builder: (context, ref, _) {
        final portfolio = ref.watch(portfolioProvider);
        final orders = ref.watch(orderProvider);
        final fund = ref.watch(fundProvider);
        final mfData = ref.watch(mfProvider);
        // Watch websocket for price updates
        ref.watch(websocketProvider);

        return Container(
          width: width,
          // padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: shadcn.Theme.of(context).colorScheme.card,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.02),
            //     blurRadius: 10,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPortfolioHeader(context),
              const SizedBox(height: 14),
              _buildPortfolioContent(context, portfolio, orders, fund, mfData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Portfolio',
              style: MyntWebTextStyles.head(
                context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioContent(
    BuildContext context,
    PortfolioProvider portfolio,
    OrderProvider orders,
    FundProvider fund,
    MFProvider mfData,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPortfolioSection(
            context,
            'Equity',
            _getEquityMetrics(context, portfolio),
            onTap: () {
              if (WebNavigationHelper.isAvailable) {
                WebNavigationHelper.navigateTo(Routes.holdingscreen);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPortfolioSection(
            context,
            'Mutual Fund',
            _getMutualFundMetrics(context, mfData),
            onTap: () {
              if (WebNavigationHelper.isAvailable) {
                WebNavigationHelper.navigateTo(Routes.mfmainscreen);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPortfolioSection(
            context,
            'Position',
            _getPositionMetrics(context, portfolio),
            onTap: () {
              if (WebNavigationHelper.isAvailable) {
                WebNavigationHelper.navigateTo(Routes.positionscreen);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPortfolioSection(
            context,
            'Funds',
            _getFundsMetrics(context, fund),
            onTap: () {
              if (WebNavigationHelper.isAvailable) {
                WebNavigationHelper.navigateTo(Routes.fundscreen);
              }
            },
            trailing: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (WebNavigationHelper.isAvailable) {
                    WebNavigationHelper.navigateTo(Routes.fundscreen,
                        arguments: 'addMoney');
                  }
                },
                child: Text(
                  'Add Money',
                  style: MyntWebTextStyles.body(
                    context,
                    darkColor: MyntColors.primaryDark,
                    lightColor: MyntColors.primary,
                    fontWeight: MyntFonts.bold,
                  ).copyWith(fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSection(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> metrics, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return _buildMetricsGrid(context, title, metrics,
        trailing: trailing, onTap: onTap);
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> metrics, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // We want a 2x2 grid layout inside a single border with the title at the top
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: shadcn.Theme.of(context).colorScheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: MyntWebTextStyles.body(
                        context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: MyntFonts.bold,
                      ).copyWith(fontSize: 14),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
              ),
              // Divider(
              //   height: 1,
              //   color: shadcn.Theme.of(context).colorScheme.border.withOpacity(0.5),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 16, top: 6),
                child: Column(
                  children: [
                    // Row 1
                    Row(
                      children: [
                        Expanded(child: _buildMetricItem(context, metrics, 0)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMetricItem(context, metrics, 1)),
                      ],
                    ),
                    if (metrics.length > 2) ...[
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: shadcn.Theme.of(context)
                            .colorScheme
                            .border
                            .withOpacity(0.6),
                      ),
                      const SizedBox(height: 10),
                      // Row 2
                      Row(
                        children: [
                          Expanded(
                              child: _buildMetricItem(context, metrics, 2)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildMetricItem(context, metrics, 3)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    List<Map<String, dynamic>> metrics,
    int index,
  ) {
    if (index >= metrics.length) {
      return const SizedBox.shrink();
    }

    final metric = metrics[index];
    final double value =
        double.tryParse((metric['value'] as String).replaceAll('₹', '')) ?? 0.0;
    final bool isPnl = metric['isPnl'] ?? false;
    final Color valueColor = (isPnl && value != 0)
        ? (value > 0
            ? (shadcn.Theme.of(context).brightness == Brightness.dark
                ? MyntColors.profitDark
                : MyntColors.profit)
            : (shadcn.Theme.of(context).brightness == Brightness.dark
                ? MyntColors.lossDark
                : MyntColors.loss))
        : (shadcn.Theme.of(context).brightness == Brightness.dark
            ? MyntColors.textPrimaryDark
            : MyntColors.textPrimary);

    final bool isLeftAligned = index % 2 == 0;
    final alignment =
        isLeftAligned ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final rowAlignment =
        isLeftAligned ? MainAxisAlignment.start : MainAxisAlignment.end;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          metric['label'],
          style: MyntWebTextStyles.caption(
            context,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary,
          ).copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isLeftAligned ? TextAlign.left : TextAlign.right,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: rowAlignment,
          children: [
            Text(
              metric['value'],
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: valueColor,
              ).copyWith(fontSize: 14),
            ),
            if (metric['subValue'] != null) ...[
              const SizedBox(width: 4),
              Text(
                metric['subValue'],
                style: MyntWebTextStyles.caption(
                  context,
                  color: valueColor,
                ).copyWith(fontSize: 12),
              ),
            ],
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getEquityMetrics(
      BuildContext context, PortfolioProvider portfolio) {
    final holdings = portfolio.holdingsModel ?? [];
    double totalPnlHolding = 0.0;
    double oneDayChng = 0.0;
    double invest = 0.0;
    double totalCurrentVal = 0.0;

    for (var holding in holdings) {
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final exchTsym = holding.exchTsym![0];
        final pnl = double.tryParse(exchTsym.profitNloss ?? '0') ?? 0.0;
        final rpnl = double.tryParse(holding.rpnl ?? '0') ?? 0.0;
        final oneDayChgVal = double.tryParse(exchTsym.oneDayChg ?? '0') ?? 0.0;
        final investedVal = double.tryParse(holding.invested ?? '0') ?? 0.0;
        final currentVal = double.tryParse(holding.currentValue ?? '0') ?? 0.0;

        totalPnlHolding += pnl + rpnl;
        oneDayChng += oneDayChgVal;
        invest += investedVal;
        totalCurrentVal += currentVal;
      }
    }

    final oneDayChngPer =
        totalCurrentVal > 0 ? (oneDayChng / totalCurrentVal) * 100 : 0.0;
    final totPnlPercHolding =
        invest > 0 ? (totalPnlHolding / invest) * 100 : 0.0;

    return [
      {'label': 'Invested', 'value': '₹${invest.toStringAsFixed(2)}'},
      {'label': 'Current', 'value': '₹${totalCurrentVal.toStringAsFixed(2)}'},
      {
        'label': 'Total P&L',
        'value': '₹${totalPnlHolding.toStringAsFixed(2)}',
        'subValue': '${totPnlPercHolding.toStringAsFixed(2)}%',
        'isPnl': true
      },
      {
        'label': 'Today P&L',
        'value': '₹${oneDayChng.toStringAsFixed(2)}',
        'subValue': '${oneDayChngPer.toStringAsFixed(2)}%',
        'isPnl': true
      },
    ];
  }

  List<Map<String, dynamic>> _getMutualFundMetrics(
      BuildContext context, MFProvider mfData) {
    // Use the same data source as holdings tab (mfholdingnew.summary)
    // This ensures consistency and avoids race condition with the old API
    final summary = mfData.mfholdingnew?.summary;
    final invest = double.tryParse(summary?.invested ?? '0') ?? 0.0;
    final current = double.tryParse(summary?.currentValue ?? '0') ?? 0.0;
    final totalPnL = double.tryParse(summary?.absReturnValue ?? '0') ?? 0.0;
    final totalPnLPer = double.tryParse(summary?.absReturnPercent ?? '0') ?? 0.0;

    return [
      {'label': 'Invested', 'value': '₹${invest.toStringAsFixed(2)}'},
      {'label': 'Current', 'value': '₹${current.toStringAsFixed(2)}'},
      {
        'label': 'Total P&L',
        'value': '₹${totalPnL.toStringAsFixed(2)}',
        'subValue': '${totalPnLPer.toStringAsFixed(2)}%',
        'isPnl': true
      },
    ];
  }

  List<Map<String, dynamic>> _getPositionMetrics(
      BuildContext context, PortfolioProvider portfolio) {
    final positions = portfolio.postionBookModel ?? [];
    final totalPnL = portfolio.totPnL;
    final mtm = portfolio.totMtM;
    final openPnL = portfolio.totUnRealMtm;

    double totBuyAmts = 0.0;
    for (var position in positions) {
      totBuyAmts += double.tryParse(position.totbuyamt ?? '0') ?? 0;
    }

    return [
      {'label': 'Trade value', 'value': '₹${totBuyAmts.toStringAsFixed(2)}'},
      {'label': 'MTM', 'value': '₹$mtm', 'isPnl': true},
      {'label': 'Total P&L', 'value': '₹$totalPnL', 'isPnl': true},
      {'label': 'Open P&L', 'value': '₹$openPnL', 'isPnl': true},
    ];
  }

  List<Map<String, dynamic>> _getFundsMetrics(
      BuildContext context, FundProvider fund) {
    final fundDetail = fund.fundDetailModel;
    final availableBalance =
        fundDetail?.avlMrg ?? fundDetail?.totCredit ?? '0.00';
    final totalCredits = fundDetail?.totCredit ?? '0.00';
    final marginUsed = fundDetail?.marginused ?? '0.00';

    return [
      {'label': 'Available Margin', 'value': '₹$availableBalance'},
      {'label': 'Capital', 'value': '₹$totalCredits'},
      {'label': 'Used', 'value': '₹$marginUsed'},
    ];
  }

  Widget _buildPortfolioFooter(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildTopIndicesSection(
      BuildContext context, IndexListProvider indexProvider) {
    // Use topIndicesForDashboard (8 specific indices for dashboard)
    final allIndexValues =
        indexProvider.topIndicesForDashboard?.indValues ?? [];
    final indexValues = allIndexValues.take(5).toList();
    final hasIndices = indexValues.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and navigation arrows
        Row(
          children: [
            Text(
              'Indices',
              style: MyntWebTextStyles.head(
                context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.bold,
              ),
            ),
            const SizedBox(width: 12),
            // "See all indices" link moved near the title
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  await _showAllIndicesBottomSheet(context, indexProvider);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: shadcn.Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.0),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: resolveThemeColor(context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Index cards - horizontal scrollable
        if (hasIndices)
          SizedBox(
            height: 100, // Fixed height for index cards
            child: SingleChildScrollView(
              controller: _indexScrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(), // No bouncing at edges
              child: Row(
                children: indexValues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: EdgeInsets.only(
                      right: index < indexValues.length - 1 ? 12 : 0,
                    ),
                    child: _DashboardIndexCard(
                      indexItem: item,
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Loading indices...',
                style: MyntWebTextStyles.para(
                  context,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _scrollIndices(double offset) {
    if (_indexScrollController.hasClients) {
      final currentOffset = _indexScrollController.offset;
      final maxScrollExtent = _indexScrollController.position.maxScrollExtent;
      final newOffset = currentOffset + offset;

      // Clamp the offset to prevent scrolling beyond boundaries
      final clampedOffset = newOffset.clamp(0.0, maxScrollExtent);

      // Only animate if we're not at the boundary
      if (clampedOffset != currentOffset) {
        _indexScrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildTodaysTradeActionSection(BuildContext context) {
    final stocksProvider = ref.watch(stocksProvide);
    final topGainers = stocksProvider.topGainers;
    final topLosers = stocksProvider.topLosers;
    final byVolume = stocksProvider.byVolume;
    final byValue = stocksProvider.byValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          "Today's trade action",
          style: MyntWebTextStyles.head(
            context,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
            fontWeight: MyntFonts.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Four cards with responsive width
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            const cardSpacing = 16.0;
            const minCardWidth = 300.0;
            const totalCards = 4;
            const totalSpacing = cardSpacing * (totalCards - 1);
            const totalMinWidth = (minCardWidth * totalCards) + totalSpacing;

            // Calculate card width
            double cardWidth;
            bool needsScrolling = false;

            if (availableWidth >= totalMinWidth) {
              // All cards fit, distribute evenly
              cardWidth = (availableWidth - totalSpacing) / totalCards;
            } else {
              // Need scrolling, use min width
              cardWidth = minCardWidth;
              needsScrolling = true;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _tradeActionScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Gainers Card
                      _buildTradeActionCard(
                        tabIndex: 0, // Top gainer tab
                        context: context,
                        title: 'Top gainer',
                        stocks: topGainers,
                        icon: Icons.trending_up,
                        iconColor: resolveThemeColor(context,
                            dark: MyntColors.profitDark,
                            light: MyntColors.profit),
                        width: cardWidth,
                      ),
                      const SizedBox(width: cardSpacing),
                      // Top Losers Card
                      _buildTradeActionCard(
                        tabIndex: 1, // Top losers tab
                        context: context,
                        title: 'Top losers',
                        stocks: topLosers,
                        icon: Icons.trending_down,
                        iconColor: resolveThemeColor(context,
                            dark: MyntColors.lossDark, light: MyntColors.loss),
                        width: cardWidth,
                      ),
                      const SizedBox(width: cardSpacing),
                      // Volume Breakout Card
                      _buildTradeActionCard(
                        tabIndex: 2, // Volume breakout tab
                        context: context,
                        title: 'Volume breakout',
                        stocks: byVolume,
                        icon: Icons.bar_chart,
                        iconColor: Colors.blue,
                        width: cardWidth,
                      ),
                      const SizedBox(width: cardSpacing),
                      // Most Active Card
                      _buildTradeActionCard(
                        tabIndex: 3, // Most active tab
                        context: context,
                        title: 'Most active',
                        stocks: byValue,
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        showPrice: true,
                        width: cardWidth,
                      ),
                    ],
                  ),
                ),
                // Left arrow (only show if scrolling is needed)
                if (needsScrolling)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_tradeActionScrollController.hasClients) {
                                final scrollAmount = cardWidth + cardSpacing;
                                final newOffset =
                                    (_tradeActionScrollController.offset -
                                            scrollAmount)
                                        .clamp(
                                  0.0,
                                  _tradeActionScrollController
                                      .position.maxScrollExtent,
                                );
                                _tradeActionScrollController.animateTo(
                                  newOffset,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    shadcn.Theme.of(context).colorScheme.card,
                                border: Border.all(
                                  color: shadcn.Theme.of(context)
                                      .colorScheme
                                      .border,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 14,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Right arrow (only show if scrolling is needed)
                if (needsScrolling)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_tradeActionScrollController.hasClients) {
                                final scrollAmount = cardWidth + cardSpacing;
                                final newOffset =
                                    (_tradeActionScrollController.offset +
                                            scrollAmount)
                                        .clamp(
                                  0.0,
                                  _tradeActionScrollController
                                      .position.maxScrollExtent,
                                );
                                _tradeActionScrollController.animateTo(
                                  newOffset,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    shadcn.Theme.of(context).colorScheme.card,
                                border: Border.all(
                                  color: shadcn.Theme.of(context)
                                      .colorScheme
                                      .border,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.textPrimaryDark,
                                      light: MyntColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTradeActionCard({
    required int tabIndex, // Add tab index parameter
    required BuildContext context,
    required String title,
    required List<TopGainers> stocks,
    required IconData icon,
    required Color iconColor,
    bool showPrice = true,
    required double width,
  }) {
    final hasStocks = stocks.isNotEmpty;
    final displayStocks = stocks.take(5).toList();
    final isVolumeBreakout = title == 'Volume breakout';

    return Container(
      width: width,
      height: 400,
      decoration: BoxDecoration(
        color: shadcn.Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: shadcn.Theme.of(context).colorScheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: MyntWebTextStyles.body(
                        context,
                        darkColor: MyntColors.textPrimaryDark,
                        lightColor: MyntColors.textPrimary,
                        fontWeight: MyntFonts.bold,
                      ),
                    ),
                  ],
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint(
                          "See all clicked, route: ${Routes.tradeActionScreen}, tabIndex: $tabIndex");
                      debugPrint(
                          "WebNavigationHelper.isAvailable: ${WebNavigationHelper.isAvailable}");

                      if (WebNavigationHelper.isAvailable) {
                        try {
                          WebNavigationHelper.navigateTo(
                              Routes.tradeActionScreen,
                              arguments: tabIndex);
                          debugPrint(
                              "Navigation called via WebNavigationHelper with tabIndex: $tabIndex");
                        } catch (e) {
                          debugPrint("WebNavigationHelper error: $e");
                          // Fallback to direct navigation
                          _navigateToTradeAction(context, tabIndex);
                        }
                      } else {
                        debugPrint(
                            "WebNavigationHelper not available, using direct navigation");
                        _navigateToTradeAction(context, tabIndex);
                      }
                    },
                    child: Text(
                      // 'See all',
                      '',
                      style: MyntWebTextStyles.para(
                        context,
                        darkColor: MyntColors.primaryDark,
                        lightColor: MyntColors.primary,
                        fontWeight: MyntFonts.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stock list
          if (hasStocks)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayStocks.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: shadcn.Theme.of(context).colorScheme.border,
                ),
                itemBuilder: (context, index) {
                  final stock = displayStocks[index];
                  return _TradeActionStockItem(
                    stock: stock,
                    showVolume: isVolumeBreakout,
                    showPrice: showPrice,
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  'Loading...',
                  style: MyntWebTextStyles.para(
                    context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToTradeAction(BuildContext context, int tabIndex) {
    try {
      Navigator.of(context).pushNamed(
        Routes.tradeActionScreen,
        arguments: tabIndex,
      );
      debugPrint("Direct navigation attempted with tabIndex: $tabIndex");
    } catch (e) {
      debugPrint("Direct navigation error: $e");
      // Last resort: try MaterialPageRoute
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TradeActionScreenWeb(initialTabIndex: tabIndex),
        ),
      );
    }
  }

  void _scrollTradeAction(double offset) {
    if (_tradeActionScrollController.hasClients) {
      final currentOffset = _tradeActionScrollController.offset;
      final maxScrollExtent =
          _tradeActionScrollController.position.maxScrollExtent;
      final newOffset = currentOffset + offset;

      final clampedOffset = newOffset.clamp(0.0, maxScrollExtent);

      if (clampedOffset != currentOffset) {
        _tradeActionScrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _showAllIndicesBottomSheet(
    BuildContext context,
    IndexListProvider indexProvider,
  ) async {
    try {
      // Get first index from top indices or default index list as reference
      final topIndices = indexProvider.topIndicesForDashboard?.indValues;
      final defaultIndices = indexProvider.defaultIndexList?.indValues;

      // Use first index from top indices, or fallback to first default index
      final defaultIndex = (topIndices != null && topIndices.isNotEmpty)
          ? topIndices[0]
          : (defaultIndices != null && defaultIndices.isNotEmpty)
              ? defaultIndices[0]
              : null;

      if (defaultIndex == null) {
        return;
      }

      // Fetch index list for the bottom sheet
      await indexProvider.fetchIndexList("NSE", context);

      // Show the bottom sheet
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: IndexBottomSheetWeb(
              defaultIndex: defaultIndex,
              indexPosition: 0, // Use position 0 for "See all indices"
            ),
          );
        },
      );

      // Clean up after dialog closes
      await indexProvider.fetchIndexList("exit", context);
      final marketWatch = ref.read(marketWatchProvider);
      await marketWatch.requestMWScrip(context: context, isSubscribe: true);
    } catch (e) {
      debugPrint("Error showing all indices bottom sheet: $e");
    }
  }
}

// Custom index card widget for dashboard
class _DashboardIndexCard extends ConsumerStatefulWidget {
  final dynamic indexItem;

  const _DashboardIndexCard({
    required this.indexItem,
  });

  @override
  ConsumerState<_DashboardIndexCard> createState() =>
      _DashboardIndexCardState();
}

class _DashboardIndexCardState extends ConsumerState<_DashboardIndexCard> {
  StreamSubscription? _subscription;
  String _ltp = "0.00";
  String _change = "0.00";
  String _perChange = "0.00";
  bool _isInitialized = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    final item = widget.indexItem;
    _ltp = (item.ltp == null || item.ltp == "null")
        ? "0.00"
        : item.ltp?.toString() ?? "0.00";
    _change = (item.change == null || item.change == "null")
        ? "0.00"
        : item.change?.toString() ?? "0.00";
    _perChange = (item.perChange == null || item.perChange == "null")
        ? "0.00"
        : item.perChange?.toString() ?? "0.00";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _setupSocketListener();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    final token = widget.indexItem.token?.toString() ?? "";
    if (token.isEmpty) return;

    final websocket = ref.read(websocketProvider);

    // Check existing data
    final existingData = websocket.socketDatas[token];
    if (existingData != null) {
      final hasChanged = _updateFromSocketData(existingData);
      if (hasChanged && mounted) {
        setState(() {});
      }
    }

    // Listen for updates - only rebuild if data actually changed
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token) && mounted) {
        final socketData = data[token];
        if (socketData != null) {
          final hasChanged = _updateFromSocketData(socketData);
          if (hasChanged) {
            setState(() {});
          }
        }
      }
    });
  }

  bool _updateFromSocketData(dynamic data) {
    bool hasChanged = false;

    final newLtp = data['lp']?.toString() ?? "0.00";
    if (newLtp != "null" && newLtp != _ltp) {
      _ltp = newLtp;
      hasChanged = true;
    }

    final newChange = data['chng']?.toString() ?? "0.00";
    if (newChange != "null" && newChange != _change) {
      _change = newChange;
      hasChanged = true;
    }

    final newPerChange = data['pc']?.toString() ?? "0.00";
    if (newPerChange != "null" && newPerChange != _perChange) {
      _perChange = newPerChange;
      hasChanged = true;
    }

    return hasChanged;
  }

  Color _getChangeColor(BuildContext context) {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (_change == "0.00" || _perChange == "0.00") {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    } else {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor(context);
    final marketWatch = ref.read(marketWatchProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          try {
            // First, safely fetch the quote data
            await marketWatch.fetchScripQuoteIndex(
              widget.indexItem.token?.toString() ?? "",
              widget.indexItem.exch?.toString() ?? "",
              context,
            );

            final quots = marketWatch.getQuotes;

            // Make sure we have valid quote data before proceeding
            if (quots == null) {
              return;
            }

            // Create DepthInputArgs with null safety
            DepthInputArgs depthArgs = DepthInputArgs(
                exch: quots.exch?.toString() ?? "",
                token: quots.token?.toString() ?? "",
                tsym: quots.tsym?.toString() ?? "",
                instname: quots.instname?.toString() ?? "",
                symbol: quots.symbol?.toString() ?? "",
                expDate: quots.expDate?.toString() ?? "",
                option: quots.option?.toString() ?? "");

            // Call depth APIs with the safely constructed arguments
            if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
              await marketWatch.calldepthApis(context, depthArgs, "");
            }
          } catch (e) {
            debugPrint("Error tapping index: $e");
          }
        },
        child: Container(
          width: 180, // Fixed width for all cards
          height: 100, // Fixed height for all cards
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _isHovered
                ? shadcn.Theme.of(context).colorScheme.muted
                : shadcn.Theme.of(context).colorScheme.card,
            borderRadius: BorderRadius.circular(4),
            // border: Border.all(
            //   color: shadcn.Theme.of(context).colorScheme.border,
            //   width: 1,
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.indexItem.idxname?.toUpperCase() ?? "",
                style: MyntWebTextStyles.body(
                  context,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                  fontWeight: MyntFonts.semiBold,
                ),
              ),
              // Price and change section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LTP without ₹ symbol, with profit/loss color
                  Text(
                    _ltp,
                    style: MyntWebTextStyles.body(
                      context,
                      color: changeColor, // Profit/loss color for LTP
                      fontWeight: MyntFonts.medium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Change and percentage - textPrimary color
                  Row(
                    children: [
                      Text(
                        _change.startsWith("-") ? _change : "+$_change ",
                        style: MyntWebTextStyles.para(
                          context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.medium,
                        ),
                      ),
                      Text(
                        "($_perChange%)",
                        style: MyntWebTextStyles.para(
                          context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.medium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom stock card widget for gainers/losers
class _DashboardStockCard extends ConsumerStatefulWidget {
  final TopGainers stock;
  final bool isGainer;

  const _DashboardStockCard({
    required this.stock,
    required this.isGainer,
  });

  @override
  ConsumerState<_DashboardStockCard> createState() =>
      _DashboardStockCardState();
}

class _DashboardStockCardState extends ConsumerState<_DashboardStockCard> {
  StreamSubscription? _subscription;
  String _ltp = "0.00";
  String _change = "0.00";
  String _perChange = "0.00";
  bool _isInitialized = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _ltp = widget.stock.lp ?? "0.00";
    _change = widget.stock.c ?? "0.00";
    _perChange = widget.stock.pc ?? "0.00";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _setupSocketListener();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    final token = widget.stock.token?.toString() ?? "";
    if (token.isEmpty) return;

    final websocket = ref.read(websocketProvider);

    final existingData = websocket.socketDatas[token];
    if (existingData != null) {
      final hasChanged = _updateFromSocketData(existingData);
      if (hasChanged && mounted) {
        setState(() {});
      }
    }

    // Listen for updates - only rebuild if data actually changed
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token) && mounted) {
        final socketData = data[token];
        if (socketData != null) {
          final hasChanged = _updateFromSocketData(socketData);
          if (hasChanged) {
            setState(() {});
          }
        }
      }
    });
  }

  bool _updateFromSocketData(dynamic data) {
    bool hasChanged = false;

    final newLtp = data['lp']?.toString() ?? "0.00";
    if (newLtp != "null" && newLtp != _ltp) {
      _ltp = newLtp;
      hasChanged = true;
    }

    final newChange = data['c']?.toString() ?? "0.00";
    if (newChange != "null" && newChange != _change) {
      _change = newChange;
      hasChanged = true;
    }

    final newPerChange = data['pc']?.toString() ?? "0.00";
    if (newPerChange != "null" && newPerChange != _perChange) {
      _perChange = newPerChange;
      hasChanged = true;
    }

    return hasChanged;
  }

  Color _getChangeColor(BuildContext context) {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (_change == "0.00" || _perChange == "0.00") {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    } else {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor(context);
    final marketWatch = ref.read(marketWatchProvider);
    final symbolName = widget.stock.tsym?.split("-").isNotEmpty == true
        ? widget.stock.tsym!.split("-").first.toUpperCase()
        : widget.stock.tsym?.toUpperCase() ?? "";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          try {
            await marketWatch.fetchScripQuoteIndex(
              widget.stock.token?.toString() ?? "",
              widget.stock.exch?.toString() ?? "",
              context,
            );

            final quots = marketWatch.getQuotes;
            if (quots == null) {
              return;
            }

            DepthInputArgs depthArgs = DepthInputArgs(
                exch: quots.exch?.toString() ?? "",
                token: quots.token?.toString() ?? "",
                tsym: quots.tsym?.toString() ?? "",
                instname: quots.instname?.toString() ?? "",
                symbol: quots.symbol?.toString() ?? "",
                expDate: quots.expDate?.toString() ?? "",
                option: quots.option?.toString() ?? "");

            if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
              await marketWatch.calldepthApis(context, depthArgs, "");
            }
          } catch (e) {
            debugPrint("Error tapping stock: $e");
          }
        },
        child: Container(
          width: 180,
          height: 125,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? shadcn.Theme.of(context).colorScheme.muted
                : shadcn.Theme.of(context).colorScheme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: shadcn.Theme.of(context).colorScheme.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stock name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbolName,
                    style: MyntWebTextStyles.body(
                      context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.stock.exch ?? "",
                    style: MyntWebTextStyles.caption(
                      context,
                      darkColor: MyntColors.textSecondaryDark,
                      lightColor: MyntColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Price and change section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LTP with profit/loss color
                  Text(
                    _ltp,
                    style: MyntWebTextStyles.body(
                      context,
                      color: changeColor,
                      fontWeight: MyntFonts.semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Change and percentage - textPrimary color
                  Row(
                    children: [
                      Text(
                        _change.startsWith("-") ? _change : "+$_change ",
                        style: MyntWebTextStyles.para(
                          context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.semiBold,
                        ),
                      ),
                      Text(
                        "($_perChange%)",
                        style: MyntWebTextStyles.para(
                          context,
                          darkColor: MyntColors.textPrimaryDark,
                          lightColor: MyntColors.textPrimary,
                          fontWeight: MyntFonts.semiBold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Trade action stock item widget
class _TradeActionStockItem extends ConsumerStatefulWidget {
  final TopGainers stock;
  final bool showVolume;
  final bool showPrice;

  const _TradeActionStockItem({
    required this.stock,
    this.showVolume = false,
    this.showPrice = true,
  });

  @override
  ConsumerState<_TradeActionStockItem> createState() =>
      _TradeActionStockItemState();
}

class _TradeActionStockItemState extends ConsumerState<_TradeActionStockItem> {
  StreamSubscription? _subscription;
  String _ltp = "0.00";
  String _change = "0.00";
  String _perChange = "0.00";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _ltp = widget.stock.lp ?? "0.00";
    _change = widget.stock.c ?? "0.00";
    _perChange = widget.stock.pc ?? "0.00";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _setupSocketListener();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    final token = widget.stock.token?.toString() ?? "";
    if (token.isEmpty) return;

    final websocket = ref.read(websocketProvider);

    final existingData = websocket.socketDatas[token];
    if (existingData != null) {
      final hasChanged = _updateFromSocketData(existingData);
      if (hasChanged && mounted) {
        setState(() {});
      }
    }

    // Listen for updates - only rebuild if data actually changed
    _subscription = websocket.socketDataStream.listen((data) {
      if (data.containsKey(token) && mounted) {
        final socketData = data[token];
        if (socketData != null) {
          final hasChanged = _updateFromSocketData(socketData);
          if (hasChanged) {
            setState(() {});
          }
        }
      }
    });
  }

  bool _updateFromSocketData(dynamic data) {
    bool hasChanged = false;

    final newLtp = data['lp']?.toString() ?? "0.00";
    if (newLtp != "null" && newLtp != _ltp) {
      _ltp = newLtp;
      hasChanged = true;
    }

    final newChange = data['c']?.toString() ?? "0.00";
    if (newChange != "null" && newChange != _change) {
      _change = newChange;
      hasChanged = true;
    }

    final newPerChange = data['pc']?.toString() ?? "0.00";
    if (newPerChange != "null" && newPerChange != _perChange) {
      _perChange = newPerChange;
      hasChanged = true;
    }

    return hasChanged;
  }

  Color _getChangeColor(BuildContext context) {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (_change == "0.00" || _perChange == "0.00") {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    } else {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor(context);
    final marketWatch = ref.read(marketWatchProvider);
    final symbolName = widget.stock.tsym?.split("-").isNotEmpty == true
        ? widget.stock.tsym!.split("-").first.toUpperCase()
        : widget.stock.tsym?.toUpperCase() ?? "";
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () async {
              try {
                await marketWatch.fetchScripQuoteIndex(
                  widget.stock.token?.toString() ?? "",
                  widget.stock.exch?.toString() ?? "",
                  context,
                );

                final quots = marketWatch.getQuotes;
                if (quots == null) {
                  return;
                }

                DepthInputArgs depthArgs = DepthInputArgs(
                    exch: quots.exch?.toString() ?? "",
                    token: quots.token?.toString() ?? "",
                    tsym: quots.tsym?.toString() ?? "",
                    instname: quots.instname?.toString() ?? "",
                    symbol: quots.symbol?.toString() ?? "",
                    expDate: quots.expDate?.toString() ?? "",
                    option: quots.option?.toString() ?? "");

                if (depthArgs.token.isNotEmpty && depthArgs.exch.isNotEmpty) {
                  await marketWatch.calldepthApis(context, depthArgs, "");
                }
              } catch (e) {
                debugPrint("Error tapping stock: $e");
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              decoration: BoxDecoration(
                color: isHovered
                    ? shadcn.Theme.of(context).colorScheme.muted
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  // First row: Symbol | LTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symbol
                      Expanded(
                        child: Text(
                          symbolName,
                          style: MyntWebTextStyles.body(
                            context,
                            darkColor: MyntColors.textPrimaryDark,
                            lightColor: MyntColors.textPrimary,
                          ),
                        ),
                      ),
                      // LTP
                      if (widget.showPrice)
                        Text(
                          "₹$_ltp",
                          style: MyntWebTextStyles.body(
                            context,
                            color: changeColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second row: Exchange | Change & Change %
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exchange
                      Expanded(
                        child: Text(
                          widget.stock.exch ?? "",
                          style: MyntWebTextStyles.exch(
                            context,
                            darkColor: MyntColors.textSecondaryDark,
                            lightColor: MyntColors.textSecondary,
                          ),
                        ),
                      ),
                      // Change and percentage
                      if (widget.showPrice)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _change.startsWith("-") ? _change : "+$_change",
                              style: MyntWebTextStyles.para(
                                context,
                                darkColor: MyntColors.textPrimaryDark,
                                lightColor: MyntColors.textPrimary,
                              ),
                            ),
                            Text(
                              " ($_perChange%)",
                              style: MyntWebTextStyles.para(
                                context,
                                darkColor: MyntColors.textPrimaryDark,
                                lightColor: MyntColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

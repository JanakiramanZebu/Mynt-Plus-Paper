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

  @override
  void initState() {
    super.initState();
    // Note: Data fetching is handled by _handleDashboardTap() in customizable_split_home_screen.dart
    // This prevents duplicate API calls when dashboard button is clicked
    // WebSocket bodyscription is handled by WebbodyscriptionManager
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final indexProvider = ref.read(indexListProvider);

        // Get top indices for dashboard (8 specific indices) if not already fetched
        // This ensures tokens are available for WebbodyscriptionManager
        // Only fetch if not already available to avoid duplicate calls
        if (indexProvider.topIndicesForDashboard == null) {
          await indexProvider.getTopIndicesForDashboard(context);
        }

        // Trade action data is fetched by _handleDashboardTap() before this screen is shown
        // No need to fetch here to avoid duplicate TopList API calls
      }
    });
  }

  @override
  void dispose() {
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
      backgroundColor: shadcn.Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard cards section (Holdings, Position, Orders, Margins)
              _buildDashboardCardsSection(context),
              const SizedBox(height: 32),
              // Top indices section
              _buildTopIndicesSection(context, indexProvider),
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
    return Consumer(
      builder: (context, ref, _) {
        final portfolio = ref.watch(portfolioProvider);
        final orders = ref.watch(orderProvider);
        final fund = ref.watch(fundProvider);
        // Watch websocket to rebuild when price data updates (triggers rebuild on any socket data change)
        ref.watch(websocketProvider);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid configuration based on available width
            final width = constraints.maxWidth;
            int crossAxisCount;

            if (width >= 800) {
              // Large and medium screens: 2 columns
              crossAxisCount = 2;
            } else {
              // Small screens: 1 column
              crossAxisCount = 1;
            }

            // Calculate card width based on columns
            final cardWidth = crossAxisCount == 2
                ? (width - 12) / 2 // bodytract spacing and divide by 2
                : width;

            // Use Wrap instead of GridView to allow natural card heights
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildHoldingsCard(context, portfolio),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildPositionCard(context, portfolio),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildOrdersCard(context, orders),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildMarginsCard(context, fund),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHoldingsCard(BuildContext context, PortfolioProvider portfolio) {
    final holdings = portfolio.holdingsModel ?? [];
    final holdingsCount = holdings.length;

    // Calculate stats locally from holdings data (like mobile does)
    double totalPnlHolding = 0.0;
    double oneDayChng = 0.0;
    double invest = 0.0;
    double totalCurrentVal = 0.0;
    int positiveCount = 0;
    int negativeCount = 0;

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

        if (pnl + rpnl > 0) {
          positiveCount++;
        } else if (pnl + rpnl < 0) {
          negativeCount++;
        }
      }
    }

    // Calculate percentages
    final oneDayChngPer = totalCurrentVal > 0 ? (oneDayChng / totalCurrentVal) * 100 : 0.0;
    final totPnlPercHolding = invest > 0 ? ((totalPnlHolding / invest) * 100).toStringAsFixed(2) : '0.00';

    final invested = invest.toStringAsFixed(2);
    final current = totalCurrentVal.toStringAsFixed(2);
    final totalPnL = totalPnlHolding.toStringAsFixed(2);
    final totalPnLPercent = totPnlPercHolding;
    final todayPnL = oneDayChng.toStringAsFixed(2);
    final todayPnLPercent = oneDayChngPer.toStringAsFixed(2);

    return _buildCard(
      context: context,
      title: 'Holdings',
      icon: Icons.work_outline,
      iconColor: resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit),
      metrics: [
        {'label': 'Invested', 'value': '₹$invested'},
        {'label': 'Current', 'value': '₹$current'},
        {
          'label': 'Total P&L',
          'value': '₹$totalPnL',
          'percent': '$totalPnLPercent%'
        },
        {
          'label': 'Today P&L',
          'value': '₹$todayPnL',
          'percent': '$todayPnLPercent%'
        },
      ],
      summary: 'No of holdings - $holdingsCount',
      positiveCount: positiveCount,
      negativeCount: negativeCount,
      onViewDetails: () {
        if (WebNavigationHelper.isAvailable) {
          WebNavigationHelper.navigateTo(Routes.holdingscreen);
        }
      },
    );
  }

  Widget _buildPositionCard(BuildContext context, PortfolioProvider portfolio) {
    // Use postionBookModel for all positions (both open and closed)
    final positions = portfolio.postionBookModel ?? [];
    final positionsCount = positions.length;
    final openPositionsCount = positions.where((p) => p.netqty != "0").length;

    // Calculate stats locally from positions data (like mobile does)
    double totBuyAmts = 0.0;
    double totMtm = 0.0;
    double totPnl = 0.0;
    double unRealMtm = 0.0;
    int positiveCount = 0;
    int negativeCount = 0;

    for (var position in positions) {
      final buyAmt = double.tryParse(position.totbuyamt ?? '0') ?? 0.0;
      final mtmVal = double.tryParse(position.mTm ?? '0') ?? 0.0;
      final pnlVal = double.tryParse(position.profitNloss ?? '0') ?? 0.0;

      totBuyAmts += buyAmt;
      totMtm += mtmVal;
      totPnl += pnlVal;

      // Count positive/negative based on P&L for ALL positions
      if (pnlVal > 0) {
        positiveCount++;
      } else if (pnlVal < 0) {
        negativeCount++;
      }

      // For unrealized P&L, only count open positions
      if (position.netqty != "0") {
        unRealMtm += pnlVal;
      }
    }

    final tradeValue = totBuyAmts.toStringAsFixed(2);
    final mtm = totMtm.toStringAsFixed(2);
    final totalPnL = totPnl.toStringAsFixed(2);
    final openPnL = unRealMtm.toStringAsFixed(2);

    return _buildCard(
      context: context,
      title: 'Position',
      icon: Icons.trending_up,
      iconColor: resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit),
      metrics: [
        {'label': 'Trade value', 'value': '₹$tradeValue'},
        {'label': 'MTM', 'value': '₹$mtm'},
        {'label': 'Total P&L', 'value': '₹$totalPnL'},
        {'label': 'Open P&L', 'value': '₹$openPnL'},
      ],
      summary:
          'No of positions - $positionsCount / Open positions - $openPositionsCount',
      positiveCount: positiveCount,
      negativeCount: negativeCount,
      onViewDetails: () {
        if (WebNavigationHelper.isAvailable) {
          WebNavigationHelper.navigateTo(Routes.positionscreen);
        }
      },
    );
  }

  Widget _buildOrdersCard(BuildContext context, OrderProvider orders) {
    final orderList = orders.orderBookModel ?? [];
    final openOrders = orderList
        .where((o) => o.status == 'OPEN' || o.status == 'PENDING')
        .length;
    final executedOrders =
        orderList.where((o) => o.status == 'COMPLETE').length;
    final rejectedOrders = orderList
        .where((o) => o.status == 'REJECTED' || o.status == 'CANCELED')
        .length;

    return _buildCard(
      context: context,
      title: 'Orders',
      icon: Icons.shopping_bag_outlined,
      iconColor: resolveThemeColor(context,
          dark: MyntColors.primaryDark, light: MyntColors.primary),
      metrics: [
        {'label': 'Open Orders', 'value': '$openOrders'},
        {'label': 'Execute Orders', 'value': '$executedOrders'},
        {'label': 'Rejected', 'value': '$rejectedOrders'},
      ],
      showPositiveNegative: false,
      onViewDetails: () {
        if (WebNavigationHelper.isAvailable) {
          WebNavigationHelper.navigateTo(Routes.orderBook);
        }
      },
    );
  }

  Widget _buildMarginsCard(BuildContext context, FundProvider fund) {
    final fundDetail = fund.fundDetailModel;
    final availableBalance =
        fundDetail?.avlMrg ?? fundDetail?.totCredit ?? '0.00';
    final totalCredits = fundDetail?.totCredit ?? '0.00';
    final marginUsed = fundDetail?.marginused ?? '0.00';

    return _buildCard(
      context: context,
      title: 'Margins',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: resolveThemeColor(context,
          dark: MyntColors.primaryDark, light: MyntColors.primary),
      metrics: [
        {'label': 'Available balance', 'value': '₹$availableBalance'},
        {'label': 'Total credits', 'value': '₹$totalCredits'},
        {'label': 'Margin used', 'value': '₹$marginUsed'},
      ],
      showPositiveNegative: false,
      onViewDetails: () {
        if (WebNavigationHelper.isAvailable) {
          WebNavigationHelper.navigateTo(Routes.fundscreen);
        }
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, String>> metrics,
    String? summary,
    int positiveCount = 0,
    int negativeCount = 0,
    bool showPositiveNegative = true,
    required VoidCallback onViewDetails,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: shadcn.Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and icon
          Row(
            children: [
              Row(
                children: [
                  Text(
                    title,
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
          ),
          const SizedBox(height: 16),
          // Metrics grid - responsive based on card width, no fixed aspect ratio
          LayoutBuilder(
            builder: (ctx, constraints) {
              // Calculate responsive metrics grid columns
              final cardWidth = constraints.maxWidth;
              int metricsColumns;

              if (cardWidth >= 600) {
                // Wide cards: 4 columns (original)
                metricsColumns = 4;
              } else if (cardWidth >= 400) {
                // Medium cards: 2 columns, 2 rows
                metricsColumns = 2;
              } else {
                // Narrow cards: 2 columns
                metricsColumns = 2;
              }

              // Use Wrap instead of GridView to allow natural sizing
              return Wrap(
                spacing: 8,
                runSpacing: 12,
                children: List.generate(
                  metrics.length,
                  (index) {
                    final metric = metrics[index];
                    return SizedBox(
                      width: (cardWidth - (8 * (metricsColumns - 1))) /
                          metricsColumns,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            metric['label'] ?? '',
                            style: MyntWebTextStyles.para(
                              context,
                              darkColor: MyntColors.textSecondaryDark,
                              lightColor: MyntColors.textSecondary,
                              fontWeight: MyntFonts.semiBold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  metric['value'] ?? '0.00',
                                  style: MyntWebTextStyles.bodySmall(
                                    context,
                                    darkColor: MyntColors.textPrimaryDark,
                                    lightColor: MyntColors.textPrimary,
                                    fontWeight: MyntFonts.semiBold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (metric['percent'] != null) ...[
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    metric['percent']!,
                                    style: MyntWebTextStyles.bodySmall(
                                      context,
                                      darkColor: MyntColors.textSecondaryDark,
                                      lightColor: MyntColors.textSecondary,
                                      fontWeight: MyntFonts.semiBold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Summary and buttons
          if (summary != null || showPositiveNegative) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (summary != null)
                  Expanded(
                    child: Text(
                      summary,
                      style: MyntWebTextStyles.para(
                        context,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary,
                        fontWeight: MyntFonts.semiBold,
                      ),
                    ),
                  ),
                if (showPositiveNegative) ...[
                  if (summary != null) const SizedBox(width: 12),
                  _buildPillButton(
                    context,
                    '$positiveCount Positive',
                    Icons.arrow_upward,
                    resolveThemeColor(context,
                        dark: MyntColors.profitDark, light: MyntColors.profit),
                  ),
                  const SizedBox(width: 8),
                  _buildPillButton(
                    context,
                    '$negativeCount Negative',
                    Icons.arrow_downward,
                    resolveThemeColor(context,
                        dark: MyntColors.lossDark, light: MyntColors.loss),
                  ),
                ],
              ],
            ),
          ],
          // View details link
          const SizedBox(height: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onViewDetails,
              child: Text(
                'View details',
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
    );
  }

  Widget _buildPillButton(
      BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: MyntWebTextStyles.para(
              context,
              color: color,
              fontWeight: MyntFonts.semiBold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }

  Widget _buildTopIndicesSection(
      BuildContext context, IndexListProvider indexProvider) {
    // Use topIndicesForDashboard (8 specific indices for dashboard)
    final indexValues = indexProvider.topIndicesForDashboard?.indValues;
    final hasIndices = indexValues != null && indexValues.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and navigation arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with icons
            Row(
              children: [
                Text(
                  'Top indices',
                  style: MyntWebTextStyles.head(
                    context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                    fontWeight: MyntFonts.bold,
                  ),
                ),
              ],
            ),
            // Navigation arrows
            Row(
              children: [
                // Left arrow button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _scrollIndices(-200);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shadcn.Theme.of(context).colorScheme.card,
                          border: Border.all(
                            color: shadcn.Theme.of(context).colorScheme.border,
                            width: 1,
                          ),
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
                const SizedBox(width: 8),
                // Right arrow button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _scrollIndices(200);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shadcn.Theme.of(context).colorScheme.card,
                          border: Border.all(
                            color: shadcn.Theme.of(context).colorScheme.border,
                            width: 1,
                          ),
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
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Index cards - horizontal scrollable
        if (hasIndices)
          SizedBox(
            height: 140, // Fixed height for index cards
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
        const SizedBox(height: 12),
        // "See all indices" link
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              await _showAllIndicesBottomSheet(context, indexProvider);
            },
            child: Text(
              'See all indices',
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
                      'See all',
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
          height: 125, // Fixed height for all cards
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
              // Index name with underline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.indexItem.idxname?.toUpperCase() ?? "",
                    style: MyntWebTextStyles.body(
                      context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    height: 1,
                    width: 30,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                  ),
                ],
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

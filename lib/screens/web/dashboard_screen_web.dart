import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../provider/thems.dart';
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
    // WebSocket subscription is handled by WebSubscriptionManager
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final indexProvider = ref.read(indexListProvider);
        
        // Get top indices for dashboard (8 specific indices) if not already fetched
        // This ensures tokens are available for WebSubscriptionManager
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
    // Note: WebSubscriptionManager handles unsubscription automatically
    // when screen is replaced or removed via updateActiveScreen()
    // No need to unsubscribe here to avoid double calls
    
    _indexScrollController.dispose();
    _tradeActionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final indexProvider = ref.watch(indexListProvider);
    
    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? WebDarkColors.background
          : WebColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard cards section (Holdings, Position, Orders, Margins)
              _buildDashboardCardsSection(theme),
              const SizedBox(height: 32),
              // Top indices section
              _buildTopIndicesSection(theme, indexProvider),
              const SizedBox(height: 32),
              // Today's trade action section
              _buildTodaysTradeActionSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCardsSection(ThemesProvider theme) {
    return Consumer(
      builder: (context, ref, _) {
        final portfolio = ref.watch(portfolioProvider);
        final orders = ref.watch(orderProvider);
        final fund = ref.watch(fundProvider);
        
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.5,
          children: [
            _buildHoldingsCard(theme, portfolio),
            _buildPositionCard(theme, portfolio),
            _buildOrdersCard(theme, orders),
            _buildMarginsCard(theme, fund),
          ],
        );
      },
    );
  }

  Widget _buildHoldingsCard(ThemesProvider theme, PortfolioProvider portfolio) {
    final holdings = portfolio.holdingsModel ?? [];
    final holdingsCount = holdings.length;
    final invested = portfolio.totInvesHold;
    final current = portfolio.totalCurrentVal.toStringAsFixed(2);
    final totalPnL = portfolio.totalPnlHolding.toStringAsFixed(2);
    final totalPnLPercent = portfolio.totPnlPercHolding;
    final todayPnL = portfolio.oneDayChng.toStringAsFixed(2);
    final todayPnLPercent = portfolio.oneDayChngPer.toStringAsFixed(2);
    
    // Calculate positive and negative holdings
    int positiveCount = 0;
    int negativeCount = 0;
    for (var holding in holdings) {
      if (holding.exchTsym != null && holding.exchTsym!.isNotEmpty) {
        final pnl = double.tryParse(holding.exchTsym![0].profitNloss ?? '0') ?? 0.0;
        final rpnl = double.tryParse(holding.rpnl ?? '0') ?? 0.0;
        if (pnl + rpnl > 0) {
          positiveCount++;
        } else if (pnl + rpnl < 0) {
          negativeCount++;
        }
      }
    }
    
    return _buildCard(
      theme: theme,
      title: 'Holdings',
      icon: Icons.work_outline,
      iconColor: theme.isDarkMode ? WebDarkColors.success : WebColors.success,
      metrics: [
        {'label': 'Invested', 'value': '₹$invested'},
        {'label': 'Current', 'value': '₹$current'},
        {'label': 'Total P&L', 'value': '₹$totalPnL', 'percent': '$totalPnLPercent%'},
        {'label': 'Today P&L', 'value': '₹$todayPnL', 'percent': '$todayPnLPercent%'},
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

  Widget _buildPositionCard(ThemesProvider theme, PortfolioProvider portfolio) {
    final positions = portfolio.openPosition ?? [];
    final positionsCount = positions.length;
    final openPositionsCount = positions.where((p) => p.qty != "0").length;
    final tradeValue = portfolio.totBuyAmt;
    final mtm = portfolio.totMtM;
    final totalPnL = portfolio.totPnL;
    final openPnL = portfolio.totUnRealMtm;
    
    // Calculate positive and negative positions
    int positiveCount = 0;
    int negativeCount = 0;
    for (var position in positions) {
      if (position.qty != "0") {
        final pnl = double.tryParse(position.profitNloss ?? '0') ?? 0.0;
        if (pnl > 0) {
          positiveCount++;
        } else if (pnl < 0) {
          negativeCount++;
        }
      }
    }
    
    return _buildCard(
      theme: theme,
      title: 'Position',
      icon: Icons.trending_up,
      iconColor: theme.isDarkMode ? WebDarkColors.success : WebColors.success,
      metrics: [
        {'label': 'Trade value', 'value': '₹$tradeValue'},
        {'label': 'MTM', 'value': '₹$mtm'},
        {'label': 'Total P&L', 'value': '₹$totalPnL'},
        {'label': 'Open P&L', 'value': '₹$openPnL'},
      ],
      summary: 'No of positions - $positionsCount / Open positions - $openPositionsCount',
      positiveCount: positiveCount,
      negativeCount: negativeCount,
      onViewDetails: () {
        if (WebNavigationHelper.isAvailable) {
          WebNavigationHelper.navigateTo(Routes.positionscreen);
        }
      },
    );
  }

  Widget _buildOrdersCard(ThemesProvider theme, OrderProvider orders) {
    final orderList = orders.orderBookModel ?? [];
    final openOrders = orderList.where((o) => o.status == 'OPEN' || o.status == 'PENDING').length;
    final executedOrders = orderList.where((o) => o.status == 'COMPLETE').length;
    final rejectedOrders = orderList.where((o) => o.status == 'REJECTED' || o.status == 'CANCELED').length;
    
    return _buildCard(
      theme: theme,
      title: 'Orders',
      icon: Icons.shopping_bag_outlined,
      iconColor: theme.isDarkMode ? WebDarkColors.warning : WebColors.warning,
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

  Widget _buildMarginsCard(ThemesProvider theme, FundProvider fund) {
    final fundDetail = fund.fundDetailModel;
    final availableBalance = fundDetail?.avlMrg ?? fundDetail?.totCredit ?? '0.00';
    final totalCredits = fundDetail?.totCredit ?? '0.00';
    final marginUsed = fundDetail?.marginused ?? '0.00';
    
    return _buildCard(
      theme: theme,
      title: 'Margins',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: theme.isDarkMode ? WebDarkColors.warning : WebColors.warning,
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
    required ThemesProvider theme,
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
        color: theme.isDarkMode ? WebDarkColors.surface : Colors.white,
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
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Icon(icon, color: iconColor, size: 20),
                  // const SizedBox(width: 8),
                  Text(
                    title,
                    style: WebTextStyles.head(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.bold,
                    ),
                  ),
                ],
              ),
              // MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   child: GestureDetector(
              //     onTap: onViewDetails,
              //     child: Icon(
              //       Icons.arrow_forward_ios,
              //       size: 16,
              //       color: theme.isDarkMode
              //           ? WebDarkColors.textSecondary
              //           : WebColors.textSecondary,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          // Metrics grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
              childAspectRatio: 3,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    metric['label'] ?? '',
                    style: WebTextStyles.para(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                          fontWeight: WebFonts.semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        metric['value'] ?? '0.00',
                        style: WebTextStyles.sub(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.semiBold,
                        ),
                      ),
                      if (metric['percent'] != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          metric['percent']!,
                          style: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.semiBold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
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
                      style: WebTextStyles.para(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
                        fontWeight: WebFonts.semiBold,
                      ),
                    ),
                  ),
                if (showPositiveNegative) ...[
                  if (summary != null) const SizedBox(width: 12),
                  _buildPillButton(
                    theme,
                    '$positiveCount Positive',
                    Icons.arrow_upward,
                    theme.isDarkMode ? WebDarkColors.success : WebColors.success,
                  ),
                  const SizedBox(width: 8),
                  _buildPillButton(
                    theme,
                    '$negativeCount Negative',
                    Icons.arrow_downward,
                    theme.isDarkMode ? WebDarkColors.error : WebColors.error,
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
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                  fontWeight: WebFonts.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton(ThemesProvider theme, String label, IconData icon, Color color) {
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
            style: WebTextStyles.para(
              isDarkTheme: theme.isDarkMode,
              color: color,
              fontWeight: WebFonts.semiBold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }

  Widget _buildTopIndicesSection(ThemesProvider theme, IndexListProvider indexProvider) {
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
                  style: WebTextStyles.head(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: WebFonts.bold,
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
                          color: theme.isDarkMode
                              ? WebDarkColors.surface
                              : WebColors.surface,
                          border: Border.all(
                            color: theme.isDarkMode
                                ? WebDarkColors.divider
                                : WebColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
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
                          color: theme.isDarkMode
                              ? WebDarkColors.surface
                              : WebColors.surface,
                          border: Border.all(
                            color: theme.isDarkMode
                                ? WebDarkColors.divider
                                : WebColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
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
          Container(
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
                      isDarkMode: theme.isDarkMode,
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        else
          Container(
            height: 120,
            child: Center(
              child: Text(
                'Loading indices...',
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
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
              await _showAllIndicesBottomSheet(context, theme, indexProvider);
            },
            child: Text(
              'See all indices',
              style: WebTextStyles.para(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.primary
                    : WebColors.primary,
                fontWeight: WebFonts.bold,
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

  Widget _buildTodaysTradeActionSection(ThemesProvider theme) {
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
          style: WebTextStyles.head(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
            fontWeight: WebFonts.bold,
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
            final totalSpacing = cardSpacing * (totalCards - 1);
            final totalMinWidth = (minCardWidth * totalCards) + totalSpacing;
            
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
                        theme: theme,
                        title: 'Top gainer',
                        stocks: topGainers,
                        icon: Icons.trending_up,
                        iconColor: theme.isDarkMode ? WebDarkColors.success : WebColors.success,
                        width: cardWidth,
                      ),
                      SizedBox(width: cardSpacing),
                      // Top Losers Card
                      _buildTradeActionCard(
                        tabIndex: 1, // Top losers tab
                        theme: theme,
                        title: 'Top losers',
                        stocks: topLosers,
                        icon: Icons.trending_down,
                        iconColor: theme.isDarkMode ? WebDarkColors.error : WebColors.error,
                        width: cardWidth,
                      ),
                      SizedBox(width: cardSpacing),
                      // Volume Breakout Card
                      _buildTradeActionCard(
                        tabIndex: 2, // Volume breakout tab
                        theme: theme,
                        title: 'Volume breakout',
                        stocks: byVolume,
                        icon: Icons.bar_chart,
                        iconColor: Colors.blue,
                        width: cardWidth,
                      ),
                      SizedBox(width: cardSpacing),
                      // Most Active Card
                      _buildTradeActionCard(
                        tabIndex: 3, // Most active tab
                        theme: theme,
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
                                final newOffset = (_tradeActionScrollController.offset - scrollAmount).clamp(
                                  0.0,
                                  _tradeActionScrollController.position.maxScrollExtent,
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
                                color: theme.isDarkMode
                                    ? WebDarkColors.surface
                                    : WebColors.surface,
                                border: Border.all(
                                  color: theme.isDarkMode
                                      ? WebDarkColors.divider
                                      : WebColors.divider,
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
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
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
                                final newOffset = (_tradeActionScrollController.offset + scrollAmount).clamp(
                                  0.0,
                                  _tradeActionScrollController.position.maxScrollExtent,
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
                                color: theme.isDarkMode
                                    ? WebDarkColors.surface
                                    : WebColors.surface,
                                border: Border.all(
                                  color: theme.isDarkMode
                                      ? WebDarkColors.divider
                                      : WebColors.divider,
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
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
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
    required ThemesProvider theme,
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
        color: theme.isDarkMode
            ? WebDarkColors.surface
            : WebColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode
              ? WebDarkColors.divider.withOpacity(0.3)
              : WebColors.divider.withOpacity(0.3),
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
                      style: WebTextStyles.sub(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: WebFonts.bold,
                      ),
                    ),
                  ],
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint("See all clicked, route: ${Routes.tradeActionScreen}, tabIndex: $tabIndex");
                      debugPrint("WebNavigationHelper.isAvailable: ${WebNavigationHelper.isAvailable}");
                      
                      if (WebNavigationHelper.isAvailable) {
                        try {
                          WebNavigationHelper.navigateTo(Routes.tradeActionScreen, arguments: tabIndex);
                          debugPrint("Navigation called via WebNavigationHelper with tabIndex: $tabIndex");
                        } catch (e) {
                          debugPrint("WebNavigationHelper error: $e");
                          // Fallback to direct navigation
                          _navigateToTradeAction(context, tabIndex);
                        }
                      } else {
                        debugPrint("WebNavigationHelper not available, using direct navigation");
                        _navigateToTradeAction(context, tabIndex);
                      }
                    },
                    child: Text(
                      'See all',
                      style: WebTextStyles.para(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        fontWeight: WebFonts.bold,
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
                  color: theme.isDarkMode
                      ? WebDarkColors.divider.withOpacity(0.3)
                      : WebColors.divider.withOpacity(0.3),
                ),
                itemBuilder: (context, index) {
                  final stock = displayStocks[index];
                  return _TradeActionStockItem(
                    stock: stock,
                    isDarkMode: theme.isDarkMode,
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
                  style: WebTextStyles.para(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textSecondary
                        : WebColors.textSecondary,
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
      final maxScrollExtent = _tradeActionScrollController.position.maxScrollExtent;
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
    ThemesProvider theme,
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
  final bool isDarkMode;

  const _DashboardIndexCard({
    required this.indexItem,
    required this.isDarkMode,
  });

  @override
  ConsumerState<_DashboardIndexCard> createState() => _DashboardIndexCardState();
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

  Color _getChangeColor() {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return widget.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else if (_change == "0.00" || _perChange == "0.00") {
      return widget.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return widget.isDarkMode ? WebDarkColors.success : WebColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor();
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
               ? (widget.isDarkMode
                   ? WebDarkColors.surfaceVariant.withOpacity(0.5)
                   : WebColors.surfaceVariant.withOpacity(0.5))
               : (widget.isDarkMode
                   ? WebDarkColors.surface
                   : WebColors.surface),
           borderRadius: BorderRadius.circular(8),
           border: Border.all(
             color: (widget.isDarkMode
                     ? WebDarkColors.divider
                     : WebColors.divider),
             width:  1,
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
                  style: WebTextStyles.sub(
                    isDarkTheme: widget.isDarkMode,
                    color: widget.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: WebFonts.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  height: 1,
                  width: 30,
                  color: widget.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
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
                  style: WebTextStyles.sub(
                    isDarkTheme: widget.isDarkMode,
                    color: changeColor, // Profit/loss color for LTP
                    fontWeight: WebFonts.semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                // Change and percentage - textPrimary color
                Row(
                  children: [
                    Text(
                      _change.startsWith("-") ? _change  : "+$_change " ,
                      style: WebTextStyles.para(
                        isDarkTheme: widget.isDarkMode,
                        color: widget.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: WebFonts.semiBold,
                      ),
                    ),
                    Text(
                      "($_perChange%)",
                      style: WebTextStyles.para(
                        isDarkTheme: widget.isDarkMode,
                        color: widget.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: WebFonts.semiBold,
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
  final bool isDarkMode;
  final bool isGainer;

  const _DashboardStockCard({
    required this.stock,
    required this.isDarkMode,
    required this.isGainer,
  });

  @override
  ConsumerState<_DashboardStockCard> createState() => _DashboardStockCardState();
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

  Color _getChangeColor() {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return widget.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else if (_change == "0.00" || _perChange == "0.00") {
      return widget.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return widget.isDarkMode ? WebDarkColors.success : WebColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor();
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
                ? (widget.isDarkMode
                    ? WebDarkColors.surfaceVariant.withOpacity(0.5)
                    : WebColors.surfaceVariant.withOpacity(0.5))
                : (widget.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (widget.isDarkMode
                  ? WebDarkColors.divider
                  : WebColors.divider),
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
                    style: WebTextStyles.sub(
                      isDarkTheme: widget.isDarkMode,
                      color: widget.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.stock.exch ?? "",
                    style: WebTextStyles.caption(
                      isDarkTheme: widget.isDarkMode,
                      color: widget.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
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
                    style: WebTextStyles.sub(
                      isDarkTheme: widget.isDarkMode,
                      color: changeColor,
                      fontWeight: WebFonts.semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Change and percentage - textPrimary color
                  Row(
                    children: [
                      Text(
                        _change.startsWith("-") ? _change : "+$_change ",
                        style: WebTextStyles.para(
                          isDarkTheme: widget.isDarkMode,
                          color: widget.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.semiBold,
                        ),
                      ),
                      Text(
                        "($_perChange%)",
                        style: WebTextStyles.para(
                          isDarkTheme: widget.isDarkMode,
                          color: widget.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: WebFonts.semiBold,
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
  final bool isDarkMode;
  final bool showVolume;
  final bool showPrice;

  const _TradeActionStockItem({
    required this.stock,
    required this.isDarkMode,
    this.showVolume = false,
    this.showPrice = true,
  });

  @override
  ConsumerState<_TradeActionStockItem> createState() => _TradeActionStockItemState();
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

  Color _getChangeColor() {
    if (_change.startsWith("-") || _perChange.startsWith('-')) {
      return widget.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else if (_change == "0.00" || _perChange == "0.00") {
      return widget.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return widget.isDarkMode ? WebDarkColors.success : WebColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _getChangeColor();
    final marketWatch = ref.read(marketWatchProvider);
    final symbolName = widget.stock.tsym?.split("-").isNotEmpty == true
        ? widget.stock.tsym!.split("-").first.toUpperCase()
        : widget.stock.tsym?.toUpperCase() ?? "";
    bool _isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
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
            color: _isHovered
                ? (widget.isDarkMode
                    ? WebDarkColors.surfaceVariant.withOpacity(0.3)
                    : WebColors.surfaceVariant.withOpacity(0.3))
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
                      style: WebTextStyles.symbolList(
                        isDarkTheme: widget.isDarkMode,
                        color: widget.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        
                      ),
                    ),
                  ),
                  // LTP
                  if (widget.showPrice)
                    Text(
                      "₹$_ltp",
                      style: WebTextStyles.priceWatch(
                        isDarkTheme: widget.isDarkMode,
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
                      style: WebTextStyles.exchText(
                        isDarkTheme: widget.isDarkMode,
                        color: widget.isDarkMode
                            ? WebDarkColors.textSecondary
                            : WebColors.textSecondary,
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
                          style: WebTextStyles.pricePercent(
                            isDarkTheme: widget.isDarkMode,
                            color: widget.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                          ),
                        ),
                        Text(
                          " ($_perChange%)",  
                          style: WebTextStyles.pricePercent(
                            isDarkTheme: widget.isDarkMode,
                            color: widget.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../models/order_book_model/gtt_order_book.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../models/order_book_model/place_gtt_order.dart';
import '../../../../models/portfolio_model/position_book_model.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/assets.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/common_buttons_web.dart';
import '../../../../utils/responsive_snackbar.dart';
import '../../position/group/position_group_screen_web.dart';
import '../scalper_provider.dart';

final _assets = Assets();

/// Positions and Orders panel at the bottom of the scalper screen
/// Supports collapse/expand and drag-to-resize
class ScalperPositionsPanel extends ConsumerStatefulWidget {
  const ScalperPositionsPanel({super.key});

  @override
  ConsumerState<ScalperPositionsPanel> createState() =>
      _ScalperPositionsPanelState();
}

class _ScalperPositionsPanelState extends ConsumerState<ScalperPositionsPanel> {
  int _selectedTabIndex = 0;
  bool _isGrouped = false;
  bool _isDragging = false;
  String _selectedOrderFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scalperProvider).fetchGttOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scalper = ref.watch(scalperProvider);
    final portfolio = ref.watch(portfolioProvider);
    final isCollapsed = scalper.isPositionsPanelCollapsed;

    // Show ALL positions (open + closed), apply position filter
    final rawPositions = portfolio.allPostionList;
    final allPositions = scalper.positionFilter == 'fno'
        ? rawPositions
            .where((p) =>
                p.exch == 'NFO' || p.exch == 'BFO' || p.exch == 'MCX')
            .toList()
        : rawPositions;

    // Calculate totals using profitNloss (matches main positions page)
    double totalPnL = 0;
    for (final pos in allPositions) {
      totalPnL += double.tryParse(pos.profitNloss ?? '0') ?? 0;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle at the top
        _buildDragHandle(context, allPositions, totalPnL),
        // Main content (collapsible)
        if (!isCollapsed)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.backgroundColorDark,
                  light: MyntColors.backgroundColor,
                ),
              ),
              child: Column(
                children: [
                  // Header with tabs and actions
                  _buildHeader(context, totalPnL, allPositions.length),
                  // Content
                  Expanded(
                    child: IndexedStack(
                      index: _selectedTabIndex,
                      children: [
                        // Positions tab - show groups view or regular list
                        _isGrouped
                            ? const PositionGroupScreen()
                            : _buildPositionsList(context, allPositions),
                        // Orders tab
                        _buildOrdersList(context, ref),
                      ],
                    ),
                  ),
                  // Footer with totals (hide when in groups view)
                  if (!_isGrouped) _buildFooter(context, portfolio),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Drag handle for resizing the panel
  Widget _buildDragHandle(BuildContext context, List<PositionBookModel> allPositions, double totalPnL) {
    final scalper = ref.watch(scalperProvider);
    final isCollapsed = scalper.isPositionsPanelCollapsed;

    final isPositive = totalPnL >= 0;
    final pnlColor = isPositive
        ? resolveThemeColor(context, dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context, dark: MyntColors.lossDark, light: MyntColors.loss);

    // Count open positions (non-zero qty)
    final openCount = allPositions.where((p) => (int.tryParse(p.qty ?? '0') ?? 0) != 0).length;

    return GestureDetector(
      onVerticalDragStart: (_) {
        setState(() => _isDragging = true);
      },
      onVerticalDragUpdate: (details) {
        final newHeight = scalper.positionsPanelHeight - details.delta.dy;
        if (newHeight < ScalperProvider.minPanelHeight && !isCollapsed) {
          ref.read(scalperProvider).collapsePositionsPanel();
        } else if (isCollapsed && details.delta.dy < -5) {
          ref.read(scalperProvider).expandPositionsPanel();
        } else if (!isCollapsed) {
          ref.read(scalperProvider).setPositionsPanelHeight(newHeight);
        }
      },
      onVerticalDragEnd: (_) {
        setState(() => _isDragging = false);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: _isDragging
                  ? MyntColors.primaryDark.withValues(alpha: 0.08)
                  : MyntColors.backgroundColorDark,
              light: _isDragging
                  ? MyntColors.primary.withValues(alpha: 0.05)
                  : MyntColors.backgroundColor,
            ),
            border: Border(
              top: BorderSide(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider,
                ),
              ),
            ),
          ),
          child: Stack(
            children: [
              // Drag indicator centered
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.dividerDark,
                      light: MyntColors.divider,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content row on top
              Row(
                children: [
                  // Show P&L summary only when collapsed
                  if (isCollapsed) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Positions',
                      style: MyntWebTextStyles.bodySmall(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: resolveThemeColor(context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary),
                      ),
                    ),
                    if (openCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: resolveThemeColor(context,
                              dark: MyntColors.primaryDark,
                              light: MyntColors.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$openCount',
                          style: MyntWebTextStyles.caption(
                            context,
                            fontWeight: MyntFonts.semiBold,
                            color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    // P&L chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: pnlColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'P&L',
                            style: MyntWebTextStyles.caption(
                              context,
                              fontWeight: MyntFonts.medium,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.textSecondaryDark,
                                  light: MyntColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${isPositive ? '+' : ''}${totalPnL.toStringAsFixed(2)}',
                            style: MyntWebTextStyles.bodySmall(
                              context,
                              fontWeight: MyntFonts.semiBold,
                              color: pnlColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Collapse/Expand button
                  InkWell(
                    onTap: () => ref.read(scalperProvider).togglePositionsPanel(),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double totalPnL, int posCount) {
    final orders = ref.watch(orderProvider);
    final allOrders = orders.allOrder ?? [];
    final openOrders = orders.openOrder ?? [];
    final hasOpenOrders = openOrders.isNotEmpty;

    // Count open positions (non-zero qty, not BO/CO)
    final portfolio = ref.watch(portfolioProvider);
    final openPositions = portfolio.allPostionList
        .where((p) =>
            (int.tryParse(p.qty ?? '0') ?? 0) != 0 &&
            p.sPrdtAli != 'BO' &&
            p.sPrdtAli != 'CO')
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Tabs (matching holdings/positions page pattern)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Positions tab
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (mounted && _selectedTabIndex != 0) {
                      setState(() => _selectedTabIndex = 0);
                      ref.read(scalperProvider).fetchGttOrders(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 0
                          ? (isDarkMode(context)
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Positions',
                          style: MyntWebTextStyles.body(
                            context,
                            fontWeight: _selectedTabIndex == 0
                                ? MyntFonts.semiBold
                                : MyntFonts.medium,
                          ).copyWith(
                            color: _selectedTabIndex == 0
                                ? shadcn.Theme.of(context).colorScheme.foreground
                                : shadcn.Theme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        if (posCount > 0) ...[
                          const SizedBox(width: 4),
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: Text(
                              '$posCount',
                              style: MyntWebTextStyles.bodySmall(
                                context,
                                fontWeight: _selectedTabIndex == 0
                                    ? MyntFonts.semiBold
                                    : MyntFonts.medium,
                              ).copyWith(
                                fontSize: 12,
                                color: _selectedTabIndex == 0
                                    ? shadcn.Theme.of(context).colorScheme.foreground
                                    : shadcn.Theme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Orders tab
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (mounted && _selectedTabIndex != 1) {
                      setState(() => _selectedTabIndex = 1);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 1
                          ? (isDarkMode(context)
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Orders',
                          style: MyntWebTextStyles.body(
                            context,
                            fontWeight: _selectedTabIndex == 1
                                ? MyntFonts.semiBold
                                : MyntFonts.medium,
                          ).copyWith(
                            color: _selectedTabIndex == 1
                                ? shadcn.Theme.of(context).colorScheme.foreground
                                : shadcn.Theme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                        if (openOrders.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: Text(
                              '${openOrders.length}',
                              style: MyntWebTextStyles.bodySmall(
                                context,
                                fontWeight: _selectedTabIndex == 1
                                    ? MyntFonts.semiBold
                                    : MyntFonts.medium,
                              ).copyWith(
                                fontSize: 12,
                                color: _selectedTabIndex == 1
                                    ? shadcn.Theme.of(context).colorScheme.foreground
                                    : shadcn.Theme.of(context).colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Position Groups icon (only on Positions tab)
          if (_selectedTabIndex == 0) ...[
            Tooltip(
              message: _isGrouped ? 'Show Positions' : 'Show Position Groups',
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => setState(() => _isGrouped = !_isGrouped),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: _isGrouped
                        ? BoxDecoration(
                            color: resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          )
                        : null,
                    child: SvgPicture.asset(
                      _assets.posgrp,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        _isGrouped
                            ? resolveThemeColor(context,
                                dark: MyntColors.primaryDark,
                                light: MyntColors.primary)
                            : resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Order filter dropdown (only on Orders tab)
          if (_selectedTabIndex == 1) ...[
            _buildOrderFilterDropdown(context, allOrders),
            const SizedBox(width: 12),
          ],
          // Close All button (only on Positions tab)
          if (_selectedTabIndex == 0) ...[
            _buildActionButton(
              context,
              icon: Icons.close_rounded,
              label: 'Close All',
              isEnabled: openPositions.isNotEmpty,
              color: resolveThemeColor(context,
                  dark: MyntColors.lossDark, light: MyntColors.loss),
              onPressed: openPositions.isNotEmpty
                  ? () => _showCloseAllDialog(context, openPositions)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          // Cancel All button
          _buildActionButton(
            context,
            icon: Icons.cancel_outlined,
            label: 'Cancel All',
            isEnabled: hasOpenOrders,
            color: resolveThemeColor(context,
                dark: MyntColors.lossDark, light: MyntColors.loss),
            onPressed: hasOpenOrders
                ? () => _showCancelAllDialog(context, openOrders)
                : null,
          ),
        ],
      ),
    );
  }

  /// Get display status text for an order (same logic as _ScalperOrderTableRowState)
  String _getOrderStatusText(OrderBookModel order) {
    if (order.status == null) return 'N/A';
    final status = order.status!.toUpperCase();
    switch (status) {
      case 'OPEN':
        return 'OPEN';
      case 'COMPLETE':
      case 'EXECUTED':
        return 'EXECUTED';
      case 'REJECTED':
        return 'REJECTED';
      case 'CANCELLED':
      case 'CANCELED':
        return 'CANCELLED';
      case 'PENDING':
        return 'PENDING';
      case 'TRIGGER_PENDING':
        return 'TRIGGER PENDING';
      case 'AFTER_MARKET_ORDER_REQ_RECEIVED':
        return 'AMO';
      default:
        return status;
    }
  }

  Widget _buildOrderFilterDropdown(BuildContext context, List<OrderBookModel> allOrders) {
    // Build unique status options from actual orders
    final statusSet = <String>{};
    for (final order in allOrders) {
      statusSet.add(_getOrderStatusText(order));
    }
    final statuses = statusSet.toList()..sort();

    // If current filter no longer exists in available statuses, reset to All
    if (_selectedOrderFilter != 'All' && !statuses.contains(_selectedOrderFilter)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedOrderFilter = 'All');
      });
    }

    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final isFiltered = _selectedOrderFilter != 'All';

    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedOrderFilter = value),
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: resolveThemeColor(context,
          dark: MyntColors.backgroundColorDark, light: MyntColors.backgroundColor),
      itemBuilder: (context) {
        return [
          _buildFilterMenuItem(context, 'All', allOrders.length),
          ...statuses.map((status) {
            final count = allOrders.where((o) => _getOrderStatusText(o) == status).length;
            return _buildFilterMenuItem(context, status, count);
          }),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isFiltered
              ? resolveThemeColor(context,
                  dark: MyntColors.primaryDark, light: MyntColors.primary)
                  .withValues(alpha: 0.08)
              : null,
          border: Border.all(
            color: isFiltered
                ? resolveThemeColor(context,
                    dark: MyntColors.primaryDark, light: MyntColors.primary)
                : resolveThemeColor(context,
                    dark: MyntColors.dividerDark, light: MyntColors.divider),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 14,
              color: isFiltered
                  ? resolveThemeColor(context,
                      dark: MyntColors.primaryDark, light: MyntColors.primary)
                  : secondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              _selectedOrderFilter,
              style: MyntWebTextStyles.caption(
                context,
                fontWeight: MyntFonts.medium,
                color: isFiltered
                    ? resolveThemeColor(context,
                        dark: MyntColors.primaryDark, light: MyntColors.primary)
                    : primaryColor,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isFiltered
                  ? resolveThemeColor(context,
                      dark: MyntColors.primaryDark, light: MyntColors.primary)
                  : secondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(
      BuildContext context, String label, int count) {
    final isSelected = _selectedOrderFilter == label;
    return PopupMenuItem<String>(
      value: label,
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: MyntWebTextStyles.para(
                context,
                fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                color: isSelected
                    ? resolveThemeColor(context,
                        dark: MyntColors.primaryDark, light: MyntColors.primary)
                    : resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.dividerDark, light: MyntColors.divider)
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: MyntWebTextStyles.caption(
                context,
                fontWeight: MyntFonts.medium,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isEnabled,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final disabledColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final effectiveColor = isEnabled ? color : disabledColor;
    final borderColor = isEnabled
        ? color
        : resolveThemeColor(context,
            dark: MyntColors.dividerDark, light: MyntColors.divider);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: effectiveColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: MyntWebTextStyles.caption(
                context,
                fontWeight: MyntFonts.medium,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsList(
      BuildContext context, List<PositionBookModel> positions) {
    if (positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no open Positions',
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Table header
        _buildPositionsTableHeader(context),
        // Table rows
        Expanded(
          child: ListView.builder(
            itemCount: positions.length,
            itemBuilder: (context, index) {
              return _ScalperPositionTableRow(position: positions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPositionsTableHeader(BuildContext context) {
    final headerStyle = MyntWebTextStyles.caption(
      context,
      fontWeight: MyntFonts.semiBold,
      color: resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 28), // Expand chevron column
          Expanded(flex: 2, child: Text('Product', style: headerStyle)),
          Expanded(flex: 3, child: Text('Instrument', style: headerStyle)),
          Expanded(child: Text('Qty', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('Act Avg', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('LTP', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('Stoploss', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('Target', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('P&L', style: headerStyle, textAlign: TextAlign.right)),
          const SizedBox(width: 40), // Space for close button
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderProvider).allOrder ?? [];

    // Apply status filter
    final orders = _selectedOrderFilter == 'All'
        ? allOrders
        : allOrders.where((o) => _getOrderStatusText(o) == _selectedOrderFilter).toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 48,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No orders',
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildOrdersTableHeader(context),
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _ScalperOrderTableRow(order: orders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTableHeader(BuildContext context) {
    final headerStyle = MyntWebTextStyles.caption(
      context,
      fontWeight: MyntFonts.semiBold,
      color: resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Time', style: headerStyle)),
          Expanded(child: Text('Type', style: headerStyle)),
          Expanded(flex: 2, child: Text('Instrument', style: headerStyle)),
          Expanded(child: Text('Product', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('Qty', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('LTP', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('Price', style: headerStyle, textAlign: TextAlign.right)),
          Expanded(child: Text('Status', style: headerStyle, textAlign: TextAlign.right)),
          const SizedBox(width: 40), // Space for cancel button
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, PortfolioProvider portfolio) {
    // Calculate total P&L from all positions using profitNloss (matches main page)
    final allPositions = portfolio.allPostionList;
    double totalPnl = 0;
    for (final pos in allPositions) {
      totalPnl += double.tryParse(pos.profitNloss ?? '0') ?? 0;
    }

    final pnlColor = totalPnl > 0
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : totalPnl < 0
            ? resolveThemeColor(context,
                dark: MyntColors.lossDark, light: MyntColors.loss)
            : resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          // Match column layout from table header
          const SizedBox(width: 28), // Chevron column
          const Expanded(flex: 2, child: SizedBox()), // Product
          const Expanded(flex: 3, child: SizedBox()), // Instrument
          const Expanded(child: SizedBox()), // Qty
          const Expanded(child: SizedBox()), // Act Avg
          Expanded(
            child: Text(
              'Total',
              style: MyntWebTextStyles.para(
                context,
                fontWeight: MyntFonts.semiBold,
                color: resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const Expanded(child: SizedBox()), // SL
          const Expanded(child: SizedBox()), // Target
          Expanded(
            child: Text(
              totalPnl.toStringAsFixed(2),
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.semiBold,
                color: pnlColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 40), // Match close button column
        ],
      ),
    );
  }

  void _showCloseAllDialog(BuildContext context, List<PositionBookModel> openPositions) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ScalperExitPositionDialog(
        positions: openPositions,
        isExitAll: true,
      ),
    );
  }

  void _showCancelAllDialog(BuildContext context, List<OrderBookModel> openOrders) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ScalperCancelOrdersDialog(
        orders: openOrders,
        isCancelAll: true,
      ),
    );
  }
}

/// Table row for positions - matches main positions page layout and calculations
class _ScalperPositionTableRow extends ConsumerStatefulWidget {
  final PositionBookModel position;

  const _ScalperPositionTableRow({required this.position});

  @override
  ConsumerState<_ScalperPositionTableRow> createState() =>
      _ScalperPositionTableRowState();
}

class _ScalperPositionTableRowState
    extends ConsumerState<_ScalperPositionTableRow> {
  bool _isHovered = false;

  /// Format position quantity - for MCX, divide by lot size (matches main page)
  String _formatPositionQty(PositionBookModel position) {
    final rawQty = int.tryParse(position.netqty?.toString() ?? '0') ?? 0;
    final lotSize = position.exch == 'MCX'
        ? (int.tryParse(position.ls?.toString() ?? '1') ?? 1)
        : 1;
    final qty = rawQty ~/ lotSize;
    return qty > 0 ? '+$qty' : '$qty';
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final product = position.sPrdtAli ?? 'N/A';
    final formattedQty = _formatPositionQty(position);
    final actAvg = position.avgPrc ?? '0.00';
    final ltp = position.lp ?? '0.00';
    final pnlValue = position.profitNloss ?? '0.00';
    final pnl = double.tryParse(pnlValue) ?? 0;
    final isClosed = (int.tryParse(position.qty ?? '0') ?? 0) == 0;

    final qtyNum = int.tryParse(formattedQty.replaceAll('+', '')) ?? 0;

    final textColor = isClosed
        ? resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary)
        : resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);

    final qtyColor = isClosed
        ? textColor
        : qtyNum > 0
            ? resolveThemeColor(context,
                dark: MyntColors.profitDark, light: MyntColors.profit)
            : qtyNum < 0
                ? resolveThemeColor(context,
                    dark: MyntColors.lossDark, light: MyntColors.loss)
                : resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);

    final pnlColor = pnl > 0
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : pnl < 0
            ? resolveThemeColor(context,
                dark: MyntColors.lossDark, light: MyntColors.loss)
            : resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);

    final textStyle = MyntWebTextStyles.para(
      context,
      fontWeight: MyntFonts.medium,
      color: textColor,
    );

    final instrumentText = (position.dname != null && position.dname!.isNotEmpty)
        ? position.dname!.replaceAll("-EQ", "").trim()
        : (position.tsym ?? '').replaceAll("-EQ", "").trim();

    final showExchange = position.exch != null &&
        position.exch!.isNotEmpty &&
        (position.expDate == null || position.expDate!.isEmpty);

    // Can exit: not closed, not BO/CO
    final canExit = !isClosed &&
        position.qty != "0" &&
        position.sPrdtAli != "BO" &&
        position.sPrdtAli != "CO";

    final scalper = ref.watch(scalperProvider);
    final netqty = int.tryParse(position.netqty?.toString() ?? '0') ?? 0;
    final isOpen = !isClosed && netqty != 0;
    final isExpanded = isOpen && scalper.expandedPositionTokens.contains(position.token);
    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);

    // GTT data for this position
    final slPrice = isOpen && position.token != null
        ? scalper.getPositionStoploss(position.token!, netqty)
        : null;
    final targetPrice = isOpen && position.token != null
        ? scalper.getPositionTarget(position.token!, netqty)
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isClosed
                  ? resolveThemeColor(context,
                      dark: MyntColors.textPrimary.withValues(alpha: 0.05),
                      light: const Color(0x8F121212).withValues(alpha: 0.03))
                  : null,
              border: Border(
                bottom: isExpanded ? BorderSide.none : BorderSide(
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.dividerDark,
                    light: MyntColors.divider,
                  ),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Expand chevron
                SizedBox(
                  width: 28,
                  child: isOpen
                      ? InkWell(
                          onTap: () => ref.read(scalperProvider).toggleExpandPosition(position.token!),
                          borderRadius: BorderRadius.circular(4),
                          child: Icon(
                            isExpanded ? Icons.expand_more : Icons.chevron_right,
                            size: 18,
                            color: secondaryColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // Product
                Expanded(
                  flex: 2,
                  child: Text(
                    product,
                    style: MyntWebTextStyles.para(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary),
                    ),
                  ),
                ),
                // Instrument
                Expanded(
                  flex: 3,
                  child: Tooltip(
                    message: '$instrumentText${showExchange ? ' ${position.exch}' : ''}',
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(
                        children: [
                          TextSpan(text: instrumentText, style: textStyle),
                          if (showExchange)
                            TextSpan(
                              text: ' ${position.exch}',
                              style: MyntWebTextStyles.caption(
                                context,
                                color: resolveThemeColor(context,
                                    dark: MyntColors.textSecondaryDark,
                                    light: MyntColors.textSecondary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Qty
                Expanded(
                  child: Text(
                    formattedQty,
                    style: MyntWebTextStyles.para(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: qtyColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                // Act Avg
                Expanded(
                  child: Text(
                    actAvg,
                    style: textStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                // LTP
                Expanded(
                  child: Text(
                    ltp,
                    style: textStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                // Stoploss
                Expanded(
                  child: isOpen
                      ? _buildGttCell(context, slPrice, 'stoploss', position, secondaryColor, textStyle)
                      : Text('-', style: textStyle, textAlign: TextAlign.right),
                ),
                // Target
                Expanded(
                  child: isOpen
                      ? _buildGttCell(context, targetPrice, 'target', position, secondaryColor, textStyle)
                      : Text('-', style: textStyle, textAlign: TextAlign.right),
                ),
                // P&L
                Expanded(
                  child: Text(
                    pnlValue,
                    style: MyntWebTextStyles.para(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: pnlColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                // Close button (shown on hover for open positions)
                SizedBox(
                  width: 40,
                  child: (_isHovered && canExit)
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Tooltip(
                            message: 'Exit Position',
                            child: InkWell(
                              onTap: () => _showExitPositionDialog(context, position),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.lossDark, light: MyntColors.loss)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.lossDark, light: MyntColors.loss),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // Expanded GTT sub-row
          if (isExpanded)
            _buildExpandedGttRow(context, position, netqty, scalper, secondaryColor),
        ],
      ),
    );
  }

  /// Build a SL or Target cell with price, percentage, and edit icon
  Widget _buildGttCell(
    BuildContext context,
    String? price,
    String gttType,
    PositionBookModel position,
    Color secondaryColor,
    TextStyle textStyle,
  ) {
    final hasPrice = price != null && price.isNotEmpty;
    // Calculate percentage from avg price
    String? pctText;
    if (hasPrice) {
      final triggerVal = double.tryParse(price) ?? 0;
      final avgVal = double.tryParse(position.avgPrc ?? '0') ?? 0;
      if (avgVal > 0 && triggerVal > 0) {
        final pct = ((triggerVal - avgVal) / avgVal * 100).abs();
        pctText = '${pct.round()}%';
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasPrice)
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: textStyle,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
                if (pctText != null)
                  Text(
                    pctText,
                    style: MyntWebTextStyles.caption(
                      context,
                      color: secondaryColor.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.right,
                  ),
              ],
            ),
          ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _showGttDialog(context, position, gttType),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.edit,
              size: 14,
              color: secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Build the expanded GTT details row
  Widget _buildExpandedGttRow(
    BuildContext context,
    PositionBookModel position,
    int netqty,
    ScalperProvider scalper,
    Color secondaryColor,
  ) {
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);
    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final gttOrders = scalper.getPositionGttOrders(position.token!);
    final slGtt = scalper.getGttByType(position.token!, 'SL', netqty);
    final targetGtt = scalper.getGttByType(position.token!, 'Target', netqty);
    final hasAny = slGtt != null || targetGtt != null;

    return Container(
      padding: const EdgeInsets.only(left: 44, right: 16, top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: resolveThemeColor(context,
            dark: MyntColors.searchBgDark, light: MyntColors.searchBg),
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: hasAny
          ? Row(
              children: [
                // SL segment
                if (slGtt != null) ...[
                  _buildGttSegment(context, 'SL', slGtt, scalper, textColor, secondaryColor),
                  if (targetGtt != null) const SizedBox(width: 24),
                ],
                // Target segment
                if (targetGtt != null)
                  _buildGttSegment(context, 'Target', targetGtt, scalper, textColor, secondaryColor),
                const Spacer(),
                // Qty label
                Text(
                  'Qty: ${gttOrders.isNotEmpty ? gttOrders.first.qty : ""}',
                  style: MyntWebTextStyles.caption(context, color: secondaryColor),
                ),
              ],
            )
          : Text(
              'No active GTT orders',
              style: MyntWebTextStyles.caption(context, color: secondaryColor),
            ),
    );
  }

  /// Build a single SL or Target segment in the expanded row
  Widget _buildGttSegment(
    BuildContext context,
    String label,
    GttOrderBookModel gtt,
    ScalperProvider scalper,
    Color textColor,
    Color secondaryColor,
  ) {
    final dividerColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);
    final lossColor = resolveThemeColor(context,
        dark: MyntColors.lossDark, light: MyntColors.loss);
    final price = gtt.d ?? '0.00';
    final tickSize = double.tryParse(gtt.ti ?? '') ?? 0.05;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: MyntWebTextStyles.caption(
            context,
            fontWeight: MyntFonts.semiBold,
            color: label == 'SL' ? lossColor : resolveThemeColor(context,
                dark: MyntColors.profitDark, light: MyntColors.profit),
          ),
        ),
        const SizedBox(width: 8),
        // Minus button
        _buildGttModifyBtn(
          context,
          icon: Icons.remove,
          onTap: () => scalper.modifyGttPrice(gtt, -tickSize, context),
          dividerColor: dividerColor,
          textColor: textColor,
        ),
        // Price display
        Container(
          constraints: const BoxConstraints(minWidth: 60),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: dividerColor, width: 0.5),
          ),
          child: Text(
            price,
            textAlign: TextAlign.center,
            style: MyntWebTextStyles.para(
              context,
              fontWeight: MyntFonts.semiBold,
              color: textColor,
            ),
          ),
        ),
        // Plus button
        _buildGttModifyBtn(
          context,
          icon: Icons.add,
          onTap: () => scalper.modifyGttPrice(gtt, tickSize, context),
          dividerColor: dividerColor,
          textColor: textColor,
        ),
        const SizedBox(width: 6),
        // Cancel button
        InkWell(
          onTap: () async {
            await ref.read(scalperProvider).cancelGttOrderSilent(gtt.alId!, context);
            await ref.read(scalperProvider).fetchGttOrders(context);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: lossColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.close, size: 12, color: lossColor),
          ),
        ),
      ],
    );
  }

  /// Small +/- button for GTT price modification
  Widget _buildGttModifyBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required Color dividerColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor, width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12, color: textColor),
      ),
    );
  }

  void _showGttDialog(BuildContext context, PositionBookModel position, String gttType) {
    final scalper = ref.read(scalperProvider);
    final netqty = int.tryParse(position.netqty?.toString() ?? '0') ?? 0;
    final existingGtt = scalper.getGttByType(position.token!, gttType == 'stoploss' ? 'SL' : 'Target', netqty);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ScalperGttDialog(
        position: position,
        gttType: gttType,
        existingGtt: existingGtt,
      ),
    );
  }

  void _showExitPositionDialog(BuildContext context, PositionBookModel position) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ScalperExitPositionDialog(positions: [position], isExitAll: false),
    );
  }
}

/// Table row for orders - matches main orders page layout exactly
/// Columns: Time, Type, Instrument, Product, Qty, LTP, Price, Status, Cancel
class _ScalperOrderTableRow extends StatefulWidget {
  final OrderBookModel order;

  const _ScalperOrderTableRow({required this.order});

  @override
  State<_ScalperOrderTableRow> createState() => _ScalperOrderTableRowState();
}

class _ScalperOrderTableRowState extends State<_ScalperOrderTableRow> {
  bool _isHovered = false;

  OrderBookModel get order => widget.order;

  /// Format order qty with MCX lot size handling (matches main page)
  String _formatOrderQty(OrderBookModel order) {
    final rawFilled = int.tryParse(order.fillshares ?? '0') ?? 0;
    final rawQty = int.tryParse(order.qty ?? '0') ?? 0;
    final lotSize = order.exch == 'MCX'
        ? (int.tryParse(order.ls ?? '1') ?? 1)
        : 1;
    final filledQty = rawFilled ~/ lotSize;
    final totalQty = rawQty ~/ lotSize;
    return '$filledQty / $totalQty';
  }

  /// Get valid price - show "MKT" for market orders (matches main page)
  String _getValidPrice(OrderBookModel order) {
    if (order.prctyp == 'MKT' || order.prctyp == 'MARKET') {
      return 'MKT';
    }
    if (order.prc != null && order.prc != '0' && order.prc != '0.00') {
      return order.prc!;
    }
    return '0.00';
  }

  /// Get status display text (matches main page CellFormatters.getStatusText)
  String _getStatusText(OrderBookModel order) {
    if (order.status == null) return 'N/A';
    final status = order.status!.toUpperCase();
    switch (status) {
      case 'OPEN':
        return 'OPEN';
      case 'COMPLETE':
      case 'EXECUTED':
        return 'EXECUTED';
      case 'REJECTED':
        return 'REJECTED';
      case 'CANCELLED':
      case 'CANCELED':
        return 'CANCELLED';
      case 'PENDING':
        return 'PENDING';
      case 'TRIGGER_PENDING':
        return 'TRIGGER PENDING';
      case 'AFTER_MARKET_ORDER_REQ_RECEIVED':
        return 'AMO';
      default:
        return status;
    }
  }

  /// Get status color (matches main page exactly)
  Color _getStatusColor(BuildContext context, String statusText) {
    final upper = statusText.toUpperCase();
    if (upper.contains('COMPLETE') || upper.contains('EXECUTED') || upper.contains('FILLED')) {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (upper.contains('REJECT') || upper.contains('CANCEL')) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else if (upper.contains('PENDING') || upper.contains('OPEN') || upper.contains('AMO')) {
      return MyntColors.warning;
    }
    return resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
  }

  /// Get initial LTP value - fallback to close price if ltp is null/0 (matches main page)
  String _getValidLTP(OrderBookModel order) {
    if (order.ltp != null &&
        order.ltp.toString() != 'null' &&
        order.ltp.toString().isNotEmpty &&
        order.ltp.toString() != '0' &&
        order.ltp.toString() != '0.00') {
      return order.ltp.toString();
    }
    if (order.c != null && order.c.toString() != 'null') {
      final closePrice = double.tryParse(order.c.toString());
      if (closePrice != null) return closePrice.toString();
    }
    return '0.00';
  }

  String _formatTime(String norentm) {
    if (norentm.isEmpty) return '--';
    final parts = norentm.split(' ');
    if (parts.isNotEmpty) {
      final timePart = parts[0];
      final timeParts = timePart.split(':');
      if (timeParts.length >= 2) {
        return '${timeParts[0]}:${timeParts[1]}';
      }
      return timePart;
    }
    return norentm;
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = order.trantype == 'B';
    final statusText = _getStatusText(order);
    final statusColor = _getStatusColor(context, statusText);
    final product = order.sPrdtAli ?? order.prd ?? '';
    final time = _formatTime(order.norentm ?? '');

    final typeColor = isBuy
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);

    final textColor = resolveThemeColor(
      context,
      dark: MyntColors.textPrimaryDark,
      light: MyntColors.textPrimary,
    );

    final textStyle = MyntWebTextStyles.para(
      context,
      fontWeight: MyntFonts.medium,
      color: textColor,
    );

    // Instrument display - use dname if available, otherwise tsym
    final instrumentText = (order.dname != null && order.dname!.isNotEmpty)
        ? order.dname!.replaceAll('-EQ', '').trim()
        : (order.tsym ?? '').replaceAll('-EQ', '').trim();

    // Check if order is open (cancellable)
    final isOpen = statusText == 'OPEN' ||
        statusText == 'PENDING' ||
        statusText == 'TRIGGER PENDING' ||
        statusText == 'AMO';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: resolveThemeColor(
                context,
                dark: MyntColors.dividerDark,
                light: MyntColors.divider,
              ),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Time
            Expanded(
              child: Text(
                time,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Type (BUY/SELL) - colored text like main page
            Expanded(
              child: Text(
                isBuy ? 'BUY' : 'SELL',
                style: MyntWebTextStyles.para(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: typeColor,
                ),
              ),
            ),
            // Instrument
            Expanded(
              flex: 2,
              child: Tooltip(
                message: '$instrumentText${order.exch != null ? ' ${order.exch}' : ''}',
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(text: instrumentText, style: textStyle),
                      if (order.exch != null && order.exch!.isNotEmpty)
                        TextSpan(
                          text: ' ${order.exch}',
                          style: MyntWebTextStyles.caption(
                            context,
                            color: resolveThemeColor(context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Product
            Expanded(
              child: Text(
                product,
                style: textStyle,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Qty (filledQty / totalQty with MCX lot size)
            Expanded(
              child: Text(
                _formatOrderQty(order),
                style: textStyle,
                textAlign: TextAlign.right,
              ),
            ),
            // LTP - live from WebSocket (matches main page pattern)
            Expanded(
              child: _ScalperOrderLTPCell(
                token: order.token ?? '',
                initialLtp: _getValidLTP(order),
              ),
            ),
            // Price (shows "MKT" for market orders)
            Expanded(
              child: Text(
                _getValidPrice(order),
                style: textStyle,
                textAlign: TextAlign.right,
              ),
            ),
            // Status - colored badge with background (matches main page)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Tooltip(
                  message: statusText == 'REJECTED'
                      ? (order.rejreason ?? 'Unknown reason')
                      : '',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: MyntWebTextStyles.para(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Cancel button (shown on hover for open orders)
            SizedBox(
              width: 40,
              child: (_isHovered && isOpen)
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: 'Cancel Order',
                        child: InkWell(
                          onTap: () => _showCancelOrderDialog(context, order),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: resolveThemeColor(context,
                                  dark: MyntColors.lossDark, light: MyntColors.loss)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: resolveThemeColor(context,
                                  dark: MyntColors.lossDark, light: MyntColors.loss),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context, OrderBookModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ScalperCancelOrdersDialog(
        orders: [order],
        isCancelAll: false,
      ),
    );
  }
}

/// Live LTP cell for orders - subscribes to WebSocket stream
/// Matches the _OrderLTPCell pattern from the main orders page
class _ScalperOrderLTPCell extends ConsumerStatefulWidget {
  final String token;
  final String initialLtp;

  const _ScalperOrderLTPCell({
    required this.token,
    required this.initialLtp,
  });

  @override
  ConsumerState<_ScalperOrderLTPCell> createState() =>
      _ScalperOrderLTPCellState();
}

class _ScalperOrderLTPCellState extends ConsumerState<_ScalperOrderLTPCell> {
  late String ltp;
  StreamSubscription? _subscription;
  bool _didSetupSubscription = false;

  @override
  void initState() {
    super.initState();
    ltp = widget.initialLtp;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didSetupSubscription && widget.token.isNotEmpty) {
      _didSetupSubscription = true;

      // Check existing socket data first (tokens may already be subscribed)
      final existingData = ref.read(websocketProvider).socketDatas;
      if (existingData.containsKey(widget.token)) {
        final existingLtp = existingData[widget.token]['lp']?.toString();
        if (existingLtp != null &&
            existingLtp != '0.00' &&
            existingLtp != 'null' &&
            existingLtp != '0') {
          ltp = existingLtp;
        }
      }

      // Subscribe for future updates
      Future.microtask(() {
        if (!mounted) return;

        _subscription =
            ref.read(websocketProvider).socketDataStream.listen((data) {
          if (!mounted || !data.containsKey(widget.token)) return;

          final newLtp = data[widget.token]['lp']?.toString();
          if (newLtp != null &&
              newLtp != ltp &&
              newLtp != '0.00' &&
              newLtp != 'null') {
            setState(() => ltp = newLtp);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      ltp,
      style: MyntWebTextStyles.para(
        context,
        fontWeight: MyntFonts.medium,
        color: resolveThemeColor(
          context,
          dark: MyntColors.textPrimaryDark,
          light: MyntColors.textPrimary,
        ),
      ),
      textAlign: TextAlign.right,
    );
  }
}

/// GTT dialog for setting / editing Stoploss or Target trigger price
class _ScalperGttDialog extends ConsumerStatefulWidget {
  final PositionBookModel position;
  final String gttType; // 'stoploss' or 'target'
  final GttOrderBookModel? existingGtt;

  const _ScalperGttDialog({
    required this.position,
    required this.gttType,
    this.existingGtt,
  });

  @override
  ConsumerState<_ScalperGttDialog> createState() => _ScalperGttDialogState();
}

class _ScalperGttDialogState extends ConsumerState<_ScalperGttDialog> {
  final _triggerController = TextEditingController();
  final _percentageController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _isSyncing = false; // prevents infinite listener loops

  bool get _isEditing => widget.existingGtt != null;
  bool get _isStoploss => widget.gttType == 'stoploss';

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _triggerController.text = widget.existingGtt!.d ?? '';
      // Back-calculate percentage from existing trigger price
      _syncPercentageFromTrigger();
    }
    _percentageController.addListener(_onPercentageChanged);
    _triggerController.addListener(_onTriggerChanged);
  }

  @override
  void dispose() {
    _percentageController.removeListener(_onPercentageChanged);
    _triggerController.removeListener(_onTriggerChanged);
    _percentageController.dispose();
    _triggerController.dispose();
    super.dispose();
  }

  /// Tick size from position data (defaults to 0.05 for options)
  double get _tickSize {
    final ti = double.tryParse(widget.position.ti ?? '');
    return (ti != null && ti > 0) ? ti : 0.05;
  }

  double get _avgPrice =>
      double.tryParse(widget.position.avgPrc ?? '0') ?? 0;

  /// Round a price to the nearest tick
  double _roundToTick(double price) {
    final tick = _tickSize;
    return (price / tick).round() * tick;
  }

  /// Percentage → Trigger: calculate trigger price from avg + percentage
  void _onPercentageChanged() {
    if (_isSyncing) return;
    final pctText = _percentageController.text.trim();
    if (pctText.isEmpty) {
      _isSyncing = true;
      _triggerController.text = '';
      _isSyncing = false;
      return;
    }
    final pct = int.tryParse(pctText);
    if (pct == null || pct <= 0) return;
    if (_avgPrice <= 0) return;

    final netqty = int.tryParse(widget.position.netqty?.toString() ?? '0') ?? 0;
    final isLong = netqty > 0;

    // SL: below avg for long, above avg for short
    // Target: above avg for long, below avg for short
    final goesUp = _isStoploss ? !isLong : isLong;
    final rawPrice = goesUp
        ? _avgPrice * (1 + pct / 100)
        : _avgPrice * (1 - pct / 100);

    final rounded = _roundToTick(rawPrice);
    _isSyncing = true;
    _triggerController.text = rounded.toStringAsFixed(2);
    _isSyncing = false;
  }

  /// Trigger → Percentage: back-calculate percentage from trigger price
  void _onTriggerChanged() {
    if (_isSyncing) return;
    _syncPercentageFromTrigger();
  }

  void _syncPercentageFromTrigger() {
    final triggerText = _triggerController.text.trim();
    if (triggerText.isEmpty || _avgPrice <= 0) {
      _isSyncing = true;
      _percentageController.text = '';
      _isSyncing = false;
      return;
    }
    final triggerVal = double.tryParse(triggerText);
    if (triggerVal == null || triggerVal <= 0) return;

    final pct = ((triggerVal - _avgPrice) / _avgPrice * 100).abs();
    final rounded = pct.round();
    if (rounded <= 0) {
      _isSyncing = true;
      _percentageController.text = '';
      _isSyncing = false;
      return;
    }
    _isSyncing = true;
    _percentageController.text = rounded.toString();
    _isSyncing = false;
  }

  /// Arrow ↑/↓ on trigger field: adjust by tick size
  void _adjustTrigger(int direction) {
    final current = double.tryParse(_triggerController.text.trim()) ?? 0;
    final newPrice = _roundToTick(current + direction * _tickSize);
    if (newPrice <= 0) return;
    _triggerController.text = newPrice.toStringAsFixed(2);
  }

  /// Arrow ↑/↓ on percentage field: adjust by 1
  void _adjustPercentage(int direction) {
    final current = int.tryParse(_percentageController.text.trim()) ?? 0;
    final newPct = current + direction;
    if (newPct < 0) return;
    _percentageController.text = newPct.toString();
  }

  Future<void> _handleSubmit() async {
    final triggerPrice = _triggerController.text.trim();
    if (triggerPrice.isEmpty) {
      setState(() => _errorText = 'Enter a trigger price');
      return;
    }
    final price = double.tryParse(triggerPrice);
    if (price == null || price <= 0) {
      setState(() => _errorText = 'Enter a valid price');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final position = widget.position;
      final netqty = int.tryParse(position.netqty?.toString() ?? '0') ?? 0;
      final isLong = netqty > 0;
      final absQty = netqty.abs();

      // Determine alert type based on SL/Target and position direction
      String ait;
      if (_isStoploss) {
        ait = isLong ? 'LTP_B_O' : 'LTP_A_O';
      } else {
        ait = isLong ? 'LTP_A_O' : 'LTP_B_O';
      }

      final trantype = isLong ? 'S' : 'B';

      final input = PlaceGTTOrderInput(
        tsym: position.tsym ?? '',
        exch: position.exch ?? '',
        ait: ait,
        validity: 'GTT',
        d: triggerPrice,
        remarks: '',
        trantype: trantype,
        prctyp: 'MKT',
        prd: position.prd ?? 'I',
        ret: 'DAY',
        qty: absQty.toString(),
        prc: '0',
        alid: widget.existingGtt?.alId ?? '',
        trgprc: '0',
      );

      final orderProv = ref.read(orderProvider);
      if (_isEditing) {
        await orderProv.modifyGTTOrder(input, context);
      } else {
        await orderProv.placeGTTOrder(input, context);
      }

      // Refresh GTT orders in scalper provider
      if (mounted) {
        await ref.read(scalperProvider).fetchGttOrders(context);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('_ScalperGttDialog: submit error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = 'Failed to ${_isEditing ? 'modify' : 'place'} GTT order';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final instrumentName = (position.dname ?? position.tsym ?? '')
        .replaceAll('-EQ', '')
        .trim();
    final netqty = int.tryParse(position.netqty?.toString() ?? '0') ?? 0;
    final absQty = netqty.abs();
    final isLong = netqty > 0;

    // Get real-time LTP from websocket
    final socketData = position.token != null
        ? ref.watch(websocketProvider).socketDatas[position.token]
        : null;
    final ltp = socketData?['lp']?.toString() ?? position.lp ?? '0.00';

    final title = _isEditing
        ? 'Edit ${_isStoploss ? 'Stoploss' : 'Target'}'
        : 'Set ${_isStoploss ? 'Stoploss' : 'Target'}';

    final hintText = _isStoploss
        ? (isLong
            ? 'Triggers sell when LTP falls below this price'
            : 'Triggers buy when LTP rises above this price')
        : (isLong
            ? 'Triggers sell when LTP rises above this price'
            : 'Triggers buy when LTP falls below this price');

    final textColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final secondaryColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.dividerDark, light: MyntColors.divider);
    final accentColor = _isStoploss
        ? resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss)
        : resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);

    return PointerInterceptor(
      child: Center(
        child: shadcn.Card(
          borderRadius: BorderRadius.circular(8),
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: MyntWebTextStyles.title(
                          context,
                          color: textColor,
                        ),
                      ),
                      MyntCloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symbol info row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  instrumentName,
                                  style: MyntWebTextStyles.body(
                                    context,
                                    fontWeight: MyntFonts.semiBold,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Qty: $absQty',
                                      style: MyntWebTextStyles.caption(
                                        context,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'LTP: $ltp',
                                      style: MyntWebTextStyles.caption(
                                        context,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isLong
                                            ? resolveThemeColor(context,
                                                    dark: MyntColors.profitDark,
                                                    light: MyntColors.profit)
                                                .withValues(alpha: 0.15)
                                            : resolveThemeColor(context,
                                                    dark: MyntColors.lossDark,
                                                    light: MyntColors.loss)
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isLong ? 'LONG' : 'SHORT',
                                        style: MyntWebTextStyles.caption(
                                          context,
                                          fontWeight: MyntFonts.semiBold,
                                          color: isLong
                                              ? resolveThemeColor(context,
                                                  dark: MyntColors.profitDark,
                                                  light: MyntColors.profit)
                                              : resolveThemeColor(context,
                                                  dark: MyntColors.lossDark,
                                                  light: MyntColors.loss),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Trigger price + Percentage row (bidirectional)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trigger price input
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trigger Price',
                                  style: MyntWebTextStyles.bodySmall(
                                    context,
                                    fontWeight: MyntFonts.medium,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Focus(
                                  onKeyEvent: (node, event) {
                                    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                                      return KeyEventResult.ignored;
                                    }
                                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                      _adjustTrigger(1);
                                      return KeyEventResult.handled;
                                    }
                                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                      _adjustTrigger(-1);
                                      return KeyEventResult.handled;
                                    }
                                    return KeyEventResult.ignored;
                                  },
                                  child: TextField(
                                    controller: _triggerController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    autofocus: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                    ],
                                    style: MyntWebTextStyles.body(
                                      context,
                                      fontWeight: MyntFonts.medium,
                                      color: textColor,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter trigger price',
                                      hintStyle: MyntWebTextStyles.body(
                                        context,
                                        color: secondaryColor.withValues(alpha: 0.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: accentColor, width: 1.5),
                                      ),
                                      errorText: _errorText,
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _handleSubmit(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Percentage input
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '% of Avg (${position.avgPrc ?? "0.00"})',
                                  style: MyntWebTextStyles.bodySmall(
                                    context,
                                    fontWeight: MyntFonts.medium,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Focus(
                                  onKeyEvent: (node, event) {
                                    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                                      return KeyEventResult.ignored;
                                    }
                                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                      _adjustPercentage(1);
                                      return KeyEventResult.handled;
                                    }
                                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                      _adjustPercentage(-1);
                                      return KeyEventResult.handled;
                                    }
                                    return KeyEventResult.ignored;
                                  },
                                  child: TextField(
                                    controller: _percentageController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: MyntWebTextStyles.body(
                                      context,
                                      fontWeight: MyntFonts.medium,
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '%',
                                      hintStyle: MyntWebTextStyles.body(
                                        context,
                                        color: secondaryColor.withValues(alpha: 0.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: accentColor, width: 1.5),
                                      ),
                                      isDense: true,
                                      suffixText: '%',
                                      suffixStyle: MyntWebTextStyles.caption(
                                        context,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    onSubmitted: (_) => _handleSubmit(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tick: $_tickSize — price rounded to nearest tick',
                        style: MyntWebTextStyles.caption(
                          context,
                          color: secondaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hint text
                      Text(
                        hintText,
                        style: MyntWebTextStyles.caption(
                          context,
                          color: secondaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Submit button
                      MyntButton(
                        type: MyntButtonType.primary,
                        size: MyntButtonSize.large,
                        label: _isEditing ? 'Update' : 'Submit',
                        isFullWidth: true,
                        isLoading: _isLoading,
                        backgroundColor: accentColor,
                        onPressed: _isLoading ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Exit position dialog - matches ExitAllPositionsDialogWeb design
class _ScalperExitPositionDialog extends ConsumerStatefulWidget {
  final List<PositionBookModel> positions;
  final bool isExitAll;

  const _ScalperExitPositionDialog({
    required this.positions,
    required this.isExitAll,
  });

  @override
  ConsumerState<_ScalperExitPositionDialog> createState() =>
      _ScalperExitPositionDialogState();
}

class _ScalperExitPositionDialogState
    extends ConsumerState<_ScalperExitPositionDialog> {
  bool _isLoading = false;

  Future<void> _handleExit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final positionBook = ref.read(portfolioProvider);
      final scalper = ref.read(scalperProvider);

      if (widget.isExitAll) {
        // Select all and exit (uses provider's built-in exit all)
        positionBook.selectExitAllPosition(true);
        await positionBook.exitPosition(context, true);
      } else {
        // Mark specific positions for exit, then call exitPosition
        // First reset, then select only our positions
        positionBook.resetExitPositionSelection();

        final allPositions = positionBook.allPostionList;
        for (final pos in widget.positions) {
          final idx = allPositions.indexOf(pos);
          if (idx >= 0) {
            positionBook.selectExitPosition(idx);
          }
        }
        await positionBook.exitPosition(context, false);
      }

      // Auto-cancel GTT orders for exited positions
      for (final pos in widget.positions) {
        if (pos.token != null && pos.token!.isNotEmpty) {
          await scalper.cancelAllGttForPosition(pos.token!, context);
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error exiting position: $e');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.positions.length;
    final isSingle = count == 1 && !widget.isExitAll;
    final instrumentName = isSingle
        ? (widget.positions.first.dname ?? widget.positions.first.tsym ?? '')
            .replaceAll('-EQ', '')
            .trim()
        : '';

    // Check if any position has active GTT orders
    final scalper = ref.read(scalperProvider);
    final hasActiveGtt = widget.positions.any((pos) =>
        pos.token != null && scalper.getPositionGttOrders(pos.token!).isNotEmpty);

    return PointerInterceptor(
      child: Center(
        child: shadcn.Card(
          borderRadius: BorderRadius.circular(8),
          padding: EdgeInsets.zero,
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: shadcn.Theme.of(context).colorScheme.border,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isExitAll ? 'Exit All Positions' : 'Exit Position',
                        style: MyntWebTextStyles.title(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                        ),
                      ),
                      MyntCloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isSingle
                              ? 'Are you sure you want to exit $instrumentName?'
                              : 'Are you sure you want to square off all $count open positions?',
                          textAlign: TextAlign.center,
                          style: MyntWebTextStyles.body(
                            context,
                            fontWeight: FontWeight.w500,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary,
                            ),
                          ),
                        ),
                        if (hasActiveGtt) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.isExitAll
                                ? 'Active GTT (SL/Target) orders will also be cancelled.'
                                : 'Active GTT orders for this position will also be cancelled.',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.caption(
                              context,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        MyntButton(
                          type: MyntButtonType.primary,
                          size: MyntButtonSize.large,
                          label: 'Exit Order',
                          isFullWidth: true,
                          isLoading: _isLoading,
                          backgroundColor: resolveThemeColor(
                            context,
                            dark: MyntColors.lossDark,
                            light: MyntColors.loss,
                          ),
                          onPressed: _isLoading ? null : _handleExit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cancel orders dialog - matching exit all positions dialog design
class _ScalperCancelOrdersDialog extends ConsumerStatefulWidget {
  final List<OrderBookModel> orders;
  final bool isCancelAll;

  const _ScalperCancelOrdersDialog({
    required this.orders,
    required this.isCancelAll,
  });

  @override
  ConsumerState<_ScalperCancelOrdersDialog> createState() =>
      _ScalperCancelOrdersDialogState();
}

class _ScalperCancelOrdersDialogState
    extends ConsumerState<_ScalperCancelOrdersDialog> {
  bool _isLoading = false;

  Future<void> _handleCancel() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final orderProv = ref.read(orderProvider);

      for (final order in widget.orders) {
        final orderNo = order.norenordno?.toString() ?? '';
        if (orderNo.isEmpty) continue;

        if ((order.sPrdtAli == 'BO' || order.sPrdtAli == 'CO') &&
            order.snonum != null) {
          await orderProv.fetchExitSNOOrd(
            order.snonum.toString(),
            order.prd.toString(),
            context,
            false,
          );
        } else {
          await orderProv.fetchOrderCancel(orderNo, context, false);
        }
      }

      // Refresh order book
      await orderProv.fetchOrderBook(context, true);

      if (mounted) {
        Navigator.of(context).pop();
        ResponsiveSnackBar.showSuccess(
          context,
          widget.isCancelAll
              ? 'All open orders cancelled'
              : 'Order cancelled',
        );
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.orders.length;
    final isSingle = count == 1 && !widget.isCancelAll;
    final instrumentName = isSingle
        ? (widget.orders.first.dname ?? widget.orders.first.tsym ?? '')
            .replaceAll('-EQ', '')
            .trim()
        : '';

    return PointerInterceptor(
      child: Center(
        child: shadcn.Card(
          borderRadius: BorderRadius.circular(8),
          padding: EdgeInsets.zero,
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: shadcn.Theme.of(context).colorScheme.border,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isCancelAll ? 'Cancel All Orders' : 'Cancel Order',
                        style: MyntWebTextStyles.title(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                        ),
                      ),
                      MyntCloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isSingle
                              ? 'Are you sure you want to cancel the order for $instrumentName?'
                              : 'Are you sure you want to cancel all $count open orders?',
                          textAlign: TextAlign.center,
                          style: MyntWebTextStyles.body(
                            context,
                            fontWeight: FontWeight.w500,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        MyntButton(
                          type: MyntButtonType.primary,
                          size: MyntButtonSize.large,
                          label: widget.isCancelAll ? 'Cancel All' : 'Cancel Order',
                          isFullWidth: true,
                          isLoading: _isLoading,
                          backgroundColor: resolveThemeColor(
                            context,
                            dark: MyntColors.lossDark,
                            light: MyntColors.loss,
                          ),
                          onPressed: _isLoading ? null : _handleCancel,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

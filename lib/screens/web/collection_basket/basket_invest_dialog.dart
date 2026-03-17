import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
import 'package:mynt_plus/provider/dashboard_provider.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:mynt_plus/utils/custom_navigator.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

void showBasketInvestDialog(BuildContext context) {
  final provider =
      ProviderScope.containerOf(context).read(dashboardProvider);
  provider.resetBasketInvest();
  // Pre-fill with minimum amount that satisfies all funds' minimum purchase requirements
  // For each fund: minPurchaseAmount / (weight% / 100) = minimum total needed
  // Take the max across all funds to ensure every fund meets its minimum
  double minTotalInvest = 0;
  for (final fund in provider.selectedFunds) {
    if (fund.percentage > 0) {
      final needed = fund.minimumPurchaseAmount / (fund.percentage / 100);
      if (needed > minTotalInvest) minTotalInvest = needed;
    }
  }
  // Round up to nearest integer
  final defaultAmount = minTotalInvest.ceil();
  provider.basketInvestAmountController.text = '$defaultAmount';
  provider.calculateBasketAllocations(defaultAmount.toDouble());
  provider.enrichFundsByIsins();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Basket Invest',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: const Center(
          child: Material(
            color: Colors.transparent,
            child: _BasketInvestDialogContent(),
          ),
        ),
      );
    },
  );
}

class _BasketInvestDialogContent extends ConsumerStatefulWidget {
  const _BasketInvestDialogContent();

  @override
  ConsumerState<_BasketInvestDialogContent> createState() =>
      _BasketInvestDialogContentState();
}

class _BasketInvestDialogContentState
    extends ConsumerState<_BasketInvestDialogContent> {
  final ScrollController _orderScrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  @override
  void dispose() {
    _orderScrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isOrdering = strategy.isBasketOrdering || strategy.basketOrderCompleted;
    final double dialogWidth = isOrdering
        ? 450.0
        : screenWidth * 0.55 < 620 ? 620.0 : screenWidth * 0.55;

    return shadcn.Card(
      borderRadius: BorderRadius.circular(8),
      padding: EdgeInsets.zero,
      child: Container(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (strategy.isBasketOrdering || strategy.basketOrderCompleted)
              _buildOrderProgress(context, strategy)
            else
              _buildInvestForm(context, strategy),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final strategy = ref.watch(dashboardProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            strategy.isBasketOrdering
                ? 'Placing Orders...'
                : strategy.basketOrderCompleted
                    ? 'Order Summary'
                    : 'Invest in Basket',
            style: MyntWebTextStyles.title(context,
                fontWeight: MyntFonts.semiBold,
                color: resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary)),
          ),
          if (!strategy.isBasketOrdering)
            MyntCloseButton(
              onPressed: () {
                Navigator.pop(context);
                // Delay past the 200ms exit animation so the dialog doesn't
                // rebuild to its empty state while still animating out.
                Future.delayed(const Duration(milliseconds: 300), strategy.resetBasketInvest);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInvestForm(BuildContext context, DashboardProvider strategy) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Investment Amount Field
          Text(
            'Investment Amount',
            style: MyntWebTextStyles.body(context,
                fontWeight: MyntFonts.medium,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: strategy.basketAllocations.isNotEmpty ? 300 : double.infinity),
            child: MyntFormTextField(
            controller: strategy.basketInvestAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            placeholder: 'Enter amount',
            height: 40,
            leadingWidget: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                assets.ruppeIcon,
                colorFilter: ColorFilter.mode(
                  resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
                  BlendMode.srcIn,
                ),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (amount != null && amount > 0) {
                strategy.calculateBasketAllocations(amount);
              } else {
                strategy.calculateBasketAllocations(0);
              }
            },
          ),
          ),

          

          // (Error shown via toast)

          // Fund Allocation Table
          if (strategy.basketAllocations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Fund Allocation',
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary),
                ),
                if (strategy.isFetchingNav) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(MyntColors.primary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Fetching NAV...',
                    style: MyntWebTextStyles.caption(context,
                        fontWeight: MyntFonts.regular,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _buildAllocationTable(context, strategy),
          ],

          const SizedBox(height: 16),

          // Place Order Button
          Align(
            alignment: strategy.basketAllocations.isNotEmpty ? Alignment.centerRight : Alignment.center,
            child: SizedBox(
            width: strategy.basketAllocations.isNotEmpty ? 200 : double.infinity,
            height: 44,
            child: MyntPrimaryButton(
              label: 'Place Order',
              onPressed: () {
                if (strategy.isBasketReadyToOrder) {
                  strategy.placeBasketLumpsumOrders();
                } else if (strategy.basketInvestError != null) {
                  error(context, strategy.basketInvestError!);
                } else if (strategy.basketAllocations.isEmpty) {
                  error(context, 'Please enter an investment amount');
                } else {
                  error(context, 'Please fix allocation errors before placing order');
                }
              },
            ),
          ),
          ),
        ],
      ),
    );
  }

  // Shadcn table cell with no internal borders
  shadcn.TableCell _tableCell(Widget child, {bool alignRight = false, bool alignCenter = false, Color? backgroundColor}) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: backgroundColor,
        alignment: alignRight
            ? Alignment.centerRight
            : alignCenter
                ? Alignment.center
                : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _buildAllocationTable(BuildContext context, DashboardProvider strategy) {
    final headerColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final headerStyle = MyntWebTextStyles.tableHeader(
      context,
      darkColor: headerColor,
      lightColor: headerColor,
      fontWeight: MyntFonts.semiBold,
    );
    final cellStyle = MyntWebTextStyles.tableCell(
      context,
      darkColor: MyntColors.textPrimaryDark,
      lightColor: MyntColors.textPrimary,
      fontWeight: MyntFonts.medium,
    );
    final secondaryStyle = MyntWebTextStyles.tableCell(
      context,
      darkColor: MyntColors.textSecondaryDark,
      lightColor: MyntColors.textSecondary,
      fontWeight: MyntFonts.medium,
    );
    final boldStyle = MyntWebTextStyles.tableCell(
      context,
      darkColor: MyntColors.textPrimaryDark,
      lightColor: MyntColors.textPrimary,
      fontWeight: MyntFonts.bold,
    );

    return shadcn.OutlinedContainer(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          const lockWidth = 28.0;
          const scrollbarWidth = 8.0;
          const bool hideNav = false;
          // Fund(4)+Weight(2)+NAV(2)+Amount(2)+Units(2) = 12 flex
          const double flexTotal = 12.0;
          final flexUnit = (totalWidth - lockWidth - scrollbarWidth) / flexTotal;

          Map<int, shadcn.TableSize> colWidths(bool nav) => nav
              ? {
                  0: shadcn.FixedTableSize(flexUnit * 4),
                  1: shadcn.FixedTableSize(flexUnit * 2),
                  2: shadcn.FixedTableSize(flexUnit * 2),
                  3: shadcn.FixedTableSize(flexUnit * 2),
                  4: shadcn.FixedTableSize(flexUnit * 2),
                  5: shadcn.FixedTableSize(lockWidth + scrollbarWidth),
                }
              : {
                  0: shadcn.FixedTableSize(flexUnit * 5),
                  1: shadcn.FixedTableSize(flexUnit * 2),
                  2: shadcn.FixedTableSize(flexUnit * 2),
                  3: shadcn.FixedTableSize(flexUnit * 2),
                  4: shadcn.FixedTableSize(lockWidth + scrollbarWidth),
                };

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              shadcn.Table(
                columnWidths: colWidths(!hideNav),
                defaultRowHeight: const shadcn.FixedTableSize(42),
                rows: [
                  shadcn.TableHeader(
                    cells: [
                      _tableCell(Text('Fund Name', style: headerStyle)),
                      _tableCell(Text('Weight', style: headerStyle), alignCenter: true),
                      if (!hideNav)
                        _tableCell(Text('NAV', style: headerStyle), alignRight: true),
                      _tableCell(Text('Amount', style: headerStyle), alignRight: true),
                      _tableCell(Text('Units', style: headerStyle), alignRight: true),
                      _tableCell(const SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
              // Scrollable data rows — scrollbar always visible, reserved outside lock col
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                  child: RawScrollbar(
                    controller: _tableScrollController,
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(0),
                    thumbColor: shadcn.Theme.of(context)
                        .colorScheme
                        .mutedForeground
                        .withValues(alpha: 0.5),
                    child: SingleChildScrollView(
                      controller: _tableScrollController,
                      child: shadcn.Table(
                        columnWidths: colWidths(!hideNav),
                        defaultRowHeight: const shadcn.FixedTableSize(50),
                        rows: [
                          for (int index = 0; index < strategy.basketAllocations.length; index++)
                            _buildAllocationTableRow(
                              context, strategy, strategy.basketAllocations[index], index,
                              cellStyle, secondaryStyle, hideNav: hideNav,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Footer / Total row
              Divider(
                height: 1,
                color: shadcn.Theme.of(context).colorScheme.border,
              ),
              shadcn.Table(
                columnWidths: colWidths(!hideNav),
                defaultRowHeight: const shadcn.FixedTableSize(42),
                rows: [
                  shadcn.TableFooter(
                    cells: [
                      _tableCell(Text('Total', style: boldStyle)),
                      _tableCell(
                        Text(
                          '${strategy.totalPercentage.round()}%',
                          style: boldStyle.copyWith(
                            color: strategy.totalPercentage.round() == 100
                                ? null
                                : Colors.red,
                          ),
                        ),
                        alignCenter: true,
                      ),
                      if (!hideNav) _tableCell(const SizedBox.shrink()),
                      _tableCell(
                        Text(
                          '₹${_formatAmount(strategy.basketAllocations.fold(0.0, (sum, a) => sum + a.allocatedAmount))}',
                          style: boldStyle,
                        ),
                        alignRight: true,
                      ),
                      _tableCell(const SizedBox.shrink()),
                      _tableCell(const SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  shadcn.TableRow _buildAllocationTableRow(
    BuildContext context,
    DashboardProvider strategy,
    BasketFundAllocation allocation,
    int index,
    TextStyle cellStyle,
    TextStyle secondaryStyle, {
    bool hideNav = false,
  }) {
    final errorBg = !allocation.isValid
        ? Colors.red.withValues(alpha: 0.06)
        : null;

    return shadcn.TableRow(
      cells: [
        // Fund Name
        _tableCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: allocation.fund.name,
                waitDuration: const Duration(milliseconds: 500),
                child: Text(
                  allocation.fund.name,
                  style: cellStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!allocation.isValid)
                Text(
                  'Min invest amount is ₹${allocation.fund.minimumPurchaseAmount.toStringAsFixed(0)}',
                  style: MyntWebTextStyles.tableCell(
                    context,
                    color: Colors.red,
                    darkColor: Colors.red,
                    lightColor: Colors.red,
                    fontWeight: MyntFonts.medium,
                  ).copyWith(fontSize: 10),
                ),
            ],
          ),
          backgroundColor: errorBg,
        ),
        // Weight (editable percentage)
        _tableCell(
          Center(
            child: SizedBox(
              width: 110,
              height: 34,
              child: _PercentageField(
                percentage: allocation.fund.percentage,
                isValid: allocation.isValid,
                isLocked: allocation.fund.isLocked,
                onChanged: (newPerc) {
                  strategy.updateBasketFundPercentage(index, newPerc);
                },
              ),
            ),
          ),
          alignCenter: true,
          backgroundColor: errorBg,
        ),
        // NAV — hidden when table is narrow
        if (!hideNav)
          _tableCell(
            Text(
              allocation.nav > 0
                  ? '₹${allocation.nav.toStringAsFixed(4)}'
                  : '-',
              style: secondaryStyle,
            ),
            alignRight: true,
            backgroundColor: errorBg,
          ),
        // Amount
        _tableCell(
          Text(
            '₹${_formatAmount(allocation.allocatedAmount)}',
            style: !allocation.isValid
                ? cellStyle.copyWith(color: Colors.red)
                : cellStyle.copyWith(fontWeight: MyntFonts.semiBold),
          ),
          alignRight: true,
          backgroundColor: errorBg,
        ),
        // Units
        _tableCell(
          Text(
            allocation.estimatedUnits > 0
                ? allocation.estimatedUnits.toStringAsFixed(4)
                : '-',
            style: secondaryStyle,
          ),
          alignRight: true,
          backgroundColor: errorBg,
        ),
        // Lock toggle
        _tableCell(
          InkWell(
            onTap: () {
              strategy.toggleFundLock(allocation.fund, context);
            },
            borderRadius: BorderRadius.circular(4),
            child: Icon(
              allocation.fund.isLocked ? Icons.lock : Icons.lock_open,
              size: 16,
              color: allocation.fund.isLocked
                  ? resolveThemeColor(context,
                      dark: MyntColors.primaryDark,
                      light: MyntColors.primary)
                  : resolveThemeColor(context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary),
            ),
          ),
          backgroundColor: errorBg,
        ),
      ],
    );
  }

  Widget _buildOrderProgress(
      BuildContext context, DashboardProvider strategy) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Order List',
                  style: MyntWebTextStyles.body(context,
                      fontWeight: MyntFonts.semiBold,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary),
                ),
                 if (strategy.isBasketOrdering) ...[
            const SizedBox(width: 8),
            Text(
              '(Placing order ${strategy.currentOrderIndex + 1} of ${strategy.basketAllocations.length})',
              style: MyntWebTextStyles.para(context,
                  fontWeight: MyntFonts.medium,
                  darkColor: MyntColors.textSecondaryDark,
                  lightColor: MyntColors.textSecondary),
            ),
          ],
              ],
            ),
          ),
          // Order Results List (scrollable with styled scrollbar)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior()
                  .copyWith(scrollbars: false),
              child: RawScrollbar(
                controller: _orderScrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(0),
                thumbColor: shadcn.Theme.of(context)
                    .colorScheme
                    .mutedForeground
                    .withValues(alpha: 0.5),
                child: ListView.separated(
                  controller: _orderScrollController,
                  shrinkWrap: true,
                  itemCount: strategy.basketAllocations.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 0,
                    thickness: 1,
                    color: resolveThemeColor(context,
                        dark: MyntColors.dividerDark,
                        light: MyntColors.divider),
                  ),
                  itemBuilder: (_, index) {
                    final allocation = strategy.basketAllocations[index];
                    final hasResult =
                        index < strategy.basketOrderResults.length;
                    final result =
                        hasResult ? strategy.basketOrderResults[index] : null;

                    // Status badge widget
                    Widget? statusBadge;
                    if (!hasResult) {
                      if (index == strategy.currentOrderIndex &&
                          strategy.isBasketOrdering) {
                        statusBadge = SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                MyntColors.primary),
                          ),
                        );
                      }
                    } else {
                      final statusColor = result!.isSuccess
                          ? Colors.green
                          : Colors.red;
                      final statusText = result.isSuccess
                          ? 'CONFIRMED'
                          : 'FAILED';
                      statusBadge = Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: MyntWebTextStyles.para(
                            context,
                            fontWeight: MyntFonts.medium,
                            color: statusColor,
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First row: Fund name + Status badge
                          SizedBox(
                            height: 24,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    allocation.fund.name,
                                    style: MyntWebTextStyles.body(context,
                                        fontWeight: MyntFonts.medium,
                                        darkColor: MyntColors.textPrimaryDark,
                                        lightColor: MyntColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (statusBadge != null) ...[
                                  const SizedBox(width: 8),
                                  statusBadge,
                                ],
                              ],
                            ),
                          ),
                          // Second row: Amount
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Text(
                                  '₹${_formatAmount(allocation.allocatedAmount)}',
                                  style: MyntWebTextStyles.para(context,
                                      fontWeight: MyntFonts.medium,
                                      darkColor: MyntColors.textSecondaryDark,
                                      lightColor: MyntColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          // // Result message (commented out for now)
                          // if (hasResult && result!.message != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 4),
                          //     child: Text(
                          //       result.message!,
                          //       style: MyntWebTextStyles.para(context,
                          //           fontWeight: MyntFonts.medium,
                          //           color: result.isSuccess
                          //               ? Colors.green
                          //               : Colors.red),
                          //       maxLines: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (strategy.basketOrderCompleted) ...[
            Divider(
              height: 1,
              color: resolveThemeColor(context,
                  dark: MyntColors.dividerDark,
                  light: MyntColors.divider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total Invested : ₹${_formatAmount(strategy.basketOrderResults.where((r) => r.isSuccess).fold(0.0, (sum, r) => sum + r.amount))}',
                    style: MyntWebTextStyles.body(context,
                        fontWeight: MyntFonts.medium,
                        darkColor: MyntColors.textSecondaryDark,
                        lightColor: MyntColors.textSecondary),
                  ),
                  
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: resolveThemeColor(context,
                      dark: Colors.blue.withValues(alpha: 0.08),
                      light: Colors.blue.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: resolveThemeColor(context,
                        dark: Colors.blue.withValues(alpha: 0.2),
                        light: Colors.blue.withValues(alpha: 0.15)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: resolveThemeColor(context,
                            dark: Colors.blue.shade300,
                            light: Colors.blue.shade600)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please check your registered email for payment instructions from BSE to complete your investment.',
                        style: MyntWebTextStyles.para(context,
                            fontWeight: MyntFonts.medium,
                            color: resolveThemeColor(context,
                                dark: Colors.blue.shade300,
                                light: Colors.blue.shade700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: MyntPrimaryButton(
                  label: 'View Order Book',
                  onPressed: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 300), strategy.resetBasketInvest);
                    // Set MF explore to Portfolio tab (2) and Portfolio sub-tab to Orders (1)
                    ref.read(mfProvider).mfExTabchange(2);
                    ref.read(mfProvider).setMfPortfolioInitialTab(1);
                    if (WebNavigationHelper.isAvailable) {
                      WebNavigationHelper.navigateTo('mutualFund');
                    }
                  },
                ),
              ),
            ),
          ],
        ],
    );
  }



  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    }
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (Match match) => '${match[1]},',
        );
  }
}

class _PercentageField extends StatefulWidget {
  final double percentage;
  final bool isValid;
  final bool isLocked;
  final ValueChanged<double> onChanged;

  const _PercentageField({
    required this.percentage,
    required this.isValid,
    this.isLocked = false,
    required this.onChanged,
  });

  @override
  State<_PercentageField> createState() => _PercentageFieldState();
}

class _PercentageFieldState extends State<_PercentageField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.percentage.round().toString());
  }

  @override
  void didUpdateWidget(covariant _PercentageField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the percentage changed externally (not from user typing)
    final currentText = _controller.text;
    final newText = widget.percentage.round().toString();
    if (currentText != newText && double.tryParse(currentText) != widget.percentage) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateWeight(int delta) {
    if (widget.isLocked) return;
    final current = int.tryParse(_controller.text) ?? 0;
    final newVal = (current + delta).clamp(1, 100);
    final newText = '$newVal';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    widget.onChanged(newVal.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);
    final iconColor = widget.isLocked
        ? resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary)
        : resolveThemeColor(context,
            dark: MyntColors.primaryDark, light: MyntColors.primary);
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.primary);
    final bgColor = dark ? MyntColors.cardDark : const Color(0xffF1F3F8);
    final textStyle = MyntWebTextStyles.body(context,
        fontWeight: MyntFonts.regular,
        darkColor: MyntColors.textPrimaryDark,
        lightColor: MyntColors.textPrimary);

    return Container(
      height: 34,
      width: 110,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _updateWeight(-1),
            child: SizedBox(
              width: 28,
              height: 34,
              child: Center(child: Icon(Icons.remove, size: 16, color: iconColor)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: widget.isLocked,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.startsWith('0')) return oldValue;
                  return newValue;
                }),
              ],
              style: textStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value);
                if (intValue != null && intValue > 0 && intValue <= 100) {
                  widget.onChanged(intValue.toDouble());
                }
              },
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _updateWeight(1),
            child: SizedBox(
              width: 28,
              height: 34,
              child: Center(child: Icon(Icons.add, size: 16, color: iconColor)),
            ),
          ),
        ],
      ),
    );
  }
}

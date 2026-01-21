import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../sharedWidget/common_buttons_web.dart';

class ExitAllPositionsDialogWeb extends ConsumerStatefulWidget {
  final List<PositionBookModel> selectedPositions;
  final List<int> selectedIndices;
  /// When true, exits ALL open positions. When false, exits only selected positions.
  final bool isExitAll;

  const ExitAllPositionsDialogWeb({
    super.key,
    required this.selectedPositions,
    required this.selectedIndices,
    required this.isExitAll,
  });

  @override
  ConsumerState<ExitAllPositionsDialogWeb> createState() =>
      _ExitAllPositionsDialogWebState();
}

class _ExitAllPositionsDialogWebState
    extends ConsumerState<ExitAllPositionsDialogWeb> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final positionBook = ref.read(portfolioProvider);

    return Center(
      child: shadcn.Card(
        borderRadius: BorderRadius.circular(8),
        padding: EdgeInsets.zero,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(context, theme),

              // Content
              Flexible(
                child: _buildContent(context, theme),
              ),

              // Footer
              _buildFooter(context, theme, positionBook),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemesProvider theme) {
    return Container(
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
            widget.selectedPositions.length > 1
                ? 'Exit All Positions'
                : 'Exit Position',
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
    );
  }

  Widget _buildContent(BuildContext context, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: shadcn.OutlinedContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available width (minus padding for OutlinedContainer border)
            final availableWidth = constraints.maxWidth - 2;

            // Define column proportions (total = 6.5)
            // Instrument: 2.5, Product: 1, Qty: 1, P&L: 1, LTP: 1
            const totalProportion = 6.5;
            final instrumentWidth = (availableWidth * 2.5) / totalProportion;
            final productWidth = (availableWidth * 1) / totalProportion;
            final qtyWidth = (availableWidth * 1) / totalProportion;
            final pnlWidth = (availableWidth * 1) / totalProportion;
            final ltpWidth = (availableWidth * 1) / totalProportion;

            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: shadcn.Table(
                  columnWidths: {
                    0: shadcn.FixedTableSize(instrumentWidth),
                    1: shadcn.FixedTableSize(productWidth),
                    2: shadcn.FixedTableSize(qtyWidth),
                    3: shadcn.FixedTableSize(pnlWidth),
                    4: shadcn.FixedTableSize(ltpWidth),
                  },
                  defaultRowHeight: const shadcn.FixedTableSize(40),
                  rows: [
                    shadcn.TableHeader(
                      cells: [
                        _buildHeaderCell('Instrument', context),
                        _buildHeaderCell('Product', context),
                        _buildHeaderCell('Qty', context, alignRight: true),
                        _buildHeaderCell('P&L', context, alignRight: true),
                        _buildHeaderCell('LTP', context, alignRight: true),
                      ],
                    ),
                    ...widget.selectedPositions.map((position) {
                      final qty = int.tryParse(position.qty ?? '0') ?? 0;
                      final isClosed = _isPositionClosed(position);

                      return shadcn.TableRow(
                        cells: [
                          // Instrument - use tsym for full symbol name (e.g., SENSEX261227800PE)
                          _buildDataCell(
                            context,
                            '${position.tsym ?? position.symbol ?? ''} ${position.exch ?? ''}',
                            color: _getPositionTextColor(context, position),
                          ),
                          // Product
                          _buildDataCell(
                            context,
                            position.sPrdtAli ?? 'N/A',
                            color: _getPositionTextColor(context, position),
                          ),
                          // Qty
                          _buildDataCell(
                            context,
                            _formatQty(qty.toString()),
                            color: isClosed
                                ? Colors.grey
                                : _getQtyColor(context, qty.toString()),
                            alignRight: true,
                          ),
                          // P&L
                          _buildDataCell(
                            context,
                            position.profitNloss ?? '0.00',
                            color: isClosed
                                ? Colors.grey
                                : _getValueColor(
                                    context, position.profitNloss ?? '0.00'),
                            alignRight: true,
                          ),
                          // LTP
                          _buildDataCell(
                            context,
                            position.lp ?? '0.00',
                            color: _getPositionTextColor(context, position),
                            alignRight: true,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to build header cells with proper styling
  shadcn.TableCell _buildHeaderCell(String label, BuildContext context,
      {bool alignRight = false}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: MyntWebTextStyles.tableHeader(
            context,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build data cells with proper styling
  shadcn.TableCell _buildDataCell(
    BuildContext context,
    String text, {
    Color? color,
    bool alignRight = false,
  }) {
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
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: MyntWebTextStyles.tableCell(
            context,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemesProvider theme,
      PortfolioProvider positionBook) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning message
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.errorDark,
                  light: MyntColors.error,
                ),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.selectedPositions.length > 1
                      ? 'This action will place market orders to exit all selected positions. This action cannot be undone.'
                      : 'This action will place a market order to exit the selected position. This action cannot be undone.',
                  style: MyntWebTextStyles.caption(
                    context,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Exit All button
          Row(
            children: [
              Expanded(
                child: MyntPrimaryButton(
                  onPressed: _isLoading || widget.selectedPositions.isEmpty
                      ? null
                      : () {
                          positionBook.exitPosition(context, widget.isExitAll);
                          Navigator.of(context).pop(); // Close dialog after exit
                        },
                  label: widget.selectedPositions.length > 1
                      ? (widget.isExitAll ? 'Exit All Positions' : 'Exit Selected')
                      : 'Exit Position',
                  isLoading: _isLoading,
                  backgroundColor: resolveThemeColor(
                    context,
                    dark: MyntColors.tertiary,
                    light: MyntColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getValueColor(BuildContext context, String value) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.successDark,
        light: MyntColors.success,
      );
    } else if (numValue < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.errorDark,
        light: MyntColors.error,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
    }
  }

  Color _getQtyColor(BuildContext context, String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.successDark,
        light: MyntColors.success,
      );
    } else if (numQty < 0) {
      return resolveThemeColor(
        context,
        dark: MyntColors.errorDark,
        light: MyntColors.error,
      );
    } else {
      return resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
    }
  }

  bool _isPositionClosed(PositionBookModel position) {
    final qty = int.tryParse(position.qty ?? '0') ?? 0;
    return qty == 0;
  }

  Color _getPositionTextColor(
      BuildContext context, PositionBookModel position) {
    if (_isPositionClosed(position)) {
      final color = resolveThemeColor(
        context,
        dark: MyntColors.textSecondaryDark,
        light: MyntColors.textSecondary,
      );
      return color.withValues(alpha: 0.6);
    }
    return resolveThemeColor(
      context,
      dark: MyntColors.textPrimaryDark,
      light: MyntColors.textPrimary,
    );
  }

  String _formatQty(String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    return numQty > 0 ? '+$qty' : qty;
  }
}

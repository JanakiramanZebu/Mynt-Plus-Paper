import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/res/web_colors.dart' show WebDarkColors;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:flutter/widgets.dart' as flutter;
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';

import '../../../../res/res.dart';
// import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart' as styles;
import '../../../../utils/responsive_snackbar.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../sharedWidget/no_data_found_web.dart';
import '../../../../sharedWidget/hover_actions_web.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import 'create_basket_web.dart';
// import '../../../web/market_watch/search_dialog_web.dart'; // Commented out - search bar integrated
import '../../../web/order/place_order_screen_web.dart';

class BasketList extends ConsumerStatefulWidget {
  const BasketList({super.key});

  @override
  ConsumerState<BasketList> createState() => _BasketListState();
}

class _BasketListState extends ConsumerState<BasketList> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  // ✅ Use ValueNotifier instead of setState to avoid rebuilding entire widget
  final ValueNotifier<String?> _hoveredRowIndex = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _hoveredRowIndex.dispose();
    _hoveredColumnIndex.dispose();
    super.dispose();
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      }
    });
  }

  // Helper method to ensure Geist font is always applied
  TextStyle _geistTextStyle(
      {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: 'Geist',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? styles.MyntColors.textSecondaryDark,
      lightColor: color ?? styles.MyntColors.textSecondary,
      fontWeight: MyntFonts.semiBold,
    );
  }

  // Builds a cell with hover detection
  shadcn.TableCell buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    bool alignRight = false,
    VoidCallback? onTap,
  }) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 2;
    final horizontalPadding = isFirstColumn || isLastColumn ? 16.0 : 8.0;

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
      child: MouseRegion(
        onEnter: (_) => _hoveredRowIndex.value = '$rowIndex',
        onExit: (_) => _hoveredRowIndex.value = null,
        child: ValueListenableBuilder<String?>(
          valueListenable: _hoveredRowIndex,
          builder: (context, hoveredRowId, _) {
            Widget cellContent = Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 8),
              alignment: alignRight ? Alignment.topRight : null,
              decoration: BoxDecoration(
                color: hoveredRowId == '$rowIndex'
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark,
                        light: MyntColors.primary,
                      ).withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: child,
            );

            // Wrap with GestureDetector if onTap is provided
            if (onTap != null) {
              cellContent = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: cellContent,
              );
            }

            return cellContent;
          },
        ),
      ),
    );
  }

  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 2;
    final horizontalPadding = isFirstColumn || isLastColumn ? 16.0 : 6.0;

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
      child: InkWell(
        onTap: () => _onSortTable(columnIndex, true),
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && _sortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              if (!alignRight && _sortColumnIndex == columnIndex)
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate minimum column widths dynamically
  Map<int, double> _calculateMinWidths(
      List<dynamic> baskets, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Basket Name',
      'Items',
      'Created Date',
    ];
    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      for (final basket in baskets.take(5)) {
        final basketMap = basket as Map<String, dynamic>;
        String cellText = '';
        switch (col) {
          case 0: // Basket Name
            cellText = (basketMap['bsketName'] ?? 'N/A').toString();
            break;
          case 1: // Items
            cellText = (basketMap['curLength'] ?? 0).toString();
            break;
          case 2: // Created Date
            cellText = (basketMap['createdDate'] ?? '').toString();
            break;
        }

        final cellWidth = _measureTextWidth(cellText, textStyle);
        if (cellWidth > maxWidth) {
          maxWidth = cellWidth;
        }
      }

      minWidths[col] = maxWidth + padding;
    }

    return minWidths;
  }

  double _measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _geistTextStyle(fontSize: 14)),
      textDirection: flutter.TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  bool _isNumericColumn(String header) {
    switch (header) {
      case 'Items':
        return true;
      case 'Basket Name':
      case 'Created Date':
        return false;
      default:
        return false;
    }
  }

  List<dynamic> _getFilteredBaskets(List<dynamic> baskets) {
    final orderBook = ref.read(orderProvider);
    final searchQuery = orderBook.orderSearchCtrl.text.toUpperCase();

    if (searchQuery.isEmpty) {
      return baskets;
    }

    return baskets.where((basket) {
      final basketName = (basket['bsketName'] ?? '').toString().toUpperCase();
      return basketName.contains(searchQuery);
    }).toList();
  }

  int _getBasketColumnIndexForHeader(String header) {
    switch (header) {
      case 'Basket Name':
        return 0;
      case 'Items':
        return 1;
      case 'Created Date':
        return 2;
      default:
        return -1;
    }
  }

  List<dynamic> _getSortedBaskets(List<dynamic> baskets) {
    if (_sortColumnIndex == null) return baskets;
    final sorted = [...baskets];
    int c = _sortColumnIndex!;
    bool asc = _sortAscending;

    sorted.sort((a, b) {
      int comparison = 0;
      switch (c) {
        case 0: // Basket Name
          comparison = ((a as Map)['bsketName'] ?? '')
              .toString()
              .compareTo(((b as Map)['bsketName'] ?? '').toString());
          break;
        case 1: // Items
          final aItems =
              int.tryParse(((a as Map)['curLength'] ?? 0).toString()) ?? 0;
          final bItems =
              int.tryParse(((b as Map)['curLength'] ?? 0).toString()) ?? 0;
          comparison = aItems.compareTo(bItems);
          break;
        case 2: // Created Date
          comparison = ((a as Map)['createdDate'] ?? '')
              .toString()
              .compareTo(((b as Map)['createdDate'] ?? '').toString());
          break;
      }
      return asc ? comparison : -comparison;
    });
    return sorted;
  }

  Widget _buildBasketNameCell(
    Map<String, dynamic> basket,
    ThemesProvider theme,
    String uniqueId,
    int index,
    bool isRowHovered,
  ) {
    final bsktName = basket['bsketName'] ?? 'N/A';
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Basket icon and name - full width, can be partially covered by buttons
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(right: isRowHovered ? 80.0 : 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    assets.basketdashboard,
                    width: 10,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      colorScheme.mutedForeground,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      bsktName,
                      style: _geistTextStyle(
                        color: colorScheme.foreground,
                      ),
                      maxLines: 1,
                      overflow: isRowHovered
                          ? TextOverflow.ellipsis
                          : TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Action buttons - positioned at the right edge
        if (isRowHovered)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, // Empty handler to stop propagation
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      shadcn.Theme.of(context)
                          .colorScheme
                          .background
                          .withValues(alpha: 0.0),
                      shadcn.Theme.of(context)
                          .colorScheme
                          .background
                          .withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: HoverActionsContainer(
                  isVisible: isRowHovered,
                  actions: [
                    HoverActionButton(
                      label: 'Delete',
                      size: 54,
                      borderRadius: 5,
                      color: Colors.white,
                      onPressed: () =>
                          _handleDeleteBasket(context, basket, index),
                      backgroundColor: resolveThemeColor(context,
                          dark: MyntColors.tertiary,
                          light: MyntColors.tertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment,
  ) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    return Align(
      alignment: alignment,
      child: Text(
        text,
        style: _geistTextStyle(
          color: colorScheme.foreground,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBasketSortIcon(int columnIndex, ThemesProvider theme) {
    if (_sortColumnIndex == columnIndex) {
      return Icon(
        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
        size: 16,
        color: theme.isDarkMode ? MyntColors.primary : MyntColors.primary,
      );
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode ? MyntColors.secondary : MyntColors.secondary,
      );
    }
  }

  Widget _buildBasketTable(ThemesProvider theme, List<dynamic> baskets) {
    if (baskets.isEmpty) {
      return const SizedBox.expand(
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: NoDataFound(),
          ),
        ),
      );
    }

    // Sort baskets
    final sortedBaskets = _getSortedBaskets(baskets);

    return SizedBox.expand(
      child: shadcn.OutlinedContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate minimum widths dynamically based on actual content
            final minWidths = _calculateMinWidths(sortedBaskets, context);

            // Available width
            final availableWidth = constraints.maxWidth;

            // Step 1: Start with minimum widths (content-based, no wasted space)
            final columnWidths = <int, double>{};
            for (int i = 0; i < 3; i++) {
              columnWidths[i] = minWidths[i] ?? 100.0;
            }

            // Step 2: Calculate total minimum width needed
            final totalMinWidth = columnWidths.values
                .fold<double>(0.0, (sum, width) => sum + width);

            // Step 3: If there's extra space, distribute it proportionally
            if (totalMinWidth < availableWidth) {
              final extraSpace = availableWidth - totalMinWidth;

              const basketNameGrowthFactor = 1.0;
              const textGrowthFactor = 1.0;
              const numericGrowthFactor = 1.0;

              final growthFactors = <int, double>{};
              double totalGrowthFactor = 0.0;

              for (int i = 0; i < 3; i++) {
                if (i == 0) {
                  // Basket Name
                  growthFactors[i] = basketNameGrowthFactor;
                  totalGrowthFactor += basketNameGrowthFactor;
                } else if (i == 2) {
                  // Created Date
                  growthFactors[i] = textGrowthFactor;
                  totalGrowthFactor += textGrowthFactor;
                } else {
                  // Items
                  growthFactors[i] = numericGrowthFactor;
                  totalGrowthFactor += numericGrowthFactor;
                }
              }

              if (totalGrowthFactor > 0) {
                for (int i = 0; i < 3; i++) {
                  if (growthFactors[i]! > 0) {
                    final extraForThisColumn =
                        (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                    columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                  }
                }
              }
            }

            final totalRequiredWidth = columnWidths.values
                .fold<double>(0.0, (sum, width) => sum + width);
            final needsHorizontalScroll = totalRequiredWidth > availableWidth;

            Widget buildTableContent() {
              return Column(
                children: [
                  // Fixed Header
                  shadcn.Table(
                    columnWidths: {
                      0: shadcn.FixedTableSize(columnWidths[0]!),
                      1: shadcn.FixedTableSize(columnWidths[1]!),
                      2: shadcn.FixedTableSize(columnWidths[2]!),
                    },
                    defaultRowHeight: const shadcn.FixedTableSize(50),
                    rows: [
                      shadcn.TableHeader(
                        cells: [
                          buildHeaderCell('Basket Name', 0),
                          buildHeaderCell('Items', 1, true),
                          buildHeaderCell('Created Date', 2),
                        ],
                      ),
                    ],
                  ),
                  // Scrollable Body
                  Expanded(
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: ValueListenableBuilder<String?>(
                          valueListenable: _hoveredRowIndex,
                          builder: (context, hoveredRowId, _) {
                            return shadcn.Table(
                              key: ValueKey(
                                  'table_${_sortColumnIndex}_$_sortAscending'),
                              columnWidths: {
                                0: shadcn.FixedTableSize(columnWidths[0]!),
                                1: shadcn.FixedTableSize(columnWidths[1]!),
                                2: shadcn.FixedTableSize(columnWidths[2]!),
                              },
                              defaultRowHeight: const shadcn.FixedTableSize(50),
                              rows: sortedBaskets.asMap().entries.map((entry) {
                                final index = entry.key;
                                final basket =
                                    entry.value as Map<String, dynamic>;
                                final uniqueId = '$index';
                                final isRowHovered = hoveredRowId == uniqueId;

                                return shadcn.TableRow(
                                  cells: [
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 0,
                                      onTap: () =>
                                          _handleBasketTap(context, basket),
                                      child: _buildBasketNameCell(basket, theme,
                                          uniqueId, index, isRowHovered),
                                    ),
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 1,
                                      alignRight: true,
                                      onTap: () =>
                                          _handleBasketTap(context, basket),
                                      child: _buildTextCell(
                                        (basket['curLength'] ?? 0).toString(),
                                        theme,
                                        Alignment.centerRight,
                                      ),
                                    ),
                                    buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 2,
                                      onTap: () =>
                                          _handleBasketTap(context, basket),
                                      child: _buildTextCell(
                                        basket['createdDate']?.toString() ?? '',
                                        theme,
                                        Alignment.centerLeft,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (needsHorizontalScroll) {
              return Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalRequiredWidth,
                    child: buildTableContent(),
                  ),
                ),
              );
            }

            return buildTableContent();
          },
        ),
      ),
    );
  }

  Future<void> _handleDeleteBasket(
      BuildContext context, Map<String, dynamic> basket, int index) async {
    final bsktName = basket['bsketName'] ?? '';
    final basketProvider = ref.read(orderProvider);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = ref.read(themeProvider);
        return Dialog(
          backgroundColor: theme.isDarkMode
              ? MyntColors.backgroundColorDark
              : MyntColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(false),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: theme.isDarkMode
                            ? MyntColors.textSecondaryDark
                            : MyntColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Are you sure you want to \ndelete this ',
                    style: WebTextStyles.dialogContent(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? MyntColors.textPrimaryDark
                          : MyntColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: 'basket',
                        style: WebTextStyles.dialogContent(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? MyntColors.textPrimaryDark
                              : MyntColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: ' ${bsktName.toString().toUpperCase()}?',
                        style: WebTextStyles.dialogContent(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? MyntColors.textPrimaryDark
                              : MyntColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isDeleting
                        ? MyntLoader.inline(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          )
                        : Text(
                            'Delete',
                            style: WebTextStyles.buttonMd(
                              isDarkTheme: theme.isDarkMode,
                              color: Colors.white,
                            ).copyWith(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete == true) {
      setState(() => _isDeleting = true);
      await basketProvider.removeBasket(index);
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _handleBasketTap(
      BuildContext context, Map<String, dynamic> basket) async {
    final bsktName = basket['bsketName'] ?? '';
    final basketProvider = ref.read(orderProvider);

    await basketProvider.fetchBasketMargin();
    await basketProvider.chngBsktName(bsktName, context, true);

    if (context.mounted) {
      final colorScheme = shadcn.Theme.of(context).colorScheme;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: colorScheme.popover,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BasketScripList(
                  bsktName: bsktName,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch basket provider to rebuild when basket data changes
    final basket = ref.watch(orderProvider);
    final theme = ref.watch(themeProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? MyntColors.primaryDark
                      : WebColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: Colors.white.withOpacity(0.1),
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 150), () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            final theme = ref.read(themeProvider);
                            return Dialog(
                              backgroundColor: theme.isDarkMode
                                  ? MyntColors.backgroundColorDark
                                  : MyntColors.backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const SizedBox(
                                width: 400,
                                child: CreateBasket(),
                              ),
                            );
                          },
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        "Create Basket",
                        style: WebTextStyles.buttonMd(
                          isDarkTheme: theme.isDarkMode,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        basket.isBasketLoading
            ? SizedBox(
                height: 400, child: Center(child: MyntLoader.simple()))
            : basket.bsktList.isEmpty
                ? const SizedBox(height: 400, child: NoDataFound())
                : Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: _buildBasketTable(
                                theme, _getFilteredBaskets(basket.bsktList)),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}

class BasketScripList extends ConsumerStatefulWidget {
  final String bsktName;
  const BasketScripList({super.key, required this.bsktName});

  @override
  ConsumerState<BasketScripList> createState() => _BasketScripListState();
}

class _BasketScripListState extends ConsumerState<BasketScripList>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  String _searchValue = "";
  late TabController _tabController;
  VoidCallback?
      _tabControllerListener; // Store listener reference for proper cleanup
  final int _tabCount = 5; // For basket mode
  final Map<int, bool> _hoveredItems = {}; // For Buy/Sell button hover
  // ✅ Use ValueNotifier instead of setState to avoid rebuilding entire widget
  final ValueNotifier<String?> _hoveredRowIndex = ValueNotifier<String?>(null);
  final ValueNotifier<int?> _hoveredColumnIndex = ValueNotifier<int?>(null);
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _tabCount, vsync: this, initialIndex: 0);
    // Store listener reference for proper cleanup
    _tabControllerListener = () {
      if (_tabController.indexIsChanging && _searchValue.isNotEmpty) {
        final marketWatch = ref.read(marketWatchProvider);
        marketWatch.searchClear();
        marketWatch.scripSearch(
            _searchValue, context, _tabController.index, "Basket");
      }
    };
    _tabController.addListener(_tabControllerListener!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabScrollController.dispose();
    _searchScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    // Remove listener before disposing to prevent memory leaks
    if (_tabControllerListener != null) {
      _tabController.removeListener(_tabControllerListener!);
      _tabControllerListener = null;
    }
    _tabController.dispose();
    _hoveredRowIndex.dispose();
    _hoveredColumnIndex.dispose();
    super.dispose();
  }

  // Helper method to get responsive column configuration for Basket Items
  Map<String, dynamic> _getResponsiveBasketItemsColumns(double screenWidth) {
    // Desktop/Default:
    return {
      'headers': [
        'Instrument',
        'Buy/Sell',
        'Product',
        'Price type',
        'Qty',
        'Price',
        'Actions'
      ],
      'columnFlex': {
        'Instrument': 3,
        'Buy/Sell': 1,
        'Product': 1,
        'Price type': 1,
        'Qty': 1,
        'Price': 1,
        'Actions': 1,
      },
      'columnMinWidth': {
        'Instrument': 250,
        'Buy/Sell': 80,
        'Product': 90,
        'Price type': 90,
        'Qty': 80,
        'Price': 90,
        'Actions': 110,
      },
    };
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      }
    });
  }

  bool _isNumericColumnBasketItems(String header) {
    switch (header) {
      case 'Qty':
      case 'Price':
      case 'LTP':
        return true;
      case 'Instrument':
      case 'Details':
      case 'Type':
      case 'Status':
        return false;
      default:
        return false;
    }
  }

  List<Map<String, dynamic>> _getSortedBasketScripts(
      List<Map<String, dynamic>> items) {
    if (_sortColumnIndex == null) return items;
    final sorted = [...items];
    int c = _sortColumnIndex!;
    bool asc = _sortAscending;

    int cmp<T extends Comparable<T>>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    }

    num parseNum(String? v) => double.tryParse(v ?? '') ?? 0;

    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Instrument
          final aSymbol = '${a['symbol'] ?? ''}';
          final bSymbol = '${b['symbol'] ?? ''}';
          r = cmp<String>(aSymbol, bSymbol);
          break;
        case 1: // Buy/Sell
          r = cmp<String>(a["trantype"]?.toString(), b["trantype"]?.toString());
          break;
        case 2: // Product
          r = cmp<String>(a['prd']?.toString(), b['prd']?.toString());
          break;
        case 3: // Price type
          r = cmp<String>(a['prctype']?.toString(), b['prctype']?.toString());
          break;
        case 4: // Qty
          final aQty = int.tryParse(a["qty"]?.toString() ?? "0") ?? 0;
          final bQty = int.tryParse(b["qty"]?.toString() ?? "0") ?? 0;
          r = aQty.compareTo(bQty);
          break;
        case 5: // Price
          final aPrice = parseNum(a["prc"]?.toString());
          final bPrice = parseNum(b["prc"]?.toString());
          r = cmp<num>(aPrice, bPrice);
          break;
        // Actions (6) is not sortable
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  /// Checks if the basket contains scripts from multiple exchanges
  bool _hasMultipleExchanges(List scriptList) {
    if (scriptList.isEmpty) return false;

    // Extract all exchanges from the basket scripts
    Set<String> exchanges = {};
    for (var script in scriptList) {
      if (script['exch'] != null) {
        exchanges.add(script['exch'].toString());
      }
    }

    // If there's more than one unique exchange, return true
    return exchanges.length > 1;
  }

  /// Checks if the current basket has any orders placed
  bool _hasOrdersPlacedInBasket(
      String basketName, OrderProvider orderProvider) {
    // Check if this basket has any order tracking
    return orderProvider.basketOrderIds.containsKey(basketName) &&
        orderProvider.basketOrderIds[basketName]!.isNotEmpty;
  }

  Widget _buildSearchResults(WidgetRef ref, ThemesProvider theme) {
    final searchScrip = ref.watch(marketWatchProvider);

    if (searchScrip.allSearchScrip?.isEmpty ?? true) {
      return Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? MyntColors.backgroundColorDark
              : MyntColors.backgroundColor,
        ),
        child: const Center(
          child: NoDataFoundWeb(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
      ),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: RawScrollbar(
          controller: _searchScrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(0),
          thumbColor: resolveThemeColor(
            context,
            dark: WebColors.textSecondaryDark.withOpacity(0.5),
            light: WebColors.textSecondary.withOpacity(0.5),
          ),
          child: ListView.separated(
            controller: _searchScrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: searchScrip.allSearchScrip!.length,
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color: resolveThemeColor(
                context,
                dark: WebColors.dividerDark,
                light: WebColors.divider,
              ),
            ),
            itemBuilder: (BuildContext context, int index) {
              final scrip = searchScrip.allSearchScrip![index];

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredItems[index] = true),
                onExit: (_) => setState(() => _hoveredItems[index] = false),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.02)
                        : Colors.black.withOpacity(0.02),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          // Scrip Info
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Symbol name and option
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${scrip.symbol?.isNotEmpty == true ? scrip.symbol : scrip.tsym}"
                                          .replaceAll("-EQ", "")
                                          .toUpperCase(),
                                      style: WebTextStyles.symbolList(
                                        isDarkTheme: theme.isDarkMode,
                                        color: theme.isDarkMode
                                            ? MyntColors.textPrimary
                                            : WebColors.textPrimary,
                                      ),
                                    ),
                                    if (scrip.option != null &&
                                        scrip.option.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          "${scrip.option}",
                                          style: WebTextStyles.symbolList(
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    if (scrip.expDate != null &&
                                        scrip.expDate.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          " ${scrip.expDate}",
                                          style: WebTextStyles.symbolList(
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textPrimary
                                                : WebColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        '${scrip.exch}',
                                        style: WebTextStyles.exchText(
                                            isDarkTheme: theme.isDarkMode,
                                            color: WebColors.textSecondary),
                                      ),
                                    ),
                                    // Buy/Sell buttons for Basket mode - shown next to symbol
                                    const SizedBox(width: 8),
                                    IgnorePointer(
                                      ignoring:
                                          !(_hoveredItems[index] ?? false),
                                      child: AnimatedOpacity(
                                        opacity: (_hoveredItems[index] ?? false)
                                            ? 1.0
                                            : 0.0,
                                        duration:
                                            const Duration(milliseconds: 150),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Buy Button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                onTap: () async {
                                                  await _handleBuySellClick(
                                                      context,
                                                      scrip,
                                                      true,
                                                      ref,
                                                      theme);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: WebColors.primary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 4.0),
                                                  child: Text(
                                                    'Buy',
                                                    style:
                                                        WebTextStyles.buttonSm(
                                                      isDarkTheme:
                                                          theme.isDarkMode,
                                                      color: WebColors.primary,
                                                      fontWeight:
                                                          WebFonts.medium,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Sell Button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                onTap: () async {
                                                  await _handleBuySellClick(
                                                      context,
                                                      scrip,
                                                      false,
                                                      ref,
                                                      theme);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: WebColors.tertiary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 4.0),
                                                  child: Text(
                                                    'Sell',
                                                    style:
                                                        WebTextStyles.buttonSm(
                                                      isDarkTheme:
                                                          theme.isDarkMode,
                                                      color: WebColors.tertiary,
                                                      fontWeight:
                                                          WebFonts.medium,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Handle Buy/Sell click for basket mode
  Future<void> _handleBuySellClick(
    BuildContext context,
    dynamic scrip,
    bool isBuy,
    WidgetRef ref,
    ThemesProvider theme,
  ) async {
    try {
      final marketWatch = ref.read(marketWatchProvider);
      final orderProv = ref.read(orderProvider);

      // Check basket limit
      if (orderProv.bsktScripList.length >=
          orderProv.frezQtyOrderSliceMaxLimit) {
        ResponsiveSnackBar.showWarning(
          context,
          "Basket limit reached. Please create a new basket as you are exceeding the ${orderProv.frezQtyOrderSliceMaxLimit} item limit.",
        );
        return;
      }

      // Check if segment is active
      if (!marketWatch.exarr.contains('"${scrip.exch}"')) {
        ResponsiveSnackBar.showError(context, "Segment is not active.");
        return;
      }

      // Fetch scrip info first
      await marketWatch.fetchScripInfo(
        scrip.token.toString(),
        scrip.exch.toString(),
        context,
        true,
      );

      if (!context.mounted) return;

      // Check if scrip info was fetched
      if (marketWatch.scripInfoModel == null) {
        ResponsiveSnackBar.showError(
            context, "Failed to fetch scrip information.");
        return;
      }

      // Fetch depth data (getQuotes) to get LTP and percentage change
      await marketWatch.fetchScripQuote(
        scrip.token.toString(),
        scrip.exch.toString(),
        context,
      );

      if (!context.mounted) return;

      // Get LTP and percentage change from depth data (getQuotes)
      final depthData = marketWatch.getQuotes;
      final ltp =
          depthData?.lp?.toString() ?? depthData?.c?.toString() ?? "0.00";
      final perChange = depthData?.pc?.toString() ?? "0.00";

      // Create OrderScreenArgs
      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: scrip.exch.toString(),
        tSym: scrip.tsym.toString(),
        isExit: false,
        token: scrip.token.toString(),
        transType: isBuy,
        lotSize: marketWatch.scripInfoModel?.ls?.toString() ?? "1",
        ltp: ltp,
        perChange: perChange,
        orderTpye: '',
        holdQty: '',
        isModify: false,
        prd: null,
        raw: {
          'exch': scrip.exch.toString(),
          'token': scrip.token.toString(),
          'tsym': scrip.tsym.toString(),
          'symbol': scrip.symbol?.toString() ?? scrip.tsym.toString(),
          'expDate': scrip.expDate?.toString() ?? '',
          'option': scrip.option?.toString() ?? '',
          'trantype': isBuy ? 'B' : 'S', // Add transaction type to raw map
        },
      );

      // Clear search
      marketWatch.searchClear();
      _searchController.clear();
      setState(() {
        _searchValue = "";
      });

      // Show order screen as draggable dialog using showDraggable method
      // This uses Overlay.of(context) which works from within the dialog
      if (context.mounted) {
        PlaceOrderScreenWeb.showDraggable(
          context: context,
          orderArg: orderArgs,
          scripInfo: marketWatch.scripInfoModel!,
          isBasket: "Basket",
        );
      }
    } catch (e, stackTrace) {
      print("Error in _handleBuySellClick: $e");
      print("Stack trace: $stackTrace");
      if (context.mounted) {
        ResponsiveSnackBar.showError(
            context, "Failed to open order screen: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = ref.read(themeProvider);
    final basket = ref.watch(orderProvider);

    // Calculate margins
    final preTradeMargin = basket.bsktScripList.isEmpty ||
            basket.bsktOrderMargin == null
        ? "0.00"
        : (double.parse(basket.bsktOrderMargin!.marginused ?? '0.00') -
                double.parse(basket.bsktOrderMargin!.marginusedprev ?? '0.00'))
            .toStringAsFixed(2);

    final postTradeMargin = basket.bsktScripList.isEmpty ||
            basket.bsktOrderMargin == null
        ? "0.00"
        : (double.parse(basket.bsktOrderMargin!.marginusedtrade ?? '0.00') -
                double.parse(basket.bsktOrderMargin!.marginusedprev ?? '0.00'))
            .toStringAsFixed(2);

    return Material(
      color: theme.isDarkMode
          ? styles.MyntColors.backgroundColorDark
          : styles.MyntColors.backgroundColor,
      child: Stack(
        children: [
          Column(
            children: [
              // 1. Header: "Basket order" + Close
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Basket order",
                      style: WebTextStyles.custom(
                        fontSize: 14,
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? WebDarkColors.textPrimary
                            : WebColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: theme.isDarkMode
                            ? WebDarkColors.iconSecondary
                            : WebColors.secondary,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // 2. Toolbar: Name Section + Search Bar
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Basket Name Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : const Color(0xfff5f5f5), // Light gray bg
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        basket.selectedBsktName.isEmpty
                            ? widget.bsktName
                            : basket.selectedBsktName,
                        style: WebTextStyles.custom(
                          fontSize: 13,
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Icons (Edit/Delete Basket Placeholder)
                    _buildBasketHoverButton(
                      icon: Icons.edit_outlined,
                      color: resolveThemeColor(
                        context,
                        dark: styles.MyntColors.textSecondaryDark,
                        light: styles.MyntColors.textSecondary,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            final theme = ref.read(themeProvider);
                            return Dialog(
                              backgroundColor: resolveThemeColor(
                                context,
                                dark: MyntColors.backgroundColorDark,
                                light: MyntColors.backgroundColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: SizedBox(
                                width: 400,
                                child: CreateBasket(
                                  initialName: basket.selectedBsktName.isEmpty
                                      ? widget.bsktName
                                      : basket.selectedBsktName,
                                  isEdit: true,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      theme: theme,
                    ),
                    const SizedBox(width: 4),
                    _buildBasketHoverButton(
                      icon: Icons.delete_outline,
                      color: resolveThemeColor(
                        context,
                        dark: styles.MyntColors.textSecondaryDark,
                        light: styles.MyntColors.textSecondary,
                      ),
                      onPressed: () => _handleDeleteBasket(theme),
                      theme: theme,
                    ),

                    const Spacer(),

                    // Search Bar
                    Container(
                      width: 300,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : const Color(0xfff5f5f5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: WebTextStyles.formInput(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5), // Centered vertically
                          border: InputBorder.none,
                          hintText: "Search script",
                          hintStyle: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                              fontWeight: FontWeight.normal),
                          prefixIcon: Icon(Icons.search,
                              size: 18,
                              color: resolveThemeColor(
                                context,
                                dark: styles.MyntColors.textSecondaryDark,
                                light: styles.MyntColors.textSecondary,
                              )),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              // Toggle dropdown logic if needed, currently behaves as search
                            },
                            child: Icon(Icons.keyboard_arrow_down,
                                size: 18,
                                color: resolveThemeColor(
                                  context,
                                  dark: styles.MyntColors.textSecondaryDark,
                                  light: styles.MyntColors.textSecondary,
                                )),
                          ),
                        ),
                        onChanged: (value) async {
                          setState(() {
                            _searchValue = value.toUpperCase();
                          });
                          final marketWatch = ref.read(marketWatchProvider);
                          if (value.isEmpty) {
                            marketWatch.searchClear();
                          } else {
                            marketWatch.scripSearch(value.toUpperCase(),
                                context, _tabController.index, "Basket");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Table Content
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: basket.bsktScripList.isEmpty
                      ? const NoDataFound()
                      : Builder(
                          builder: (context) {
                            // Process basket items to extract symbol info
                            final processedItems =
                                List<Map<String, dynamic>>.from(
                                    basket.bsktScripList);
                            for (int i = 0; i < processedItems.length; i++) {
                              processedItems[i]['_originalIndex'] = i;
                              if (processedItems[i]['exch'] == "BFO" &&
                                  processedItems[i]["dname"] != "null") {
                                List<String> splitVal = processedItems[i]
                                        ["dname"]
                                    .toString()
                                    .split(" ");
                                processedItems[i]['symbol'] = splitVal[0];
                                processedItems[i]['expDate'] =
                                    "${splitVal[1]} ${splitVal[2]}";
                                processedItems[i]['option'] =
                                    splitVal.length > 4
                                        ? "${splitVal[3]} ${splitVal[4]}"
                                        : splitVal[3];
                              } else {
                                Map spilitSymbol = spilitTsym(
                                    value: "${processedItems[i]['tsym']}");
                                processedItems[i]['symbol'] =
                                    "${spilitSymbol["symbol"]}";
                                processedItems[i]['expDate'] =
                                    "${spilitSymbol["expDate"]}";
                                processedItems[i]['option'] =
                                    "${spilitSymbol["option"]}";
                              }
                            }

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                final responsiveConfig =
                                    _getResponsiveBasketItemsColumns(
                                        screenWidth);
                                final headers = List<String>.from(
                                    responsiveConfig['headers'] as List);
                                final columnFlex = Map<String, int>.from(
                                    responsiveConfig['columnFlex'] as Map);
                                final columnMinWidth = Map<String, double>.from(
                                    responsiveConfig['columnMinWidth'] as Map);
                                final totalMinWidth = columnMinWidth.values
                                    .fold<double>(0.0, (a, b) => a + b);
                                final needHorizontalScroll =
                                    constraints.maxWidth < totalMinWidth;

                                final tableColumn = Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.isDarkMode
                                          ? WebDarkColors.divider
                                          : WebColors.divider,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Header
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: theme.isDarkMode
                                                      ? WebDarkColors.divider
                                                      : WebColors.divider,
                                                  width: 1)),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                0), // Padding inside cells
                                        child: needHorizontalScroll
                                            ? IntrinsicWidth(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children:
                                                      headers.map((label) {
                                                    return _buildBasketColumnCell(
                                                      needHorizontalScroll:
                                                          needHorizontalScroll,
                                                      flex: columnFlex[label] ??
                                                          1,
                                                      minW: columnMinWidth[
                                                              label] ??
                                                          80.0,
                                                      child: _buildBasketHeaderWidget(
                                                          label,
                                                          _getBasketColumnIndexForHeader(
                                                              label),
                                                          theme),
                                                    );
                                                  }).toList(),
                                                ),
                                              )
                                            : Row(
                                                children: headers.map((label) {
                                                  return _buildBasketColumnCell(
                                                    needHorizontalScroll:
                                                        needHorizontalScroll,
                                                    flex:
                                                        columnFlex[label] ?? 1,
                                                    minW:
                                                        columnMinWidth[label] ??
                                                            80.0,
                                                    child: _buildBasketHeaderWidget(
                                                        label,
                                                        _getBasketColumnIndexForHeader(
                                                            label),
                                                        theme),
                                                  );
                                                }).toList(),
                                              ),
                                      ),
                                      // Body
                                      Expanded(
                                        child: Scrollbar(
                                          controller: _verticalScrollController,
                                          thumbVisibility: true,
                                          child: _buildBasketBodyList(
                                            theme,
                                            processedItems,
                                            headers,
                                            columnFlex,
                                            columnMinWidth,
                                            totalMinWidth: totalMinWidth,
                                            needHorizontalScroll:
                                                needHorizontalScroll,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (needHorizontalScroll) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _horizontalScrollController,
                                    child: SizedBox(
                                        width: totalMinWidth,
                                        child: tableColumn),
                                  );
                                }
                                return tableColumn;
                              },
                            );
                          },
                        ),
                ),
              ),

              // 4. Footer: Margins + Action Buttons
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Margin Info
                    Row(
                      children: [
                        Text(
                          "Basket Margin: ",
                          style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "₹$preTradeMargin",
                          style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          "Post Trade Margin: ",
                          style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "₹$postTradeMargin",
                          style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Refresh Button
                    IconButton(
                      onPressed: () async {
                        await basket.fetchBasketMargin();
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 22,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textSecondaryDark,
                          light: MyntColors.textSecondary,
                        ),
                      ),
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 16),

                    // Place Order Button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: _hasMultipleExchanges(basket.bsktScripList)
                            ? null // Disabled if multiple exchanges
                            : () async {
                                if (_hasOrdersPlacedInBasket(
                                    widget.bsktName, basket)) {
                                  basket.resetBasketOrderTracking(
                                      widget.bsktName);
                                  ResponsiveSnackBar.showSuccess(context,
                                      "Basket reset. You can place orders again.");
                                } else {
                                  await basket.placeBasketOrder(context,
                                      navigateToOrderBook: false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.isDarkMode
                              ? WebDarkColors.primary
                              : WebColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 0,
                        ),
                        child: Text(
                          _hasOrdersPlacedInBasket(widget.bsktName, basket)
                              ? "Reset Orders"
                              : "Place Order",
                          style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: MyntColors.backgroundColor, // Always white
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Search Results Overlay
          if (_searchValue.isNotEmpty)
            Positioned(
              top: 110, // Header(50) + Toolbar(60)
              right: 16, // Padding of Toolbar
              width: 300, // Width of Search Bar
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.backgroundColorDark,
                      light: MyntColors.backgroundColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                    )),
                child: Column(
                  children: [
                    // Use existing search tabs if needed, or hide them for 'simple' search
                    // Image 0 doesn't show tabs, but functionality might require them.
                    // Keeping tabs for functionality but styling them minimal if possible.
                    // For now, simpler: just results.
                    Expanded(
                      child: _buildSearchResults(ref, theme),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String formatToTimeOnly(String rawDate) {
    try {
      final dateTime = DateFormat("dd MMM yyyy, hh:mm a").parse(rawDate);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return ''; // or return rawDate if you want fallback
    }
  }

  // Helper methods for individual item status indicators

  int _getBasketColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument':
        return 0;
      case 'Buy/Sell':
        return 1;
      case 'Product':
        return 2;
      case 'Price type':
        return 3;
      case 'Qty':
        return 4;
      case 'Price':
        return 5;
      case 'Actions':
        return 6;
      default:
        return -1;
    }
  }

  Widget _buildBasketHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
  ) {
    final isNumeric = _isNumericColumnBasketItems(label);
    return SizedBox.expand(
      child: MouseRegion(
        onEnter: (_) => _hoveredColumnIndex.value = columnIndex,
        onExit: (_) => _hoveredColumnIndex.value = null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onSortTable(columnIndex, true),
          child: ValueListenableBuilder<int?>(
            valueListenable: _hoveredColumnIndex,
            builder: (context, hoveredIndex, child) {
              return Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: hoveredIndex == columnIndex
                      ? (theme.isDarkMode
                          ? WebDarkColors.primary.withOpacity(0.1)
                          : WebColors.primary.withOpacity(0.05))
                      : Colors.transparent,
                ),
                alignment:
                    isNumeric ? Alignment.centerRight : Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                child: Row(
                  mainAxisAlignment: isNumeric
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: WebTextStyles.tableHeader(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBasketColumnCell({
    required bool needHorizontalScroll,
    required int flex,
    required double minW,
    required Widget child,
  }) {
    if (needHorizontalScroll) {
      return SizedBox(
        width: minW,
        child: child,
      );
    }

    return Expanded(
      flex: flex,
      child: SizedBox(
        width: minW,
        child: child,
      ),
    );
  }

  Widget _buildBasketBodyList(
    ThemesProvider theme,
    List<Map<String, dynamic>> processedItems,
    List<String> headers,
    Map<String, int> columnFlex,
    Map<String, double> columnMinWidth, {
    required double totalMinWidth,
    required bool needHorizontalScroll,
  }) {
    final sorted = _getSortedBasketScripts(processedItems);
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final item = sorted[index];
        final originalIndex = item['_originalIndex'] as int;
        final uniqueId = 'basket_$originalIndex';

        return MouseRegion(
          onEnter: (_) => _hoveredRowIndex.value = uniqueId,
          onExit: (_) => _hoveredRowIndex.value = null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Handle tap - same as original onTap
              await ref.read(marketWatchProvider).fetchScripInfo(
                  "${item['token']}", '${item['exch']}', context, true);

              if (!context.mounted) return;

              final basket = ref.read(orderProvider);
              basket.bsktScripList[originalIndex]['index'] = originalIndex;
              basket.bsktScripList[originalIndex]['prctyp'] =
                  basket.bsktScripList[originalIndex]['prctype'];

              final ltp = item['lp']?.toString() ?? "0.00";
              final perChange = item['pc']?.toString() ?? "0.00";

              OrderScreenArgs orderArgs = OrderScreenArgs(
                  exchange: '${item['exch']}',
                  tSym: '${item['tsym']}',
                  isExit: false,
                  token: "${item['token']}",
                  transType: item['trantype'] == 'B' ? true : false,
                  lotSize: ref
                      .read(marketWatchProvider)
                      .scripInfoModel
                      ?.ls
                      .toString(),
                  ltp: ltp,
                  perChange: perChange,
                  orderTpye: '',
                  holdQty: '',
                  isModify: true,
                  prd: item['prd']?.toString(),
                  raw: item);

              final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
              if (scripInfo == null) {
                ResponsiveSnackBar.showError(
                    context, 'Unable to fetch scrip information');
                return;
              }

              PlaceOrderScreenWeb.showDraggable(
                context: context,
                orderArg: orderArgs,
                scripInfo: scripInfo,
                isBasket: 'BasketEdit',
              );
            },
            child: ValueListenableBuilder<String?>(
              valueListenable: _hoveredRowIndex,
              builder: (context, hoveredToken, child) {
                final rowIsHovered = hoveredToken == uniqueId;

                return Container(
                  decoration: BoxDecoration(
                    color: rowIsHovered
                        ? (theme.isDarkMode
                            ? WebDarkColors.primary.withOpacity(0.06)
                            : WebColors.primary.withOpacity(0.10))
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: needHorizontalScroll
                      ? IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: headers.map((label) {
                              final flex = columnFlex[label] ?? 1;
                              final minW = columnMinWidth[label] ?? 80.0;
                              return _buildBasketColumnCell(
                                needHorizontalScroll: needHorizontalScroll,
                                flex: flex,
                                minW: minW,
                                child: _buildBasketCellWidget(
                                  label,
                                  item,
                                  originalIndex,
                                  theme,
                                  uniqueId,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          children: headers.map((label) {
                            final flex = columnFlex[label] ?? 1;
                            final minW = columnMinWidth[label] ?? 80.0;
                            return _buildBasketColumnCell(
                              needHorizontalScroll: needHorizontalScroll,
                              flex: flex,
                              minW: minW,
                              child: _buildBasketCellWidget(
                                label,
                                item,
                                originalIndex,
                                theme,
                                uniqueId,
                              ),
                            );
                          }).toList(),
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasketCellWidget(
    String column,
    Map<String, dynamic> item,
    int originalIndex,
    ThemesProvider theme,
    String uniqueId,
  ) {
    switch (column) {
      case 'Instrument':
        return _BasketInstrumentCell(
          item: item,
          originalIndex: originalIndex,
          theme: theme,
          uniqueId: uniqueId,
          hoveredRowIndex: _hoveredRowIndex,
          onDelete: (item, index, theme) =>
              _handleDeleteBasketScript(item, index, theme),
        );
      case 'Buy/Sell':
        final trantype = item["trantype"]?.toString();
        final buySell = trantype == "S" ? "SELL" : "BUY";
        final textColor = trantype == "S"
            ? (theme.isDarkMode ? WebDarkColors.error : WebColors.error)
            : (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary);
        return _buildBasketTextCell(
          buySell,
          theme,
          Alignment.centerLeft,
          color: textColor,
        );
      case 'Product':
        // Map prd to user friendly text
        String product = "Intraday"; // Default
        switch (item["prd"]) {
          case "I":
            product = "Intraday";
            break;
          case "C":
            product = "Delivery";
            break;
          case "M":
            product = "Margin";
            break;
          case "F":
            product = "MTF";
            break;
        }
        return _buildBasketTextCell(
          product,
          theme,
          Alignment.centerLeft,
        );
      case 'Price type':
        // Map prcType to user friendly text if needed, or use as is
        String priceType = item["prctype"] ?? "LMT";
        if (priceType == "LMT") priceType = "LMT";
        if (priceType == "MKT") priceType = "MKT";
        if (priceType == "SL-LMT") priceType = "SL-LMT";
        if (priceType == "SL-MKT") priceType = "SL-MKT";
        return _buildBasketTextCell(
          priceType,
          theme,
          Alignment.centerLeft,
        );
      case 'Qty':
        final qty = item["qty"]?.toString() ?? '0';
        return _buildBasketTextCell(
          qty,
          theme,
          Alignment.centerRight,
        );
      case 'Price':
        return _buildBasketTextCell(
          item["prc"]?.toString() ?? '0.00',
          theme,
          Alignment.centerRight,
        );
      case 'Actions':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Copy (Placeholder)
            // Copy
            _buildBasketHoverButton(
              icon: Icons.copy,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
              onPressed: () async {
                await ref.read(marketWatchProvider).fetchScripInfo(
                    "${item['token']}", '${item['exch']}', context, true);

                if (!context.mounted) return;

                final ltp = item['lp']?.toString() ?? "0.00";
                final perChange = item['pc']?.toString() ?? "0.00";

                OrderScreenArgs orderArgs = OrderScreenArgs(
                    exchange: '${item['exch']}',
                    tSym: '${item['tsym']}',
                    isExit: false,
                    token: "${item['token']}",
                    transType: item['trantype'] == 'B',
                    lotSize: ref
                        .read(marketWatchProvider)
                        .scripInfoModel
                        ?.ls
                        .toString(),
                    ltp: ltp,
                    perChange: perChange,
                    orderTpye: '',
                    holdQty: '',
                    isModify: false, // Copy as new order
                    prd: item['prd']?.toString(),
                    raw: item);

                final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
                if (scripInfo == null) {
                  ResponsiveSnackBar.showError(
                      context, 'Unable to fetch scrip information');
                  return;
                }

                PlaceOrderScreenWeb.showDraggable(
                  context: context,
                  orderArg: orderArgs,
                  scripInfo: scripInfo,
                  isBasket: 'Basket', // Add to basket
                );
              },
              theme: theme,
            ),
            const SizedBox(width: 8),
            // Edit
            _buildBasketHoverButton(
              icon: Icons.edit,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
              onPressed: () async {
                // Trigger edit mode
                // Same as row tap logic - reusing edit handler
                await ref.read(marketWatchProvider).fetchScripInfo(
                    "${item['token']}", '${item['exch']}', context, true);

                if (!context.mounted) return;

                final basket = ref.read(orderProvider);
                basket.bsktScripList[originalIndex]['index'] = originalIndex;
                basket.bsktScripList[originalIndex]['prctyp'] =
                    basket.bsktScripList[originalIndex]['prctype'];

                final ltp = item['lp']?.toString() ?? "0.00";
                final perChange = item['pc']?.toString() ?? "0.00";

                OrderScreenArgs orderArgs = OrderScreenArgs(
                    exchange: '${item['exch']}',
                    tSym: '${item['tsym']}',
                    isExit: false,
                    token: "${item['token']}",
                    transType: item['trantype'] == 'B' ? true : false,
                    lotSize: ref
                        .read(marketWatchProvider)
                        .scripInfoModel
                        ?.ls
                        .toString(),
                    ltp: ltp,
                    perChange: perChange,
                    orderTpye: '',
                    holdQty: '',
                    isModify: true,
                    prd: item['prd']?.toString(),
                    raw: item);

                final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
                if (scripInfo == null) {
                  ResponsiveSnackBar.showError(
                      context, 'Unable to fetch scrip information');
                  return;
                }

                PlaceOrderScreenWeb.showDraggable(
                  context: context,
                  orderArg: orderArgs,
                  scripInfo: scripInfo,
                  isBasket: 'BasketEdit',
                );
              },
              theme: theme,
            ),
            const SizedBox(width: 8),
            // Delete
            _buildBasketHoverButton(
              icon: Icons.delete_outline,
              color: theme.isDarkMode
                  ? WebDarkColors.tertiary
                  : WebColors.tertiary,
              onPressed: () => _handleDeleteBasketScript(
                {'_originalIndex': originalIndex, ...item},
                originalIndex,
                theme,
              ),
              theme: theme,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasketTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Text(
          text,
          style: WebTextStyles.custom(
            fontSize: 13,
            isDarkTheme: theme.isDarkMode,
            color: color ??
                (theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary),
            fontWeight: WebFonts.medium,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBasketHoverButton({
    String? label,
    IconData? icon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      height: 28,
      width: label == null && icon != null ? 28 : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: 16,
                      color: color,
                    )
                  : Text(
                      label ?? "",
                      style: WebTextStyles.custom(
                        fontSize: 11,
                        isDarkTheme: theme.isDarkMode,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteBasketScript(
      Map<String, dynamic> item, int index, ThemesProvider theme) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: colors.colorBlack, light: colors.colorWhite),
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            padding: const EdgeInsets.all(24), // Consistent padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button (Top Right)
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(false),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: resolveThemeColor(context,
                            dark: styles.MyntColors.textSecondaryDark,
                            light: styles.MyntColors.textSecondary),
                      ),
                    ),
                  ),
                ),

                // Text Content
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Are you sure you want to \ndelete this ',
                    style: MyntWebTextStyles.title(
                      context,
                      color: resolveThemeColor(context,
                          dark: styles.MyntColors.textPrimaryDark,
                          light: styles.MyntColors.textPrimary),
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: 'basket Script ',
                        style: MyntWebTextStyles.title(
                          context,
                        ).copyWith(
                          fontWeight: FontWeight.w400, // Regular
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: '"${item['symbol']?.replaceAll("-EQ", "")}"?',
                        style: MyntWebTextStyles.title(
                          context,
                        ).copyWith(
                          fontWeight: FontWeight.w700, // Bold
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Button
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48, // Slightly taller button
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7), // Primary Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: MyntWebTextStyles.buttonMd(
                        context,
                        color: Colors.white,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete == true && mounted) {
      final basket = ref.read(orderProvider);
      await basket.removeBsktScrip(
          index,
          basket.selectedBsktName.isEmpty
              ? widget.bsktName
              : basket.selectedBsktName);
      await basket.fetchBasketMargin();
    }
  }

  Future<void> _handleDeleteBasket(ThemesProvider theme) async {
    final basketProvider = ref.read(orderProvider);
    final bsktName = basketProvider.selectedBsktName.isEmpty
        ? widget.bsktName
        : basketProvider.selectedBsktName;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: colors.colorBlack, light: colors.colorWhite),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(false),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: resolveThemeColor(context,
                            dark: styles.MyntColors.textSecondaryDark,
                            light: styles.MyntColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Are you sure you want to \ndelete this ',
                    style: MyntWebTextStyles.title(
                      context,
                      color: resolveThemeColor(context,
                          dark: styles.MyntColors.textPrimaryDark,
                          light: styles.MyntColors.textPrimary),
                    ).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: 'basket',
                        style: MyntWebTextStyles.title(
                          context,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: ' ${bsktName.toUpperCase()}?',
                        style: MyntWebTextStyles.title(
                          context,
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0037B7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: MyntWebTextStyles.buttonMd(
                        context,
                        color: Colors.white,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete == true) {
      // Find index of basket
      final index = basketProvider.bsktList
          .indexWhere((element) => element['bsketName'].toString() == bsktName);
      if (index != -1) {
        await basketProvider.removeBasket(index);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }
}

// Isolated widget for Basket Instrument Cell with real-time LTP
class _BasketInstrumentCell extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  final int originalIndex;
  final ThemesProvider theme;
  final String uniqueId;
  final ValueNotifier<String?> hoveredRowIndex;
  final Function(Map<String, dynamic>, int, ThemesProvider) onDelete;

  const _BasketInstrumentCell({
    required this.item,
    required this.originalIndex,
    required this.theme,
    required this.uniqueId,
    required this.hoveredRowIndex,
    required this.onDelete,
  });

  @override
  ConsumerState<_BasketInstrumentCell> createState() =>
      _BasketInstrumentCellState();
}

class _BasketInstrumentCellState extends ConsumerState<_BasketInstrumentCell> {
  late String ltp;
  late String pc;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _updateValues();

    final token = widget.item['token']?.toString();
    if (token != null) {
      _subscription =
          ref.read(websocketProvider).socketDataStream.listen((data) {
        if (!mounted || !data.containsKey(token)) return;

        bool changed = false;
        final newLtp = data[token]['lp']?.toString();
        if (newLtp != null && newLtp != ltp && newLtp != 'null') {
          ltp = newLtp;
          // Update model for sorting consistency
          widget.item['lp'] = newLtp;
          changed = true;
        }

        final newPc = data[token]['pc']?.toString();
        if (newPc != null && newPc != pc && newPc != 'null') {
          pc = newPc;
          // Update model for consistency
          widget.item['pc'] = newPc;
          changed = true;
        }

        if (changed) {
          setState(() {});
        }
      });
    }
  }

  @override
  void didUpdateWidget(_BasketInstrumentCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      _updateValues();
    }
  }

  void _updateValues() {
    ltp = widget.item['lp']?.toString() ?? '0.00';
    pc = widget.item['pc']?.toString() ?? '0.00%';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol =
        widget.item['symbol']?.toString() ?? widget.item['tsym'] ?? '';
    final exch = widget.item['exch']?.toString() ?? '';
    final isPositive = !pc.toString().startsWith('-');

    return ValueListenableBuilder<String?>(
      valueListenable: widget.hoveredRowIndex,
      builder: (context, hoveredToken, child) {
        final rowIsHovered = hoveredToken == widget.uniqueId;

        return ClipRect(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Content (Symbol + LTP)
              Flexible(
                flex: rowIsHovered ? 1 : 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Symbol Row
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              symbol,
                              style: WebTextStyles.custom(
                                fontSize: 13,
                                isDarkTheme: widget.theme.isDarkMode,
                                color: widget.theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                                fontWeight: WebFonts.medium,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: widget.theme.isDarkMode
                                          ? WebDarkColors.divider
                                          : WebColors.divider,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(2)),
                              child: Text(exch,
                                  style: WebTextStyles.custom(
                                      fontSize: 9,
                                      isDarkTheme: widget.theme.isDarkMode,
                                      color: widget.theme.isDarkMode
                                          ? WebDarkColors.textSecondary
                                          : WebColors.textSecondary,
                                      fontWeight: WebFonts.regular)))
                        ],
                      ),
                      const SizedBox(height: 2),
                      // LTP + Change Row
                      Row(children: [
                        Text(
                          "₹$ltp",
                          style: WebTextStyles.custom(
                            fontSize: 11,
                            isDarkTheme: widget.theme.isDarkMode,
                            color: widget.theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary,
                            fontWeight: WebFonts.regular,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${isPositive ? '+' : ''}$pc",
                          style: WebTextStyles.custom(
                            fontSize: 11,
                            isDarkTheme: widget.theme.isDarkMode,
                            color: isPositive
                                ? (widget.theme.isDarkMode
                                    ? WebDarkColors.profit
                                    : WebColors.profit)
                                : (widget.theme.isDarkMode
                                    ? WebDarkColors.loss
                                    : WebColors.loss),
                            fontWeight: WebFonts.regular,
                          ),
                        ),
                      ])
                    ],
                  ),
                ),
              ),
              // Delete button fade in on hover (or reuse existing helper if accessible, else implementing inline for isolation)
              if (rowIsHovered)
                // Use a fade transition for smoother effect
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 140),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      height: 28,
                      width: 28,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          splashColor: (widget.theme.isDarkMode
                                  ? WebDarkColors.tertiary
                                  : WebColors.tertiary)
                              .withOpacity(0.15),
                          highlightColor: (widget.theme.isDarkMode
                                  ? WebDarkColors.tertiary
                                  : WebColors.tertiary)
                              .withOpacity(0.08),
                          onTap: () => widget.onDelete(
                              widget.item, widget.originalIndex, widget.theme),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: widget.theme.isDarkMode
                                    ? WebDarkColors.tertiary
                                    : WebColors.tertiary,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: widget.theme.isDarkMode
                                    ? WebDarkColors.tertiary
                                    : WebColors.tertiary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

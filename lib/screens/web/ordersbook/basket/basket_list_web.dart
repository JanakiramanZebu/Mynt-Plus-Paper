import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../utils/responsive_snackbar.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'create_basket_web.dart';
import '../../../web/market_watch/search_dialog_web.dart';
import '../../../web/order/place_order_screen_web.dart';

class BasketList extends ConsumerStatefulWidget {
  const BasketList({super.key});

  @override
  ConsumerState<BasketList> createState() => _BasketListState();
}

class _BasketListState extends ConsumerState<BasketList> {
  String? _hoveredRowIndex;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final ScrollController _verticalScrollController = ScrollController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
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
          comparison = ((a as Map)['bsketName'] ?? '').toString().compareTo(((b as Map)['bsketName'] ?? '').toString());
          break;
        case 1: // Created Date
          comparison = ((a as Map)['createdDate'] ?? '').toString().compareTo(((b as Map)['createdDate'] ?? '').toString());
          break;
        case 2: // Items
          final aItems = int.tryParse(((a as Map)['curLength'] ?? 0).toString()) ?? 0;
          final bItems = int.tryParse(((b as Map)['curLength'] ?? 0).toString()) ?? 0;
          comparison = aItems.compareTo(bItems);
          break;
      }
      return asc ? comparison : -comparison;
    });
    return sorted;
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _sortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 20,
          height: 16,
          child: !isSorted 
              ? Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: theme.isDarkMode ? WebDarkColors.iconSecondary : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  DataCell _buildBasketNameCellWithHover(Map<String, dynamic> basket, int index, ThemesProvider theme, String token) {
    final bsktName = basket['bsketName'] ?? '';
    final isHovered = _hoveredRowIndex == token;

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowIndex = token),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: SizedBox.expand(
          child: Row(
            children: [
              // Text that takes at least 50% of width, leaves space for buttons
              Expanded(
                flex: isHovered ? 1 : 2, // When hovered, text takes less space but still visible
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: bsktName,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          assets.basketdashboard,
                          width: 18,
                          height: 18,
                          color: theme.isDarkMode
                              ? WebDarkColors.iconSecondary
                              : WebColors.iconSecondary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            bsktName,
                            style: WebTextStyles.tableDataCompact(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Buttons on the right side - fade in/out
              IgnorePointer(
                ignoring: !isHovered,
                child: AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHoverButton(
                        label: 'Delete',
                        color: Colors.white,
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.error
                            : WebColors.error,
                        onPressed: () => _handleDeleteBasket(context, basket, index),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildCellWithHover(Map<String, dynamic> basket, int index, DataCell cell, {Alignment alignment = Alignment.centerLeft}) {
    final uniqueId = '$index';
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowIndex = uniqueId),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment,
            child: cell.child,
          ),
        ),
      ),
    );
  }

  Widget _buildHoverButton({
    String? label,
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
              child: Text(
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

  Future<void> _handleDeleteBasket(BuildContext context, Map<String, dynamic> basket, int index) async {
    final bsktName = basket['bsketName'] ?? '';
    final basketProvider = ref.read(orderProvider);
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = ref.read(themeProvider);
        return Dialog(
          backgroundColor: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete Basket',
                        style: WebTextStyles.dialogTitle(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.15)
                              : Colors.black.withOpacity(.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(.08)
                              : Colors.black.withOpacity(.08),
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: theme.isDarkMode
                                  ? WebDarkColors.iconSecondary
                                  : WebColors.iconSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Are you sure you want to delete this basket ${bsktName.toString().toUpperCase()}?',
                              textAlign: TextAlign.center,
                              style: WebTextStyles.dialogContent(
                                isDarkTheme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? WebDarkColors.textPrimary
                                    : WebColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? WebDarkColors.error
                                  : WebColors.error,
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
                                onTap: () => Navigator.of(dialogContext).pop(true),
                                child: Center(
                                  child: _isDeleting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Delete',
                                          style: WebTextStyles.buttonMd(
                                            isDarkTheme: theme.isDarkMode,
                                            color: Colors.white,
                                          ),
                                        ),
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

  Future<void> _handleBasketTap(BuildContext context, Map<String, dynamic> basket) async {
    final bsktName = basket['bsketName'] ?? '';
    final basketProvider = ref.read(orderProvider);
    
    await basketProvider.fetchBasketMargin();
    await basketProvider.chngBsktName(bsktName, context, true);
    
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.3,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  color: ref.read(themeProvider).isDarkMode
                      ? WebDarkColors.surface
                      : WebColors.surface,
                  borderRadius: BorderRadius.circular(5),
                ),
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
    final basket = ref.watch(orderProvider);
    final theme = ref.watch(themeProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.primary
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
                                  ? WebDarkColors.surface
                                  : WebColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                width: 400,
                                child: const CreateBasket(),
                              ),
                            );
                          },
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            ? const SizedBox(
                height: 400, child: Center(child: CircularProgressIndicator()))
            : basket.bsktList.isEmpty
                ? const SizedBox(height: 400, child: NoDataFound())
                : Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          radius: Radius.zero,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DataTable(
                                    columnSpacing: 15,
                                    showCheckboxColumn: false,
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    headingRowHeight: 44,
                                    headingRowColor: WidgetStateProperty.all(Colors.transparent),
                                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                      (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.hovered)) {
                                          return (theme.isDarkMode
                                                  ? WebDarkColors.primary
                                                  : WebColors.primary)
                                              .withOpacity(0.15);
                                        }
                                        if (states.contains(WidgetState.selected)) {
                                          return (theme.isDarkMode
                                                  ? WebDarkColors.primary
                                                  : WebColors.primary)
                                              .withOpacity(0.1);
                                        }
                                        return null;
                                      },
                                    ),
                                    columns: [
                                      DataColumn(
                                        numeric: false,
                                        label: _buildSortableColumnHeader('Basket Name', theme, 0),
                                        onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                                      ),
                                      DataColumn(
                                        numeric: false,
                                        label: _buildSortableColumnHeader('Created Date', theme, 1),
                                        onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: _buildSortableColumnHeader('Items', theme, 2),
                                        onSort: (columnIndex, ascending) => _onSortTable(columnIndex, ascending),
                                      ),
                                    ],
                                    rows: _getSortedBaskets(basket.bsktList).asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final basketItem = entry.value as Map<String, dynamic>;
                                      final uniqueId = '$index';
                                      
                                      return DataRow(
                                        onSelectChanged: (bool? selected) {
                                          _handleBasketTap(context, basketItem);
                                        },
                                        cells: [
                                          _buildBasketNameCellWithHover(basketItem, index, theme, uniqueId),
                                          _buildCellWithHover(basketItem, index, DataCell(
                                            Text(
                                              basketItem['createdDate']?.toString() ?? '',
                                              style: WebTextStyles.tableDataCompact(
                                                isDarkTheme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? WebDarkColors.textPrimary
                                                    : WebColors.textPrimary,
                                              ),
                                            ),
                                          ), alignment: Alignment.centerLeft),
                                          _buildCellWithHover(basketItem, index, DataCell(
                                            Text(
                                              (basketItem['curLength'] ?? 0).toString(),
                                              style: WebTextStyles.tableDataCompact(
                                                isDarkTheme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? WebDarkColors.textPrimary
                                                    : WebColors.textPrimary,
                                              ),
                                            ),
                                          ), alignment: Alignment.centerRight),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}

class BasketScripList extends ConsumerWidget {
  final String bsktName;
  const BasketScripList({super.key, required this.bsktName});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final basket = ref.watch(orderProvider);

    return Material(
      color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      child: Column(
        children: [
        // Custom Header with close button and title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
            children: [
              Expanded(
                child: TextWidget.titleText(
                  text:
                      "${bsktName}   (${basket.bsktScripList.length} / ${basket.frezQtyOrderSliceMaxLimit})",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),
              if (basket.bsktScripList.length < basket.frezQtyOrderSliceMaxLimit)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.6)
                        : colors.btnBg,
                    borderRadius: BorderRadius.circular(5),
                    border: theme.isDarkMode
                        ? null
                        : Border.all(
                            color: colors.btnOutlinedBorder,
                            width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const BeveledRectangleBorder(),
                    child: InkWell(
                        customBorder: const BeveledRectangleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () async {
                          // Check if basket already has frezQtyOrderSliceMaxLimit items
                          if (basket.bsktScripList.length >= basket.frezQtyOrderSliceMaxLimit) {
                            ResponsiveSnackBar.showWarning(
                              context,
                              "Basket limit reached. Please create a new basket as you are exceeding the ${basket.frezQtyOrderSliceMaxLimit} item limit.",
                            );
                            return;
                          }
    
                          await ref
                              .watch(marketWatchProvider)
                              .searchClear();
                          // Open SearchDialogWeb as dialog with basket context
                          // SearchDialogWeb already has its own backdrop and styling
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return const SearchDialogWeb(
                                wlName: "Basket",
                                isBasket: "Basket",
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: TextWidget.subText(
                              text: "Add symbol",
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.primaryLight,
                              fw: 2),
                        )),
                  ),
                ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.highlightDark
                      : colors.highlightLight,
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Margin Information Row
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                  text: "Pre Trade Margin",
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  fw: 0,
                                ),
                                const SizedBox(height: 6),
                                TextWidget.subText(
                                  text: basket.bsktScripList.isEmpty ||
                                          basket.bsktOrderMargin == null
                                      ? "0.00"
                                      : (double.parse(basket.bsktOrderMargin!.marginused ?? '0.00') - double.parse(basket.bsktOrderMargin!.marginusedprev ?? '0.00')).toStringAsFixed(2),
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                ),
                              ],
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextWidget.subText(
                                    text: "Post Trade Margin",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fw: 0,
                                  ),
                                  const SizedBox(height: 6),
                                  TextWidget.subText(
                                    text: basket.bsktScripList.isEmpty ||
                                            basket.bsktOrderMargin == null
                                        ? "0.00"
                                        : (double.parse(basket.bsktOrderMargin!.marginusedtrade ?? '0.00') - double.parse(basket.bsktOrderMargin!.marginusedprev ?? '0.00')).toStringAsFixed(2),
                                    theme: theme.isDarkMode,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 0,
                                  ),
                                ])
                          ]),
                    ])),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? colors.primaryDark.withOpacity(0.3) : colors.primaryLight.withOpacity(0.3),
                  // color: const Color(0xffe3f2fd),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
                  TextWidget.paraText(
                    text: " On Script Tap to edit / long press to delete.",
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.secondaryDark
                        : colors.secondaryLight,
                    fw: 0,
                  ),
                ])),
            Expanded(
                child: basket.bsktScripList.isEmpty
                    ? const NoDataFound()
                    : StreamBuilder<Map>(
                        stream: ref.watch(websocketProvider).socketDataStream,
                        builder: (context, snapshot) {
                          final socketDatas = snapshot.data ?? {};
              
                          // Check if we have socket data and need to update
                          if (snapshot.hasData && socketDatas.isNotEmpty) {
                            bool updated = false;
              
                            // Update basket script list with real-time values
                            for (var script in basket.bsktScripList) {
                              final token = script['token']?.toString();
                              if (token != null &&
                                  socketDatas.containsKey(token)) {
                                final lp = socketDatas[token]['lp']?.toString();
                                final pc = socketDatas[token]['pc']?.toString();
              
                                if (lp != null && lp != "null") {
                                  if (script['lp']?.toString() != lp) {
                                    script['lp'] = lp;
                                    updated = true;
                                  }
                                }
              
                                if (pc != null && pc != "null") {
                                  if (script['pc']?.toString() != pc) {
                                    script['pc'] = pc;
                                    updated = true;
                                  }
                                }
                              }
                            }
              
                            // Force a refresh if we have updates
                            if (updated) {
                              // Update in the next frame to avoid rebuild conflicts
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  // This will trigger a rebuild with the new values
                                  basket.notifyBasketUpdates();
                                }
                              });
                            }
                          }
              
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: basket.bsktScripList.length,
                            separatorBuilder: (_, __) => const ListDivider(),
                            itemBuilder: (BuildContext context, int index) {
                              if (basket.bsktScripList[index]['exch'] ==
                                      "BFO" &&
                                  basket.bsktScripList[index]["dname"] !=
                                      "null") {
                                List<String> splitVal = basket
                                    .bsktScripList[index]["dname"]
                                    .toString()
                                    .split(" ");
              
                                basket.bsktScripList[index]['symbol'] =
                                    splitVal[0];
                                basket.bsktScripList[index]['expDate'] =
                                    "${splitVal[1]} ${splitVal[2]}";
                                basket.bsktScripList[index]['option'] =
                                    splitVal.length > 4
                                        ? "${splitVal[3]} ${splitVal[4]}"
                                        : splitVal[3];
                              } else {
                                Map spilitSymbol = spilitTsym(
                                    value:
                                        "${basket.bsktScripList[index]['tsym']}");
              
                                basket.bsktScripList[index]['symbol'] =
                                    "${spilitSymbol["symbol"]}";
                                basket.bsktScripList[index]['expDate'] =
                                    "${spilitSymbol["expDate"]}";
                                basket.bsktScripList[index]['option'] =
                                    "${spilitSymbol["option"]}";
                              }
              
                              return InkWell(
                                onLongPress: () async {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor:
                                              theme.isDarkMode
                                                  ? WebDarkColors.surface
                                                  : WebColors.surface,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Container(
                                            width: 400,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: theme.isDarkMode
                                                            ? WebDarkColors.divider
                                                            : WebColors.divider,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Delete Basket Script',
                                                        style: WebTextStyles.sub(
                                                          isDarkTheme: theme.isDarkMode,
                                                          color: theme.isDarkMode
                                                              ? WebDarkColors.textPrimary
                                                              : WebColors.textPrimary,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                      Material(
                                                        color: Colors.transparent,
                                                        shape: const CircleBorder(),
                                                        child: InkWell(
                                                          customBorder: const CircleBorder(),
                                                          splashColor: theme.isDarkMode
                                                              ? Colors.white.withOpacity(.15)
                                                              : Colors.black.withOpacity(.15),
                                                          highlightColor: theme.isDarkMode
                                                              ? Colors.white.withOpacity(.08)
                                                              : Colors.black.withOpacity(.08),
                                                          onTap: () => Navigator.of(context).pop(),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(5),
                                                            child: Icon(
                                                              Icons.close,
                                                              size: 18,
                                                              color: theme.isDarkMode
                                                                  ? WebDarkColors.iconSecondary
                                                                  : WebColors.iconSecondary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                            child: Text(
                                                              'Are you sure you want to delete this basket Script "${basket.bsktScripList[index]['symbol']?.replaceAll("-EQ", "")}"?',
                                                              style: WebTextStyles.custom(
                                                                fontSize: 13,
                                                                isDarkTheme: theme.isDarkMode,
                                                                color: theme.isDarkMode
                                                                    ? WebDarkColors.textPrimary
                                                                    : WebColors.textPrimary,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 16),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        height: 40,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            await basket.removeBsktScrip(index, bsktName);
                                                            await basket.fetchBasketMargin();
                                                            if (context.mounted) {
                                                              Navigator.pop(context);
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: theme.isDarkMode
                                                                ? WebDarkColors.primary
                                                                : WebColors.primary,
                                                            minimumSize: const Size(0, 40),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Delete',
                                                            style: WebTextStyles.custom(
                                                              fontSize: 13,
                                                              isDarkTheme: theme.isDarkMode,
                                                              color: WebColors.surface,
                                                              fontWeight: FontWeight.w700,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                onTap: () async {
                                  await ref.read(marketWatchProvider).fetchScripInfo(
                                      "${basket.bsktScripList[index]['token']}",
                                      '${basket.bsktScripList[index]['exch']}',
                                      context,
                                      true);
                                  
                                  if (!context.mounted) return;
                                  
                                  basket.bsktScripList[index]['index'] = index;
                                  basket.bsktScripList[index]['prctyp'] =
                                      basket.bsktScripList[index]['prctype'];
              
                                  // Ensure lp and pc values are not null for OrderScreenArgs
                                  final ltp = basket.bsktScripList[index]['lp']
                                          ?.toString() ??
                                      "0.00";
                                  final perChange = basket.bsktScripList[index]
                                              ['pc']
                                          ?.toString() ??
                                      "0.00";
              
                                  OrderScreenArgs orderArgs = OrderScreenArgs(
                                      exchange:
                                          '${basket.bsktScripList[index]['exch']}',
                                      tSym:
                                          '${basket.bsktScripList[index]['tsym']}',
                                      isExit: false,
                                      token:
                                          "${basket.bsktScripList[index]['token']}",
                                      transType: basket.bsktScripList[index]
                                                  ['trantype'] ==
                                              'B'
                                          ? true
                                          : false,
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
                                      prd: basket.bsktScripList[index]['prd']
                                          ?.toString(),
                                      raw: basket.bsktScripList[index]);
                                  
                                  final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
                                  if (scripInfo == null) {
                                    ResponsiveSnackBar.showError(context, 'Unable to fetch scrip information');
                                    return;
                                  }
                                  
                                  // Show place order screen as draggable dialog for web
                                  PlaceOrderScreenWeb.showDraggable(
                                    context: context,
                                    orderArg: orderArgs,
                                    scripInfo: scripInfo,
                                    isBasket: 'BasketEdit',
                                  );
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(children: [
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['symbol'].replaceAll("-EQ", "")} ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      theme: theme.isDarkMode,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['expDate']} ",
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                  // const SizedBox(width: 4),
                                                  TextWidget.subText(
                                                      text:
                                                          "${basket.bsktScripList[index]['option']} ",
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0,
                                                      textOverflow: TextOverflow
                                                          .ellipsis),
                                                ]),
                                                if (basket.bsktScripList[index]
                                                        ['orderStatus'] !=
                                                    null) ...[
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _getItemStatusColor(
                                                              basket.bsktScripList[
                                                                      index][
                                                                  'orderStatus'], theme)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Icon(
                                                        //   _getItemStatusIcon(basket
                                                        //           .bsktScripList[index]
                                                        //       ['orderStatus']),
                                                        //   size: 14,
                                                        //   color: _getItemStatusColor(
                                                        //       basket.bsktScripList[
                                                        //               index]
                                                        //           ['orderStatus']),
                                                        // ),
                                                        // const SizedBox(width: 4),
                                                        TextWidget.paraText(
                                                          text: basket
                                                              .bsktScripList[
                                                                  index][
                                                                  'orderStatus']
                                                              .toString()
                                                              .toUpperCase(),
                                                          theme: false,
                                                          fw: 0,
                                                          color: _getItemStatusColor(
                                                              basket.bsktScripList[
                                                                      index][
                                                                  'orderStatus'], theme),
                                                        ),
                                                        if (basket.bsktScripList[
                                                                    index]
                                                                ['avgPrice'] !=
                                                            null) ...[
                                                          const SizedBox(
                                                              width: 8),
                                                          TextWidget
                                                              .captionText(
                                                            text:
                                                                "@ ₹${basket.bsktScripList[index]['avgPrice']}",
                                                            theme: false,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            fw: 0,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ]),
                                          const SizedBox(height: 8),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        TextWidget.paraText(
                                                          text:
                                                              "${basket.bsktScripList[index]["exch"]} - ${basket.bsktScripList[index]["ordType"]} - ${basket.bsktScripList[index]["prctype"]} - ${formatToTimeOnly(basket.bsktScripList[index]["date"])}",
                                                          theme: false,
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                              : colors
                                                                  .textSecondaryLight,
                                                          fw: 0,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    TextWidget.paraText(
                                                      text:
                                                          "LTP ${basket.bsktScripList[index]['lp']?.toString() ?? "0.00"}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                          fw: 0,
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                          const SizedBox(height: 8),
              
                                          // TextWidget.paraText(
                                          //           text:
                                          //               " (${basket.bsktScripList[index]['pc']?.toString() ?? "0.00"}%)",
                                          //           theme: false,
                                          //           color: basket.bsktScripList[
                                          //                           index]['pc']
                                          //                       ?.toString()
                                          //                       .startsWith(
                                          //                           "-") ??
                                          //                   false
                                          //               ? colors.darkred
                                          //               : basket.bsktScripList[
                                          //                               index]
                                          //                               ['pc']
                                          //                           ?.toString() ==
                                          //                       "0.00"
                                          //                   ? colors.ltpgrey
                                          //                   : colors.ltpgreen,
                                          //           fw: 0),
              
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(children: [
                                                  TextWidget.paraText(
                                                      text: basket.bsktScripList[
                                                                      index][
                                                                  "trantype"] ==
                                                              "S"
                                                          ? "SELL"
                                                          : "BUY",
                                                      theme: false,
                                                      color: basket.bsktScripList[
                                                                      index][
                                                                  "trantype"] ==
                                                              "S"
                                                          ? theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                          : theme.isDarkMode
                                                              ? colors
                                                                  .primaryDark
                                                              : colors
                                                                  .primaryLight,
                                                      fw: 0),
                                                  const SizedBox(width: 8),
                                                  TextWidget.paraText(
                                                    text:
                                                        "${basket.bsktScripList[index]["dscqty"]}/${basket.bsktScripList[index]["qty"]}",
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                      fw: 0,
                                                  )
                                                ]),
                                                Row(children: [
                                                  if (basket.bsktScripList[
                                                          index]["prctype"] !=
                                                      "MKT") ...[
                                                    TextWidget.paraText(
                                                      text:
                                                          "${basket.bsktScripList[index]['prc'] ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 0,
                                                    ),
                                                  ]
                                                ])
                                              ]),
                                          // Individual Order Status Display
                                        ])),
                              );
                            },
                          );
                        },
                      )),
          ]),
        ),
        // Bottom action bar
        if (basket.bsktScripList.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.surface
                  : WebColors.surface,
              border: Border(
                top: BorderSide(
                  color: theme.isDarkMode
                      ? WebDarkColors.divider
                      : WebColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Static error message for multiple exchanges
                if (_hasMultipleExchanges(basket.bsktScripList))
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: colors.loss,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget.paraText(
                          text:
                              "Basket should contain orders of only 1 segment",
                          theme: false,
                          color: colors.colorWhite,
                          fw: 0,
                        ),
                      ],
                    ),
                  ),
                Container(
                  height: 75,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? WebDarkColors.surface
                        : WebColors.surface,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: _hasOrdersPlacedInBasket(bsktName, basket)
                        ? OutlinedButton.icon(
                            onPressed: () {
                              basket.resetBasketOrderTracking(bsktName);
                              ResponsiveSnackBar.showSuccess(
                                  context, "Basket reset. You can place orders again.");
                            },
                            label: TextWidget.subText(
                              text: "Reset Orders",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.primaryLight,
                              fw: 2,
                            ),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 45),
                                side: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.colorGrey
                                      : colors.primaryLight,
                                ),
                                backgroundColor: theme.isDarkMode
                                    ? colors.textSecondaryDark.withOpacity(0.6)
                                    : colors.btnBg,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5)))),
                          )
                        : OutlinedButton.icon(
                            onPressed:
                                _hasMultipleExchanges(basket.bsktScripList)
                                    ? () {}
                                    : () async {
                                        await basket.placeBasketOrder(
                                            context,
                                            navigateToOrderBook: false);
                                      },
                            label: TextWidget.subText(
                              text: "Place Order",
                              theme: false,
                              color: _hasMultipleExchanges(
                                      basket.bsktScripList)
                                  ? colors.colorWhite.withOpacity(0.3)
                                  : colors.colorWhite,
                              fw: 2,
                            ),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                minimumSize: const Size(0, 45),
                                backgroundColor: _hasMultipleExchanges(
                                        basket.bsktScripList)
                                    ? (theme.isDarkMode
                                        ? colors.textSecondaryDark.withOpacity(0.3)
                                        : colors.textSecondaryLight.withOpacity(0.3))
                                    : (theme.isDarkMode
                                        ? colors.primaryDark
                                        : colors.primaryLight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                          ),
                  ),
                ),
              ],
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
  Color _getItemStatusColor(String status, theme) {
    switch (status.toLowerCase()) {
      case 'placed':
        return  theme.isDarkMode ? colors.primaryDark : colors.primaryLight;
      case 'complete':
        return  theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return  theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return  theme.isDarkMode ? colors.pending : colors.pending;
      default:
        return  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  IconData _getItemStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Icons.send;
      case 'complete':
        return Icons.check_circle;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return Icons.cancel;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return Icons.schedule;
      default:
        return Icons.info_outline;
    }
  }
}

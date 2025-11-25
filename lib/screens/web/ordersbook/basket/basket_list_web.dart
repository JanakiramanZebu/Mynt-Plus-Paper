import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../sharedWidget/no_data_found_web.dart';
import 'create_basket_web.dart';
// import '../../../web/market_watch/search_dialog_web.dart'; // Commented out - search bar integrated
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

  Widget _buildSortableColumnHeader(
      String label, ThemesProvider theme, int columnIndex) {
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
                  color: theme.isDarkMode
                      ? WebDarkColors.iconSecondary
                      : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  DataCell _buildBasketNameCellWithHover(Map<String, dynamic> basket, int index,
      ThemesProvider theme, String token) {
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
                flex: isHovered
                    ? 1
                    : 2, // When hovered, text takes less space but still visible
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
                            ? WebDarkColors.tertiary
                            : WebColors.tertiary,
                        onPressed: () =>
                            _handleDeleteBasket(context, basket, index),
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

  DataCell _buildCellWithHover(
      Map<String, dynamic> basket, int index, DataCell cell,
      {Alignment alignment = Alignment.centerLeft}) {
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

  Widget _buildBasketTable(ThemesProvider theme, List<dynamic> baskets) {
    final sortedBaskets = _getSortedBaskets(baskets);
    final headers = ['Basket Name', 'Items', 'Created Date'];
    final columnFlex = {'Basket Name': 3, 'Items': 1, 'Created Date': 2};
    final columnMinWidth = {'Basket Name': 200.0, 'Items': 80.0, 'Created Date': 180.0};

    final tableColumn = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.isDarkMode
              ? WebDarkColors.divider
              : WebColors.divider,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
        color: theme.isDarkMode
            ? WebDarkColors.background
            : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Sticky header (fixed) ---
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.primary
                  : WebColors.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: theme.isDarkMode
                      ? WebDarkColors.divider
                      : WebColors.divider,
                  width: 1,
                ),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: headers.asMap().entries.map((entry) {
                final index = entry.key;
                final label = entry.value;
                final flex = columnFlex[label] ?? 1;
                final minW = columnMinWidth[label] ?? 80.0;

                return Expanded(
                  flex: flex,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minW),
                    child: InkWell(
                      onTap: () => _onSortTable(index, !_sortAscending),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6),
                              child: _buildSortableColumnHeader(label, theme, index),
                            ),
                          ),
                          if (_sortColumnIndex == index)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Icon(
                                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 16,
                                color: theme.isDarkMode
                                    ? WebDarkColors.iconPrimary
                                    : WebColors.iconPrimary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // --- Scrollable body (vertical) ---
          Expanded(
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              radius: Radius.zero,
              child: _buildBasketBodyList(theme, sortedBaskets, headers, columnFlex, columnMinWidth),
            ),
          ),
        ],
      ),
    );

    return tableColumn;
  }

  Widget _buildBasketBodyList(
    ThemesProvider theme,
    List<dynamic> baskets,
    List<String> headers,
    Map<String, int> columnFlex,
    Map<String, double> columnMinWidth,
  ) {
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: baskets.length,
      itemBuilder: (context, index) {
        final basketItem = baskets[index] as Map<String, dynamic>;
        final uniqueId = '$index';
        final isHovered = _hoveredRowIndex == uniqueId;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowIndex = uniqueId),
          onExit: (_) => setState(() => _hoveredRowIndex = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleBasketTap(context, basketItem),
            child: Container(
              decoration: BoxDecoration(
                color: isHovered
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Basket Name
                  Expanded(
                    flex: columnFlex['Basket Name'] ?? 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: columnMinWidth['Basket Name'] ?? 200.0),
                      child: _buildBasketNameWidget(basketItem, index, theme, uniqueId, isHovered),
                    ),
                  ),
                  // Items
                  Expanded(
                    flex: columnFlex['Items'] ?? 1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: columnMinWidth['Items'] ?? 80.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                          child: Text(
                            (basketItem['curLength'] ?? 0).toString(),
                            style: WebTextStyles.tableDataCompact(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textPrimary
                                  : WebColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Created Date
                  Expanded(
                    flex: columnFlex['Created Date'] ?? 2,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: columnMinWidth['Created Date'] ?? 180.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                          child: Text(
                            basketItem['createdDate']?.toString() ?? '',
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasketNameWidget(
    Map<String, dynamic> basket,
    int index,
    ThemesProvider theme,
    String token,
    bool isHovered,
  ) {
    final bsktName = basket['bsketName'] ?? '';

    return Row(
      children: [
        Expanded(
          flex: isHovered ? 1 : 2,
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
                      ? WebDarkColors.tertiary
                      : WebColors.tertiary,
                  onPressed: () => _handleDeleteBasket(context, basket, index),
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
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

  Future<void> _handleDeleteBasket(
      BuildContext context, Map<String, dynamic> basket, int index) async {
    final bsktName = basket['bsketName'] ?? '';
    final basketProvider = ref.read(orderProvider);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = ref.read(themeProvider);
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 20, left: 20, right: 20),
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
                                onTap: () =>
                                    Navigator.of(dialogContext).pop(true),
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

  Future<void> _handleBasketTap(
      BuildContext context, Map<String, dynamic> basket) async {
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
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: ref.read(themeProvider).isDarkMode
                      ? WebDarkColors.surface
                      : WebColors.surface,
                  borderRadius: BorderRadius.circular(8),
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
            ? const SizedBox(
                height: 400, child: Center(child: CircularProgressIndicator()))
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
                            child: _buildBasketTable(theme, basket.bsktList),
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
  int _tabCount = 5; // For basket mode
  final Map<int, bool> _hoveredItems = {}; // For Buy/Sell button hover
  String? _hoveredRowIndex;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  
  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _tabCount, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _searchValue.isNotEmpty) {
        final marketWatch = ref.read(marketWatchProvider);
        marketWatch.searchClear();
        marketWatch.scripSearch(
            _searchValue, context, _tabController.index, "Basket");
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabScrollController.dispose();
    _searchScrollController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to get responsive column configuration for Basket Items
  Map<String, dynamic> _getResponsiveBasketItemsColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Instrument', 'Type', 'Qty', 'Price', 'Status'],
        'columnFlex': {
          'Instrument': 3,
          'Type': 2,
          'Qty': 1,
          'Price': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Instrument': 150,
          'Type': 70,
          'Qty': 60,
          'Price': 85,
          'Status': 90,
        },
      };
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: Show most columns
      return {
        'headers': ['Instrument', 'Type', 'Qty', 'Price', 'LTP', 'Status'],
        'columnFlex': {
          'Instrument': 3,
          'Type': 2,
          'Qty': 1,
          'Price': 2,
          'LTP': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Instrument': 160,
          'Type': 75,
          'Qty': 65,
          'Price': 90,
          'LTP': 90,
          'Status': 100,
        },
      };
    } else {
      // Desktop: Full columns with optimal widths
      return {
        'headers': ['Instrument', 'Details', 'Type', 'Qty', 'Price', 'LTP', 'Status'],
        'columnFlex': {
          'Instrument': 3,
          'Details': 3,
          'Type': 2,
          'Qty': 1,
          'Price': 2,
          'LTP': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Instrument': 170,
          'Details': 200,
          'Type': 80,
          'Qty': 68,
          'Price': 95,
          'LTP': 95,
          'Status': 110,
        },
      };
    }
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
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
          final aSymbol =
              '${a['symbol'] ?? ''} ${a['expDate'] ?? ''} ${a['option'] ?? ''}';
          final bSymbol =
              '${b['symbol'] ?? ''} ${b['expDate'] ?? ''} ${b['option'] ?? ''}';
          r = cmp<String>(aSymbol, bSymbol);
          break;
        case 1: // Details
          final aDetails =
              "${a["exch"]} - ${a["ordType"]} - ${a["prctype"]} - ${formatToTimeOnly(a["date"] ?? "")}";
          final bDetails =
              "${b["exch"]} - ${b["ordType"]} - ${b["prctype"]} - ${formatToTimeOnly(b["date"] ?? "")}";
          r = cmp<String>(aDetails, bDetails);
          break;
        case 2: // Type
          r = cmp<String>(a["trantype"]?.toString(), b["trantype"]?.toString());
          break;
        case 3: // Qty
          final aQty = int.tryParse(a["qty"]?.toString() ?? "0") ?? 0;
          final bQty = int.tryParse(b["qty"]?.toString() ?? "0") ?? 0;
          r = aQty.compareTo(bQty);
          break;
        case 4: // Price
          final aPrice = parseNum(a["prc"]?.toString());
          final bPrice = parseNum(b["prc"]?.toString());
          r = cmp<num>(aPrice, bPrice);
          break;
        case 5: // LTP
          final aLtp = parseNum(a["lp"]?.toString());
          final bLtp = parseNum(b["lp"]?.toString());
          r = cmp<num>(aLtp, bLtp);
          break;
        case 6: // Status
          r = cmp<String>(
              a["orderStatus"]?.toString(), b["orderStatus"]?.toString());
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  Widget _buildSortableColumnHeader(
      String label, ThemesProvider theme, int columnIndex) {
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
                  color: theme.isDarkMode
                      ? WebDarkColors.iconSecondary
                      : WebColors.iconSecondary,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
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

  Widget _buildSearchTabs(WidgetRef ref, ThemesProvider theme) {
    final searchTabList =
        ref.read(marketWatchProvider).searchTabList.sublist(0, _tabCount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int index = 0; index < searchTabList.length; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildSearchTab(
                      searchTabList[index].text ?? '',
                      index,
                      _tabController.index == index,
                      theme,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab(
    String title,
    int index,
    bool isSelected,
    ThemesProvider theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          if (_tabController.index != index) {
            _tabController.animateTo(index);
            if (_searchValue.isNotEmpty) {
              final marketWatch = ref.read(marketWatchProvider);
              marketWatch.searchClear();
              marketWatch.scripSearch(_searchValue, context, index, "Basket");
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : (theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface),
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(WidgetRef ref, ThemesProvider theme) {
    final searchScrip = ref.watch(marketWatchProvider);

    if (searchScrip.allSearchScrip?.isEmpty ?? true) {
      return Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
        ),
        child: const Center(
          child: NoDataFoundWeb(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      ),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: RawScrollbar(
          controller: _searchScrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(0),
          thumbColor: theme.isDarkMode
              ? WebDarkColors.textSecondary.withOpacity(0.5)
              : WebColors.textSecondary.withOpacity(0.5),
          child: ListView.separated(
            controller: _searchScrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: searchScrip.allSearchScrip!.length,
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color:
                  theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
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
                                            ? WebDarkColors.textPrimary
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
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
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
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
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

    return Material(
      color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
      child: Stack(
        children: [
          // Base Content (Header, Search Bar, Margin Info, Basket Items)
          Column(
            children: [
              // Custom Header with close button and title
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.surface
                      : WebColors.surface,
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
                            "${widget.bsktName}   (${basket.bsktScripList.length} / ${basket.frezQtyOrderSliceMaxLimit})",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 1,
                      ),
                    ),
                    // Commented out Add symbol button - search bar will be added below
                    // if (basket.bsktScripList.length < basket.frezQtyOrderSliceMaxLimit)
                    //   Container(
                    //     margin: const EdgeInsets.only(right: 8),
                    //     decoration: BoxDecoration(
                    //       color: theme.isDarkMode
                    //           ? colors.textSecondaryDark.withOpacity(0.6)
                    //           : colors.btnBg,
                    //       borderRadius: BorderRadius.circular(5),
                    //       border: theme.isDarkMode
                    //           ? null
                    //           : Border.all(
                    //               color: colors.btnOutlinedBorder,
                    //               width: 1),
                    //     ),
                    //     child: Material(
                    //       color: Colors.transparent,
                    //       shape: const BeveledRectangleBorder(),
                    //       child: InkWell(
                    //           customBorder: const BeveledRectangleBorder(),
                    //           splashColor: theme.isDarkMode
                    //               ? colors.splashColorDark
                    //               : colors.splashColorLight,
                    //           highlightColor: theme.isDarkMode
                    //               ? colors.highlightDark
                    //               : colors.highlightLight,
                    //           onTap: () async {
                    //             // Check if basket already has frezQtyOrderSliceMaxLimit items
                    //             if (basket.bsktScripList.length >= basket.frezQtyOrderSliceMaxLimit) {
                    //               ResponsiveSnackBar.showWarning(
                    //                 context,
                    //                 "Basket limit reached. Please create a new basket as you are exceeding the ${basket.frezQtyOrderSliceMaxLimit} item limit.",
                    //               );
                    //               return;
                    //             }

                    //             await ref
                    //                 .watch(marketWatchProvider)
                    //                 .searchClear();
                    //             // Open SearchDialogWeb as dialog with basket context
                    //             // SearchDialogWeb already has its own backdrop and styling
                    //             showDialog(
                    //               context: context,
                    //               barrierDismissible: true,
                    //               barrierColor: Colors.transparent,
                    //               builder: (BuildContext context) {
                    //                 return const SearchDialogWeb(
                    //                   wlName: "Basket",
                    //                   isBasket: "Basket",
                    //                 );
                    //               },
                    //             );
                    //           },
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(
                    //                 horizontal: 12, vertical: 8),
                    //             child: TextWidget.subText(
                    //                 text: "Add symbol",
                    //                 theme: theme.isDarkMode,
                    //                 color: theme.isDarkMode
                    //                     ? colors.colorWhite
                    //                     : colors.primaryLight,
                    //                 fw: 2),
                    //           )),
                    //     ),
                    //   ),
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
              // Search Bar Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.surface
                      : WebColors.surface,
                  // border: Border(
                  //   bottom: BorderSide(
                  //     color: theme.isDarkMode
                  //         ? WebDarkColors.divider
                  //         : WebColors.divider,
                  //     width: 1,
                  //   ),
                  // ),
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: theme.isDarkMode
                          ? WebDarkColors.inputBorder
                          : WebColors.inputBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        assets.searchIcon,
                        width: 16,
                        height: 16,
                        color: theme.isDarkMode
                            ? WebDarkColors.iconSecondary
                            : WebColors.iconSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          style: WebTextStyles.formInput(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp('[π£•₹€℅™∆√¶/.,]'))
                          ],
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Search and add instruments",
                            hintStyle: WebTextStyles.formInput(
                              isDarkTheme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? WebDarkColors.textSecondary
                                  : WebColors.textSecondary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 12),
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
                      // Clear search text icon
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, child) {
                          if (value.text.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  hoverColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  splashColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchValue = "";
                                    });
                                    ref.read(marketWatchProvider).searchClear();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.isDarkMode
                                            ? WebDarkColors.inputBorder
                                            : WebColors.inputBorder,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.iconSecondary
                                          : WebColors.iconSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Content Area (Basket Items and Margin Info) - Always visible
              Expanded(
                child: Column(children: [
                  Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.textSecondary.withOpacity(0.1)
                            : WebColors.textSecondary.withOpacity(0.1),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Margin Information Row
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            : (double.parse(basket
                                                            .bsktOrderMargin!
                                                            .marginused ??
                                                        '0.00') -
                                                    double.parse(basket
                                                            .bsktOrderMargin!
                                                            .marginusedprev ??
                                                        '0.00'))
                                                .toStringAsFixed(2),
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        theme: theme.isDarkMode,
                                        fw: 0,
                                      ),
                                    ],
                                  ),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                              : (double.parse(basket
                                                              .bsktOrderMargin!
                                                              .marginusedtrade ??
                                                          '0.00') -
                                                      double.parse(basket
                                                              .bsktOrderMargin!
                                                              .marginusedprev ??
                                                          '0.00'))
                                                  .toStringAsFixed(2),
                                          theme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          fw: 0,
                                        ),
                                      ])
                                ]),
                          ])),
                  // Container(
                  //     padding: const EdgeInsets.symmetric(vertical: 6),
                  //     decoration: BoxDecoration(
                  //       color: theme.isDarkMode
                  //           ? colors.primaryDark.withOpacity(0.3)
                  //           : colors.primaryLight.withOpacity(0.3),
                  //       // color: const Color(0xffe3f2fd),
                  //     ),
                  //     child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
                  //           TextWidget.paraText(
                  //             text:
                  //                 " On Script Tap to edit / long press to delete.",
                  //             theme: false,
                  //             color: theme.isDarkMode
                  //                 ? colors.secondaryDark
                  //                 : colors.secondaryLight,
                  //             fw: 0,
                  //           ),
                  //         ])),
                  Expanded(
                      child: basket.bsktScripList.isEmpty
                          ? const NoDataFound()
                          : StreamBuilder<Map>(
                              stream:
                                  ref.watch(websocketProvider).socketDataStream,
                              builder: (context, snapshot) {
                                final socketDatas = snapshot.data ?? {};

                                // Check if we have socket data and need to update
                                if (snapshot.hasData &&
                                    socketDatas.isNotEmpty) {
                                  bool updated = false;

                                  // Update basket script list with real-time values
                                  for (var script in basket.bsktScripList) {
                                    final token = script['token']?.toString();
                                    if (token != null &&
                                        socketDatas.containsKey(token)) {
                                      final lp =
                                          socketDatas[token]['lp']?.toString();
                                      final pc =
                                          socketDatas[token]['pc']?.toString();

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
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (context.mounted) {
                                        // This will trigger a rebuild with the new values
                                        basket.notifyBasketUpdates();
                                      }
                                    });
                                  }
                                }

                                // Process basket items to extract symbol info
                                final processedItems =
                                    List<Map<String, dynamic>>.from(
                                        basket.bsktScripList);
                                for (int i = 0;
                                    i < processedItems.length;
                                    i++) {
                                  // Preserve original index for delete operations
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
                                    // Get screen width for responsive design
                                    final screenWidth = MediaQuery.of(context).size.width;
                                    
                                    // Get responsive column configuration
                                    final responsiveConfig = _getResponsiveBasketItemsColumns(screenWidth);
                                    final headers = List<String>.from(responsiveConfig['headers'] as List);
                                    final columnFlex = Map<String, int>.from(responsiveConfig['columnFlex'] as Map);
                                    final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
                                    
                                    // Calculate total minimum width
                                    final totalMinWidth =
                                        columnMinWidth.values.fold<double>(0.0, (a, b) => a + b);
                                    // Determine whether horizontal scroll is needed
                                    final needHorizontalScroll = constraints.maxWidth < totalMinWidth;

                                    // Build the Column (header + body)
                                    final tableColumn = Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.isDarkMode
                                              ? WebDarkColors.divider
                                              : WebColors.divider,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        color: theme.isDarkMode
                                            ? WebDarkColors.background
                                            : Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // --- Sticky header (fixed) ---
                                          Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: theme.isDarkMode
                                                  ? WebDarkColors.primary
                                                  : WebColors.primary.withOpacity(0.05),
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: theme.isDarkMode
                                                      ? WebDarkColors.divider
                                                      : WebColors.divider,
                                                  width: 1,
                                                ),
                                              ),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(4),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: needHorizontalScroll
                                              ? IntrinsicWidth(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: headers.map((label) {
                                                      final flex = columnFlex[label] ?? 1;
                                                      final minW = columnMinWidth[label] ?? 80.0;
                                                      final columnIndex = _getBasketColumnIndexForHeader(label);

                                                      return _buildBasketColumnCell(
                                                        needHorizontalScroll: needHorizontalScroll,
                                                        flex: flex,
                                                        minW: minW,
                                                        child: _buildBasketHeaderWidget(
                                                          label, 
                                                          columnIndex, 
                                                          theme, 
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
                                                    final columnIndex = _getBasketColumnIndexForHeader(label);

                                                    return _buildBasketColumnCell(
                                                      needHorizontalScroll: needHorizontalScroll,
                                                      flex: flex,
                                                      minW: minW,
                                                      child: _buildBasketHeaderWidget(
                                                        label, 
                                                        columnIndex, 
                                                        theme, 
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                        ),

                                        // --- Scrollable body (vertical) ---
                                        Expanded(
                                          child: Scrollbar(
                                            controller: _verticalScrollController,
                                            thumbVisibility: true,
                                            radius: Radius.zero,
                                            child: _buildBasketBodyList(
                                              theme,
                                              processedItems,
                                              headers,
                                              columnFlex,
                                              columnMinWidth,
                                              totalMinWidth: totalMinWidth,
                                              needHorizontalScroll: needHorizontalScroll,
                                            ),
                                          ),
                                        ),
                                      ],
                                      ),
                                    );

                                    // If horizontal scroll needed, wrap the entire column inside SingleChildScrollView
                                    if (needHorizontalScroll) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 20.0),
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          height: constraints.maxHeight,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            controller: _horizontalScrollController,
                                            child: SizedBox(
                                              width: totalMinWidth,
                                              child: tableColumn,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    // else (no horizontal scroll)
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 20.0),
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        height: constraints.maxHeight,
                                        child: tableColumn,
                                      ),
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
                              color: colors.tertiary),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? WebDarkColors.surface
                              : WebColors.surface,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: _hasOrdersPlacedInBasket(
                                  widget.bsktName, basket)
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    basket.resetBasketOrderTracking(
                                        widget.bsktName);
                                    ResponsiveSnackBar.showSuccess(context,
                                        "Basket reset. You can place orders again.");
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
                                      minimumSize: const Size(0, 40),
                                      side: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.colorGrey
                                            : colors.primaryLight,
                                      ),
                                      backgroundColor: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.6)
                                          : colors.btnBg,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)))),
                                )
                              : OutlinedButton.icon(
                                  onPressed: _hasMultipleExchanges(
                                          basket.bsktScripList)
                                      ? () {}
                                      : () async {
                                          await basket.placeBasketOrder(context,
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
                                    minimumSize: const Size(0, 40),
                                    backgroundColor: _hasMultipleExchanges(
                                            basket.bsktScripList)
                                        ? (theme.isDarkMode
                                            ? colors.textSecondaryDark
                                                .withOpacity(0.3)
                                            : colors.textSecondaryLight
                                                .withOpacity(0.3))
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
          // Search Overlay (Tabs + Results) - Positioned above margin section
          if (_searchValue.isNotEmpty)
            Positioned(
              top: 120, // Header (60) + Search Bar (60) = 120
              left: 40, // Match search bar horizontal padding
              right: 40, // Match search bar horizontal padding
              height:
                  450, // Fixed height so margin section remains visible below
              child: Container(
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? WebDarkColors.surface
                      : WebColors.surface,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tabs Section
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.surface
                            : WebColors.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.isDarkMode
                                ? WebDarkColors.divider
                                : WebColors.divider,
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildSearchTabs(ref, theme),
                    ),
                    // Search Results Section
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
  Color _getItemStatusColor(String status, theme) {
    switch (status.toLowerCase()) {
      case 'placed':
        return theme.isDarkMode ? colors.primaryDark : colors.primaryLight;
      case 'complete':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'rejected':
      case 'canceled':
      case 'failed':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'open':
      case 'partial':
      case 'trigger_pending':
        return theme.isDarkMode ? colors.pending : colors.pending;
      default:
        return theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight;
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

  // Basket table cell builders
  DataCell _buildBasketCellWithHover(Map<String, dynamic> item,
      ThemesProvider theme, String token, DataCell cell,
      {Alignment alignment = Alignment.centerRight}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowIndex = token),
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

  int _getBasketColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument': return 0;
      case 'Details': return 1;
      case 'Type': return 2;
      case 'Qty': return 3;
      case 'Price': return 4;
      case 'LTP': return 5;
      case 'Status': return 6;
      default: return -1;
    }
  }

  Widget _buildBasketHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
  ) {
    return InkWell(
      onTap: () => _onSortTable(columnIndex, !_sortAscending),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6),
              child: Text(
                label,
                style: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          // Sort icon
          if (_sortColumnIndex == columnIndex)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconPrimary
                    : WebColors.iconPrimary,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                Icons.unfold_more,
                size: 16,
                color: theme.isDarkMode
                    ? WebDarkColors.iconSecondary
                    : WebColors.iconSecondary,
              ),
            ),
        ],
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
        final isHovered = _hoveredRowIndex == uniqueId;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowIndex = uniqueId),
          onExit: (_) => setState(() => _hoveredRowIndex = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Handle tap - same as original onTap
              await ref
                  .read(marketWatchProvider)
                  .fetchScripInfo(
                      "${item['token']}",
                      '${item['exch']}',
                      context,
                      true);

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

              final scripInfo = ref
                  .read(marketWatchProvider)
                  .scripInfoModel;
              if (scripInfo == null) {
                ResponsiveSnackBar.showError(context,
                    'Unable to fetch scrip information');
                return;
              }

              PlaceOrderScreenWeb.showDraggable(
                context: context,
                orderArg: orderArgs,
                scripInfo: scripInfo,
                isBasket: 'BasketEdit',
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: isHovered
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              isHovered,
                              uniqueId,
                              needHorizontalScroll: needHorizontalScroll,
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
                            isHovered,
                            uniqueId,
                            needHorizontalScroll: needHorizontalScroll,
                          ),
                        );
                      }).toList(),
                    ),
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
    bool isHovered,
    String uniqueId, {
    required bool needHorizontalScroll,
  }) {
    switch (column) {
      case 'Instrument':
        return _buildBasketInstrumentWidget(
          item,
          originalIndex,
          theme,
          isHovered,
          uniqueId,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Details':
        final details =
            "${item["exch"]} - ${item["ordType"]} - ${item["prctype"]} - ${formatToTimeOnly(item["date"] ?? "")}";
        return _buildBasketDetailsTextCell(
          details,
          theme,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Type':
        final trantype = item["trantype"]?.toString();
        final buySell = trantype == "S" ? "SELL" : "BUY";
        final textColor = trantype == "S"
            ? (theme.isDarkMode ? colors.lossDark : colors.lossLight)
            : (theme.isDarkMode ? colors.profitDark : colors.profitLight);
        return _buildBasketTextCell(
          buySell,
          theme,
          Alignment.centerLeft,
          color: textColor,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Qty':
        final qty = item["qty"]?.toString() ?? '0';
        final filledQty = item["filledQty"]?.toString() ?? '0';
        final qtyText = "$filledQty/$qty";
        return _buildBasketTextCell(
          qtyText,
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Price':
        return _buildBasketTextCell(
          item["prc"]?.toString() ?? '0.00',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'LTP':
        return _buildBasketTextCell(
          item["lp"]?.toString() ?? '0.00',
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Status':
        final status = item["orderStatus"]?.toString() ?? '-';
        return _buildBasketTextCell(
          status,
          theme,
          Alignment.centerLeft,
          needHorizontalScroll: needHorizontalScroll,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasketInstrumentWidget(
    Map<String, dynamic> item,
    int originalIndex,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId, {
    required bool needHorizontalScroll,
  }) {
    final symbol = item['symbol']?.toString() ?? '';
    final expDate = item['expDate']?.toString() ?? '';
    final option = item['option']?.toString() ?? '';
    
    String displayText = symbol.trim();
    if (expDate.isNotEmpty) {
      displayText += ' $expDate';
    }
    if (option.isNotEmpty) {
      displayText += ' $option';
    }

    return ClipRect(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: isHovered ? 1 : 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: displayText,
                child: Text(
                  displayText,
                  style: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: WebFonts.medium,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Delete button fade in on hover
          IgnorePointer(
            ignoring: !isHovered,
            child: AnimatedOpacity(
              opacity: isHovered ? 1 : 0,
              duration: const Duration(milliseconds: 140),
              child: _buildBasketHoverButton(
                label: 'Delete',
                color: Colors.white,
                backgroundColor: theme.isDarkMode
                    ? WebDarkColors.tertiary
                    : WebColors.tertiary,
                onPressed: () => _handleDeleteBasketScript(
                  {'_originalIndex': originalIndex, ...item},
                  originalIndex,
                  theme,
                ),
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketTextCell(
    String text,
    ThemesProvider theme,
    Alignment alignment, {
    Color? color,
    bool needHorizontalScroll = false,
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

  Widget _buildBasketDetailsTextCell(
    String text,
    ThemesProvider theme, {
    bool needHorizontalScroll = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        child: Tooltip(
          message: text,
          child: Text(
            text,
            style: WebTextStyles.custom(
              fontSize: 13,
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary,
              fontWeight: WebFonts.medium,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  DataCell _buildBasketInstrumentCellWithHover(Map<String, dynamic> item,
      int index, ThemesProvider theme, String token) {
    final isHovered = _hoveredRowIndex == token;

    String symbol = '${item['symbol']?.replaceAll("-EQ", "") ?? 'N/A'}';
    String expDate = item['expDate'] ?? '';
    String option = item['option'] ?? '';

    String displayText = symbol.trim();
    if (expDate.isNotEmpty && expDate.trim().isNotEmpty) {
      displayText += ' $expDate';
    }
    if (option.isNotEmpty && option.trim().isNotEmpty) {
      displayText += ' $option';
    }

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowIndex = token),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: SizedBox.expand(
          child: Row(
            children: [
              // Text that takes at least 50% of width, leaves space for buttons
              Expanded(
                flex: isHovered
                    ? 1
                    : 2, // When hovered, text takes less space but still visible
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: displayText,
                    child: Text(
                      displayText,
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
                      // Delete button
                      _buildBasketHoverButton(
                        label: 'Delete',
                        color: Colors.white,
                        backgroundColor: theme.isDarkMode
                            ? WebDarkColors.tertiary
                            : WebColors.tertiary,
                        onPressed: () =>
                            _handleDeleteBasketScript(item, index, theme),
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

  DataCell _buildBasketDetailsCell(
      Map<String, dynamic> item, ThemesProvider theme) {
    String details =
        "${item["exch"]} - ${item["ordType"]} - ${item["prctype"]} - ${formatToTimeOnly(item["date"] ?? "")}";

    return DataCell(
      Text(
        details,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataCell _buildBasketTypeCell(
      Map<String, dynamic> item, ThemesProvider theme) {
    String buySell = item["trantype"] == "S" ? "SELL" : "BUY";
    Color buttonColor = item["trantype"] == "S"
        ? (theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary)
        : (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary);

    return DataCell(
      Text(
        buySell,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: buttonColor,
        ),
      ),
    );
  }

  DataCell _buildBasketQtyCell(
      Map<String, dynamic> item, ThemesProvider theme) {
    String qty = "${item["dscqty"]}/${item["qty"]}";

    return DataCell(
      Text(
        qty,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildBasketPriceCell(
      Map<String, dynamic> item, ThemesProvider theme) {
    String price = "0.00";
    if (item["prctype"] != "MKT" && item['prc'] != null) {
      price = "${item['prc']}";
    }

    return DataCell(
      Text(
        price,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildBasketLTPCell(
      Map<String, dynamic> item, ThemesProvider theme) {
    String ltp = item['lp']?.toString() ?? "0.00";

    return DataCell(
      Text(
        ltp,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textPrimary
              : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildBasketStatusCell(
      Map<String, dynamic> item, ThemesProvider theme) {
    if (item['orderStatus'] == null) {
      return DataCell(
        Text(
          '-',
          style: WebTextStyles.tableDataCompact(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
          ),
        ),
      );
    }

    final status = item['orderStatus'].toString().toUpperCase();
    final statusColor = _getItemStatusColor(status, theme);
    String statusText = status;

    if (item['avgPrice'] != null) {
      statusText += " @ ₹${item['avgPrice']}";
    }

    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusText,
          style: WebTextStyles.tableDataCompact(
            isDarkTheme: theme.isDarkMode,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBasketHoverButton({
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

  Future<void> _handleDeleteBasketScript(
      Map<String, dynamic> item, int index, ThemesProvider theme) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          onTap: () => Navigator.of(dialogContext).pop(false),
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
                      Text(
                        'Are you sure you want to delete this basket Script "${item['symbol']?.replaceAll("-EQ", "")}"?',
                        textAlign: TextAlign.center,
                        style: WebTextStyles.custom(
                          fontSize: 13,
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? WebDarkColors.textPrimary
                              : WebColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
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
      },
    );

    if (shouldDelete == true && mounted) {
      final basket = ref.read(orderProvider);
      await basket.removeBsktScrip(index, widget.bsktName);
      await basket.fetchBasketMargin();
    }
  }
}

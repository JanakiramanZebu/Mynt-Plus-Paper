import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../provider/stocks_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../models/explore_model/stocks_model/toplist_stocks.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/no_data_found.dart';

class TradeActionScreenWeb extends ConsumerStatefulWidget {
  final int? initialTabIndex;
  
  const TradeActionScreenWeb({super.key, this.initialTabIndex});

  @override
  ConsumerState<TradeActionScreenWeb> createState() => _TradeActionScreenWebState();
}

class _TradeActionScreenWebState extends ConsumerState<TradeActionScreenWeb>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _hoveredRowToken;
  StreamSubscription? _socketSubscription;
  
  // Store WebSocket data for each stock
  final Map<String, Map<String, dynamic>> _socketDataMap = {};

  final List<String> _tabs = [
    'Top gainer',
    'Top losers',
    'Volume breakout',
    'Most active',
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex ?? 0;
    final safeIndex = initialIndex >= 0 && initialIndex < _tabs.length ? initialIndex : 0;
    _tabController = TabController(
      length: _tabs.length, 
      vsync: this, 
      initialIndex: safeIndex
    );
    
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
        // Note: WebSocket subscription is handled by WebSubscriptionManager
        // No need to subscribe/unsubscribe on tab change since all trade action stocks are subscribed
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Ensure we're on the correct tab after the controller is created
        if (widget.initialTabIndex != null && 
            widget.initialTabIndex! >= 0 && 
            widget.initialTabIndex! < _tabs.length &&
            _tabController.index != widget.initialTabIndex!) {
          _tabController.animateTo(widget.initialTabIndex!);
        }
        
        final stocksProvider = ref.read(stocksProvide);
        // Fetch all trade action data (WebSubscriptionManager will subscribe after data is fetched)
        // Only fetch if data is empty (handler function will fetch with cooldown)
        if (stocksProvider.topGainers.isEmpty && stocksProvider.topLosers.isEmpty) {
          await stocksProvider.fetchTradeAction("NSE", "NSEALL", "topG_L", "topG_L");
          await stocksProvider.fetchTradeAction("NSE", "NSEALL", "mostActive", "mostActive");
        }
        
        // Setup WebSocket listener for receiving data updates
        // Note: Subscription is handled by WebSubscriptionManager
        _setupSocketSubscription();
      }
    });
  }
  
  @override
  void didUpdateWidget(TradeActionScreenWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the initialTabIndex changed, update the tab
    if (oldWidget.initialTabIndex != widget.initialTabIndex &&
        widget.initialTabIndex != null &&
        widget.initialTabIndex! >= 0 &&
        widget.initialTabIndex! < _tabs.length &&
        _tabController.index != widget.initialTabIndex!) {
      _tabController.animateTo(widget.initialTabIndex!);
    }
  }
  
  void _setupSocketSubscription() {
    final websocket = ref.read(websocketProvider);
    
    // Get existing socket data
    _socketDataMap.clear();
    websocket.socketDatas.forEach((key, value) {
      if (key is String && value is Map) {
        _socketDataMap[key] = Map<String, dynamic>.from(value);
      }
    });
    
    // Listen for updates
    _socketSubscription = websocket.socketDataStream.listen((socketDatas) {
      if (mounted) {
        socketDatas.forEach((key, value) {
          if (key is String && value is Map) {
            _socketDataMap[key] = Map<String, dynamic>.from(value);
          }
        });
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _tabController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  List<TopGainers> _getCurrentStocks() {
    final stocksProvider = ref.read(stocksProvide);
    List<TopGainers> stocks;
    switch (_tabController.index) {
      case 0:
        stocks = stocksProvider.topGainers;
        break;
      case 1:
        stocks = stocksProvider.topLosers;
        break;
      case 2:
        stocks = stocksProvider.byVolume;
        break;
      case 3:
        stocks = stocksProvider.byValue;
        break;
      default:
        return [];
    }
    
    // Apply sorting if a column is selected
    if (_sortColumnIndex != null) {
      stocks = List<TopGainers>.from(stocks);
      stocks.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Symbol
            comparison = _getSymbolName(a).compareTo(_getSymbolName(b));
            break;
          case 1: // Exchange
            comparison = (a.exch ?? '').compareTo(b.exch ?? '');
            break;
          case 2: // LTP - prefer socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aLtp = double.tryParse(aSocketData?['lp']?.toString() ?? a.lp ?? '0') ?? 0.0;
            final bLtp = double.tryParse(bSocketData?['lp']?.toString() ?? b.lp ?? '0') ?? 0.0;
            comparison = aLtp.compareTo(bLtp);
            break;
          case 3: // Change - prefer socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aChangeStr = aSocketData?['chng']?.toString() ?? a.c ?? '0';
            final bChangeStr = bSocketData?['chng']?.toString() ?? b.c ?? '0';
            final aChange = double.tryParse(aChangeStr) ?? 0.0;
            final bChange = double.tryParse(bChangeStr) ?? 0.0;
            comparison = aChange.compareTo(bChange);
            break;
          case 4: // Change % - prefer socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aPerChange = double.tryParse(aSocketData?['pc']?.toString() ?? a.pc ?? '0') ?? 0.0;
            final bPerChange = double.tryParse(bSocketData?['pc']?.toString() ?? b.pc ?? '0') ?? 0.0;
            comparison = aPerChange.compareTo(bPerChange);
            break;
          case 5: // Open - get from socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aOpen = double.tryParse(aSocketData?['o']?.toString() ?? '0') ?? 0.0;
            final bOpen = double.tryParse(bSocketData?['o']?.toString() ?? '0') ?? 0.0;
            comparison = aOpen.compareTo(bOpen);
            break;
          case 6: // High - get from socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aHigh = double.tryParse(aSocketData?['h']?.toString() ?? '0') ?? 0.0;
            final bHigh = double.tryParse(bSocketData?['h']?.toString() ?? '0') ?? 0.0;
            comparison = aHigh.compareTo(bHigh);
            break;
          case 7: // Low - get from socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aLow = double.tryParse(aSocketData?['l']?.toString() ?? '0') ?? 0.0;
            final bLow = double.tryParse(bSocketData?['l']?.toString() ?? '0') ?? 0.0;
            comparison = aLow.compareTo(bLow);
            break;
          case 8: // Close - prefer socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aClose = double.tryParse(aSocketData?['c']?.toString() ?? a.pp ?? '0') ?? 0.0;
            final bClose = double.tryParse(bSocketData?['c']?.toString() ?? b.pp ?? '0') ?? 0.0;
            comparison = aClose.compareTo(bClose);
            break;
          case 9: // Volume - prefer socket data
            final aToken = a.token ?? "";
            final bToken = b.token ?? "";
            final aUniqueId = '${a.exch ?? ''}|$aToken';
            final bUniqueId = '${b.exch ?? ''}|$bToken';
            final aSocketData = _socketDataMap[aUniqueId] ?? _socketDataMap[aToken];
            final bSocketData = _socketDataMap[bUniqueId] ?? _socketDataMap[bToken];
            final aVolume = int.tryParse(aSocketData?['v']?.toString() ?? a.v ?? '0') ?? 0;
            final bVolume = int.tryParse(bSocketData?['v']?.toString() ?? b.v ?? '0') ?? 0;
            comparison = aVolume.compareTo(bVolume);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }
    
    return stocks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    
    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? WebDarkColors.background
          : WebColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with tabs
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? WebDarkColors.surface
                    : WebColors.surface,
                // border: Border(
                //   bottom: BorderSide(
                //     color: theme.isDarkMode
                //         ? WebDarkColors.divider
                //         : WebColors.divider,
                //   ),
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  // Text(
                  //   "Today's trade action",
                  //   style: WebTextStyles.head(
                  //     isDarkTheme: theme.isDarkMode,
                  //     color: theme.isDarkMode
                  //         ? WebDarkColors.textPrimary
                  //         : WebColors.textPrimary,
                  //     fontWeight: WebFonts.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  // Tabs
                  _buildTabs(theme),
                ],
              ),
            ),
            // Table content
            Expanded(
              child: _buildTable(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ThemesProvider theme) {
    return SizedBox(
      height: 45,
      child: SingleChildScrollView(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int index = 0; index < _tabs.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildTab(
                  _tabs[index],
                  index,
                  _tabController.index == index,
                  theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
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
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.transparent,
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

  Widget _buildTable(ThemesProvider theme) {
    final stocks = _getCurrentStocks();

    if (stocks.isEmpty) {
      return const Center(child: NoDataFound());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height: screen height minus all UI elements
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0; // Top and bottom padding (16 * 2)
        final headerHeight = 120.0; // Header with tabs
        final spacing = 16.0; // Spacing between sections
        final bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            height: calculatedHeight.toDouble(),
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
            clipBehavior: Clip.antiAlias, // Ensure no gaps show through
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  radius: const Radius.circular(3),
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.textSecondary.withOpacity(0.3)
                        : WebColors.textSecondary.withOpacity(0.3);
                  }),
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    return theme.isDarkMode 
                        ? WebDarkColors.divider.withOpacity(0.1)
                        : WebColors.divider.withOpacity(0.1);
                  }),
                  trackBorderColor: MaterialStateProperty.all(Colors.transparent),
                  minThumbLength: 48.0,
                ),
              ),
              child: DataTable2(
                columnSpacing: 12,
                // horizontalMargin: 12,
                // Calculate minWidth: Symbol(300) + Exchange(100) + 8 columns(120 each) + spacing(12*9) = ~1500
                minWidth: 1500,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                fixedLeftColumns: 1, // Fix the Symbol column
                fixedColumnsColor: theme.isDarkMode 
                    ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                    : WebColors.backgroundSecondary.withOpacity(0.8),
                showBottomBorder: true,
                horizontalScrollController: _horizontalScrollController,
                scrollController: _verticalScrollController,
                showCheckboxColumn: false,
                headingRowColor: MaterialStateProperty.all(
                  theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary.withOpacity(0.05),
                ),
                headingTextStyle: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
                dataTextStyle: WebTextStyles.custom(
                  fontSize: 13,
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.medium,
                ),
                border: TableBorder(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  horizontalInside: BorderSide(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.transparent, // Hide vertical lines
                    width: 0,
                  ),
                ),
                columns: _buildColumns(theme),
                rows: _buildRows(stocks, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn2> _buildColumns(ThemesProvider theme) {
    return [
      DataColumn2(
        label: _buildHeaderWidget('Symbol', 0, theme),
        size: ColumnSize.L,
        fixedWidth: 300.0, // Match position screen width
        onSort: (index, ascending) => _onSortTable(0, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Exchange', 1, theme),
        size: ColumnSize.S,
        fixedWidth: 100.0,
        onSort: (index, ascending) => _onSortTable(1, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('LTP', 2, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(2, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Change', 3, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(3, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Change %', 4, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(4, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Open', 5, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(5, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('High', 6, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(6, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Low', 7, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(7, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Close', 8, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(8, ascending),
      ),
      DataColumn2(
        label: _buildHeaderWidget('Volume', 9, theme),
        size: ColumnSize.S,
        fixedWidth: 120.0,
        onSort: (index, ascending) => _onSortTable(9, ascending),
      ),
    ];
  }

  Widget _buildHeaderWidget(String label, int columnIndex, ThemesProvider theme) {
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
        if (columnIndex >= 0)
          _buildSortIcon(columnIndex, theme),
      ],
    );
  }

  Widget _buildSortIcon(int columnIndex, ThemesProvider theme) {
    if (_sortColumnIndex == columnIndex) {
      return const SizedBox(width: 16);
    } else {
      return Icon(
        Icons.unfold_more,
        size: 16,
        color: theme.isDarkMode
            ? WebDarkColors.iconSecondary
            : WebColors.iconSecondary,
      );
    }
  }

  List<DataRow2> _buildRows(List<TopGainers> stocks, ThemesProvider theme) {
    return stocks.map((stock) {
      final token = stock.token ?? "";
      final uniqueId = '${token}_${stock.exch ?? ''}';
      final isHovered = _hoveredRowToken == uniqueId;
      
      // Get WebSocket data if available
      final socketData = _socketDataMap[token];
      final ltp = socketData?['lp']?.toString() ?? stock.lp ?? '0.00';
      final change = socketData?['chng']?.toString() ?? stock.c ?? '0.00';
      final perChange = socketData?['pc']?.toString() ?? stock.pc ?? '0.00';
      final open = socketData?['o']?.toString() ?? '0.00';
      final high = socketData?['h']?.toString() ?? '0.00';
      final low = socketData?['l']?.toString() ?? '0.00';
      final close = socketData?['c']?.toString() ?? stock.pp ?? '0.00';
      final volume = socketData?['v']?.toString() ?? stock.v ?? '0';

      return DataRow2(
        color: MaterialStateProperty.resolveWith((states) {
          if (isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return null;
        }),
        cells: [
          _buildCell(_getSymbolName(stock), theme, Alignment.centerLeft, uniqueId: uniqueId),
          _buildCell(stock.exch ?? "", theme, Alignment.centerLeft, uniqueId: uniqueId),
          _buildCell("₹$ltp", theme, Alignment.centerRight,
              color: _getChangeColorFromValues(change, perChange, theme), uniqueId: uniqueId),
          _buildCell(
              change.startsWith("-") ? change : "+$change",
              theme,
              Alignment.centerRight,
              color: _getChangeColorFromValues(change, perChange, theme), uniqueId: uniqueId),
          _buildCell(
              "$perChange%",
              theme,
              Alignment.centerRight,
              color: _getChangeColorFromValues(change, perChange, theme), uniqueId: uniqueId),
          _buildCell(open, theme, Alignment.centerRight, uniqueId: uniqueId),
          _buildCell(high, theme, Alignment.centerRight, uniqueId: uniqueId),
          _buildCell(low, theme, Alignment.centerRight, uniqueId: uniqueId),
          _buildCell(close, theme, Alignment.centerRight, uniqueId: uniqueId),
          _buildCell(volume, theme, Alignment.centerRight, uniqueId: uniqueId),
        ],
        onTap: () => _handleStockTap(stock, theme),
      );
    }).toList();
  }

  DataCell _buildCell(String text, ThemesProvider theme, Alignment alignment,
      {Color? color, String? uniqueId}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) {
          if (uniqueId != null) {
            setState(() => _hoveredRowToken = uniqueId);
          }
        },
        onExit: (_) {
          if (uniqueId != null) {
            setState(() => _hoveredRowToken = null);
          }
        },
        child: Align(
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
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

  String _getSymbolName(TopGainers stock) {
    final tsym = stock.tsym ?? "";
    if (tsym.contains("-")) {
      return tsym.split("-").first.toUpperCase();
    }
    return tsym.toUpperCase();
  }

  Color _getChangeColor(TopGainers stock, ThemesProvider theme) {
    final change = stock.c ?? "0.00";
    final perChange = stock.pc ?? "0.00";
    return _getChangeColorFromValues(change, perChange, theme);
  }
  
  Color _getChangeColorFromValues(String change, String perChange, ThemesProvider theme) {
    if (change.startsWith("-") || perChange.startsWith('-')) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else if (change == "0.00" || perChange == "0.00") {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    }
  }

  void _onSortTable(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Future<void> _handleStockTap(TopGainers stock, ThemesProvider theme) async {
    try {
      final marketWatch = ref.read(marketWatchProvider);
      
      await marketWatch.fetchScripQuoteIndex(
        stock.token?.toString() ?? "",
        stock.exch?.toString() ?? "",
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
  }
}


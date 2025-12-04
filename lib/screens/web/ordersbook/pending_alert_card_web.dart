import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../models/notification_model/broker_message_model.dart';
import '../../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/notification_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../utils/responsive_snackbar.dart';
import 'pending_alert_detail_screen_web.dart';

class PendingAlertWeb extends ConsumerStatefulWidget {
  const PendingAlertWeb({super.key});

  @override
  ConsumerState<PendingAlertWeb> createState() => _PendingAlertWebState();
}

class _PendingAlertWebState extends ConsumerState<PendingAlertWeb> 
    with AutomaticKeepAliveClientMixin {
  List<BrokerMessage>? triggeredAlerts;
  final Set<int> _selectedAlerts = <int>{};
  
  // Sorting variables
  int? _alertSortColumnIndex;
  bool _alertSortAscending = true;
  
  // WebSocket subscription for real-time updates
  StreamSubscription? _socketSubscription;
  
  // Throttling properties
  DateTime _lastSocketUpdateTime = DateTime.now();
  static const Duration _minUpdateInterval = Duration(milliseconds: 50);
  
  // Hover state
  String? _hoveredRowToken;
  int? _hoveredColumnIndex; // Track which column is being hovered
  
  // Processing state for actions
  bool _isProcessingCancel = false;
  bool _isProcessingModify = false;
  String? _processingAlertToken;
  
  // Scroll controllers
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  
  // Track if data has been initialized
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Only fetch data once when widget is first created
    if (!_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasInitialized) {
          _hasInitialized = true;
          _refreshData();
          // Setup WebSocket subscription after data is loaded
          _setupSocketSubscription();
        }
      });
    }
  }

  @override
  void dispose() {
    _teardownSocketSubscription();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // Combined method to refresh all data
  Future<void> _refreshData() async {
    if (!mounted) return;

    // Fetch both types of data
    await ref.read(marketWatchProvider).fetchPendingAlert(context);
    await _fetchTriggeredAlerts();
    
    // Subscribe to WebSocket for real-time updates
    _subscribeToAlertTokens();
  }

  // Subscribe to alert tokens for real-time LTP updates
  void _subscribeToAlertTokens() {
    try {
      final manage = ref.read(marketWatchProvider);
      final pendingAlerts = manage.alertPendingModel ?? [];
      
      if (pendingAlerts.isEmpty) return;

      // Create input string for WebSocket subscription
      final tokens = pendingAlerts
          .where((alert) => alert.token != null && alert.token!.isNotEmpty)
          .map((alert) => "${alert.exch}|${alert.token}")
          .toSet()
          .join("#");

      if (tokens.isNotEmpty) {
        print("Subscribing to alert tokens: $tokens");
        ref.read(websocketProvider).establishConnection(
          channelInput: tokens,
          task: "t", // Subscribe
          context: context,
        );
      }
    } catch (e) {
      print("Error subscribing to alert tokens: $e");
    }
  }

  // Fetch triggered alerts from broker messages
  Future<void> _fetchTriggeredAlerts() async {
    if (!mounted) return;
    await ref.read(notificationprovider).fetchbrokermsg(context);
  }

  // WebSocket subscription methods for real-time updates
  void _setupSocketSubscription() {
    // Use microtask to ensure context is available
    Future.microtask(() {
      final socketProvider = ref.read(websocketProvider);

      _socketSubscription =
          socketProvider.socketDataStream.listen((socketDatas) {
        if (socketDatas.isEmpty) return;

        // Apply throttling to avoid rapid updates
        final now = DateTime.now();
        if (now.difference(_lastSocketUpdateTime) < _minUpdateInterval) {
          return;
        }

        _lastSocketUpdateTime = now;
        _processSocketUpdates(socketDatas);
      });
    });
  }

  void _teardownSocketSubscription() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
  }

  void _processSocketUpdates(Map socketDatas) {
    bool hasUpdates = false;
    final manage = ref.read(marketWatchProvider);
    final pendingAlerts = manage.alertPendingModel ?? [];

    // Helper function to check if a string is a valid numeric price
    bool isValidNumeric(String? value) {
      if (value == null || value == "null") {
        return false;
      }
      return double.tryParse(value) != null;
    }

    // Process pending alerts for LTP updates
    for (var alert in pendingAlerts) {
      if (alert.token == null || alert.token!.isEmpty) continue;

      // Skip if no socket data for this token
      if (!socketDatas.containsKey(alert.token)) continue;

      final socketData = socketDatas[alert.token];
      if (socketData == null || socketData.isEmpty) continue;

      // Cache current values to detect changes
      final currentLtp = alert.ltp;

      // Update LTP (Last Traded Price) from WebSocket data
      final lp = socketData['lp']?.toString();
      if (isValidNumeric(lp)) {
        // Always update if different to ensure real-time display
        if (currentLtp != lp) {
          alert.ltp = lp;
          hasUpdates = true;
        }
      }

      // Update percentage change if available
      final pc = socketData['pc']?.toString();
      if (isValidNumeric(pc)) {
        if (alert.perChange != pc) {
          alert.perChange = pc;
          hasUpdates = true;
        }
      }
    }

    // Trigger UI update if there were changes
    if (hasUpdates && mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final manage = ref.watch(marketWatchProvider);
    final notification = ref.watch(notificationprovider);
    final order = ref.watch(orderProvider);
    final theme = ref.read(themeProvider);

    // Use order provider search functionality
    final isSearching = order.orderSearchCtrl.text.isNotEmpty;
    final pendingAlerts = isSearching
        ? manage.alertPendingSearch ?? []
        : manage.alertPendingModel ?? [];

    // Using ref.listen to detect changes in the alerts data
    ref.listen<MarketWatchProvider>(
        marketWatchProvider, (previous, current) {});
    ref.listen<NotificationProvider>(
        notificationprovider, (previous, current) {});

    // Use filtered triggered alerts from provider (if searching) or filter in UI (if not searching)
    if (isSearching) {
      triggeredAlerts = notification.triggeredAlertSearch ?? [];
    } else {
      // Filter broker messages that are related to alerts (only when not searching)
      triggeredAlerts = notification.brokermsg
              ?.where((msg) =>
                  msg.dmsg != null &&
                  msg.dmsg!.contains("Ltp") &&
                  (msg.dmsg!.contains("above") || msg.dmsg!.contains("below")))
              .toList() ??
          [];
    }

    // Combine pending and triggered alerts (pending first)
    final List<dynamic> allAlerts = [
      ...pendingAlerts,
      ...(triggeredAlerts ?? [])
    ];

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildAlertTable(_getSortedAlerts(allAlerts), theme),
      ),
    );
  }

  List<dynamic> _getSortedAlerts(List<dynamic> alerts) {
    if (_alertSortColumnIndex == null) return alerts;
    final sorted = [...alerts];
    int c = _alertSortColumnIndex!;
    bool asc = _alertSortAscending;
    
    int cmp<T extends Comparable>(T? a, T? b) {
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
          String aInstrument = a is BrokerMessage ? 'N/A' : (a.tsym?.replaceAll("-EQ", "") ?? 'N/A');
          String bInstrument = b is BrokerMessage ? 'N/A' : (b.tsym?.replaceAll("-EQ", "") ?? 'N/A');
          r = cmp<String>(aInstrument, bInstrument);
          break;
        case 1: // Exchange
          String aExchange = a is BrokerMessage ? 'N/A' : (a.exch ?? '');
          String bExchange = b is BrokerMessage ? 'N/A' : (b.exch ?? '');
          r = cmp<String>(aExchange, bExchange);
          break;
        case 2: // Alert Type
          String aType = '';
          String bType = '';
          if (a is BrokerMessage) {
            aType = 'TRIGGERED';
          } else {
            switch (a.aiT) {
              case 'LTP_A': aType = 'LTP Above'; break;
              case 'LTP_B': aType = 'LTP Below'; break;
              case 'CH_PER_A': aType = 'Perc.Change Above'; break;
              case 'CH_PER_B': aType = 'Perc.Change Below'; break;
              default: aType = 'Unknown';
            }
          }
          if (b is BrokerMessage) {
            bType = 'TRIGGERED';
          } else {
            switch (b.aiT) {
              case 'LTP_A': bType = 'LTP Above'; break;
              case 'LTP_B': bType = 'LTP Below'; break;
              case 'CH_PER_A': bType = 'Perc.Change Above'; break;
              case 'CH_PER_B': bType = 'Perc.Change Below'; break;
              default: bType = 'Unknown';
            }
          }
          r = cmp<String>(aType, bType);
          break;
        case 3: // Target
          if (a is BrokerMessage || b is BrokerMessage) {
            String aTarget = a is BrokerMessage ? 'N/A' : (a.aiT == "CH_PER_A" || a.aiT == "CH_PER_B" ? "%${a.d}" : "${a.d}");
            String bTarget = b is BrokerMessage ? 'N/A' : (b.aiT == "CH_PER_A" || b.aiT == "CH_PER_B" ? "%${b.d}" : "${b.d}");
            r = cmp<String>(aTarget, bTarget);
          } else {
            num aTarget = parseNum("${a.d ?? 0}");
            num bTarget = parseNum("${b.d ?? 0}");
            r = aTarget.compareTo(bTarget);
          }
          break;
        case 4: // LTP
          if (a is BrokerMessage || b is BrokerMessage) {
            String aLtp = a is BrokerMessage ? 'N/A' : "${a.ltp ?? a.close ?? 0.00}";
            String bLtp = b is BrokerMessage ? 'N/A' : "${b.ltp ?? b.close ?? 0.00}";
            r = cmp<String>(aLtp, bLtp);
          } else {
            num aLtp = parseNum("${a.ltp ?? a.close ?? 0.00}");
            num bLtp = parseNum("${b.ltp ?? b.close ?? 0.00}");
            r = aLtp.compareTo(bLtp);
          }
          break;
        case 5: // Status
          String aStatus = a is BrokerMessage ? 'TRIGGERED' : 'PENDING';
          String bStatus = b is BrokerMessage ? 'TRIGGERED' : 'PENDING';
          r = cmp<String>(aStatus, bStatus);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  void _onSortAlertTable(int columnIndex) {
    setState(() {
      if (_alertSortColumnIndex == columnIndex) {
        _alertSortAscending = !_alertSortAscending;
      } else {
        _alertSortColumnIndex = columnIndex;
        _alertSortAscending = true;
      }
    });
  }

  // Helper method to get responsive column configuration for Alerts
  // Always show all columns - horizontal scroll handles overflow on small screens
  Map<String, dynamic> _getResponsiveAlertColumns(double screenWidth) {
    return {
      'headers': ['Instrument', 'Exchange', 'Alert Type', 'Target', 'LTP', 'Status'],
      'columnMinWidth': {
        'Instrument': 300,
        'Exchange': 110,
        'Alert Type': 160,
        'Target': 120,
        'LTP': 100,
        'Status': 110,
      },
    };
  }

  Widget _buildAlertTable(List<dynamic> alerts, ThemesProvider theme) {
    if (alerts.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: NoDataFound(),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = 32.0; // Top and bottom padding (16 * 2)
        final headerHeight = 50.0; // Header height (tabs + search bar)
        final spacing = 16.0; // Spacing between header and content
        final bottomMargin = 20.0; // Bottom margin
        final tableHeight =
            screenHeight - padding - headerHeight - spacing - bottomMargin;

        // Ensure we don't exceed 75% of screen height
        final maxHeight = screenHeight * 0.75;
        final calculatedHeight = tableHeight > maxHeight
            ? maxHeight
            : (tableHeight > 400 ? tableHeight : 400.0);

        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveAlertColumns(screenWidth);
        final headers = List<String>.from(responsiveConfig['headers'] as List);
        final columnMinWidth = Map<String, double>.from(responsiveConfig['columnMinWidth'] as Map);
        
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
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  // Make both scrollbars always visible
                  thumbVisibility: MaterialStateProperty.all(true),
                  trackVisibility: MaterialStateProperty.all(true),
                  
                  // Consistent thickness for both horizontal and vertical
                  thickness: MaterialStateProperty.all(6.0),
                  crossAxisMargin: 0.0,
                  mainAxisMargin: 0.0,
                  
                  // Consistent radius
                  radius: const Radius.circular(3),
                  
                  // Consistent colors for both scrollbars
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
                horizontalMargin: 12,
                minWidth: 1200,
                sortColumnIndex: null, // Disable DataTable2's built-in sorting
                sortAscending: _alertSortAscending,
                fixedLeftColumns: 1, // Fix the first column (Instrument)
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
                  // Remove vertical lines
                ),
                columns: _buildAlertDataTable2Columns(headers, columnMinWidth, theme),
                rows: _buildAlertDataTable2Rows(alerts, headers, theme),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isNumericColumnAlert(String header) {
    return header == 'Target' || header == 'LTP'; // Only Target and LTP are numeric
  }

  int _getAlertColumnIndexForHeader(String header) {
    switch (header) {
      case 'Instrument': return 0;
      case 'Exchange': return 1;
      case 'Alert Type': return 2;
      case 'Target': return 3;
      case 'LTP': return 4;
      case 'Status': return 5;
      default: return -1;
    }
  }

  List<DataColumn2> _buildAlertDataTable2Columns(
    List<String> headers,
    Map<String, double> columnMinWidth,
    ThemesProvider theme,
  ) {
    return headers.map((header) {
      final columnIndex = _getAlertColumnIndexForHeader(header);
      final isNumeric = _isNumericColumnAlert(header);
      final isInstrument = header == 'Instrument';
      
      return DataColumn2(
        label: SizedBox.expand(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoveredColumnIndex = columnIndex),
            onExit: (_) => setState(() => _hoveredColumnIndex = null),
            child: Tooltip(
              message: 'Sort by $header',
              child: GestureDetector(
                onTap: () => _onSortAlertTable(columnIndex),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _hoveredColumnIndex == columnIndex
                        ? (theme.isDarkMode
                            ? WebDarkColors.primary.withOpacity(0.1)
                            : WebColors.primary.withOpacity(0.05))
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              header,
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
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 16, // Fixed width for the icon
                              child: _buildAlertSortIcon(columnIndex, theme),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        size: isInstrument ? ColumnSize.L : ColumnSize.S,
        fixedWidth: isInstrument ? 300.0 : null,
        onSort: null, // Disable DataTable2's default sort
      );
    }).toList();
  }

  List<DataRow2> _buildAlertDataTable2Rows(
    List<dynamic> alerts,
    List<String> headers,
    ThemesProvider theme,
  ) {
    final sorted = _getSortedAlerts(alerts);
    return sorted.map((alert) {
      // Create unique identifier for hover
      String uniqueId;
      if (alert is BrokerMessage) {
        uniqueId = 'triggered_${alert.norentm ?? sorted.indexOf(alert)}';
      } else {
        uniqueId = '${alert.alId ?? alert.token ?? sorted.indexOf(alert)}';
      }
      final isHovered = _hoveredRowToken == uniqueId;

      return DataRow2(
        color: MaterialStateProperty.resolveWith((states) {
          if (isHovered) {
            return theme.isDarkMode
                ? WebDarkColors.primary.withOpacity(0.06)
                : WebColors.primary.withOpacity(0.10);
          }
          return null;
        }),
        cells: headers.map((header) {
          return _buildAlertDataTable2Cell(
            header,
            alert,
            theme,
            isHovered,
            uniqueId,
          );
        }).toList(),
        onTap: () {
          // Only show detail dialog for pending alerts, not triggered ones
          if (alert is! BrokerMessage) {
            showDialog(
              context: context,
              builder: (context) => PendingAlertDetailScreenWeb(alert: alert),
            );
          }
        },
      );
    }).toList();
  }

  DataCell _buildAlertDataTable2Cell(
    String column,
    dynamic alert,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    Widget cellContent;
    
    switch (column) {
      case 'Instrument':
        cellContent = _buildAlertInstrumentCellContent(
          alert,
          theme,
          isHovered,
          uniqueId,
        );
        break;
      case 'Exchange':
        final exchange = alert is BrokerMessage ? 'N/A' : (alert.exch ?? 'N/A');
        cellContent = _buildAlertTextCell(
          exchange,
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Alert Type':
        String alertType = '';
        if (alert is BrokerMessage) {
          alertType = 'TRIGGERED';
        } else {
          switch (alert.aiT) {
            case 'LTP_A': alertType = 'LTP Above'; break;
            case 'LTP_B': alertType = 'LTP Below'; break;
            case 'CH_PER_A': alertType = 'Perc.Change Above'; break;
            case 'CH_PER_B': alertType = 'Perc.Change Below'; break;
            default: alertType = 'Unknown';
          }
        }
        cellContent = _buildAlertTextCell(
          alertType,
          theme,
          Alignment.centerLeft,
        );
        break;
      case 'Target':
        String target = '';
        if (alert is BrokerMessage) {
          target = 'N/A';
        } else {
          if (alert.aiT == "CH_PER_A" || alert.aiT == "CH_PER_B") {
            target = "%${alert.d ?? '0.00'}";
          } else {
            target = "${alert.d ?? '0.00'}";
          }
        }
        cellContent = _buildAlertTextCell(
          target,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'LTP':
        final ltp = alert is BrokerMessage 
            ? 'N/A' 
            : "${alert.ltp ?? alert.close ?? '0.00'}";
        cellContent = _buildAlertTextCell(
          ltp,
          theme,
          Alignment.centerRight,
        );
        break;
      case 'Status':
        final status = alert is BrokerMessage ? 'TRIGGERED' : 'PENDING';
        final statusColor = _getAlertStatusColor(status, theme);
        cellContent = _buildAlertTextCell(
          status,
          theme,
          Alignment.centerLeft,
          color: statusColor,
        );
        break;
      default:
        cellContent = const SizedBox.shrink();
    }

    // Wrap with MouseRegion to detect hover anywhere on the cell
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: cellContent,
        ),
      ),
    );
  }

  Widget _buildAlertInstrumentCellContent(
    dynamic alert,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId,
  ) {
    final isProcessing = _processingAlertToken == uniqueId;
    final isPending = alert is! BrokerMessage;

    String symbol = '';
    String exchange = '';
    if (alert is BrokerMessage) {
      symbol = 'N/A';
      exchange = '';
    } else {
      symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';
      exchange = alert.exch ?? '';
    }
    String displayText = symbol.trim();
    if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
      displayText += ' ${exchange.trim()}';
    }

    return Row(
      children: [
        Expanded(
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
        // Action buttons fade in on hover
        IgnorePointer(
          ignoring: !isHovered,
          child: AnimatedOpacity(
            opacity: isHovered ? 1 : 0,
            duration: const Duration(milliseconds: 140),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending) ...[
                  _buildAlertHoverButton(
                    label: 'Modify',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.primary
                        : WebColors.primary,
                    onPressed: isProcessing && _isProcessingModify
                        ? null
                        : () => _handleModifyAlert(alert),
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildAlertHoverButton(
                    label: 'Cancel',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode
                        ? WebDarkColors.error
                        : WebColors.error,
                    onPressed: isProcessing && _isProcessingCancel
                        ? null
                        : () => _handleCancelAlert(alert),
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSortIcon(int columnIndex, ThemesProvider theme) {
    IconData icon;
    Color color;

    if (_alertSortColumnIndex == columnIndex) {
      // Column is currently sorted
      icon = _alertSortAscending ? Icons.arrow_upward : Icons.arrow_downward;
      color = theme.isDarkMode ? WebDarkColors.primary : WebColors.primary;
    } else {
      // Column is not sorted
      icon = Icons.unfold_more;
      color = theme.isDarkMode
          ? WebDarkColors.iconSecondary.withOpacity(0.6)
          : WebColors.iconSecondary.withOpacity(0.6);
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  Widget _buildAlertTextCell(
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
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildAlertHoverButton({
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: WebTextStyles.custom(
            fontSize: 12,
            isDarkTheme: theme.isDarkMode,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getAlertStatusColor(String status, ThemesProvider theme) {
    switch (status.toUpperCase()) {
      case 'TRIGGERED':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'PENDING':
        return colors.pending;
      default:
        return theme.isDarkMode
            ? WebDarkColors.textPrimary
            : WebColors.textPrimary;
    }
  }



  // Helper function to parse BrokerMessage dmsg
  Map<String, String> _parseBrokerMessage(BrokerMessage alert) {
    final dmsg = alert.dmsg ?? '';
    final result = <String, String>{
      'instrument': '',
      'exchange': '',
      'target': '',
      'ltp': '',
    };
    
    if (dmsg.isEmpty) return result;
    
    // Try to extract instrument and exchange (e.g., "RELIANCE NSE", "YESBANK NSE")
    final exchangeMatch = RegExp(r'\b(NSE|BSE|MCX|NCDEX)\b', caseSensitive: false).firstMatch(dmsg);
    if (exchangeMatch != null) {
      result['exchange'] = exchangeMatch.group(1) ?? '';
      
      // Extract instrument name before exchange
      final exchangeIndex = dmsg.indexOf(exchangeMatch.group(0)!);
      if (exchangeIndex > 0) {
        final beforeExchange = dmsg.substring(0, exchangeIndex).trim();
        // Extract the last word/phrase before exchange (likely the instrument name)
        final words = beforeExchange.split(RegExp(r'\s+'));
        if (words.isNotEmpty) {
          // Take the last meaningful word (skip common words like "for", "at", etc.)
          for (int i = words.length - 1; i >= 0; i--) {
            final word = words[i].trim();
            if (word.isNotEmpty && 
                !word.toLowerCase().contains('for') && 
                !word.toLowerCase().contains('at') &&
                !word.toLowerCase().contains('above') &&
                !word.toLowerCase().contains('below')) {
              result['instrument'] = word;
              break;
            }
          }
        }
      }
    }
    
    // Try to extract target price (numbers after "above" or "below")
    final priceMatch = RegExp(r'(?:above|below)\s+([\d,]+\.?\d*)', caseSensitive: false).firstMatch(dmsg);
    if (priceMatch != null) {
      result['target'] = priceMatch.group(1)?.replaceAll(',', '') ?? '';
    }
    
    // Try to extract LTP if mentioned
    final ltpMatch = RegExp(r'ltp[:\s]+([\d,]+\.?\d*)', caseSensitive: false).firstMatch(dmsg);
    if (ltpMatch != null) {
      result['ltp'] = ltpMatch.group(1)?.replaceAll(',', '') ?? '';
    }
    
    return result;
  }


  DataCell _buildExchangeCell(dynamic alert, ThemesProvider theme) {
    String exchange = '';
    if (alert is BrokerMessage) {
      final parsed = _parseBrokerMessage(alert);
      exchange = parsed['exchange'] ?? '';
      if (exchange.isEmpty) {
        exchange = 'N/A';
      }
    } else {
      exchange = alert.exch ?? '';
    }
    
    return DataCell(
      Text(
        exchange,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildAlertTypeCell(dynamic alert, ThemesProvider theme) {
    String alertType = '';
    Color alertColor = colors.pending;
    
    if (alert is BrokerMessage) {
      alertType = 'TRIGGERED';
      alertColor = theme.isDarkMode ? colors.primaryDark : colors.primaryLight;
    } else {
      switch (alert.aiT) {
        case 'LTP_A':
          alertType = 'LTP Above';
          alertColor = theme.isDarkMode ? colors.profitDark : colors.profitLight;
          break;
        case 'LTP_B':
          alertType = 'LTP Below';
          alertColor = theme.isDarkMode ? colors.lossDark : colors.lossLight;
          break;
        case 'CH_PER_A':
          alertType = 'Perc.Change Above';
          alertColor = theme.isDarkMode ? colors.profitDark : colors.profitLight;
          break;
        case 'CH_PER_B':
          alertType = 'Perc.Change Below';
          alertColor = theme.isDarkMode ? colors.lossDark : colors.lossLight;
          break;
        default:
          alertType = 'Unknown';
      }
    }
    
    return DataCell(
      Text(
        alertType,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: alertColor,
        ),
      ),
    );
  }

  DataCell _buildTargetCell(dynamic alert, ThemesProvider theme) {
    String target = '';
    
    if (alert is BrokerMessage) {
      final parsed = _parseBrokerMessage(alert);
      target = parsed['target'] ?? '';
      if (target.isEmpty) {
        target = 'N/A';
      }
    } else {
      if (alert.aiT == "CH_PER_A" || alert.aiT == "CH_PER_B") {
        target = "%${alert.d}";
      } else {
        target = "${alert.d}";
      }
    }
    
    return DataCell(
      Text(
        target,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildLTPCell(dynamic alert, ThemesProvider theme) {
    String ltp = '';
    String change = '';
    
    if (alert is BrokerMessage) {
      final parsed = _parseBrokerMessage(alert);
      ltp = parsed['ltp'] ?? '';
      if (ltp.isEmpty) {
        ltp = 'N/A';
      }
    } else {
      ltp = "${alert.ltp ?? alert.close ?? 0.00}";
      change = " (${alert.perChange ?? 0.00}%)";
    }
    
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ltp,
            style: WebTextStyles.tableDataCompact(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
          ),
          if (change.isNotEmpty)
            Text(
              change,
              style: WebTextStyles.tableDataCompact(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  DataCell _buildStatusCell(dynamic alert, ThemesProvider theme) {
    String status = '';
    Color statusColor = colors.pending;
    
    if (alert is BrokerMessage) {
      status = 'TRIGGERED';
      statusColor = theme.isDarkMode ? colors.primaryDark : colors.primaryLight;
    } else {
      status = 'PENDING';
      statusColor = colors.pending;
    }
    
    return DataCell(
      Text(
        status,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: statusColor,
        ),
      ),
    );
  }


  // Action handlers
  Future<void> _handleCancelAlert(AlertPendingModel alert) async {
    final uniqueId = alert.alId?.toString() ?? alert.token?.toString() ?? '';
    if (_isProcessingCancel && _processingAlertToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingCancel = true;
        _processingAlertToken = uniqueId;
      });

      final String alertId = "${alert.alId}";
      await ref.read(marketWatchProvider).fetchCancelAlert(alertId, context);
      await ref.read(marketWatchProvider).fetchPendingAlert(context);

      if (mounted) {
        ResponsiveSnackBar.showSuccess(context, 'Alert Cancelled');
      }
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to cancel alert');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCancel = false;
          _processingAlertToken = null;
        });
      }
    }
  }

  Future<void> _handleModifyAlert(AlertPendingModel alert) async {
    final uniqueId = alert.alId?.toString() ?? alert.token?.toString() ?? '';
    if (_isProcessingModify && _processingAlertToken == uniqueId) return;

    try {
      setState(() {
        _isProcessingModify = true;
        _processingAlertToken = uniqueId;
      });

      // Open modify alert dialog
      showDialog(
        context: context,
        builder: (context) => PendingAlertDetailScreenWeb(alert: alert),
      );
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(context, 'Failed to open modify alert: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingModify = false;
          _processingAlertToken = null;
        });
      }
    }
  }

}

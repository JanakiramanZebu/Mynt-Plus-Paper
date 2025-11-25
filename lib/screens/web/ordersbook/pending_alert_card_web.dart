import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  
  // Responsive breakpoints
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;
  
  // WebSocket subscription for real-time updates
  StreamSubscription? _socketSubscription;
  
  // Throttling properties
  DateTime _lastSocketUpdateTime = DateTime.now();
  static const Duration _minUpdateInterval = Duration(milliseconds: 50);
  
  // Hover state
  String? _hoveredRowToken;
  
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

    // Filter broker messages that are related to alerts
    triggeredAlerts = notification.brokermsg
            ?.where((msg) =>
                msg.dmsg != null &&
                msg.dmsg!.contains("Ltp") &&
                (msg.dmsg!.contains("above") || msg.dmsg!.contains("below")))
            .toList() ??
        [];

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
  Map<String, dynamic> _getResponsiveAlertColumns(double screenWidth) {
    if (screenWidth < _mobileBreakpoint) {
      // Mobile: Show only essential columns
      return {
        'headers': ['Instrument', 'Alert Type', 'Target', 'Status'],
        'columnFlex': {
          'Instrument': 3,
          'Alert Type': 2,
          'Target': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Instrument': 150,
          'Alert Type': 130,
          'Target': 90,
          'Status': 90,
        },
      };
    } else if (screenWidth < _tabletBreakpoint) {
      // Tablet: Show most columns
      return {
        'headers': ['Instrument', 'Alert Type', 'Target', 'LTP', 'Status'],
        'columnFlex': {
          'Instrument': 3,
          'Alert Type': 2,
          'Target': 2,
          'LTP': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Instrument': 160,
          'Alert Type': 140,
          'Target': 95,
          'LTP': 100,
          'Status': 100,
        },
      };
    } else {
      // Desktop: Full columns with optimal widths
      return {
        'headers': ['Instrument', 'Exchange', 'Alert Type', 'Target', 'LTP', 'Status'],
        'columnFlex': {
          'Instrument': 3,
          'Exchange': 2,
          'Alert Type': 2,
          'Target': 2,
          'LTP': 2,
          'Status': 2,
        },
        'columnMinWidth': {
          'Instrument': 170,
          'Exchange': 100,
          'Alert Type': 150,
          'Target': 100,
          'LTP': 110,
          'Status': 110,
        },
      };
    }
  }

  Widget _buildAlertTable(List<dynamic> alerts, ThemesProvider theme) {
    if (alerts.isEmpty) {
      return SizedBox(
        height: 400,
        child: const Align(
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
        // Get screen width for responsive design
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Get responsive column configuration
        final responsiveConfig = _getResponsiveAlertColumns(screenWidth);
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
                          final columnIndex = _getAlertColumnIndexForHeader(label);

                          return _buildAlertColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildAlertHeaderWidget(
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
                        final columnIndex = _getAlertColumnIndexForHeader(label);

                        return _buildAlertColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildAlertHeaderWidget(
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
                child: _buildAlertBodyList(
                  theme,
                  alerts,
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

  Widget _buildAlertHeaderWidget(
    String label,
    int columnIndex,
    ThemesProvider theme,
  ) {
    return InkWell(
      onTap: () => _onSortAlertTable(columnIndex),
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
          if (_alertSortColumnIndex == columnIndex)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                _alertSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
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

  Widget _buildAlertColumnCell({
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

  Widget _buildAlertBodyList(
    ThemesProvider theme,
    List<dynamic> alerts,
    List<String> headers,
    Map<String, int> columnFlex,
    Map<String, double> columnMinWidth, {
    required double totalMinWidth,
    required bool needHorizontalScroll,
  }) {
    final sorted = _getSortedAlerts(alerts);
    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final alert = sorted[index];
        
        // Create unique identifier for hover
        String uniqueId;
        if (alert is BrokerMessage) {
          uniqueId = 'triggered_${alert.norentm ?? index}';
        } else {
          uniqueId = '${alert.alId ?? alert.token ?? index}';
        }
        final isHovered = _hoveredRowToken == uniqueId;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowToken = uniqueId),
          onExit: (_) => setState(() => _hoveredRowToken = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Only show detail dialog for pending alerts, not triggered ones
              if (alert is! BrokerMessage) {
                showDialog(
                  context: context,
                  builder: (context) => PendingAlertDetailScreenWeb(alert: alert),
                );
              }
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
                          return _buildAlertColumnCell(
                            needHorizontalScroll: needHorizontalScroll,
                            flex: flex,
                            minW: minW,
                            child: _buildAlertCellWidget(
                              label,
                              alert,
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
                        return _buildAlertColumnCell(
                          needHorizontalScroll: needHorizontalScroll,
                          flex: flex,
                          minW: minW,
                          child: _buildAlertCellWidget(
                            label,
                            alert,
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

  Widget _buildAlertCellWidget(
    String column,
    dynamic alert,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId, {
    required bool needHorizontalScroll,
  }) {
    switch (column) {
      case 'Instrument':
        return _buildAlertInstrumentWidget(
          alert,
          theme,
          isHovered,
          uniqueId,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Exchange':
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
        return _buildAlertTextCell(
          exchange,
          theme,
          Alignment.centerLeft,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Alert Type':
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
        return _buildAlertTextCell(
          alertType,
          theme,
          Alignment.centerLeft,
          color: alertColor,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'Target':
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
        return _buildAlertTextCell(
          target,
          theme,
          Alignment.centerRight,
          needHorizontalScroll: needHorizontalScroll,
        );
      case 'LTP':
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
        
        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ltp,
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
                  overflow: TextOverflow.visible,
                ),
                if (change.isNotEmpty)
                  Text(
                    change,
                    style: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                      fontWeight: WebFonts.medium,
                    ),
                  ),
              ],
            ),
          ),
        );
      case 'Status':
        String status = '';
        Color statusColor = colors.pending;
        
        if (alert is BrokerMessage) {
          status = 'TRIGGERED';
          statusColor = theme.isDarkMode ? colors.primaryDark : colors.primaryLight;
        } else {
          status = 'PENDING';
          statusColor = colors.pending;
        }
        return _buildAlertTextCell(
          status,
          theme,
          Alignment.centerLeft,
          color: statusColor,
          needHorizontalScroll: needHorizontalScroll,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAlertInstrumentWidget(
    dynamic alert,
    ThemesProvider theme,
    bool isHovered,
    String uniqueId, {
    required bool needHorizontalScroll,
  }) {
    String symbol = '';
    String exchange = '';
    
    if (alert is BrokerMessage) {
      final parsed = _parseBrokerMessage(alert);
      symbol = parsed['instrument'] ?? '';
      exchange = parsed['exchange'] ?? '';
      
      String displayText = symbol.trim();
      if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
        displayText += ' ${exchange.trim()}';
      }
      
      // If we couldn't parse, show the notification time or a default
      if (displayText.trim().isEmpty) {
        displayText = alert.norentm ?? 'N/A';
      }
      
      return _buildAlertTextCell(
        displayText,
        theme,
        Alignment.centerLeft,
        needHorizontalScroll: needHorizontalScroll,
      );
    } else {
      // Pending alert - show with hover buttons
      final isProcessing = _processingAlertToken == uniqueId;
      
      symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';
      exchange = alert.exch ?? '';
      
      String displayText = symbol.trim();
      if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
        displayText += ' ${exchange.trim()}';
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
            // Action buttons fade in on hover
            IgnorePointer(
              ignoring: !isHovered,
              child: AnimatedOpacity(
                opacity: isHovered ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cancel button
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
                    const SizedBox(width: 6),
                    // Modify button
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
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAlertTextCell(
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
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, int columnIndex) {
    final isSorted = _alertSortColumnIndex == columnIndex;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: WebTextStyles.tableHeader(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
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

  DataCell _buildTimeCell(dynamic alert, ThemesProvider theme) {
    String timeText = '';
    if (alert is BrokerMessage) {
      timeText = alert.norentm ?? '';
    } else {
      // For pending alerts, we might not have time, use current time or empty
      timeText = '';
    }
    
    return DataCell(
      Text(
        timeText,
        style: WebTextStyles.helperText(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
        ),
      ),
    );
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

  DataCell _buildInstrumentCell(dynamic alert, ThemesProvider theme) {
    String symbol = '';
    String exchange = '';
    
    if (alert is BrokerMessage) {
      final parsed = _parseBrokerMessage(alert);
      symbol = parsed['instrument'] ?? '';
      exchange = parsed['exchange'] ?? '';
      
      String displayText = symbol.trim();
      if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
        displayText += ' ${exchange.trim()}';
      }
      
      // If we couldn't parse, show the notification time or a default
      if (displayText.trim().isEmpty) {
        displayText = alert.norentm ?? 'N/A';
      }
      
      symbol = displayText;
    } else {
      symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';
      exchange = alert.exch ?? '';
      
      String displayText = symbol.trim();
      if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
        displayText += ' ${exchange.trim()}';
      }
      symbol = displayText;
    }
    
    return DataCell(
      Text(
        symbol,
        style: WebTextStyles.tableDataCompact(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
        ),
      ),
    );
  }

  DataCell _buildInstrumentCellWithHover(AlertPendingModel alert, ThemesProvider theme, String token) {
    final alertToken = token;
    final isHovered = _hoveredRowToken == alertToken;
    final isProcessing = _processingAlertToken == alertToken;
    
    String symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';
    String exchange = alert.exch ?? '';
    
    String displayText = symbol.trim();
    if (exchange.isNotEmpty && exchange.trim().isNotEmpty) {
      displayText += ' ${exchange.trim()}';
    }

    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = alertToken),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Row(
            children: [
              // Text that takes at least 50% of width, leaves space for buttons
              Expanded(
                flex: isHovered ? 1 : 2, // When hovered, text takes less space but still visible
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
                      // Cancel button
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
                      const SizedBox(width: 6),
                      // Modify button
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

  DataCell _buildCellWithHover(dynamic alert, ThemesProvider theme, String token, DataCell cell, {Alignment alignment = Alignment.centerLeft}) {
    return DataCell(
      MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowToken = token),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: SizedBox.expand(
          child: Align(
            alignment: alignment,
            child: cell.child,
          ),
        ),
      ),
    );
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

  Widget _buildAlertHoverButton({
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
                style: WebTextStyles.buttonXs(
                  isDarkTheme: theme.isDarkMode,
                  color: color,
                  fontWeight: WebFonts.semiBold,
                ),
              ),
            ),
          ),
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

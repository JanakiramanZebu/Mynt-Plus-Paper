import 'dart:async';
import 'package:flutter/material.dart' show RefreshIndicator, SizedBox, Align, Padding, LayoutBuilder, MediaQuery, Column, Expanded, Scrollbar, SingleChildScrollView, ScrollController, Axis, ValueKey, Row, MainAxisSize, MainAxisAlignment, CrossAxisAlignment, Text, TextStyle, TextDirection, TextPainter, TextSpan, FontWeight, Color, EdgeInsets, Alignment, TextOverflow, Curves, AnimatedContainer, IgnorePointer, AnimatedOpacity, GestureDetector, HitTestBehavior, MouseRegion, InkWell, Icons, VoidCallback, Icon, Container, BoxDecoration, BorderRadius, Border, BorderSide, CircularProgressIndicator, Center, Widget, BuildContext, IconData, Colors, WidgetsBinding, Material, BoxConstraints, IntrinsicWidth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../models/notification_model/broker_message_model.dart';
import '../../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/notification_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/thems.dart';
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

class _PendingAlertWebState extends ConsumerState<PendingAlertWeb> {
  List<BrokerMessage>? triggeredAlerts;
  
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
    // Check if widget is still mounted before accessing providers
    if (!mounted) return;
    
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


  Widget _buildAlertTable(List<dynamic> alerts, ThemesProvider theme) {
    if (alerts.isEmpty) {
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

    // Sort alerts
    final sortedAlerts = _getSortedAlerts(alerts);

    return SizedBox.expand(
      child: shadcn.OutlinedContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate minimum widths dynamically based on actual content
            final minWidths = _calculateMinWidths(sortedAlerts, context);

            // Available width
            final availableWidth = constraints.maxWidth;
            
            // Step 1: Start with minimum widths (content-based, no wasted space)
            final columnWidths = <int, double>{};
            for (int i = 0; i < 6; i++) {
              columnWidths[i] = minWidths[i] ?? 100.0;
            }

            // Step 2: Calculate total minimum width needed
            final totalMinWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
            
            // Step 3: If there's extra space, distribute it proportionally
            if (totalMinWidth < availableWidth) {
              final extraSpace = availableWidth - totalMinWidth;
              
              const instrumentGrowthFactor = 2.5;
              const textGrowthFactor = 1.2;
              const numericGrowthFactor = 1.0;
              
              final growthFactors = <int, double>{};
              double totalGrowthFactor = 0.0;
              
              for (int i = 0; i < 6; i++) {
                if (i == 0) {
                  // Instrument
                  growthFactors[i] = instrumentGrowthFactor;
                  totalGrowthFactor += instrumentGrowthFactor;
                } else if (i == 1 || i == 2 || i == 5) {
                  // Exchange, Alert Type, Status
                  growthFactors[i] = textGrowthFactor;
                  totalGrowthFactor += textGrowthFactor;
                } else {
                  // Target, LTP
                  growthFactors[i] = numericGrowthFactor;
                  totalGrowthFactor += numericGrowthFactor;
                }
              }
              
              if (totalGrowthFactor > 0) {
                for (int i = 0; i < 6; i++) {
                  if (growthFactors[i]! > 0) {
                    final extraForThisColumn = (extraSpace * growthFactors[i]!) / totalGrowthFactor;
                    columnWidths[i] = columnWidths[i]! + extraForThisColumn;
                  }
                }
              }
            }

            final totalRequiredWidth = columnWidths.values.fold<double>(0.0, (sum, width) => sum + width);
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
                      3: shadcn.FixedTableSize(columnWidths[3]!),
                      4: shadcn.FixedTableSize(columnWidths[4]!),
                      5: shadcn.FixedTableSize(columnWidths[5]!),
                    },
                    defaultRowHeight: const shadcn.FixedTableSize(40),
                    rows: [
                      shadcn.TableHeader(
                        cells: [
                          buildHeaderCell('Instrument', 0),
                          buildHeaderCell('Exchange', 1),
                          buildHeaderCell('Alert Type', 2),
                          buildHeaderCell('Target', 3, true),
                          buildHeaderCell('LTP', 4, true),
                          buildHeaderCell('Status', 5),
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
                        child: shadcn.Table(
                          key: ValueKey('table_${_alertSortColumnIndex}_$_alertSortAscending'),
                          columnWidths: {
                            0: shadcn.FixedTableSize(columnWidths[0]!),
                            1: shadcn.FixedTableSize(columnWidths[1]!),
                            2: shadcn.FixedTableSize(columnWidths[2]!),
                            3: shadcn.FixedTableSize(columnWidths[3]!),
                            4: shadcn.FixedTableSize(columnWidths[4]!),
                            5: shadcn.FixedTableSize(columnWidths[5]!),
                          },
                          defaultRowHeight: const shadcn.FixedTableSize(40),
                          rows: sortedAlerts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final alert = entry.value;
                            final uniqueId = alert is BrokerMessage
                                ? 'triggered_${alert.norentm ?? index}'
                                : '${alert.alId ?? alert.token ?? index}';
                            final isRowHovered = _hoveredRowToken == uniqueId;

                            return shadcn.TableRow(
                              cells: [
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  onTap: () => _showAlertDetail(alert),
                                  child: _buildInstrumentCell(alert, theme, isRowHovered, uniqueId),
                                ),
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 1,
                                  onTap: () => _showAlertDetail(alert),
                                  child: _buildExchangeCell(alert, theme),
                                ),
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 2,
                                  onTap: () => _showAlertDetail(alert),
                                  child: _buildAlertTypeCell(alert, theme),
                                ),
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 3,
                                  alignRight: true,
                                  onTap: () => _showAlertDetail(alert),
                                  child: _buildTargetCell(alert, theme),
                                ),
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 4,
                                  alignRight: true,
                                  onTap: () => _showAlertDetail(alert),
                                  child: _buildLTPCell(alert, theme),
                                ),
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 5,
                                  onTap: () => _showAlertDetail(alert),
                                  child: _buildStatusCell(alert, theme),
                                ),
                              ],
                            );
                          }).toList(),
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

  // Helper method to ensure Geist font is always applied
  TextStyle _geistTextStyle({Color? color, double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: 'Geist',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
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
    final isLastColumn = columnIndex == 5;
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
        onEnter: (_) => setState(() {
          final alert = _getSortedAlerts(_getAllAlerts())[rowIndex];
          final uniqueId = alert is BrokerMessage
              ? 'triggered_${alert.norentm ?? rowIndex}'
              : '${alert.alId ?? alert.token ?? rowIndex}';
          _hoveredRowToken = uniqueId;
        }),
        onExit: (_) => setState(() => _hoveredRowToken = null),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
            alignment: alignRight ? Alignment.topRight : null,
            child: child,
          ),
        ),
      ),
    );
  }

  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex, [bool alignRight = false]) {
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 5;
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
        onTap: () => _onSortAlertTable(columnIndex),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _alertSortColumnIndex == columnIndex)
                Icon(
                  _alertSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _alertSortColumnIndex == columnIndex) const SizedBox(width: 4),
              Text(
                label,
                style: _geistTextStyle(
                  color: shadcn.Theme.of(context).colorScheme.foreground,
                ),
              ),
              if (!alignRight && _alertSortColumnIndex == columnIndex) const SizedBox(width: 4),
              if (!alignRight && _alertSortColumnIndex == columnIndex)
                Icon(
                  _alertSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
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
  Map<int, double> _calculateMinWidths(List<dynamic> alerts, BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14, fontFamily: 'Geist');
    const padding = 24.0;
    const sortIconWidth = 24.0;

    final headers = [
      'Instrument',
      'Exchange',
      'Alert Type',
      'Target',
      'LTP',
      'Status',
    ];
    final minWidths = <int, double>{};

    for (int col = 0; col < headers.length; col++) {
      double maxWidth = 0.0;
      final headerWidth = _measureTextWidth(headers[col], textStyle);
      maxWidth = headerWidth + sortIconWidth;

      for (final alert in alerts.take(5)) {
        String cellText = '';
        switch (col) {
          case 0: // Instrument
            if (alert is BrokerMessage) {
              cellText = 'N/A';
            } else {
              final symbol = (alert.tsym ?? '').replaceAll("-EQ", "").trim();
              final exchange = alert.exch ?? '';
              cellText = exchange.isNotEmpty ? '$symbol $exchange' : symbol;
            }
            break;
          case 1: // Exchange
            cellText = alert is BrokerMessage ? 'N/A' : (alert.exch ?? 'N/A');
            break;
          case 2: // Alert Type
            if (alert is BrokerMessage) {
              cellText = 'TRIGGERED';
            } else {
              switch (alert.aiT) {
                case 'LTP_A': cellText = 'LTP Above'; break;
                case 'LTP_B': cellText = 'LTP Below'; break;
                case 'CH_PER_A': cellText = 'Perc.Change Above'; break;
                case 'CH_PER_B': cellText = 'Perc.Change Below'; break;
                default: cellText = 'Unknown';
              }
            }
            break;
          case 3: // Target
            if (alert is BrokerMessage) {
              cellText = 'N/A';
            } else {
              if (alert.aiT == "CH_PER_A" || alert.aiT == "CH_PER_B") {
                cellText = "%${alert.d ?? '0.00'}";
              } else {
                cellText = "${alert.d ?? '0.00'}";
              }
            }
            break;
          case 4: // LTP
            cellText = alert is BrokerMessage 
                ? 'N/A' 
                : "${alert.ltp ?? alert.close ?? '0.00'}";
            break;
          case 5: // Status
            cellText = alert is BrokerMessage ? 'TRIGGERED' : 'PENDING';
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
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  // Helper to get all alerts for hover detection
  List<dynamic> _getAllAlerts() {
    final manage = ref.read(marketWatchProvider);
    final notification = ref.read(notificationprovider);
    final order = ref.read(orderProvider);
    
    final isSearching = order.orderSearchCtrl.text.isNotEmpty;
    final pendingAlerts = isSearching
        ? manage.alertPendingSearch ?? []
        : manage.alertPendingModel ?? [];
    
    List<BrokerMessage>? triggered;
    if (isSearching) {
      triggered = notification.triggeredAlertSearch ?? [];
    } else {
      triggered = notification.brokermsg
          ?.where((msg) =>
              msg.dmsg != null &&
              msg.dmsg!.contains("Ltp") &&
              (msg.dmsg!.contains("above") || msg.dmsg!.contains("below")))
          .toList();
    }
    
    return [
      ...pendingAlerts,
      ...(triggered ?? [])
    ];
  }

  void _showAlertDetail(dynamic alert) {
    // Only show detail sheet for pending alerts, not triggered ones
    if (alert is! BrokerMessage) {
      shadcn.openSheet(
        context: context,
        builder: (sheetContext) => PendingAlertDetailScreenWeb(alert: alert),
        position: shadcn.OverlayPosition.end,
      );
    }
  }

  Widget _buildInstrumentCell(
    dynamic alert,
    ThemesProvider theme,
    bool isRowHovered,
    String uniqueId,
  ) {
    final isProcessing = _processingAlertToken == uniqueId;
    final isPending = alert is! BrokerMessage;
    final colorScheme = shadcn.Theme.of(context).colorScheme;

    String symbol = '';
    String exchange = '';
    if (alert is BrokerMessage) {
      symbol = 'N/A';
      exchange = '';
    } else {
      symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';
      exchange = alert.exch ?? '';
    }

    return Row(
      children: [
        // Instrument name - symbol (normal color) + exchange (grey)
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                symbol,
                style: _geistTextStyle(
                  color: colorScheme.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (exchange.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  exchange,
                  style: _geistTextStyle(
                    color: colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Action buttons - appear on hover
        AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: isRowHovered ? null : 0,
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: !isRowHovered,
            child: AnimatedOpacity(
              opacity: isRowHovered ? 1 : 0,
              duration: const Duration(milliseconds: 140),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
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
        ),
      ],
    );
  }

  Widget _buildExchangeCell(dynamic alert, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final exchange = alert is BrokerMessage ? 'N/A' : (alert.exch ?? 'N/A');
    
    return Text(
      exchange,
      style: _geistTextStyle(
        color: colorScheme.foreground,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAlertTypeCell(dynamic alert, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    String alertType = '';
    Color alertColor = colorScheme.mutedForeground;
    
    if (alert is BrokerMessage) {
      alertType = 'TRIGGERED';
      alertColor = colorScheme.chart2; // Green for triggered
    } else {
      switch (alert.aiT) {
        case 'LTP_A':
          alertType = 'LTP Above';
          alertColor = colorScheme.chart2; // Green
          break;
        case 'LTP_B':
          alertType = 'LTP Below';
          alertColor = colorScheme.destructive; // Red
          break;
        case 'CH_PER_A':
          alertType = 'Perc.Change Above';
          alertColor = colorScheme.chart2; // Green
          break;
        case 'CH_PER_B':
          alertType = 'Perc.Change Below';
          alertColor = colorScheme.destructive; // Red
          break;
        default:
          alertType = 'Unknown';
      }
    }
    
    return Text(
      alertType,
      style: _geistTextStyle(
        color: alertColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTargetCell(dynamic alert, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
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
    
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        target,
        style: _geistTextStyle(
          color: colorScheme.foreground,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLTPCell(dynamic alert, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final ltp = alert is BrokerMessage 
        ? 'N/A' 
        : "${alert.ltp ?? alert.close ?? '0.00'}";
    
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        ltp,
        style: _geistTextStyle(
          color: colorScheme.foreground,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(dynamic alert, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final status = alert is BrokerMessage ? 'TRIGGERED' : 'PENDING';
    final statusColor = _getAlertStatusColor(status, theme);
    
    return Text(
      status,
      style: _geistTextStyle(
        color: statusColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAlertHoverButton({
    String? label,
    IconData? icon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    double? iconWeight,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
    final borderRadiusValue = borderRadius ?? 5.0;
    final effectiveIconWeight = iconWeight ?? 400.0;

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.08),
        onTap: onPressed,
        child: Container(
          padding: isLongLabel
              ? const EdgeInsets.symmetric(horizontal: 8)
              : EdgeInsets.zero,
          constraints: BoxConstraints(
            minHeight: 25,
            minWidth: isLongLabel ? 0 : 25,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadiusValue),
            border: borderColor != null
                ? Border.all(
                    color: borderColor,
                    width: 1.3,
                  )
                : null,
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 16,
                    color: color,
                    weight: effectiveIconWeight,
                  )
                : Text(
                    label ?? "",
                    style: WebTextStyles.buttonXs(
                      isDarkTheme: theme.isDarkMode,
                      color: color,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
          ),
        ),
      ),
    );

    if (isLongLabel) {
      return IntrinsicWidth(
        child: SizedBox(
          height: 25,
          child: button,
        ),
      );
    } else {
      return SizedBox(
        width: 25,
        height: 25,
        child: button,
      );
    }
  }

  Color _getAlertStatusColor(String status, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    switch (status.toUpperCase()) {
      case 'TRIGGERED':
        return colorScheme.chart2; // Green/success
      case 'PENDING':
        return colorScheme.chart1; // Orange/warning
      default:
        return colorScheme.mutedForeground;
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

      // Open modify alert sheet
      shadcn.openSheet(
        context: context,
        builder: (sheetContext) => PendingAlertDetailScreenWeb(alert: alert),
        position: shadcn.OverlayPosition.end,
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

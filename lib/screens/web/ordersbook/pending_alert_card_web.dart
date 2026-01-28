import 'dart:async';
import 'package:flutter/material.dart'
    show
        RefreshIndicator,
        SizedBox,
        Align,
        Padding,
        LayoutBuilder,
        MediaQuery,
        Column,
        Expanded,
        Flexible,
        SingleChildScrollView,
        ScrollController,
        Axis,
        ValueKey,
        Row,
        MainAxisSize,
        MainAxisAlignment,
        Text,
        TextStyle,
        TextDirection,
        TextPainter,
        TextSpan,
        FontWeight,
        Color,
        EdgeInsets,
        Alignment,
        TextOverflow,
        GestureDetector,
        HitTestBehavior,
        MouseRegion,
        InkWell,
        Icons,
        VoidCallback,
        Icon,
        Container,
        BoxDecoration,
        BorderRadius,
        Border,
        BorderSide,
        Center,
        Widget,
        BuildContext,
        IconData,
        Colors,
        WidgetsBinding,
        Material,
        BoxConstraints,
        IntrinsicWidth,
        BoxShadow,
        RawScrollbar,
        Radius,
        Offset,
        TextButton,
        RoundedRectangleBorder,
        Dialog,
        Navigator,
        showDialog,
        RichText,
        TextAlign,
        ValueNotifier,
        ValueListenableBuilder,
        Stack,
        Positioned,
        Clip,
        LinearGradient;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

import '../../../res/mynt_web_color_styles.dart' as styles;
import '../../../res/mynt_web_text_styles.dart';

import '../../../models/notification_model/broker_message_model.dart';
import '../../../models/marketwatch_model/alert_model/alert_pending_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/notification_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/thems.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../sharedWidget/hover_actions_web.dart';
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

  // Hover state - Use ValueNotifier for performance
  final ValueNotifier<String?> _hoveredRowToken = ValueNotifier<String?>(null);

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
    _hoveredRowToken.dispose();
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
              task: "d", // Subscribe with depth for web
              context: context,
            );
      }
    } catch (e) {
      print("Error subscribing to alert tokens: $e");
    }
  }

  // Helper method to determine font size based on screen width
  double _getResponsiveFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 1000) {
      return 11.0;
    } else if (width < 1300) {
      return 12.0;
    }
    return 14.0;
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
          String aInstrument = a is BrokerMessage
              ? 'N/A'
              : (a.tsym?.replaceAll("-EQ", "") ?? 'N/A');
          String bInstrument = b is BrokerMessage
              ? 'N/A'
              : (b.tsym?.replaceAll("-EQ", "") ?? 'N/A');
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
              case 'LTP_A':
                aType = 'LTP Above';
                break;
              case 'LTP_B':
                aType = 'LTP Below';
                break;
              case 'CH_PER_A':
                aType = 'Perc.Change Above';
                break;
              case 'CH_PER_B':
                aType = 'Perc.Change Below';
                break;
              default:
                aType = 'Unknown';
            }
          }
          if (b is BrokerMessage) {
            bType = 'TRIGGERED';
          } else {
            switch (b.aiT) {
              case 'LTP_A':
                bType = 'LTP Above';
                break;
              case 'LTP_B':
                bType = 'LTP Below';
                break;
              case 'CH_PER_A':
                bType = 'Perc.Change Above';
                break;
              case 'CH_PER_B':
                bType = 'Perc.Change Below';
                break;
              default:
                bType = 'Unknown';
            }
          }
          r = cmp<String>(aType, bType);
          break;
        case 3: // Target
          if (a is BrokerMessage || b is BrokerMessage) {
            String aTarget = a is BrokerMessage
                ? 'N/A'
                : (a.aiT == "CH_PER_A" || a.aiT == "CH_PER_B"
                    ? "%${a.d}"
                    : "${a.d}");
            String bTarget = b is BrokerMessage
                ? 'N/A'
                : (b.aiT == "CH_PER_A" || b.aiT == "CH_PER_B"
                    ? "%${b.d}"
                    : "${b.d}");
            r = cmp<String>(aTarget, bTarget);
          } else {
            num aTarget = parseNum("${a.d ?? 0}");
            num bTarget = parseNum("${b.d ?? 0}");
            r = aTarget.compareTo(bTarget);
          }
          break;
        case 4: // LTP
          if (a is BrokerMessage || b is BrokerMessage) {
            String aLtp =
                a is BrokerMessage ? 'N/A' : "${a.ltp ?? a.close ?? 0.00}";
            String bLtp =
                b is BrokerMessage ? 'N/A' : "${b.ltp ?? b.close ?? 0.00}";
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
            child: NoDataFound(secondaryEnabled: false),
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
            final totalMinWidth = columnWidths.values
                .fold<double>(0.0, (sum, width) => sum + width);

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
                      3: shadcn.FixedTableSize(columnWidths[3]!),
                      4: shadcn.FixedTableSize(columnWidths[4]!),
                      5: shadcn.FixedTableSize(columnWidths[5]!),
                    },
                    defaultRowHeight: const shadcn.FixedTableSize(50),
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
                    child: RawScrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      trackColor: resolveThemeColor(context,
                          dark: Colors.grey.withOpacity(0.1),
                          light: Colors.grey.withOpacity(0.1)),
                      thumbColor: resolveThemeColor(context,
                          dark: Colors.grey.withOpacity(0.3),
                          light: Colors.grey.withOpacity(0.3)),
                      thickness: 6,
                      radius: const Radius.circular(3),
                      interactive: true,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: shadcn.Table(
                          key: ValueKey(
                              'table_${_alertSortColumnIndex}_$_alertSortAscending'),
                          columnWidths: {
                            0: shadcn.FixedTableSize(columnWidths[0]!),
                            1: shadcn.FixedTableSize(columnWidths[1]!),
                            2: shadcn.FixedTableSize(columnWidths[2]!),
                            3: shadcn.FixedTableSize(columnWidths[3]!),
                            4: shadcn.FixedTableSize(columnWidths[4]!),
                            5: shadcn.FixedTableSize(columnWidths[5]!),
                          },
                          defaultRowHeight: const shadcn.FixedTableSize(50),
                          rows: sortedAlerts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final alert = entry.value;
                            final uniqueId = alert is BrokerMessage
                                ? 'triggered_${alert.norentm ?? index}'
                                : '${alert.alId ?? alert.token ?? index}';

                            return shadcn.TableRow(
                              cells: [
                                buildCellWithHover(
                                  rowIndex: index,
                                  columnIndex: 0,
                                  onTap: () => _showAlertDetail(alert),
                                  child: ValueListenableBuilder<String?>(
                                    valueListenable: _hoveredRowToken,
                                    builder: (context, hoveredToken, _) {
                                      final isRowHovered =
                                          hoveredToken == '$index';
                                      return _buildInstrumentCell(
                                          alert, theme, isRowHovered, uniqueId);
                                    },
                                  ),
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
              return RawScrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                trackColor: resolveThemeColor(context,
                    dark: Colors.grey.withOpacity(0.1),
                    light: Colors.grey.withOpacity(0.1)),
                thumbColor: resolveThemeColor(context,
                    dark: Colors.grey.withOpacity(0.3),
                    light: Colors.grey.withOpacity(0.3)),
                thickness: 6,
                radius: const Radius.circular(3),
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
  TextStyle _geistTextStyle(
      {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return MyntWebTextStyles.body(
      context,
      color: color,
      fontWeight: fontWeight ?? MyntFonts.medium,
    ).copyWith(fontSize: fontSize);
  }

  TextStyle _getHeaderStyle(BuildContext context, {Color? color}) {
    return MyntWebTextStyles.tableHeader(
      context,
      color: color,
      darkColor: color ?? MyntColors.textSecondaryDark,
      lightColor: color ?? MyntColors.textSecondary,
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
        onEnter: (_) => _hoveredRowToken.value = '$rowIndex',
        onExit: (_) => _hoveredRowToken.value = null,
        child: ValueListenableBuilder<String?>(
          valueListenable: _hoveredRowToken,
          builder: (context, hoveredToken, _) {
            return GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 8),
                alignment: alignRight ? Alignment.topRight : null,
                decoration: BoxDecoration(
                  color: hoveredToken == '$rowIndex'
                      ? resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ).withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  // Builds a sortable header cell
  shadcn.TableCell buildHeaderCell(String label, int columnIndex,
      [bool alignRight = false]) {
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
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (alignRight && _alertSortColumnIndex == columnIndex)
                Icon(
                  _alertSortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              if (alignRight && _alertSortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              Text(
                label,
                style: _getHeaderStyle(context),
              ),
              if (!alignRight && _alertSortColumnIndex == columnIndex)
                const SizedBox(width: 4),
              if (!alignRight && _alertSortColumnIndex == columnIndex)
                Icon(
                  _alertSortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
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
      List<dynamic> alerts, BuildContext context) {
    // Use dynamic font size for measurement
    final fontSize = _getResponsiveFontSize(context);

    final headerStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'Geist',
      fontWeight: MyntFonts.semiBold, // w600 for headers
    );
    final cellStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'Geist',
      fontWeight: MyntFonts.medium, // w500 for data cells
    );

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
      final headerWidth = _measureTextWidth(headers[col], headerStyle);
      maxWidth = headerWidth + sortIconWidth;

      for (final alert in alerts.take(20)) {
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
                case 'LTP_A':
                  cellText = 'LTP Above';
                  break;
                case 'LTP_B':
                  cellText = 'LTP Below';
                  break;
                case 'CH_PER_A':
                  cellText = 'Perc.Change Above';
                  break;
                case 'CH_PER_B':
                  cellText = 'Perc.Change Below';
                  break;
                default:
                  cellText = 'Unknown';
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

        final cellWidth = _measureTextWidth(cellText, cellStyle);
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

  void _showAlertDetail(dynamic alert) {
    // Only show detail sheet for pending alerts, not triggered ones
    if (alert is! BrokerMessage) {
      shadcn.openSheet(
        context: context,
        builder: (sheetContext) {
          final screenWidth = MediaQuery.of(sheetContext).size.width;
          final sheetWidth = screenWidth < 1300 ? screenWidth * 0.3 : 480.0;
          return Container(
            width: sheetWidth,
            decoration: BoxDecoration(
              color: resolveThemeColor(
                context,
                dark: styles.MyntColors.backgroundColorDark,
                light: styles.MyntColors.backgroundColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: PendingAlertDetailScreenWeb(alert: alert),
          );
        },
        position: shadcn.OverlayPosition.end,
        barrierColor: Colors.transparent,
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

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Instrument name - full width, can be partially covered by buttons
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  right: isRowHovered && isPending ? 140.0 : 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      symbol,
                      style: _geistTextStyle(
                        color: colorScheme.foreground,
                      ),
                      maxLines: 1,
                      overflow: isRowHovered
                          ? TextOverflow.ellipsis
                          : TextOverflow.visible,
                    ),
                  ),
                  if (exchange.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      exchange,
                      style: _geistTextStyle(
                        color: colorScheme.mutedForeground,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Action buttons - positioned at the right edge
        if (isRowHovered && isPending)
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
                  isVisible: isRowHovered && isPending,
                  actions: [
                    HoverActionButton(
                      label: 'Modify',
                      size: 54,
                      borderRadius: 5,
                      color: Colors.white,
                      onPressed: isProcessing && _isProcessingModify
                          ? null
                          : () => _handleModifyAlert(alert),
                      backgroundColor: resolveThemeColor(context,
                          dark: MyntColors.primary, light: MyntColors.primary),
                    ),
                    HoverActionButton(
                      label: 'Cancel',
                      size: 54,
                      borderRadius: 5,
                      color: Colors.white,
                      onPressed: isProcessing && _isProcessingCancel
                          ? null
                          : () => _handleCancelAlert(alert),
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
          alertColor = MyntColors.profit; // Green
          break;
        case 'LTP_B':
          alertType = 'LTP Below';
          alertColor = MyntColors.loss; // Red
          break;
        case 'CH_PER_A':
          alertType = 'Perc.Change Above';
          alertColor = MyntColors.profit; // Green
          break;
        case 'CH_PER_B':
          alertType = 'Perc.Change Below';
          alertColor = MyntColors.loss; // Red
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
    final status = alert is BrokerMessage ? 'TRIGGERED' : 'PENDING';

    // Use MyntColors for status (matching GTT orders)
    Color statusColor;
    if (status == 'TRIGGERED') {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (status == 'PENDING') {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.warning, light: MyntColors.warning);
    } else {
      statusColor = resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status.toUpperCase(),
          style: MyntWebTextStyles.bodySmall(
            context,
            color: statusColor,
            fontWeight: MyntFonts.medium,
          ),
          overflow: TextOverflow.visible,
          softWrap: false,
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
    final exchangeMatch =
        RegExp(r'\b(NSE|BSE|MCX|NCDEX)\b', caseSensitive: false)
            .firstMatch(dmsg);
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
    final priceMatch =
        RegExp(r'(?:above|below)\s+([\d,]+\.?\d*)', caseSensitive: false)
            .firstMatch(dmsg);
    if (priceMatch != null) {
      result['target'] = priceMatch.group(1)?.replaceAll(',', '') ?? '';
    }

    // Try to extract LTP if mentioned
    final ltpMatch = RegExp(r'ltp[:\s]+([\d,]+\.?\d*)', caseSensitive: false)
        .firstMatch(dmsg);
    if (ltpMatch != null) {
      result['ltp'] = ltpMatch.group(1)?.replaceAll(',', '') ?? '';
    }

    return result;
  }

  Future<bool?> _showCancelAlertDialog(AlertPendingModel alert) async {
    final symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: styles.MyntColors.backgroundColorDark,
                  light: styles.MyntColors.backgroundColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row with title and close button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cancel Alert',
                        style: MyntWebTextStyles.title(
                          context,
                          color: resolveThemeColor(context,
                              dark: styles.MyntColors.textPrimaryDark,
                              light: styles.MyntColors.textPrimary),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const shadcn.CircleBorder(),
                        child: InkWell(
                          customBorder: const shadcn.CircleBorder(),
                          onTap: () => Navigator.of(dialogContext).pop(false),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: resolveThemeColor(context,
                                  dark: styles.MyntColors.textSecondaryDark,
                                  light: styles.MyntColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content area
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Confirmation text with symbol in quotes
                      Text(
                        'Are you sure you want to cancel "$symbol"?',
                        textAlign: TextAlign.center,
                        style: MyntWebTextStyles.body(
                          context,
                          color: resolveThemeColor(context,
                              dark: styles.MyntColors.textPrimaryDark,
                              light: styles.MyntColors.textPrimary),
                        ),
                      ),

                      // Red Cancel button
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: styles.MyntColors.tertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: MyntWebTextStyles.buttonMd(
                              context,
                              color: Colors.white,
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
  }

  // Action handlers
  Future<void> _handleCancelAlert(AlertPendingModel alert) async {
    // Show confirmation dialog first
    final bool? confirm = await _showCancelAlertDialog(alert);
    if (confirm != true) return;

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
        builder: (sheetContext) {
          final screenWidth = MediaQuery.of(sheetContext).size.width;
          final sheetWidth = screenWidth < 1300 ? screenWidth * 0.3 : 480.0;
          return Container(
            width: sheetWidth,
            decoration: BoxDecoration(
              color: resolveThemeColor(
                context,
                dark: styles.MyntColors.backgroundColorDark,
                light: styles.MyntColors.backgroundColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: PendingAlertDetailScreenWeb(alert: alert),
          );
        },
        position: shadcn.OverlayPosition.end,
        barrierColor: Colors.transparent,
      );
    } catch (e) {
      if (mounted) {
        ResponsiveSnackBar.showError(
            context, 'Failed to open modify alert: ${e.toString()}');
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

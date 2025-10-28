import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/notification_model/broker_message_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/notification_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/websocket_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';
import 'pending_alert_detail_screen_web.dart';

class PendingAlertWeb extends ConsumerStatefulWidget {
  const PendingAlertWeb({super.key});

  @override
  ConsumerState<PendingAlertWeb> createState() => _PendingAlertWebState();
}

class _PendingAlertWebState extends ConsumerState<PendingAlertWeb> {
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

  @override
  void initState() {
    super.initState();
    // Fetch initial data when widget is created
    _refreshData();

    // Add post-frame callback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      // Setup WebSocket subscription after data is loaded
      _setupSocketSubscription();
    });
  }

  @override
  void dispose() {
    _teardownSocketSubscription();
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
          String aTarget = a is BrokerMessage ? 'N/A' : (a.aiT == "CH_PER_A" || a.aiT == "CH_PER_B" ? "%${a.d}" : "${a.d}");
          String bTarget = b is BrokerMessage ? 'N/A' : (b.aiT == "CH_PER_A" || b.aiT == "CH_PER_B" ? "%${b.d}" : "${b.d}");
          r = cmp<String>(aTarget, bTarget);
          break;
        case 4: // LTP
          String aLtp = a is BrokerMessage ? 'N/A' : "${a.ltp ?? a.close ?? 0.00}";
          String bLtp = b is BrokerMessage ? 'N/A' : "${b.ltp ?? b.close ?? 0.00}";
          r = cmp<String>(aLtp, bLtp);
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
      return const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: NoDataFound(),
          ),
        );
    }

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: DataTable(
          showCheckboxColumn: false,
          sortColumnIndex: _alertSortColumnIndex,
          sortAscending: _alertSortAscending,
          headingRowColor: WidgetStateProperty.all(
            theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
          ),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return (theme.isDarkMode ? colors.primaryDark : colors.primaryLight).withOpacity(0.1);
              }
              return null;
            },
          ),
          columns: [
            DataColumn(
              label: _buildSortableColumnHeader('Instrument', theme,
                  isActive: _alertSortColumnIndex == 0, ascending: _alertSortAscending),
              onSort: (i, asc) => _onSortAlertTable(0),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Exchange', theme,
                  isActive: _alertSortColumnIndex == 1, ascending: _alertSortAscending),
              onSort: (i, asc) => _onSortAlertTable(1),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Alert Type', theme,
                  isActive: _alertSortColumnIndex == 2, ascending: _alertSortAscending),
              onSort: (i, asc) => _onSortAlertTable(2),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Target', theme,
                  isActive: _alertSortColumnIndex == 3, ascending: _alertSortAscending),
              onSort: (i, asc) => _onSortAlertTable(3),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('LTP', theme,
                  isActive: _alertSortColumnIndex == 4, ascending: _alertSortAscending),
              onSort: (i, asc) => _onSortAlertTable(4),
            ),
            DataColumn(
              label: _buildSortableColumnHeader('Status', theme,
                  isActive: _alertSortColumnIndex == 5, ascending: _alertSortAscending),
              onSort: (i, asc) => _onSortAlertTable(5),
            ),
          ],
          rows: alerts.asMap().entries.map((entry) {
            final index = entry.key;
            final alert = entry.value;
            
            return DataRow(
              selected: _selectedAlerts.contains(index),
             onSelectChanged: (bool? selected) {
                showDialog(
                  context: context,
                  builder: (context) => PendingAlertDetailScreenWeb(alert: alert),
                );
              },
              cells: [
                _buildInstrumentCell(alert, theme),
                _buildExchangeCell(alert, theme),
                _buildAlertTypeCell(alert, theme),
                _buildTargetCell(alert, theme),
                _buildLTPCell(alert, theme),
                _buildStatusCell(alert, theme),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme, {bool isActive = false, bool ascending = true}) {
    // Rely on DataTable's built-in sort indicator; don't render a custom arrow here
    return Text(
      label,
      style: TextWidget.textStyle(
        fontSize: 12,
        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
        theme: theme.isDarkMode,
        fw: 2,
      ),
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildInstrumentCell(dynamic alert, ThemesProvider theme) {
    String symbol = '';
    if (alert is BrokerMessage) {
      // Extract symbol from message or use default
      symbol = 'N/A'; // BrokerMessage doesn't have tsym property
    } else {
      symbol = alert.tsym?.replaceAll("-EQ", "") ?? 'N/A';
    }
    
    return DataCell(
      Text(
        symbol,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildExchangeCell(dynamic alert, ThemesProvider theme) {
    String exchange = '';
    if (alert is BrokerMessage) {
      exchange = 'N/A'; // BrokerMessage doesn't have exch property
    } else {
      exchange = alert.exch ?? '';
    }
    
    return DataCell(
      Text(
        exchange,
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: alertColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: alertColor,
            width: 1,
          ),
        ),
        child: Text(
          alertType,
          style: TextWidget.textStyle(
            fontSize: 12,
            color: alertColor,
            theme: theme.isDarkMode,
            fw: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildTargetCell(dynamic alert, ThemesProvider theme) {
    String target = '';
    
    if (alert is BrokerMessage) {
      target = 'N/A'; // Triggered alerts don't show target
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
        style: TextWidget.textStyle(
          fontSize: 12,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 2,
        ),
      ),
    );
  }

  DataCell _buildLTPCell(dynamic alert, ThemesProvider theme) {
    String ltp = '';
    String change = '';
    
    if (alert is BrokerMessage) {
      ltp = 'N/A';
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
            style: TextWidget.textStyle(
              fontSize: 12,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 2,
            ),
          ),
          if (change.isNotEmpty)
            Text(
              change,
              style: TextWidget.textStyle(
                fontSize: 12,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                theme: theme.isDarkMode,
                fw: 2,
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: statusColor,
            width: 1,
          ),
        ),
        child: Text(
          status,
          style: TextWidget.textStyle(
            fontSize: 12,
            color: statusColor,
            theme: theme.isDarkMode,
            fw: 2,
          ),
        ),
      ),
    );
  }

}

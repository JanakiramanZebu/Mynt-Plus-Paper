import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/network_state_provider.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/core/api_link.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../routes/app_routes.dart';
import '../routes/route_names.dart';
import 'auth_provider.dart';
import 'market_watch_provider.dart';
import 'notification_provider.dart';
import 'subscription_manager.dart';

final websocketProvider =
    ChangeNotifierProvider((ref) => WebSocketProvider(ref));

class WebSocketProvider extends ChangeNotifier {
  final Ref ref;
  WebSocketProvider(this.ref);

  // Constants
  static const int _maxReconnectAttempts = 8; // Increased for poor networks
  static const int _subscriptionTimeout =
      10; // Increased timeout for slow networks
  static const Duration _reconnectDelay = Duration(seconds: 2);
  static const Duration _lowBandwidthPingInterval =
      Duration(seconds: 30); // Ping to keep connection alive

  // Network quality tracking
  Timer? _pingTimer;
  DateTime? _lastMessageTime;
  bool _isLowBandwidth = false;
  int _failedPingCount = 0;
  static const int _maxFailedPings = 3;

  // State management
  bool _wsConnected = false;
  bool _connecting = false;
  int _connectionCount = 0;
  bool _retryScreen = false;
  bool _wsMount = true;
  BuildContext? _context;
  bool _reconnecting =
      false; // Track if we're already in the reconnection process
  bool _reconnectionSuccess = false; // Track if we've successfully reconnected

  // WebSocket and subscription management
  WebSocketChannel? _channel;
  Completer<void>? _connectionCompleter;
  final Map<String, Timer> _subscriptionTimers = {};
  final Map<String, dynamic> _socketDatas = {};
  final Map<String, String> _ltpCache = {}; // Cache for last known LTP values
  Timer? _holdStartTime;
  Timer? _reconnectBackoff; // Add backoff timer

  // Add StreamController
  final _socketDataController = StreamController<Map>.broadcast();
  Stream<Map> get socketDataStream => _socketDataController.stream;

  // Getters
  bool get wsConnected => _wsConnected;
  bool get retryScreen => _retryScreen;
  Map get socketDatas => _socketDatas;
  bool get reconnectionSuccess => _reconnectionSuccess;
  
  // Get cached LTP for a token
  String? getCachedLTP(String token) => _ltpCache[token];
  
  // Get best available LTP (socket > cache > fallback)
  String getBestLTP(String token, String fallbackLTP) {
    // First check if we have current socket data
    if (_socketDatas.containsKey(token) && _socketDatas[token]['lp'] != null) {
      final socketLTP = _socketDatas[token]['lp'].toString();
      if (socketLTP != "0.00" && socketLTP != "null") {
        return socketLTP;
      }
    }
    
    // Then check cached LTP
    final cachedLTP = _ltpCache[token];
    if (cachedLTP != null && cachedLTP != "0.00") {
      return cachedLTP;
    }
    
    // Finally fallback to provided value
    return fallbackLTP;
  }

  // Preferences
  final Preferences _pref = locator<Preferences>();

  int get connectioncount => _connectionCount;

  bool get retryscreen => _retryScreen;

  bool wsmount = true;

  Timer? _debounceTimer; // Added debounce timer for throttling updates

  void changeretryscreen(bool value) {
    _retryScreen = value;
    // Use post-frame callback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void changeconnectioncount() {
    _connectionCount = 0;
    // Use post-frame callback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void resetConnectionCount() {
    _connectionCount = 0;
    _reconnectionSuccess = true;

    // Use post-frame callback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    // Reset reconnection success flag after a delay to allow UI to update
    Future.delayed(const Duration(seconds: 1), () {
      _reconnectionSuccess = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  void closeSocket(bool mounted) {
    wsmount = mounted;
    _wsConnected = false;
    _connecting = false;
    _reconnecting =
        false; // Reset reconnection flag to ensure we can reconnect properly

    // Stop ping timer
    _stopPingTimer();

    // Cancel any outstanding connection completion
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter!
          .completeError("WebSocket connection closed intentionally");
    }

    // Properly close channel
    _channel?.sink.close();
    _channel = null; // Set to null to ensure we create a new one on reconnect

    // Cancel all timers to prevent further reconnection attempts
    for (var timer in _subscriptionTimers.values) {
      timer.cancel();
    }
    _subscriptionTimers.clear();

    // Cancel backoff timer if it exists
    _reconnectBackoff?.cancel();
    _reconnectBackoff = null;

    if (mounted) {
      // Use post-frame callback to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void websockConn(bool value) {
    _wsConnected = value;

    // Start ping timer if connected in potential low bandwidth
    if (value) {
      _startPingTimer();
    } else {
      _stopPingTimer();
    }

    // Use post-frame callback to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _startSubscriptionTimer(String key, BuildContext context) {
    // Cancel any existing timer for this key to avoid duplicates
    _subscriptionTimers[key]?.cancel();

    // Only start timer if we're connected
    if (_wsConnected) {
      _subscriptionTimers[key] = Timer(
        const Duration(seconds: _subscriptionTimeout),
        () => _handleSubscriptionTimeout(key, context),
      );
    }
  }

  void _handleSubscriptionTimeout(String key, BuildContext context) {
    // Only increment counter if we're not already reconnecting
    if (!_reconnecting) {
      _connectionCount++;
    }
    _subscriptionTimers.remove(key);

    if (_connectionCount < _maxReconnectAttempts) {
      reconnect(context);
    }
  }

  void _startPingTimer() {
    _stopPingTimer();
    _lastMessageTime = DateTime.now();

    // Set up a timer to ping the server periodically to keep connection alive
    _pingTimer = Timer.periodic(_lowBandwidthPingInterval, (timer) {
      if (_wsConnected && _channel != null) {
        // If we haven't received a message in a while, send a ping
        final now = DateTime.now();
        if (_lastMessageTime != null &&
            now.difference(_lastMessageTime!).inSeconds >
                _lowBandwidthPingInterval.inSeconds - 5) {
          _sendPing();
        }
      } else {
        _stopPingTimer();
      }
    });
  }

  void _sendPing() {
    try {
      if (_wsConnected && _channel != null) {
        // Send a lightweight ping message
        _channel!.sink.add(jsonEncode({"t": "h"})); // Heartbeat/ping message

        // Track failed pings
        _failedPingCount++;

        // If we've failed too many pings, try to reconnect
        if (_failedPingCount >= _maxFailedPings && !_reconnecting) {
          _isLowBandwidth = true;
          if (_context != null) {
            reconnect(_context!);
          }
        }
      }
    } catch (e) {
      // Handle ping failure
    }
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _failedPingCount = 0;
  }

  Future<void> establishConnection({
    required String channelInput,
    required String task,
    required BuildContext context,
  }) async {
    _context = context;

    // Save channel input for reconnection (only if it's a subscription request)
    if (task == "t" && channelInput.isNotEmpty) {
      ConstantName.lastSubscribe = channelInput;
    } else if (task == "d" && channelInput.isNotEmpty) {
      ConstantName.lastSubscribeDepth = channelInput;
    }

    // If already connected and we have a subscription request, process it
    if (_wsConnected) {
      if (channelInput.isNotEmpty) {
        _handleSubscription(channelInput, task, context);
      }
      return;
    }

    // If connection already in progress, wait for it to complete
    if (_connecting) {
      try {
        // Use a shorter timeout for waiting on an existing connection attempt in low bandwidth
        final timeout = _isLowBandwidth
            ? const Duration(seconds: 20)
            : const Duration(seconds: 10);

        await _connectionCompleter?.future.timeout(timeout, onTimeout: () {
          throw TimeoutException('Connection attempt timed out');
        });

        // After connection completes, handle any subscription request
        if (_wsConnected && channelInput.isNotEmpty) {
          _handleSubscription(channelInput, task, context);
        }
      } catch (e) {
        if (_connectionCount < _maxReconnectAttempts && !_reconnecting) {
          reconnect(context);
        }
      }
      return;
    }

    _connecting = true;
    _connectionCompleter = Completer<void>();

    try {
      // Connect with a timeout appropriate for network conditions
      final connectTimeout = _isLowBandwidth
          ? const Duration(seconds: 15)
          : const Duration(seconds: 10);

      final uri = Uri.parse(ApiLinks.wsURL);

      // Create connection with timeout
      _channel = WebSocketChannel.connect(uri);

      // Set up a timeout for connection
      final timeoutTimer = Timer(connectTimeout, () {
        if (_connecting && (_channel == null || !_wsConnected)) {
          _handleConnectionError(
              TimeoutException('WebSocket connection timed out'), context);
        }
      });

      // Send connection request
      _channel!.sink.add(jsonEncode({
        "t": "c",
        "actid": _pref.clientId,
        "uid": _pref.clientId,
        "source": ApiLinks.source,
        "susertoken": _pref.clientSession,
      }));

      _channel!.stream.listen(
        _handleWebSocketMessage,
        onDone: () => _handleConnectionClosed(context),
        onError: (error) => _handleConnectionError(error, context),
      );

      // Cancel timeout timer as we've successfully set up the connection
      timeoutTimer.cancel();
    } catch (error) {
      _handleConnectionError(error, context);
    }
  }

  void _handleWebSocketMessage(dynamic event) {
    try {
      // Update last message time for ping tracking
      _lastMessageTime = DateTime.now();
      _failedPingCount = 0;

      final res = jsonDecode(event.toString());

      if (res['s']?.toString().toLowerCase() == "ok" &&
          res['t']?.toString() == "ck") {
        log("WebSocket connected successfully");
        _handleConnectionSuccess();
      } else if (res['t']?.toString().toLowerCase() == "tf" ||
          res['t']?.toString().toLowerCase() == "df") {
        // log("Socket Data: ${res.toString()}");
        _handleMarketData(res);
      } else if (res['t']?.toString().toLowerCase() == "tk" ||
          res['t']?.toString().toLowerCase() == "dk") {
        // log("Socket Data: ${res.toString()}");
        _handleTokenData(res);
      } else if (res['t']?.toString().toLowerCase() == "om" &&
          _context != null) {
        _handleOrderMessage(res);
      } else if (res['t']?.toString().toLowerCase() == "am" &&
          _context != null) {
        _handleAlertMessage(res);
      } else if (res['t']?.toString().toLowerCase() == "h") {
        // Handle heartbeat/ping response
        _failedPingCount = 0;
      }

      // Use post-frame callback to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      // Log parsing errors for debugging
      log("WebSocket message parsing error: $e");
    }
  }

  void _handleConnectionSuccess() {
    _wsConnected = true;
    _connecting = false;
    resetConnectionCount(); // Reset connection count properly
    _reconnecting = false;
    _retryScreen = false; // Ensure retry screen is not shown

    // Reset low bandwidth mode on successful connection
    _isLowBandwidth = false;

    // Start ping timer for connection monitoring
    _startPingTimer();

    // Cancel any backoff timer
    _reconnectBackoff?.cancel();
    _reconnectBackoff = null;

    if (!_connectionCompleter!.isCompleted) {
      _connectionCompleter?.complete();
    }
  }

  void _handleAlertMessage(Map<String, dynamic> res) {
    // Show alert message in a SnackBar
    if (res['dmsg'] != null && _context != null) {
      // Display the alert message to the user
      successMessage(_context!, res['dmsg'].toString());

      // Navigate to the alerts tab (tab index 6) when alert is triggered
      // This will take the user to the alerts tab even if they're on another screen
      ref.read(orderProvider).changeTabIndex(6, _context!);
    }

    // Update both pending alerts and triggered alerts
    if (_context != null) {
      // Fetch broker messages for triggered alerts
      ref.read(notificationprovider).fetchbrokermsg(_context!);

      // Fetch pending alerts to refresh the list
      ref.read(marketWatchProvider).fetchPendingAlert(_context!);
    }
  }

  void _handleMarketData(Map<String, dynamic> res) {
    final key = res['tk']?.toString();
    if (key == null || !_socketDatas.containsKey(key)) return;

    // Batch updates - only update UI after processing the data
    _updateSocketData(key, res);

    // Notify market watch provider to update its UI with the latest data
    _notifyMarketWatchProvider();
  }

  void _handleTokenData(Map<String, dynamic> res) {
    final key = res['tk']?.toString();
    if (key == null) return;

    if (!_socketDatas.containsKey(key)) {
      _socketDatas[key] = <String, dynamic>{};
      _initializeTokenData(key, res);

      // Notify only after initialization is complete to avoid partial updates
      _socketDataController.add(_socketDatas);

      // Only trigger the portfolio update once after initialization
      // and only if we have valid price data
      if (_socketDatas[key]['lp'] != null &&
          _socketDatas[key]['lp'] != '0' &&
          _socketDatas[key]['lp'] != '0.00') {
        ref.read(portfolioProvider).updateHoldingValues(key, _socketDatas[key]);
      }

      // Notify market watch provider to update its UI with the latest data
      _notifyMarketWatchProvider();
    } else {
      // For existing tokens, use the optimized update method
      _updateSocketData(key, res);
    }
  }

  void _handleOrderMessage(Map<String, dynamic> res) {
    if (_holdStartTime?.isActive ?? false) {
      _holdStartTime?.cancel();
    }

    _holdStartTime = Timer(const Duration(milliseconds: 500), () {
      if (_context != null) {
        _refreshData(_context!);
      }
      _holdStartTime = null;
    });
  }

  void _refreshData(BuildContext context) {
    ref.read(portfolioProvider).fetchHoldings(context, "");
    ref.read(orderProvider).fetchOrderBook(context, true);
    ref.read(orderProvider).fetchTradeBook(context);
    ref.read(orderProvider).fetchGTTOrderBook(context, "");
    ref.read(fundProvider).fetchFunds(context);

    Timer(const Duration(seconds: 1),
        () => ref.read(portfolioProvider).fetchPositionBook(context, false));
  }

  void _updateSocketData(String key, Map<String, dynamic> res) {
    final data = _socketDatas[key];
    if (data == null) return;

    // Track if we've made meaningful updates that require UI refresh
    bool hasUpdates = false;

    // Update only fields that are present in the new data and have changed
    for (final field in res.keys) {
      final value = res[field];

      // Skip update for null values
      if (value == null) continue;

      // For price fields, only update if new value is non-zero
      if (['lp', 'c', 'pc', 'o', 'h', 'l'].contains(field)) {
        final numValue = double.tryParse(value.toString()) ?? 0.0;
        if (numValue <= 0.0) continue;
      }

      // Only update if value is different from current
      if (data[field] != value) {
        data[field] = value;
        hasUpdates = true;
        
        // Cache LTP value for future use during refresh
        if (field == 'lp') {
          _ltpCache[key] = value.toString();
        }
      }
    }

    // Only calculate change if we have updates that would affect it
    // and both lp and close price are available
    if (hasUpdates && data["lp"] != null && data["c"] != null) {
      final lp = double.tryParse(data["lp"].toString()) ?? 0.00;
      final c = double.tryParse(data["c"].toString()) ?? 0.00;

      // Only calculate if both values are valid
      if (lp > 0.0 && c > 0.0) {
        // Calculate the percentage change
        final newChng = (lp - c).toStringAsFixed(2);

        // Only update if the change is actually different
        if (data["chng"] != newChng) {
          data["chng"] = newChng;
          data["pc"] = res["pc"];
          hasUpdates = true;
        }
      }
    }

    // Only notify listeners if we actually had meaningful changes
    if (hasUpdates) {
      _socketDataController.add(_socketDatas);

      // Minimize portfolio recalculations by checking if this is a price update
      // and only update if we have valid price data
      if ((res.containsKey('lp') ||
              res.containsKey('pc') ||
              res.containsKey('c')) &&
          data["lp"] != null &&
          data["lp"] != "0" &&
          data["lp"] != "0.00") {
        ref.read(portfolioProvider).updateHoldingValues(key, data);
      }
    }
  }

  void _initializeTokenData(String key, Map<String, dynamic> res) {
    final data = _socketDatas[key];

    // Initialize basic fields
    data["pc"] = res["pc"] ?? "0.00";
    data["ap"] = res["ap"] ?? "0.00";
    data["o"] = res["o"] ?? "0.00";
    data["h"] = res["h"] ?? "0.00";
    data["l"] = res["l"] ?? "0.00";
    data["c"] = res["c"] ?? "0.00";
    data["lp"] = res["lp"] ?? "0.00";
    
    // Cache initial LTP value
    if (res["lp"] != null && res["lp"] != "0.00") {
      _ltpCache[key] = res["lp"].toString();
    }
    
    data["v"] = res["v"] ?? "0.00";
    data["oi"] = res["oi"] ?? "0.00";
    data["toi"] = res["toi"] ?? "0.00";
    data["poi"] = res["poi"] ?? "0.00";

    // Initialize depth data if available
    if (res['t']?.toString().toLowerCase() == "dk") {
      _initializeDepthData(data, res);
    }

    // Calculate change
    data["chng"] =
        ((double.tryParse(data["lp"]?.toString() ?? '0.00') ?? 0.00) -
                (double.tryParse(data["c"]?.toString() ?? '0.00') ?? 0.00))
            .toStringAsFixed(2);
  }

  void _initializeDepthData(
      Map<String, dynamic> data, Map<String, dynamic> res) {
    // Initialize depth fields
    for (int i = 1; i <= 5; i++) {
      data["sp$i"] = res["sp$i"] ?? "0.00";
      data["sq$i"] = res["sq$i"] ?? "0";
      data["bp$i"] = res["bp$i"] ?? "0.00";
      data["bq$i"] = res["bq$i"] ?? "0";
    }

    data["tsq"] = res["tsq"] ?? "0.00";
    data["tbq"] = res["tbq"] ?? "0";
    data["52h"] = res["52h"] ?? "0.0";
    data["52l"] = res["52l"] ?? "0.0";
    data["ft"] = res["ft"] ?? "0.0";
    data["lc"] = res["lc"] ?? "0.0";
    data["uc"] = res["uc"] ?? "0.0";
    data["ltq"] = res["ltq"] ?? "0.0";
    data["ltt"] = res["ltt"] ?? "0.0";
  }

  void _handleSubscription(
      String channelInput, String task, BuildContext context) {
    // In low bandwidth mode, we filter out less critical subscriptions
    if (_isLowBandwidth &&
        task.toLowerCase() != "u" &&
        channelInput.contains(',')) {
      // If in low bandwidth mode, consider batching or prioritizing subscriptions
      // For example, we might only subscribe to the most important symbols
      final symbols = channelInput.split('#');
      // if (symbols.length > 10) {
      //   // If too many symbols, only subscribe to the first 10 in low bandwidth mode
      //   final prioritySymbols = symbols.take(10).join('#');
      channelInput = symbols.join('#');
      // }
    }

    if (task.toLowerCase() != "u" &&
        task.toLowerCase() != 'ud' &&
        !channelInput.startsWith('|')) {
      _startSubscriptionTimer(channelInput, context);
    }

    connectTouchLine(input: channelInput, task: task, context: context);
  }

  void connectTouchLine({
    required String task,
    required String input,
    required BuildContext context,
  }) {
    if (input.isEmpty) {
      print("WebSocket: Empty input provided to connectTouchLine");
      return;
    }

    // Update SubscriptionManager based on task type
    final subscriptionManager = ref.read(subscriptionManagerProvider);
    
    log("🔌 WebSocket: connectTouchLine called - task: '$task', input: '$input'");
    
    // Update context in subscription manager when actively used
    subscriptionManager.updateContext(context);
    
    if (task.toLowerCase() == "t" || task.toLowerCase() == "d") {
      // Subscribe tasks - add to subscription manager
      subscriptionManager.addSubscription(input);
      final symbols = input.split('#').where((s) => s.isNotEmpty).toList();
      log("WebSocket: ➕ Added ${symbols.length} subscriptions for task '$task'");
      log("  Symbols: ${symbols.join(', ')}");
    } else if (task.toLowerCase() == "u" || task.toLowerCase() == "ud") {
      // Unsubscribe tasks - remove from subscription manager
      subscriptionManager.removeSubscription(input);
      final symbols = input.split('#').where((s) => s.isNotEmpty).toList();
      log("WebSocket: ➖ Removed ${symbols.length} subscriptions for task '$task'");
      log("  Symbols: ${symbols.join(', ')}");
    }

    if (_wsConnected && _channel != null) {
      print(
          "WebSocket: Sending ${task} request for ${input.split('#').length} symbols");
      _channel?.sink.add(jsonEncode({"t": task, "k": input}));
    } else {
      // If socket isn't ready yet, schedule a retry
      print("WebSocket: Connection not ready, scheduling retry in 500ms");
      Future.delayed(Duration(milliseconds: 500), () {
        if (_wsConnected && _channel != null) {
          print("WebSocket: Retrying subscription after delay");
          _channel?.sink.add(jsonEncode({"t": task, "k": input}));
        } else {
          print(
              "WebSocket: Still not connected after delay, attempting full reconnection");
          if (_context != null) {
            establishConnection(
              channelInput: input,
              task: task,
              context: context,
            );
          }
        }
      });
    }
  }

  void _handleConnectionClosed(BuildContext context) {
    if (!_reconnecting) {
      _connectionCount++;

      // Use post-frame callback to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners(); // Notify to update UI with new connection count
      });
    }

    closeSocket(true);

    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter?.completeError("WebSocket connection closed.");
    }

    if (_connectionCount < _maxReconnectAttempts) {
      // Use post-frame callback to avoid provider modification during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reconnect(context);
      });
    }
  }

  void _handleConnectionError(dynamic error, BuildContext context) {
    if (!_reconnecting) {
      _connectionCount++;
      // Use post-frame callback to avoid modifying provider during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners(); // Notify to update UI with new connection count
      });
    }

    closeSocket(true);

    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter?.completeError(error);
    }

    if (_connectionCount < _maxReconnectAttempts) {
      // Use post-frame callback to avoid provider modification during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reconnect(context);
      });
    }
  }

  void reconnect(BuildContext context) {
    // Prevent multiple simultaneous reconnection attempts
    if (_reconnecting) return;
    _reconnecting = true;

    // Cancel any existing backoff timer
    _reconnectBackoff?.cancel();

    // Use exponential backoff based on connection count
    // With longer delays for low bandwidth conditions
    final multiplier = _isLowBandwidth ? 2 : 1;
    final backoffDelay = Duration(
        seconds:
            _reconnectDelay.inSeconds * (_connectionCount + 1) * multiplier);

    // If retry screen is active, attempt immediate reconnection
    if (_retryScreen) {
      _attemptReconnection(context);
    } else {
      // Check if we're connected to a network before scheduling reconnection
      final connectionStatus = ref.read(networkStateProvider).connectionStatus;

      if (connectionStatus != ConnectivityResult.none) {
        _reconnectBackoff = Timer(backoffDelay, () {
          _attemptReconnection(context);
        });
      } else {
        // Reset reconnecting flag if no network is available
        _reconnecting = false;
        // Use post-frame callback to avoid modifying provider during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    }
  }

  void _attemptReconnection(BuildContext context) {
    final connectionStatus = ref.read(networkStateProvider).connectionStatus;

    if (connectionStatus != ConnectivityResult.none) {
      // Reset retry screen flag as we're attempting reconnection
      _retryScreen = false;

      // Make sure we only try to refresh data once per reconnection attempt
      if (!_wsConnected) {
        if (currentRouteName != Routes.loginScreen){
        _refreshData(context);
        }
      }
      

      // First establish a base connection if needed
      establishConnection(
        channelInput: "",
        task: "c",
        context: context,
      );

      // After connection, subscribe to stored channels if they exist
      // Give a slight delay to ensure connection is established
      Future.delayed(const Duration(milliseconds: 500), () {
        // Verify we're still in reconnection process before continuing
        if (_reconnecting && !_wsConnected) {
          if (ConstantName.lastSubscribe.isNotEmpty) {
            connectTouchLine(
              input: ConstantName.lastSubscribe,
              task: "t",
              context: context,
            );
          }

          if (ConstantName.lastSubscribeDepth.isNotEmpty) {
            connectTouchLine(
              input: ConstantName.lastSubscribeDepth,
              task: "d",
              context: context,
            );
          }
        }

        // Reset reconnecting flag after attempt, regardless of success
        // The actual connection state is tracked by _wsConnected
        _reconnecting = false;
        // Use post-frame callback to avoid modifying provider during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      });
          } else {
        // Reset reconnecting flag if no network is available
        _reconnecting = false;
        // Use post-frame callback to avoid modifying provider during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
  }

  @override
  void dispose() {
    // Ensure all timers are canceled
    _stopPingTimer();
    _holdStartTime?.cancel();
    _reconnectBackoff?.cancel();
    _debounceTimer?.cancel(); // Cancel debounce timer

    // Cancel all subscription timers
    for (var timer in _subscriptionTimers.values) {
      timer.cancel();
    }
    _subscriptionTimers.clear();

    // Close socket channel
    _channel?.sink.close();

    // Close data stream
    _socketDataController.close();

    super.dispose();
  }

  // Method to notify the market watch provider of data updates
  void _notifyMarketWatchProvider() {
    try {
      // If we don't have any data, don't bother updating
      if (_socketDatas.isEmpty) return;

      // FIX: Remove debounce for critical LTP updates to ensure real-time prices
      // Directly send the updates to market watch provider
      try {
        // Safely check if the market watch provider is still available
        final marketWatchProv = ref.read(marketWatchProvider);

        // Check if the provider is already disposed
        if (marketWatchProv.disposed) {
          print("Market watch provider is disposed, skipping update");
          return;
        }

        // Send a copy of the data to prevent modification issues
        final dataCopy = Map<String, dynamic>.from(_socketDatas);
        marketWatchProv.updateSocketData(dataCopy);
      } catch (e) {
        // Silent catch - this can happen during app shutdown or page transitions
        // We don't want to crash the app if the provider is being disposed
        print(
            "Market watch provider access error (likely during transition): $e");
      }
    } catch (e) {
      print("Error setting up notification to market watch provider: $e");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mynt_plus/provider/network_state_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'functions.dart';
import 'dart:async';

//  If there is no internet, it will show on the screen.

class NoInternetScreen extends ConsumerStatefulWidget {
  final VoidCallback? onReconnectionSuccess;
  
  const NoInternetScreen({
    super.key,
    this.onReconnectionSuccess,
  });

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen> {
  bool _isReconnecting = false;
  bool _isCheckingConnection = false;
  Timer? _connectionCheckTimer;
  bool _disposed = false;
  String _errorMessage = "";
  
  @override
  void initState() {
    super.initState();
    _checkConnectionState();
  }
  
  // Check connection state periodically to detect auto-reconnection
  void _checkConnectionState() {
    // Don't start another check if one is already in progress
    // or if the widget has been disposed
    if (_isCheckingConnection || _disposed) return;
    
    // Cancel any existing timer
    _connectionCheckTimer?.cancel();
    
    if (mounted) {
      setState(() {
        _isCheckingConnection = true;
      });
    }
    
    // Check current connection state
    Connectivity().checkConnectivity().then((results) {
      if (_disposed) return;
      
      // connectivity_plus 7.0.0 returns List<ConnectivityResult>
      final result = results.isNotEmpty 
          ? (results.contains(ConnectivityResult.none) 
              ? ConnectivityResult.none 
              : results.first)
          : ConnectivityResult.none;
      
      if (result != ConnectivityResult.none) {
        // If network is available but websocket is not connected, try reconnecting
        final webSocket = ref.read(websocketProvider);
        if (!webSocket.wsConnected && webSocket.connectioncount < 5) {
          _attemptReconnection();
        }
      }
      
      if (mounted) {
        setState(() {
          _isCheckingConnection = false;
        });
      }
      
      // Schedule next check after 5 seconds, but only if widget is still mounted
      if (!_disposed) {
        _connectionCheckTimer = Timer(const Duration(seconds: 5), _checkConnectionState);
      }
    });
  }
  
  // Handle reconnection attempt
  Future<void> _attemptReconnection() async {
    if (_isReconnecting || _disposed) return;
    
    if (mounted) {
      setState(() {
        _isReconnecting = true;
        _errorMessage = "";
      });
    }
    
    try {
      // Check current connection state first
      final results = await Connectivity().checkConnectivity();
      // connectivity_plus 7.0.0 returns List<ConnectivityResult>
      final connectivityResult = results.isNotEmpty 
          ? (results.contains(ConnectivityResult.none) 
              ? ConnectivityResult.none 
              : results.first)
          : ConnectivityResult.none;
      
      if (connectivityResult == ConnectivityResult.none) {
        if (mounted) {
          setState(() {
            _errorMessage = "No internet connection available. Please check your network settings.";
            _isReconnecting = false;
          });
        }
        return;
      }
      
      final webSocket = ref.read(websocketProvider);
      
      // Reset connection count if it's at max attempts
      if (webSocket.connectioncount >= 5) {
        webSocket.changeconnectioncount();
      }
      
      // Start reconnection process
      webSocket.closeSocket(true);
      webSocket.changeretryscreen(true);
      
      // Call initialLoadMethods to reload all necessary data
      try {
        await ref.read(authProvider).initialLoadMethods(context, "");
        
        // Once initialLoadMethods completes successfully, try reconnecting websocket
        webSocket.reconnect(context);
        
        // Wait for reconnection to complete
        await Future.delayed(const Duration(seconds: 2));
        
        // Call the onReconnectionSuccess callback if provided
        if (widget.onReconnectionSuccess != null && mounted) {
          widget.onReconnectionSuccess!();
        }
        
        if (mounted) {
          setState(() {
            _isReconnecting = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to reload data. Please try again.";
            _isReconnecting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Connection failed. Please try again.";
          _isReconnecting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final webSocket = ref.watch(websocketProvider);
      final networkState = ref.watch(networkStateProvider);
      final theme = ref.watch(themeProvider);
      
      // Check if we should still show this screen
      // If websocket is connected or connectioncount is reset and network is available
      if ((webSocket.wsConnected || 
          (webSocket.reconnectionSuccess && networkState.connectionStatus != ConnectivityResult.none)) && 
          webSocket.connectioncount < 5) {
        // Return empty container as this screen should be dismissed
        return Container();
      }
      
      final isNetworkAvailable = networkState.connectionStatus != ConnectivityResult.none;
      final statusMessage = _errorMessage.isNotEmpty 
          ? _errorMessage
          : isNetworkAvailable 
              ? "Connection issues detected. Please try reconnecting."
              : "It seems like you are offline. Please check your network connection.";
      
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: SvgPicture.asset("assets/icon/Mynt New logo.svg",
                            //  color: const Color(0xff0037B7),
                            height: 80,
                            width: 150,
                            fit: BoxFit.contain)),
                    const SizedBox(height: 20),
                    if (isNetworkAvailable && webSocket.connectioncount >= 5)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Multiple connection attempts failed. Please try reconnecting manually.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? const Color(0xffB0BEC5)
                          : const Color(0xff000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )),
                  onPressed: (_isReconnecting) 
                      ? null 
                      : _attemptReconnection,
                  child: (_isReconnecting) 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ) 
                      : Text("Connect Again",
                          style: textStyle(
                              theme.isDarkMode
                                  ? const Color(0xff000000)
                                  : const Color(0xffFFFFFF),
                              15,
                              0)),
                ),
              ),
              Container(
                  color: Colors.black,
                  child: ListTile(
                      minLeadingWidth: 10,
                      leading: const Padding(
                          padding: EdgeInsets.only(top: 3.5),
                          child: Icon(Icons.warning_amber_outlined,
                              size: 15, color: Colors.amber)),
                      title: Text(
                          statusMessage,
                          style: const TextStyle(fontSize: 12, color: Colors.white))))
            ],
          ),
        ),
      );
    });
  }
}

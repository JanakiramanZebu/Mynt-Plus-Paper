import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/index_list_provider.dart';
import 'package:mynt_plus/provider/network_state_provider.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/core/api_link.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';

final websocketProvider =
    ChangeNotifierProvider((ref) => WebSocketProvider(ref.read));

class WebSocketProvider extends ChangeNotifier {
  final Reader ref;
  WebSocketProvider(this.ref);

  // Map to track active subscriptions and their timers
  final Map<String, Timer> _subscriptionTimers = {};

  // Timeout duration (e.g., 10 seconds)
  static const int subscriptionTimeout = 5;

  int _connectioncount = 0;

  int get connectioncount => _connectioncount;

  bool _wsConnected = false;
  bool _connecting = false;

  WebSocketChannel? channel;
  Completer<void>? _connectionCompleter;

  final Map _socketDatas = {};

  Map get socketDatas => _socketDatas;

  final Preferences pref = locator<Preferences>();

  bool get wsConnected => _wsConnected;

  bool _retryscreen = false;
  bool get retryscreen => _retryscreen;

  void changeretryscreen(bol) {
    _retryscreen = bol;
  }

  void changeconnectioncount() {
    _connectioncount = 0;
  }

  void closeSocket() {
    _wsConnected = false;
    _connecting = false;
    channel?.sink.close();
    // Cancel all subscription timers
    for (var timer in _subscriptionTimers.values) {
      timer.cancel();
    }
    _subscriptionTimers.clear();
    notifyListeners();
  }

  // bool _isGetData = false;
  websockConn(bool value) {
    _wsConnected = value;
    notifyListeners();
  }

  // Websocket Recpnnection(Heart beat)
  reconnectWS() {
    if (ref(networkStateProvider).connectionStatus != ConnectivityResult.none &&
        _wsConnected) {
      if (!_wsConnected) {
        channel?.sink.add(jsonEncode({"t": "h"}));
      }
    }
  }

  // void showBottomAlert(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(20),
  //       ),
  //     ),
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "Alert Message",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               "This is a sample alert message displayed at the bottom of the screen. You can customize it as needed.",
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 16),
  //             ElevatedButton(
  //               onPressed: () {
  //                 // Handle button action here
  //                 reconnect(context);
  //                 Navigator.pop(context);
  //               },
  //               child: Text("Refresh"),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _startSubscriptionTimer(String key, context) {
    // Cancel any existing timer for the same subscription
    _subscriptionTimers[key]?.cancel();
    log("started timer $key");
    // Start a new timer
    _subscriptionTimers[key] = Timer(
      const Duration(seconds: subscriptionTimeout),
      () {
        // Timeout reached without receiving data
        debugPrint("Subscription timeout for: $key");
        _subscriptionTimers.remove(key);
        log("timout error call bottom modal $key");
        // Attempt reconnection or re-subscription
        _handleSubscriptionTimeout(context);
      },
    );
  }

  void _handleSubscriptionTimeout(context) {
    _connectioncount += 1;
    debugPrint("WebSocket disconnected. Attempting to reconnect...");
    // Reconnect logic here
    ref(indexListProvider)
        .logError
        .add({"type": "Timeout error", "Error": "error"});
    closeSocket();
    // showBottomAlert(context);
    if (_connectioncount < 5) {
      establishConnection(
        channelInput: ConstantName.lastSubscribe,
        task: "t",
        context: context,
      );
      establishConnection(
        channelInput: ConstantName.lastSubscribeDepth,
        task: "d",
        context: context,
      );
    }
  }

  Future<void> establishConnection({
    required String channelInput,
    required String task,
    required BuildContext context,
  }) async {
    // Save the channel input for reconnection purposes
    if (task == "t") {
      ConstantName.lastSubscribe = channelInput;
    } else if (task == "d") {
      ConstantName.lastSubscribeDepth = channelInput;
    }

    // If already connected, use the connection to subscribe
    if (_wsConnected) {
      if (channelInput.isNotEmpty) {
        log("task subscription 1 $channelInput");
        if (task.toLowerCase() != "u" &&
            task.toLowerCase() != 'ud' &&
            !channelInput.startsWith('|')) {
          log("subscription function call 1 $task");
          _startSubscriptionTimer(channelInput, context);
        }
        connectTouchLine(input: channelInput, task: task, context: context);
      }
      return;
    }

    // If already connecting, wait for the connection to complete
    if (_connecting) {
      try {
        await _connectionCompleter?.future;
        if (_wsConnected && channelInput.isNotEmpty) {
          log("task subscription 2  $channelInput");
          if (task.toLowerCase() != "u" &&
              task.toLowerCase() != 'ud' &&
              !channelInput.startsWith('|')) {
            log("subscription function call 2 $task");
            _startSubscriptionTimer(channelInput, context);
          }
          connectTouchLine(input: channelInput, task: task, context: context);
        }
      } catch (e) {
        log("Connection error: $e");
        if (_connectioncount < 5) {
          reconnect(context); // Handle the failure gracefully
        }
      }
      return;
    }

    // Start a new connection
    _connecting = true;
    _connectionCompleter = Completer<void>();

    final data = {
      "t": "c",
      "actid": pref.clientId,
      "uid": pref.clientId,
      "source": ApiLinks.source,
      "susertoken": pref.clientSession,
    };

    try {
      channel = WebSocketChannel.connect(Uri.parse(ApiLinks.wsURL));
      channel!.sink.add(jsonEncode(data));

      channel!.stream.listen(
        (event) {
          final res = jsonDecode(event.toString());

          if (res['s'].toString().toLowerCase() == "ok" &&
              res['t'].toString() == "ck") {
            _wsConnected = true;
            _connecting = false;
            _connectioncount = 0;
            // Complete the connection future
            _connectionCompleter?.complete();
            if (task.toLowerCase() == 't' ||
                task.toLowerCase() == 'u' ||
                task.toLowerCase() == 'd' ||
                task.toLowerCase() == 'ud') {
              if (channelInput.isNotEmpty) {
                connectTouchLine(
                    input: channelInput, task: task, context: context);
                // Start a timeout timer for this subscription
                log("task subscription 3  $channelInput");
                if (task.toLowerCase() != "u" &&
                    task.toLowerCase() != 'ud' &&
                    !channelInput.startsWith('|')) {
                  log("subscription function call 3  $task");
                  _startSubscriptionTimer(channelInput, context);
                }
              }
            }
          }
          final key = res['tk']?.toString();
          if (key != null) {
            // Cancel the timer for this subscription as we received a response
            // Cancel all timers and clear the map
            if (_subscriptionTimers != {}) {
              _subscriptionTimers.forEach((key, timer) {
                timer.cancel();
              });
              _subscriptionTimers.clear();
            }
          }
          if (res['t'].toString().toLowerCase() == "dk") {
            _wsConnected = false;
          }
          if (res['t'].toString().toLowerCase() == "tf" ||
              res['t'].toString().toLowerCase() == "df") {
            // fToast!.removeQueuedCustomToasts();
            if (_socketDatas.containsKey("${res['tk']}")) {
              if (res["pc"] != null) {
                _socketDatas["${res['tk']}"]["pc"] = res["pc"];
              }

              if (res["o"] != null) {
                _socketDatas["${res['tk']}"]["o"] = res["o"];
              }
              if (res["h"] != null) {
                _socketDatas["${res['tk']}"]["h"] = res["h"];
              }
              if (res["l"] != null) {
                _socketDatas["${res['tk']}"]["l"] = res["l"];
              }
              if (res["c"] != null) {
                _socketDatas["${res['tk']}"]["c"] = res["c"];
              }
              if (res["lp"] != null) {
                _socketDatas["${res['tk']}"]["lp"] = res["lp"];
                ref(portfolioProvider).updateHoldingValues(
                    "${res['tk']}", _socketDatas["${res['tk']}"]);
              }
              if (res["v"] != null) {
                _socketDatas["${res['tk']}"]["v"] = res["v"];
              }
              if (res["oi"] != null) {
                _socketDatas["${res['tk']}"]["oi"] = res["oi"];
              }
              if (res["toi"] != null) {
                _socketDatas["${res['tk']}"]["toi"] = res["toi"];
              }
              if (res["poi"] != null) {
                _socketDatas["${res['tk']}"]["poi"] = res["poi"];
              }
              if (res["sp1"] != null) {
                _socketDatas["${res['tk']}"]["sp1"] = res["sp1"];
              }
              if (res["sp2"] != null) {
                _socketDatas["${res['tk']}"]["sp2"] = res["sp2"];
              }
              if (res["sp3"] != null) {
                _socketDatas["${res['tk']}"]["sp3"] = res["sp3"];
              }
              if (res["sp4"] != null) {
                _socketDatas["${res['tk']}"]["sp4"] = res["sp4"];
              }
              if (res["sp5"] != null) {
                _socketDatas["${res['tk']}"]["sp5"] = res["sp5"];
              }
              if (res["sq1"] != null) {
                _socketDatas["${res['tk']}"]["sq1"] = res["sq1"];
              }
              if (res["sq2"] != null) {
                _socketDatas["${res['tk']}"]["sq2"] = res["sq2"];
              }
              if (res["sq3"] != null) {
                _socketDatas["${res['tk']}"]["sq3"] = res["sq3"];
              }
              if (res["sq4"] != null) {
                _socketDatas["${res['tk']}"]["sq4"] = res["sq4"];
              }
              if (res["sq5"] != null) {
                _socketDatas["${res['tk']}"]["sq5"] = res["sq5"];
              }
              if (res["tsq"] != null) {
                _socketDatas["${res['tk']}"]["tsq"] = res["tsq"];
              }
              if (res["bp1"] != null) {
                _socketDatas["${res['tk']}"]["bp1"] = res["bp1"];
              }
              if (res["bp2"] != null) {
                _socketDatas["${res['tk']}"]["bp2"] = res["bp2"];
              }
              if (res["bp3"] != null) {
                _socketDatas["${res['tk']}"]["bp3"] = res["bp3"];
              }
              if (res["bp4"] != null) {
                _socketDatas["${res['tk']}"]["bp4"] = res["bp4"];
              }
              if (res["bp5"] != null) {
                _socketDatas["${res['tk']}"]["bp5"] = res["bp5"];
              }
              if (res["bq1"] != null) {
                _socketDatas["${res['tk']}"]["bq1"] = res["bq1"];
              }
              if (res["bq2"] != null) {
                _socketDatas["${res['tk']}"]["bq2"] = res["bq2"];
              }
              if (res["bq3"] != null) {
                _socketDatas["${res['tk']}"]["bq3"] = res["bq3"];
              }
              if (res["bq4"] != null) {
                _socketDatas["${res['tk']}"]["bq4"] = res["bq4"];
              }
              if (res["bq5"] != null) {
                _socketDatas["${res['tk']}"]["bq5"] = res["bq5"];
              }
              if (res["tbq"] != null) {
                _socketDatas["${res['tk']}"]["tbq"] = res["tbq"];
              }

              _socketDatas["${res['tk']}"]["chng"] = (double.parse(
                          _socketDatas["${res['tk']}"]["lp"] ?? "0.00") -
                      double.parse(_socketDatas["${res['tk']}"]["c"] ?? "0.00"))
                  .toStringAsFixed(2);

              if (res["52h"] != null) {
                _socketDatas["${res['tk']}"]["52h"] = res["52h"];
              }
              if (res["52l"] != null) {
                _socketDatas["${res['tk']}"]["52l"] = res["52l"];
              }
              if (res["52hd"] != null) {
                _socketDatas["${res['tk']}"]["52hd"] = res["52hd"];
              }
              if (res["52ld"] != null) {
                _socketDatas["${res['tk']}"]["52ld"] = res["52ld"];
              }
              if (res["ft"] != null) {
                _socketDatas["${res['tk']}"]["ft"] = res["ft"];
              }
              if (res["lc"] != null) {
                _socketDatas["${res['tk']}"]["lc"] = res["lc"];
              }
              if (res["uc"] != null) {
                _socketDatas["${res['tk']}"]["uc"] = res["uc"];
              }
              if (res["ltq"] != null) {
                _socketDatas["${res['tk']}"]["ltq"] = res["ltq"];
              }
              if (res["ltt"] != null) {
                _socketDatas["${res['tk']}"]["ltt"] = res["ltt"];
              }

              //  log("Soxket data  --  ${_socketDatas["${res['d']}"]["chng"]}");
            }

            if (ref(indexListProvider).selectedBtmIndx == 1 &&
                ref(portfolioProvider).selectedTab == 1) {
              // ref(portfolioProvider).holdingCalc(_socketDatas);
            }
          } else if (res['t'].toString().toLowerCase() == "tk" ||
              res['t'].toString().toLowerCase() == "dk") {
            // fToast!.removeQueuedCustomToasts();
            if (!_socketDatas.containsKey("${res['tk']}")) {
              _socketDatas["${res['tk']}"] = <String, dynamic>{};
            }
            _socketDatas["${res['tk']}"]["pc"] = res["pc"] ?? "0.00";
            _socketDatas["${res['tk']}"]["o"] = res["o"] ?? "0.00";
            _socketDatas["${res['tk']}"]["h"] = res["h"] ?? "0.00";
            _socketDatas["${res['tk']}"]["l"] = res["l"] ?? "0.00";
            _socketDatas["${res['tk']}"]["c"] = res["c"] ?? "0.00";
            _socketDatas["${res['tk']}"]["lp"] = res["lp"] ?? "0.00";
            _socketDatas["${res['tk']}"]["v"] = res["v"] ?? "0.00";
            _socketDatas["${res['tk']}"]["oi"] = res["oi"] ?? "0.00";
            _socketDatas["${res['tk']}"]["toi"] = res["toi"] ?? "0.00";
            _socketDatas["${res['tk']}"]["poi"] = res["poi"] ?? "0.00";
            if (res['t'].toString().toLowerCase() == "dk") {
              _socketDatas["${res['tk']}"]["sp1"] = res["sp1"] ?? "0.00";
              _socketDatas["${res['tk']}"]["sp2"] = res["sp2"] ?? "0.00";
              _socketDatas["${res['tk']}"]["sp3"] = res["sp3"] ?? "0.00";
              _socketDatas["${res['tk']}"]["sp4"] = res["sp4"] ?? "0.00";
              _socketDatas["${res['tk']}"]["sp5"] = res["sp5"] ?? "0.00";
              _socketDatas["${res['tk']}"]["sq1"] = res["sq1"] ?? "0";
              _socketDatas["${res['tk']}"]["sq2"] = res["sq2"] ?? "0";
              _socketDatas["${res['tk']}"]["sq3"] = res["sq3"] ?? "0";
              _socketDatas["${res['tk']}"]["sq4"] = res["sq4"] ?? "0";
              _socketDatas["${res['tk']}"]["sq5"] = res["sq5"] ?? "0";
              _socketDatas["${res['tk']}"]["tsq"] = res["tsq"] ?? "0.00";
              _socketDatas["${res['tk']}"]["bp1"] = res["bp1"] ?? "0.00";
              _socketDatas["${res['tk']}"]["bp2"] = res["bp2"] ?? "0.00";
              _socketDatas["${res['tk']}"]["bp3"] = res["bp3"] ?? "0.00";
              _socketDatas["${res['tk']}"]["bp4"] = res["bp4"] ?? "0.00";
              _socketDatas["${res['tk']}"]["bp5"] = res["bp5"] ?? "0.00";
              _socketDatas["${res['tk']}"]["bq1"] = res["bq1"] ?? "0";
              _socketDatas["${res['tk']}"]["bq2"] = res["bq2"] ?? "0";
              _socketDatas["${res['tk']}"]["bq3"] = res["bq3"] ?? "0";
              _socketDatas["${res['tk']}"]["bq4"] = res["bq4"] ?? "0";
              _socketDatas["${res['tk']}"]["bq5"] = res["bq5"] ?? "0";
              _socketDatas["${res['tk']}"]["tbq"] = res["tbq"] ?? "0";
              _socketDatas["${res['tk']}"]["52h"] = res["52h"] ?? "0.0";
              _socketDatas["${res['tk']}"]["52l"] = res["52l"] ?? "0.0";
              _socketDatas["${res['tk']}"]["ft"] = res["ft"] ?? "0.0";
              _socketDatas["${res['tk']}"]["lc"] = res["lc"] ?? "0.0";
              _socketDatas["${res['tk']}"]["uc"] = res["uc"] ?? "0.0";
              _socketDatas["${res['tk']}"]["ltq"] = res["ltq"] ?? "0.0";
              _socketDatas["${res['tk']}"]["ltt"] = res["ltt"] ?? "0.0";
            }

            _socketDatas["${res['tk']}"]["chng"] =
                ((double.tryParse(res["lp"]?.toString() ?? '0.00') ?? 0.00) -
                        (double.tryParse(res["c"]?.toString() ?? '0.00') ??
                            0.00))
                    .toStringAsFixed(2);
            // Check if the key exists in _socketDatas
            // if (_socketDatas.containsKey(key)) {
            //   // Compare the new value with the existing value
            //   if (_socketDatas[key] != res) {
            //     // Update only if data is different
            //     _socketDatas[key] = res;
            //     print("Data updated for key: $key");
            //   }
            // } else {
            //   // If key doesn't exist, add it
            //   _socketDatas[key] = res;
            //   print("New data added for key: $key");
            // }
            ref(portfolioProvider).updateHoldingValues("${res['tk']}", res);

            // log("Soxket data ${jsonEncode(_socketDatas)}");
          } else if (res['t'].toString().toLowerCase() == "om") {
            ref(indexListProvider)
                .logError
                .add({"type": "Order Response", "Error": "$res"});
            ref(portfolioProvider).fetchHoldings(context, "");

            ref(orderProvider).fetchOrderBook(context, true);
            ref(orderProvider).fetchTradeBook(context);
            ref(orderProvider).fetchGTTOrderBook(context, "");
            ref(fundProvider).fetchFunds(context);
            if (res['status'].toString() == "COMPLETE") {
              Timer(
                  const Duration(seconds: 1),
                  () =>
                      ref(portfolioProvider).fetchPositionBook(context, false));
            }
          }

          notifyListeners();
        },
        onDone: () {
          if (channel!.closeCode != null) {
            _handleConnectionClosed(context);
            ref(indexListProvider).logError.add({
              "type": "Websocket ${channel!.closeCode} ",
              "Error": "Connection closed "
            });
          }
          notifyListeners();
        },
        onError: (error) {
          _handleConnectionError(error, context);
          ref(indexListProvider)
              .logError
              .add({"type": "Websocket Error", "Error": "$error"});
          notifyListeners();
        },
      );
    } catch (error) {
      _handleConnectionError(error, context);
    }
  }

  void connectTouchLine({
    required String task,
    required String input,
    required BuildContext context,
  }) {
    final data = {"t": task, "k": input};
    if (input.isNotEmpty && _wsConnected) {
      channel?.sink.add(jsonEncode(data));
    }
  }

  void _handleConnectionClosed(context) {
    _connectioncount += 1;
    closeSocket();
    // Check if the Completer is already completed
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter?.completeError("WebSocket connection closed.");
    }
    if (_connectioncount < 5) {
      reconnect(context);
    }
  }

  void _handleConnectionError(dynamic error, context) {
    _connectioncount += 1;
    closeSocket();
    _connectionCompleter?.completeError(error);
    if (_connectioncount < 5) {
      Future.delayed(const Duration(seconds: 5)).then((_) {
        if (_wsConnected != true) {
          reconnect(context);
          ref(indexListProvider)
              .logError
              .add({"type": "Reconnect try", "Error": "error"});
        }
        notifyListeners();
      });
    }
  }

  void reconnect(context) {
    if (_retryscreen == true) {
      if (ref(networkStateProvider).connectionStatus !=
          ConnectivityResult.none) {
        ref(portfolioProvider).fetchHoldings(context, "");
        ref(orderProvider).fetchOrderBook(context, true);
        ref(orderProvider).fetchTradeBook(context);
        ref(orderProvider).fetchGTTOrderBook(context, "");
        ref(fundProvider).fetchFunds(context);
        ref(portfolioProvider).fetchPositionBook(context, false);

        establishConnection(
          channelInput: ConstantName.lastSubscribe,
          task: "t",
          context: context,
        );
        establishConnection(
          channelInput: ConstantName.lastSubscribeDepth,
          task: "d",
          context: context,
        );
        _retryscreen = false;
      }
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) {
        if (ref(networkStateProvider).connectionStatus !=
            ConnectivityResult.none) {
          ref(portfolioProvider).fetchHoldings(context, "");
          ref(orderProvider).fetchOrderBook(context, true);
          ref(orderProvider).fetchTradeBook(context);
          ref(orderProvider).fetchGTTOrderBook(context, "");
          ref(fundProvider).fetchFunds(context);
          ref(portfolioProvider).fetchPositionBook(context, false);

          establishConnection(
            channelInput: ConstantName.lastSubscribe,
            task: "t",
            context: context,
          );
          establishConnection(
            channelInput: ConstantName.lastSubscribeDepth,
            task: "d",
            context: context,
          );
          _retryscreen = false;
        }
      });
    }
  }
}

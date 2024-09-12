import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/core/api_link.dart';
import '../locator/constant.dart';

import '../locator/locator.dart';
import '../locator/preference.dart';
import 'fund_provider.dart';
import 'index_list_provider.dart';
import 'network_state_provider.dart';
import 'order_provider.dart';
import 'portfolio_provider.dart';

final websocketProvider =
    ChangeNotifierProvider((ref) => WebSocketProvider(ref.read));

class WebSocketProvider extends ChangeNotifier {
  bool _wsConnected = false;

  bool get wsConnected => _wsConnected;

  final Reader ref;
  WebSocketProvider(this.ref);

  static WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse(ApiLinks.wsURL));

  final FToast _fToast = FToast();
  FToast get fToast => _fToast;

  final Map _socketDatas = {};

  Map get socketDatas => _socketDatas;

  // bool _isGetData = false;
  websockConn(bool value) {
    _wsConnected = value;
    notifyListeners();
  }

bool conectionClosed=false;

  final Preferences pref = locator<Preferences>();

  void closeSocket() { 
    conectionClosed=true;
    _wsConnected = false;
    channel.sink.close();
  }

  reconnectWS() {
    if (ref(networkStateProvider).connectionStatus != ConnectivityResult.none &&
        _wsConnected) {

          if (!conectionClosed ) {
            channel.sink.add(jsonEncode({"t": "h"}));
          }
      
    }
  }

  establishConnection(
      {required String channelInput,
      required String task,
      required BuildContext context}) {
    if (task == "t") {
      ConstantName.lastSubscribe = channelInput;
    } else if (task == "d") {
      ConstantName.lastSubscribeDepth = channelInput;
    }
    // _socketDatas = {};
    if (!wsConnected) {
      final data = {
        "t": "c",
        "actid": pref.clientId,
        "uid": pref.clientId,
        "source": ApiLinks.source,
        "susertoken": pref.clientSession
      };
      channel = WebSocketChannel.connect(Uri.parse(ApiLinks.wsURL));
      channel.sink.add(jsonEncode(data));

      channel.stream.listen(
        (data) {
          //  log("Socket Data ===> $data");
          final res = jsonDecode(data.toString());

          if (res['s'].toString().toLowerCase() == "ok" &&
              res['t'].toString() == "ck") {
            _wsConnected = true;
            if (task.toLowerCase() == 't' ||
                task.toLowerCase() == 'u' ||
                task.toLowerCase() == 'd' ||
                task.toLowerCase() == 'ud') {
              if (channelInput.isNotEmpty) {
                connectTouchLine(
                    input: channelInput, task: task, context: context);
              }
            }
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

              // log("Soxket data  --  ${_socketDatas["${res['tk']}"]["chng"]}");
            }

            if (ref(indexListProvider).selectedBtmIndx == 1 &&
                ref(portfolioProvider).selectedTab == 1) {
              // ref(portfolioProvider).holdingCalc(_socketDatas);
            }
          } else if (res['t'].toString().toLowerCase() == "tk" ||
              res['t'].toString().toLowerCase() == "dk") {
            // fToast!.removeQueuedCustomToasts();
            if (res["pc"] == null) {
              res["pc"] = "0.00";
            }

            if (res["o"] == null) {
              res["o"] = "0.00";
            }
            if (res["h"] == null) {
              res["h"] = "0.00";
            }
            if (res["l"] == null) {
              res["l"] = "0.00";
            }
            if (res["c"] == null) {
              res["c"] = "0.00";
            }

            res["lp"] = res["lp"] ?? res["c"] ?? "0.00";

            if (res["v"] == null) {
              res["v"] = "0.00";
            }
            if (res["oi"] == null) {
              res["oi"] = "0.00";
            }
            if (res["toi"] == null) {
              res["toi"] = "0.00";
            }
            if (res["poi"] == null) {
              res["poi"] = "0.00";
            }
            if (res["sp1"] == null) {
              res["sp1"] = "0.00";
            }
            if (res["sp2"] == null) {
              res["sp2"] = "0.00";
            }
            if (res["sp3"] == null) {
              res["sp3"] = "0.00";
            }
            if (res["sp4"] == null) {
              res["sp4"] = "0.00";
            }
            if (res["sp5"] == null) {
              res["sp5"] = "0.00";
            }
            if (res["sq1"] == null) {
              res["sq1"] = "0";
            }
            if (res["sq2"] == null) {
              res["sq2"] = "0";
            }
            if (res["sq3"] == null) {
              res["sq3"] = "0";
            }
            if (res["sq4"] == null) {
              res["sq4"] = "0";
            }
            if (res["sq5"] == null) {
              res["sq5"] = "0";
            }
            if (res["tsq"] == null) {
              res["tsq"] = "0.00";
            }
            if (res["bp1"] == null) {
              res["bp1"] = "0.00";
            }
            if (res["bp2"] == null) {
              res["bp2"] = "0.00";
            }
            if (res["bp3"] == null) {
              res["bp3"] = "0.00";
            }
            if (res["bp4"] == null) {
              res["bp4"] = "0.00";
            }
            if (res["bp5"] == null) {
              res["bp5"] = "0.00";
            }
            if (res["bq1"] == null) {
              res["bq1"] = "0";
            }
            if (res["bq2"] == null) {
              res["bq2"] = "0";
            }
            if (res["bq3"] == null) {
              res["bq3"] = "0";
            }
            if (res["bq4"] == null) {
              res["bq4"] = "0";
            }
            if (res["bq5"] == null) {
              res["bq5"] = "0";
            }
            if (res["tbq"] == null) {
              res["tbq"] = "0";
            }

            if (res["52h"] == null) {
              res["52h"] = "0.0";
            }
            if (res["52l"] == null) {
              res["52l"] = "0.0";
            }

            if (res["ft"] == null) {
              res["ft"] = "0.0";
            }
            if (res["lc"] == null) {
              res["lc"] = "0.0";
            }
            if (res["uc"] == null) {
              res["uc"] = "0.0";
            }
            if (res["ltq"] == null) {
              res["ltq"] = "0.0";
            }
            if (res["ltt"] == null) {
              res["ltt"] = "0.0";
            }

            res["chng"] = (double.parse(

                // res["lp"] == "null" || res["lp"] == null
                //           ? res["c"] == "null" || res["c"] == null
                //               ? "0.00"
                //               : res["c"]
                //           :

                res["lp"]) - double.parse(
                // res["c"] == "null" || res["c"] == null
                //   ? "0.00"
                //   :
                res["c"])).toStringAsFixed(2);
            _socketDatas.addAll({"${res['tk']}": res});

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

          // Future.delayed(const Duration(milliseconds: 2000), () {
          notifyListeners();
          // });
        },
        onDone: () async {
          // log("Connection closed ${channel.closeRe
          //ason} ${channel.closeCode}");
          if (channel.closeCode != null) {
            closeSocket();
            _wsConnected = false;
            ref(indexListProvider).logError.add({
              "type": "Websocket ${channel.closeCode} ",
              "Error": "Connection closed "
            });
            if (ref(networkStateProvider).connectionStatus !=
                ConnectivityResult.none) {
              Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                establishConnection(
                    channelInput: ConstantName.lastSubscribe,
                    task: "t",
                    context: context);
                establishConnection(
                    channelInput: ConstantName.lastSubscribeDepth,
                    task: "d",
                    context: context);
             });
            }
          }
          // notifyListeners();
        },
        onError: (error) {
          closeSocket();
          _wsConnected = false;
          log("ref(networkStateProvider).connectionStatus ${ref(networkStateProvider).connectionStatus}");
          if (ref(networkStateProvider).connectionStatus !=
              ConnectivityResult.none) {
            // ref(showcaseProvide).showToast("Reconnecting", context);
          }
          ref(indexListProvider)
              .logError
              .add({"type": "Websocket Error", "Error": "$error"});
          print("eeee $error");
        },
      );
    } else {
      if (task.toLowerCase() == 't' ||
          task.toLowerCase() == 'u' ||
          task.toLowerCase() == 'd' ||
          task.toLowerCase() == 'ud') {
        if (channelInput.isNotEmpty) {
          connectTouchLine(input: channelInput, task: task, context: context);
        }
      }
    }
  }

  void connectTouchLine(
      {required String task,
      required String input,
      required BuildContext context}) {
    final data = {"t": task, "k": input};

    if (input.isNotEmpty) {
      channel.sink.add(jsonEncode(data));
    }
  }
}

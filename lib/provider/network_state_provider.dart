import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locator/constant.dart';
import 'index_list_provider.dart';
import 'market_watch_provider.dart';
import 'order_provider.dart';
import 'portfolio_provider.dart';
import 'websocket_provider.dart';

final networkStateProvider =
    ChangeNotifierProvider((ref) => NetworkStateProvider(ref));

class NetworkStateProvider extends ChangeNotifier {
  final Ref ref;
  NetworkStateProvider(this.ref);
  StreamController<ConnectivityResult> networkState =
      StreamController<ConnectivityResult>.broadcast();
  late StreamSubscription connection;

  // ConnectivityResult connectionResult = ConnectivityResult.none;

  ConnectivityResult _connectionStatus = ConnectivityResult.mobile;
  ConnectivityResult get connectionStatus => _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  BuildContext? _globbcontext;
  // void streamNetworkStatus() {
  //   connectStatus();
  //   connection = Connectivity().onConnectivityChanged.listen((event) {
  //     networkState.add(event);
  //     connectionResult = event;
  //     log('STATUS CHANGED ::: $event');
  //     if (event.toString().toLowerCase() == 'connectivityresult.none') {
  //       log("PRINTER ::: $event");
  //     }
  //     notifyListeners();
  //   });
  // }

  void netWorkDispose() {
    connectivitySubscription.cancel();
  }

  // connectStatus() async {
  //   final ConnectivityResult connectivityResult =
  //       await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     log("Mobile");
  //     networkState.add(connectivityResult);
  //     connectionResult = connectivityResult;
  //     // I am connected to a mobile network.
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     // I am connected to a wifi network.
  //     log("WIFI");
  //     networkState.add(connectivityResult);
  //     connectionResult = connectivityResult;
  //   }log("_connectionStatus{$connectionResult}");
  //   notifyListeners();
  // }

// Asigning context
  getContext(BuildContext context) {
    _globbcontext = context;
    notifyListeners();
  }

// Listening  Network status
  networkStream() {
    initConnectivity();
    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

// Initially check internet connection
  initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      ref.read(indexListProvider)
          .logError
          .add({"type": "Internet connection", "Error": "$e"});
      notifyListeners();
      print('Couldn\'t check connectivity status   $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    return _updateConnectionStatus(result);
  }

  _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;

    if (_connectionStatus == ConnectivityResult.none) {
      ref.read(websocketProvider).closeSocket(true);
      ref.read(websocketProvider).websockConn(false);
    } else {
      // ref.read(websocketProvider).websockConn(false);
      if (ConstantName.sessCheck) {
        if (ConstantName.lastSubscribe.isNotEmpty) {
          ref.read(websocketProvider).establishConnection(
              channelInput: ConstantName.lastSubscribe,
              task: "t",
              context: _globbcontext!);
        }
        if (ConstantName.lastSubscribeDepth.isNotEmpty) {
          ref.read(websocketProvider).establishConnection(
              channelInput: ConstantName.lastSubscribeDepth,
              task: "d",
              context: _globbcontext!);
        }
      }

      if (ref.read(indexListProvider).selectedBtmIndx == 1) {
        // await ref.read(marketWatchProvider)
        //     .fetchMWScrip(ref.read(marketWatchProvider).wlName,  _globbcontext!);

        await ref.read(marketWatchProvider)
            .requestMWScrip(context: _globbcontext!, isSubscribe: true);
      } else if (ref.read(indexListProvider).selectedBtmIndx == 2) {
        await ref.read(portfolioProvider)
            .requestWSHoldings(isSubscribe: true, context: _globbcontext!);
        await ref.read(portfolioProvider)
            .requestWSPosition(isSubscribe: true, context: _globbcontext!);
        // await ref.read(portfolioProvider).fetchHoldings(_globbcontext, "");
        // await ref.read(portfolioProvider).fetchPositionBook(_globbcontext!, false);
      } else if (ref.read(indexListProvider).selectedBtmIndx == 3) {
        await ref.read(orderProvider)
            .requestWSOrderBook(isSubscribe: true, context: _globbcontext!);

        // ref.read(orderProvider).fetchOrderBook(_globbcontext!, true);
        // ref.read(orderProvider).fetchTradeBook(_globbcontext!);

        // ref.read(orderProvider).fetchGTTOrderBook(_globbcontext!, "");
      }
    }
    // log(" connectionStatus - $_connectionStatus");
    notifyListeners();
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
 
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart'; 

// final websocketProvider =
//     ChangeNotifierProvider((ref) => WebSocketProvider(ref.read));

// class WebSocketProvider extends ChangeNotifier {
//   bool wsConnected = false;
//   late WebSocketChannel channel;
//   final pref = locator<Preferences>();
//   final Reader ref;
//   List<TouchlineAcknowledgementStream>? touchAcknowledgementData;
//   List<TouchlineAcknowledgementStream>? get getTouchAcknowledgementData =>
//       touchAcknowledgementData;

//   StreamController<TouchlineUpdateStream> mwStream =
//       StreamController<TouchlineUpdateStream>.broadcast();
//   StreamController<TouchlineAcknowledgementStream> touchAcknowledgementStream =
//       StreamController<TouchlineAcknowledgementStream>.broadcast();
//   StreamController<DepthWSResponse> dpStream =
//       StreamController<DepthWSResponse>.broadcast();
//   StreamController<DepthAckWSResponse> dpAckStream =
//       StreamController<DepthAckWSResponse>.broadcast();
//   StreamController<OrderStreamResponse> osStream =
//       StreamController<OrderStreamResponse>.broadcast();
//   WebSocketProvider(this.ref);

//   void closeSocket() {
//     channel.sink.close();
//   }

//   Future establishConnection({
//     required String channelInput,
//     required String task,
//     required BuildContext context,
//   }) async {
//     if (!wsConnected) {
//       log(":: Connecting ::");
//       channel = IOWebSocketChannel.connect("wss://ws.zebull.in/NorenWS/");
//       final bytes = utf8.encode(pref.sessionId!); // data being hashed
//       final bytes1 = utf8.encode(sha256.convert(bytes).toString());
//       final digest = sha256.convert(bytes1).toString();
//       log('DIGEST ::::: $digest');
//       final data = {
//         "t": "c",
//         "actid": '${pref.userId}_MOB',
//         "uid": '${pref.userId}_MOB',
//         "source": ApiLinks.loginType,
//         "susertoken": digest,
//       };
//       log("${jsonEncode(data)}");
//       touchAcknowledgementData = [];
//       channel.sink.add(jsonEncode(data));
//       channel.stream.listen((data) {
//         log("$data");

//         final res = jsonDecode(data.toString());
//         // log(res['s'].toString());

//         if (res['s'].toString().toLowerCase() == "ok" &&
//             res['t'].toString() == "ck") {
//           wsConnected = true;
//           if (task.toLowerCase() == 't' ||
//               task.toLowerCase() == 'u' ||
//               task.toLowerCase() == 'd' ||
//               task.toLowerCase() == 'ud') {
//             connectTouchLine(input: channelInput, task: task);
//           }
//         }
//         if (res['s'].toString().toLowerCase() == "not_ok" &&
//             res['t'].toString() == "ck") {
//           // wsConnected = false;
//           context.read(userProvider).sessionLogout(context);
//         }

//         switch (res['t'].toString().toLowerCase()) {
//           case "tf":
//             if (res['lp'] != null) {
//               log("$data");
//               mwStream.add(
//                 TouchlineUpdateStream.fromJson(res as Map<String, dynamic>),
//               );
//             }
//             break;
//           case "tk":
//             log("Scrip Acknowledgement :::: $data");
//             touchAcknowledgementData!.add(
//               TouchlineAcknowledgementStream.fromJson(
//                 res as Map<String, dynamic>,
//               ),
//             );
//             touchAcknowledgementStream
//                 .add(TouchlineAcknowledgementStream.fromJson(res));
//             // notifyListeners();
//             break;
//           case "dk":
//             log("DK ::: ${res.toString()}");
//             dpAckStream
//                 .add(DepthAckWSResponse.fromJson(res as Map<String, dynamic>));
//             break;
//           case "df":
//             log("DF ::: ${res.toString()}");
//             dpStream.add(DepthWSResponse.fromJson(res as Map<String, dynamic>));
//             break;
//         }
//         notifyListeners();
//       })
//         ..onDone(() async {
//           wsConnected = false;
//           log(":: DONE ERR :::: Connection Closed");
//           log(Connectivity().checkConnectivity().toString());
//           if (await Connectivity().checkConnectivity() !=
//               ConnectivityResult.none) {
//             // wsConnected = false;
//             log("Reconnecting");
//             log('pref.bmTabIndex :::: ${pref.bmTabIndex}');
//             try {
//               Future.delayed(const Duration(milliseconds: 100), () {
//                 if (pref.bmTabIndex == 0) {
//                   try {
//                     if (ref(marketProvider).isDepthActive) {
//                       establishConnection(
//                         channelInput:
//                             context.read(marketProvider).depthInputChennal,
//                         task: 't',
//                         context: context,
//                       );
//                       establishConnection(
//                         channelInput:
//                             context.read(marketProvider).depthInputChennal,
//                         task: 'd',
//                         context: context,
//                       );
//                     } else {
//                       ref(marketProvider)
//                           .requestWS(isSubscribe: true, context: context);
//                     }
//                   } catch (e) {
//                     log("Reconnecting Error::: $e");
//                   }
//                 } else if (pref.bmTabIndex == 2) {
//                   ref(dashboardProvider).requestWS(
//                     isSubscribe: true,
//                     context: context,
//                     subscribeAnalyticsType: '',
//                   );
//                 }
//               });
//             } catch (e) {
//               log("Reconnecting Error::: $e");
//             }

//             // establishConnection(channelInput: '', task: 'c', context: context);

//           }
//         })
//         ..onError((handleError) async {
//           wsConnected = false;
//           log(":: ERR WS :: ${handleError.toString()}");
//           log(Connectivity().checkConnectivity().toString());
//           if (await Connectivity().checkConnectivity() !=
//               ConnectivityResult.none) {
//             // wsConnected = false;
//             log("Error");
//           }
//         });
//     } else {
//       if (task.toLowerCase() == 't' ||
//           task.toLowerCase() == 'u' ||
//           task.toLowerCase() == 'd' ||
//           task.toLowerCase() == 'ud') {
//         touchAcknowledgementData = [];
//         connectTouchLine(input: channelInput, task: task);
//       }
//     }
//   }

//   void connectTouchLine({required String task, required String input}) {
//     final data = {
//       "t": task,
//       "k": input,
//     };
//     log('Subscription ws::$input $task');
//     log('Status ws::$wsConnected');
//     channel.sink.add(jsonEncode(data));
//   }
// }

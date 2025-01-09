import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/websocket_provider.dart';

class SocketDisconnectedWidget extends ConsumerWidget {
  const SocketDisconnectedWidget({super.key});



  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final webs = watch(websocketProvider);
    return Scaffold(
      body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              color: Colors.black,
              child: ListTile(
                  minLeadingWidth: 10,
                  leading: const Padding(
                      padding: EdgeInsets.only(top: 3.5),
                      child: Icon(Icons.warning_amber_outlined,
                          size: 15, color: Colors.amber)),
                  title: const Text(
                      'Websocket Disconnected',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      trailing: ElevatedButton(onPressed: () {webs.reconnect(context);}, child: const Text("Reload")),))),
    );
  }
}
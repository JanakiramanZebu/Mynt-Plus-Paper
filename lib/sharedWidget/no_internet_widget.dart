import 'package:flutter/material.dart';


//  If there is no internet, it will show on the screen.

class NoInternetWidget extends StatefulWidget {
  const NoInternetWidget({super.key});

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(.3),
              child: const ListTile(
                  minLeadingWidth: 10,
                  leading: Padding(
                      padding: EdgeInsets.only(top: 3.5),
                      child: Icon(Icons.warning_amber_outlined,
                          size: 15, color: Colors.amber)),
                  title: Text(
                      'It seems like you are offline.Please check your network connection.',
                      style: TextStyle(fontSize: 12, color: Colors.white))))),
    );
  }
}

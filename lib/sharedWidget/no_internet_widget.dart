import 'package:flutter/material.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            color: Colors.black,
            child: const ListTile(
                minLeadingWidth: 10,
                leading: Padding(
                    padding: EdgeInsets.only(top: 3.5),
                    child: Icon(Icons.warning_amber_outlined,
                        size: 15, color: Colors.amber)),
                title: Text(
                    'It seems like you are offline.Please check your network connection.',
                    style: TextStyle(fontSize: 12, color: Colors.white)))));
  }
}

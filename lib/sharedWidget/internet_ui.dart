import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InterNetUI extends StatelessWidget {
  const InterNetUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/icon/MYNT App Logo_v2.svg',
              width: 80,
              height: 80,
            ),
          ),
          const Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                ),
              ),
            ),
          ),
          Align(
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
                          style:
                              TextStyle(fontSize: 12, color: Colors.white))))),
        ],
      ),
    );
  }
}

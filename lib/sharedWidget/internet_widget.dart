import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//  If there is no internet, it will show on the screen.

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
            Container(
                color: Colors.black,
                child: const ListTile(
                    minLeadingWidth: 10,
                    leading: Padding(
                        padding: EdgeInsets.only(top: 3.5),
                        child: Icon(Icons.warning_amber_outlined,
                            size: 15, color: Colors.amber)),
                    title: Text(
                        'It seems like you are offline.Please check your network connection.',
                        style: TextStyle(fontSize: 12, color: Colors.white))))
          ],
        ),
      ),
    );
  }
}

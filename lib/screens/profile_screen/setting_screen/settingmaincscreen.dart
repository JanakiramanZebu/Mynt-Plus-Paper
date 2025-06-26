import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';

class SettingMainScreen extends StatefulWidget {
  const SettingMainScreen({super.key});

  @override
  State<SettingMainScreen> createState() => _SettingMainScreenState();
}

class _SettingMainScreenState extends State<SettingMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        elevation: 0.3,
        leadingWidth: 41,
        titleSpacing: 6,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: SvgPicture.asset(assets.backArrow),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff000000)),
        title: TextWidget.subText(
            text: 'Setting',
            theme: false,
            color: const Color(0xff000000),
            fw: 1),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, Routes.windowsetting);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 1),
              title: TextWidget.subText(
                text: 'Window Setting',
                theme: false,
                color: const Color(0xff666666),
                fw: 0,
              ),
              trailing:
                  SvgPicture.asset('assets/profile/profilerightarrow.svg'),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xffF1F3F8),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, Routes.notificationscreen);
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
              title: TextWidget.subText(
                text: 'Notification Setting',
                theme: false,
                color: const Color(0xff666666),
                fw: 1,
              ),
              trailing:
                  SvgPicture.asset('assets/profile/profilerightarrow.svg'),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xffF1F3F8),
            ),
            ListTile(
              onTap: () {
                // Navigator.pushNamed(context, Routes.setautopay);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 1),
              title: TextWidget.subText(
                text: 'Account Setting',
                theme: false,
                color: const Color(0xff666666),
                fw: 1,
              ),
              trailing:
                  SvgPicture.asset('assets/profile/profilerightarrow.svg'),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xffF1F3F8),
            ),
          ],
        ),
      ),
    );
  }
}

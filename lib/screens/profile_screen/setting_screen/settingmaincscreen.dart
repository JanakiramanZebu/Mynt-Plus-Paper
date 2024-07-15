import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
          title: Text('Setting',
              style: textStyle(const Color(0xff000000), 14, FontWeight.w600)),
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
              title: Text(
                'Window Setting',
                style: textStyle(const Color(0xff666666), 14, FontWeight.w600),
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
              title: Text(
                'Notification Setting',
                style: textStyle(const Color(0xff666666), 14, FontWeight.w600),
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
              title: Text(
                'Account Setting',
                style: textStyle(const Color(0xff666666), 14, FontWeight.w600),
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

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

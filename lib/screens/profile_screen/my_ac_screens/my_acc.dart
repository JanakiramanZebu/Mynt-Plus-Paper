import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/list_divider.dart';

class MyAccount extends ConsumerWidget {
  const MyAccount({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);   final theme =ref.read(themeProvider);
    return Scaffold(
    
      appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: const CustomBackBtn(), 
          elevation: 0.2,
          
          
          title: Text('Profile',
              style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w600)),
          ),
      body: ListView.separated(
        itemCount: userProfile.accountMenu.length,
        itemBuilder: (context, int index) {
          return ListTile(
            onTap: () async {
              await ref.read(fundProvider).fetchHstoken(context);
              if (index == 0) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "profile");
              } else if (index == 1) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "bank");
              } else if (index == 2) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "deposltory");
              } else if (index == 3) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "segment");
              } else if (index == 4) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "mtf");
              } else if (index == 5) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "annualincome");
              } else if (index == 6) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "nominee");
              } else if (index == 7) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "family");
              } else if (index == 8) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "closure");
              } else if (index == 9) {
                Navigator.pushNamed(context, Routes.profileWebViewApp,
                    arguments: "formdownload");
              }
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(userProfile.accountMenu[index]['title'],
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            trailing:
                SvgPicture.asset(userProfile.accountMenu[index]['trailing']),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const ListDivider();
        },
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

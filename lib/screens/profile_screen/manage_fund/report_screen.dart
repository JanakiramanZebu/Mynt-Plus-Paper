import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/list_divider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final List<String> reportPaths = [
      'ledger',
      'holding',
      'pnl',
      'calenderpnl',
      'taxpnl',
      'tradebook',
      'pdfdownload',
    ];
    final userProfile = watch(userProfileProvider);
    final hstoken = watch(fundProvider);
    final Preferences pref = locator<Preferences>();
    final theme = context.read(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 41,
        titleSpacing: 6,
        centerTitle: false,
        leading: const CustomBackBtn(),
        elevation: 0.2,
        title: Text('Reports',
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w600)),
      ),
      body: ListView.separated(
        itemCount: userProfile.reporttMenu.length,
        itemBuilder: (context, int index) {
          return ListTile(
            onTap: () async {
              await context.read(fundProvider).fetchHstoken(context);
              if (index >= 0 && index < reportPaths.length) {
                final url =
                    'https://profile.mynt.in/${reportPaths[index]}/?sAccountId=${pref.clientId}&sToken=${hstoken.fundHstoken!.hstk}';
                launch(url);
              }
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(userProfile.reporttMenu[index]['title'],
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            trailing:
                SvgPicture.asset(userProfile.reporttMenu[index]['trailing']),
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
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

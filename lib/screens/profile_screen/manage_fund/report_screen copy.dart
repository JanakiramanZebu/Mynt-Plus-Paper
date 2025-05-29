import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/ledger_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/user_profile_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/list_divider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final hstoken = ref.watch(fundProvider);
    final Preferences pref = locator<Preferences>();
    final theme = ref.read(themeProvider);
    final ledgerdate = ref.watch(ledgerProvider);

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
              await ref.read(fundProvider).fetchHstoken(context);

              if (index == 0) {
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "ledger");

                await ledgerdate.getCurrentDate('else');

                ledgerdate.fetchLegerData(context,
                    ledgerdate.startDate, ledgerdate.endDate);

                Navigator.pushNamed(context, Routes.ledgerscreen,
                    arguments: "DDDDD");
              } else if (index == 1) {
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "holding");
                await ledgerdate.getCurrentDate('else');

                ledgerdate.fetchholdingsData(ledgerdate.today, context);
                Navigator.pushNamed(context, Routes.holdingscreen,
                    arguments: "DDDDD");
              }
              // else if (index == 2) {
              //   Navigator.pushNamed(context, Routes.reportWebViewApp,
              //       arguments: "positions");
              // }
              else if (index == 2) {
                await ledgerdate.getCurrentDate('else');

                ledgerdate.fetchpnldata(context,
                    ledgerdate.startDate, ledgerdate.today, true);

                Navigator.pushNamed(context, Routes.pnlscreen,
                    arguments: "DDDDD");
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "pnl");
              } else if (index == 3) {
                
                await ledgerdate.getCurrentDate('else');
                 
                    ledgerdate.calendarProvider();
              ledgerdate.fetchcalenderpnldata(context,
                    ledgerdate.startDate, ledgerdate.today,'Equity');
                Navigator.pushNamed(context, Routes.calenderpnlScreen,
                    arguments: "DDDDD");
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "calenderpnl");
              } else if (index == 4) {
                await ledgerdate.getYearlistTaxpnl();
                ledgerdate.getCurrentDate('');
                print("year${ledgerdate.taxpnlyeararray[0]}");

                ledgerdate.fetchtaxpnleqdata(context, ledgerdate.yearforTaxpnl);
                //  ledgerdate.chargesforpnlseg();

                ledgerdate.taxpnlExTabchange(0);
                ledgerdate.chargesforeqtaxpnl(
                    context, ledgerdate.yearforTaxpnl);

                Navigator.pushNamed(context, Routes.taxpnlscreen,
                    arguments: "DDDDD");
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "taxpnl");
              } else if (index == 5) {
                await ledgerdate.getCurrentDate('tradebook');
                ledgerdate.fetchtradebookdata(context,
                    ledgerdate.startDate, ledgerdate.today);

                Navigator.pushNamed(context, Routes.tradebook,
                    arguments: "DDDDD");
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "tradebook");
              } else if (index == 6) {
                // launch(
                //     'https://profile.mynt.in/pdfdownload/?sAccountId=${pref.clientId}&sToken=${hstoken.fundHstoken!.hstk}'
                //     );
                 await ledgerdate.getCurrentDate('else');
                 
                 ledgerdate.fetchpdfdownload(context,
                    ledgerdate.startDate, ledgerdate.today);
                Navigator.pushNamed(context, Routes.pdfdownload,
                    arguments: "DDDDD");
                // Navigator.pushNamed(context, Routes.reportWebViewApp,
                //     arguments: "pdfdownload");
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

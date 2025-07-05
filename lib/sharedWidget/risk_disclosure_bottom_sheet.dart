import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/locator/preference.dart'; 
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../locator/locator.dart';
import 'custom_drag_handler.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:trading_app_zebu/api/core/api_link.dart';

// import '../../provider/shocase_provider.dart';

class RiskDisclousreBottomSheet extends ConsumerWidget {
  const RiskDisclousreBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      final theme = ref.read(themeProvider);
    final Preferences pref = locator<Preferences>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
             const CustomDragHandler(),
              const SizedBox(height: 10),
              Row(children: [
                SvgPicture.asset("assets/icon/reports.svg" ,color:  theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                Text('  Risk disclosures on derivatives',
                    overflow: TextOverflow.ellipsis,
                    style:
                        textStyle( theme.isDarkMode?colors.colorWhite:colors.colorBlack, 16, FontWeight.w600))
              ]),
              Column(children: [
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.circle, size: 9.5)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          "9 out of 10 individual traders in the equity Futures and Options (F&O) segment incurred net losses.",
                          style: textStyle(
                              theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500)))
                ]),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.circle, size: 9.5)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          "On average, the loss-making traders registered a net trading loss close to ₹50,000.",
                          style: textStyle(
                           theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500)))
                ]),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.circle, size: 9.5)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          "Over and above the net trading losses incurred, loss makers expended an additional 28% of net trading losses as transaction costs.",
                          style: textStyle(
                             theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500)))
                ]),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.circle, size: 9.5)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          "Those making net trading profits incurred between 15% to 50% of such profits as transaction costs.",
                          style: textStyle(
                               theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500)))
                ]),
                const SizedBox(height: 12),
                RichText(
                    text: TextSpan(
                        style: textStyle(
           colors.colorGrey, 11, FontWeight.w400),
                        children: <TextSpan>[
                      const TextSpan(text: 'Source: '),
                      TextSpan(
                          text: 'SEBI study ',
                          style: textStyle(
                         theme.isDarkMode?colors.colorLightBlue:colors.colorBlue     , 11, FontWeight.w500)),
                      const TextSpan(
                          text:
                              "dated January 25, 2023, on 'Analysis of Profit and Loss of Individual Traders dealing in equity Futures and Options (F&O) Segment,' wherein Aggregate Level findings are based on annual Profit/Loss incurred by individual traders in equity F&O during FY 2021-22.")
                    ])),
                const SizedBox(height: 12)
              ]),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        pref.setRiskDiscloser(true);
                        // if (ApiLinks.showAppTutorial) {
                        //    WidgetsBinding.instance.addPostFrameCallback((_) =>
                        //     ShowCaseWidget.of(context).startShowCase([
                        //       ref.read(showcaseProvide).createwatchlistcase
                              
                        //     ]));
                        // }
                       

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:  theme.isDarkMode?colors.primaryDark:colors.primaryLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      child: Text("I Understand",
                          style: textStyle(
                              ! theme.isDarkMode?colors.colorWhite:colors.colorWhite, 14, FontWeight.w500)))),
              const SizedBox(height: 14)
            ]));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  Text headerTitleText(String text) {
    return Text(text,
        style: textStyle(const Color(0xff000000), 14, FontWeight.w500));
  }
}

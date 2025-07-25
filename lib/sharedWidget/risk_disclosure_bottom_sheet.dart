import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/locator/preference.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../locator/locator.dart';
import '../res/global_state_text.dart';
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

    return SafeArea(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
                const SizedBox(height: 10),
                Row(children: [
                  // SvgPicture.asset("assets/icon/reports.svg" , height: 20, width: 20, color:  theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                  TextWidget.titleText(
                    text: '  Risk disclosures on derivatives',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
                    textOverflow: TextOverflow.ellipsis,
                  )
                ]),
                Column(children: [
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "9 out of 10 individual traders in the equity Futures and Options (F&O) segment incurred net losses.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "On average, the loss-making traders registered a net trading loss close to ₹50,000.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "Over and above the net trading losses incurred, loss makers expended an additional 28% of net trading losses as transaction costs.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle,
                            size: 9.5, color: colors.primaryLight)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextWidget.subText(
                      text:
                          "Those making net trading profits incurred between 15% to 50% of such profits as transaction costs.",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ))
                  ]),
                  const SizedBox(height: 12),
      
                  Text(
                    "Source: SEBI study dated January 25, 2023, on 'Analysis of Profit and Loss of Individual Traders dealing in equity Futures and Options (F&O) Segment,' wherein Aggregate Level findings are based on annual Profit/Loss incurred by individual traders in equity F&O during FY 2021-22.",
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                          height: 1.3,
                    ),
                  ),
      
                  // RichText(
                  //     text: TextSpan(
                  //         style: TextWidget.textStyle(
                  //           fontSize: 12,
                  //           theme: theme.isDarkMode,
                  //           color: theme.isDarkMode?colors.textSecondaryDark : colors.textSecondaryLight,
      
                  //         ),
                  //         children: <TextSpan>[
                  //       const TextSpan(text: 'Source: '),
                  //       TextSpan(
                  //           text: 'SEBI study ',
                  //           style: TextWidget.textStyle(
                  //             fontSize: 12,
                  //             theme: theme.isDarkMode,
                  //             color: theme.isDarkMode?colors.secondaryDark:colors.secondaryLight,
      
                  //           )),
                  //       const TextSpan(
                  //           text:
                  //               "dated January 25, 2023, on 'Analysis of Profit and Loss of Individual Traders dealing in equity Futures and Options (F&O) Segment,' wherein Aggregate Level findings are based on annual Profit/Loss incurred by individual traders in equity F&O during FY 2021-22.")
                  //     ])),
                  const SizedBox(height: 12)
                ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
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
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: TextWidget.subText(
                          text: "I Understand",
                          color: colors.colorWhite,
                          theme: theme.isDarkMode,
                          fw: 2,
                        ),
                      )),
                ),
                const SizedBox(height: 14)
              ])),
    );
  }
}

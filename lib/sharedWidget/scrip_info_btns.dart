import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../models/marketwatch_model/get_quotes.dart';
import '../provider/market_watch_provider.dart';
import '../provider/user_profile_provider.dart';
import '../routes/route_names.dart';
import '../screens/market_watch/scrip_depth_info.dart';

// Common methods for visible scrip information buttons, such as overview, chart, option chain, and others, are covered in this class.

class ScripInfoBtns extends ConsumerWidget {
  final String token;
  final String exch;
  final String insName;
  final String tsym;
  final Function(Function)? navigationLock;
  
  const ScripInfoBtns({
      super.key,
      required this.exch,
      required this.token,
      required this.insName,
      required this.tsym,
      this.navigationLock});

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketwatch = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
      height: 50,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider),
              top: BorderSide(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider))),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: marketwatch.depthBtns.length,
        itemBuilder: (BuildContext context, int index) {
          final bool isActive = 
              marketwatch.actDeptBtn == marketwatch.depthBtns[index]['btnName'];
          
          return ElevatedButton(
            onPressed: () async {
              if (navigationLock != null) {
                // Use the navigation lock to prevent multiple navigation events
                navigationLock!(() async {
                  await _handleButtonPress(
                      context, ref, marketwatch, index);
                });
              } else {
                await _handleButtonPress(context, ref, marketwatch, index);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              backgroundColor: theme.isDarkMode
                  ? isActive
                      ? const Color(0xff212121)
                      : const Color(0xffB5C0CF).withOpacity(.15)
                  : isActive
                      ? const Color(0xff000000)
                      : const Color(0xffF1F3F8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "${marketwatch.depthBtns[index]['imgPath']}",
                  width: 16,
                  height: 16,
                  color: theme.isDarkMode
                      ? isActive
                          ? Colors.white
                          : Colors.white
                      : isActive
                          ? Colors.white
                          : Colors.black,
                ),
                const SizedBox(width: 6),
                Text(
                  "${marketwatch.depthBtns[index]['btnName']}",
                  style: textStyle(
                    theme.isDarkMode
                        ? isActive
                            ? Colors.white
                            : Colors.white
                        : isActive
                            ? Colors.white
                            : Colors.black,
                    12,
                    FontWeight.w500
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 10);
        },
      ),
    );
  }

  Future<void> _handleButtonPress(BuildContext context, WidgetRef ref,
      MarketWatchProvider marketwatch, int index) async {
    // Set to initial loading state
    marketwatch.singlePageloader(true);

    try {
      if (marketwatch.depthBtns[index]['btnName'] == "Chart") {
        // Chart button logic
        ref.read(userProfileProvider).setChartdialog(true);
        marketwatch.setChartScript(exch, token, tsym);
      } else if (marketwatch.depthBtns[index]['btnName'] == "Option") {
        // Option button logic - direct navigation
        if (exch == "NFO" || (exch == "MCX" && insName == "OPTFUT")) {
          await marketwatch.fetchStikePrc(
              "${marketwatch.getQuotes!.undTk}",
              "${marketwatch.getQuotes!.undExch}",
              context);
        }
        
        // First set up the option script data
        marketwatch.setOptionScript(
            context,
            exch,
            token,
            tsym);
        
        // Wait a small amount of time to ensure data is processed
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Create depth args for navigation
        DepthInputArgs depthArgs = DepthInputArgs(
            exch: exch,
            token: token,
            tsym: marketwatch.getQuotes!.tsym ?? '',
            instname: marketwatch.getQuotes!.instname ?? "",
            symbol: marketwatch.getQuotes!.symbol ?? '',
            expDate: marketwatch.getQuotes!.expDate ?? '',
            option: marketwatch.getQuotes!.option ?? '');
        
        // Navigate directly to option chain screen
        Navigator.pop(context);
        Navigator.pushNamed(
            context,
            Routes.optionChain,
            arguments: depthArgs);
      } else {
        // For other buttons, show the depth info in a bottom sheet
        DepthInputArgs depthArgs = DepthInputArgs(
            exch: exch,
            token: token,
            tsym: '${marketwatch.getQuotes!.tsym}',
            instname: marketwatch.getQuotes!.instname ?? "",
            symbol: '${marketwatch.getQuotes!.symbol}',
            expDate: '${marketwatch.getQuotes!.expDate}',
            option: '${marketwatch.getQuotes!.option}');
        Navigator.pop(context);

        showModalBottomSheet(
            barrierColor: Colors.transparent,
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16))),
            backgroundColor: const Color(0xffffffff),
            context: context,
            builder: (context) => ScripDepthInfo(
                wlValue: depthArgs, isBasket: ''));
      }
    } finally {
      // Ensure we turn off loading regardless of success/failure
      marketwatch.singlePageloader(false);
    }
  }
}

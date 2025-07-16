import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../res/global_state_text.dart';
import '../res/res.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // To format the dates

class IpoTimeLineWidget extends StatelessWidget {
  final bool isfFrist;
  final bool isLast;
  final Map<String, dynamic> orderHistoryData;
  const IpoTimeLineWidget({
    super.key,
    required this.isfFrist,
    required this.isLast,
    required this.orderHistoryData,
  });

  @override
  Widget build(BuildContext context) {
    // final today = DateTime.now();
    // final eventDate =
    //     DateFormat('EEE, MMM d, yyyy').parse(orderHistoryData['value']!);
    // // final eventDate =
    // // DateFormat('EEEE, MMMM d, yyyy').parse(orderHistoryData['value']!);
    // Color lineColor;
    // Color indicatorColor;
    // // Check if the event is in the past, today, or in the future
    // if (eventDate.isAfter(today)) {
    //   lineColor = const Color(0xffFFB038); // Past dates
    //   indicatorColor = const Color(0xffFFB038);
    // } else if (eventDate.isAtSameMomentAs(today)) {
    //   lineColor = colors.colorLightBlue; // Today's date
    //   indicatorColor = colors.colorLightBlue;
    // } else {
    //   lineColor = const Color(0xff2DB266);
    //   indicatorColor = const Color(0xff2DB266);
    // }
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);

        return Column(
          children: [
            const SizedBox(height: 8),
            _buildInfoRow(
                orderHistoryData['name'], orderHistoryData['value'], theme),
            const SizedBox(height: 8),
          ],
        );

        // TimelineTile(
        //     hasIndicator: true,
        //     isFirst: isfFrist,
        //     isLast: isLast,
        //     afterLineStyle: LineStyle(thickness: 2, color: lineColor),
        //     beforeLineStyle: LineStyle(thickness: 2, color: lineColor),
        //     indicatorStyle: IndicatorStyle(
        //         width: 20,
        //         color: indicatorColor,
        //         iconStyle: IconStyle(
        //           iconData: lineColor == const Color(0xffFFB038)
        //               ? Icons.more_horiz_outlined
        //               : Icons.check,
        //           fontSize: 12,
        //           color: const Color(0xffffffff),
        //         )),
        //     endChild: Container(
        //       margin: const EdgeInsets.only(left: 4),
        //       // decoration: BoxDecoration(
        //       //   color: lineColor == const Color(0xffFFB038)
        //       //       ? const Color(0xffFFF6E6)
        //       //       : const Color(0xffECF8F1),
        //       //   borderRadius: BorderRadius.circular(10),
        //       //   // border: Border.all(color: Colors.grey.withOpacity(.3)
        //       // ),
        //       child: ListTile(
        //         contentPadding:
        //             const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        //         dense: true,
        //         title: Text(orderHistoryData['name']!.toUpperCase(),
        //             style: textStyle(
        //                 theme.isDarkMode
        //                     ? colors.colorWhite
        //                     : colors.colorBlack,
        //                 12,
        //                 FontWeight.w500)),
        //         subtitle: Text(orderHistoryData['value']!,
        //             style: textStyle(
        //                 const Color(0xff666666), 10, FontWeight.w500)),
        //       ),
        //     ));
      },
    );
  }

  Widget _buildInfoRow(String title1, String value1, ThemesProvider theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              text: title1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
          TextWidget.subText(
              text: value1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 3),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0)
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../res/res.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // To format the dates

class MFtimelineWidget extends StatelessWidget {
  final bool isfFrist;
  final bool isLast;
final Map<String, dynamic> orderHistoryData;
  const MFtimelineWidget({
    super.key,
    required this.isfFrist,
    required this.isLast,
    required this.orderHistoryData,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // final eventDate =
    //     DateFormat('EEE, MMM d, yyyy').parse(orderHistoryData['value']!);
    // // final eventDate =
    // // DateFormat('EEEE, MMMM d, yyyy').parse(orderHistoryData['value']!);
    Color lineColor;
    Color indicatorColor;
    Color lineColor1;
    Color indicatorColor2;
    // // Check if the event is in the past, today, or in the future
    // if (eventDate.isAfter(today)) {
    //   lineColor = const Color(0xffFFB038); // Past dates
    //   indicatorColor = const Color(0xffFFB038);
    // } else if (eventDate.isAtSameMomentAs(today)) {
    //   lineColor = colors.colorLightBlue; // Today's date
    //   indicatorColor = colors.colorLightBlue;
    // } else {
      lineColor = const Color(0xff2DB266); // Future dates
      indicatorColor = const Color(0xff2DB266);
       lineColor1 = const Color(0XFFD34645); // Future dates
      indicatorColor2 = const Color(0XFFD34645);
    // }
    return Container(
      padding: const EdgeInsets.symmetric(),
      height: 60,
      child: TimelineTile(
          hasIndicator: true,
          // isFirst: isfFrist,
          // isLast: isLast,
          afterLineStyle: LineStyle(thickness: 2, color: orderHistoryData['register_cancel'] == "CANCELLED" ? lineColor1 : lineColor),
          beforeLineStyle: LineStyle(thickness: 2, color:  orderHistoryData['register_cancel'] == "CANCELLED" ? indicatorColor2 : indicatorColor),
          indicatorStyle: IndicatorStyle(
              width: 20,
              color: orderHistoryData['register_cancel'] == "CANCELLED" ? lineColor1 : lineColor,
              iconStyle: IconStyle(
                iconData: orderHistoryData['register_cancel'] == "CANCELLED"
                    ? Icons.more_horiz_outlined
                    : Icons.check,
                fontSize: 12,
                color: const Color(0xffffffff),
              )),
          endChild: Container(
            margin: const EdgeInsets.only(left: 4),
            // decoration: BoxDecoration(
            //   color: lineColor == const Color(0xffFFB038)
            //       ? const Color(0xffFFF6E6)
            //       : const Color(0xffECF8F1),
            //   borderRadius: BorderRadius.circular(10),
            //   // border: Border.all(color: Colors.grey.withOpacity(.3)
            // ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              dense: true,
              title: Text(orderHistoryData['register_cancel']!.toUpperCase(),
                  style: textStyle(colors.colorBlack, 12, FontWeight.w500)),
              subtitle: Text(orderHistoryData['date']!,
                  style:
                      textStyle(const Color(0xff666666), 10, FontWeight.w500)),
            ),
          )),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

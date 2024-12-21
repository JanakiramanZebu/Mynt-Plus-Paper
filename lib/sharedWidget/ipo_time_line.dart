import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
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
   
    final today = DateTime.now();
    final eventDate =
        DateFormat('EEEE, MMMM d, yyyy').parse(orderHistoryData['value']!);
    Color lineColor;
    Color indicatorColor;
    // Check if the event is in the past, today, or in the future
    if (eventDate.isAfter(today)) {
      lineColor = const Color(0xffFFB038); // Past dates
      indicatorColor = const Color(0xffFFB038);
    } else if (eventDate.isAtSameMomentAs(today)) {
      lineColor = colors.colorLightBlue; // Today's date
      indicatorColor = colors.colorLightBlue;
    } else {
      lineColor = const Color(0xff2DB266); // Future dates
      indicatorColor = const Color(0xff2DB266);
    }
    return Container(
      padding: const EdgeInsets.symmetric(),
      height: 90,
      child: TimelineTile(
          hasIndicator: true,
          isFirst: isfFrist,
          isLast: isLast,
          afterLineStyle: LineStyle(thickness: 2, color: lineColor),
          beforeLineStyle: LineStyle(thickness: 2, color: lineColor),
          indicatorStyle: IndicatorStyle(
              width: 22,
              color: indicatorColor,
              iconStyle: IconStyle(
                iconData: lineColor == const Color(0xffFFB038)
                    ? Icons.more_horiz_outlined
                    : Icons.check,
                fontSize: 12,
                color: const Color(0xffffffff),
              )),
          endChild: Container(
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: lineColor == const Color(0xffFFB038)
                  ? const Color(0xffFFF6E6)
                  : const Color(0xffECF8F1),
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(color: Colors.grey.withOpacity(.3)
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              dense: true,
              title: Text(orderHistoryData['name']!.toUpperCase(),
                  style: textStyle(
                      colors.colorBlack,
                      14,
                      FontWeight.w500)),
              subtitle: Text(orderHistoryData['value']!,
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

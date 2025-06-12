import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:timeline_tile/timeline_tile.dart';

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
    // Get appropriate colors based on the status
    final registerCancelValue = orderHistoryData['register_cancel'] as String?;
    final isLive = registerCancelValue == "CANCELLED";
    final lineColor = isLive ? const Color(0XFFD34645) : const Color(0xff2DB266);
    final indicatorColor = isLive ? const Color(0XFFD34645) : const Color(0xff2DB266);
    
    return Container(
      padding: const EdgeInsets.symmetric(),
      height: 60,
      child: TimelineTile(
          hasIndicator: true,
          afterLineStyle: LineStyle(thickness: 2, color: lineColor),
          beforeLineStyle: LineStyle(thickness: 2, color: indicatorColor),
          indicatorStyle: IndicatorStyle(
              width: 20,
              color: lineColor,
              iconStyle: IconStyle(
                iconData: isLive 
                    ? Icons.more_horiz_outlined
                    : Icons.check,
                fontSize: 12,
                color: const Color(0xffffffff),
              )),
          endChild: Container(
            margin: const EdgeInsets.only(left: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              dense: true,
              title: Text(
                (registerCancelValue ?? "UNKNOWN").toUpperCase(),
                style: textStyle(colors.colorBlack, 12, FontWeight.w500)
              ),
              subtitle: Text(
                orderHistoryData['date'] as String? ?? "Unknown date",
                style: textStyle(const Color(0xff666666), 10, FontWeight.w500)
              ),
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

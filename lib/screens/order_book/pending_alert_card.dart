// ignore_for_file: deprecated_member_use
import 'dart:math';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/no_data_found.dart';


class PendingAlert extends StatefulWidget {
  const PendingAlert({super.key});


  @override
  State<PendingAlert> createState() => _PendingAlertState();
}


class _PendingAlertState extends State<PendingAlert> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final manage = watch(marketWatchProvider);        final theme = context.read(themeProvider);
      double angleInDegrees = 55;
      double angleInRadians = angleInDegrees * (pi / 180);
      return manage.alertPendingModel!.isNotEmpty &&  manage.alertPendingModel![0].stat!="Not_Ok"
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            Navigator.pushNamed(
                                context, Routes.pendingalertdetails,
                                arguments:
                                    manage.alertPendingModel![index]);
                          },
                          child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "${manage.alertPendingModel![index].tsym} ",
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: textStyles
                                                  .scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                                          Row(
                                            children: [
                                              Text(" LTP: ",
                                                  style: textStyle(
                                                      const Color(
                                                          0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  "₹${manage.alertPendingModel![index].ltp ?? manage.alertPendingModel![index].close ?? 0.00}",
                                                  style: textStyle(
                                                     theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          )
                                        ]),
                                    const SizedBox(height: 4),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                        CustomExchBadge(exch: "${manage.alertPendingModel![index].exch}"),
                                          Text(
                                              " (${manage.alertPendingModel![index].perChange ?? 0.00}%)",
                                              style: textStyle(
                                                  Color(manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .perChange ==
                                                          null
                                                      ? 0
                                                      : manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .perChange!
                                                              .startsWith(
                                                                  "-")
                                                          ? 0XFFFF1717
                                                          : manage.alertPendingModel![index]
                                                                      .perChange ==
                                                                  "0.00"
                                                              ? 0xff666666
                                                              : 0xff43A833),
                                                  12,
                                                  FontWeight.w500))
                                        ]),
                                    const SizedBox(height: 4),
                                  Divider(color: theme.isDarkMode?colors.darkColorDivider:colors.colorDivider),
                                    const SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Alert: ",
                                                  style: textStyle(
                                                      const Color(
                                                          0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .aiT ==
                                                          "LTP_A"
                                                      ? "LTP Above"
                                                      : manage
                                                                  .alertPendingModel![
                                                                      index]
                                                                  .aiT ==
                                                              "LTP_B"
                                                          ? "LTP Below"
                                                          : manage
                                                                      .alertPendingModel![
                                                                          index]
                                                                      .aiT ==
                                                                  "CH_PER_A"
                                                              ? "Perc.Change Above"
                                                              : "Perc.Change below",
                                                  style: textStyle(
                                                     theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                              Transform.rotate(
                                                angle: angleInRadians,
                                                child: Icon(
                                                    manage
                                                                .alertPendingModel![
                                                                    index]
                                                                .aiT ==
                                                            "LTP_A"
                                                        ? Icons.arrow_upward
                                                        : manage
                                                                    .alertPendingModel![
                                                                        index]
                                                                    .aiT ==
                                                                "LTP_B"
                                                            ? Icons
                                                                .arrow_downward
                                                            : manage.alertPendingModel![index].aiT ==
                                                                    "CH_PER_A"
                                                                ? Icons
                                                                    .arrow_upward
                                                                : Icons
                                                                    .arrow_downward,
                                                    size: 18,
                                                    color: manage
                                                                .alertPendingModel![
                                                                    index]
                                                                .aiT ==
                                                            "LTP_A"
                                                        ? const Color(
                                                            0xff43A833)
                                                        : manage
                                                                    .alertPendingModel![
                                                                        index]
                                                                    .aiT ==
                                                                "LTP_B"
                                                            ? const Color(
                                                                0xffFF1717)
                                                            : manage.alertPendingModel![index].aiT ==
                                                                    "CH_PER_A"
                                                                ? const Color(
                                                                    0xff43A833)
                                                                : const Color(
                                                                    0xffFF1717)),
                                              ),
                                              Text(manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .aiT ==
                                                          "CH_PER_A" ||
                                                      manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .aiT ==
                                                          "CH_PER_B"
                                                  ? "%${manage.alertPendingModel![index].d}"
                                                  : "₹${manage.alertPendingModel![index].d}"),
                                            ],
                                          ),
                                        ])
                                  ])));
                    },
                    itemCount: manage.alertPendingModel!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          color: theme.isDarkMode?colors.darkGrey: const Color(0xffF1F3F8), height: 6);
                    },
                  ),
                ],
              ))
          : const NoDataFound();
    });
  }


  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}






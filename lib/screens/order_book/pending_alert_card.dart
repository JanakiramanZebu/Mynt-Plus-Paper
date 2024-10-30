// ignore_for_file: deprecated_member_use
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_alert_pending.dart';

class PendingAlert extends StatefulWidget {
  const PendingAlert({super.key});

  @override
  State<PendingAlert> createState() => _PendingAlertState();
}

class _PendingAlertState extends State<PendingAlert> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final manage = watch(marketWatchProvider);
      final theme = context.read(themeProvider);
      double angleInDegrees = 55;
      double angleInRadians = angleInDegrees * (pi / 180);
      return SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (manage.alertPendingModel!.length > 1)
            Container(
                decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            width: 6))),
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 2, top: 8, bottom: 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(children: [
                            InkWell(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  showModalBottomSheet(
                                      useSafeArea: true,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16))),
                                      context: context,
                                      builder: (context) {
                                        return const OrderbookPendingAlertkFilterBottomSheet();
                                      });
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: SvgPicture.asset(assets.filterLines,
                                        color: const Color(0xff333333)))),
                            InkWell(
                                onTap: () {
                                  manage.showAlertPendingSearch(true);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, left: 10),
                                    child: SvgPicture.asset(assets.searchIcon,
                                        width: 19,
                                        color: const Color(0xff333333))))
                          ])
                        ]))),
          if (manage.showAlertSearch)
            Container(
              height: 62,
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          width: 6))),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                      controller: manage.alertPendingSearchtext,
                      style: textStyle(
                          const Color(0xff000000), 16, FontWeight.w600),
                      decoration: InputDecoration(
                          fillColor: const Color(0xffF1F3F8),
                          filled: true,
                          hintStyle: textStyle(
                              const Color(0xff69758F), 15, FontWeight.w500),
                          prefixIconColor: const Color(0xff586279),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SvgPicture.asset(assets.searchIcon,
                                color: const Color(0xff586279),
                                fit: BoxFit.contain,
                                width: 20),
                          ),
                          suffixIcon: InkWell(
                            onTap: () async {
                              manage.clearAlertSearch();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SvgPicture.asset(assets.removeIcon,
                                  fit: BoxFit.scaleDown, width: 20),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20)),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20)),
                          hintText: "Search Scrip Name",
                          contentPadding: const EdgeInsets.only(top: 20),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20))),
                      onChanged: (value) async {
                        manage.orderAletrPendingSearch(value, context);
                      },
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        manage.showAlertPendingSearch(false);
                        manage.clearAlertSearch();
                      },
                      child: Text("Close", style: textStyles.textBtn))
                ],
              ),
            ),
          if (manage.alertPendingSearch!.isEmpty)
            manage.alertPendingModel!.isNotEmpty &&
                    manage.alertPendingModel![0].stat != "Not_Ok"
                ? ListView.separated(
                    primary: true,
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            Navigator.pushNamed(
                                context, Routes.pendingalertdetails,
                                arguments: manage.alertPendingModel![index]);
                          },
                          child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "${manage.alertPendingModel![index].tsym} ",
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyles
                                                  .scripNameTxtStyle
                                                  .copyWith(
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack)),
                                          Row(
                                            children: [
                                              Text(" LTP: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  "₹${manage.alertPendingModel![index].ltp ?? manage.alertPendingModel![index].close ?? 0.00}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
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
                                          CustomExchBadge(
                                              exch:
                                                  "${manage.alertPendingModel![index].exch}"),
                                          Text(
                                              " (${manage.alertPendingModel![index].perChange ?? 0.00}%)",
                                              style: textStyle(
                                                  manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .perChange ==
                                                          null
                                                      ? colors.ltpgrey
                                                      : manage
                                                              .alertPendingModel![
                                                                  index]
                                                              .perChange!
                                                              .startsWith("-")
                                                          ? colors.darkred
                                                          : manage
                                                                      .alertPendingModel![
                                                                          index]
                                                                      .perChange ==
                                                                  "0.00"
                                                              ? colors.ltpgrey
                                                              : colors.ltpgreen,
                                                  12,
                                                  FontWeight.w500))
                                        ]),
                                    const SizedBox(height: 4),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.darkColorDivider
                                            : colors.colorDivider),
                                    const SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Alert: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
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
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
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
                                                            : manage
                                                                        .alertPendingModel![
                                                                            index]
                                                                        .aiT ==
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
                                                        ? colors.ltpgreen
                                                        : manage
                                                                    .alertPendingModel![
                                                                        index]
                                                                    .aiT ==
                                                                "LTP_B"
                                                            ? colors.darkred
                                                            : manage
                                                                        .alertPendingModel![
                                                                            index]
                                                                        .aiT ==
                                                                    "CH_PER_A"
                                                                ? colors
                                                                    .ltpgreen
                                                                : colors
                                                                    .darkred),
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
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          height: 6);
                    },
                  )
                : const SizedBox(
                    height: 500, child: Center(child:  NoDataFound())),
          if (manage.alertPendingSearch!.isNotEmpty)
            ListView.separated(
              primary: true,
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () async {
                      Navigator.pushNamed(context, Routes.pendingalertdetails,
                          arguments: manage.alertPendingSearch![index]);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${manage.alertPendingSearch![index].tsym} ",
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyles.scripNameTxtStyle
                                            .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack)),
                                    Row(
                                      children: [
                                        Text(" LTP: ",
                                            style: textStyle(
                                                const Color(0xff5E6B7D),
                                                13,
                                                FontWeight.w600)),
                                        Text(
                                            "₹${manage.alertPendingSearch![index].ltp ?? manage.alertPendingSearch![index].close ?? 0.00}",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w500)),
                                      ],
                                    )
                                  ]),
                              const SizedBox(height: 4),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomExchBadge(
                                        exch:
                                            "${manage.alertPendingSearch![index].exch}"),
                                    Text(
                                        " (${manage.alertPendingSearch![index].perChange ?? 0.00}%)",
                                        style: textStyle(
                                            manage.alertPendingSearch![index]
                                                        .perChange ==
                                                    null
                                                ? colors.ltpgrey
                                                : manage
                                                        .alertPendingSearch![
                                                            index]
                                                        .perChange!
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : manage
                                                                .alertPendingSearch![
                                                                    index]
                                                                .perChange ==
                                                            "0.00"
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen,
                                            12,
                                            FontWeight.w500))
                                  ]),
                              const SizedBox(height: 4),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider),
                              const SizedBox(height: 5),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Alert: ",
                                            style: textStyle(
                                                const Color(0xff5E6B7D),
                                                13,
                                                FontWeight.w600)),
                                        Text(
                                            manage.alertPendingSearch![index]
                                                        .aiT ==
                                                    "LTP_A"
                                                ? "LTP Above"
                                                : manage
                                                            .alertPendingSearch![
                                                                index]
                                                            .aiT ==
                                                        "LTP_B"
                                                    ? "LTP Below"
                                                    : manage
                                                                .alertPendingSearch![
                                                                    index]
                                                                .aiT ==
                                                            "CH_PER_A"
                                                        ? "Perc.Change Above"
                                                        : "Perc.Change below",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w500)),
                                        Transform.rotate(
                                          angle: angleInRadians,
                                          child: Icon(
                                              manage.alertPendingSearch![index]
                                                          .aiT ==
                                                      "LTP_A"
                                                  ? Icons.arrow_upward
                                                  : manage
                                                              .alertPendingSearch![
                                                                  index]
                                                              .aiT ==
                                                          "LTP_B"
                                                      ? Icons.arrow_downward
                                                      : manage
                                                                  .alertPendingSearch![
                                                                      index]
                                                                  .aiT ==
                                                              "CH_PER_A"
                                                          ? Icons.arrow_upward
                                                          : Icons
                                                              .arrow_downward,
                                              size: 18,
                                              color: manage
                                                          .alertPendingSearch![
                                                              index]
                                                          .aiT ==
                                                      "LTP_A"
                                                  ? colors.ltpgreen
                                                  : manage
                                                              .alertPendingSearch![
                                                                  index]
                                                              .aiT ==
                                                          "LTP_B"
                                                      ? colors.darkred
                                                      : manage
                                                                  .alertPendingSearch![
                                                                      index]
                                                                  .aiT ==
                                                              "CH_PER_A"
                                                          ? colors.ltpgreen
                                                          : colors.darkred),
                                        ),
                                        Text(manage.alertPendingSearch![index]
                                                        .aiT ==
                                                    "CH_PER_A" ||
                                                manage
                                                        .alertPendingSearch![
                                                            index]
                                                        .aiT ==
                                                    "CH_PER_B"
                                            ? "%${manage.alertPendingSearch![index].d}"
                                            : "₹${manage.alertPendingSearch![index].d}"),
                                      ],
                                    ),
                                  ])
                            ])));
              },
              itemCount: manage.alertPendingSearch!.length,
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                    color: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    height: 6);
              },
            )
        ],
      ));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

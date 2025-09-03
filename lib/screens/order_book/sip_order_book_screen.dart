import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/res/res.dart';
import '../../models/order_book_model/sip_order_book.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_sip.dart';

class SipOrderBook extends ConsumerWidget {
  final List<SipDetails>? sipbook;
  const SipOrderBook({super.key, required this.sipbook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final order = ref.watch(orderProvider);
    return sipbook == null
        ? const NoDataFound()
        : Column(
            children: [
              if (sipbook!.length > 1)
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
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(16))),
                                          context: context,
                                          builder: (context) {
                                            return const OrderbookSipkFilterBottomSheet();
                                          });
                                    },
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: SvgPicture.asset(
                                            assets.filterLines,
                                            color: const Color(0xff333333)))),
                                InkWell(
                                    onTap: () {
                                      order.showSipSearch(true);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 12, left: 10),
                                        child: SvgPicture.asset(
                                            assets.searchIcon,
                                            width: 19,
                                            color: const Color(0xff333333))))
                              ])
                            ]))),
              if (order.showSipOrderSearch)
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
                          controller: order.orderSipSearchCtrl,
                          style: TextWidget.textStyle(
                              color: const Color(0xff000000),
                              fontSize: 16,
                              fw: 1,
                              theme: false),
                          decoration: InputDecoration(
                              fillColor: const Color(0xffF1F3F8),
                              filled: true,
                              hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                    fw: 0,
                                    ),
                              prefixIconColor: const Color(0xff586279),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: SvgPicture.asset(assets.searchIcon,
                                    color: const Color(0xff586279),
                                    fit: BoxFit.contain,
                                    width: 20),
                              ),
                              suffixIcon: InkWell(
                                onTap: () async {
                                  order.clearSipSearch();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
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
                            order.orderSipSearch(value, context);
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            order.showSipSearch(false);
                            order.clearSipSearch();
                          },
                          child: TextWidget.subText(
                              text: "Close",
                              theme: false,
                              color: colors.colorBlue,
                              fw: 0)),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.siporderBookSearch!.isEmpty)
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () async {
                                  ref
                                      .read(orderProvider)
                                      .fetchSipOrderHistory(context);
                                  Navigator.pushNamed(
                                      context, Routes.sipDetails,
                                      arguments: sipbook![index]);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget.titleText(
                                                text:
                                                    "${sipbook![index].sipName}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 1),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "LTP ",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                                TextWidget.paraText(
                                                    text:
                                                        "${sipbook![index].scrips![0].ltp}",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget.subText(
                                                text: sipformatDateTime(
                                                    value:
                                                        "${sipbook![index].regDate}"),
                                                theme: false,
                                                color: const Color(0xff666666),
                                                fw: 1),
                                            TextWidget.paraText(
                                                text:
                                                    " (${sipbook![index].scrips![0].perChange ?? 0.00}%)",
                                                theme: false,
                                                color: sipbook![index]
                                                            .scrips![0]
                                                            .perChange ==
                                                        null
                                                    ? colors.ltpgrey
                                                    : sipbook![index]
                                                            .scrips![0]
                                                            .perChange!
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : sipbook![index]
                                                                    .scrips![0]
                                                                    .perChange ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen,
                                                fw: 0),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : const Color(0xffECEDEE)),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Start Date: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text: duedateformate(
                                                        value:
                                                            "${sipbook![index].startDate}"),
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    fw: 0),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Due Date: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text: duedateformate(
                                                        value:
                                                            "${sipbook![index].internal?.dueDate}"),
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    fw: 0),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Pending Period: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text:
                                                        "${sipbook![index].endPeriod}",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    fw: 0),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Execution Date: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text: duedateformate(
                                                        value:
                                                            "${sipbook![index].internal?.execDate}"),
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    fw: 0),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    )));
                          },
                          itemCount: sipbook!.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : const Color(0xffF1F3F8),
                                height: 7);
                          },
                        ),
                      if (order.siporderBookSearch!.isNotEmpty)
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () async {
                                  ref
                                      .read(orderProvider)
                                      .fetchSipOrderHistory(context);
                                  Navigator.pushNamed(
                                      context, Routes.sipDetails,
                                      arguments:
                                          order.siporderBookSearch![index]);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget.titleText(
                                                text:
                                                    "${order.siporderBookSearch![index].sipName}",
                                                theme: theme.isDarkMode,
                                                fw: 1),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "LTP: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text:
                                                        "${order.siporderBookSearch![index].scrips![0].ltp}",
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget.paraText(
                                                text: sipformatDateTime(
                                                    value:
                                                        "${order.siporderBookSearch![index].regDate}"),
                                                theme: false,
                                                color: const Color(0xff666666),
                                                fw: 1),
                                            TextWidget.paraText(
                                                text:
                                                    " (${order.siporderBookSearch![index].scrips![0].perChange ?? 0.00}%)",
                                                theme: false,
                                                color: order
                                                            .siporderBookSearch![
                                                                index]
                                                            .scrips![0]
                                                            .perChange ==
                                                        null
                                                    ? colors.ltpgrey
                                                    : order
                                                            .siporderBookSearch![
                                                                index]
                                                            .scrips![0]
                                                            .perChange!
                                                            .startsWith("-")
                                                        ? colors.darkred
                                                        : order
                                                                    .siporderBookSearch![
                                                                        index]
                                                                    .scrips![0]
                                                                    .perChange ==
                                                                "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen,
                                                fw: 0),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : const Color(0xffECEDEE)),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Start Date: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text: duedateformate(
                                                        value:
                                                            "${order.siporderBookSearch![index].startDate}"),
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Due Date: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text: duedateformate(
                                                        value:
                                                            "${order.siporderBookSearch![index].internal?.dueDate}"),
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Pending Period: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text:
                                                        "${order.siporderBookSearch![index].endPeriod}",
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text: "Execution Date: ",
                                                    theme: false,
                                                    color:
                                                        const Color(0xff5E6B7D),
                                                    fw: 1),
                                                TextWidget.subText(
                                                    text: duedateformate(
                                                        value:
                                                            "${order.siporderBookSearch![index].internal?.execDate}"),
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    )));
                          },
                          itemCount: order.siporderBookSearch!.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : const Color(0xffF1F3F8),
                                height: 7);
                          },
                        )
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

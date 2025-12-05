import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/global_state_text.dart';
// import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/redemption_bottomsheet_mf.dart';
import 'package:mynt_plus/screens/Mobile/portfolio_screens/mfHoldings/filter_scrip_bottom_sheet.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/custom_text_form_field.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
// import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
// import 'package:mynt_plus/sharedWidget/snack_bar.dart';

class MFHoldingScreen extends StatefulWidget {
  const MFHoldingScreen({super.key});
  @override
  State<MFHoldingScreen> createState() => _MFHoldingScreen();
}

class _MFHoldingScreen extends State<MFHoldingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final mfHolding = ref.watch(portfolioProvider);
      final theme = ref.watch(themeProvider);
      // final mforderbook = ref.watch(mfProvider);

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? const Color(0xffB5C0CF).withOpacity(.15)
                    : const Color(0xffF1F3F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                        text: "Invested",
                        theme: theme.isDarkMode,
                        color: const Color(0xff5E6B7D),
                        fw: 0,
                      ),
                      const SizedBox(height: 8),
                      TextWidget.subText(
                        text:
                        "₹${getFormatter(value: mfHolding.mfTotInveest, v4d: false, noDecimal: false)}",
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                        fw: 0,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextWidget.subText(
                        text: "Total P&L",
                        theme: theme.isDarkMode,
                        color: const Color(0xff5E6B7D),
                        fw: 0,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWidget.titleText(
                            text:
                            "₹${getFormatter(value: mfHolding.mfTotalPnl, v4d: false, noDecimal: false)} ",
                            theme: theme.isDarkMode,
                            color:
                              mfHolding.mfTotalPnl.toString().startsWith("-")
                                  ? colors.darkred
                                  : colors.ltpgreen,
                            fw: 0,
                          ),
                          TextWidget.subText(
                            text:
                            "(${mfHolding.mfTotalPnlPerchng.isNaN ? 0.00 : mfHolding.mfTotalPnlPerchng.toStringAsFixed(2)}%)",
                            theme: theme.isDarkMode,
                            color: mfHolding.mfTotalPnlPerchng
                                      .toString()
                                      .startsWith("-")
                                  ? colors.darkred
                                  : colors.ltpgreen,
                            fw: 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
         
         
         
         
         
         
         
         
            if (mfHolding.mfHoldingsModel!.length > 1)
              Container(
                decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? const Color(0xffB5C0CF).withOpacity(.15)
                          : const Color(0xffF1F3F8),
                      width: 6,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 2, top: 0, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                context: context,
                                builder: (context) {
                                  return const MFHoldingsScripFilterBottomSheet();
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SvgPicture.asset(
                                assets.filterLines,
                                color: theme.isDarkMode
                                    ? const Color(0xffBDBDBD)
                                    : colors.colorGrey,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              mfHolding.showHoldMFSearch(true);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 12, left: 10),
                              child: SvgPicture.asset(
                                assets.searchIcon,
                                width: 19,
                                color: theme.isDarkMode
                                    ? const Color(0xffBDBDBD)
                                    : colors.colorGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (mfHolding.showSearchHoldMF)
              Container(
                height: 62,
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      width: 6,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: mfHolding.holdingMFSearchCtrl,
                        style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          1,
                        ),
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: InputDecoration(
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          filled: true,
                         hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                    fw: 0,
                                    ),
                          prefixIconColor: const Color(0xff586279),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SvgPicture.asset(
                              assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                              width: 20,
                            ),
                          ),
                          suffixIcon: InkWell(
                            onTap: () async {
                              mfHolding.clearHoldSearch();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SvgPicture.asset(
                                assets.removeIcon,
                                fit: BoxFit.scaleDown,
                                width: 20,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Search Scrip Name",
                          contentPadding: const EdgeInsets.only(top: 20),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (value) async {
                          mfHolding.mfHoldingSearch(value, context);
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        mfHolding.showHoldMFSearch(false);
                      },
                      child: TextWidget.subText(
                        text: "Close",
                        theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                        fw: 0,
                      ),
                    ),
                  ],
                ),
              ),
            mfHolding.mfHoldingSearchItem!.isEmpty
                ? Expanded(
                    child: mfHolding.mfHoldingsModel!.isNotEmpty &&
                            mfHolding.mfHoldingsModel![0].stat != "Not_Ok"
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await mfHolding.fetchMFHoldings(context);
                            },
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  // onTap: () async {
                                  //   mforderbook.loaderfun();
                                  //   await mforderbook.fetchmfholdsinglelist(
                                  //     "${mfHolding.mfHoldingsModel![index].exchTsym![0].isin}",
                                  //   );

                                  //   if (mforderbook.mfholdsingepage?.stat ==
                                  //       "Ok") {
                                  //     Navigator.pushNamed(
                                  //       context,
                                  //       Routes.mfholdsinlepage,
                                  //     );
                                  //   } else {
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(
                                  //       successMessage(
                                  //           context, "No Single Page Data Found"),
                                  //     );
                                  //   }
                                  // },
                                  //  onTap: () async {
                                  //  _showBottomSheet(
                                  //       context,
                                  //       RedemptionBottomScreen(mfHoldingData:mfHolding.mfHoldingsModel![index]),
                                  //     );
                                  //  },
                                 child: Container(
  padding: const EdgeInsets.all(0), // Set even padding
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // 70% of the screen width
              child: Text(
                 "${mfHolding.mfHoldingsModel![index].exchTsym![0].cname!
      .split(' ')
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
      .join(' ')}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                ),
                style: TextWidget.textStyle(fontSize: 14, theme: theme.isDarkMode,height: 1.2),
                 
              ),
            ),
            const Spacer(), // Pushes the right-aligned text to the edge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                                                  TextWidget.subText(
                                                    text:
                  "₹${mfHolding.mfHoldingsModel![index].exchTsym![0].pnl == "null" ? 0.00 : mfHolding.mfHoldingsModel![index].exchTsym![0].pnl}",
                                                    theme: theme.isDarkMode,
                                                    color: mfHolding
                                                            .mfHoldingsModel![
                                                                index]
                                                            .exchTsym![0]
                                                            .pnl!
                                                            .startsWith("-")
                        ? colors.darkred
                        : colors.ltpgreen,
                                                    fw: 0,
                ),
                                                  TextWidget.paraText(
                                                      text:
                  " (${mfHolding.mfHoldingsModel![index].exchTsym![0].pnlPerChng == "NaN" ? 0.0 : mfHolding.mfHoldingsModel![index].exchTsym![0].pnlPerChng == "null" ? 0.00 : mfHolding.mfHoldingsModel![index].exchTsym![0].pnlPerChng}%)",
                                                      theme: theme.isDarkMode,
                                                      color: mfHolding
                                                              .mfHoldingsModel![
                                                                  index]
                                                              .exchTsym![0]
                                                              .pnlPerChng!
                                                              .startsWith("-")
                        ? colors.darkred
                                                          : mfHolding
                                                                      .mfHoldingsModel![
                                                                          index]
                                                                      .exchTsym![
                                                                          0]
                                                                      .pnlPerChng ==
                                                                  "NaN"
                            ? colors.ltpgrey
                            : colors.ltpgreen,
                                                      fw: 0),
              ],
            ),
          ],
        ),
      ),
      // const SizedBox(height: 8), 
      Divider(
        color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        thickness: 1.0,
      ),
    ],
  ),
),

                                );
                              },
                              itemCount: mfHolding.mfHoldingsModel!.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  height: 0,
                                );
                              },
                            ),
                          )
                        : const Center(child: NoDataFound(
                          secondaryEnabled: false,
                        )),
                  )
                : Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Tooltip(
                                      textStyle: TextWidget.textStyle(
                                        color: colors.colorWhite,
                                        fontSize: 12,
                                        fw: 0,
                                        theme: theme.isDarkMode,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 5,
                                      ),
                                      message:
                                          "${mfHolding.mfHoldingSearchItem![index].exchTsym![0].cname}",
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: TextWidget.subText(
                                          text:
                                        "${mfHolding.mfHoldingSearchItem![index].exchTsym![0].cname} ",
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                          textOverflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  const SizedBox(width: 120),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomExchBadge(
                                    exch:
                                        "${mfHolding.mfHoldingSearchItem![index].exchTsym![0].exch}",
                                  ),
                                  Row(
                                    children: [
                                      TextWidget.paraText(
                                          text: "NAV: ",
                                          theme: theme.isDarkMode,
                                          color: const Color(0xff5E6B7D),
                                          fw: 1),
                                      TextWidget.subText(
                                          text:
                                        "₹${mfHolding.mfHoldingSearchItem![index].exchTsym![0].nav}",
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.subText(
                                          text: "Qty: ",
                                          theme: theme.isDarkMode,
                                          color: const Color(0xff5E6B7D),
                                          fw: 0),
                                      TextWidget.subText(
                                          text:
                                        "${mfHolding.mfHoldingSearchItem![index].holdqty ?? 0} @ ₹${mfHolding.mfHoldingSearchItem![index].uploadPrc}",
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextWidget.subText(
                                          text:
                                        "₹${mfHolding.mfHoldingSearchItem![index].exchTsym![0].pnl}",
                                          theme: false,
                                          color: mfHolding
                                                  .mfHoldingSearchItem![index]
                                                  .exchTsym![0]
                                                  .pnl!
                                                  .startsWith("-")
                                              ? colors.darkred
                                              : colors.ltpgreen,
                                          fw: 0),
                                      TextWidget.paraText(
                                          text:
                                        " (${mfHolding.mfHoldingSearchItem![index].exchTsym![0].pnlPerChng == "NaN" ? 0.0 : mfHolding.mfHoldingSearchItem![index].exchTsym![0].pnlPerChng}%)",
                                          theme: theme.isDarkMode,
                                          color: mfHolding
                                                  .mfHoldingSearchItem![index]
                                                  .exchTsym![0]
                                                  .pnlPerChng!
                                                  .startsWith("-")
                                              ? colors.darkred
                                              : mfHolding
                                                          .mfHoldingSearchItem![
                                                              index]
                                                          .exchTsym![0]
                                                          .pnlPerChng ==
                                                      "NaN"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen,
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
                                      TextWidget.subText(
                                          text: "Inv: ",
                                          theme: theme.isDarkMode,
                                          color: const Color(0xff5E6B7D),
                                          fw: 0),
                                      TextWidget.subText(
                                          text:
                                        "₹${getFormatter(value: double.parse("${mfHolding.mfHoldingSearchItem![index].invested ?? 0.00}"), v4d: false, noDecimal: false)}",
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextWidget.subText(
                                          text: "Cur: ",
                                          theme: theme.isDarkMode,
                                          color: const Color(0xff5E6B7D),
                                          fw: 0),
                                      TextWidget.subText(
                                          text:
                                        "₹${getFormatter(value: double.parse("${mfHolding.mfHoldingSearchItem![index].currentVal ?? 0.00}"), v4d: false, noDecimal: false)}",
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: mfHolding.mfHoldingSearchItem!.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          height: 6,
                        );
                      },
                    ),
                  ),
          ],
        ),
      );
    });
  }
    void _showBottomSheet(BuildContext context, Widget BottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BottomSheet));
  }
}

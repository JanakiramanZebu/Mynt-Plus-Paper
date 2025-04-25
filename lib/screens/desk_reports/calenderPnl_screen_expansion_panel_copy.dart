import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../models/desk_reports_model/calender_pnl_model.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_switch_btn.dart';

class CalenderpnlScreen extends StatefulWidget {
  const CalenderpnlScreen({super.key});

  @override
  State<CalenderpnlScreen> createState() => _CalenderpnlScreenState();
}

class _CalenderpnlScreenState extends State<CalenderpnlScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double netvalue = 0.0;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final ledgerprovider = watch(ledgerProvider);
      final sortedDates = ledgerprovider.grouped.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      if (ledgerprovider.calenderpnlAllData != null) {
        netvalue = (ledgerprovider.calenderpnlAllData?.realized ?? 0.0) -
            (ledgerprovider.calenderpnlAllData!.totalCharges ?? 0.0);
      }
      return Scaffold(
        appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: InkWell(
              onTap: () {
                ledgerprovider.falseloader('calpnl');
                ledgerprovider.setSegment("Equity");
                ledgerprovider.setFinancialYear("");
                Navigator.pop(context);
              },
              child: const CustomBackBtn()),
          elevation: 0.2,
          title: TextWidget.heroText(
              text: "Calender P&L",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),
        ),
        body: TransparentLoaderScreen(
          isLoading: ledgerprovider.calendarpnlloading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: screenWidth,
                    child: Container(
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Realised P&L",
                                      style: textStyle(const Color(0xFF696969),
                                          14, FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "${ledgerprovider.calenderpnlAllData != null ? ledgerprovider.calenderpnlAllData!.realized.toStringAsFixed(2) : 0.0} ",
                                        style: ledgerprovider
                                                    .calenderpnlAllData !=
                                                null
                                            ? ledgerprovider.calenderpnlAllData!
                                                        .realized !=
                                                    0
                                                ? ledgerprovider
                                                            .calenderpnlAllData!
                                                            .realized <
                                                        0
                                                    ? textStyle(Colors.red, 16,
                                                        FontWeight.w600)
                                                    : textStyle(Colors.green,
                                                        16, FontWeight.w600)
                                                : textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    16,
                                                    FontWeight.w600)
                                            : textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                16,
                                                FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Unrealised P&L",
                                      textAlign: TextAlign.right,
                                      style: textStyle(const Color(0xFF696969),
                                          14, FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        ledgerprovider.calenderpnlAllData !=
                                                null
                                            ? ledgerprovider
                                                .calenderpnlAllData!.unrealized
                                                .toStringAsFixed(2)
                                            : '0.0',
                                        style: ledgerprovider
                                                    .calenderpnlAllData !=
                                                null
                                            ? ledgerprovider.calenderpnlAllData!
                                                        .unrealized !=
                                                    0
                                                ? ledgerprovider
                                                            .calenderpnlAllData!
                                                            .unrealized <
                                                        0
                                                    ? textStyle(Colors.red, 16,
                                                        FontWeight.w600)
                                                    : textStyle(Colors.green,
                                                        16, FontWeight.w600)
                                                : textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    16,
                                                    FontWeight.w600)
                                            : textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                16,
                                                FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 18.0,
                                right: 18.0,
                                top: 4.0,
                                bottom: 18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Charges and Taxes",
                                      style: textStyle(const Color(0xFF696969),
                                          14, FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        ledgerprovider.calenderpnlAllData !=
                                                null
                                            ? ledgerprovider.calenderpnlAllData!
                                                        .totalCharges !=
                                                    null
                                                ? ledgerprovider
                                                    .calenderpnlAllData!
                                                    .totalCharges!
                                                    .toStringAsFixed(2)
                                                : '0.0'
                                            : '0.0',
                                        textAlign: TextAlign.right,
                                        style: textStyle(
                                            Colors.red, 16, FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Net Realised P&L",
                                      textAlign: TextAlign.right,
                                      style: textStyle(const Color(0xFF696969),
                                          14, FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        netvalue.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                        style: netvalue != 0
                                            ? netvalue > 0
                                                ? textStyle(Colors.green, 16,
                                                    FontWeight.w600)
                                                : textStyle(Colors.red, 16,
                                                    FontWeight.w600)
                                            : textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                16,
                                                FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      // width: screenWidth * 0.45,
                      height: 35.0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xff3A3A3A)
                            : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ledgerprovider.selectedFinancialYear,
                          dropdownColor: theme.isDarkMode
                              ? const Color(0xff3A3A3A)
                              : const Color(0xffF1F3F8),
                          items:
                              ledgerprovider.availableFinancialYears.map((fy) {
                            return DropdownMenuItem<String>(
                              value: fy,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  fy,
                                  style: textStyle(
                                    theme.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    12,
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newFY) {
                            if (newFY != null) {
                              ledgerprovider.setFinancialYear(newFY);
                              // Call API after updating financial year
                              ledgerprovider.fetchcalenderpnldata(context,
                                ledgerprovider.formattedStartDate,
                                ledgerprovider.formattedendDate,
                                ledgerprovider.selectedSegment,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 35.0,
                      // width: screenWidth * 0.45,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xff3A3A3A)
                            : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ledgerprovider.selectedSegment,
                          dropdownColor: theme.isDarkMode
                              ? const Color(0xff3A3A3A)
                              : const Color(0xffF1F3F8),
                          items: ledgerprovider.availableSegments.map((seg) {
                            return DropdownMenuItem<String>(
                              value: seg,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  seg,
                                  style: textStyle(
                                    theme.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    12,
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (seg) {
                            if (seg != null) {
                              ledgerprovider.setSegment(seg);
                              ledgerprovider.fetchcalenderpnldata(context,
                                ledgerprovider.formattedStartDate,
                                ledgerprovider.formattedendDate,
                                ledgerprovider.selectedSegment,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 16.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("M",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w500)),
                          const SizedBox(width: 6),
                          CustomSwitch(
                              onChanged: (bool value) {
                                // print('object ${value}');
                                ledgerprovider.chngPnlmonthordaily(
                                    !ledgerprovider.isMonthly);
                              },
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                              value: ledgerprovider.isMonthly),
                          const SizedBox(width: 6),
                          Text("D",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextWidget.overlineText(
                    text: "! M and D means Monthly and Daily",
                    color: Color(0xFF696969),
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 0),
              ),
              ledgerprovider.calenderpnlAllData == null
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : Expanded(
                      child: SingleChildScrollView(
                        physics: const ScrollPhysics(),
                        child: Column(
                          
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CalendarTabs(
                                theme: theme,
                                heatmapData: ledgerprovider.heatmapData,
                              ),
                            ),
                            Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                                  color: theme.isDarkMode
                                                      ? const Color(0xffB5C0CF)
                                                          .withOpacity(.15)
                                                      : const Color(0xffF1F3F8),
                                                  thickness: 1.0,
                                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 16.0 ,top: 8.0,bottom : 8.0),
                                    child: TextWidget.titleText(
                                        text: "Date-specific Information",
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0)),
                              Divider(
                                                  color: theme.isDarkMode
                                                      ? const Color(0xffB5C0CF)
                                                          .withOpacity(.15)
                                                      : const Color(0xffF1F3F8),
                                                  thickness: 1.0,
                                                ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sortedDates.length,
                              itemBuilder: (context, index) {
                                final dateKey = sortedDates[index];
                                final tradesForDate =
                                    ledgerprovider.grouped[dateKey]!; 
                                // Calculate total realized PnL for this date
                                final totalRealisedPnl =
                                    tradesForDate.fold<double>(
                                        0.0,
                                        (sum, item) =>
                                            sum +
                                            double.parse(item.realisedpnl!));

                                // Format the date (e.g. "03 Oct 2024")
                                final dateString =
                                    '${dateKey.day.toString().padLeft(2, '0')} '
                                    '${_monthName(dateKey.month)} '
                                    '${dateKey.year}';

                                return Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    collapsedBackgroundColor:
                                        Colors.transparent,
                                    childrenPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    title: Text(
                                        "$dateString  (${tradesForDate.length})",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            14,
                                            FontWeight.w500)),
                                    trailing: Text(
                                        '₹ ${totalRealisedPnl.toStringAsFixed(2)}',
                                        style: totalRealisedPnl != 0
                                            ? totalRealisedPnl > 0
                                                ? textStyle(Colors.green, 14,
                                                    FontWeight.w500)
                                                : textStyle(Colors.red, 14,
                                                    FontWeight.w500)
                                            : textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w500)),
                                    children: [
                                      Column(
                                        children: List.generate(
                                            tradesForDate.length, (index) {
                                          final trade = tradesForDate[index];
                                          return Column(
                                            children: [
                                              _buildTradeItem(trade, theme),
                                              if (index !=
                                                  tradesForDate.length - 1)
                                                Divider(
                                                  color: theme.isDarkMode
                                                      ? const Color(0xffB5C0CF)
                                                          .withOpacity(.15)
                                                      : const Color(0xffF1F3F8),
                                                  thickness: 7.0,
                                                ),
                                              SizedBox(
                                                height: 5,
                                              )
                                            ],
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  thickness: 7.0,
                                );
                              },
                            )
                          ],
                            ),
                          
                          ]


                          
                          ,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  // Helper method to build the UI for a single trade
  Widget _buildTradeItem(TradeData trade, ThemesProvider theme) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: screenWidth *
                    0.65, // Ensures text takes the available width
                child: InkWell(
                  onTap: () async {
                    // Handle the onTap event here
                  },
                  child: Text(
                    "${trade.sCRIPSYMBOL}",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        13,
                        FontWeight.w600),
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow
                        .ellipsis, // Adds "..." if the text is too long
                    maxLines: 2, // Limits text to 2 lines, change as needed
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Divider(
            color: Color.fromARGB(255, 212, 212, 212),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Net Qty :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.updatedNETQTY}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Buy Qty :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalBuyQty}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Sell Qty :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalSellQty}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Buy Rate :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalBuyRate}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Sell Rate :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.totalSellRate}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Buy Amount :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.bAMT}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Sell Amount :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.sAMT}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextWidget.subText(
                      text: "Realised :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.realisedpnl}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
              Row(
                children: [
                  TextWidget.subText(
                      text: "Unrealised :  ",
                      color: Color(0xFF696969),
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  TextWidget.subText(
                      text: "${trade.unrealisedpnl}",
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for key-value text
  Widget _keyValueText(String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
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
            child: bottomSheet));
  }

  // Convert month integer to month name
  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class CalendarTabs extends StatefulWidget {
  final dynamic theme; // Passed from your UI (e.g., watch(themeProvider))
  final Map<DateTime, double> heatmapData; // Data from ledgerprovider

  const CalendarTabs({
    super.key,
    required this.theme,
    required this.heatmapData,
  });

  @override
  State<CalendarTabs> createState() => _CalendarTabsState();
}

class _CalendarTabsState extends State<CalendarTabs> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer(
      builder: (context, ScopedReader watch, _) {
        final ledgerprovider = watch(ledgerProvider);
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
          color:
              widget.theme.isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
          child: Container(
            width: screenWidth * 0.9, // Adjust as needed

            child: Column(
              children: [
                // Top row: Monthly/Daily tabs + Financial year dropdown
                // Row(
                //   // crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     // Monthly tab
                //     GestureDetector(
                //       onTap: () => ledgerprovider.setTab(true),
                //       child: Column(
                //         children: [
                //           Text(
                //             "Monthly",
                //             style: textStyle(
                //               widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //               14,
                //               FontWeight.w600,
                //             ),
                //           ),
                //           if (ledgerprovider.isMonthly)
                //             Container(
                //               margin: const EdgeInsets.only(top: 2),
                //               height: 2,
                //               width: 60,
                //               color: widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //             ),
                //         ],
                //       ),
                //     ),
                //     // Daily tab
                //     GestureDetector(
                //       onTap: () => ledgerprovider.setTab(false),
                //       child: Column(
                //         children: [
                //           Text(
                //             "Daily",
                //             style: textStyle(
                //               widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //               14,
                //               FontWeight.w600,
                //             ),
                //           ),
                //           if (!ledgerprovider.isMonthly)
                //             Container(
                //               margin: const EdgeInsets.only(top: 2),
                //               height: 2,
                //               width: 60,
                //               color: widget.theme.isDarkMode
                //                   ? Colors.white
                //                   : Colors.black,
                //             ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 8),
                // Content: Either Monthly grid or Daily calendar
                if (ledgerprovider.isMonthly)
                  _MonthlyGrid(
                    theme: widget.theme,
                    monthlyPnL: ledgerprovider.monthlyPnL,
                    onMonthSelected: (DateTime selectedMonth) {
                      ledgerprovider.setSelectedMonth(selectedMonth);
                      ledgerprovider.setTab(false);
                    },
                    startFY: ledgerprovider.startTaxDate,
                    endFY: ledgerprovider.endTaxDate,
                  )
                else
                  _DailyCalendar(
                    key: ValueKey(
                        ledgerprovider.selectedMonth.toIso8601String()),
                    theme: widget.theme,
                    heatmapData: widget.heatmapData,
                    startDate: ledgerprovider.startTaxDate,
                    endDate: ledgerprovider.endTaxDate,
                    currentMonth: ledgerprovider.selectedMonth,
                    onMonthChanged: (DateTime newMonth) {
                      ledgerprovider.setSelectedMonth(newMonth);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// UI-only MonthlyGrid widget that always shows 12 months (Apr–Mar) in a 4×3 grid.
class _MonthlyGrid extends StatelessWidget {
  final dynamic theme;
  final Map<String, double> monthlyPnL;
  final ValueChanged<DateTime> onMonthSelected;
  final DateTime startFY;
  final DateTime endFY;

  const _MonthlyGrid({
    required this.theme,
    required this.monthlyPnL,
    required this.onMonthSelected,
    required this.startFY,
    required this.endFY,
  });

  @override
  Widget build(BuildContext context) {
    // Generate 12 months from startFY to endFY (guaranteed)
    final months = <DateTime>[];
    DateTime current = DateTime(startFY.year, startFY.month, 1);
    while (!current.isAfter(endFY)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    // Chunk into 4 columns (4 items per row)
    final rows = <List<DateTime>>[];
    for (int i = 0; i < months.length; i += 4) {
      final endIndex = (i + 4 > months.length) ? months.length : (i + 4);
      rows.add(months.sublist(i, endIndex));
    }
    return Column(
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final monthDate in row) _buildMonthBox(context, monthDate),
            ],
          ),
      ],
    );
  }

  Widget _buildMonthBox(BuildContext context, DateTime monthDate) {
    double screenWidth = MediaQuery.of(context).size.width;
    final key =
        "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}";
    final double? monthValue = monthlyPnL[key];
    final numval = (monthValue == null || monthValue == 0)
        ? "-"
        : monthValue.toStringAsFixed(2);
    var displayText = numval != "-"
        ? NumberFormat.compactCurrency(
            decimalDigits: 2,
            locale: 'en_IN',
            symbol: '',
          ).format(double.parse(numval))
        : '-';
    if (displayText.contains("T")) {
      displayText = displayText.replaceAll("T", "K");
    }
    final monthAbbrs = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    final monthName = monthAbbrs[monthDate.month - 1];
    Color bgColor;
    if (monthValue == null) {
      bgColor =
          theme.isDarkMode ? const Color(0xff3A3A3A) : const Color(0xffF1F3F8);
    } else {
      bgColor = (monthValue < 0)
          ? Colors.red.withOpacity(0.2)
          : Colors.green.withOpacity(0.2);
    }
    return Container(
      margin: const EdgeInsets.all(6),
      width: screenWidth * 0.18,
      height: screenWidth * 0.18,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            monthName,
            style: textStyle(theme.isDarkMode ? Colors.white : Colors.black, 14,
                FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            displayText,
            style: textStyle(
                theme.isDarkMode ? Colors.white70 : Colors.grey[800]!,
                12,
                FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// UI-only DailyCalendar widget.
class _DailyCalendar extends StatefulWidget {
  final dynamic theme;
  final Map<DateTime, double> heatmapData;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const _DailyCalendar({
    required this.theme,
    required this.heatmapData,
    required this.startDate,
    required this.endDate,
    required this.currentMonth,
    required this.onMonthChanged,
    required ValueKey<String> key,
  });

  @override
  State<_DailyCalendar> createState() => _DailyCalendarState();
}

class _DailyCalendarState extends State<_DailyCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = widget.currentMonth;
  }

  @override
  void didUpdateWidget(covariant _DailyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      setState(() {
        _month = widget.currentMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysToDisplay = _buildMonthDays(_month);
    final weeks = _chunkDays(daysToDisplay, 7);
    return Column(
      children: [
        // Month title with left/right arrows
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                _formatMonthYear(_month),
                style: textStyle(
                    widget.theme.isDarkMode ? Colors.white : Colors.black,
                    16,
                    FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
        ),
        // Day headers (Mon–Sun)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Mon",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Tue",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Wed",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Thu",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Fri",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Sat",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
              Text("Sun",
                  style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      12,
                      FontWeight.w700)),
            ],
          ),
        ),
        // Calendar grid: rows of 7 days
        for (final week in weeks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final day in week) _buildDayBox(context, day),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDayBox(BuildContext context, DateTime date) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (date.isBefore(widget.startDate) ||
        date.isAfter(widget.endDate) ||
        date.year < 1900) {
      return Container(
        width: screenWidth * 0.09,
        height: screenWidth * 0.09,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: widget.theme.isDarkMode
              ? const Color(0xff3A3A3A)
              : const Color(0xffF1F3F8),
          borderRadius: BorderRadius.circular(8.0),
        ),
      );
    }
    final double? value =
        widget.heatmapData[DateTime(date.year, date.month, date.day)];

    Color bgColor;
    if (value == null) {
      bgColor = widget.theme.isDarkMode
          ? const Color(0xff3A3A3A)
          : const Color(0xffF1F3F8);
    } else {
      bgColor = (value < 0)
          ? Colors.red.withOpacity(0.2)
          : Colors.green.withOpacity(0.2);
    }
    final displayTextVal = value == null ? "-" : value.toStringAsFixed(2);
    var displayText = displayTextVal != "-"
        ? NumberFormat.compactCurrency(
                decimalDigits: 2, locale: 'en_IN', symbol: '')
            .format(double.parse(displayTextVal))
        : '-';
    if (displayText.contains("T")) {
      displayText = displayText.replaceAll("T", "K");
    }
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Selected Date: ${date.toLocal().toIso8601String().split('T').first} => $value",
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 50,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString().padLeft(2, '0'),
              style: textStyle(
                  widget.theme.isDarkMode ? Colors.white : Colors.black,
                  12,
                  FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              displayText,
              style: textStyle(
                  widget.theme.isDarkMode ? Colors.white70 : Colors.grey[800]!,
                  10,
                  FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousMonth() {
    if (_month.year == widget.startDate.year &&
        _month.month == widget.startDate.month) return;
    final prevMonth = DateTime(_month.year, _month.month - 1, 1);
    setState(() {
      _month =
          prevMonth.isBefore(widget.startDate) ? widget.startDate : prevMonth;
    });
    widget.onMonthChanged(_month);
  }

  void _goToNextMonth() {
    if (_month.year == widget.endDate.year &&
        _month.month == widget.endDate.month) return;
    final nextMonth = DateTime(_month.year, _month.month + 1, 1);
    setState(() {
      _month = nextMonth.isAfter(widget.endDate) ? widget.endDate : nextMonth;
    });
    widget.onMonthChanged(_month);
  }

  String _formatMonthYear(DateTime date) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return "${monthNames[date.month - 1]} ${date.year}";
  }

  List<DateTime> _buildMonthDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final leading = firstDayOfMonth.weekday - 1;
    final trailing = 7 - lastDayOfMonth.weekday;
    final days = <DateTime>[];
    for (int i = 0; i < leading; i++) {
      days.add(DateTime(1900, 1, 1));
    }
    for (int d = 1; d <= lastDayOfMonth.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    for (int i = 0; i < trailing; i++) {
      days.add(DateTime(1900, 1, 1));
    }
    return days;
  }

  List<List<DateTime>> _chunkDays(List<DateTime> days, int chunkSize) {
    final chunks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += chunkSize) {
      chunks.add(days.sublist(
          i, (i + chunkSize > days.length) ? days.length : i + chunkSize));
    }
    return chunks;
  }
}

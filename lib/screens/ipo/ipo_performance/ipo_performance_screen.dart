// ignore_for_file: deprecated_member_use

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_btn.dart';
import '../../../sharedWidget/no_data_found.dart';

class IPOPerformance extends StatefulWidget {
  const IPOPerformance({super.key});

  @override
  State<IPOPerformance> createState() => _IPOPerformanceState();
}

class _IPOPerformanceState extends State<IPOPerformance> {
  List<int> years = [];
  int? selectedYear;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    var currentYear = DateTime.now().year;
    for (var year = 2000; year <= currentYear; year++) {
      years.add(year);
    }
    selectedYear = years.last;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer(builder: (context, ScopedReader watch, _) {
        final perfomance = watch(ipoProvide);
        final theme = watch(themeProvider);
        final internet = watch(networkStateProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : const Color(0xffECEDEE)),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("IPO Performance $selectedYear",
                                style: textStyle(const Color(0xff000000), 18,
                                    FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                                "Monitor the IPO Performance of Mainline IPO Stocks listed at BSE and NSE",
                                style: textStyle(const Color(0xff666666), 14,
                                    FontWeight.w500)),
                            const SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: perfomance.performancesearchcontroller,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                15,
                                FontWeight.w500),
                            decoration: InputDecoration(
                                fillColor: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                filled: true,
                                hintStyle: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500),
                                prefixIconColor: const Color(0xff586279),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: SvgPicture.asset(assets.searchIcon,
                                      color: const Color(0xff586279),
                                      fit: BoxFit.contain,
                                      width: 15),
                                ),
                                suffixIcon: InkWell(
                                  onTap: () async {
                                    perfomance.clearPerformanceSearch();
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
                                    borderRadius: BorderRadius.circular(30)),
                                disabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30)),
                                hintText: "Search company",
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30))),
                            onChanged: (value) {
                              perfomance.searchperformance(value, context);
                              if (value.isEmpty) {
                                perfomance.clearPerformanceSearch();
                              }
                              if (internet.connectionStatus !=
                                  ConnectivityResult.none) {
                                perfomance.searchperformance(value, context);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                          dropdownStyleData: DropdownStyleData(
                              maxHeight: 240,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: !theme.isDarkMode
                                      ? colors.colorWhite
                                      : const Color.fromARGB(255, 16, 16, 16))),
                          buttonStyleData: ButtonStyleData(
                              height: 40,
                              width: 124,
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.1)
                                      : const Color(0xffF1F3F8),
                                  // border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(32)))),
                          isExpanded: true,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500),
                          items: years.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(value.toString()),
                              ),
                            );
                          }).toList(),
                          value: selectedYear,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedYear = newValue!;
                              perfomance
                                  .getipoperfomance(selectedYear!.toInt());
                              FocusScope.of(context).unfocus();
                            });
                          },
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            perfomance.ipoPerformanceModel!.emsg == "no data"
                ? const Center(child: NoDataFound())
                : perfomance.performancesearch!.isEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                  title: Text(
                                      "${perfomance.ipoPerformanceModel!.data![index].companyName}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          15,
                                          FontWeight.w600)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                          "Listing on : ${perfomance.ipoPerformanceModel!.data![index].listedDate}",
                                          style: textStyle(Color(0xff666666),
                                              13, FontWeight.w500)),
                                    ],
                                  )),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : const Color(0xffECEDEE)),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16.0, 12, 16, 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Issue Price",
                                            style: GoogleFonts.inter(
                                                textStyle: textStyle(
                                                    const Color(0xff666666),
                                                    13,
                                                    FontWeight.w500))),
                                        const SizedBox(height: 4),
                                        Text(
                                            "₹${perfomance.ipoPerformanceModel!.data![index].priceRange}",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Close Price",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "₹ ${perfomance.ipoPerformanceModel!.data![index].clsPric}",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Gain/Loss",
                                            style: GoogleFonts.inter(
                                                textStyle: textStyle(
                                                    const Color(0xff666666),
                                                    13,
                                                    FontWeight.w500))),
                                        const SizedBox(height: 4),
                                        Text(
                                            "₹${perfomance.ipoPerformanceModel!.data![index].listingGain}",
                                            style: textStyle(
                                                perfomance
                                                        .ipoPerformanceModel!
                                                        .data![index]
                                                        .listingGain!
                                                        .toStringAsFixed(2)
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Lisiting Gain",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "${perfomance.ipoPerformanceModel!.data![index].listingGainPer}%",
                                            style: textStyle(
                                                perfomance
                                                        .ipoPerformanceModel!
                                                        .data![index]
                                                        .listingGainPer!
                                                        .toStringAsFixed(2)
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Container(
                            height: 10,
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : const Color(0xffF1F3F8),
                          );
                        },
                        itemCount: showAll
                            ? perfomance.ipoPerformanceModel!.data!.length
                            : 5)
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                  title: Text(
                                      "${perfomance.performancesearch![index].companyName}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          15,
                                          FontWeight.w600)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                          "Listing on : ${perfomance.performancesearch![index].listedDate}",
                                          style: textStyle(Color(0xff666666),
                                              13, FontWeight.w500)),
                                    ],
                                  )),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : const Color(0xffECEDEE)),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16.0, 12, 16, 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Issue Price",
                                            style: GoogleFonts.inter(
                                                textStyle: textStyle(
                                                    const Color(0xff666666),
                                                    13,
                                                    FontWeight.w500))),
                                        const SizedBox(height: 4),
                                        Text(
                                            "₹${perfomance.performancesearch![index].priceRange}",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Close Price",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "₹ ${perfomance.performancesearch![index].clsPric}",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Gain/Loss",
                                            style: GoogleFonts.inter(
                                                textStyle: textStyle(
                                                    const Color(0xff666666),
                                                    13,
                                                    FontWeight.w500))),
                                        const SizedBox(height: 4),
                                        Text(
                                            "₹${perfomance.performancesearch![index].listingGain}",
                                            style: textStyle(
                                                perfomance
                                                        .performancesearch![
                                                            index]
                                                        .listingGain!
                                                        .toStringAsFixed(2)
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Lisiting Gain",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "${perfomance.performancesearch![index].listingGainPer}%",
                                            style: textStyle(
                                                perfomance
                                                        .performancesearch![
                                                            index]
                                                        .listingGainPer!
                                                        .toStringAsFixed(2)
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                15,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Container(
                            height: 10,
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : const Color(0xffF1F3F8),
                          );
                        },
                        itemCount: perfomance.performancesearch!.length),
            perfomance.performancesearch!.isEmpty ||
                    perfomance.ipoPerformanceModel!.emsg == "no data"
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10),
                    child: CustomTextBtn(
                      icon: assets.downArrow,
                      label: showAll ? "See less IPOs" : "See more IPOs",
                      onPress: () {
                        setState(() {
                          showAll = !showAll;
                        });
                      },
                    ),
                  )
                : Container()
          ],
        );
      }),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

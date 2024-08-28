import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_text_btn.dart';
import '../../../sharedWidget/functions.dart';
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Color(0xffECEDEE),
            ),
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
                      SvgPicture.asset("assets/icon/ipoperformance.svg"),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("IPO Performance 2024",
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
                            decoration: InputDecoration(
                                fillColor: const Color(0xffF1F3F8),
                                filled: true,
                                labelStyle: GoogleFonts.inter(
                                    textStyle: textStyle(
                                        const Color(0xff000000),
                                        16,
                                        FontWeight.w600)),
                                hintStyle: GoogleFonts.inter(
                                    textStyle: textStyle(
                                        const Color(0xff69758F),
                                        15,
                                        FontWeight.w500)),
                                prefixIconColor: const Color(0xff586279),
                                prefixIcon: SvgPicture.asset(
                                  assets.appbarbell,
                                  color: const Color(0xff586279),
                                  fit: BoxFit.scaleDown,
                                  width: 14,
                                  height: 14,
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
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                          dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xffFFFFFF))),
                          buttonStyleData: const ButtonStyleData(
                              height: 40,
                              width: 124,
                              decoration: BoxDecoration(
                                  color: Color(0xffF1F3F8),
                                  // border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(32)))),
                          isExpanded: true,
                          style:
                              textStyle(colors.colorBlack, 13, FontWeight.w500),
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
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                              title: Text(
                                  "${perfomance.ipoPerformanceModel!.data![index].companyName}",
                                  style: GoogleFonts.inter(
                                      textStyle: textStyle(
                                          const Color(0xff000000),
                                          15,
                                          FontWeight.w600))),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                      "Listing on : ${perfomance.ipoPerformanceModel!.data![index].listedDate}",
                                      style: GoogleFonts.inter(
                                          textStyle: textStyle(
                                              const Color(0xff666666),
                                              13,
                                              FontWeight.w500))),
                                ],
                              )),
                          const Divider(
                            height: 0,
                            color: Color(0xffECEDEE),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 12, 16, 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            const Color(0xff000000),
                                            15,
                                            FontWeight.w500)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Close Price",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500))),
                                    const SizedBox(height: 4),
                                    Text(
                                        "₹ ${perfomance.ipoPerformanceModel!.data![index].clsPric}",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                const Color(0xff000000),
                                                15,
                                                FontWeight.w500))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            perfomance.ipoPerformanceModel!
                                                    .data![index].listingGain!
                                                    .toStringAsFixed(2)
                                                    .startsWith("-")
                                                ? const Color(0xffFF1717)
                                                : const Color(0xff43A833),
                                            15,
                                            FontWeight.w500)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Lisiting Gain",
                                        style: GoogleFonts.inter(
                                            textStyle: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500))),
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
                                                ? const Color(0xffFF1717)
                                                : const Color(0xff43A833),
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
                        color: const Color(0xffF1F3F8),
                      );
                    },
                    itemCount: showAll
                        ? perfomance.ipoPerformanceModel!.data!.length
                        : 5),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: CustomTextBtn(
                icon: assets.downArrow,
                label: showAll ? "See less IPOs" : "See more IPOs",
                onPress: () {
                  setState(() {
                    showAll = !showAll;
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }

 
}

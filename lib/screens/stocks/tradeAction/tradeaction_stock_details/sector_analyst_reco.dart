import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_analysict_list.dart';
import '../../../../sharedWidget/scrollable_btn.dart';
 

class EftAnalystRecommentation extends StatefulWidget {
  const EftAnalystRecommentation({super.key});

  @override
  State<EftAnalystRecommentation> createState() =>
      _EftAnalystRecommentationState();
}

class _EftAnalystRecommentationState extends State<EftAnalystRecommentation> {
  List<String> sectorList = ["Mar 2023", "Dec 2022", "Sep 2021", "Jun 2021"];
  List<bool> isActiveBtn = [true, false, false, false];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Analyst Recommendation',
            style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0xff000000),
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
              height: 32,
              child:
                  ScrollableBtn(btnActive: isActiveBtn, btnName: sectorList)),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Shareholding Breakdown',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff000000)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SvgPicture.asset('assets/icon/colorscontain.svg'),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: const BoxDecoration(
              color: Color(0xffFAFBFF),
              border: Border(bottom: BorderSide(color: Color(0xffDDDDDD)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invester',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff666666)),
              ),
              Row(
                children: [
                  Text(
                    'Holding%',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icon/vector.svg')
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EftAnalystRecoList(),
            ),
            const SizedBox(
              height: 22,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                width: screenWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffDDDDDD))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shareholding History',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff000000)),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      'Select a segment from the breakdowns to see its pattern here',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff666666)),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: screenWidth,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xffF1F3F8),
                          borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Promoter Holding",
                              style: GoogleFonts.inter(
                                  textStyle: textStyle(const Color(0xff000000),
                                      13, FontWeight.w500))),
                          const SizedBox(
                            width: 10,
                          ),
                          SvgPicture.asset(
                            "assets/icon/arrow_sm_down.svg",
                            fit: BoxFit.scaleDown,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SvgPicture.asset('assets/icon/barchart.svg')
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              color: Color(0xffECEDEE),
            )
          ],
        ),
      ],
    );
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}

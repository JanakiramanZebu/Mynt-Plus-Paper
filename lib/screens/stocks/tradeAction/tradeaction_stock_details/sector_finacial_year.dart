import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../res/res.dart';
import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_stocklist.dart';
import '../../../../sharedWidget/scrollable_btn.dart';
 

class SectorFinacinalYear extends StatefulWidget {
  const SectorFinacinalYear({super.key});

  @override
  State<SectorFinacinalYear> createState() => _SectorFinacinalYearState();
}

class _SectorFinacinalYearState extends State<SectorFinacinalYear> {
  late ExpandedTileController _controller;
  late ExpandedTileController _controllers;
  @override
  void initState() {
    // initialize controller
    _controller = ExpandedTileController(isExpanded: false);
    _controllers = ExpandedTileController(isExpanded: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> sectorList = ["Valution", "Technical", "Forecasts"];
    List<bool> isActiveBtn = [true, false, false];
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          width: screenWidth,
          decoration: const BoxDecoration(
              color: Color(0xffFAFBFF),
              border: Border(bottom: BorderSide(color: Color(0xffDDDDDD)))),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Financial Years',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 180,
                      ),
                      Text(
                        'Mar 2023',
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
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Revenue',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              Text(
                '₹6,766',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff000000)),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: Color(0xffDDDDDD),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EPS (in Rs)',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              Text(
                '- ₹91,235',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xffFF1717)),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: Color(0xffDDDDDD),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DPS',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              Text(
                '₹10,455',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff000000)),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: Color(0xffDDDDDD),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout Ratio',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              Text(
                '₹34,252',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff000000)),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Container(
            width: screenWidth,
            height: 32,
            decoration: BoxDecoration(
                color: const Color(0xffF1F3F8),
                borderRadius: BorderRadius.circular(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icon/download.svg",
                  fit: BoxFit.scaleDown,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text("Annual report",
                    style: GoogleFonts.inter(
                        textStyle: textStyle(
                            const Color(0xff000000), 13, FontWeight.w500))),
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
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xffECEDEE)),
                  top: BorderSide(color: Color(0xffECEDEE)))),
          child: ExpandedTile(
            disableAnimation: true,
            trailingRotation: 90,
            theme: const ExpandedTileThemeData(
              headerColor: Color(0xffFFFFFF),
              // headerPadding: EdgeInsets.all(10),
              // contentPadding: EdgeInsets.symmetric(horizontal: 1),
              // contentRadius: 12.0,
              contentBackgroundColor: Color(0xffFFFFFF),
            ),
            controller: _controllers,
            leading: Text(
              'Balance Statement',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff000000)),
            ),
            content: Container(
              color: const Color(0xffFFFFFF),
              child: const Center(
                child: Text("This is the content!"),
              ),
            ),
            onTap: () {
              debugPrint("tapped!!");
            },
            onLongTap: () {
              debugPrint("long tapped!!");
            },
            title: Container(),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
              border: Border(
            bottom: BorderSide(color: Color(0xffECEDEE)),
          )),
          child: ExpandedTile(
            disableAnimation: true,
            trailingRotation: 90,
            theme: const ExpandedTileThemeData(
              headerColor: Color(0xffFFFFFF),
              // headerPadding: EdgeInsets.all(10),
              // contentPadding: EdgeInsets.symmetric(horizontal: 1),
              // contentRadius: 12.0,
              contentBackgroundColor: Color(0xffFFFFFF),
            ),
            controller: _controller,
            leading: Text(
              'Earning Statement',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff000000)),
            ),
            content: Container(
              color: const Color(0xffFFFFFF),
              child: const Center(
                child: Text("This is the content!"),
              ),
            ),
            onTap: () {
              debugPrint("tapped!!");
            },
            onLongTap: () {
              debugPrint("long tapped!!");
            },
            title: Container(),
          ),
        ),
        const SizedBox(
          height: 28,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analyst Recommendation',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              const SizedBox(
                height: 22,
              ),
              SizedBox(
                  height: 30,
                  child: ScrollableBtn(
                      btnActive: isActiveBtn, btnName: sectorList)),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          width: screenWidth,
          decoration: const BoxDecoration(
              color: Color(0xffFAFBFF),
              border: Border(bottom: BorderSide(color: Color(0xffDDDDDD)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stocks',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff666666)),
              ),
              Row(
                children: [
                  Text(
                    'PE Ratio',
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
        const StockList(),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            decoration: InputDecoration(
                fillColor: const Color(0xffF1F3F8),
                filled: true,
                labelStyle: GoogleFonts.inter(
                    textStyle: textStyle(
                        const Color(0xff000000), 16, FontWeight.w600)),
                hintStyle: GoogleFonts.inter(
                    textStyle: textStyle(
                        const Color(0xff69758F), 15, FontWeight.w500)),
                prefixIconColor: const Color(0xff586279),
                prefixIcon: SvgPicture.asset(
                  assets.searchIcon,
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
                hintText: "Search for stocks to add",
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30))),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}

textStyle(Color color, double fontSize, fWeight) {
  return GoogleFonts.inter(
      textStyle: TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  ));
}

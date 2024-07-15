import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../res/res.dart';

class PortfolioHoldings extends StatefulWidget {
  const PortfolioHoldings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PortfolioHoldingsState createState() => _PortfolioHoldingsState();
}

class _PortfolioHoldingsState extends State<PortfolioHoldings> {
  List<String> chartDuration = [
    "Stocks Holdings",
    "Others Holdings",
  ];
  List<bool> isActiveBtn = [
    true,
    false,
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Portfolio Holdings',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000),
                    letterSpacing: 0.36),
              ),
              const SizedBox(
                height: 20,
              ),
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
                                textStyle: textStyle(const Color(0xff000000),
                                    16, FontWeight.w600)),
                            hintStyle: GoogleFonts.inter(
                                textStyle: textStyle(const Color(0xff69758F),
                                    15, FontWeight.w500)),
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
                            hintText: "Search for stock",
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30))),
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Text("This Month",
                            style: GoogleFonts.inter(
                                textStyle: textStyle(const Color(0xff000000),
                                    13, FontWeight.w500))),
                        SvgPicture.asset(
                          "assets/icon/vector.svg",
                          width: 38,
                          height: 40,
                          fit: BoxFit.scaleDown,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
            height: 50,
            child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        for (var i = 0; i < isActiveBtn.length; i++) {
                          isActiveBtn[i] = false;
                        }
                        isActiveBtn[index] = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: isActiveBtn[index]
                              ? const Border(
                                  bottom: BorderSide(
                                      color: Color(0xff000000), width: 2))
                              : null),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      child: Text(chartDuration[index],
                          style: textStyle(
                              isActiveBtn[index]
                                  ? const Color(0xff000000)
                                  : const Color(0xff666666),
                              isActiveBtn[index] ? 14 : 13,
                              FontWeight.w600)),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 30);
                },
                itemCount: isActiveBtn[0] || isActiveBtn[1]
                    ? 2
                    : chartDuration.length)),
        if (isActiveBtn[0]) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isActiveBtn[0]) ...[
                mktProtWidget(),
              ]
            ],
          ),
          !isActiveBtn[0]
              ? const Divider(color: Color(0xffF1F2F4))
              : Container(),
        ],
        if (isActiveBtn[1]) ...[
          mktProtWidgets(),
          !isActiveBtn[1]
              ? const Divider(color: Color(0xffF1F2F4))
              : Container(),
        ]
      ],
    );
  }

  Container mktProtWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHight = MediaQuery.of(context).size.height * 0.60;
    return Container(
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 2, color: Color(0xffECEDEE)))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          SizedBox(
              height: 420,
              width: screenWidth,
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 6, color: Color(0xffF1F3F8)))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Agro Tech Foods Ltd.',
                                    overflow: TextOverflow.fade,
                                    maxLines: 2,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff000000),
                                    )),
                                Image.asset('assets/img/bought.png'),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('2,003,259',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff000000),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text('QTY.HELD',
                                        style: GoogleFonts.inter(
                                          letterSpacing: 0.24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff666666),
                                        )),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('8.22%',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff000000),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text('Holdings (%)'.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          letterSpacing: 0.24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff666666),
                                        )),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('174.21 Cr',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff000000),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text('Hold. val (cr)'.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          letterSpacing: 0.24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff666666),
                                        )),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              width: screenWidth,
                              decoration: BoxDecoration(
                                  color: const Color(0xffF5F8FF),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('Filing awaited for current qtr',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff000000),
                                  )),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 1,
                    );
                  },
                  itemCount: 3)),
          TextButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'See more holdings',
                    style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icon/Icon (5).svg'),
                ],
              )),
        ],
      ),
    );
  }

  Container mktProtWidgets() {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHight = MediaQuery.of(context).size.height * 0.60;
    return Container(
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 2, color: Color(0xffECEDEE)))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          SizedBox(
              height: 420,
              width: screenWidth,
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 6, color: Color(0xffF1F3F8)))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Aptech Ltd',
                                    overflow: TextOverflow.fade,
                                    maxLines: 2,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff000000),
                                    )),
                                // Image.asset('assets/icon/stockholding.png')
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('2,003,259',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff000000),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text('QTY.HELD',
                                        style: GoogleFonts.inter(
                                          letterSpacing: 0.24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff666666),
                                        )),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('8.22%',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff000000),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text('Holdings (%)'.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          letterSpacing: 0.24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff666666),
                                        )),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('174.21 Cr',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff000000),
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text('Hold. val (cr)'.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          letterSpacing: 0.24,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff666666),
                                        )),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              width: screenWidth,
                              decoration: BoxDecoration(
                                  color: const Color(0xffF5F8FF),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('Filing awaited for current qtr',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff000000),
                                  )),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 1,
                    );
                  },
                  itemCount: 3)),
          TextButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'See more holdings',
                    style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset('assets/icon/Icon (5).svg'),
                ],
              )),
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

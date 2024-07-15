import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';

class SuperStarPortfolio extends StatelessWidget {
  const SuperStarPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        leadingWidth: 35,
        backgroundColor: const Color(0xffFFFFFF),
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        shadowColor: const Color(0xffECEFF3),
        title: Text(
          'Superstar portfolios',
          style: textStyle(const Color(0xff000000), 14, FontWeight.w600),
        ),
        actions: [
          SvgPicture.asset(assets.filterlines),
          const SizedBox(
            width: 12,
          ),
          SvgPicture.asset(assets.searchIcon),
          const SizedBox(
            width: 12,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 6, color: Color(0xffF1F3F8)))),
            child: Text(
              '8 Superstar Porfolio',
              style: textStyle(const Color(0xff666666), 13, FontWeight.w500),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, Routes.portfolioindex);
            },
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 6, color: Color(0xffF1F3F8)))),
              width: screenWidth,
              child: Column(
                children: [
                  ListTile(
                    leading: Image.asset(assets.superstar),
                    title: Text(
                      'Ashish Kacholia\'s',
                      style: textStyle(
                          const Color(0xff000000), 15, FontWeight.w600),
                    ),
                    subtitle: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: const Color(0xffF1F3F8)),
                              child: Text(
                                'Growth'.toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff666666),
                                    letterSpacing: 1.1),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: const Color(0xffF1F3F8)),
                              child: Text(
                                'Equity'.toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff666666),
                                    letterSpacing: 1.1),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: const Color(0xffF1F3F8)),
                              child: Text(
                                'ELSS'.toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff666666),
                                    letterSpacing: 1.1),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 75,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xffCCCCCC)),
                                borderRadius: BorderRadius.circular(19),
                              ),
                              child: SvgPicture.asset(assets.highrisk)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xffCCCCCC)),
                              borderRadius: BorderRadius.circular(19),
                            ),
                            child: SvgPicture.asset(assets.watchlist),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      color: Color(0xffECEDEE),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("₹27,400",
                                style: GoogleFonts.inter(
                                    textStyle: textStyle(
                                        const Color(0xff000000),
                                        15,
                                        FontWeight.w500))),
                            const SizedBox(height: 5),
                            Text("MIN.INVEST",
                                style: GoogleFonts.inter(
                                    letterSpacing: 0.24,
                                    textStyle: textStyle(
                                        const Color(0xff666666),
                                        12,
                                        FontWeight.w500)))
                          ],
                        ),
                        Column(
                          children: [
                            Text("+20.2%",
                                style: GoogleFonts.inter(
                                    textStyle: textStyle(
                                        const Color(0xff43A833),
                                        15,
                                        FontWeight.w500))),
                            const SizedBox(height: 5),
                            Text("3Y CAGR",
                                style: GoogleFonts.inter(
                                    letterSpacing: 0.24,
                                    textStyle: textStyle(
                                        const Color(0xff666666),
                                        12,
                                        FontWeight.w500)))
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("20",
                                style: GoogleFonts.inter(
                                    textStyle: textStyle(
                                        const Color(0xff000000),
                                        15,
                                        FontWeight.w500))),
                            const SizedBox(height: 5),
                            Text("STOCKS",
                                style: GoogleFonts.inter(
                                    letterSpacing: 0.24,
                                    textStyle: textStyle(
                                        const Color(0xff666666),
                                        12,
                                        FontWeight.w500)))
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

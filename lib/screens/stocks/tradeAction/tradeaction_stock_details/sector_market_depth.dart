import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SectorMarketDepth extends StatefulWidget {
  const SectorMarketDepth({super.key});

  @override
  State<SectorMarketDepth> createState() => _SectorMarketDepthState();
}

class _SectorMarketDepthState extends State<SectorMarketDepth> {
  @override
  Widget build(BuildContext context) {
    double screenWidths = MediaQuery.of(context).size.width;
    double screenWidthss = MediaQuery.of(context).size.width / 2.1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Market Depth',
            style: GoogleFonts.inter(
              letterSpacing: 0.36,
              color: const Color(0xff000000),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy Qty.'.toUpperCase(),
                    style: GoogleFonts.inter(
                        letterSpacing: 0.96,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '65.45%',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sell QTY.'.toUpperCase(),
                    style: GoogleFonts.inter(
                        letterSpacing: 0.96,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '32.78%',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ],
              )
            ],
          ),
        ),
        LinearPercentIndicator(
          barRadius: const Radius.circular(10),
          backgroundColor: const Color(0xffD34645),
          width: screenWidths,
          animation: true,
          animationDuration: 3000,
          // fillColor: Color(0xff148564),
          lineHeight: 5,

          percent: 0.65,

          progressColor: const Color(0xff148564),
        ),
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity',
                style: GoogleFonts.inter(
                  color: const Color(0xff506D84),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Bid',
                style: GoogleFonts.inter(
                  color: const Color(0xff148564),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Ask',
                style: GoogleFonts.inter(
                  color: const Color(0xffD34645),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Quantity',
                style: GoogleFonts.inter(
                  color: const Color(0xff506D84),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidthss,
              // color: Color(0xffDAECE7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearPercentIndicator(
                    width: screenWidthss,
                    backgroundColor: const Color(0xffFFFFFF),
                    animation: true,
                    animationDuration: 3000,
                    lineHeight: 20.0,
                    percent: 0.20,
                    center: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5,007',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff000000)),
                        ),
                        Text(
                          '116.80',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff666666)),
                        ),
                      ],
                    ),
                    linearStrokeCap: LinearStrokeCap.butt,
                    progressColor: const Color(0xffDAECE7),
                  ),
                ],
              ),
            ),
            LinearPercentIndicator(
              width: screenWidthss,
              backgroundColor: const Color(0xffFCDDDC),
              animation: true,
              animationDuration: 3000,
              lineHeight: 20.0,
              percent: 0,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '116.80',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                  Text(
                    '5,007',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                ],
              ),
              progressColor: const Color(0xffFFFFFF),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidthss,
              // color: Color(0xffDAECE7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearPercentIndicator(
                    width: screenWidthss,
                    backgroundColor: const Color(0xffFFFFFF),
                    animation: true,
                    animationDuration: 2000,
                    lineHeight: 20.0,
                    percent: 0.70,
                    center: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5,007',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff000000)),
                        ),
                        Text(
                          '116.80',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff666666)),
                        ),
                      ],
                    ),
                    linearStrokeCap: LinearStrokeCap.butt,
                    progressColor: const Color(0xffDAECE7),
                  ),
                ],
              ),
            ),
            LinearPercentIndicator(
              width: screenWidthss,
              backgroundColor: const Color(0xffFCDDDC),
              animation: true,
              animationDuration: 3000,
              lineHeight: 20.0,
              percent: 0.60,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '116.80',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                  Text(
                    '5,007',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                ],
              ),
              progressColor: const Color(0xffFFFFFF),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidthss,
              // color: Color(0xffDAECE7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearPercentIndicator(
                    width: screenWidthss,
                    backgroundColor: const Color(0xffDAECE7),
                    animation: true,
                    animationDuration: 2000,
                    lineHeight: 20.0,
                    percent: 0,
                    center: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5,007',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff000000)),
                        ),
                        Text(
                          '116.80',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff666666)),
                        ),
                      ],
                    ),
                    linearStrokeCap: LinearStrokeCap.butt,
                    progressColor: const Color(0xffFFFFFF),
                  ),
                ],
              ),
            ),
            LinearPercentIndicator(
              width: screenWidthss,
              backgroundColor: const Color(0xffFCDDDC),
              animation: true,
              animationDuration: 3000,
              lineHeight: 20.0,
              percent: 0.40,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '116.80',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                  Text(
                    '5,007',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                ],
              ),
              progressColor: const Color(0xffFFFFFF),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidthss,
              // color: Color(0xffDAECE7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearPercentIndicator(
                    width: screenWidthss,
                    backgroundColor: const Color(0xffFFFFFF),
                    animation: true,
                    animationDuration: 2000,
                    lineHeight: 20.0,
                    percent: 0.60,
                    center: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5,007',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff000000)),
                        ),
                        Text(
                          '116.80',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff666666)),
                        ),
                      ],
                    ),
                    progressColor: const Color(0xffDAECE7),
                  ),
                ],
              ),
            ),
            LinearPercentIndicator(
              width: screenWidthss,
              backgroundColor: const Color(0xffFCDDDC),
              animation: true,
              animationDuration: 3000,
              lineHeight: 20.0,
              percent: 0.30,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '116.80',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                  Text(
                    '5,007',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                ],
              ),
              progressColor: const Color(0xffFFFFFF),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidthss,
              // color: Color(0xffDAECE7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearPercentIndicator(
                    width: screenWidthss,
                    backgroundColor: const Color(0xffFFFFFF),
                    animation: true,
                    animationDuration: 2000,
                    lineHeight: 20.0,
                    percent: 0.60,
                    center: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5,007',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff000000)),
                        ),
                        Text(
                          '116.80',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff666666)),
                        ),
                      ],
                    ),
                    progressColor: const Color(0xffDAECE7),
                  ),
                ],
              ),
            ),
            LinearPercentIndicator(
              width: screenWidthss,
              backgroundColor: const Color(0xffFCDDDC),
              animation: true,
              animationDuration: 3000,
              lineHeight: 20.0,
              percent: 0.30,
              center: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '116.80',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                  Text(
                    '5,007',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff666666)),
                  ),
                ],
              ),
              progressColor: const Color(0xffFFFFFF),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        const Divider(
          color: Color(0xffECEDEE),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}

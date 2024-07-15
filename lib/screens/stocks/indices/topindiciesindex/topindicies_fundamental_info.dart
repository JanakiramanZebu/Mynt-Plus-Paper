import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../res/res.dart';

class TopIndiciesFundamentalInfo extends StatefulWidget {
  const TopIndiciesFundamentalInfo({super.key});

  @override
  State<TopIndiciesFundamentalInfo> createState() =>
      _TopIndiciesFundamentalInfoState();
}

class _TopIndiciesFundamentalInfoState
    extends State<TopIndiciesFundamentalInfo> {
  double low = 0.00;
  double high = 0.00;
  double price = 0.00;
  int indicesLength = 0;
  bool hideMore = false;
  @override
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      //                   <--- left side
                      color: Color(0xffddddddddd),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PE RATIO',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xfff666666),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '22.86',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      //                   <--- left side
                      color: Color(0xffddddddddd),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PB RATIO',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xfff666666),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '22.86',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    )
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xffddddddddd),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRADED VALUE',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xfff666666),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2,21,060',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            'HIGH-LOW',
            style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xff666666),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.96),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹1,348.95',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 162,
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: const Color(0xff000000),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 8.0),
                    inactiveTrackColor: const Color(0xff000000),
                    valueIndicatorTextStyle: GoogleFonts.inter(
                        textStyle: textStyle(
                            const Color(0xffffffff), 14, FontWeight.w500)),
                  ),
                  child: Slider(
                      min: low == 0.00 ? price - 10 : low,
                      max: high == 0.00 ? price + 10 : high,
                      value: price,
                      label: "₹$price",
                      activeColor: const Color(0xffD9D9D9),
                      thumbColor: const Color(0xff000000),
                      // divisions: 10,
                      onChanged: null),
                ),
              ),
              Text(
                '₹1,322.65',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xffDDDDDD),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            '52 Weeks High - 52 Weeks Low'.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xff666666),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.96),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹1,438.80',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 162,
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: const Color(0xff000000),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 8.0),
                    inactiveTrackColor: const Color(0xff000000),
                    valueIndicatorTextStyle: GoogleFonts.inter(
                        textStyle: textStyle(
                            const Color(0xffffffff), 14, FontWeight.w500)),
                  ),
                  child: Slider(
                      min: low == 0.00 ? price - 10 : low,
                      max: high == 0.00 ? price + 10 : high,
                      value: price,
                      label: "₹$price",
                      activeColor: const Color(0xffD9D9D9),
                      thumbColor: const Color(0xff000000),
                      // divisions: 10,
                      onChanged: null),
                ),
              ),
              Text(
                '₹1300.34',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xffDDDDDD),
          ),
          const SizedBox(
            height: 22,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xffF1F3F8),
            ),
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Top NIFTY 50 Options',
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              assets.rightarrow,
                              // ignore: deprecated_member_use
                              color: const Color(0xff0037B7),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'It represents the top 50 Largecap companies based on market capitalisation.',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xfff666666)),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(assets.nifity50image),
                ],
              ),
            ),
          ),
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

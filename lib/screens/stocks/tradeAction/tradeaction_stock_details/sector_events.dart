import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../sharedWidget/scrollable_btn.dart'; 

class EftEvent extends StatefulWidget {
  const EftEvent({super.key});

  @override
  State<EftEvent> createState() => _EftEventState();
}

class _EftEventState extends State<EftEvent> {
  List<String> sectorList = [
    "Dividends",
    "Corp. action",
    "Announcement",
  ];
  List<bool> isActiveBtn = [
    true,
    false,
    false,
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Events',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              const SizedBox(
                height: 17,
              ),
              SizedBox(
                  height: 30,
                  child: ScrollableBtn(
                      btnActive: isActiveBtn, btnName: sectorList)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dividens',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'The last rights shares that Punjab National Bank had issued was in 2017 in the ratio of 2:25 at a premium of Rs 605.00 per share. The share has been quoting ex-rights from January 31, 2018.',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff666666)),
              ),
              const SizedBox(
                height: 26,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '2023 Dividends'.toUpperCase(),
                    style: GoogleFonts.inter(
                        letterSpacing: 1.04,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                  Container(
                    width: 85,
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("2023",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff000000))),
                        SvgPicture.asset(
                          'assets/icon/vector.svg',
                          // ignore: deprecated_member_use
                          color: const Color(0xff666666),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: 'Ex date -',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff666666)),
                  children: [
                    TextSpan(
                      text: '',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xff666666)),
                    ),
                    TextSpan(
                      text: ' 25 Jun, 2023',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xff000000),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                'Read Document',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0037B7),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        const Divider(
          color: Color(0xffECEDEE),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dividend'.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: const Color(0xff666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66),
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      text: '23 ',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff43A833)),
                      children: [
                        TextSpan(
                          text: '/share',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xff999999)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total dividend'.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: const Color(0xff666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66),
                  ),
                  Text(
                    '750',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Yield'.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: const Color(0xff666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66),
                  ),
                  Text(
                    '2.3%',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: 'Ex date -',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff666666)),
                  children: [
                    TextSpan(
                      text: '',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xff666666)),
                    ),
                    TextSpan(
                      text: ' 25 Jun, 2023',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xff000000),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                'Read Document',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0037B7),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        const Divider(
          color: Color(0xffECEDEE),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dividend'.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: const Color(0xff666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66),
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      text: '23 ',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff43A833)),
                      children: [
                        TextSpan(
                          text: '/share',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xff999999)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total dividend'.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: const Color(0xff666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66),
                  ),
                  Text(
                    '750',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Yield'.toUpperCase(),
                    style: GoogleFonts.inter(
                        color: const Color(0xff666666),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.66),
                  ),
                  Text(
                    '2.3%',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff000000)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 28,
        ),
        Text(
          'Load more dividends',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff0037B7)),
        ),
        const SizedBox(
          height: 20,
        ),
        const Divider(
          color: Color(0xffECEDEE),
        ),
      ],
    );
  }
}

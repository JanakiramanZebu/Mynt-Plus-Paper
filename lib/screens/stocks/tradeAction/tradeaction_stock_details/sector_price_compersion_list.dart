import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class EftPriceComperstionlist extends StatefulWidget {
  const EftPriceComperstionlist({super.key});

  @override
  State<EftPriceComperstionlist> createState() =>
      _EftPriceComperstionlistState();
}

class _EftPriceComperstionlistState extends State<EftPriceComperstionlist> {
  List<Cars> dummyData = [
    Cars(
        img: 'assets/icon/greenrectangle.svg',
        listname: 'Reliance Industries',
        icon: 'assets/icon/pen.svg',
        value: '+37.64%',
        close: 'assets/icon/close.svg'),
    Cars(
        img: 'assets/icon/lightgreenrectangle.svg',
        listname: 'Hindustan Petroleum..',
        icon: 'assets/icon/pen.svg',
        value: '-37.64%',
        close: 'assets/icon/close.svg'),
    Cars(
        img: 'assets/icon/yellowrectangle.svg',
        listname: 'Hindustan Petroleum..',
        icon: 'assets/icon/pen.svg',
        value: '+12.60%',
        close: 'assets/icon/close.svg'),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(dummyData[index].img),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      dummyData[index].listname,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff000000)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(dummyData[index].icon),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      dummyData[index].value,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: dummyData[index].value == '-37.64%'
                              ? const Color(0xffFF1717)
                              : const Color(0xff7CD36E)),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(dummyData[index].close)
                  ],
                ),
              ],
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            color: Color(0xffECEDEE),
          ),
        );
      },
    );
  }
}

class Cars {
  String img;
  String listname;
  String icon;
  String value;
  String close;

  Cars(
      {required this.img,
      required this.listname,
      required this.icon,
      required this.value,
      required this.close});
}

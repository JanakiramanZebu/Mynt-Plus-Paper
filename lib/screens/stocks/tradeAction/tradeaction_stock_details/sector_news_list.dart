import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EftNews extends StatefulWidget {
  const EftNews({super.key});

  @override
  State<EftNews> createState() => _EftNewsState();
}

class _EftNewsState extends State<EftNews> {
  List<Cars> dummyData = [
    Cars(
      img: '2 days ago     Economic Times',
      listname: 'Canara Bank starts process to sell non-core asset IPOs',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'CBI Books IL&FS Transportation Limited for Causing Loss of Over Rs 6,524 Cr',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Technical Analysis: Canara Bank, Barbeque-Nation Hospitality and HEG',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
    Cars(
      img: '2 days ago     Economic Times',
      listname:
          'Google Pay launches RuPay credit cards support on UPI in India',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
        color: Color(0xF1F3F8ff),
      ))),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dummyData[index].img,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff999999)),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  dummyData[index].listname,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff000000)),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: Color(0xffF1F3F8),
            ),
          );
        },
      ),
    );
  }
}

class Cars {
  String img;
  String listname;
  Cars({
    required this.img,
    required this.listname,
  });
}

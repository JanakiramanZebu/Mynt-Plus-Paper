import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class EftAnalystRecoList extends StatefulWidget {
  const EftAnalystRecoList({super.key});

  @override
  State<EftAnalystRecoList> createState() => _EftAnalystRecoListState();
}

class _EftAnalystRecoListState extends State<EftAnalystRecoList> {
  List<Cars> dummyData = [
    Cars(
      img: 'assets/icon/greenrectangle.svg',
      listname: 'Total Promoter Holding',
      value: '50.41 %',
    ),
    Cars(
      img: 'assets/icon/lightgreenrectangle.svg',
      listname: 'Foreign Institutions',
      value: '22.49 %',
    ),
    Cars(
      img: 'assets/icon/yellowrectangle.svg',
      listname: 'Other Domestic Institutions',
      value: '9.87 %',
    ),
    Cars(
      img: 'assets/icon/lightyellow.svg',
      listname: 'Retail and Other',
      value: '10.88 %',
    ),
    Cars(
      img: 'assets/icon/Rectangle (6).svg',
      listname: 'Mutual Funds',
      value: '6.34%',
    )
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
                  ],
                ),
                Row(
                  children: [
                    Text(
                      dummyData[index].value,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff000000)),
                    ),
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

  String value;

  Cars({
    required this.img,
    required this.listname,
    required this.value,
  });
}

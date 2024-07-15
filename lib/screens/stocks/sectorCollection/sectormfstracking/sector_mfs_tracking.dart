import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectorMfsTracking extends StatefulWidget {
  const SectorMfsTracking({super.key});

  @override
  State<SectorMfsTracking> createState() => _SectorMfsTrackingState();
}

class _SectorMfsTrackingState extends State<SectorMfsTracking> {
  List<MfsTracking> mfstracking = [
    MfsTracking(
        mfsname: 'Nippon India ETF Nifty BeES',
        mfsindex: 'NIFTYBEES',
        mfslp: '201.08',
        mfsperchange: '+0.19%'),
    MfsTracking(
        mfsname: 'ICICI Prudential Nifty ETF',
        mfsindex: 'ICICINIFTY',
        mfslp: '301.08',
        mfsperchange: '-0.19%'),
    MfsTracking(
        mfsname: 'Mirae Asset Nifty 50 ETF',
        mfsindex: 'MAN50ETF',
        mfslp: '301.08',
        mfsperchange: '-0.19%'),
    MfsTracking(
        mfsname: 'UTI-Nifty Exchange Traded Fund',
        mfsindex: 'UTINIFTETF',
        mfslp: '301.08',
        mfsperchange: '-0.19%'),
    MfsTracking(
        mfsname: 'HDFC Nifty 50',
        mfsindex: 'HDFCNIFETF',
        mfslp: '301.08',
        mfsperchange: '-0.19%'),
  ];
  @override
  Widget build(BuildContext context) {
    // double screenHieght = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 141,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: mfstracking.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffCCCCCC)),
                borderRadius: const BorderRadius.all(Radius.circular(4))),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mfstracking[index].mfsname,
                  style:
                      textStyle(const Color(0xff000000), 14, FontWeight.w600),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  mfstracking[index].mfsindex,
                  style: GoogleFonts.inter(
                      color: const Color(0xff666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  endIndent: 110,
                  color: Color(0xff000000),
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      mfstracking[index].mfslp,
                      style: textStyle(
                          const Color(0xff000000), 14, FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      mfstracking[index].mfsperchange,
                      style: textStyle(
                          const Color(0xff43A833), 14, FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 20,
          );
        },
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

class MfsTracking {
  String mfsname;
  String mfsindex;
  String mfslp;
  String mfsperchange;
  MfsTracking({
    required this.mfsname,
    required this.mfsindex,
    required this.mfslp,
    required this.mfsperchange,
  });
}

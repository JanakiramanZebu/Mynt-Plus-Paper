import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_mfi_list.dart';

class EftMutualFundsHoldingTrend extends StatefulWidget {
  const EftMutualFundsHoldingTrend({super.key});

  @override
  State<EftMutualFundsHoldingTrend> createState() =>
      _EftMutualFundsHoldingTrendState();
}

class _EftMutualFundsHoldingTrendState
    extends State<EftMutualFundsHoldingTrend> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mutual Funds Holding Trend',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'In last 3 months, mutual fund holding of the company has almost stayed constant',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff666666)),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                    '3M Change',
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
        const SizedBox(
          height: 16,
        ),
        const EftMutualFundList(),
        const SizedBox(
          height: 24,
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
          height: 22,
        ),
        const Divider(
          color: Color(0xffECEDEE),
        )
      ],
    );
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}

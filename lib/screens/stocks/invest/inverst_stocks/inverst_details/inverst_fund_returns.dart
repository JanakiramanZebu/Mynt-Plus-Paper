import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class InverstFundReturns extends ConsumerWidget {
  const InverstFundReturns({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //  final  fundReturn = watch();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Fund returns",
                  style:
                      textStyle(const Color(0xff000000), 16, FontWeight.w600)),
              const SizedBox(width: 12),
              // SvgPicture.asset("assets/img/dot_green.svg"),
              Text(" Benchmark",
                  style:
                      textStyle(const Color(0xff666666), 12, FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisSpacing: 13,
            mainAxisSpacing: 11,
            childAspectRatio: 1.07,
            children: List.generate(6, (index) {
              return Stack(
                children: [
                  Container(
                    height: 106,
                    width: 110,
                    decoration: BoxDecoration(
                        color: index.isEven
                            ? const Color(0xffFBFFFA)
                            : const Color(0xffFFFCFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffCCCCCC))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(index.isEven ? "35.4%" : "-67.90",
                              style: textStyle(
                                  Color(index.isEven ? 0xff43A833 : 0xffFF1717),
                                  18,
                                  FontWeight.w500)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("3 YEAR CAGR",
                              textAlign: TextAlign.center,
                              style: textStyle(const Color(0xff666666), 12,
                                  FontWeight.w500)),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 75,
                    child: Container(
                      height: 28,
                      width: 110,
                      decoration: const BoxDecoration(
                          color: Color(0xff43A833),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8))),
                      child: Center(
                        child: Text("2.4%",
                            style: textStyle(
                                const Color(0xffFFFFFF), 12, FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(
            height: 16,
          ),
          const Divider(
            color: Color(0xffECEDEE),
          ),
        ],
      ),
    );
  }

  textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

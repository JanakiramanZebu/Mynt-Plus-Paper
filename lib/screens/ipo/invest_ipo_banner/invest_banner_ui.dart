import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class InvestIPO extends ConsumerWidget {
  const InvestIPO({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: const Color(0xff834EDA),
              borderRadius: BorderRadius.circular(5)),
          margin: const EdgeInsets.only(left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ListTile(
                title: Text("Invest in IPOs",
                    style: GoogleFonts.inter(
                        textStyle: textStyle(
                            const Color(0xffFEFDFD), 20, FontWeight.w600))),
                subtitle: Column(
                  children: [
                    const SizedBox(height: 3),
                    Text(
                        "Initial public offering a new stock issuance for the first time.",
                        style: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xffE6DCF8), 14, FontWeight.w500))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Container(
              //   margin:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              //   decoration: BoxDecoration(
              //       color: const Color(0xff000000),
              //       borderRadius: BorderRadius.circular(32)),
              //   child: Text("Apply for an IPO",
              //       style: GoogleFonts.inter(
              //           textStyle: textStyle(
              //               const Color(0xffFFFFFF), 14, FontWeight.w600))),
              // )
            ],
          ),
        ),
      ],
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

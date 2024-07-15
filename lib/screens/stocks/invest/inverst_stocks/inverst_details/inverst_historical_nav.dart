import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InverstHistrocialNav extends StatefulWidget {
  const InverstHistrocialNav({super.key});

  @override
  State<InverstHistrocialNav> createState() => _InverstHistrocialNavState();
}

class _InverstHistrocialNavState extends State<InverstHistrocialNav> {
  List<String> chartDuration = ["1M", "3M", "6M", "1YR", "3YR", "MAX"];
  List<bool> isActiveBtn = [true, false, false, false, false, false];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 26),
                    Text("Historical NAV",
                        style: textStyle(
                            const Color(0xff000000), 18, FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text("Past Fund performance",
                        style: textStyle(
                            const Color(0xff666666), 14, FontWeight.w500)),
                  ]),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.only(left: 16),
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            for (var i = 0; i < isActiveBtn.length; i++) {
                              isActiveBtn[i] = false;
                            }
                            isActiveBtn[index] = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: isActiveBtn[index]
                                  ? const Border(
                                      bottom: BorderSide(
                                          color: Color(0xff000000), width: 2))
                                  : null),
                          padding: const EdgeInsets.all(14),
                          child: Text(chartDuration[index],
                              style: textStyle(
                                  isActiveBtn[index]
                                      ? const Color(0xff000000)
                                      : const Color(0xff666666),
                                  isActiveBtn[index] ? 14 : 13,
                                  FontWeight.w600)),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 8);
                    },
                    itemCount: chartDuration.length)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                color: const Color(0xff3AAA92),
                                borderRadius: BorderRadius.circular(2)),
                          ),
                          Text("  Listed Venture Capital".toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff666666),
                                letterSpacing: 0.8,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '₹ 205.412',
                        style:
                            textStyle(const Color(0xff000000), 14, FontWeight.w600),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                color: const Color(0xffF6C646),
                                borderRadius: BorderRadius.circular(2)),
                          ),
                          Text("  Nifty Midcap 100".toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff666666),
                                letterSpacing: 0.8,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '₹ 205.412',
                        style:
                            textStyle(const Color(0xff000000), 14, FontWeight.w600),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            // AspectRatio(
            //   aspectRatio: 1.4,
            //   child: LineChartWidget(
            //     plotData: PlotData(
            //       maxY: 1000,
            //       minY: 0,
            //       result: [
            //         100,
            //         12,
            //         170,
            //         20,
            //         36,
            //         80,
            //         200,
            //         100,
            //         400,
            //         500,
            //         300,
            //         700,
            //         1000
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
            child: Image.asset('assets/img/line-chart.png'))
      ],
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

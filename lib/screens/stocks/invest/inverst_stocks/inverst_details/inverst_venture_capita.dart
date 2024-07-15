import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import '../../../../../res/res.dart';

class InverstVentureCapita extends StatefulWidget {
  const InverstVentureCapita({super.key});

  @override
  State<InverstVentureCapita> createState() => _InverstVentureCapitaState();
}

class _InverstVentureCapitaState extends State<InverstVentureCapita> {
  List<Tradinganddemataccount> dematedata = [
    Tradinganddemataccount(
      topic: 'Launched (29y ago)',
      info: 'Aug 17, 2019',
    ),
    Tradinganddemataccount(
      topic: 'Next Rebalance',
      info: 'Oct 3, 2023',
    ),
    Tradinganddemataccount(
      topic: 'Lumpsum Min.',
      info: '5000',
    ),
    Tradinganddemataccount(
      topic: 'SIP Minimum',
      info: '1000',
    ),
    Tradinganddemataccount(
      topic: 'Rebalance Freq.',
      info: 'Quarterly',
    ),
    Tradinganddemataccount(
      topic: 'Last Rebalance',
      info: 'Oct 3, 2023',
    ),
  ];
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffECEDEE)))),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the Venture Capital',
            style: GoogleFonts.inter(
                color: const Color(0xff000000),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.36),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Collection Objective',
            style: GoogleFonts.inter(
                color: const Color(0xff000000),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.32),
          ),
          const SizedBox(
            height: 8,
          ),
          ReadMoreText(
            "We find multi-baggers in listed small caps by using big-data analytics to quantitatively select governance standards and earnings potential using our proprietary database and algorithm.",
            style: GoogleFonts.inter(
                letterSpacing: -0.07,
                height: 1.7,
                textStyle:
                    textStyle(const Color(0xff666666), 14, FontWeight.w600)),
            trimLines: 3,
            colorClickableText: const Color(0xff0037B7),
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Read more',
            trimExpandedText: ' Read less',
          ),
          const SizedBox(
            height: 32,
          ),
          GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 169,
                  childAspectRatio: 2.9,
                  crossAxisSpacing: 50,
                  mainAxisSpacing: 20),
              itemCount: dematedata.length,
              itemBuilder: (BuildContext ctx, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        //                   <--- left side
                        color: dematedata[index].topic == 'Rebalance Freq.' ||
                                dematedata[index].topic == 'Last Rebalance'
                            ? const Color(0xffFFFFFF)
                            : const Color(0xffdddddd),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dematedata[index].topic.toUpperCase(),
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.96,
                              color: const Color(0xff666666))),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        dematedata[index].info.toUpperCase(),
                        style:
                            textStyle(const Color(0xff000000), 14, FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                );
              }),
          const SizedBox(
            height: 32,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Collection Managers",
                  style:
                      textStyle(const Color(0xff000000), 16, FontWeight.w600)),
              const SizedBox(height: 14),
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffCCCCCC)),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Image.asset(index == 0
                                  ? assets.manager1
                                  : assets.manager2)
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    index == 0
                                        ? "Priya Ranjan"
                                        : "Sandeep Tandon",
                                    style: GoogleFonts.inter(
                                        textStyle: textStyle(
                                            const Color(0xff000000),
                                            16,
                                            FontWeight.w600))),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Fund Manager",
                                            style: textStyle(
                                                const Color(0xff000000),
                                                12,
                                                FontWeight.w500)),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text("11 yrs",
                                                style: textStyle(
                                                    const Color(0xff666666),
                                                    12,
                                                    FontWeight.w500)),
                                            Text(" experience",
                                                style: textStyle(
                                                    const Color(0xff999999),
                                                    12,
                                                    FontWeight.w500)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("₹19,236.26",
                                                style: textStyle(
                                                    const Color(0xff000000),
                                                    12,
                                                    FontWeight.w500)),
                                            Text(" Cr",
                                                style: textStyle(
                                                    const Color(0xff999999),
                                                    12,
                                                    FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text("24 funds managed",
                                            style: textStyle(
                                                const Color(0xff999999),
                                                12,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemCount: 2),
              const SizedBox(height: 40),
            ],
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

class Tradinganddemataccount {
  String topic;
  String info;

  Tradinganddemataccount({
    required this.topic,
    required this.info,
  });
}

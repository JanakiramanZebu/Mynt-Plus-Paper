import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialRatios extends StatelessWidget {
  const FinancialRatios({super.key});

  @override
  Widget build(BuildContext context) {
    List<Tradinganddemataccount> dematedata = [
      Tradinganddemataccount(
        topic: 'PE Ratio',
        info: '27.43',
      ),
      Tradinganddemataccount(
        topic: 'PB ratio',
        info: '3.86',
      ),
      Tradinganddemataccount(
        topic: 'Div Yield',
        info: '0.70',
      ),
      Tradinganddemataccount(
        topic: 'Index PE',
        info: '21.75',
      ),
      Tradinganddemataccount(
        topic: 'Index PB',
        info: '21.75',
      ),
      Tradinganddemataccount(
        topic: 'Index Div Yield',
        info: '0.87',
      ),
    ];
    
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffECEDEE)))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Ratios',
            style: textStyle(const Color(0xff000000), 16, FontWeight.w600),
          ),
          const SizedBox(
            height: 24,
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
                        color: dematedata[index].topic == 'Index PB' ||
                                dematedata[index].topic == 'Index Div Yield'
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
                            textStyle(const Color(0xff000000), 16, FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                );
              }),
        
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

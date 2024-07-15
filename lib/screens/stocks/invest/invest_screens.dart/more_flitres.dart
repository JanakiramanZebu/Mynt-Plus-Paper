import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreFilters extends StatelessWidget {
  const MoreFilters({super.key});

  @override
  Widget build(BuildContext context) {
     List<Morefilters> morefilters = [
    Morefilters(
      topic: 'Top Gainer ',
      info: '395 funds',
      basket: '18 recommended',
    ),
    Morefilters(
      topic: 'Low Performer',
      info: '472 funds',
      basket: '12 recommended',
    ),
    Morefilters(
      topic: 'Shadow Basket',
      info: '503 funds',
      basket: '18 recommended',
    ),
    Morefilters(
      topic: 'Growth Basket',
      info: '600 funds',
      basket: '18 recommended',
    ),
  ];

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: morefilters.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffCCCCCC)),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                width: 142,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      morefilters[index].topic,
                      style: GoogleFonts.inter(
                          textStyle: textStyle(
                              const Color(0xff000000), 14, FontWeight.w600)),
                    ),
                    const Divider(
                      endIndent: 85,
                      color: Color(0xff000000),
                      thickness: 1,
                    ),
                    Text(morefilters[index].info,
                        style: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff666666), 12, FontWeight.w500))),
                    const SizedBox(height: 4),
                    Text(morefilters[index].basket,
                        style: GoogleFonts.inter(
                            textStyle: textStyle(
                                const Color(0xff43A833), 12, FontWeight.w400)))
                  ],
                ));
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              width: 12,
            );
          },
        ),
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

class Morefilters {
  String topic;
  String info;
  String basket;
  Morefilters({
    required this.topic,
    required this.info,
    required this.basket,
  });
}

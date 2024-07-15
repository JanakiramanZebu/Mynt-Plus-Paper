import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AllCollection extends StatelessWidget {
  const AllCollection({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<Allcollections> collectiondata = [
      Allcollections(
        logo: 'assets/icon/gold-coin 3.svg',
        topic: 'Popular under ₹500 ',
        info:
            'Low-volatility zebu trade with minimum investment amount less than ₹500',
        button: 'See all 10 basket',
      ),
      Allcollections(
        logo: 'assets/icon/organic-2 1.svg',
        topic: 'Wealth Defenders',
        info:
            'Low-volatility zebu trade with minimum investment amount less than ₹500',
        button: 'See all 10 basket',
      ),
      Allcollections(
        logo: 'assets/icon/percent-sign 3.svg',
        topic: 'Popular under ₹500 ',
        info:
            'Low-volatility zebu trade with minimum investment amount less than ₹500',
        button: 'See all 17 basket',
      ),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: screenWidth,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffCCCCCC)),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    collectiondata[index].logo == 'assets/icon/gold-coin 3.svg'
                        ? SvgPicture.asset(collectiondata[index].logo)
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9.17, vertical: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xff000000),
                                borderRadius: BorderRadius.circular(80)),
                            child:
                                SvgPicture.asset(collectiondata[index].logo)),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      collectiondata[index].topic,
                      style: textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      collectiondata[index].info,
                      style: textStyle(const Color(0xff666666), 14, FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      collectiondata[index].button,
                      style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 16,
              );
            },
            itemCount: collectiondata.length,
          ),
        ),
        TextButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'See more',
                  style: textStyle(const Color(0xff0037B7), 14, FontWeight.w600),
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset('assets/icon/Icon (5).svg'),
              ],
            ))
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

class Allcollections {
  String logo;
  String topic;
  String info;
  String button;

  Allcollections({
    required this.button,
    required this.topic,
    required this.info,
    required this.logo,
  });
}

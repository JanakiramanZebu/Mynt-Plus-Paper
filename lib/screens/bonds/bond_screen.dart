 
 
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:flutter_svg/svg.dart';
import '../../provider/bond_provider.dart';

import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import 'bonds_list.dart';

class BondScreen extends StatefulWidget {
  const BondScreen({super.key});

  @override
  State<BondScreen> createState() => _BondScreenState();
}

class _BondScreenState extends State<BondScreen> {
  @override
  Widget build(BuildContext context) {
    int current = 0;
    // final CarouselController controller = CarouselController();

    return Consumer(builder: (context, ScopedReader watch, _) {
      // final theme = watch(themeProvider);

      final bondsData = watch(bondProvider);
      return
          // Scaffold(
          //   appBar: AppBar(
          //       elevation: .2,
          //       leadingWidth: 41,
          //       centerTitle: false,
          //       titleSpacing: 6,
          //       leading: const CustomBackBtn(),
          //       shadowColor: const Color(0xffECEFF3),
          //       title: Text("Bonds",
          //           style: textStyles.appBarTitleTxt.copyWith(
          //               color: theme.isDarkMode
          //                   ? colors.colorWhite
          //                   : colors.colorBlack))),
          //   body:
          ListView(children: [
        const SizedBox(height: 12),
        CarouselSlider(
          // carouselController: controller,
          options: CarouselOptions(
              autoPlay: true,
              initialPage: current,
              aspectRatio: 2.62,
              viewportFraction: 0.92,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  current = index;
                });
              }),
          items: bondsData.bondTypes
              .map((item) => Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xffEEF0F2), width: 1.5),
                      color: const Color(0xffF7F8F8),
                      borderRadius: BorderRadius.circular(6)),
                  child: Stack(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Starting invest in",
                              style: textStyle(const Color(0xff999999), 13,
                                  FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text("${item['type']}",
                              style: textStyle(
                                  colors.colorBlack, 16, FontWeight.w600)),
                          const SizedBox(height: 10),
                          Text(
                              "Handpicked bonds from our experts that meet your investment needs",
                              style: textStyle(const Color(0xff666666), 13,
                                  FontWeight.w500)),
                          const SizedBox(height: 14),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 14),
                              decoration: BoxDecoration(
                                  color: colors.colorBlack,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text("Invest Now",
                                  style: textStyle(
                                      colors.colorWhite, 14, FontWeight.w600)))
                        ]),
                    Positioned(
                        bottom: 7,
                        right: 5,
                        child: SvgPicture.asset("${item['image']}",
                            height: 60, width: 120)),
                  ])))
              .toList(),
        ),
        
        const SizedBox(height: 16),
        const BondsList()
      ]
              // ),
              );
    });
  }
}

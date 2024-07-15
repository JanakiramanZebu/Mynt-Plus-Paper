import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../res/res.dart';

import '../../../provider/stocks_provider.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_text_btn.dart'; 

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final news = watch(stocksProvide).newsModel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      color: const Color(0xffFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stocks in News",
            style: GoogleFonts.inter(
                textStyle:
                    textStyle(const Color(0xff181B19), 18, FontWeight.w600)),
          ),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: news!.length > 5 ? 5 : news.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse("${news[index].link}");
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(left: 11),
                        decoration: const BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: Color(0xff0037B7), width: 3))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${news[index].title}",
                              style: GoogleFonts.inter(
                                  textStyle: textStyle(const Color(0xff000000),
                                      14, FontWeight.w500)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${news[index].date}",
                              style: GoogleFonts.inter(
                                  textStyle: textStyle(const Color(0xff999999),
                                      10, FontWeight.w500)),
                            ),
                          ],
                        )),
                  ),
                ],
              );
            },
            separatorBuilder: (context, int index) {
              return const Divider(
                thickness: 1,
                height: 24,
                color: Color(0xffECEDEE),
              );
            },
          ),
          Container(
              margin: const EdgeInsets.only(right: 16, top: 18),
              width: MediaQuery.of(context).size.width,
              child: CustomTextBtn(
                  label: 'See more news',
                  onPress: () {
                    Navigator.pushNamed(context, Routes.allnews);
                  },
                  icon: assets.rightarrow))
        ],
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

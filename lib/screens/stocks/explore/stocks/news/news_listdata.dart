import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';
import '../../../../../sharedWidget/list_divider.dart';

class NewsListData extends ConsumerWidget {
  const NewsListData({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final news = watch(stocksProvide).newsModel!.data;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 41,
        centerTitle: false,
        titleSpacing: 0,
        leading: const CustomBackBtn(),
        elevation: .4,
        title: Text(
              "Stocks in News",
              style: GoogleFonts.inter(
                  textStyle:
                      textStyle(const Color(0xff181B19), 14, FontWeight.w600))
            )),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: news!.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: () async {
              final Uri url = Uri.parse("${news[index].link}");
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            dense: true,
            title: Text(
              "${news[index].title}",
              style: textStyle(
                  const Color(0xff000000), 14, FontWeight.w500),
            ),
            subtitle: Text(
              "${news[index].pubDate}",
              style: GoogleFonts.inter(
                  textStyle: textStyle(
                      const Color(0xff999999), 10, FontWeight.w500)),
            ),
            leading: news[index].image == "None"
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.darkGrey),
                    width: 80,
                    height: 50,
                    child: Text("MYNT +",
                        style: textStyle(const Color(0xff000000), 14,
                            FontWeight.w600)),
                  )
                : Image.network("${news[index].image}",
                    width: 80, height: 50, fit: BoxFit.fill),
          );
        },
        separatorBuilder: (context, int index) {
          return const ListDivider();
        },
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

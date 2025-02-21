import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../res/res.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../routes/route_names.dart';
import '../../../../../sharedWidget/list_divider.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final news = watch(stocksProvide).newsModel!.data;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xffFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("News",
              style: textStyle(const Color(0xff000000), 16, FontWeight.w600)),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: news!.length > 5 ? 5 : news.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final Uri url = Uri.parse("${news[index].link}");
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                dense: true,
                title: Text(
                  "${news[index].title}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      textStyle(const Color(0xff000000), 14, FontWeight.w500),
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
                        child: Text("MYNT ",
                            style: textStyle(
                                const Color(0xff000000), 14, FontWeight.w600)),
                      )
                    : Image.network("${news[index].image}",
                        width: 80, height: 50, fit: BoxFit.fill),
              );
            },
            separatorBuilder: (context, int index) {
              return const ListDivider();
            },
          ),
          Center(
            child: TextButton(
                onPressed: () async {
                  Navigator.pushNamed(context, Routes.allnews);
                },
                child: Text('See all',
                    style: GoogleFonts.inter(
                        color: const Color(0xff0037B7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600))),
          )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}

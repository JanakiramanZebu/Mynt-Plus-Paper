import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../screens/stocks/tradeAction/tradeaction_stock_details/sector_news_list.dart';
import '../../../../sharedWidget/scrollable_btn.dart';
 

class EftEventNews extends StatefulWidget {
  const EftEventNews({super.key});

  @override
  State<EftEventNews> createState() => _EftEventNewsState();
}

class _EftEventNewsState extends State<EftEventNews> {
  List<String> sectorList = [
    "This week",
    "This Month",
    "Older News",
  ];
  List<bool> isActiveBtn = [
    true,
    false,
    false,
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Events',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff000000)),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                  height: 30,
                  child: ScrollableBtn(
                      btnActive: isActiveBtn, btnName: sectorList)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24),
          child: Text(
            '12 news'.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff000000),
                letterSpacing: 0.96),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const EftNews(),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Text(
            'Load more news',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff0037B7)),
          ),
        )
      ],
    );
  }
}

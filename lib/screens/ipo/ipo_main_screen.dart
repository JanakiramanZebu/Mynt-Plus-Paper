import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../res/res.dart';
import 'invest_ipo_banner/invest_banner_ui.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'mainstream_ipo/main_stream_ipo_main_screen.dart';
import 'sme_ipo/sme_ipo_screen.dart';


class IPOScreen extends StatelessWidget {
  const IPOScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: SvgPicture.asset(assets.backArrow),
            ),
          ),
          backgroundColor: colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("IPOs", style: textStyles.appBarTitleTxt)),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            InvestIPO(),
            MainStreamIpo(),
             SMEIPO(),
            SizedBox(
              height: 20,
            ),
            IPOPerformance(),
          ],
        ),
      ),
    );
  }
}

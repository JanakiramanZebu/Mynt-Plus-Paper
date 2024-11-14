import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../provider/iop_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import 'invest_ipo_banner/invest_banner_ui.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'mainstream_ipo/main_stream_ipo_main_screen.dart';
import 'sme_ipo/sme_ipo_screen.dart';

class IPOScreen extends ConsumerWidget {
  const IPOScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                child: SvgPicture.asset(assets.backArrow,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack),
              ),
            ),
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            title: Text("IPOs",
                style: textStyles.appBarTitleTxt.copyWith(
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                )),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () async{
                        await context.read(ipoProvide).getipoorderbookmodel();
                          await context.read(ipoProvide).ipotab();
                          Navigator.pushNamed(context, Routes.ipoorderbook);
                      },
                      child: Icon(Icons.shopping_bag_outlined)))
                ],
                ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              InvestIPO(),
              MainStreamIpo(),
              SizedBox(
                height: 20,
              ),
              SMEIPO(),
              SizedBox(
                height: 20,
              ),
              IPOPerformance(),
            ],
          ),
        ),
      ),
    );
  }
}

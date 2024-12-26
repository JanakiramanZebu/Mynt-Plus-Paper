import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider/iop_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/payment_loader.dart';
import 'invest_ipo_banner/invest_banner_ui.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'main_sme_list/main_sme_list.dart';

class IPOScreen extends StatefulWidget {
  const IPOScreen({super.key});

  @override
  State<IPOScreen> createState() => _IPOScreenState();
}

class _IPOScreenState extends State<IPOScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    setState(() {
      context.read(ipoProvide).tabCtrl = TabController(
          length: context.read(ipoProvide).orderTabName.length,
          vsync: this,
          initialIndex: context.read(ipoProvide).selectedTab);

      context.read(ipoProvide).tabCtrl.addListener(() {
        context
            .read(ipoProvide)
            .changeIpoIndex(context.read(ipoProvide).tabCtrl.index, context);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      final ipo = watch(ipoProvide);
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
        
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: .2,
            centerTitle: false,
            leadingWidth: 41,
            titleSpacing: 6,
            // leading: InkWell(
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 9),
            //     child: SvgPicture.asset(assets.backArrow,
            //         color: theme.isDarkMode
            //             ? colors.colorWhite
            //             : colors.colorBlack),
            //   ),
            // ),
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            // title: Text("IPOs",
            //     style: textStyles.appBarTitleTxt.copyWith(
            //       color:
            //           theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            //     )),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 14),
                child: InkWell(
                    onTap: () async {
                      Future.delayed(const Duration(microseconds: 100),
                          () async {
                        await context
                            .read(ipoProvide)
                            .getipoorderbookmodel(true);
                        await context.read(ipoProvide).ipotab();
                      });

                      Navigator.pushNamed(context, Routes.ipoorderbook);
                    },
                    child: Stack(clipBehavior: Clip.none, children: [
                      const Icon(Icons.shopping_bag_outlined),
                      Positioned(
                        top: -6,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: colors.colorBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${ipo.openorder?.length ?? 0}',
                            style: textStyle(
                                colors.colorWhite, 9, FontWeight.w500),
                          ),
                        ),
                      ),
                    ])),
              )
            ],
            bottom: PreferredSize(
              preferredSize: Size(20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const InvestIPO(),
                  Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider,
                                  width: 0))),
                      child: TabBar(
                          tabAlignment: TabAlignment.fill,
                          indicatorSize: TabBarIndicatorSize.tab,
                          // isScrollable: true,
                          indicatorColor: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          unselectedLabelColor: const Color(0XFF777777),
                          unselectedLabelStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.28)),
                          labelColor: theme.isDarkMode
                              ? colors.colorLightBlue
                              : colors.colorBlue,
                          labelStyle: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          controller: ipo.tabCtrl,
                          tabs: ipo.orderTabName)),
                ],
              ),
            ),
          ),
          
          body: ipo.loading
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const ProgressiveDotsLoader(),
                  const SizedBox(height: 3),
                  Text('This will take a few seconds.',
                      style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
                ])
              : TabBarView(controller: ipo.tabCtrl, children: const [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // MainStreamIpo(),
                        // SMEIPO(),
                        // SizedBox(
                        //   height: 10,
                        // )
                        MainSmeListCard()
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [IPOPerformance()],
                    ),
                  )
                ]),
        ),
      );
    });
  }
}

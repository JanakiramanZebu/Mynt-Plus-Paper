import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/ipo/invest_ipo_banner/invest_banner_ui.dart';
import '../../provider/iop_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import 'preclose_ipo/preclose_ipo_screen.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'main_sme_list/main_sme_list.dart';

class IPOSubScreen extends StatefulWidget {
  const IPOSubScreen({super.key});

  @override
  State<IPOSubScreen> createState() => _IPOSubScreenState();
}

class _IPOSubScreenState extends State<IPOSubScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    // setState(() {
    // ref.read(ipoProvide).tabCtrl = TabController(
    //     length: ref.read(ipoProvide).orderTabName.length,
    //     vsync: this,
    //     initialIndex: ref.read(ipoProvide).selectedTab);

    // ref.read(ipoProvide).tabCtrl.addListener(() {
    //   context
    //       .read(ipoProvide)
    //       .changeIpoIndex(ref.read(ipoProvide).tabCtrl.index, context);
    // });

    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final ipo = ref.watch(ipoProvide);
        return Column(
          children: [
            PreferredSize(
                preferredSize: const Size(20, 80),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const InvestIPO(),
                      const SizedBox(
                        height: 13,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: OutlinedButton(
                          onPressed: () async {
                            Future.delayed(const Duration(microseconds: 100),
                                () async {
                              await ref
                                  .read(ipoProvide)
                                  .getipoorderbookmodel(true);
                              // await ref.read(ipoProvide).ipotab();
                            });

                            Navigator.pushNamed(context, Routes.ipoorderbook);
                          }, // Set an actual function or keep null for disabled state
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                Colors.white, // Button background color
                            elevation: 0,
                            side:
                                BorderSide(width: 1.2, color: colors.colorBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(50), // Rounded corners
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10), // Padding
                          ),
                          child: Container(
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Wrap content
                                children: [
                                  SvgPicture.asset(
                                    'assets/explore/firefox.svg',

                                    height: 24, // Set height
                                    width: 24, // Set width
                                  ),
                                  const SizedBox(width: 8), // Spacing
                                  Text(
                                    "View my bids",
                                    style: textStyle(
                                        colors.colorBlue, 16, FontWeight.w500),
                                  ),
                                  SizedBox(width: 8), // Spacing
                                  Icon(Icons.keyboard_arrow_down,
                                      color:
                                          colors.colorBlue), // Down arrow icon
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ])),
            const SizedBox(
              height: 12,
            ),
            Container(
              padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
              height: 52,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          width: 0),
                      top: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          width: 0))),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ipo.inIPOTabNameBtns.length,
                itemBuilder: (BuildContext context, int index) {
                  return ElevatedButton(
                      onPressed: () async {
                        ipo.chngDephBtn(ipo.inIPOTabNameBtns[index]['btnName']);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          backgroundColor: theme.isDarkMode
                              ? ipo.inIPOTabNameAct ==
                                      ipo.inIPOTabNameBtns[index]['btnName']
                                  ? colors.colorbluegrey
                                  : const Color(0xffB5C0CF).withOpacity(.15)
                              : ipo.inIPOTabNameAct ==
                                      ipo.inIPOTabNameBtns[index]['btnName']
                                  ? const Color(0xff000000)
                                  : const Color(0xffF1F3F8),
                          shape: const StadiumBorder()),
                      child: Row(children: [
                        SvgPicture.asset(
                          "${ipo.inIPOTabNameBtns[index]['imgPath']}",
                          color: theme.isDarkMode
                              ? Color(ipo.inIPOTabNameAct ==
                                      ipo.inIPOTabNameBtns[index]['btnName']
                                  ? 0xff000000
                                  : 0xffffffff)
                              : Color(ipo.inIPOTabNameAct ==
                                      ipo.inIPOTabNameBtns[index]['btnName']
                                  ? 0xffffffff
                                  : 0xff000000),
                        ),
                        const SizedBox(width: 8),
                        Text("${ipo.inIPOTabNameBtns[index]['btnName']}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? Color(ipo.inIPOTabNameAct ==
                                            ipo.inIPOTabNameBtns[index]
                                                ['btnName']
                                        ? 0xff000000
                                        : 0xffffffff)
                                    : Color(ipo.inIPOTabNameAct ==
                                            ipo.inIPOTabNameBtns[index]
                                                ['btnName']
                                        ? 0xffffffff
                                        : 0xff000000),
                                12.5,
                                FontWeight.w500))
                      ]));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 10);
                },
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 12,
                ),
                child: ListView(
                  children: [
                    if (ipo.inIPOTabNameAct == "Live / Pre Open") ...[
                      const MainSmeListCard()
                    ] else if (ipo.inIPOTabNameAct == "Closed") ...[
                      const ClosedIPOScreen()
                    ] else if (ipo.inIPOTabNameAct == "Listed") ...[
                      const IPOPerformance()
                    ],
                  ],
                ),
              ),
            ),
          ],
        );

        // GestureDetector(
        //   onTap: () => FocusScope.of(context).unfocus(),
        //   child: Scaffold(
        //     appBar: AppBar(
        //       elevation: .2,
        //       centerTitle: false,
        //       // leadingWidth: 41,
        //       // titleSpacing: 6,
        //       // leading: InkWell(
        //       //   onTap: () {
        //       //     Navigator.pop(context);
        //       //   },
        //       //   child: Padding(
        //       //     padding: const EdgeInsets.symmetric(horizontal: 9),
        //       //     child: SvgPicture.asset(assets.backArrow,
        //       //         color: theme.isDarkMode
        //       //             ? colors.colorWhite
        //       //             : colors.colorBlack),
        //       //   ),
        //       // ),
        //       backgroundColor:
        //           theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        //       shadowColor: const Color(0xffECEFF3),
        //       // title: Text("IPOs",
        //       //     style: textStyles.appBarTitleTxt.copyWith(
        //       //       color:
        //       //           theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        //       //     )),
        //       bottom: PreferredSize(
        //         preferredSize: const Size(0, 0),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisAlignment: MainAxisAlignment.start,
        //           children: [
        //             // const InvestIPO(),
        //             Container(
        //                 // padding: EdgeInsets.zero,
        //                 // decoration: BoxDecoration(
        //                 //     border: Border(
        //                 //         bottom: BorderSide(
        //                 //             color: theme.isDarkMode
        //                 //                 ? colors.darkColorDivider
        //                 //                 : colors.colorDivider,
        //                 //             width: 0))),
        //                 child: TabBar(
        //                     tabAlignment: TabAlignment.fill,
        //                     indicatorSize: TabBarIndicatorSize.tab,
        //                     // isScrollable: true,
        //                     indicatorColor: theme.isDarkMode
        //                         ? colors.colorLightBlue
        //                         : colors.colorBlue,
        //                     unselectedLabelColor: const Color(0XFF777777),
        //                     unselectedLabelStyle: GoogleFonts.inter(
        //                         textStyle: const TextStyle(
        //                             fontSize: 13,
        //                             fontWeight: FontWeight.w500,
        //                             letterSpacing: -0.28)),
        //                     labelColor: theme.isDarkMode
        //                         ? colors.colorLightBlue
        //                         : colors.colorBlue,
        //                     labelStyle: GoogleFonts.inter(
        //                         textStyle: const TextStyle(
        //                             fontSize: 14, fontWeight: FontWeight.w600)),
        //                     controller: ipo.tabCtrl,
        //                     tabs: ipo.orderTabName)),
        //           ],
        //         ),
        //       ),
        //     ),
        //     body: ipo.loading
        //         ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        //             const ProgressiveDotsLoader(),
        //             const SizedBox(height: 3),
        //             Text('This will take a few seconds.',
        //                 style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
        //           ])
        //         : TabBarView(controller: ipo.tabCtrl, children: const [
        //             SingleChildScrollView(
        //               child: Column(
        //                 children: [
        //                   MainSmeListCard()
        //                   ],
        //               ),
        //             ),
        //             SingleChildScrollView(
        //               child: Column(
        //                 children: [IPOPerformance()],
        //               ),
        //             )
        //           ]),
        //   ),
        // );
      },
    );
  }
}

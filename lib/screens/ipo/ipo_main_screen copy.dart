import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../provider/iop_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/payment_loader.dart';
import 'ipo_main_sub_screen.dart';

class IPOScreen extends ConsumerStatefulWidget {
  const IPOScreen({super.key});

  @override
  ConsumerState<IPOScreen> createState() => _IPOScreenState();
}

class _IPOScreenState extends ConsumerState<IPOScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    setState(() {
      ref.read(ipoProvide).ipoScreenTab = TabController(
          length: ref.read(ipoProvide).ipoScreenTabName.length,
          vsync: this,
          initialIndex: ref.read(ipoProvide).selectedTab);

      ref.read(ipoProvide).ipoScreenTab.addListener(() {
        ref.read(ipoProvide).changeIpoIndex(
            ref.read(ipoProvide).ipoScreenTab.index, context);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);
    // final panelController = SlidingUpPanelController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
            appBar: AppBar(
              elevation: .2,
              centerTitle: false,

              // leadingWidth: 41,
              toolbarHeight: 80,
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
              leading: Container(
                padding: EdgeInsets.only(left: 10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: SvgPicture.asset(
                    assets.myntnewLogo,
                    // color: theme.isDarkMode
                    //     ? colors.colorWhite
                    //     : colors.colorBlack
                  ),
                ),
              ),
              backgroundColor:
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              shadowColor: const Color(0xffECEFF3),
              title: Container(
                  height: 50,
                  child: SearchBar(
                    hintText: "Search",
                    backgroundColor: WidgetStateProperty.all(
                        colors.kColorLightGrey), // Gray background
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(50), // Rounded corners
                      side: BorderSide.none, // No border
                    )),
                    elevation: WidgetStateProperty.all(0), // No shadow
                    leading: const Icon(Icons.search,
                        color: Colors.black54), // Prefix icon
                  )),
              // title: Text("IPOs",
              //     style: textStyles.appBarTitleTxt.copyWith(
              //       color: theme.isDarkMode
              //           ? colors.colorWhite
              //           : colors.colorBlack,
              //     )),
              // actions: [
              //   Padding(
              //     padding: const EdgeInsets.only(right: 16, top: 14),
              // child:
              // InkWell(
              //     onTap: () async {
              //       Future.delayed(const Duration(microseconds: 100),
              //           () async {
              //         await context
              //             .read(ipoProvide)
              //             .getipoorderbookmodel(true);
              //         // await ref.read(ipoProvide).ipotab();
              //       });

              //       Navigator.pushNamed(context, Routes.ipoorderbook);
              //     },
              //     child: Stack(clipBehavior: Clip.none, children: [
              //       const Icon(Icons.shopping_bag_outlined),
              //       Positioned(
              //         top: -6,
              //         right: -5,
              //         child: Container(
              //           padding: const EdgeInsets.all(5),
              //           decoration: BoxDecoration(
              //             color: colors.colorBlue,
              //             shape: BoxShape.circle,
              //           ),
              //           child: Text(
              //             '${ipo.openorder?.length ?? 0}',
              //             style: textStyle(
              //                 colors.colorWhite, 9, FontWeight.w500),
              //           ),
              //         ),
              //       ),
              //     ])
              //     ),
              //   )
              // ],
              // bottom: const PreferredSize(
              //   preferredSize: Size(20, 80),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       InvestIPO(),
              //       // Container(
              //       //   padding: EdgeInsets.zero,
              //       //   decoration: BoxDecoration(
              //       //       border: Border(
              //       //           bottom: BorderSide(
              //       //               color: theme.isDarkMode
              //       //                   ? colors.darkColorDivider
              //       //                   : colors.colorDivider,
              //       //               width: 0))),
              //       //   child: TabBar(
              //       //       tabAlignment: TabAlignment.fill,
              //       //       indicatorSize: TabBarIndicatorSize.tab,
              //       //       // isScrollable: true,
              //       //       indicatorColor: theme.isDarkMode
              //       //           ? colors.colorLightBlue
              //       //           : colors.colorBlue,
              //       //       unselectedLabelColor: const Color(0XFF777777),
              //       //       unselectedLabelStyle: GoogleFonts.inter(
              //       //           textStyle: const TextStyle(
              //       //               fontSize: 13,
              //       //               fontWeight: FontWeight.w500,
              //       //               letterSpacing: -0.28)),
              //       //       labelColor: theme.isDarkMode
              //       //           ? colors.colorLightBlue
              //       //           : colors.colorBlue,
              //       //       labelStyle: GoogleFonts.inter(
              //       //           textStyle: const TextStyle(
              //       //               fontSize: 14, fontWeight: FontWeight.w600)),
              //       //       controller: ipo.ipoScreenTab,
              //       //       tabs: ipo.ipoScreenTabName),
              //       // ),
              //     ],
              //   ),
              // ),
            ),
            body: Stack(children: [
              ipo.loading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          const ProgressiveDotsLoader(),
                          const SizedBox(height: 3),
                          Text('This will take a few seconds.',
                              style: textStyle(
                                  colors.colorGrey, 13, 0)),
                        ])
                  : const IPOSubScreen(),

              // SlidingUpPanelWidget(
              //   controlHeight: 50,
              //   panelController: panelController,
              //   anchor: 1.0,
              //   onStatusChanged: (status) {
              //     if (status == SlidingUpPanelStatus.expanded) {
              //       ipoorderbookgetdata(context);
              //     }
              //   },
              //   child: Container(
              //     width: double.infinity,
              //     color: Colors.white,
              //     padding: EdgeInsets.all(8),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Container(
              //           width: 40,
              //           height: 5,
              //           margin: EdgeInsets.symmetric(vertical: 3),
              //           decoration: BoxDecoration(
              //             color: Colors.grey[400],
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //         ),
              //         const Text("Order Book",
              //             style: TextStyle(
              //                 fontSize: 16, fontWeight: FontWeight.bold)),
              //         const SizedBox(height: 10),
              //         ref.read(ipoProvide).displayload
              //             ? const Center(child: CircularProgressIndicator())
              //             : Expanded(
              //                 child: SingleChildScrollView(
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     mainAxisAlignment: MainAxisAlignment.start,
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       Padding(
              //                         padding: const EdgeInsets.symmetric(
              //                             horizontal: 16.0, vertical: 8),
              //                         child: Text(
              //                           "Open Orders",
              //                           style: textStyle(
              //                               theme.isDarkMode
              //                                   ? colors.colorWhite
              //                                       .withOpacity(0.3)
              //                                   : colors.colorBlack
              //                                       .withOpacity(0.3),
              //                               15,
              //                               FontWeight.w600),
              //                         ),
              //                       ),
              //                       IpoOpenOrder(open: ipo),
              //                       Padding(
              //                           padding: const EdgeInsets.symmetric(
              //                               horizontal: 16.0, vertical: 8),
              //                           child: Text(
              //                             "Closed Orders",
              //                             style: textStyle(
              //                                 theme.isDarkMode
              //                                     ? colors.colorWhite
              //                                         .withOpacity(0.3)
              //                                     : colors.colorBlack
              //                                         .withOpacity(0.3),
              //                                 15,
              //                                 FontWeight.w600),
              //                           )),
              //                       IpoCloseOrder(close: ipo)
              //                       // ]
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //       ],
              //     ),
              //   ),
              // ),
            ])

            // TabBarView(controller: ipo.ipoScreenTab, children: const [
            //     IPOSubScreen(),
            //     // IpoOrderbookMainScreen()
            //   ]),
            ),
      );
  }

  // void ipoorderbookgetdata(BuildContext context) async {
  //   Future.delayed(const Duration(microseconds: 100), () async {
  //     await ref.read(ipoProvide).getipoorderbookmodel1(true);
  //   });
  // }
}

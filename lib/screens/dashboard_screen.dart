import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';
import '../provider/stocks_provider.dart';
import 'stocks/explore/stocks/stock_screens.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _IPOmainScreenState();
}

class _IPOmainScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    setState(() {
      context.read(stocksProvide).chngTradeAct("Equity");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/icon/MYNT App Logo_v2.svg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: SearchBar(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.iposearchscreen);
                      },
                      hintText: "Search company",
                      backgroundColor: WidgetStateProperty.all(
                          colors.kColorLightGrey), // Gray background
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(50), // Rounded corners
                          side: BorderSide.none, // No border
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0), // No shadow
                      leading: const Icon(Icons.search,
                          color: Colors.black54), // Prefix icon
                    )),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 260,
                    floating: false,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                            padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
                            decoration: BoxDecoration(
                                color: const Color(0xffFAFBFF),
                                borderRadius: BorderRadius.circular(0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      top: 6, bottom: 12, left: 20),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 65, 209, 149)
                                              .withOpacity(
                                                  1.0), // #834EDA at 0% (100% opacity)
                                          Color(0xFF51FFB6), // #834EDA at 100% (50% opacity)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title: Text("Simple.\nInsightful.\nIncremental.",
                                            style: GoogleFonts.inter(
                                                textStyle: textStyle(
                                                    const Color(0xff000000),
                                                    24,
                                                    FontWeight.w900))),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add your button functionality here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22, vertical: 0),
                                          backgroundColor: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Text(
                                          "Start explore",
                                          style: TextStyle(
                                            color: theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 13),
                                // Center(
                                //   child: ElevatedButton(
                                //     onPressed: () async {
                                //       Future.delayed(
                                //           const Duration(microseconds: 100),
                                //           () async {
                                //         await context
                                //             .read(ipoProvide)
                                //             .getipoorderbookmodel(true);
                                //         // await context.read(ipoProvide).ipotab();
                                //       });

                                //       Navigator.pushNamed(
                                //           context, Routes.ipoorderbook);
                                //     },
                                //     style: ElevatedButton.styleFrom(
                                //       padding: const EdgeInsets.symmetric(
                                //           vertical: 5),
                                //       backgroundColor: Colors.white,
                                //       elevation: 0,
                                //       side: const BorderSide(
                                //           color: Color(0xFF87A1DD), width: 1.5),
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(24),
                                //       ),
                                //     ),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.max,
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       children: [
                                //         SvgPicture.asset(
                                //           'assets/explore/firefox.svg',
                                //           width: 16,
                                //           height: 16,
                                //         ),
                                //         const SizedBox(width: 8),
                                //         const Text(
                                //           "View my bids",
                                //           style: TextStyle(
                                //               color: Color(0xFF4069C9),
                                //               fontWeight: FontWeight.w600,
                                //               fontSize: 14),
                                //         ),
                                //         const Icon(
                                //           Icons.expand_more,
                                //           color: Color(0xFF4069C9),
                                //           size: 28,
                                //           weight: 7,
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ))),
                  ),
                ];
              },
              body: const StockScreen()),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   elevation: 0,
        //   // foregroundColor: customizations[index].$1,
        //   backgroundColor: Colors.black.withOpacity(0.2),
        //   child: const Icon(
        //     Icons.arrow_back_rounded,
        //     color: Colors.black,
        //     weight: 10,
        //   ),
        // )
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

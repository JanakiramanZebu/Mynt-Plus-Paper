import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../res/res.dart';
import '../../provider/mf_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import 'mf_explore_screens.dart';

class MfmainScreen extends StatefulWidget {
  const MfmainScreen({super.key});

  @override
  State<MfmainScreen> createState() => _MfmainScreenState();
}

class _MfmainScreenState extends State<MfmainScreen> {
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final mf = watch(mfProvider);
final portfolio = watch(portfolioProvider);
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              // InkWell(
              //   onTap: () {
              //     bool? value = mf.isportfolio;
              //     mf.setPortfolioIs(!value!);
              //     print("object $value");
              //   },
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
                    child: ExcludeFocus(
                      child: SearchBar(
                        onTap: (){
                          print("Pressed");
                      Navigator.pushNamed(
                        context,
                        Routes.mfsearchscreen
                      );
                        },
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
                      ),
                    ),
                  ),
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
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                            decoration: BoxDecoration(
                                color: const Color(0xffFAFBFF),
                                borderRadius: BorderRadius.circular(0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (portfolio.mfTotInveest > 0) ...[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                "Mutual funds",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF2F3A9F),
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                portfolio.mfTotCurrentVal.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Current Value",
                                style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              const Divider(
                                color: Color.fromARGB(255, 216, 212, 212),
                                thickness: 0.5,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Total Invested",
                                          style: TextStyle(
                                              color: Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Text(portfolio.mfTotInveest.toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Total Return",
                                          style: TextStyle(
                                              color: Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Text(portfolio.mfTotalPnl.toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Return %",
                                          style: TextStyle(
                                              color: Color(0xFF666666),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Text("${portfolio.mfTotalPnlPerchng.toStringAsFixed(2)}%",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFFF1717))),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 22),
                                    ],
                                  )
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 6, bottom: 12, left: 20),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF3E6742).withOpacity(
                                                1.0), // #834EDA at 0% (100% opacity)
                                            const Color(0xFF3E6742).withOpacity(
                                                0.5), // #834EDA at 100% (50% opacity)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        ListTile(
                                          contentPadding: const EdgeInsets.all(0),
                                          title: Text("Mutual Funds",
                                              style: GoogleFonts.inter(
                                                  textStyle: textStyle(
                                                      const Color(0xffFEFDFD),
                                                      22,
                                                      FontWeight.w700))),
                                          subtitle: Column(
                                            children: [
                                              const SizedBox(height: 6),
                                              Text(
                                                  "Invest in newly listed companies to grow wealth and diversify your portfolio.",
                                                  style: GoogleFonts.inter(
                                                      textStyle: textStyle(
                                                          const Color.fromARGB(
                                                              255,
                                                              246,
                                                              242,
                                                              255),
                                                          14,
                                                          FontWeight.w500))),
                                            ],
                                          ),
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
                                            "Start Investing",
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
                                  const SizedBox(height: 16),
                                ],
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async{
                                      await mf.fetchMfOrderbook(context);
                                      await portfolio.fetchMFHoldings(context);
                                      Navigator.pushNamed(context, Routes.mfOrderbookscreen);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      side: const BorderSide(
                                          color: Color(0xFF87A1DD), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/explore/firefox.svg',
                                          width: 16,
                                          height: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "View my portfolio / orders",
                                          style: TextStyle(
                                              color: Color(0xFF4069C9),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        const Icon(
                                          Icons.expand_more,
                                          color: Color(0xFF4069C9),
                                          size: 28,
                                          weight: 7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ))),
                  ),
                ];
              },
              body: MFExploreScreens(theme: theme)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          elevation: 0,
          // foregroundColor: customizations[index].$1,
          backgroundColor: Colors.black.withOpacity(0.2),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            weight: 10,
          ),
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

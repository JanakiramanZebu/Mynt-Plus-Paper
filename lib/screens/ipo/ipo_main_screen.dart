import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/screens/ipo/ipo_explore_screens.dart';
import '../../../res/res.dart';
import '../../provider/iop_provider.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';

class IPOScreen extends StatefulWidget {
  const IPOScreen({super.key});

  @override
  State<IPOScreen> createState() => _IPOmainScreenState();
}

class _IPOmainScreenState extends State<IPOScreen> {
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);

      return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
               color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                size: 22,
              ),
            ),
          ),
          elevation: 0,
          // leadingWidth: 40,
          centerTitle: false,
          titleSpacing: -8,
          shadowColor: const Color(0xffECEFF3),
          title: Padding(
            padding: const EdgeInsets.only(
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                   

                    
                    child: SearchBar(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pushNamed(context, Routes.iposearchscreen);
                      },
                      hintText: "Search IPO",
                      hintStyle: WidgetStateProperty.all(
                        TextStyle(
                          color: Color(0xff69758F), // Change hint text color
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all(theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide.none, 
                        ),
                      ),
                      textStyle: WidgetStateProperty.all(
                       textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500),
                      ),
                      elevation: WidgetStateProperty.all(0),
                      leading:
                      
                      //  Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8),
                      //   child: Container(
                      //     child: const Icon(
                      //       Icons.search,
                      //       color: Colors.black54,
                      //     ),
                      //   ),
                      // ),

                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: SvgPicture.asset(assets.searchIcon,
                            color: const Color(0xff586279),
                            fit: BoxFit.contain,
                            width: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: IpoExploreScreens(theme: theme),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

      // body: SafeArea(
      //   child: NestedScrollView(
      //       headerSliverBuilder:
      //           (BuildContext context, bool innerBoxIsScrolled) {
      //         return [
      //           SliverAppBar(
      //             automaticallyImplyLeading: false,
      //             expandedHeight: 260,
      //             floating: false,
      //             pinned: false,
      //             flexibleSpace: FlexibleSpaceBar(
      //                 background: Container(
      //                     padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      //                     decoration: BoxDecoration(
      //                         color: const Color(0xffFAFBFF),
      //                         borderRadius: BorderRadius.circular(0)),
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         // Container(
      //                         //   padding: const EdgeInsets.only(
      //                         //       top: 6, bottom: 12, left: 20),
      //                         //   decoration: BoxDecoration(
      //                         //       gradient: LinearGradient(
      //                         //         colors: [
      //                         //           Color(0xFF834EDA).withOpacity(
      //                         //               1.0), // #834EDA at 0% (100% opacity)
      //                         //           Color(0xFF834EDA).withOpacity(
      //                         //               0.5), // #834EDA at 100% (50% opacity)
      //                         //         ],
      //                         //         begin: Alignment.topCenter,
      //                         //         end: Alignment.bottomCenter,
      //                         //       ),
      //                         //       borderRadius:
      //                         //           BorderRadius.circular(16)),
      //                         //   child: Column(
      //                         //     crossAxisAlignment:
      //                         //         CrossAxisAlignment.start,
      //                         //     children: [
      //                         //       const SizedBox(height: 12),
      //                         //       ListTile(
      //                         //         contentPadding: EdgeInsets.all(0),
      //                         //         title: Text("Invest in IPOs",
      //                         //             style: GoogleFonts.inter(
      //                         //                 textStyle: textStyle(
      //                         //                     const Color(0xffFEFDFD),
      //                         //                     22,
      //                         //                     FontWeight.w700))),
      //                         //         subtitle: Column(
      //                         //           children: [
      //                         //             const SizedBox(height: 6),
      //                         //             Text(
      //                         //                 "Invest in newly listed companies to grow wealth and diversify your portfolio.",
      //                         //                 style: GoogleFonts.inter(
      //                         //                     textStyle: textStyle(
      //                         //                         const Color.fromARGB(
      //                         //                             255,
      //                         //                             246,
      //                         //                             242,
      //                         //                             255),
      //                         //                         14,
      //                         //                         FontWeight.w500))),
      //                         //           ],
      //                         //         ),
      //                         //       ),
      //                         //       const SizedBox(height: 10),
      //                         //       ElevatedButton(
      //                         //         onPressed: () {
      //                         //           // Add your button functionality here
      //                         //         },
      //                         //         style: ElevatedButton.styleFrom(
      //                         //           elevation: 0,
      //                         //           padding: const EdgeInsets.symmetric(
      //                         //               horizontal: 22, vertical: 0),
      //                         //           backgroundColor: theme.isDarkMode
      //                         //               ? colors.colorWhite
      //                         //               : colors.colorBlack,
      //                         //           shape: RoundedRectangleBorder(
      //                         //             borderRadius:
      //                         //                 BorderRadius.circular(50),
      //                         //           ),
      //                         //         ),
      //                         //         child: Text(
      //                         //           "Apply for an IPO",
      //                         //           style: TextStyle(
      //                         //             color: theme.isDarkMode
      //                         //                 ? colors.colorBlack
      //                         //                 : colors.colorWhite,
      //                         //             fontWeight: FontWeight.w700,
      //                         //           ),
      //                         //         ),
      //                         //       ),
      //                         //     ],
      //                         //   ),
      //                         // ),
      //                         const SizedBox(height: 13),
      //                         Center(
      //                           child: ElevatedButton(
      //                             onPressed: () async {
      //                           Future.delayed(const Duration(microseconds: 100),
      //                                 () async {
      //                               await context
      //                                   .read(ipoProvide)
      //                                   .getipoorderbookmodel(true);
      //                               // await context.read(ipoProvide).ipotab();
      //                             });

      //                               Navigator.pushNamed(
      //                                   context, Routes.ipoorderbook);
      //                             },
      //                             style: ElevatedButton.styleFrom(
      //                               padding: const EdgeInsets.symmetric(
      //                                   vertical: 5),
      //                               backgroundColor: Colors.white,
      //                               elevation: 0,
      //                               side: const BorderSide(
      //                                   color: Color(0xFF87A1DD),
      //                                   width: 1.5),
      //                               shape: RoundedRectangleBorder(
      //                                 borderRadius:
      //                                     BorderRadius.circular(24),
      //                               ),
      //                             ),
      //                             child: Row(
      //                               mainAxisSize: MainAxisSize.max,
      //                               mainAxisAlignment:
      //                                   MainAxisAlignment.center,
      //                               children: [
      //                                 SvgPicture.asset(
      //                                   'assets/explore/firefox.svg',
      //                                   width: 16,
      //                                   height: 16,
      //                                 ),
      //                                 const SizedBox(width: 8),
      //                                 const Text(
      //                                   "View my bids",
      //                                   style: TextStyle(
      //                                       color: Color(0xFF4069C9),
      //                                       fontWeight: FontWeight.w600,
      //                                       fontSize: 14),
      //                                 ),
      //                                 const Icon(
      //                                   Icons.expand_more,
      //                                   color: Color(0xFF4069C9),
      //                                   size: 28,
      //                                   weight: 7,
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ))),
      //           ),
      //         ];
      //       },
      //
      // ),
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

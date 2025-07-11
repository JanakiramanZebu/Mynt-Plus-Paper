import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/screens/bonds/bonds_explore_screens.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';

class BondsScreen extends ConsumerStatefulWidget {
  const BondsScreen({super.key});

  @override
  ConsumerState<BondsScreen> createState() => _BondsmainScreenState();
}

class _BondsmainScreenState extends ConsumerState<BondsScreen> {
  // Static constants for better performance
  static const double _iconSize = 22.0;
  static const double _searchBarHeight = 45.0;
  static const double _searchBarBorderRadius = 25.0;
  static const double _searchBarFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bondsProvider).fetchAllBonds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      // appBar: _buildAppBar(context, theme),
      body: BondsExploreScreens(theme: theme),
    );
  }
}





// NestedScrollView(
//                 headerSliverBuilder:
//                     (BuildContext context, bool innerBoxIsScrolled) {
//                   return [
//                     SliverAppBar(
//                       automaticallyImplyLeading: false,
//                       expandedHeight: 260,
//                       floating: false,
//                       pinned: false,
//                       flexibleSpace: FlexibleSpaceBar(
//                           background: Container(
//                               padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
//                               decoration: BoxDecoration(
//                                   color: const Color(0xffFAFBFF),
//                                   borderRadius: BorderRadius.circular(0)),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.only(
//                                         top: 6, bottom: 12, left: 20),
//                                     decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             const Color(0xFF148564).withOpacity(
//                                                 1.0), // #834EDA at 0% (100% opacity)
//                                             const Color(0xFF148564).withOpacity(
//                                                 0.5), // #834EDA at 100% (50% opacity)
//                                           ],
//                                           begin: Alignment.topCenter,
//                                           end: Alignment.bottomCenter,
//                                         ),
//                                         borderRadius:
//                                             BorderRadius.circular(16)),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(height: 12),
//                                         ListTile(
//                                           contentPadding: EdgeInsets.all(0),
//                                           title: Text("Invest in Bonds",
//                                               style: GoogleFonts.inter(
//                                                   textStyle: textStyle(
//                                                       const Color(0xffFEFDFD),
//                                                       22,
//                                                       FontWeight.w700))),
//                                           subtitle: Column(
//                                             children: [
//                                               const SizedBox(height: 6),
//                                               Text(
//                                                   "Handpicked bonds from our experts that meet your investment needs.",
//                                                   style: GoogleFonts.inter(
//                                                       textStyle: textStyle(
//                                                           const Color.fromARGB(
//                                                               255,
//                                                               246,
//                                                               242,
//                                                               255),
//                                                           14,
//                                                           FontWeight.w500))),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 10),
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             // Add your button functionality here
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             elevation: 0,
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 22, vertical: 0),
//                                             backgroundColor: theme.isDarkMode
//                                                 ? colors.colorWhite
//                                                 : colors.colorBlack,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(50),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             "Invest in Bonds",
//                                             style: TextStyle(
//                                               color: theme.isDarkMode
//                                                   ? colors.colorBlack
//                                                   : colors.colorWhite,
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 13),
//                                   Center(
//                                     child: ElevatedButton(
//                                       onPressed: () async {
//                                     Future.delayed(const Duration(microseconds: 100),
//                                           () async {
//                                         await context
//                                             .read(bondsProvider)
//                                             .fetchBondsOrderBook();
//                                       });

//                                         Navigator.pushNamed(
//                                             context, Routes.bondsorderbook);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 5),
//                                         backgroundColor: Colors.white,
//                                         elevation: 0,
//                                         side: const BorderSide(
//                                             color: Color(0xFF87A1DD),
//                                             width: 1.5),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(24),
//                                         ),
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.max,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SvgPicture.asset(
//                                             'assets/explore/firefox.svg',
//                                             width: 16,
//                                             height: 16,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           const Text(
//                                             "View my bids",
//                                             style: TextStyle(
//                                                 color: Color(0xFF4069C9),
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14),
//                                           ),
//                                           const Icon(
//                                             Icons.expand_more,
//                                             color: Color(0xFF4069C9),
//                                             size: 28,
//                                             weight: 7,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ))),
//                     ),
//                   ];
//                 },
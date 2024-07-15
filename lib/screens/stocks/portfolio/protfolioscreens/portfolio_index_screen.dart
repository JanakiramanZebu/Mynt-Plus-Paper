// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/portfolio/protfolioscreens/protfolio_details/Portfolio_price_chart.dart';
// import '../../../../screens/stocks/portfolio/protfolioscreens/protfolio_details/portfolio_bulk_deals.dart';
// import '../../../../screens/stocks/portfolio/protfolioscreens/protfolio_details/portfolio_holdings.dart';
// import '../../../../screens/stocks/portfolio/protfolioscreens/protfolio_details/portfolio_overview.dart';

// class PortfolioIndexScreen extends StatefulWidget {
//   const PortfolioIndexScreen({super.key});

//   @override
//   State<PortfolioIndexScreen> createState() => _PortfolioIndexScreenState();
// }

// class _PortfolioIndexScreenState extends State<PortfolioIndexScreen> {
//   List<String> chartDuration = ["1M", "3M", "6M", "1YR", "3YR", "MAX"];
//   List<bool> isActiveBtn = [true, false, false, false, false, false];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         elevation: 0,
//         leadingWidth: 35,
//         backgroundColor: const Color(0xffFFFFFF),
//         iconTheme: IconThemeData(
//           color: Colors.grey[800],
//         ),
//         shadowColor: const Color(0xffECEFF3),
//         title: Text(
//           'Superstar Portfolio Details',
//           style: textStyle(const Color(0xff000000), 14, FontWeight.w600),
//         ),
//         actions: [
//           SvgPicture.asset(assets.filterlines),
//           const SizedBox(
//             width: 12,
//           ),
//           SvgPicture.asset(assets.searchIcon),
//           const SizedBox(
//             width: 12,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                   color: Color(0xffFAFBFF),
//                   border: Border(
//                       bottom: BorderSide(color: Color(0xffEEF0F2)),
//                       top: BorderSide(color: Color(0xffEEF0F2)))),
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: ListTile(
//                 leading: Image.asset(assets.superstar),
//                 title: Text(
//                   'Ashish Kacholia\'s',
//                   style:
//                       textStyle(const Color(0xff000000), 15, FontWeight.w600),
//                 ),
//                 subtitle: Column(
//                   children: [
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(4),
//                               color: const Color(0xffFFFFFF)),
//                           child: Text(
//                             'Superstar'.toUpperCase(),
//                             style: GoogleFonts.inter(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666),
//                                 letterSpacing: 1.1),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 4,
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(4),
//                               color: const Color(0xffFFFFFF)),
//                           child: Text(
//                             'Longterm'.toUpperCase(),
//                             style: GoogleFonts.inter(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xff666666),
//                                 letterSpacing: 1.1),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const PortfolioPriceChart(),
//             const PortfolioOverview(),
//             const PortfolioHoldings(),
//             const PortfolioBulk()
//           ],
//         ),
//       ),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     );
//   }
// }

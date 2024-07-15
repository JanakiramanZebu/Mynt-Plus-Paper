// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../model/action_trade_model.dart';
// import '../../../../res/res.dart';
// import '../../../../screens/stocks/tradeAction/trade_manage_price_alert.dart';

// class TradeSetTradeAlert extends StatefulWidget {
//   final ActionTradeModel tradedata;
//   const TradeSetTradeAlert({super.key, required this.tradedata});

//   @override
//   State<TradeSetTradeAlert> createState() => _TradeSetTradeAlertState();
// }

// class _TradeSetTradeAlertState extends State<TradeSetTradeAlert> {
//   TextEditingController addtraget = TextEditingController();
//   final List<String> items = [
//     'Item1',
//     'Item2',
//     'Item3',
//     'Item4',
//     'Item5',
//     'Item6',
//     'Item7',
//     'Item8',
//   ];
//   String? selectedValue;
//   String? selectedValues;
//   String? selectedValuess;
//   bool isexpand = true;
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: const Color(0xffFFFFFF),
//       appBar: AppBar(
//         elevation: .3,
//         shadowColor: const Color(0xffECEFF3),
//         backgroundColor: const Color(0xffFFFFFF),
//         iconTheme: const IconThemeData(color: Color(0xff000000)),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               width: screenWidth,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               decoration: const BoxDecoration(color: Color(0xffFAFBFF)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${widget.tradedata.tsym}',
//                     style: GoogleFonts.inter(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.32,
//                         color: const Color(0xff000000)),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   Text(
//                     '₹${widget.tradedata.ltp}',
//                     style: GoogleFonts.inter(
//                         color: const Color(0xff000000),
//                         textStyle: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         )),
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     '22.00(${widget.tradedata.perChange}%)',
//                     style: GoogleFonts.inter(
//                         color: widget.tradedata.perChange!.startsWith('-')
//                             ? const Color(0xffFF1717)
//                             : const Color(0xff43A833),
//                         textStyle: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         )),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     'Alert me',
//                     style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: const Color(0xff000000),
//                         fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   SizedBox(
//                     height: 44,
//                     width: screenWidth,
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton2<String>(
//                         isExpanded: true,
//                         hint: Text(
//                           ' Greater than equal to',
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xff000000),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         items: items
//                             .map((String item) => DropdownMenuItem<String>(
//                                   value: item,
//                                   child: Text(
//                                     item,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xff000000),
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ))
//                             .toList(),
//                         value: selectedValue,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedValue = value;
//                           });
//                         },
//                         // buttonStyleData: ButtonStyleData(
//                         //   padding: const EdgeInsets.symmetric(
//                         //     horizontal: 14,
//                         //   ),
//                         //   decoration: BoxDecoration(
//                         //     borderRadius: BorderRadius.circular(24),
//                         //     color: const Color(0xffF1F3F8),
//                         //   ),
//                         //   elevation: 0,
//                         // ),
//                         // iconStyleData: const IconStyleData(
//                         //   icon: Icon(
//                         //     Icons.arrow_forward_ios_outlined,
//                         //   ),
//                         //   iconSize: 14,
//                         //   iconEnabledColor: Color(0xff666666),
//                         //   iconDisabledColor: Color(0xff666666),
//                         // ),
//                         // dropdownStyleData: DropdownStyleData(
//                         //   maxHeight: 200,
//                         //   width: 350,
//                         //   // padding: const EdgeInsets.symmetric(horizontal: 16),
//                         //   decoration: BoxDecoration(
//                         //     borderRadius: BorderRadius.circular(14),
//                         //     color: const Color(0xffFFFFFF),
//                         //   ),
//                         //   offset: const Offset(5, 0),
//                         //   scrollbarTheme: ScrollbarThemeData(
//                         //     radius: const Radius.circular(40),
//                         //     thickness: MaterialStateProperty.all(6),
//                         //     thumbVisibility: MaterialStateProperty.all(true),
//                         //   ),
//                         // ),
//                         // menuItemStyleData: const MenuItemStyleData(
//                         //   height: 40,
//                         //   padding: EdgeInsets.only(left: 14, right: 14),
//                         // ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Divider(
//                     color: Color(0xffF1F2F4),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     'Enter Value',
//                     style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: const Color(0xff000000),
//                         fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   SizedBox(
//                     height: 44,
//                     width: screenWidth,
//                     child: TextFormField(
//                       controller: addtraget,
//                       style: textStyle(
//                           const Color(0xff000000), 16, FontWeight.w600),
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                           fillColor: const Color(0xffF1F3F8),
//                           filled: true,
//                           hintText: "1,288.90",
//                           hintStyle: textStyle(
//                               const Color(0xff999999), 16, FontWeight.w600),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 16),
//                           labelStyle: GoogleFonts.inter(
//                               textStyle: textStyle(const Color(0xff000000), 16,
//                                   FontWeight.w600)),
//                           prefixIconColor: const Color(0xff586279),
//                           prefix: SvgPicture.asset(
//                             assets.ruppeIcon,
//                             fit: BoxFit.scaleDown,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(30)),
//                           disabledBorder: InputBorder.none,
//                           focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(30)),
//                           border: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                               borderRadius: BorderRadius.circular(30))),
//                       onChanged: (value) {},
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 4,
//                   ),
//                   Text(
//                     'Value cannot be 0',
//                     style: GoogleFonts.inter(
//                         fontSize: 10,
//                         color: const Color(0xff666666),
//                         fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Divider(
//                     color: Color(0xffF1F2F4),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     'Type',
//                     style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: const Color(0xff000000),
//                         fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   SizedBox(
//                     height: 44,
//                     width: screenWidth,
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton2<String>(
//                         isExpanded: true,
//                         hint: Text(
//                           ' Last Traded Price',
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xff000000),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         items: items
//                             .map((String item) => DropdownMenuItem<String>(
//                                   value: item,
//                                   child: Text(
//                                     item,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xff000000),
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ))
//                             .toList(),
//                         value: selectedValues,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedValues = value;
//                           });
//                         },
//                         // buttonStyleData: ButtonStyleData(
//                         //   padding: const EdgeInsets.symmetric(
//                         //     horizontal: 14,
//                         //   ),
//                         //   decoration: BoxDecoration(
//                         //     borderRadius: BorderRadius.circular(24),
//                         //     color: const Color(0xffF1F3F8),
//                         //   ),
//                         //   elevation: 0,
//                         // ),
//                         // iconStyleData: const IconStyleData(
//                         //   icon: Icon(
//                         //     Icons.arrow_forward_ios_outlined,
//                         //   ),
//                         //   iconSize: 14,
//                         //   iconEnabledColor: Color(0xff666666),
//                         //   iconDisabledColor: Color(0xff666666),
//                         // ),
//                         // dropdownStyleData: DropdownStyleData(
//                         //   maxHeight: 200,
//                         //   width: 350,
//                         //   decoration: BoxDecoration(
//                         //     borderRadius: BorderRadius.circular(14),
//                         //     color: const Color(0xffFFFFFF),
//                         //   ),
//                         //   offset: const Offset(10, 0),
//                         //   scrollbarTheme: ScrollbarThemeData(
//                         //     radius: const Radius.circular(40),
//                         //     thickness: MaterialStateProperty.all(6),
//                         //     thumbVisibility: MaterialStateProperty.all(true),
//                         //   ),
//                         // ),
//                         // menuItemStyleData: const MenuItemStyleData(
//                         //   height: 40,
//                         //   padding: EdgeInsets.only(left: 14, right: 14),
//                         // ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Divider(
//                     color: Color(0xffF1F2F4),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     'Validity',
//                     style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: const Color(0xff000000),
//                         fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   SizedBox(
//                     height: 44,
//                     width: screenWidth,
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton2<String>(
//                         isExpanded: true,
//                         hint: Text(
//                           ' Good Till Trigger',
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xff000000),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         items: items
//                             .map((String item) => DropdownMenuItem<String>(
//                                   value: item,
//                                   child: Text(
//                                     item,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xff000000),
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ))
//                             .toList(),
//                         value: selectedValuess,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedValuess = value;
//                           });
//                         },
//                         //   buttonStyleData: ButtonStyleData(
//                         //     padding: const EdgeInsets.symmetric(
//                         //       horizontal: 14,
//                         //     ),
//                         //     decoration: BoxDecoration(
//                         //       borderRadius: BorderRadius.circular(24),
//                         //       color: const Color(0xffF1F3F8),
//                         //     ),
//                         //     elevation: 0,
//                         //   ),
//                         //   iconStyleData: const IconStyleData(
//                         //     icon: Icon(
//                         //       Icons.arrow_forward_ios_outlined,
//                         //     ),
//                         //     iconSize: 14,
//                         //     iconEnabledColor: Color(0xff666666),
//                         //     iconDisabledColor: Color(0xff666666),
//                         //   ),
//                         //   dropdownStyleData: DropdownStyleData(
//                         //     maxHeight: 200,
//                         //     width: 350,
//                         //     padding: const EdgeInsets.symmetric(horizontal: 16),
//                         //     decoration: BoxDecoration(
//                         //       borderRadius: BorderRadius.circular(14),
//                         //       color: const Color(0xffFFFFFF),
//                         //     ),
//                         //     offset: const Offset(30, 0),
//                         //     scrollbarTheme: ScrollbarThemeData(
//                         //       radius: const Radius.circular(40),
//                         //       thickness: MaterialStateProperty.all(6),
//                         //       thumbVisibility: MaterialStateProperty.all(true),
//                         //     ),
//                         //   ),
//                         //   menuItemStyleData: const MenuItemStyleData(
//                         //     height: 40,
//                         //     padding: EdgeInsets.only(left: 14, right: 14),
//                         //   ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   SizedBox(
//                     width: screenWidth,
//                     height: 45,
//                     child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           elevation: 0,
//                           backgroundColor: const Color(0xff000000),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30)),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const ManagePriceAlert()));
//                         },
//                         child: Text(
//                           'Set my alert',
//                           style: GoogleFonts.inter(
//                               letterSpacing: 0.28,
//                               fontSize: 14,
//                               color: const Color(0xffFFFFFF),
//                               fontWeight: FontWeight.w600),
//                         )),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   TextStyle textStyle(Color color, double fontSize, fWeight) {
//     return GoogleFonts.inter(
//         textStyle: TextStyle(
//       fontWeight: fWeight,
//       color: color,
//       fontSize: fontSize,
//     ));
//   }
// }

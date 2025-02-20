// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:mynt_plus/models/mf_model/mf_orderbook_lumpsum_model.dart';
// import '../../provider/mf_provider.dart';
// import '../../provider/thems.dart';
// import '../../res/res.dart';
// import '../../sharedWidget/functions.dart';

// class XsipAlertCancelResoneAlert extends StatefulWidget {
//   final XsipPurchaseNotListed mfdata;
//   const XsipAlertCancelResoneAlert({super.key, required this.mfdata});

//   @override
//   State<XsipAlertCancelResoneAlert> createState() =>
//       _XsipAlertCancelResoneAlertState();
// }

// class _XsipAlertCancelResoneAlertState
//     extends State<XsipAlertCancelResoneAlert> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final theme = watch(themeProvider);
//       // final fund = watch(fundProvider);
//       final mfOrder = watch(mfProvider);
//       return AlertDialog(
//         backgroundColor: theme.isDarkMode
//             ? const Color.fromARGB(255, 18, 18, 18)
//             : colors.colorWhite,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10))),
//         scrollable: true,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//         titlePadding: const EdgeInsets.all(0),
//         title: Padding(
//           padding: const EdgeInsets.all(10),
//           child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
//         ),
//         content: Column(
//           children: [
//             Text("Are you sure you want to cancel order?",
//                 textAlign: TextAlign.center,
//                 style: textStyle(
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//                     16,
//                     FontWeight.w600)),
//             const SizedBox(
//               height: 15,
//             ),
//             DropdownButtonHideUnderline(
//                 child: DropdownButton2(
//                     menuItemStyleData: MenuItemStyleData(
//                         customHeights: mfOrder.xsipCustHeight()),
//                     buttonStyleData: const ButtonStyleData(
//                         height: 36,
//                         decoration: BoxDecoration(
//                             color: Color(0xffF1F3F8),
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(32)))),
//                     dropdownStyleData: DropdownStyleData(
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       offset: const Offset(0, 8),
//                     ),
//                     isExpanded: true,
//                     style:
//                         textStyle(const Color(0XFF000000), 13, FontWeight.w500),
//                     hint: Text(mfOrder.xsipvalue,
//                         style: textStyle(
//                             const Color(0XFF000000), 13, FontWeight.w500)),
//                     items: mfOrder.xsipDividers(),
//                     value: mfOrder.xsipvalue,
//                     onChanged: (value) async {
//                       mfOrder.chngxsip("$value");
//                     })),
//           ],
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor: const Color(0xffF1F3F8),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         )),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text("No",
//                         style:
//                             textStyle(colors.colorGrey, 12, FontWeight.w600))),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor: theme.isDarkMode
//                             ? colors.colorbluegrey
//                             : colors.colorBlack,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         )),
//                     onPressed: () async {
//                       mfOrder.fetchXsipcancel(
//                           context,
//                           widget.mfdata.orderNumber.toString(),
//                           widget.mfdata.internalRefNo.toString(),
//                           mfOrder.xsipcaseno,
//                           "");
                     
//                     },
//                     child: Text("Yes",
//                         style: textStyle(
//                             theme.isDarkMode
//                                 ? colors.colorBlack
//                                 : colors.colorWhite,
//                             12,
//                             FontWeight.w600))),
//               )
//             ],
//           ),
//         ],
//       );
//     });
//   }
// }

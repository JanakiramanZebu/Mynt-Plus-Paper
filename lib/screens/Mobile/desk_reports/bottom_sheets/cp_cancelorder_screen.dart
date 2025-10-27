// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mynt_plus/provider/ledger_provider.dart';
// import 'package:mynt_plus/sharedWidget/functions.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../provider/profile_all_details_provider.dart';
// import '../../../provider/thems.dart';
// import '../../../provider/fund_provider.dart';
// import '../../../res/global_state_text.dart';
// import '../../../res/res.dart';
// import '../../../sharedWidget/cust_text_formfield.dart';
// import '../../../sharedWidget/snack_bar.dart';

// class cancelOrderScreenCopAction extends StatefulWidget {
//   final dynamic data;
//   const cancelOrderScreenCopAction({super.key, required this.data});

//   @override
//   State<cancelOrderScreenCopAction> createState() =>
//       _cancelOrderScreenCopAction();
// }

// class DropdownItem {
//   final String value;
//   final String label;
//   final bool isEnabled;

//   DropdownItem({
//     required this.value,
//     required this.label,
//     this.isEnabled = true,
//   });
// }

// class _cancelOrderScreenCopAction extends State<cancelOrderScreenCopAction> {
//   @override
//   Widget build(BuildContext context) {
   

//     return Consumer(builder: (context, WidgetRef ref, _) {
//       final ledgerprovider = ref.watch(ledgerProvider);
//       final theme = ref.read(themeProvider);

//       // final myController = TextEditingController(text: ledgerprovider.selectnetpledge.text);
//       // String selectedValue = ledgerprovider.segmentvalue;

// // Optional: remove duplicates if needed (based on value)
//       final seen = <String>{};

//       return WillPopScope(
//         onWillPop: () async {
//           if (ledgerprovider.listforpledge == []) {
//             ledgerprovider.changesegvaldummy('');
//           }
//           Navigator.pop(context);
//           return true;
//         },
//         child: SingleChildScrollView(
//           child: Container(
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 color: theme.isDarkMode
//                     ? const Color(0xFF121212)
//                     : const Color(0xFFF1F3F8)),
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Column(
//                 children: [
//                   TextWidget.subText(
//                       text: "Do you want to Cancel this order?",
//                       theme: theme.isDarkMode,
//                       color: theme.isDarkMode
//                           ? colors.textSecondaryDark
//                           : colors.textPrimaryLight,
//                       fw: 3),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: () async {
//                         ledgerprovider.putordercopaction(
//                             ledgerprovider.selectvalueofcpaction,
//                             widget.data?.symbol ?? '',
//                             widget.data?.exchange ?? '',
//                             widget.data?.issueType ?? '',
//                             widget.data?.bidqty ?? '',
//                             widget.data?.orderprice ?? '',
//                             context,
//                             'CR',
//                             widget.data?.appno ?? '',
//                           );
//                       },
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: const Size(0, 45), // width, height
//                         side: BorderSide(
//                             color: colors
//                                 .btnOutlinedBorder), // Outline border color
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         backgroundColor:
//                             colors.primaryDark, // Transparent background
//                       ),
//                       child: TextWidget.titleText(
//                         text: "Cancel",
//                         color: colors.colorWhite,
//                         theme: theme.isDarkMode,
//                         fw: 2,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ]),
//           ),
//         ),
//       );
//     });
//   }
// }

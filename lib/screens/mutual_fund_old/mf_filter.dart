// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../provider/thems.dart';
// import '../../res/res.dart';
// import '../../sharedWidget/custom_drag_handler.dart';
// import 'mf_filter_widget/amc_filter.dart';
// import 'mf_filter_widget/min_purchase_amt.dart';
// import 'mf_filter_widget/sub_catgory_filter.dart';

// class MfFilterscreen extends StatelessWidget {
//   const MfFilterscreen({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final theme = watch(themeProvider);
//       return Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             color: theme.isDarkMode ? Colors.black : Colors.white,
//             boxShadow: const [
//               BoxShadow(
//                   color: Color(0xff999999),
//                   blurRadius: 4.0,
//                   offset: Offset(2.0, 0.0))
//             ]),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CustomDragHandler(),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Sort by",
//                       style: textStyles.appBarTitleTxt.copyWith(
//                           color:
//                               theme.isDarkMode ? Colors.white : Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//               Divider(
//                   color: theme.isDarkMode
//                       ? colors.darkColorDivider
//                       : colors.colorDivider),
//               const SubCatgoryFilter(),
//               const AmcFIlter(),
//               const MinPurchaseAmt(),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

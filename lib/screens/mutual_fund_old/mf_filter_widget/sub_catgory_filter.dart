// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/sharedWidget/functions.dart';

// import '../../../provider/mf_provider.dart';

// class SubCatgoryFilter extends ConsumerWidget {
//   const SubCatgoryFilter({super.key});
  

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final mf = watch(mfProvider);
//     return ExpansionTile(
//       title: Text(
//         "Sub category",
//         style: textStyle(colors.colorBlack, 14, FontWeight.w500),
//       ),
//       children: mf.uniqueList!
//           .map(
//             (child) => ListTile(
//               onTap: () {
//                 mf.selectedSubCat(child);
//                 mf.updateFilteredMF(false);
//               },
//               minLeadingWidth: 0,
//               title: Padding(
//                 padding: const EdgeInsets.only(bottom: 6.8),
//                 child: Text(
//                   child,
//                   style: textStyle(colors.colorBlack, 15, FontWeight.w500),
//                 ),
//               ),
//               leading: SvgPicture.asset(mf.subcatselected.contains(child)
//                   ? assets.checkedbox
//                   : assets.checkbox),
//             ),
//           )
//           .toList(),
//     );
//   }
// }

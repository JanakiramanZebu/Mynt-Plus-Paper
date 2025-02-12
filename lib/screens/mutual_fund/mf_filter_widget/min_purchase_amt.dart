import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';

import '../../../provider/mf_provider.dart';

class MinPurchaseAmt extends ConsumerWidget {
  const MinPurchaseAmt({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mf = watch(mfProvider);
    return ExpansionTile(
        title: Text(
          "Min. purchase amount",
          style: textStyle(colors.colorBlack, 14, FontWeight.w500),
        ),
        children: [
          RangeSlider(
            activeColor: const Color(0xffFF1717),
            values: mf.currentRangeValues,
            min: 0, // Minimum index value
            max: (mf.schmeminfilter!.length - 1).toDouble(),
            divisions: mf.schmeminfilter!.length - 1,
            labels: RangeLabels(
              mf.startValue.toString(),
              mf.endValue.toString(),
            ),
            onChanged: (RangeValues values) {
              mf.updateRange(values,mf.startValue.toString(), mf.endValue.toString(),);
              if (mf.startValue != 0 || mf.endValue != (mf.schmeminfilter!.length - 1)){
              mf.updateFilteredMF(true);
              }
            },
          ),
        ]);
  }
}
//  mf.schmeminfilter!
//           .map(
//             (child) => ListTile(
//               onTap: () {
//                  mf.selectedminamt(child.toInt());
//               },
//               minLeadingWidth: 0,
//               title: Padding(
//                 padding: const EdgeInsets.only(bottom: 6.8),
//                 child: Text(
//                   child.toString(),
//                   style: textStyle(colors.colorBlack, 15, FontWeight.w500),
//                 ),
//               ),
//               leading: SvgPicture.asset(mf.minpurchase == child
//                   ? assets.checkedbox
//                   : assets.checkbox),
//             ),
//           )
//           .toList(),
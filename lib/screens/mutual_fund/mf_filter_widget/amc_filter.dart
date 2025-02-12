import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/mf_provider.dart';


class AmcFIlter extends ConsumerWidget {
  const AmcFIlter({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mf = watch(mfProvider);
    return ExpansionTile(
      title: Text(
        "AMC",
        style: textStyle(colors.colorBlack, 14, FontWeight.w500),
      ),
      children: mf.amcfilter!
          .map(
            (child) => ListTile(
              onTap: () {
                mf.selectedamc(child);
                mf.updateFilteredMF(false);
              },
              minLeadingWidth: 0,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 6.8),
                child: Text(
                  child,
                  style: textStyle(colors.colorBlack, 15, FontWeight.w500),
                ),
              ),
              leading: SvgPicture.asset(mf.amcselected.contains(child)
                  ? assets.checkedbox
                  : assets.checkbox),
            ),
          )
          .toList(),
    );
  }
}

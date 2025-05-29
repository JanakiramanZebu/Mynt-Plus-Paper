import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';

class CustomBackBtn extends ConsumerWidget {
  const CustomBackBtn({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: SvgPicture.asset(assets.backArrow,
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack)));
  }
}

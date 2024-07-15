import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';

class ListDivider extends StatelessWidget {
  const ListDivider({super.key});

  @override
  Widget build(BuildContext context) {       final theme = context.read(themeProvider);
    return Divider(
                          thickness: 0,
                            color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider, height: 0);
  }
}
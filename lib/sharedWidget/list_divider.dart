import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';

class ListDivider extends ConsumerWidget {
  const ListDivider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return Divider(
        thickness: 0,
        color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        height: 0);
  }
}

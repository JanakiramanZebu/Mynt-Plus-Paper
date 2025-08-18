import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/thems.dart';
import '../res/global_state_text.dart';
import '../res/res.dart';
import 'functions.dart';

class IpoErrorBadge extends ConsumerWidget {
  final String errorName;
  const IpoErrorBadge({super.key, required this.errorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Row(
      children: [
        //  Icon(
        //         Icons.info_outline_rounded,
        //         color: Color(0xfffb8c00),
        //         size: 20,
        //       ),
        //       const SizedBox(
        //         width: 10,
        //       ),
        Expanded(
          child: TextWidget.captionText(
            text: errorName,
            theme: false,
            color:  theme.isDarkMode ? colors.lossDark : colors.lossLight,
            fw: 0,
          ),
        ),
      ],
    );
  }
}

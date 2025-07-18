import 'package:flutter/material.dart';

import '../res/global_state_text.dart';
import '../res/res.dart';
import 'functions.dart';

class IpoErrorBadge extends StatelessWidget {
  final String errorName;
  const IpoErrorBadge({super.key, required this.errorName});

  @override
  Widget build(BuildContext context) {
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
            color: colors.error,
            fw: 500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/list_divider.dart';

class StrikePriceListCard extends ConsumerWidget {
  final List<OptionValues> strike;
  final bool isCallUp;

  const StrikePriceListCard({
    super.key,
    required this.strike,
    required this.isCallUp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp,
      itemCount: strike.length,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (BuildContext context, int index) {
        final strikePrice = strike[index].strprc;
        return Container(
          height: 40,
          alignment: Alignment.center,
          color: resolveThemeColor(
            context,
            dark: MyntColors.listItemBgDark,
            light: MyntColors.listItemBg,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "$strikePrice",
            style: MyntWebTextStyles.bodySmall(
              context,
              fontWeight: MyntFonts.bold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class PositionGroupBottomSheet extends StatelessWidget {
  const PositionGroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final positionBook = ref.watch(portfolioProvider);

      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: resolveThemeColor(context,
                  dark: MyntColors.backgroundColorDark,
                  light: MyntColors.backgroundColor),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: Text(
                    "Group by",
                    style: MyntWebTextStyles.title(
                      context,
                      darkColor: MyntColors.textPrimaryDark,
                      lightColor: MyntColors.textPrimary,
                      fontWeight: MyntFonts.semiBold,
                    ),
                  ),
                ),
                Divider(
                  height: 3,
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark,
                      light: MyntColors.divider),
                ),
                ListView.separated(
                    shrinkWrap: true,
                    itemCount: positionBook.posGrpNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      final isSelected = positionBook.posGrpNames[index] ==
                          positionBook.posSelection;

                      return ListTile(
                          onTap: () async {
                            positionBook.chngPosSelection(
                                positionBook.posGrpNames[index]);
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          dense: true,
                          title: Text(
                            positionBook.posGrpNames[index],
                            style: MyntWebTextStyles.body(
                              context,
                              color: isSelected
                                  ? resolveThemeColor(context,
                                      dark: MyntColors.primaryDark,
                                      light: MyntColors.primary)
                                  : resolveThemeColor(context,
                                      dark: MyntColors.textSecondaryDark,
                                      light: MyntColors.textSecondary),
                              fontWeight: isSelected
                                  ? MyntFonts.semiBold
                                  : MyntFonts.medium,
                            ),
                          ),
                          trailing: index > 1
                              ? InkWell(
                                  child: const Icon(
                                    Icons.delete_outlined,
                                    color: Color(0xff666666),
                                  ),
                                  onTap: () async {
                                    // positionBook.fetchDeleteGroupName(
                                    //     positionBook.posGrpNames[index], context);
                                  })
                              : const SizedBox(width: 0.1));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const ListDivider();
                    })
              ]));
    });
  }
}

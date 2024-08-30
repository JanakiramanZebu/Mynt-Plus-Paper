import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class PositionGroup extends ConsumerWidget {
  const PositionGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final position = watch(portfolioProvider);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Group By",
                  style: textStyles.appBarTitleTxt.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack),
                ),
              ],
            ),
          ),
          Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider),
          ListView.separated(
            shrinkWrap: true,
            itemCount: position.groupPosition.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  onTap: () async {
                    await position
                        .groupByPosition(position.groupPosition[index]);
                    // selctedSortValue(index);
                    Navigator.pop(context);
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  dense: true,
                  title: Text(
                    "${position.groupPosition[index]} (${index == 0 ? position.postionGropList.length : position.positionGroup[position.groupPosition[index]]})",
                    style: textStyles.prdText,
                  ),
                  trailing: SvgPicture.asset(theme.isDarkMode
                      ? position.positionGrpName == position.groupPosition[index]
                          ? assets.darkActProductIcon
                          : assets.darkProductIcon
                      :position.positionGrpName == position.groupPosition[index]
                          ? assets.actProductIcon
                          : assets.productIcon));
            },
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
          ),
        ],
      ),
    );
  }
}

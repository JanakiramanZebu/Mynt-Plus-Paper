import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';

class PositionGroupBottomSheet extends StatelessWidget {
  const PositionGroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final positionBook = watch(portfolioProvider);
      final theme = context.read(themeProvider);
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Group by",
                              style: textStyles.appBarTitleTxt.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack))
                        ])),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                ListView.separated(
                    shrinkWrap: true,
                    itemCount: positionBook.posType.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          onTap: () async {
                            positionBook
                                .chngPosSelection(positionBook.posType[index]);
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          dense: true,
                          title: Text(positionBook.posType[index],
                              style: textStyles.prdText),
                          trailing: SvgPicture.asset(theme.isDarkMode
                              ? positionBook.posType[index] ==
                                      positionBook.posSelection
                                  ? assets.darkActProductIcon
                                  : assets.darkProductIcon
                              : positionBook.posType[index] ==
                                      positionBook.posSelection
                                  ? assets.actProductIcon
                                  : assets.productIcon));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const ListDivider();
                    })
              ]));
    });
  }
}

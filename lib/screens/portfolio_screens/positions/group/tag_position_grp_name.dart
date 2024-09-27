import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/portfolio_model/position_book_model.dart';
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';
import 'create_group.dart';

class TagPositionGrpName extends StatelessWidget {
  final PositionBookModel positionList;
  const TagPositionGrpName({super.key, required this.positionList});

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
                          Text("Tag",
                              style: textStyles.appBarTitleTxt.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack)),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CreateGroupPos();
                                    });
                              },
                              child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(children: [
                                    SvgPicture.asset(assets.addCircleIcon,
                                        color: theme.isDarkMode
                                            ? colors.colorLightBlue
                                            : colors.colorBlue),
                                    const SizedBox(width: 3),
                                    Text("Create New Group",
                                        style: textStyles.textBtn.copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorLightBlue
                                                : colors.colorBlue))
                                  ])))
                        ])),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                ListView.separated(
                    shrinkWrap: true,
                    itemCount: positionBook.posGrpNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      return index == 0 || index == 1
                          ? Container(height: 0)
                          : ListTile(
                              onTap: () async {
                                Map data = {
                                  "tsym": "${positionList.tsym}",
                                  "token": "${positionList.token}",
                                  "expDate": "${positionList.expDate}",
                                  "symbol": "${positionList.symbol}",
                                  "exch": "${positionList.exch}"
                                };
                                positionBook.fetchAddGroupSymbol(
                                    positionBook.posGrpNames[index],
                                    context,
                                    data );
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              dense: true,
                              title: Text(positionBook.posGrpNames[index],
                                  style: textStyles.prdText));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const ListDivider();
                    })
              ]));
    });
  }
}

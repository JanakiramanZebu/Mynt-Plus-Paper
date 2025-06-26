import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../../provider/portfolio_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart'; 

class PositionGroupBottomSheet extends StatelessWidget {
  const PositionGroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final positionBook = ref.watch(portfolioProvider);
      final theme = ref.read(themeProvider);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: TextWidget.titleText(
                      text: "Group by", theme: theme.isDarkMode, fw: 1),
                ),
                Divider(
                  height: 3,
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                ListView.separated(
                    shrinkWrap: true,
                
                    itemCount: positionBook.posGrpNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          onTap: () async {
                        
                            positionBook.chngPosSelection(
                                positionBook.posGrpNames[index]);

                             

                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          dense: true,
                          title: TextWidget.subText(
                              text: positionBook.posGrpNames[index],
                              theme: theme.isDarkMode,
                                  color: positionBook.posGrpNames[index] ==
                                          positionBook.posSelection
                                      ? colors.colorBlack
                                  : colors.colorGrey,
                              fw: 0),
                          trailing: index > 1
                              ? InkWell(
                                  child: const Icon(
                                    Icons.delete_outlined,
                                    color: Color(0xff666666),
                                  ),
                                  onTap: () async {
                                  //      positionBook
                                  // .fetchDeleteGroupName(positionBook.posGrpNames[index], context);
                                  })
                              : Container(width: 0.1));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const ListDivider();
                    })
              ]));
    });
  }
}

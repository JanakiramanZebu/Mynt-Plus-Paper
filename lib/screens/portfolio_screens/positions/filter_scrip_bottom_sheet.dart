import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';

class PositionScripFilterBottomSheet extends StatefulWidget {
  const PositionScripFilterBottomSheet({
    super.key,
  });

  @override
  State<PositionScripFilterBottomSheet> createState() =>
      _PositionScripBottomSheetState();
}

class _PositionScripBottomSheetState
    extends State<PositionScripFilterBottomSheet> {
  List<String> fliterList = [
    "Scrip - A to Z",
    "Scrip - Z to A",
    "Price - High to Low",
    "Price - Low to High",
    "Open Position",
    "Close Position"
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      // final watchlist = watch(marketWatchProvider);   
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sort by",
                    style: textStyles.appBarTitleTxt.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                  ),
                ],
              ),
            ),
            Divider(color: theme.isDarkMode?colors.darkColorDivider:colors.colorDivider),
            ListView.separated(
              shrinkWrap: true,
              itemCount: fliterList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    onTap: () async {
                      selctedSortValue(index);
                      Navigator.pop(context);
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    dense: true,
                    title: Text(
                      fliterList[index],
                      style: textStyles.prdText ,
                    ),
                    trailing: SvgPicture.asset(
                      theme.isDarkMode?  index == 0 ? assets.darkActProductIcon : assets.darkProductIcon:
                        index == 0 ? assets.actProductIcon : assets.productIcon));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const ListDivider();
              },
            ),
          ],
        ),
      );
    });
  }

  void selctedSortValue(int value) {
    return setState(() {
      if (value == 0) {
        context.read(portfolioProvider).sortPositions(sorting: "ASC");
      } else if (value == 1) {
        context.read(portfolioProvider).sortPositions(sorting: "DSC");
      } else if (value == 2) {
        context.read(portfolioProvider).sortPositions(sorting: "LTPDSC");
      } else if (value == 3) {
        context.read(portfolioProvider).sortPositions(sorting: "LTPASC");
      } else if (value == 4) {
        context.read(portfolioProvider).sortPositions(sorting: "Open");
      } else {
        context.read(portfolioProvider).sortPositions(sorting: "Close");
      }
    });
  }
}

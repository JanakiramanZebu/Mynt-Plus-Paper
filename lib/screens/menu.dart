import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/list_divider.dart';
import '../provider/bonds_provider.dart';
import '../provider/index_list_provider.dart';
import '../provider/iop_provider.dart';
import '../provider/mf_provider.dart';

class MoreMenuBottomSheet extends StatefulWidget {
  const MoreMenuBottomSheet({super.key});

  @override
  State<MoreMenuBottomSheet> createState() => _MoreMenuBottomSheetState();
}

class _MoreMenuBottomSheetState extends State<MoreMenuBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final menus = ref.watch(indexListProvider);
      final theme = ref.watch(themeProvider);
      int currentYear = DateTime.now().year;
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.isDarkMode ? Colors.black : Colors.white,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "More Options",
                    style: textStyles.appBarTitleTxt.copyWith(
                        color: theme.isDarkMode ? Colors.white : Colors.black),
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
              itemCount: menus.moreMenu.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    onTap: () async {
                      if (index == 0) {
                        await ref.read(ipoProvide).getSmeIpo();
                        await ref.read(ipoProvide).getmainstreamipo();
                        await ref
                            .read(ipoProvide)
                            .getipoperfomance(currentYear);
                      } else if (index == 1) {
                        await ref.read(bondsProvider).fetchAllBonds();
                      } else {
                        await ref
                            .read(mfProvider)
                            .fetchMFWatchlist("", "", context, false,"");
                            
                        // await ref.read(mfProvider).fetchMasterMF();
                      }
                      menus.bottomMenu(5 + index, context);
                      Navigator.pop(context);
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    dense: true,
                    title: Text(
                      menus.moreMenu[index]['title'],
                      style: textStyles.prdText.copyWith(
                          color:
                              theme.isDarkMode && menus.selectedBtmIndx == index
                                  ? colors.colorWhite
                                  : menus.selectedBtmIndx == index
                                      ? colors.colorBlack
                                      : colors.colorGrey),
                    ),
                    subtitle: Text(
                      menus.moreMenu[index]['subTitle'],
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color:
                              theme.isDarkMode && menus.selectedBtmIndx == index
                                  ? colors.colorWhite
                                  : menus.selectedBtmIndx == index
                                      ? colors.colorBlack
                                      : colors.colorGrey),
                    ),
                    trailing:
                        SvgPicture.asset("assets/profile/greater_arrow.svg"));
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
}

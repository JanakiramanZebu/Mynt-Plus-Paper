import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../../provider/order_input_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart'; 

class GttBottomSheet extends ConsumerWidget {
  final String data;
  const GttBottomSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderInput = ref.watch(ordInputProvider);
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
              padding: const EdgeInsets.only(left: 16.0),
              child: Text("${data}s",
                  style: textStyles.appBarTitleTxt.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack)),
            ),
            Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider),
            ListView.separated(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: data == "Alert"
                  ? orderInput.alertTypes.length
                  : orderInput.condTypes.length,
              itemBuilder: (BuildContext context, int index) {
                return data == "Alert"
                    ? ListTile(
                        onTap: () async {
                          orderInput.chngAlert(orderInput.alertTypes[index]);
                          Navigator.pop(context);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        dense: true,
                        minLeadingWidth: 22,
                        leading: SvgPicture.asset(theme.isDarkMode
                            ? orderInput.actAlert ==
                                    orderInput.alertTypes[index]
                                ? assets.darkActProductIcon
                                : assets.darkProductIcon
                            : orderInput.actAlert ==
                                    orderInput.alertTypes[index]
                                ? assets.actProductIcon
                                : assets.productIcon),
                        title: Text(orderInput.alertTypes[index],
                            style: textStyles.prdText.copyWith(
                                color: theme.isDarkMode &&
                                        orderInput.actAlert ==
                                            orderInput.alertTypes[index]
                                    ? colors.colorWhite
                                    : orderInput.actAlert ==
                                            orderInput.alertTypes[index]
                                        ? colors.colorBlack
                                        : colors.colorGrey)),
                      )
                    : ListTile(
                        onTap: () async {
                          orderInput.chngCond(orderInput.condTypes[index]);
                          Navigator.pop(context);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        dense: true,
                        minLeadingWidth: 22,
                        leading: SvgPicture.asset(theme.isDarkMode
                            ?   orderInput.actCond == orderInput.condTypes[index]
                                ? assets.darkActProductIcon
                                : assets.darkProductIcon
                            :  orderInput.actCond == orderInput.condTypes[index]
                                ? assets.actProductIcon
                                : assets.productIcon),
                        title: Text(orderInput.condTypes[index],
                            style: textStyles.prdText
                                .copyWith(color:theme.isDarkMode &&
                                      orderInput.actCond == orderInput.condTypes[index]
                                    ? colors.colorWhite
                                    :   orderInput.actCond == orderInput.condTypes[index]
                                        ? colors.colorBlack
                                        : colors.colorGrey)),
                      );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const ListDivider();
              },
            ),
             const SizedBox(height: 18),
          ],
        ),
        );
  }
}

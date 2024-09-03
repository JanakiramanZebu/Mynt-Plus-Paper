import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_data_found.dart';

class BasketList extends ConsumerWidget {
  const BasketList({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final basket = watch(orderProvider);
    final theme = watch(themeProvider);
    return basket.basketName.isEmpty
        ? const NoDataFound()
        : ListView.separated(
            shrinkWrap: true,
            itemCount: basket.basketName.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  onTap: () {
                    basket.chngBsktName(basket.basketName[index].basketname);
                    Navigator.pushNamed(context, Routes.bsktScripList,
                        arguments: basket.basketName[index].basketname);
                  },
                  dense: true,
                  title: Text(
                      "Basket name: ${basket.basketName[index].basketname}",
                      style: textStyles.scripNameTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)),
                  subtitle: Text(
                      "Created on: ${basket.basketName[index].createdDate}",
                      style: textStyles.scripExchTxtStyle.copyWith(
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack)));
            },
            separatorBuilder: (BuildContext context, int index) {
              return const ListDivider();
            },
          );
  }
}

class BasketScripList extends StatelessWidget {
  final String bsktName;
  const BasketScripList({super.key, required this.bsktName});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Scaffold(
        appBar: AppBar(
          elevation: .2,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          shadowColor: const Color(0xffECEFF3),
          title: Text(bsktName,
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600)),
          actions: [
            Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 30,
                    child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.searchScrip,
                              arguments: "Basket");
                        },
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.colorGrey
                                    : colors.colorBlack),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32)))),
                        child: Text("Add symbol",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                12,
                                FontWeight.w600)))),
              ],
            ),
          ],
        ),
        body: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? const Color(0xffB5C0CF).withOpacity(.15)
                    : const Color(0xffF1F3F8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pre Trade Margin",
                            style: textStyle(
                                const Color(0xff5E6B7D), 12, FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text("₹0.00",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Post Trade Margin",
                            style: textStyle(
                                const Color(0xff5E6B7D), 12, FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text("₹0.00",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                16,
                                FontWeight.w500)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ]));
  }
}

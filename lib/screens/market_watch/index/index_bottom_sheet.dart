import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart'; 
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../provider/index_list_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';

class IndexBottomSheet extends ConsumerWidget {
  final int defaultIndex;
  const IndexBottomSheet({super.key, required this.defaultIndex});

  // int tabIndex = 0;
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    double widgetSize = 740;
    final double initialSize = 600.0 / MediaQuery.of(context).size.height;
    double maxSize = widgetSize / MediaQuery.of(context).size.height;
    maxSize = maxSize > 0.9 ? 0.9 : maxSize;
    bool ischeck = false;
    final theme = context.read(themeProvider);
    final indexProvide = watch(indexListProvider);
    return DraggableScrollableSheet(
        initialChildSize: initialSize,
        minChildSize: 0.2,
        maxChildSize: maxSize,
        expand: false,
        builder: (_, controller) {
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
              children: [
                const CustomDragHandler(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Index List",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              18,
                              FontWeight.w600)),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: !theme.isDarkMode
                                      ? colors.colorWhite
                                      : const Color.fromARGB(255, 18, 18, 18)),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                                customHeights:  
                                    indexProvide.getCustomItemsHeight()),
                            buttonStyleData: ButtonStyleData(
                                height: 36,
                                width: 90,
                                decoration: BoxDecoration(
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8),
                                    // border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(32)))),
                            // buttonDecoration: const BoxDecoration(
                            //     color: Color(0xffF1F3F8),
                            //     // border: Border.all(color: Colors.grey),
                            //     borderRadius: BorderRadius.all(
                            //         Radius.circular(32))),
                            // buttonSplashColor: Colors.transparent,
                            isExpanded: true,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500),
                            hint: Text(indexProvide.slectedExch,
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorBlack
                                        : colors.colorBlack,
                                    13,
                                    FontWeight.w500)),
                            items: indexProvide.addDividersAfterExpDates(),
                            // customItemsHeights:
                            //     indexProvide.getCustomItemsHeight(),
                            value: indexProvide.slectedExch,
                            onChanged: (value) async {
                              indexProvide.fetchIndexList("$value", context);
                            },
                            // buttonHeight: 36,
                            // buttonWidth: 90,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider),
                Expanded(
                  child: indexProvide.isLoad
                      ? const Center(child: CircularProgressIndicator())
                      : indexProvide.indValuesList.isNotEmpty
                          ? ListView.separated(
                              controller: controller,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const ListDivider();
                              },
                              itemCount: indexProvide.indValuesList.length,
                              itemBuilder: (BuildContext context, index) {
                                if (indexProvide.defaultIndexList!.indValues![0]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token ||
                                    indexProvide.defaultIndexList!.indValues![1]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token ||
                                    indexProvide.defaultIndexList!.indValues![2]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token ||
                                    indexProvide.defaultIndexList!.indValues![3]
                                            .token ==
                                        indexProvide
                                            .indValuesList[index].token) {
                                  ischeck = true;
                                } else {
                                  ischeck = false;
                                }
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  dense: true,
                                  title: Text(
                                      indexProvide.indValuesList[index].idxname!
                                          .toUpperCase(),
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  subtitle: Row(children: [
                                    CustomExchBadge(
                                        exch: indexProvide.slectedExch)
                                  ]),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        if (indexProvide.defaultIndexList!
                                                    .indValues![0].token ==
                                                indexProvide
                                                    .indValuesList[index]
                                                    .token ||
                                            indexProvide.defaultIndexList!
                                                    .indValues![1].token ==
                                                indexProvide
                                                    .indValuesList[index]
                                                    .token ||
                                            indexProvide.defaultIndexList!
                                                    .indValues![2].token ==
                                                indexProvide
                                                    .indValuesList[index]
                                                    .token ||
                                            indexProvide.defaultIndexList!
                                                    .indValues![3].token ==
                                                indexProvide
                                                    .indValuesList[index]
                                                    .token) {
                                          Fluttertoast.showToast(
                                              msg: "Scrip Already Exist!!",
                                              backgroundColor: Colors.amber);
                                        } else {
                                          await indexProvide.changeIndex(
                                              indexProvide.indValuesList[index],
                                              context,
                                              defaultIndex);

                                          Navigator.of(context).pop();
                                        }
                                      },
                                      icon: SvgPicture.asset(
                                        color: theme.isDarkMode && ischeck
                                            ? colors.colorLightBlue
                                            : ischeck
                                                ? colors.colorBlue
                                                : colors.colorGrey,
                                        ischeck
                                            ? assets.bookmarkIcon
                                            : assets.bookmarkedIcon,
                                      )),
                                );
                              })
                          : Center(
                              child: Text("No Data found",
                                  style: textStyle(const Color(0xff777777), 15,
                                      FontWeight.w500)),
                            ),
                )
              ],
            ),
          );
        });
  }

  
}

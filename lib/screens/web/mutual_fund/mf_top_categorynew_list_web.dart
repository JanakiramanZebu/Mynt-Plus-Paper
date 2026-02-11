
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../models/mf_model/mutual_fundmodel.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/list_divider.dart';

class MFCategoryListScreenWeb extends ConsumerWidget {
  final String title;
  const MFCategoryListScreenWeb({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    // Sort the list based on s3Year in descending order
    final sortedList = mfData.catnewlist?.toList();

    if (sortedList != null) {
      sortedList.sort((a, b) {
        final aValue = double.tryParse(a.s3Year ?? '0.00') ?? 0.00;
        final bValue = double.tryParse(b.s3Year ?? '0.00') ?? 0.00;
        return bValue.compareTo(aValue); // Sort in descending order
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 41,
        centerTitle: false,
        titleSpacing: 6,
        leading: const CustomBackBtn(),
        shadowColor: const Color(0xffECEFF3),
        title: TextWidget.titleText(
          text: title,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
          theme: theme.isDarkMode,
        ),
      ),
      body: MyntLoaderOverlay(
        isLoading: (mfData.bestmfloader ?? false) ||
            mfData.categoryDataLoader ||
            mfData.mfallcatnewlist == null ||
            mfData.fundDetailLoader,
        child: mfData.catnewlist?.isEmpty ?? true
            ? ((mfData.categoryDataLoader || mfData.mfallcatnewlist == null)
                ? const SizedBox.shrink()
                : const Center(child: NoDataFound(
                    secondaryEnabled: false,
                  )))
            : Column(
                children: [
                  _buildCategoryChips(context, ref, theme, title, mfData),
                  Expanded(
                    child: ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      // padding: const EdgeInsets.all(8),
                      itemCount: sortedList?.length ?? 0,
                      separatorBuilder: (_, __) => const ListDivider(),
                      itemBuilder: (BuildContext context, int index) {
                        final item = sortedList?[index];
                        if (item == null) return const SizedBox.shrink();

                        return _buildListItem(context, item, theme, mfData);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, WidgetRef ref,
      ThemesProvider theme, String title, dynamic mfData) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      itemBuilder: (BuildContext context, int index) {
        final categoryData = mfData.mFCategoryTypesStatic;
        if (index >= categoryData.length) return const SizedBox.shrink();

        return title == categoryData[index]['title']
            ? buildCategoryCard(
                chips: categoryData[index]['sub'] ?? [],
                ref: ref,
                themee: theme,
                title: title,
              )
            : const SizedBox.shrink();
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 0);
      },
      itemCount: mfData.mFCategoryTypesStatic.length,
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item,
      ThemesProvider theme, dynamic mfData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
         splashColor: theme.isDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.15),
            highlightColor: theme.isDarkMode
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
        onLongPress: () async {
          try {
            if (item.iSIN != null) {
              await mfData.fetchMFWatchlist(
                item.iSIN,
                item.isAdd ?? false ? "delete" : "add",
                context,
                false,
                "watch",
              );
            }
          } catch (e) {
            successMessage(
                context, "Error updating watchlist: ${e.toString()}");
          }
        },
        onTap: () async {
          try {
            if (item.iSIN != null) {
              await mfData.fetchFactSheet(item.iSIN);
      
              if (mfData.factSheetDataModel?.stat != "Not Ok") {
                Map<String, dynamic> jsonData = item.toJson();
                MutualFundList bInstance = MutualFundList.fromJson(jsonData);
                Navigator.pushNamed(
                  context,
                  Routes.mfStockDetail,
                  arguments: bInstance,
                );
              } else {
                    successMessage(context, "No Single Page Data");
                final jsondata = MutualFundList.fromJson(item.toJson());
                Navigator.pushNamed(context, Routes.mforderScreen,
                    arguments: jsondata);
                mfData.orderchangetitle("One-time");
                mfData.chngOrderType("One-time");
              }
            } else {
                  successMessage(context, "Missing fund information");
            }
          } catch (e) {
            successMessage(
                context, "Error loading fund details: ${e.toString()}");
          }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: false,
          leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
                      ),
                    ),
          title: Container(
              margin:  EdgeInsets.only(right: MediaQuery.of(context).size.width *0.1,),
            child: TextWidget.subText(
              text: item.name ?? "Unknown Scheme",
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextWidget.paraText(
              text: "${item.type ?? "Unknown"}",
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              theme: theme.isDarkMode,
              fw: 3,
            ),
          ),

          trailing: TextWidget.subText(
            text: _formatReturns(item.s3Year),
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme: theme.isDarkMode,
            fw: 3,
          ),
        )
      ),
    );
  }

  String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty) {
      return "0.00%";
    }
    return "$returns%";
  }

  Color _getReturnColor(String? returns) {
    if (returns == null || returns.isEmpty) {
      return Colors.grey;
    }

    try {
      final value = double.parse(returns);
      return value >= 0 ? Colors.green : Colors.red;
    } catch (e) {
      // If parsing fails, return a neutral color
      return Colors.grey;
    }
  }

  Widget buildCategoryCard({
    required List<dynamic> chips,
    required WidgetRef ref,
    required ThemesProvider themee,
    required String title,
  }) {
    final mfData = ref.watch(mfProvider);

    return Container(
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themee.isDarkMode ? colors.colorBlack : Colors.white,
        border: Border.all(
          color: themee.isDarkMode
              ? colors.colorBlack
              : const Color.fromARGB(255, 255, 255, 255),
          width: 0,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                itemBuilder: (context, index) {
                  final chipText = chips[index]?.toString() ?? "";

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                        onTap: () async {
                          mfData.changetitle(chipText);
                          mfData.fetchcatdatanew(title, chipText);
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: chipText == mfData.selctedchip
                                    ? colors.primaryDark
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: TextWidget.subText(
                              letterSpacing: 0.2,
                              align: TextAlign.start,
                              text: chipText,
                              color: chipText == mfData.selctedchip
                                  ? colors.primaryLight
                                  : Colors.black,
                              textOverflow: TextOverflow.ellipsis,
                              theme: themee.isDarkMode,
                              fw: chipText == mfData.selctedchip ? 1 : 3),
                        )),
                  );
                },
              ),
            ),
          ),
          Padding(
             padding:
                  const EdgeInsets.only(left: 12, bottom: 8, top: 16, right: 8),
            child: Container(
              // color: themee.isDarkMode
              //     ? const Color(0xFF2A2A2A)
              //     : const Color(0xFFF1F3F8),
              // padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.paraText(
                      align: TextAlign.right,
                      text: 'Funds',
                      color: themee.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: themee.isDarkMode,
                      fw: 3),
                  TextWidget.paraText(
                      align: TextAlign.right,
                      text: '3Y Returns',
                      color: themee.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: themee.isDarkMode,
                      fw: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// Container(
//           decoration: BoxDecoration(
//             border: Border.symmetric(
//               vertical: BorderSide(
//                 color: theme.isDarkMode
//                     ? colors.darkGrey
//                     : const Color(0xffEEF0F2),
//                 width: 0,
//               ),
//             ),
//           ),
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: CircleAvatar(
//                       backgroundImage: NetworkImage(
//                         "https://v3.mynt.in/mfapi/static/images/mf/${item.aMCCode ?? 'default'}.png",
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.6,
//                               child: TextWidget.subText(
//                                   align: TextAlign.start,
//                                   text: item.name ?? "Unknown Scheme",
//                                   color: theme.isDarkMode
//                                       ? colors.textPrimaryDark
//                                       : colors.textPrimaryLight,
//                                   textOverflow: TextOverflow.ellipsis,
//                                   theme: theme.isDarkMode,
//                                   fw: 3),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: SizedBox(
//                             height: 18,
//                             child: ListView(
//                               scrollDirection: Axis.horizontal,
//                               children: [
//                                 TextWidget.paraText(
//                                   fw: 3,
//                                   text: "${item.type ?? "Unknown"}",
//                                   textOverflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                   color: theme.isDarkMode
//                                       ? colors.textSecondaryDark
//                                       : colors.textSecondaryLight,
//                                   theme: false,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 5),
//                                   child: TextWidget.paraText(
//                                     fw: 3,
//                                     text: "${item.subType ?? "Unknown"}",
//                                     textOverflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                     color: theme.isDarkMode
//                                         ? colors.textSecondaryDark
//                                         : colors.textSecondaryLight,
//                                     theme: false,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   TextWidget.titleText(
//                     fw: 3,
//                     text: _formatReturns(item.s3Year),
//                     textOverflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     color: _getReturnColor(item.s3Year),
//                     theme: false,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.only(top: 0),
//                 child: Divider(
//                   color: theme.isDarkMode
//                       ? colors.darkColorDivider
//                       : colors.colorDivider,
//                   thickness: 1.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
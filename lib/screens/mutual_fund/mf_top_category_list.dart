import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../models/mf_model/mutual_fundmodel.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MFCategoryListScreen extends ConsumerWidget {
  final String title;
  const MFCategoryListScreen({super.key, required this.title});

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
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        shadowColor: const Color(0xffECEFF3),
        title: Text(
          title,
          style: textStyles.appBarTitleTxt.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          ),
        ),
      ),
      body: TransparentLoaderScreen(
        isLoading: mfData.bestmfloader ?? false,
        child: mfData.catnewlist?.isEmpty ?? true
            ? const Center(child: NoDataFound())
            : Column(
                children: [
                  _buildCategoryChips(context, ref, theme, title, mfData),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: sortedList?.length ?? 0,
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

  Widget _buildCategoryChips(BuildContext context, WidgetRef ref, ThemesProvider theme, String title, dynamic mfData) {
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

  Widget _buildListItem(BuildContext context, dynamic item, ThemesProvider theme, dynamic mfData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: InkWell(
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
            ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Error updating watchlist: ${e.toString()}")
            );
          }
        },
        onTap: () async {
          try {
            mfData.loaderfun();
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
                ScaffoldMessenger.of(context).showSnackBar(
                  successMessage(context, "No Single Page Data")
                );
                final jsondata = MutualFundList.fromJson(item.toJson());
                Navigator.pushNamed(context, Routes.mforderScreen, arguments: jsondata);
                mfData.orderchangetitle("One-time");
                mfData.chngOrderType("One-time");
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                successMessage(context, "Missing fund information")
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Error loading fund details: ${e.toString()}")
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(
                color: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffEEF0F2),
                width: 0,
              ),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://v3.mynt.in/mf/static/images/mf/${item.aMCCode ?? 'default'}.png",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                item.schemeGroupName ?? "Unknown Scheme",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.scripNameTxtStyle.copyWith(
                                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: 18,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: CustomExchBadge(
                                    exch: item.type ?? "Unknown"
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: CustomExchBadge(
                                    exch: item.subType ?? "Unknown",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatReturns(item.s3Year),
                    style: textStyle(
                      _getReturnColor(item.s3Year),
                      14,
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                  thickness: 1.0,
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:themee.isDarkMode ? colors.colorBlack: Colors.white,
        border: Border.all(
          color: themee.isDarkMode ? colors.colorBlack: const Color.fromARGB(255, 255, 255, 255),
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
                      child: Chip(
                        label: Text(
                          chipText,
                          style: textStyle(
                            chipText == mfData.selctedchip
                                ? colors.colorWhite
                                :themee.isDarkMode ? const Color.fromARGB(255, 255, 255, 255) :colors.colorBlack,
                            12,
                            FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        shape: const StadiumBorder(),
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: -2),
                        backgroundColor: chipText == mfData.selctedchip
                            ? (themee.isDarkMode ? const Color(0xFF2A2A2A) : colors.colorBlack)
                            : (themee.isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : colors.colorWhite), 
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        side: BorderSide(
                          color:themee.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFF666666),
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              color: themee.isDarkMode ? const Color(0xFF2A2A2A): const Color(0xFFF1F3F8),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FUNDS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: themee.isDarkMode ? colors.colorWhite: Colors.black,
                      letterSpacing: 0.7,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '3Y RETURNS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color:themee.isDarkMode ? colors.colorWhite: Colors.black,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
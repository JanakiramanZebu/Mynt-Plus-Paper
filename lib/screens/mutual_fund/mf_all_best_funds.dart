// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/no_data_found.dart';
import '../../sharedWidget/custom_exch_badge.dart';

class SaveTaxesScreen extends ConsumerWidget {
  final String title;

  const SaveTaxesScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mf = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme.isDarkMode;
    final dynamic newlisst;
    
    // Safely select the proper basket based on selected chip
    if (mf.newbestmodel?.data?.baskets != null) {
      switch (mf.selctedchip) {
        case 'Tax Saving':
          newlisst = mf.newbestmodel?.data?.baskets?.taxSaving;
          break;
        case 'High Growth Equity':
          newlisst = mf.newbestmodel?.data?.baskets?.highGrowthEquity;
          break;
        case 'Stable Debt':
          newlisst = mf.newbestmodel?.data?.baskets?.stableDebt;
          break;
        case 'Sectoral Thematic':
          newlisst = mf.newbestmodel?.data?.baskets?.sectoralThematic;
          break;
        case 'International  Exposure':
          newlisst = mf.newbestmodel?.data?.baskets?.internationalExposure;
          break;
        case 'Balanced Hybrid':
          newlisst = mf.newbestmodel?.data?.baskets?.balancedHybrid;
          break;
        default:
          newlisst = null;
      }
    } else {
      newlisst = null;
    }

    // Sort by 3-year data if available
    final sortedList = newlisst != null ? List.from(newlisst) : null;
    if (sortedList != null) {
      sortedList.sort((a, b) => (double.tryParse(b.s3Year ?? "0") ?? 0)
          .compareTo(double.tryParse(a.s3Year ?? "0") ?? 0));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: isDarkMode ? colors.colorWhite : colors.colorBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            "Best Mutual Fund",
            style: textStyles.appBarTitleTxt.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TransparentLoaderScreen(
            isLoading: mf.bestmfloader ?? false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                buildSlidingPanelContent(mf.bestMFListStaticnew ?? [], mf, theme),
                Expanded(
                  child: sortedList == null || sortedList.isEmpty
                      ? const Center(child: NoDataFound())
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: sortedList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = sortedList[index];
                            final schemeGroupName = item.name ?? "Unknown Fund";
                            final amcCode = item.aMCCode ?? "default";
                            final isin = item.iSIN;
                            final type = item.schemeType ?? "";
                            final subType = item.subType ?? "";
                            final threeYearData = item.s3Year ?? "0.00";
                            // final isAdd = item.isAdd == true;
                            
                            // Parse 3-year performance data safely
                            final performanceValue = double.tryParse(
                              threeYearData.isEmpty ? "0.00" : threeYearData
                            ) ?? 0.0;
                            
                            // Determine if performance is positive or negative
                            final isPositive = performanceValue >= 0;
                            
                            return Column(
                              children: [
                                InkWell(
                                  // onLongPress: () async {
                                  //   if (isin != null) {
                                  //     await mf.fetchMFWatchlist(
                                  //       isin,
                                  //       isAdd ? "delete" : "add",
                                  //       context,
                                  //       false,
                                  //       "watch",
                                  //     );
                                  //   }
                                  // },
                                  onTap: () async {
                                    try {
                                      if (isin != null) {
                                        mf.loaderfun();
                                        await mf.fetchFactSheet(isin);
                                        mf.fetchmatchisan(isin);
                                        
                                        if (mf.factSheetDataModel?.stat != "Not Ok") {
                                          Map<String, dynamic> jsonData = item.toJson();
                                          MutualFundList bInstance = MutualFundList.fromJson(jsonData);
                                          Navigator.pushNamed(
                                            context, 
                                            Routes.mfStockDetail,
                                            arguments: bInstance
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            successMessage(context, "No Single Page Data")
                                          );
                                          
                                          final jsondata = MutualFundList.fromJson(item.toJson());
                                          Navigator.pushNamed(
                                            context, 
                                            Routes.mforderScreen,
                                            arguments: jsondata
                                          );
                                          
                                          mf.orderchangetitle("One-time");
                                          mf.chngOrderType("One-time");
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          successMessage(context, "Invalid fund data")
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        successMessage(context, "Error loading fund details")
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                        vertical: BorderSide(
                                          color: isDarkMode
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
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  
                                                  CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                      "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(context).size.width * 0.6,
                                                              child: 
                                                              TextWidget.subText(
                                                    align: TextAlign.start,
                                                    text: schemeGroupName,
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                              
                                                             
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        SizedBox(
                                                          height: 16,
                                                          child: ListView(
                                                            scrollDirection: Axis.horizontal,
                                                            children: [
                                                              TextWidget.paraText(
                                  fw: 3,
                                  text: "${item.type ?? "Unknown"}",
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  theme: false,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: TextWidget.paraText(
                                    fw: 3,
                                    text: "${item.subType ?? "Unknown"}",
                                    textOverflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    theme: false,
                                  ),
                                  
                                  
                                ),
                                                             
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextWidget.titleText(
                                                    align: TextAlign.right,
                                                    color: isPositive ? Colors.green : Colors.red,
                                                    text: "$threeYearData%",
                                                              
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                             
                                             
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          color: isDarkMode
                                            ? colors.darkColorDivider
                                            : colors.colorDivider,
                                          thickness: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlidingPanelContent(List bestMFList, MFProvider mfData, ThemesProvider theme) {
    final isDarkMode = theme.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 0),
      height: 95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left:8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 0,
                children: bestMFList.map<Widget>((mf) {
                  final title = mf['title'] ?? "";
                  final isSelected = title == mfData.selctedchip;
                  
                  return GestureDetector(
                    onTap: () => mfData.changetitle(title),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected
                                    ? colors.primaryDark
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: 
                          TextWidget.subText(
                            letterSpacing: 0.2,
                                                    align: TextAlign.start,
                                                    text: title,
                                                    color: isSelected
                                  ? colors.primaryLight
                                  : Colors.black,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: isSelected? 1 :3),
                           
                        )
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F8),
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.captionText(
                      align: TextAlign.right,
                      text: 'FUNDS',
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 3),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextWidget.captionText(
                        align: TextAlign.right,
                        text: '3Y RETURNS',
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 3),
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

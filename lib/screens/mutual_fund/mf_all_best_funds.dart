// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/no_data_found.dart';
import '../../sharedWidget/custom_exch_badge.dart';

class SaveTaxesScreen extends ConsumerWidget {
  final String title;

  const SaveTaxesScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mf = watch(mfProvider);
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    late var newlisst;

    switch (mf.selctedchip) {
      case 'Tax Saving':
        newlisst = mf.newbestmodel?.baskets?.taxSaving;
        break;
      case 'High Growth Equity':
        newlisst = mf.newbestmodel?.baskets?.highGrowthEquity;
        break;
      case 'Stable Debt':
        newlisst = mf.newbestmodel?.baskets?.stableDebt;
        break;
      case 'Sectoral Thematic':
        newlisst = mf.newbestmodel?.baskets?.sectoralThematic;
        break;
      case 'International  Exposure':
        newlisst = mf.newbestmodel?.baskets?.internationalExposure;
        break;
      case 'Balanced Hybrid':
        newlisst = mf.newbestmodel?.baskets?.balancedHybrid;
        break;
    }

    if (newlisst != null) {
      newlisst.sort((a, b) => (double.tryParse(b.tHREEYEARDATA) ?? 0)
          .compareTo(double.tryParse(a.tHREEYEARDATA) ?? 0));
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
              icon: Icon(Icons.arrow_back_ios, color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            "Best Mutual Fund",
            style: textStyles.appBarTitleTxt.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TransparentLoaderScreen(
            isLoading: mf.bestmfloader!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                buildSlidingPanelContent(mf.bestMFListStaticnew, mf),
                Expanded(
                  child: newlisst == null || newlisst.isEmpty
                      ? const Center(child: NoDataFound())
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: newlisst.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                InkWell(
                                  onLongPress: () async {
                                    await mf.fetchMFWatchlist(
                                      newlisst[index].iSIN!,
                                      newlisst[index].isAdd! ? "delete" : "add",
                                      context,
                                      false,
                                      "watch",
                                    );
                                  },
                                  onTap: () async {
                                    mf.loaderfun();
                                    await mf.fetchFactSheet(newlisst[index].iSIN!);

                                    Map<String, dynamic> jsonData = newlisst[index].toJson();
                                    MutualFundList bInstance = MutualFundList.fromJson(jsonData);
                                    Navigator.pushNamed(context, Routes.mfStockDetail, arguments: bInstance);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                        vertical: BorderSide(
                                          color: theme.isDarkMode ? colors.darkGrey : Color(0xffEEF0F2),
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
                                                      "https://v3.mynt.in/mf/static/images/mf/${newlisst[index].aMCCode}.png",
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "${newlisst[index].schemeGroupName}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: textStyles.scripNameTxtStyle.copyWith(
                                                            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        SizedBox(
                                                          height: 16,
                                                          child: ListView(
                                                            scrollDirection: Axis.horizontal,
                                                            children: [
                                                              CustomExchBadge(exch: "${newlisst[index].type}"),
                                                              const SizedBox(width: 5),
                                                              CustomExchBadge(exch: newlisst[index].subType),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "${newlisst[index].tHREEYEARDATA!.isEmpty ? "0.00" : newlisst[index].tHREEYEARDATA!}%",
                                              style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : (double.tryParse(newlisst[index].tHREEYEARDATA!.isEmpty ? "0.00" : newlisst[index].tHREEYEARDATA!)! >= 0
                                                        ? Colors.green
                                                        : Colors.red),
                                                14,
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(
                                          color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
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

  Widget buildSlidingPanelContent(List bestMFList, MFProvider mfData) {
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 0),
      height: 95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 0,
              children: bestMFList.map<Widget>((mf) {
                return GestureDetector(
                  onTap: () => mfData.changetitle(mf['title']),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          mf['title'],
                          style: textStyle(
                            mf['title'] == mfData.selctedchip ? colors.colorWhite : colors.colorBlack,
                            12,
                            FontWeight.w500,
                          ),
                        ),
                      ),
                      backgroundColor: mf['title'] == mfData.selctedchip ? colors.colorBlack : colors.colorWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colors.colorBlack, width: 1),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Color(0xFFF1F3F8),
            child: const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 8, top: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FUNDS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      letterSpacing: 0.7,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      '3Y RETURNS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
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
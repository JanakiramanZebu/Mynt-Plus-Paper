import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MfCommonSearch extends ConsumerWidget {
  const MfCommonSearch({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mfData = watch(mfProvider);
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
final dev_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
appBar: AppBar(
  elevation: 0.2,
  leadingWidth: 38,
  centerTitle: false,
  titleSpacing: 0,
  leading: Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      ),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  title: Padding(
    padding: const EdgeInsets.only(right:18.0),
    child: Container(  
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: TextFormField(
  controller: mfData.mfsearchcontroller,
  style: textStyle(
    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
    16,
    FontWeight.w600,
  ),
  decoration: InputDecoration(
    fillColor: theme.isDarkMode ? colors.darkGrey : colors.kColorLightGrey,
    filled: true,
    hintStyle: textStyle(theme.isDarkMode ? Colors.white:const Color.fromARGB(255, 0, 0, 0), 14, FontWeight.w600),
    prefixIconColor: const Color(0xff586279),
    prefixIconConstraints: const BoxConstraints(
      minWidth: 0,
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Icon(Icons.search, color:theme.isDarkMode ? Colors.white : Colors.black54),
    ),
    suffixIcon: ValueListenableBuilder<TextEditingValue>(
      valueListenable: mfData.mfsearchcontroller,
      builder: (context, value, child) {
        return value.text.isNotEmpty
            ? InkWell(
                onTap: () {
                  mfData.mfsearchcontroller.clear();
                  mfData.fetchmfCommonsearch("", context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SvgPicture.asset(
                    assets.removeIcon,
                    fit: BoxFit.scaleDown,
                    width: 20,
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(20),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(20),
    ),
    hintText: "Search Mutual Fund",
    contentPadding: const EdgeInsets.only(top: 20),
  ),
  onChanged: (value) async => mfData.fetchmfCommonsearch(value, context),
),

    ),
  ),
),

        body: TransparentLoaderScreen(
          isLoading: mfData.bestmfloader!,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                // Container(
                //   height: 62,
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                //   child: TextFormField(
                //     controller: mfData.mfsearchcontroller,
                //     style: textStyle(
                //       theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //       16,
                //       FontWeight.w600,
                //     ),
                //     decoration: InputDecoration(
                //       fillColor: theme.isDarkMode
                //           ? colors.darkGrey
                //           : const Color(0xffF1F3F8),
                //       filled: true,
                //       hintStyle: textStyle(
                //           const Color(0xff69758F), 15, FontWeight.w500),
                //       prefixIconColor: const Color(0xff586279),
                //       prefixIcon: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //         child: SvgPicture.asset(
                //           assets.searchIcon,
                //           color: const Color(0xff586279),
                //           fit: BoxFit.contain,
                //           width: 20,
                //         ),
                //       ),
                //       suffixIcon: InkWell(
                //         onTap: () async => mfData.commonsearch(),
                //         child: Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //           child: SvgPicture.asset(
                //             assets.removeIcon,
                //             fit: BoxFit.scaleDown,
                //             width: 20,
                //           ),
                //         ),
                //       ),
                //       enabledBorder: OutlineInputBorder(
                //         borderSide: BorderSide.none,
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderSide: BorderSide.none,
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       hintText: "Search",
                //       contentPadding: const EdgeInsets.only(top: 20),
                //     ),
                //     onChanged: (value) async =>
                //         mfData.fetchmfCommonsearch(value, context),
                //   ),
                // ),

                // List of Funds
                mfData.mutualFundsearchdata!.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mfData.mutualFundsearchdata!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  mfData.loaderfun();
                                  await mfData.fetchFactSheet(mfData
                                      .mutualFundsearchdata![index].iSIN!);
                                       mfData.fetchmatchisan(mfData.mutualFundsearchdata![index].iSIN!);
                                  if (mfData.factSheetDataModel?.stat !=
                                      "Not Ok") {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.mfStockDetail,
                                      arguments:
                                          mfData.mutualFundsearchdata![index],
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        successMessage(
                                            context, "No Single Page Data"));
                                    final jsondata = MutualFundList.fromJson(
                                        mfData.mutualFundsearchdata![index]
                                            .toJson());

                                    Navigator.pushNamed(
                                        context, Routes.mforderScreen,
                                        arguments: jsondata);
                                    mfData.orderchangetitle("One-time");

                                    mfData.chngOrderType("One-time");
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              "https://v3.mynt.in/mf/static/images/mf/${mfData.mutualFundsearchdata![index].aMCCode}.png",
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                   width: MediaQuery.of(context).size.width * 0.6,
                                                  child: Text(
                                                    
                                                    mfData
                                                            .mutualFundsearchdata![
                                                                index]
                                                            .schemegroupName ??
                                                        "",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textStyles
                                                        .scripNameTxtStyle
                                                        .copyWith(
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  height: 18,
                                                  child: ListView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    children: [
                                                      CustomExchBadge(
                                                          exch: mfData
                                                                  .mutualFundsearchdata![
                                                                      index]
                                                                  .type ??
                                                              ""),
                                                      const SizedBox(width: 5),
                                                      CustomExchBadge(
                                                          exch: mfData
                                                                  .mutualFundsearchdata![
                                                                      index]
                                                                  .subtype ??
                                                              ""),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            splashRadius: 20,
                                            onPressed: () async {
                                              await mfData
                                                  .fetchcommonsearchWadd(
                                                mfData
                                                    .mutualFundsearchdata![
                                                        index]
                                                    .iSIN!,
                                                mfData.mutualFundsearchdata![
                                                            index]
                                                        .isAdd!
                                                    ? "delete"
                                                    : "add",
                                                context,
                                                false,
                                              );
                                            },
                                            icon: SvgPicture.asset(
                                              color: mfData.watchbatchval == true
                                                  ? colors.colorBlue
                                                  : colors.colorBlue,
                                              mfData
                                                      .mutualFundsearchdata![
                                                          index]
                                                      .isAdd!
                                                  ? assets.bookmarkIcon
                                                  : assets.bookmarkedIcon,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Divider(
                                        color: theme.isDarkMode
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
                      )
                    : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 225),
                        child: Container(
                          height: dev_height - 140,
                          child: Column(
                            children: [
                              NoDataFound(),
                            ],
                          ),
                        ),
                      ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

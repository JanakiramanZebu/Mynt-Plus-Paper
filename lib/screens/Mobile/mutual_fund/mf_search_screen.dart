import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../res/global_state_text.dart';

class MfCommonSearch extends ConsumerWidget {
  const MfCommonSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mfData = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            elevation: .2,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  mfData.commonsearch();
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: SvgPicture.asset(assets.backArrow,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack))),
            shadowColor: const Color(0xffECEFF3),
            title: TextWidget.headText(
                text: "Mutual Funds Search",
                theme: theme.isDarkMode,
                fw: 1,
                color: theme.isDarkMode
                    ? colors.colorWhite
                    : colors.colorBlack),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Container(
                  height: 62,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    controller: mfData.mfsearchcontroller,
                   style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
                    decoration: InputDecoration(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        filled: true,
                     hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                               
                                    fw: 0,
                                    ),
                        prefixIconColor: const Color(0xff586279),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SvgPicture.asset(assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                              width: 20),
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            mfData.commonsearch();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SvgPicture.asset(assets.removeIcon,
                                fit: BoxFit.scaleDown, width: 20),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Search",
                        contentPadding: const EdgeInsets.only(top: 20),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20))),
                    onChanged: (value) async {
                      mfData.fetchmfCommonsearch(value, context);
                    },
                  )),
              // Safely check if data exists before displaying
              if (mfData.mutualFundsearchdata?.isNotEmpty ?? false)
                _buildSearchResultsList(context, mfData, theme)
              else
                const Padding(
                  padding: EdgeInsets.only(top: 250),
                  child: NoDataFound(
                    secondaryEnabled: false,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(
      BuildContext context, dynamic mfData, dynamic theme) {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mfData.mutualFundsearchdata?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final item = mfData.mutualFundsearchdata?[index];
          if (item == null) return const SizedBox.shrink();

          return Column(children: [
            InkWell(
                onTap: () async {
                  final isin = item.iSIN;
                  if (isin != null) {
                    await mfData.fetchFactSheet(isin);
                    Navigator.pushNamed(context, Routes.mfStockDetail,
                        arguments: item);
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffEEF0F2),
                                width: 1.5),
                            vertical: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffEEF0F2),
                                width: 1.5))),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                      TextWidget.subText(
                                          text: item.schemeName ?? "Unknown Scheme",
                                          maxLines: 1,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 0,
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                          height: 18,
                                          child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: [
                                                CustomExchBadge(
                                                    exch: _getSchemeType(
                                                        item.schemeName)),
                                                CustomExchBadge(
                                                    exch: item.schemeType ??
                                                        "Unknown"),
                                                CustomExchBadge(
                                                    exch: _formatSubCategory(
                                                        item.sCHEMESUBCATEGORY))
                                              ]))
                                    ])),
                                IconButton(
                                    splashRadius: 20,
                                    onPressed: () async {
                                      final isin = item.iSIN;
                                      if (isin != null) {
                                        await mfData.fetchcommonsearchWadd(
                                            isin,
                                            item.isAdd == true
                                                ? "delete"
                                                : "add",
                                            context,
                                            false);
                                      }
                                    },
                                    icon: SvgPicture.asset(
                                      color: item.isAdd == true
                                          ? colors.colorBlue
                                          : colors.colorGrey,
                                      item.isAdd == true
                                          ? assets.bookmarkIcon
                                          : assets.bookmarkedIcon,
                                    ))
                              ]),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider),
                          const SizedBox(height: 3),
                          _buildInfoRow(
                              "AUM (Cr): ",
                              _formatAum(item.aUM),
                              "3yr: ",
                              item.tHREEYEARDATA?.isEmpty ?? true
                                  ? "0.00"
                                  : item.tHREEYEARDATA!,
                              theme),
                          const SizedBox(height: 3),
                          _buildInfoRow(
                              "NAV: ",
                              item.nETASSETVALUE?.isEmpty ?? true
                                  ? "0.00"
                                  : item.nETASSETVALUE!,
                              "Min. Inv: ",
                              item.minimumPurchaseAmount?.isEmpty ?? true
                                  ? "0.00"
                                  : item.minimumPurchaseAmount!,
                              theme)
                        ]))),
            _buildInvestButton(context, mfData, item, theme)
          ]);
        });
  }

  String _getSchemeType(String? schemeName) {
    if (schemeName == null) return "NORMAL";
    if (schemeName.contains("GROWTH")) return "GROWTH";
    if (schemeName.contains("IDCW PAYOUT")) return "IDCW PAYOUT";
    if (schemeName.contains("IDCW REINVESTMENT")) return "IDCW REINVESTMENT";
    if (schemeName.contains("IDCW")) return "IDCW";
    return "NORMAL";
  }

  String _formatSubCategory(String? subCategory) {
    if (subCategory == null) return "UNKNOWN";
    return subCategory
        .replaceAll("Fund", '')
        .replaceAll("Hybrid", "")
        .toUpperCase();
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "0.00";
    try {
      return (double.parse(aum) / 10000000).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  Widget _buildInfoRow(String label1, String value1, String label2,
      String value2, dynamic theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        TextWidget.captionText(
            text: label1,
            theme: theme.isDarkMode,
            fw: 0,
            color: const Color(0xff999999)),
        TextWidget.captionText(
            text: value1,
            theme: theme.isDarkMode,
            fw: 0,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack)
      ]),
      Row(children: [
        TextWidget.captionText(
            text: label2,
            theme: theme.isDarkMode,
            fw: 0,
            color: const Color(0xff999999)),
        TextWidget.captionText(
            text: value2,
            theme: theme.isDarkMode,
            fw: 0,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack)
      ])
    ]);
  }

  Widget _buildInvestButton(
      BuildContext context, dynamic mfData, dynamic item, dynamic theme) {
    return InkWell(
        onTap: () async {
          mfData.chngMandate("Lumpsum");
          await mfData.fetchUpiDetail();
          // await mfData.fetchBankDetail();

          final isin = item.iSIN;
          final schemeCode = item.schemeCode;

          if (item.sIPFLAG == "Y" && isin != null && schemeCode != null) {
            await mfData.fetchMFSipData(isin, schemeCode);
            await mfData.fetchMFMandateDetail();
          }

          Navigator.pushNamed(context, Routes.mforderScreen, arguments: item);
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? colors.colorbluegrey
                  : const Color(0xffF1F3F8),
              border: Border.all(
                  color: theme.isDarkMode
                      ? colors.darkGrey
                      : const Color(0xffEEF0F2),
                  width: 1.5),
            ),
            child: Text("Invest",
                style: textStyles.scripNameTxtStyle.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorBlue))));
  }
}

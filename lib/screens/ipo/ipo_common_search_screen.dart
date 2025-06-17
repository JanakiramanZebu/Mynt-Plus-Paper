import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/api/core/api_core.dart';
import 'package:mynt_plus/provider/iop_provider.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/screens/ipo/main_sme_list/single_page.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';

class IpoCommonSearch extends ConsumerWidget {
  const IpoCommonSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipo = ref.watch(ipoProvide);
    final theme = ref.watch(themeProvider);
    final market = ref.watch(marketWatchProvider);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(context, ipo, theme),
        body: _buildBody(context, ipo, theme, market),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, IPOProvider ipo, ThemesProvider theme) {
    return AppBar(
      elevation: .2,
      leadingWidth: 40,
      centerTitle: false,
      titleSpacing: -8,
      leading: _BackButton(ipo: ipo, theme: theme),
      shadowColor: const Color(0xffECEFF3),
      title: _SearchField(ipo: ipo, theme: theme),
    );
  }

  Widget _buildBody(BuildContext context, IPOProvider ipo, ThemesProvider theme, MarketWatchProvider market) {
    return SingleChildScrollView(
      child: ipo.ipoCommonSearchList.isNotEmpty
          ? _SearchResultsList(ipo: ipo, theme: theme, market: market)
          : const _NoDataSection(),
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _BackButton extends StatelessWidget {
  final IPOProvider ipo;
  final ThemesProvider theme;

  const _BackButton({
    required this.ipo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          ipo.clearCommonIpoSearch();
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.arrow_back_ios,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final IPOProvider ipo;
  final ThemesProvider theme;

  const _SearchField({
    required this.ipo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: TextFormField(
        autofocus: true,
        controller: ipo.ipocommonsearchcontroller,
        style: IpoCommonSearch._textStyle(
          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          14,
          FontWeight.w500,
        ),
        decoration: InputDecoration(
          fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
          filled: true,
          hintStyle: IpoCommonSearch._textStyle(
            const Color(0xff69758F),
            14,
            FontWeight.w500,
          ),
          prefixIconColor: const Color(0xff586279),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SvgPicture.asset(
              assets.searchIcon,
              color: const Color(0xff586279),
              fit: BoxFit.contain,
              width: 20,
            ),
          ),
          suffixIcon: _ClearButton(ipo: ipo),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          disabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          hintText: "Search IPO",
          contentPadding: const EdgeInsets.only(top: 20),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onChanged: (value) async {
          ipo.searchCommonIpo(value, context);
        },
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final IPOProvider ipo;

  const _ClearButton({required this.ipo});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: ipo.ipocommonsearchcontroller,
      builder: (context, value, child) {
        return value.text.isNotEmpty
            ? InkWell(
                onTap: () => ipo.clearCommonIpoSearch(),
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SvgPicture.asset(
                    assets.removeIcon,
                    fit: BoxFit.scaleDown,
                    width: 20,
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final IPOProvider ipo;
  final ThemesProvider theme;
  final MarketWatchProvider market;

  const _SearchResultsList({
    required this.ipo,
    required this.theme,
    required this.market,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ipo.ipoCommonSearchList.length,
      itemBuilder: (context, index) {
        return _SearchResultItem(
          ipo: ipo,
          theme: theme,
          market: market,
          index: index,
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final IPOProvider ipo;
  final ThemesProvider theme;
  final MarketWatchProvider market;
  final int index;

  const _SearchResultItem({
    required this.ipo,
    required this.theme,
    required this.market,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final checkIpoStatus = ipo.ipoCommonSearchList[index].ipostatus;
    
    return InkWell(
      onTap: () => _handleItemTap(context, checkIpoStatus),
      child: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(
              color: theme.isDarkMode ? colors.darkGrey : const Color(0xffEEF0F2),
              width: 1.5,
            ),
            vertical: BorderSide(
              color: theme.isDarkMode ? colors.darkGrey : const Color(0xffEEF0F2),
              width: 1.5,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _getCompanyName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: IpoCommonSearch._textStyle(
                          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                          14,
                          FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCompanyName() {
    final item = ipo.ipoCommonSearchList[index];
    return item.companyName == "" ? item.name ?? "" : item.companyName ?? "";
  }

  Future<void> _handleItemTap(BuildContext context, String? checkIpoStatus) async {
    String pricerange = "";
    String mininvVal = "";
    String enddate = "";
    String startdate = "";
    String ipotype = "";

    if (checkIpoStatus == "Listed") {
      await _handleListedIPO(context);
    } else if (checkIpoStatus == "Live") {
      final data = await _handleLiveIPO();
      pricerange = data['pricerange'] ?? "";
      mininvVal = data['mininvVal'] ?? "";
      startdate = data['startdate'] ?? "";
      enddate = data['enddate'] ?? "";
      ipotype = data['ipotype'] ?? "";
    } else {
      final data = await _handleClosedIPO();
      pricerange = data['pricerange'] ?? "";
      mininvVal = data['mininvVal'] ?? "";
      enddate = data['enddate'] ?? "";
      startdate = data['startdate'] ?? "";
    }

    if (checkIpoStatus != "Listed" && context.mounted) {
      _showIPOBottomSheet(context, pricerange, mininvVal, enddate, startdate, ipotype);
    }
  }

  Future<void> _handleListedIPO(BuildContext context) async {
    var listdata = ipo.ipoCommonSearchList[index].toJson();
    listdata['exch'] = ipo.ipoCommonSearchList[index].exchange;
    listdata['expDate'] = "";
    listdata['option'] = "";
    listdata['instname'] = "";
    listdata['tsym'] = ipo.ipoCommonSearchList[index].symbol?.split(":")[1] ?? "";
    await market.calldepthApis(context, listdata, "");
  }

  Future<Map<String, String>> _handleLiveIPO() async {
    await ipo.getIpoSinglePage(ipoName: "${ipo.ipoCommonSearchList[index].name}");
    
    final minPrice = double.parse(ipo.ipoCommonSearchList[index].minPrice!).toInt();
    final maxPrice = double.parse(ipo.ipoCommonSearchList[index].maxPrice!).toInt();
    final minBidQty = int.parse(ipo.ipoCommonSearchList[index].minBidQuantity!);
    
    return {
      'pricerange': "₹$minPrice - ₹$maxPrice",
      'mininvVal': "₹${convertCurrencyINRStandard(mininv(minPrice.toDouble(), minBidQty).toInt())}",
      'startdate': ipo.ipoCommonSearchList[index].biddingStartDate ?? "",
      'enddate': ipo.ipoCommonSearchList[index].biddingEndDate ?? "",
      'ipotype': ipo.ipoCommonSearchList[index].key ?? "",
    };
  }

  Future<Map<String, String>> _handleClosedIPO() async {
    await ipo.getIpoSinglePage(ipoName: "${ipo.ipoCommonSearchList[index].companyName}");
    
    return {
      'pricerange': "₹${ipo.ipoCommonSearchList[index].priceRange ?? ""}",
      'mininvVal': "₹${convertCurrencyINRStandard(mininv(ipo.ipoCommonSearchList[index].minPrice?.toDouble() ?? 0.0, ipo.ipoCommonSearchList[index].minBidQu?.toInt() ?? 0).toInt())}",
      'enddate': convertClosedIpoDates(
        ipo.ipoCommonSearchList[index].iPOEndDate ?? "",
        "MMM dd, yyyy",
        "EEE, dd MMM yyyy HH:mm:ss",
      ),
      'startdate': convertClosedIpoDates(
        ipo.ipoCommonSearchList[index].iPOStartDate ?? "",
        "MMM dd, yyyy",
        "dd-MM-yyyy",
      ),
    };
  }

  void _showIPOBottomSheet(
    BuildContext context,
    String pricerange,
    String mininvVal,
    String enddate,
    String startdate,
    String ipotype,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MainSmeSinglePage(
          pricerange: pricerange,
          mininv: mininvVal,
          enddate: enddate,
          startdate: startdate,
          ipotype: ipotype,
          ipodetails: jsonEncode(ipo.ipoCommonSearchList[index]),
        ),
      ),
    );
  }
}

class _NoDataSection extends StatelessWidget {
  const _NoDataSection();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 250),
        child: NoDataFound(),
      ),
    );
  }
}

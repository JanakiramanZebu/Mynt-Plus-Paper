// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/screens/ipo/preclose_ipo/preclose_ipo_screen.dart';
import 'package:mynt_plus/screens/ipo/IPO_order_screen/ipo_order_screen.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../models/ipo_model/ipo_sme_model.dart';
import '../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/stocks_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import 'single_page.dart';

class MainSmeListCard extends StatelessWidget {
  const MainSmeListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipos = ref.watch(ipoProvide);
      final mainstreamipo = ref.watch(ipoProvide);
      final upi = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);
      final devHeight = MediaQuery.of(context).size.height;

      // Get filtered IPOs based on search
      List<dynamic> filteredIpos = _getFilteredIPOs(ipos, mainstreamipo, ref);

      List<dynamic> openIpos = filteredIpos.where((ipo) {
        // Check if the IPO object has biddingStartDate and biddingEndDate properties
        if (ipo is! SMEIPO && ipo is! MainIPO) {
          return false; // Skip IpoScrip and other objects that don't have these properties
        }
        return ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) == "Open";
      }).toList();

      List<dynamic> preOpenIpos = filteredIpos.where((ipo) {
        // Check if the IPO object has biddingStartDate and biddingEndDate properties
        if (ipo is! SMEIPO && ipo is! MainIPO) {
          return false; // Skip IpoScrip and other objects that don't have these properties
        }
        return ipostartdate(ipo.biddingStartDate, ipo.biddingEndDate) ==
            "Pre-open";
      }).toList();

      final hasAnyData = openIpos.isNotEmpty ||
          preOpenIpos.isNotEmpty ||
          (ipos.ipoPreClose?.msg?.isNotEmpty ?? false);


     if(ref.watch(stocksProvide).searchController.text.isNotEmpty &&
       ipos.ipoCommonSearchList.isEmpty){
      return Center(
          child: NoDataFound(
            title: "No Results Found",
            subtitle: "Try searching with different keywords",
            primaryEnabled: false,
            secondaryEnabled: false,
          ),
        );
       }

      if (!hasAnyData) {
        return Center(
          child: NoDataFound(
            title: "No Open IPOs Found",
            subtitle: "",
            primaryEnabled: false,
            secondaryEnabled: false,
          ),
        );
      }

      return Column(
        children: [
          // _SearchField(ipoProvider: ipos, theme: theme),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (openIpos.isNotEmpty) ...[
                    _IPOListSection(
                      ipos: openIpos,
                      ipoProvider: ipos,
                      upiProvider: upi,
                      theme: theme,
                      isPreOpen: false,
                    ),
                    _buildDivider(theme),
                  ],
                  if (preOpenIpos.isNotEmpty) ...[
                    _IPOListSection(
                      ipos: preOpenIpos,
                      ipoProvider: ipos,
                      upiProvider: upi,
                      theme: theme,
                      isPreOpen: true,
                    ),
                    _buildDivider(theme),
                  ],
                  if (ipos.ipoPreClose?.msg?.isNotEmpty == true) ...[
                    const ClosedIPOScreen(),
                  ],
                  // const SizedBox(height: 22),
                  // const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  List<dynamic> _getFilteredIPOs(IPOProvider ipos, IPOProvider mainstreamipo, WidgetRef ref) {
    // If there's a search query, use the common search results
    if (ref.watch(stocksProvide).searchController.text.isNotEmpty &&
        ipos.ipoCommonSearchList.isNotEmpty) {
      return ipos.ipoCommonSearchList;
    }
    // Otherwise, use the original mainsme list
    return mainstreamipo.mainsme;
  }

  Widget _buildDivider(ThemesProvider theme) {
    return Divider(
      height: 0,
      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
    );
  }

  static TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

class _SearchField extends StatelessWidget {
  final IPOProvider ipoProvider;
  final ThemesProvider theme;

  const _SearchField({
    required this.ipoProvider,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: ipoProvider.ipocommonsearchcontroller,
         style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),
        decoration: InputDecoration(
          fillColor:
              theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
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
            child: SvgPicture.asset(
              assets.searchIcon,
              color: const Color(0xff586279),
              fit: BoxFit.contain,
              width: 20,
            ),
          ),
          suffixIcon: _ClearButton(ipoProvider: ipoProvider),
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
          ipoProvider.searchCommonIpo(value, context);
        },
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final IPOProvider ipoProvider;

  const _ClearButton({required this.ipoProvider});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: ipoProvider.ipocommonsearchcontroller,
      builder: (context, value, child) {
        return value.text.isNotEmpty
            ? InkWell(
                onTap: () => ipoProvider.clearCommonIpoSearch(),
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

class _IPOListSection extends StatelessWidget {
  final List<dynamic> ipos;
  final dynamic ipoProvider;
  final dynamic upiProvider;
  final ThemesProvider theme;
  final bool isPreOpen;

  const _IPOListSection({
    required this.ipos,
    required this.ipoProvider,
    required this.upiProvider,
    required this.theme,
    required this.isPreOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ipos.length,
      itemBuilder: (context, index) {
        return _IPOListItem(
          ipo: ipos[index],
          ipoProvider: ipoProvider,
          upiProvider: upiProvider,
          theme: theme,
          isPreOpen: isPreOpen,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        );
      },
    );
  }
}

class _IPOListItem extends StatelessWidget {
  final dynamic ipo;
  final dynamic ipoProvider;
  final dynamic upiProvider;
  final ThemesProvider theme;
  final bool isPreOpen;

  const _IPOListItem({
    required this.ipo,
    required this.ipoProvider,
    required this.upiProvider,
    required this.theme,
    required this.isPreOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onIPOTap(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(context) {
    final dateText = isPreOpen ? "Opens on" : "Closes on";
    final date = isPreOpen
        ? _formatDate(ipo.biddingStartDate ?? "")
        : (ipo.biddingEndDate?.substring(5, 11) ?? "");
    String toTitleCase(String input) {
      return input
          .toLowerCase()
          .split(' ')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: TextWidget.subText(
                  text: toTitleCase(ipo.name ?? ""),
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                  fw: 0,
                ),
              ),
              const SizedBox(height: 8),
              TextWidget.paraText(
                text: "${ipo.key ?? ""} - $dateText $date",
                theme: false,
                fw: 0,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
            ],
          ),
        ),
        // if (!isPreOpen &&
        //     ipo.totalsub != null &&
        //     ipo.totalsub.toString().isNotEmpty)
        _buildSubscriptionInfo(context),
      ],
    );
  }

  Widget _buildSubscriptionInfo(BuildContext context) {
    bool isApplyButtonEnabled = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Material(
          color: Colors.transparent,
          shape: const RoundedRectangleBorder(),
          child: InkWell(
            customBorder: const RoundedRectangleBorder(),
            splashColor: theme.isDarkMode
                ? colors.splashColorDark
                : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () {
              if (isApplyButtonEnabled) {
                isApplyButtonEnabled = false;
                ipoProvider.setSinglepageapply(false);
                _onApplyPressed(context);
              } else {
                return;
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: TextWidget.subText(
                text: isPreOpen ? 'Pre Apply' : 'Apply',
                theme: false,
                fw: 2,
                color:
                    theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextWidget.paraText(
          text: ipo.totalsub != null && ipo.totalsub.toString().isNotEmpty ? "${ipo.totalsub?.toString() ?? ""}x Sub " : "",
          theme: false,
          fw: 3,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      ],
    );
  }

  // Widget _buildFooter(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       // _buildDateInfo(),
  //     ],
  //   );
  // }

  // Widget _buildDateInfo() {

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         dateText,
  //         style: MainSmeListCard.textStyle(
  //           const Color(0xff666666),
  //           10,
  //           FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         date,
  //         style: MainSmeListCard.textStyle(
  //           theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
  //           14,
  //           FontWeight.w500,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildApplyButton(BuildContext context) {
  //   bool isApplyButtonEnabled = true;

  //   return SizedBox(
  //     height: 30,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         elevation: 0,
  //         minimumSize: const Size(0, 30),
  //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
  //         backgroundColor:
  //             theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(50),
  //         ),
  //       ),
  //       onPressed: () {
  //         if (isApplyButtonEnabled) {
  //           isApplyButtonEnabled = false;
  //           _onApplyPressed(context);
  //         } else {
  //           return;
  //         }
  //       },
  //       child: ipoProvider.loading
  //           ? const SizedBox(
  //               width: 18,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 color: Color(0xff666666),
  //               ),
  //             )
  //           : Text(
  //               ,
  //               style: MainSmeListCard.textStyle(
  //                 theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
  //                 12,
  //                 FontWeight.w500,
  //               ),
  //             ),
  //     ),
  //   );
  // }

  Future<void> _onIPOTap(BuildContext context) async {
    await ipoProvider.getIpoSinglePage(ipoName: "${ipo.name}");
    // if (isPreOpen) {
    //   return;
    // }

    if (context.mounted) {
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
            pricerange:
                "${double.parse(ipo.minPrice ?? "0").toInt()} - ${double.parse(ipo.maxPrice ?? "0").toInt()}",
            mininv:
                "${convertCurrencyINRStandard(mininv(double.parse(ipo.minPrice ?? "0").toDouble(), int.parse(ipo.minBidQuantity ?? "0").toInt()).toInt())}",
            enddate: "${ipo.biddingEndDate ?? ""}",
            startdate: "${ipo.biddingStartDate ?? ""}",
            ipotype: "${ipo.key ?? ""}",
            ipodetails: jsonEncode(ipo),
          ),
        ),
      );
    }
  }

  Future<void> _onApplyPressed(BuildContext context) async {
    ipoProvider.setisSMEPlaceOrderBtnActiveValue = false;
    ipoProvider.setisMainIPOPlaceOrderBtnActiveValue = false;

    await upiProvider.fetchupiIdView(
      upiProvider.bankdetails?.dATA?[upiProvider.indexss][1] ?? "",
      upiProvider.bankdetails?.dATA?[upiProvider.indexss][2] ?? "",
    );

    if (ipo.key == "SME") {
      await ipoProvider.smeipocategory();
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.applyIPO,
          arguments: ipo,
        );
      }
    } else {
      await ipoProvider.mainipocategory();
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.applyIPO,
          arguments: ipo,
        );
      }
    }
  }

  String _formatDate(String date) {
    List<String> parts = date.split('-');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    DateTime parsedDate = DateTime(year, month, day);
    return DateFormat('d MMM').format(parsedDate);
  }
}

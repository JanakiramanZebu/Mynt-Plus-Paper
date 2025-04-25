import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MFSipdetScreen extends ConsumerWidget {
  const MFSipdetScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    final mfData = watch(mfProvider);

    return Scaffold(
      body: Stack(
        children: [
          TransparentLoaderScreen(
            isLoading: mfData.bestmfloader!,
            child: mfData.mfsiporderlist?.xsip?.isEmpty ?? true
                ? const Center(child: NoDataFound())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: mfData.mfsiporderlist?.xsip?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    mfData.loaderfun();
                                    await mfData.fetchmfsipsinglepage(
                                        "${mfData.mfsiporderlist?.xsip?[index].xsipRegId}");
                                    if (mfData.mfsinglepageres?.stat == "Ok") {
                                      Navigator.pushNamed(
                                          context, Routes.mfSipdetScren);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          successMessage(context,
                                              "${mfData.mfsinglepageres?.Msg}"));
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
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 0),
                                                        child: SizedBox(
                                                                width: MediaQuery.of(context).size.width * 0.7,

                                                          child: Text(
                                                            "${mfData.mfsiporderlist?.xsip?[index].schemeName}",
                                                            maxLines: 2,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: textStyles
                                                                .scripNameTxtStyle
                                                                .copyWith(
                                                              color: theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      SvgPicture.asset(
                                                        mfData.mfsiporderlist?.xsip?[
                                                                        index]
                                                                    .liveCancel ==
                                                                "LIVE"
                                                            ? assets
                                                                .completedIcon
                                                            : assets
                                                                .cancelledIcon,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 4.0),
                                                        child: Text(
                                                          "${mfData.mfsiporderlist?.xsip?[index].liveCancel == "LIVE" ? "Live" : "Cancel"}",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              14,
                                                              FontWeight.w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      CustomExchBadge(
                                                        exch:
                                                            "${mfData.mfsiporderlist?.xsip![index].frequencyType}",
                                                      ),
                                                      const SizedBox(width: 5),
                                                       CustomExchBadge(
                                                        exch:
                                                            "${mfData.mfsiporderlist?.xsip![index].dateTime}",
                                                      ),
                                                      const SizedBox(width: 5),
                                                     if(mfData.mfsiporderlist?.xsip?[
                                                                        index]
                                                                    .liveCancel ==
                                                                "LIVE")...[
                                                      CustomExchBadge(
                                                        exch:
                                                            "Due Date : ${mfData.mfsiporderlist?.xsip![index].nextSipDate}",
                                                      ),
                                                      ],
                                                      const Spacer(),
                                                      Text(
                                                        (mfData.mfsiporderlist
                                                                ?.xsip?[index]
                                                                .amount ??
                                                            'N/A'),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Divider between items
                                Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : const Color(0xffECEDEE),
                                  thickness: 2.0,
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
}
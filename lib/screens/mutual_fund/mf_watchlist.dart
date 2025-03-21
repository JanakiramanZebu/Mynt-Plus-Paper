import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MFWatchlistScreen extends ConsumerWidget {
  const MFWatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);
    final mfData = watch(mfProvider);

    return Scaffold(
      body: TransparentLoaderScreen(
        isLoading: mfData.bestmfloader!,
        child: mfData.mfWatchlist!.isEmpty
            ? const Center(child: NoDataFound())
            : Column(
                children: [
                  Container(
                    color: const Color(0xFFF1F3F8),
                    padding: const EdgeInsets.only(
                        left: 12, bottom: 8, top: 8, right: 8),
                    child: const Row(
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
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: mfData.mfWatchlist!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onLongPress: () async {
                              await mfData.fetchMFWatchlist(
                                mfData.mfWatchlist![index].iSIN!,
                                "delete",
                                context,
                                true,
                                "watch",
                              );
                            },
                            onTap: () async {
                              mfData.loaderfun();
                              await mfData.fetchFactSheet(
                                  mfData.mfWatchlist![index].iSIN!);
 mfData.fetchmatchisan(mfData.mfWatchlist![index].iSIN!);
                              Navigator.pushNamed(
                                context,
                                Routes.mfStockDetail,
                                arguments: mfData.mfWatchlist![index],
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.darkGrey
                                        : const Color(0xffEEF0F2),
                                    width:0,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            "https://v3.mynt.in/mf/static/images/mf/${mfData.mfWatchlist![index].aMCCode}.png",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mfData.mfWatchlist![index]
                                                  .schemegroupName!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyles.scripNameTxtStyle
                                                  .copyWith(
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: SizedBox(
                                                height: 18,
                                                child: ListView(
                                                  scrollDirection: Axis.horizontal,
                                                  children: [
                                                    CustomExchBadge(
                                                      exch: "${mfData.mfWatchlist![index].type}"
                                                    ),
                                                     Padding(
                                                      padding:
                                                          EdgeInsets.only(left: 5),
                                                      child: CustomExchBadge(
                                                        exch:
                                                            "${mfData.mfWatchlist![index].schemeType}",
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
                                        "${mfData.mfWatchlist![index].tHREEYEARDATA!.isEmpty ? "0.00" : mfData.mfWatchlist![index].tHREEYEARDATA!}%",
                                        style: textStyle(
                                          double.parse(mfData
                                                      .mfWatchlist![index]
                                                      .tHREEYEARDATA!
                                                      .isEmpty
                                                  ? "0.00"
                                                  : mfData.mfWatchlist![index]
                                                      .tHREEYEARDATA!) >=
                                              0
                                              ? Colors.green
                                              : Colors.red,
                                          14,
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
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
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
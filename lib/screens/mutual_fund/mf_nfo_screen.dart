// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/loader_ui.dart';

class MFNFOScreen extends ConsumerWidget {
  const MFNFOScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mf = watch(mfProvider);
    final theme = watch(themeProvider);
    final fund = watch(fundProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          elevation: 0.2,
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
            "New Fund Offer",
            style: textStyles.appBarTitleTxt.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
      ),
      body: TransparentLoaderScreen(
        isLoading: mf.investloader,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                itemCount: mf.investloader == false ? mf.mfNFOList!.nfoList!.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          mf.chngMandate("Lumpsum");
                          await mf.fetchUpiDetail();
                          await mf.fetchBankDetail();
                        
                          if (mf.mfNFOList!.nfoList![index].sIPFLAG == "Y") {
                            await mf.fetchMFSipData(
                              mf.mfNFOList!.nfoList![index].iSIN!,
                              mf.mfNFOList!.nfoList![index].schemeCode!,
                            );
                            await mf.fetchMFMandateDetail();
                          }
                            mf.orderpagetite("NFO");
                          Navigator.pushNamed(
                            context,
                            Routes.mforderScreen,
                            arguments: mf.mfNFOList!.nfoList![index],
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.symmetric(
                              vertical: BorderSide(
                                color: theme.isDarkMode ? colors.darkGrey : const Color(0xffEEF0F2),
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
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      "https://v3.mynt.in/mf/static/images/mf/${mf.mfNFOList!.nfoList![index].aMCCode}.png",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                             Row(
  children: [
    SizedBox(
      width: MediaQuery.of(context).size.width * 0.65, // 75% of screen width
      child: Text(
        "${mf.mfNFOList!.nfoList![index].fSchemeName ?? ""}",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textStyles.scripNameTxtStyle.copyWith(
          color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        ),
      ),
    ),
  ],
),

                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Open ${mf.mfNFOList!.nfoList![index].startDate!.replaceAll(RegExp(r'\s+'), ' ')}",
                                              style: textStyle(
                                                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                12,
                                                FontWeight.w400,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Text(
                                                "Closing ${mf.mfNFOList!.nfoList![index].endDate!}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
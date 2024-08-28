import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../provider/mf_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import 'mf_category.dart';
import 'mf_category_list.dart';

class MutualFundScreen extends ConsumerWidget {
  const MutualFundScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // final theme = watch(themeProvider);

    final mfData = watch(mfProvider);
    return
        // Scaffold(
        //   appBar: AppBar(
        //       actions: [
        //         IconButton(
        //             splashRadius: 20,
        //             onPressed: () async {

        //          await   mfData .  fetchMFWatchlist(null,"",context,true);
        //              Navigator.pushNamed(context, Routes.mfWatchlist);
        //             },
        //             icon: SvgPicture.asset(
        //                 color: colors.colorBlue, assets.bookmarkIcon)),
        //       ],
        //       elevation: .2,
        //       leadingWidth: 41,
        //       centerTitle: false,
        //       titleSpacing: 6,
        //       leading: const CustomBackBtn(),
        //       shadowColor: const Color(0xffECEFF3),
        //       title: Text("Mutual Funds",
        //           style: textStyles.appBarTitleTxt.copyWith(
        //               color: theme.isDarkMode
        //                   ? colors.colorWhite
        //                   : colors.colorBlack))),
        //   body:
        ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffEEF0F2), width: 1.5),
                color: const Color(0xffF1F3F8),
                borderRadius: BorderRadius.circular(6)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Best mutual funds",
                  style: textStyle(colors.colorBlack, 16, FontWeight.w600)),
              const SizedBox(height: 8),
              Text("Find the right mutual fund across these asset classes",
                  style:
                      textStyle(const Color(0xff666666), 13, FontWeight.w500)),
              const SizedBox(height: 14),
              SizedBox(
                  height: 176,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mfData.bestMFModel!.bestMFList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 160,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: colors.colorWhite,
                            borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              "${mfData.bestMFModel!.bestMFList![index].icon}",
                              height: 50,
                              width: 60,
                            ),
                            Text(
                                "${mfData.bestMFModel!.bestMFList![index].title}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(
                                    colors.colorBlack, 16, FontWeight.w500)),
                            Text(
                                "${mfData.bestMFModel!.bestMFList![index].subtitle}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(const Color(0xff999999), 13,
                                    FontWeight.w500)),
                            Text(
                                "${mfData.bestMFModel!.bestMFList![index].funds!.length} Funds",
                                style: textStyle(
                                    colors.colorBlack, 14, FontWeight.w500)),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 14);
                    },
                  ))
            ])),
        Text("Mutual funds categories",
            style: textStyle(colors.colorBlack, 16, FontWeight.w600)),
        const MfCategory(),
        const MfCategoryList()
      ],
      // ),
    );
  }

  
}

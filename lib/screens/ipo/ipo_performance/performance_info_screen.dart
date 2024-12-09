import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/ipo_model/ipo_performance_model.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';

import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../market_watch/over_view/funtamental_data_widget.dart';

class PerformanceInfoScreen extends StatefulWidget {
  final IpoScrip ipoFundamental;
  final MarketWatchProvider market;
  final int indexipo;
  const PerformanceInfoScreen(
      {super.key,
      required this.ipoFundamental,
      required this.market,
      required this.indexipo});

  @override
  State<PerformanceInfoScreen> createState() => _PerformanceInfoScreenState();
}

class _PerformanceInfoScreenState extends State<PerformanceInfoScreen> {
  double initSize = 0.88;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final theme = watch(themeProvider);
        //final ipoLtp = watch(marketWatchProvider);
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: .99,
          expand: false,
          builder: (context, scrollController) {
            return widget.market.fundamentalData?.msg == "no data found"
                ? Container(
                    child: Text("${widget.market.fundamentalData?.msg}"),
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0xff999999),
                              blurRadius: 4.0,
                              offset: Offset(2.0, 0.0))
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomDragHandler(),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${widget.market.fundamentalData!.fundamental![0].companyName!.toUpperCase()} ",
                                            style: textStyle(
                                                !theme.isDarkMode
                                                    ? colors.colorBlack
                                                    : colors.colorWhite,
                                                16,
                                                FontWeight.w600)),
                                        // Text(widget.wlValue.option,
                                        //     style: textStyle(
                                        //         !theme.isDarkMode
                                        //             ? colors.colorBlack
                                        //             : colors.colorWhite,
                                        //         16,
                                        //         FontWeight.w600)),
                                        // InkWell(
                                        //     onTap: () async {
                                        //       await scripInfo
                                        //           .fetchScripInfo(
                                        //               depthData.token!,
                                        //               depthData.exch!,
                                        //               ctx);
                                        //       if (scripInfo
                                        //               .scripInfoModel!
                                        //               .stat ==
                                        //           "Ok") {
                                        //         showModalBottomSheet(
                                        //             backgroundColor:
                                        //                 const Color(
                                        //                     0xff000000),
                                        //             isScrollControlled:
                                        //                 true,
                                        //             useSafeArea: true,
                                        //             isDismissible: true,
                                        //             shape: const RoundedRectangleBorder(
                                        //                 borderRadius: BorderRadius.vertical(
                                        //                     top: Radius
                                        //                         .circular(
                                        //                             16))),
                                        //             context: context,
                                        //             builder:
                                        //                 (BuildContext
                                        //                     context) {
                                        //               return const ScripDetailDialogue();
                                        //             });
                                        //       }
                                        //     },
                                        //     child: Container(
                                        //         padding:
                                        //             const EdgeInsets
                                        //                 .only(
                                        //                 left: 8,
                                        //                 right: 8,
                                        //                 bottom: 4,
                                        //                 top: 4),
                                        //         child: SvgPicture.asset(
                                        //             assets.dInfo,
                                        //             width: 18,
                                        //             height: 15,
                                        //             color: const Color(
                                        //                 0xff666666))))
                                      ]),
                                  // Text(
                                  //     "₹${widget.market.fundamentalData!.fundamental![0].lp ?? depthData.c ?? 0.00}",
                                  //     style: textStyle(
                                  //         !theme.isDarkMode
                                  //             ? colors.colorBlack
                                  //             : colors.colorWhite,
                                  //         16,
                                  //         FontWeight.w600)),
                                ])),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [FundamentalDataWidget()],
                          ),
                        )
                      ],
                    ),
                  );
          },
        );
      },
    );
  }
}

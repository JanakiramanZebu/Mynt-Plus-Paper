import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/ipo_model/ipo_performance_model.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

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
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        //final ipoLtp = ref.watch(marketWatchProvider);
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: .99,
          expand: false,
          builder: (context, scrollController) {
            return widget.market.fundamentalData?.msg == "no data found"
                ? const Column(
                    children: [
                      const CustomDragHandler(),
                      Padding(
                        padding: const EdgeInsets.only(top: 260),
                        child: NoDataFound(),
                      )
                    ],
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
                        Container(
                          decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : Color(0xfffafbff)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: ClipOval(
                              child: Container(
                                color: colors.colorDivider.withOpacity(.3),
                                width: 50,
                                height: 50,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      widget.ipoFundamental.companyName!
                                          .toUpperCase()
                                          .substring(0, 1),
                                      style: textStyle(colors.colorBlack, 24,
                                          FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${widget.ipoFundamental.companyName!.toUpperCase()} ",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        15,
                                        FontWeight.w600)),
                                const SizedBox(height: 5),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.colorGrey.withOpacity(.1)
                                            : const Color(0xffF1F3F8),
                                        // border: Border.all(
                                        //     color: const Color(0xffC1E7BA)),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                        widget.ipoFundamental.symbol.toString(),
                                        style: textStyle(
                                            const Color(0xff666666),
                                            9,
                                            FontWeight.w500))),
                              ],
                            ),
                          ),
                        ),
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

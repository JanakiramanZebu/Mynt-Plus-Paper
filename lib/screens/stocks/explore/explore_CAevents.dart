import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/no_data_found.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';

class CaEvents extends StatefulWidget {
  const CaEvents({super.key});

  @override
  State<CaEvents> createState() => _CaEventsState();
}

class _CaEventsState extends State<CaEvents> {
  List<String> eventaction = ["Dividend", "Bonus", "Splits", "Rights"];

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final actionEvents = watch(stocksProvide);
      final selectmodel = actionEvents.selctedEventAct;
      final marketWatch = watch(marketWatchProvider);
      final raw = actionEvents.selctedEventAct == 'dividend'
          ? actionEvents.caeventsModel?.dividend
          : actionEvents.selctedEventAct == 'bonus'
              ? actionEvents.caeventsModel?.bonus
              : actionEvents.selctedEventAct == 'splits'
                  ? actionEvents.caeventsModel?.splits
                  : actionEvents.selctedEventAct == 'rights'
                      ? actionEvents.caeventsModel?.rights
                      : [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Events",
                  style:
                      textStyle(const Color(0xff000000), 16, FontWeight.w600)),
              const SizedBox(height: 20),
              SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: eventaction.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: eventaction[index].toLowerCase() ==
                                  actionEvents.selctedEventAct
                              ? const Color(0xff000000)
                              : Colors.transparent,
                          side: BorderSide(
                            width: 1,
                            color: eventaction[index].toLowerCase() ==
                                    actionEvents.selctedEventAct
                                ? const Color(0xff000000)
                                : const Color(0xff666666),
                          ),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                        ),
                        onPressed: () async {
                          actionEvents.chngEventAct(eventaction[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            eventaction[index],
                            style: textStyle(
                                eventaction[index].toLowerCase() ==
                                        actionEvents.selctedEventAct
                                    ? const Color(0xffffffff)
                                    : const Color(0xff666666),
                                13,
                                FontWeight.w600),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 8);
                    },
                  )),
              const SizedBox(height: 16),
            ]),
          ),
          raw != null && raw.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: raw.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await marketWatch.fetchScripQuoteIndex(
                                    raw[index].token.toString(),
                                    raw[index].exch.toString(),
                                    context);

                                final quots = marketWatch.getQuotes;
                                DepthInputArgs depthArgs = DepthInputArgs(
                                    exch: quots!.exch.toString(),
                                    token: quots.token.toString(),
                                    tsym: quots.tsym.toString(),
                                    instname: quots.instname.toString(),
                                    symbol: quots.symbol.toString(),
                                    expDate: quots.expDate.toString(),
                                    option: quots.option.toString());
                                await marketWatch.calldepthApis(
                                    context, depthArgs, "");
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(raw[index].name,
                                            style: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Text("Ex : ${raw[index].exDate}",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                12,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(raw[index].ratio,
                                            style: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Text(
                                            actionEvents.selctedEventAct
                                                .toUpperCase(),
                                            style: textStyle(
                                                const Color(0xff666666),
                                                12,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index != (selectmodel.length - 1)) ...[
                              Divider(
                                color: colors.colorDivider,
                                thickness: 0.6,
                                height: 26,
                              ),
                            ]
                          ],
                        );
                      },
                    ),
                  ],
                )
              : const Center(child: NoDataFound()),
          // const SizedBox(height: 14),
        ],
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}

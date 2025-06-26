import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_exch_badge.dart';

class Allholdings extends StatefulWidget {
  const Allholdings({super.key});

  @override
  State<Allholdings> createState() => _Allholdings();
}

class _Allholdings extends State<Allholdings> {
  final Map<String, bool> _expandedPanels = {};

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final asa = ref.watch(portfolioProvider);

      return StreamBuilder<Map>(
        stream: ref.watch(websocketProvider).socketDataStream,
        builder: (context, snapshot) {
          final socketDatas = snapshot.data ?? {};
          double totvalcurr = 0.00;
          double totvalinv = 0.00;
          String ldate = asa.ldate;
          double allch = 0.00;
          double allchp = 0.00;

          if (asa.allholds.isNotEmpty && socketDatas.isNotEmpty) {
            asa.allholds.forEach((key, value) {
              value['keysval'] = 0;
              value['keysinv'] = 0;

              for (var l in value['summary']) {
                  if (socketDatas.isNotEmpty &&
                      socketDatas.containsKey(l['token'])) {
                    double val = (double.tryParse(
                                socketDatas[l['token']]['lp'].toString()) ??
                              0.0) *
                          (double.tryParse("${l['units']}") ?? 0.0);
                  socketDatas[l['token']]['keysval'] = val.toString();
                  value['keysval'] += val;
                  totvalcurr += val;
                  value['keysinv'] += l['totinv'];
                  totvalinv += l['totinv'];
                }
              }
            });
            allch = (totvalcurr - totvalinv);
            allchp = ((allch / totvalinv) * 100);
          }

          return asa.tphloader
              ? const Center(child: CircularProgressIndicator())
              : asa.allholds.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                      : const Color(0xffF1F3F8)),
                              child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                TextWidget.paraText(
                                                    text: "Current Value",
                                                    theme: false,
                                                    color:
                                                      const Color(0xff5E6B7D),
                                                    fw: 0),
                                              const SizedBox(height: 6),
                                                TextWidget.subText(
                                                    text:
                                                  "₹${getFormatter(value: totvalcurr, v4d: false, noDecimal: false)}",
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                            ],
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                  TextWidget.paraText(
                                                      text: "1D Change",
                                                      theme: false,
                                                      color: const Color(
                                                          0xff5E6B7D),
                                                      fw: 0),
                                                const SizedBox(height: 6),
                                                Row(children: [
                                                    TextWidget.titleText(
                                                        text:
                                                      "₹${getFormatter(value: allch, v4d: false, noDecimal: false)}",
                                                        theme: false,
                                                        color: allchp
                                                                  .toStringAsFixed(
                                                                      2)
                                                                  .startsWith("-")
                                                              ? colors.darkred
                                                              : colors.ltpgreen,
                                                        fw: 0),
                                                    TextWidget.subText(
                                                        text:
                                                      " (${allchp.isNaN ? "0.00" : allchp.toStringAsFixed(2)}%)",
                                                        theme: false,
                                                        color: allchp
                                                                  .toStringAsFixed(
                                                                      2)
                                                                  .startsWith("-")
                                                              ? colors.darkred
                                                              : colors.ltpgreen,
                                                        fw: 0),
                                                ])
                                              ])
                                        ])
                                  ])),
                          Container(
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorWhite,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: theme.isDarkMode
                                              ? const Color(0xffB5C0CF)
                                                  .withOpacity(.15)
                                              : const Color(0xffF1F3F8),
                                          width: 6))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                      TextWidget.subText(
                                          text: 'Last sync: ',
                                          theme: false,
                                          color: colors.colorGrey,
                                          fw: 0),
                                      TextWidget.subText(
                                          text: ldate,
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                  ],
                                ),
                              )),
                          ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: asa.allholds.keys.length,
                            itemBuilder: (context, index) {
                              String key = asa.allholds.keys.elementAt(index);
                              String imageUrl =
                                  'https://rekycbe.mynt.in/portfolio/';
                              final phaseo = asa.allholds[key]['summary'];
                              if (!_expandedPanels.containsKey(key)) {
                                _expandedPanels[key] = false;
                              }
                              double panelsum = 0;
                              double panelinv = 0;
                              if (asa.allholds[key]['keysval'] != 'Null') {
                                  panelsum =
                                      (asa.allholds[key]['keysval'] ?? 0.0)
                                    .toDouble();
                                  panelinv =
                                      (asa.allholds[key]['keysinv'] ?? 0.0)
                                    .toDouble();
                              }
                              String keych =
                                  (panelsum - panelinv).toStringAsFixed(2);
                              String keychp =
                                  ((double.parse(keych) / panelinv) * 100)
                                      .toStringAsFixed(2);
                              return ExpansionPanelList(
                                elevation: 0,
                                expandIconColor: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                expansionCallback: (panelIndex, isExpanded) {
                                  setState(() {
                                      _expandedPanels[key] =
                                          !_expandedPanels[key]!;
                                  });
                                },
                                children: [
                                  ExpansionPanel(
                                    backgroundColor: !theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    headerBuilder: (context, isExpanded) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: isExpanded ? 0 : 6),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                            child: ClipOval(
                                              child: Image.network(
                                                imageUrl +
                                                      asa.allholds[key]
                                                              ['profile']
                                                            ['logopath']
                                                        .toString(),
                                                fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 200,
                                                      child:
                                                          TextWidget.paraText(
                                                              text: key,
                                                              theme: theme
                                                                  .isDarkMode,
                                                              fw: 0,
                                                              textOverflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                        maxLines: 1),
                                                  ),
                                                    TextWidget.paraText(
                                                        text:
                                                            '(${phaseo.length})',
                                                        theme: theme.isDarkMode,
                                                        fw: 0),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                      TextWidget.subText(
                                                          text: (panelsum != 0)
                                                            ? (panelsum
                                                                  .toStringAsFixed(
                                                                      2))
                                                            : '0.0',
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 0),
                                                      TextWidget.subText(
                                                          text:
                                                              "  $keych ($keychp%)",
                                                          theme: false,
                                                          color: keych
                                                                  .startsWith(
                                                                      "-")
                                                                ? colors.darkred
                                                                : keych == "0.00"
                                                                  ? colors
                                                                      .ltpgrey
                                                                    : colors
                                                                        .ltpgreen,
                                                          fw: 0),
                                                  ]),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    body: Column(
                                      children: [
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            itemCount: phaseo.length,
                                            itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                              final raw = phaseo[index];
                                              String ltp = '0';
                                              String ch = '0.00';
                                              String chp = '0.00';
                                              String val = '0.00';
                                                if (socketDatas.containsKey(
                                                    raw['token'])) {
                                                  ltp =
                                                      socketDatas[raw['token']]
                                                        ['lp']
                                                    .toString();
                                                ch = socketDatas[raw['token']]
                                                        ['chng']
                                                    .toString();
                                                  chp =
                                                      socketDatas[raw['token']]
                                                        ['pc']
                                                    .toString();

                                                val = double.parse(
                                                          socketDatas[
                                                                  raw['token']]
                                                            ['keysval'])
                                                    .toStringAsFixed(2);
                                              }
                                              return Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                      children: [
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                                TextWidget.subText(
                                                                    text:
                                                                  "${raw['symbol']} ",
                                                                    theme: theme
                                                                        .isDarkMode,
                                                                    fw: 0,
                                                                    textOverflow:
                                                                      TextOverflow
                                                                            .ellipsis),
                                                              Row(children: [
                                                                  TextWidget.paraText(
                                                                      text:
                                                                          " LTP: ",
                                                                      theme:
                                                                          false,
                                                                      color: const Color(
                                                                            0xff5E6B7D),
                                                                      fw: 1),
                                                                  TextWidget.subText(
                                                                      text:
                                                                          "₹$ltp",
                                                                      theme: theme
                                                                          .isDarkMode,
                                                                      fw: 0),
                                                              ])
                                                            ]),
                                                          const SizedBox(
                                                              height: 4),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              CustomExchBadge(
                                                                  exch:
                                                                      "${raw['exch']}"),
                                                                TextWidget.paraText(
                                                                    text: " $ch ($chp%)",
                                                                    theme: false,
                                                                    color: ch.startsWith("-")
                                                                        ? colors.darkred
                                                                        : ch == "0.00"
                                                                            ? colors.ltpgrey
                                                                            : colors.ltpgreen,
                                                                    fw: 0),
                                                            ]),
                                                        Divider(
                                                            height: 12,
                                                            thickness: 0.4,
                                                            color: theme.isDarkMode
                                                                ? colors
                                                                    .darkColorDivider
                                                                : colors
                                                                    .colorDivider),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                      TextWidget.subText(
                                                                          text:
                                                                              "Qty: ",
                                                                          theme:
                                                                              false,
                                                                          color:
                                                                              const Color(0xff5E6B7D),
                                                                          fw: 0),
                                                                      TextWidget.subText(
                                                                          text:
                                                                        "${raw['units'] ?? 0}",
                                                                          theme:
                                                                              theme.isDarkMode,
                                                                          fw: 0),
                                                                  ]),
                                                              Row(children: [
                                                                  TextWidget.subText(
                                                                      text:
                                                                          "Cur: ",
                                                                      theme:
                                                                          false,
                                                                      color: const Color(
                                                                            0xff5E6B7D),
                                                                      fw: 0),
                                                                  TextWidget.subText(
                                                                      text:
                                                                          "₹$val",
                                                                      theme: theme
                                                                          .isDarkMode,
                                                                      fw: 0),
                                                              ])
                                                            ]),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Divider(
                                                            height: 0,
                                                            thickness: 1,
                                                            color: theme.isDarkMode
                                                                ? colors
                                                                    .darkColorDivider
                                                                : colors
                                                                    .colorDivider),
                                                      ]));
                                            })
                                      ],
                                    ),
                                    isExpanded: _expandedPanels[key]!,
                                    canTapOnHeader: true,
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          TextWidget.heroText(
                              text: 'Total Portfolio',
                              theme: theme.isDarkMode,
                              fw: 2),
                        const SizedBox(
                          height: 10,
                        ),
                          TextWidget.subText(
                              text: 'Click sync to fetch your holdings...',
                              theme: false,
                              color: colors.colorGrey,
                              fw: 0),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                backgroundColor: theme.isDarkMode
                                    ? colors.colorbluegrey
                                    : colors.colorBlack,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            onPressed: () {
                              if (asa.loading == false) {
                                asa.fetchCamRedirct(context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: asa.loading
                                  ? SizedBox(
                                      width: 18,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                          color: !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack),
                                    )
                                    : TextWidget.titleText(
                                        text: "Sync",
                                        theme: theme.isDarkMode,
                                        fw: 1),
                            )),
                      ],
                    ));
          });
    });
  }
}

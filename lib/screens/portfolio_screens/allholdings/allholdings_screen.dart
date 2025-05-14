import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
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
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = context.read(themeProvider);
      final asa = watch(portfolioProvider);

      return StreamBuilder<Map>(
        stream: watch(websocketProvider).socketDataStream,
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
                if (socketDatas.isNotEmpty && socketDatas.containsKey(l['token'])) {
                  double val =
                      (double.tryParse(socketDatas[l['token']]['lp'].toString()) ??
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
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Current Value",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      12,
                                                      FontWeight.w500)),
                                              const SizedBox(height: 6),
                                              Text(
                                                  "₹${getFormatter(value: totvalcurr, v4d: false, noDecimal: false)}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text("1D Change",
                                                    style: textStyle(
                                                        const Color(0xff5E6B7D),
                                                        12,
                                                        FontWeight.w500)),
                                                const SizedBox(height: 6),
                                                Row(children: [
                                                  Text(
                                                      "₹${getFormatter(value: allch, v4d: false, noDecimal: false)}",
                                                      style: textStyle(
                                                          allchp
                                                                  .toStringAsFixed(
                                                                      2)
                                                                  .startsWith("-")
                                                              ? colors.darkred
                                                              : colors.ltpgreen,
                                                          16,
                                                          FontWeight.w500)),
                                                  Text(
                                                      " (${allchp.isNaN ? "0.00" : allchp.toStringAsFixed(2)}%)",
                                                      style: textStyle(
                                                          allchp
                                                                  .toStringAsFixed(
                                                                      2)
                                                                  .startsWith("-")
                                                              ? colors.darkred
                                                              : colors.ltpgreen,
                                                          14,
                                                          FontWeight.w500))
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
                                    Text(
                                      'Last sync: ',
                                      style: textStyle(
                                          colors.colorGrey, 13, FontWeight.w500),
                                    ),
                                    Text(
                                      ldate,
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                          13,
                                          FontWeight.w500),
                                    ),
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
                                panelsum = (asa.allholds[key]['keysval'] ?? 0.0)
                                    .toDouble();
                                panelinv = (asa.allholds[key]['keysinv'] ?? 0.0)
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
                                    _expandedPanels[key] = !_expandedPanels[key]!;
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
                                            backgroundColor: Colors.transparent,
                                            child: ClipOval(
                                              child: Image.network(
                                                imageUrl +
                                                    asa.allholds[key]['profile']
                                                            ['logopath']
                                                        .toString(),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) =>
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
                                                    child: Text(key,
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors.colorBlack,
                                                            12,
                                                            FontWeight.w500),
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        maxLines: 1),
                                                  ),
                                                  Text('(${phaseo.length})',
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors.colorWhite
                                                              : colors.colorBlack,
                                                          12,
                                                          FontWeight.w500))
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        (panelsum != 0)
                                                            ? (panelsum
                                                                .toStringAsFixed(2))
                                                            : '0.0',
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors.colorWhite
                                                                : colors.colorBlack,
                                                            14,
                                                            FontWeight.w500)),
                                                    Text("  $keych ($keychp%)",
                                                        style: textStyle(
                                                            keych.startsWith("-")
                                                                ? colors.darkred
                                                                : keych == "0.00"
                                                                    ? colors.ltpgrey
                                                                    : colors
                                                                        .ltpgreen,
                                                            14,
                                                            FontWeight.w500))
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            itemCount: phaseo.length,
                                            itemBuilder:
                                                (BuildContext context, int index) {
                                              final raw = phaseo[index];
                                              String ltp = '0';
                                              String ch = '0.00';
                                              String chp = '0.00';
                                              String val = '0.00';
                                              if (socketDatas
                                                  .containsKey(raw['token'])) {
                                                ltp = socketDatas[raw['token']]
                                                        ['lp']
                                                    .toString();
                                                ch = socketDatas[raw['token']]
                                                        ['chng']
                                                    .toString();
                                                chp = socketDatas[raw['token']]
                                                        ['pc']
                                                    .toString();

                                                val = double.parse(
                                                        socketDatas[raw['token']]
                                                            ['keysval'])
                                                    .toStringAsFixed(2);
                                              }
                                              return Container(
                                                  padding: const EdgeInsets.all(8),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  "${raw['symbol']} ",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: textStyles
                                                                      .scripNameTxtStyle
                                                                      .copyWith(
                                                                          color: theme.isDarkMode
                                                                              ? colors
                                                                                  .colorWhite
                                                                              : colors
                                                                                  .colorBlack)),
                                                              Row(children: [
                                                                Text(" LTP: ",
                                                                    style: textStyle(
                                                                        const Color(
                                                                            0xff5E6B7D),
                                                                        13,
                                                                        FontWeight
                                                                            .w600)),
                                                                Text("₹$ltp",
                                                                    style: textStyle(
                                                                        theme.isDarkMode
                                                                            ? colors
                                                                                .colorWhite
                                                                            : colors
                                                                                .colorBlack,
                                                                        14,
                                                                        FontWeight
                                                                            .w500))
                                                              ])
                                                            ]),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              CustomExchBadge(
                                                                  exch:
                                                                      "${raw['exch']}"),
                                                              Text(" $ch ($chp%)",
                                                                  style: textStyle(
                                                                      ch.startsWith(
                                                                              "-")
                                                                          ? colors
                                                                              .darkred
                                                                          : ch ==
                                                                                  "0.00"
                                                                              ? colors
                                                                                  .ltpgrey
                                                                              : colors
                                                                                  .ltpgreen,
                                                                      12,
                                                                      FontWeight
                                                                          .w500))
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
                                                                    Text("Qty: ",
                                                                        style: textStyle(
                                                                            const Color(
                                                                                0xff5E6B7D),
                                                                            14,
                                                                            FontWeight
                                                                                .w500)),
                                                                    Text(
                                                                        "${raw['units'] ?? 0}",
                                                                        style: textStyle(
                                                                            theme.isDarkMode
                                                                                ? colors
                                                                                    .colorWhite
                                                                                : colors
                                                                                    .colorBlack,
                                                                            14,
                                                                            FontWeight
                                                                                .w500)),
                                                                  ]),
                                                              Row(children: [
                                                                Text("Cur: ",
                                                                    style: textStyle(
                                                                        const Color(
                                                                            0xff5E6B7D),
                                                                        14,
                                                                        FontWeight
                                                                            .w500)),
                                                                Text("₹$val",
                                                                    style: textStyle(
                                                                        theme.isDarkMode
                                                                            ? colors
                                                                                .colorWhite
                                                                            : colors
                                                                                .colorBlack,
                                                                        14,
                                                                        FontWeight
                                                                            .w500))
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
                        Text(
                          'Total Portfolio',
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              20,
                              FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Click sync to fetch your holdings...',
                          style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                        ),
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
                                  : Text("Sync",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          16,
                                          FontWeight.w600)),
                            )),
                      ],
                    ));
        }
      );
    });
  }
}

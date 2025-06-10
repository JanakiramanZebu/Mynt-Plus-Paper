// ignore_for_file: deprecated_member_use
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model/broker_message_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_alert_pending.dart';

class PendingAlert extends ConsumerStatefulWidget {
  const PendingAlert({super.key});

  @override
  ConsumerState<PendingAlert> createState() => _PendingAlertState();
}

class _PendingAlertState extends ConsumerState<PendingAlert> {
  bool _isPendingAlertsExpanded = true;
  bool _isTriggeredAlertsExpanded = false;
  List<BrokerMessage>? triggeredAlerts;

  @override
  void initState() {
    super.initState();
    // Fetch initial data when widget is created
    _refreshData();
    
    // Add post-frame callback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }
  
  // Combined method to refresh all data
  Future<void> _refreshData() async {
    if (!mounted) return;
    
    // Fetch both types of data
    await ref.read(marketWatchProvider).fetchPendingAlert(context);
    await _fetchTriggeredAlerts();
  }

  // Fetch triggered alerts from broker messages
  Future<void> _fetchTriggeredAlerts() async {
    if (!mounted) return;
    await ref.read(notificationprovider).fetchbrokermsg(context);
  }

  @override
  Widget build(BuildContext context) {
    final manage = ref.watch(marketWatchProvider);
    final notification = ref.watch(notificationprovider);
    final theme = ref.read(themeProvider);
    double angleInDegrees = 55;
    double angleInRadians = angleInDegrees * (pi / 180);

    // Using ref.listen to detect changes in the alerts data
    ref.listen<MarketWatchProvider>(marketWatchProvider, (previous, current) {
      // This will be called whenever the marketWatchProvider changes
      // We don't need to do anything here since the widget will rebuild automatically
    });

    // Using ref.listen to detect changes in the notification data
    ref.listen<NotificationProvider>(notificationprovider, (previous, current) {
      // This will be called whenever the notificationprovider changes
      // We don't need to do anything here since the widget will rebuild automatically
    });

    // Filter broker messages that are related to alerts
    triggeredAlerts = notification.brokermsg?.where((msg) => 
        msg.dmsg != null && 
        msg.dmsg!.contains("Ltp") && 
        (msg.dmsg!.contains("above") || msg.dmsg!.contains("below"))
    ).toList() ?? [];
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // Pending Alerts Expandable Section
          Container(
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  border: Border(
                      bottom: BorderSide(
                    color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    width: 1
                  )
                )
              ),
              child: ExpansionTile(
                initiallyExpanded: _isPendingAlertsExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isPendingAlertsExpanded = expanded;
                  });
                },
                title: Text(
                  "Pending Alerts (${manage.alertPendingModel!.length > 0 && manage.alertPendingModel![0].stat != "Not_Ok" ? manage.alertPendingModel!.length : 0})",
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600
                  ),
                ),
                trailing: Icon(
                  _isPendingAlertsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
                children: [
                  // Search and Filter Controls
                  if (manage.alertPendingModel!.length > 1)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                            width: 1
                          )
                        )
                      ),
              child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 2, top: 8, bottom: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                            Row(
                              children: [
                          InkWell(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                showModalBottomSheet(
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                                      ),
                                    context: context,
                                    builder: (context) {
                                      return const OrderbookPendingAlertkFilterBottomSheet();
                                      }
                                    );
                              },
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                    child: SvgPicture.asset(
                                      assets.filterLines,
                                      color: const Color(0xff333333)
                                    )
                                  )
                                ),
                          InkWell(
                              onTap: () {
                                manage.showAlertPendingSearch(true);
                              },
                              child: Padding(
                                    padding: const EdgeInsets.only(right: 12, left: 10),
                                    child: SvgPicture.asset(
                                      assets.searchIcon,
                                      width: 19,
                                      color: const Color(0xff333333)
                                    )
                                  )
                                )
                              ]
                            )
                          ]
                        )
                      )
                    ),
                  
                  // Search Box
        if (manage.showAlertSearch)
          Container(
            height: 62,
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                            color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                            width: 1
                          )
                        )
                      ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                    controller: manage.alertPendingSearchtext,
                              style: textStyle(const Color(0xff000000), 16, FontWeight.w600),
                    decoration: InputDecoration(
                        fillColor: const Color(0xffF1F3F8),
                        filled: true,
                                hintStyle: textStyle(const Color(0xff69758F), 15, FontWeight.w500),
                        prefixIconColor: const Color(0xff586279),
                        prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: SvgPicture.asset(
                                    assets.searchIcon,
                              color: const Color(0xff586279),
                              fit: BoxFit.contain,
                                    width: 20
                                  ),
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            manage.clearAlertSearch();
                          },
                          child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: SvgPicture.asset(
                                      assets.removeIcon,
                                      fit: BoxFit.scaleDown,
                                      width: 20
                                    ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                        hintText: "Search Scrip Name",
                        contentPadding: const EdgeInsets.only(top: 20),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)
                                )
                              ),
                    onChanged: (value) async {
                      manage.orderAletrPendingSearch(value, context);
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      manage.showAlertPendingSearch(false);
                      manage.clearAlertSearch();
                    },
                            child: Text("Close", style: textStyles.textBtn)
                          )
              ],
            ),
          ),
                  
                  // Pending Alerts List
        if (manage.alertPendingSearch!.isEmpty)
          manage.alertPendingModel!.isNotEmpty &&
                  manage.alertPendingModel![0].stat != "Not_Ok"
              ? ListView.separated(
                          primary: false,
                  reverse: true,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () async {
                                Navigator.pushNamed(context, Routes.pendingalertdetails,
                              arguments: manage.alertPendingModel![index]);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${manage.alertPendingModel![index].tsym} ",
                                            overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripNameTxtStyle.copyWith(
                                            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
                                          )
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              " LTP: ",
                                              style: textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)
                                            ),
                                            Text(
                                                "₹${manage.alertPendingModel![index].ltp ?? manage.alertPendingModel![index].close ?? 0.00}",
                                                style: textStyle(
                                                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                    14,
                                                FontWeight.w500
                                              )
                                            ),
                                          ],
                                        )
                                      ]
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomExchBadge(exch: "${manage.alertPendingModel![index].exch}"),
                                        Text(
                                            " (${manage.alertPendingModel![index].perChange ?? 0.00}%)",
                                            style: textStyle(
                                            manage.alertPendingModel![index].perChange == null
                                                    ? colors.ltpgrey
                                              : manage.alertPendingModel![index].perChange!.startsWith("-")
                                                        ? colors.darkred
                                                : manage.alertPendingModel![index].perChange == "0.00"
                                                            ? colors.ltpgrey
                                                            : colors.ltpgreen,
                                                12,
                                            FontWeight.w500
                                          )
                                        )
                                      ]
                                    ),
                                  const SizedBox(height: 4),
                                  Divider(
                                      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider
                                    ),
                                  const SizedBox(height: 5),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Alert: ",
                                              style: textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)
                                            ),
                                            Text(
                                              manage.alertPendingModel![index].aiT == "LTP_A"
                                                    ? "LTP Above"
                                                : manage.alertPendingModel![index].aiT == "LTP_B"
                                                        ? "LTP Below"
                                                  : manage.alertPendingModel![index].aiT == "CH_PER_A"
                                                                ? "Perc.Change Above"
                                                                : "Perc.Change below",
                                                style: textStyle(
                                                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                    14,
                                                FontWeight.w500
                                              )
                                            ),
                                            Transform.rotate(
                                              angle: angleInRadians,
                                              child: Icon(
                                                manage.alertPendingModel![index].aiT == "LTP_A"
                                                  ? Icons.arrow_upward
                                                  : manage.alertPendingModel![index].aiT == "LTP_B"
                                                    ? Icons.arrow_downward
                                                    : manage.alertPendingModel![index].aiT == "CH_PER_A"
                                                      ? Icons.arrow_upward
                                                      : Icons.arrow_downward,
                                                  size: 18,
                                                color: manage.alertPendingModel![index].aiT == "LTP_A"
                                                  ? colors.ltpgreen
                                                  : manage.alertPendingModel![index].aiT == "LTP_B"
                                                    ? colors.darkred
                                                    : manage.alertPendingModel![index].aiT == "CH_PER_A"
                                                      ? colors.ltpgreen
                                                      : colors.darkred
                                              ),
                                              ),
                                            Text(
                                              manage.alertPendingModel![index].aiT == "CH_PER_A" ||
                                                manage.alertPendingModel![index].aiT == "CH_PER_B"
                                                  ? "%${manage.alertPendingModel![index].d}"
                                                  : "₹${manage.alertPendingModel![index].d}"
                                            ),
                                            ],
                                          ),
                                      ]
                                    )
                                  ]
                                )
                              )
                            );
                  },
                  itemCount: manage.alertPendingModel!.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                              color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                              height: 6
                            );
                          },
                        )
                      : const SizedBox(height: 200, child: Center(child: NoDataFound()))
                ],
              ),
            ),
            
            // Triggered Alerts Expandable Section
            Container(
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    width: 1
                  )
                )
              ),
              child: ExpansionTile(
                initiallyExpanded: _isTriggeredAlertsExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isTriggeredAlertsExpanded = expanded;
                  });
                },
                title: Text(
                  "Triggered Alerts (${triggeredAlerts?.length ?? 0})",
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600
                  ),
                ),
                trailing: Icon(
                  _isTriggeredAlertsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
                children: [
                  // Triggered Alerts List
                  triggeredAlerts != null && triggeredAlerts!.isNotEmpty
                    ? ListView.separated(
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${triggeredAlerts![index].norentm}",
                                  style: textStyle(
                                    const Color(0xff5E6B7D),
                                    12,
                                    FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${triggeredAlerts![index].dmsg}",
                                  style: textStyle(
                                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                    14,
                                    FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: triggeredAlerts!.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                          );
                  },
                )
              : const SizedBox(
                        height: 100,
                        child: Center(child: NoDataFound())
                      )
                ],
              ),
            ),
            
            // Show the list item based on search
        if (manage.alertPendingSearch!.isNotEmpty)
          ListView.separated(
                primary: false,
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () async {
                    Navigator.pushNamed(context, Routes.pendingalertdetails,
                        arguments: manage.alertPendingSearch![index]);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${manage.alertPendingSearch![index].tsym} ",
                                      overflow: TextOverflow.ellipsis,
                                style: textStyles.scripNameTxtStyle.copyWith(
                                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack
                                )
                              ),
                                  Row(
                                    children: [
                                  Text(
                                    " LTP: ",
                                    style: textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)
                                  ),
                                      Text(
                                          "₹${manage.alertPendingSearch![index].ltp ?? manage.alertPendingSearch![index].close ?? 0.00}",
                                          style: textStyle(
                                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                              14,
                                      FontWeight.w500
                                    )
                                  ),
                                    ],
                                  )
                            ]
                          ),
                            const SizedBox(height: 4),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                              CustomExchBadge(exch: "${manage.alertPendingSearch![index].exch}"),
                                  Text(
                                      " (${manage.alertPendingSearch![index].perChange ?? 0.00}%)",
                                      style: textStyle(
                                  manage.alertPendingSearch![index].perChange == null
                                              ? colors.ltpgrey
                                    : manage.alertPendingSearch![index].perChange!
                                                      .startsWith("-")
                                                  ? colors.darkred
                                      : manage.alertPendingSearch![index].perChange == "0.00"
                                                      ? colors.ltpgrey
                                                      : colors.ltpgreen,
                                          12,
                                  FontWeight.w500
                                )
                              )
                            ]
                          ),
                            const SizedBox(height: 4),
                            Divider(
                            color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider
                          ),
                            const SizedBox(height: 5),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                    "Alert: ",
                                    style: textStyle(const Color(0xff5E6B7D), 13, FontWeight.w600)
                                  ),
                                  Text(
                                    manage.alertPendingSearch![index].aiT == "LTP_A"
                                              ? "LTP Above"
                                      : manage.alertPendingSearch![index].aiT == "LTP_B"
                                                  ? "LTP Below"
                                        : manage.alertPendingSearch![index].aiT == "CH_PER_A"
                                                          ? "Perc.Change Above"
                                                          : "Perc.Change below",
                                          style: textStyle(
                                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                              14,
                                      FontWeight.w500
                                    )
                                  ),
                                      Transform.rotate(
                                        angle: angleInRadians,
                                        child: Icon(
                                      manage.alertPendingSearch![index].aiT == "LTP_A"
                                                ? Icons.arrow_upward
                                        : manage.alertPendingSearch![index].aiT == "LTP_B"
                                                    ? Icons.arrow_downward
                                          : manage.alertPendingSearch![index].aiT == "CH_PER_A"
                                                        ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                            size: 18,
                                      color: manage.alertPendingSearch![index].aiT == "LTP_A"
                                                ? colors.ltpgreen
                                        : manage.alertPendingSearch![index].aiT == "LTP_B"
                                                    ? colors.darkred
                                          : manage.alertPendingSearch![index].aiT == "CH_PER_A"
                                                            ? colors.ltpgreen
                                            : colors.darkred
                                    ),
                                        ),
                                  Text(
                                    manage.alertPendingSearch![index].aiT == "CH_PER_A" ||
                                      manage.alertPendingSearch![index].aiT == "CH_PER_B"
                                            ? "%${manage.alertPendingSearch![index].d}"
                                        : "₹${manage.alertPendingSearch![index].d}"
                                  ),
                                    ],
                                  ),
                            ]
                          )
                        ]
                      )
                    )
                  );
              },
              itemCount: manage.alertPendingSearch!.length,
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                    color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    height: 6
                  );
              },
            ),
      ],
        )
      )
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontWeight: fWeight, 
        color: color, 
        fontSize: fontSize
      )
    );
  }
}

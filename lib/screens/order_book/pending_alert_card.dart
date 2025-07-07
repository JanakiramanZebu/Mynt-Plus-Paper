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
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/no_data_found.dart';
import 'filter_alert_pending.dart';
import '../../provider/order_provider.dart';
import 'pending_alert_detail_screen.dart';

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
    final order = ref.watch(orderProvider);
    final theme = ref.read(themeProvider);
    double angleInDegrees = 55;
    double angleInRadians = angleInDegrees * (pi / 180);

    final isSearching = order.orderSearchCtrl.text.isNotEmpty;
    final pendingAlerts = isSearching
        ? manage.alertPendingSearch ?? []
        : manage.alertPendingModel ?? [];

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
    triggeredAlerts = notification.brokermsg
            ?.where((msg) =>
                msg.dmsg != null &&
                msg.dmsg!.contains("Ltp") &&
                (msg.dmsg!.contains("above") || msg.dmsg!.contains("below")))
            .toList() ??
        [];

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
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              width: 1))),
                  child: ExpansionTile(
                    initiallyExpanded: _isPendingAlertsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isPendingAlertsExpanded = expanded;
                      });
                    },
                    title: TextWidget.titleText(
                        text:
                            "Pending Alerts (${pendingAlerts.isNotEmpty && pendingAlerts[0].stat != "Not_Ok" ? pendingAlerts.length : 0})",
                        theme: theme.isDarkMode,
                        fw: 1),
                    trailing: Icon(
                      _isPendingAlertsExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                    children: [
                      if (pendingAlerts.isEmpty ||
                          (pendingAlerts.isNotEmpty &&
                              pendingAlerts[0].stat == "Not_Ok"))
                        const Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 20),
                          child: NoDataFound(),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingAlerts.length,
                          itemBuilder: (context, index) {
                            final alert = pendingAlerts[index];
                            return InkWell(
                                onTap: () async {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    isDismissible: true,
                                    enableDrag: false,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (context) => Container(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child:
                                            PendingAlertDetails(alert: alert)),
                                  );
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextWidget.subText(
                                                    text: "${alert.tsym} ",
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimary
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 0,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                                Row(
                                                  children: [
                                                    TextWidget.paraText(
                                                        text: "LTP ",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                    TextWidget.paraText(
                                                        text:
                                                            "${alert.ltp ?? alert.close ?? 0.00}",
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                  ],
                                                )
                                              ]),
                                          const SizedBox(height: 4),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomExchBadge(
                                                    exch: "${alert.exch}"),
                                                TextWidget.paraText(
                                                    text:
                                                        " (${alert.perChange ?? 0.00}%)",
                                                    theme: false,
                                                    color: alert.perChange ==
                                                            null
                                                        ? theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight
                                                        : alert.perChange!
                                                                .startsWith("-")
                                                            ? theme.isDarkMode
                                                                ? colors
                                                                    .lossDark
                                                                : colors
                                                                    .lossLight
                                                            : alert.perChange ==
                                                                    "0.00"
                                                                ? theme
                                                                        .isDarkMode
                                                                    ? colors
                                                                        .textSecondaryDark
                                                                    : colors
                                                                        .textSecondaryLight
                                                                : theme
                                                                        .isDarkMode
                                                                    ? colors
                                                                        .profitDark
                                                                    : colors
                                                                        .profitLight,
                                                    fw: 3),
                                              ]),
                                          const SizedBox(height: 4),
                                          Divider(
                                              color: theme.isDarkMode
                                                  ? colors.darkColorDivider
                                                  : colors.colorDivider),
                                          const SizedBox(height: 5),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextWidget.paraText(
                                                        text: "Alert ",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                    TextWidget.paraText(
                                                        text: alert.aiT ==
                                                                "LTP_A"
                                                            ? "LTP Above"
                                                            : alert.aiT ==
                                                                    "LTP_B"
                                                                ? "LTP Below"
                                                                : alert.aiT ==
                                                                        "CH_PER_A"
                                                                    ? "Perc.Change Above"
                                                                    : "Perc.Change below",
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                    Transform.rotate(
                                                      angle: angleInRadians,
                                                      child: Icon(
                                                          alert.aiT == "LTP_A"
                                                              ? Icons
                                                                  .arrow_upward
                                                              : alert.aiT ==
                                                                      "LTP_B"
                                                                  ? Icons
                                                                      .arrow_downward
                                                                  : alert.aiT ==
                                                                          "CH_PER_A"
                                                                      ? Icons
                                                                          .arrow_upward
                                                                      : Icons
                                                                          .arrow_downward,
                                                          size: 18,
                                                          color: alert.aiT ==
                                                                  "LTP_A"
                                                              ? theme.isDarkMode
                                                                  ? colors
                                                                      .profitDark
                                                                  : colors
                                                                      .profitLight
                                                              : alert.aiT ==
                                                                      "LTP_B"
                                                                  ? theme
                                                                          .isDarkMode
                                                                      ? colors
                                                                          .lossDark
                                                                      : colors
                                                                          .lossLight
                                                                  : alert.aiT ==
                                                                          "CH_PER_A"
                                                                      ? theme
                                                                              .isDarkMode
                                                                          ? colors
                                                                              .profitDark
                                                                          : colors
                                                                              .profitLight
                                                                      : theme
                                                                              .isDarkMode
                                                                          ? colors
                                                                              .lossDark
                                                                          : colors
                                                                              .lossLight),
                                                    ),
                                                    TextWidget.paraText(
                                                        text: alert.aiT ==
                                                                    "CH_PER_A" ||
                                                                alert.aiT ==
                                                                    "CH_PER_B"
                                                            ? "%${alert.d}"
                                                            : "₹${alert.d}",
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                  ],
                                                ),
                                              ])
                                        ])));
                          },
                        )
                    ],
                  ),
                ),

                // Triggered Alerts Expandable Section
                Container(
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : colors.colorWhite,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              width: 1))),
                  child: ExpansionTile(
                    initiallyExpanded: _isTriggeredAlertsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isTriggeredAlertsExpanded = expanded;
                      });
                    },
                    title: TextWidget.titleText(
                        text:
                            "Triggered Alerts (${triggeredAlerts?.length ?? 0})",
                        theme: theme.isDarkMode,
                        fw: 1),
                    trailing: Icon(
                      _isTriggeredAlertsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget.paraText(
                                          text:
                                              "${triggeredAlerts![index].norentm}",
                                          theme: false,
                                          color: const Color(0xff5E6B7D),
                                          fw: 0),
                                      const SizedBox(height: 8),
                                      TextWidget.subText(
                                          text:
                                              "${triggeredAlerts![index].dmsg}",
                                          theme: theme.isDarkMode,
                                          fw: 0),
                                    ],
                                  ),
                                );
                              },
                              itemCount: triggeredAlerts!.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider,
                                );
                              },
                            )
                          : const SizedBox(
                              height: 200, child: Center(child: NoDataFound()))
                    ],
                  ),
                ),
              ],
            )));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

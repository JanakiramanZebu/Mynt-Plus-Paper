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
import '../../sharedWidget/list_divider.dart';
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
    ref.listen<MarketWatchProvider>(
        marketWatchProvider, (previous, current) {});
    ref.listen<NotificationProvider>(
        notificationprovider, (previous, current) {});

    // Filter broker messages that are related to alerts
    triggeredAlerts = notification.brokermsg
            ?.where((msg) =>
                msg.dmsg != null &&
                msg.dmsg!.contains("Ltp") &&
                (msg.dmsg!.contains("above") || msg.dmsg!.contains("below")))
            .toList() ??
        [];

    // Combine pending and triggered alerts (pending first)
    final List<dynamic> allAlerts = [
      ...pendingAlerts,
      ...(triggeredAlerts ?? [])
    ];

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //   child: TextWidget.titleText(
            //     text: "Alerts (${allAlerts.length})",
            //     theme: theme.isDarkMode,
            //     fw: 1,
            //   ),
            // ),
            _buildAlertList(allAlerts, theme, angleInRadians),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertList(List<dynamic> alerts, theme, double angleInRadians) {
    if (alerts.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: NoDataFound()),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        if (alert is BrokerMessage) {
          return _buildTriggeredAlertCard(alert, theme);
        } else {
          return _buildPendingAlertCard(alert, theme, angleInRadians);
        }
      },
    );
  }

  Widget _buildTriggeredAlertCard(BrokerMessage alert, theme) {
    return Container(
      color: theme.isDarkMode
          ? colors.textSecondaryDark.withOpacity(0.2)
          : colors.textSecondaryLight.withOpacity(0.2),
      child: Column(
        children: [
          // Divider(
          //   color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          //   thickness: 0,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextWidget.paraText(
                      text: "${alert.norentm}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 3,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.primaryDark.withOpacity(0.1)
                            : colors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextWidget.paraText(
                        text: "TRIGGERED",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        fw: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextWidget.paraText(
                  text: "${alert.dmsg}",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListDivider(),
          // Divider(
          //   color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          //   thickness: 0,
          // ),
        ],
      ),
    );
  }

  Widget _buildPendingAlertCard(alert, theme, double angleInRadians) {
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
          builder: (context) => PendingAlertDetails(alert: alert),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.subText(
                      text: "${alert.tsym?.replaceAll("-EQ", "")} ",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.pending.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextWidget.paraText(
                        text: "PENDING",
                        theme: false,
                        color: colors.pending,
                        fw: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextWidget.paraText(
                      text: "${alert.exch}",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        TextWidget.paraText(
                          text: "LTP ",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        TextWidget.paraText(
                          text: "${alert.ltp ?? alert.close ?? 0.00}",
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        TextWidget.paraText(
                          text: " (${alert.perChange ?? 0.00}%)",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        TextWidget.paraText(
                          text: "Alert ",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        TextWidget.paraText(
                          text: alert.aiT == "LTP_A"
                              ? "LTP Above"
                              : alert.aiT == "LTP_B"
                                  ? "LTP Below"
                                  : alert.aiT == "CH_PER_A"
                                      ? "Perc.Change Above"
                                      : "Perc.Change below",
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                        const SizedBox(width: 4),
                        Transform.rotate(
                          angle: angleInRadians,
                          child: Icon(
                            alert.aiT == "LTP_A"
                                ? Icons.arrow_upward
                                : alert.aiT == "LTP_B"
                                    ? Icons.arrow_downward
                                    : alert.aiT == "CH_PER_A"
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                            size: 16,
                            color: alert.aiT == "LTP_A"
                                ? theme.isDarkMode
                                    ? colors.profitDark
                                    : colors.profitLight
                                : alert.aiT == "LTP_B"
                                    ? theme.isDarkMode
                                        ? colors.lossDark
                                        : colors.lossLight
                                    : alert.aiT == "CH_PER_A"
                                        ? theme.isDarkMode
                                            ? colors.profitDark
                                            : colors.profitLight
                                        : theme.isDarkMode
                                            ? colors.lossDark
                                            : colors.lossLight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextWidget.paraText(
                          text:
                              alert.aiT == "CH_PER_A" || alert.aiT == "CH_PER_B"
                                  ? "%${alert.d}"
                                  : "${alert.d}",
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListDivider(),
        ],
      ),
    );
  }

 
}

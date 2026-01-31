// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_cancel_sip_alert.dart';
import 'package:mynt_plus/screens/Mobile/mutual_fund/mf_timeline.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/global_font_web.dart';
// import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/mynt_loader.dart';

class mfSipdetScren extends StatefulWidget {
  final dynamic data;

  const mfSipdetScren({super.key, this.data});
  @override
  State<mfSipdetScren> createState() => _mfSipdetScren();
}

class _mfSipdetScren extends State<mfSipdetScren>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mfdata = ref.watch(mfProvider);
      // Remove debug prints for production code

      return SafeArea(
        child: Scaffold(
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(16),
              //   topRight: Radius.circular(16),
              // ),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              border: Border(
                top: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
                left: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
                right: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
              ),
            ),
            child: MyntLoaderOverlay(
              isLoading: mfdata.bestmfloader ?? false,
              child: widget.data == null
                  ? const Center(
                      child: NoDataFound(
                      secondaryEnabled: false,
                    ))
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: theme.isDarkMode
                                              ? colors.dividerDark
                                              : colors.dividerLight,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TextWidget.subText(
                                          text: "SIP Details",
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          theme: theme.isDarkMode,
                                          fw: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildHeaderSection(mfdata, theme),
                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      // Show buttons based on status and pause flag
                                      if (_shouldShowButtons(
                                          widget.data?.status,
                                          mfdata.monthlyPauseFlag)) ...[
                                        // Show pause button only if pause flag is Y
                                        if (mfdata.monthlyPauseFlag == "Y") ...[
                                          Expanded(
                                            child: _buildPauseButton(
                                                context, mfdata, theme),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        // Always show cancel button if SIP is active
                                        Expanded(
                                          child: _buildCancelButton(
                                              context, mfdata, theme),
                                        ),
                                      ],
                                    ],
                                  ),

                                  // if (widget.data?.invList !=
                                  //         null &&
                                  //     widget.data!.invList!
                                  //         .isNotEmpty)

                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
                                      // controller: scrollController,
                                      child: Column(
                                        children: [
                                          rowOfInfoData(
                                              "SIP Register Date",
                                              "${widget.data!.sIPRegnDate ?? ""}",
                                              theme),
                                          rowOfInfoData(
                                              "Amount",
                                              "${widget.data!.installmentAmount ?? "0.00"}",
                                              theme),
                                          rowOfInfoData(
                                              "Next Due Date",
                                              "${widget.data?.NextSIPDate ?? ""}",
                                              theme),
                                          rowOfInfoData(
                                              "Start Date",
                                              "${widget.data?.startDate ?? ""}",
                                              theme),
                                          rowOfInfoData(
                                              "End Date",
                                              "${widget.data?.endDate ?? ""}",
                                              theme),
                                          rowOfInfoData(
                                              "Sip Reg No",
                                              "${widget.data?.sIPRegnNo ?? ""}",
                                              theme),
                                          rowOfInfoData(
                                              "Settlement Type",
                                              "${widget.data?.settType ?? ""}",
                                              theme),

                                          rowOfInfoData(
                                              "Frequency Type",
                                              "${widget.data?.frequencyType ?? ""}",
                                              theme),

                                          // TextWidget.subText(
                                          //     align: TextAlign.right,
                                          //     text: "SIP Status",
                                          //     color: theme.isDarkMode
                                          //         ? colors.textPrimaryDark
                                          //         : colors.textPrimaryLight,
                                          //     textOverflow: TextOverflow.ellipsis,
                                          //     theme: theme.isDarkMode,
                                          //     fw: 3),

                                          // const SizedBox(height: 15),

                                          // // Safely build the timeline list
                                          // _buildTimelineList(mfdata),

                                          // if ((widget.data
                                          //             ?.NextSIPDate ??
                                          //         "")
                                          //     .isEmpty) ...[
                                          //   const SizedBox(height: 16),
                                          //   TextWidget.subText(
                                          //       // align: TextAlign.right,
                                          //       text: "Rejected Reason",
                                          //       color: theme.isDarkMode
                                          //             ? colors.textSecondaryDark
                                          //             : colors.textSecondaryLight,
                                          //       textOverflow: TextOverflow.ellipsis,
                                          //       theme: theme.isDarkMode,
                                          //       fw: 3),
                                          //   const SizedBox(height: 8),
                                          //   if (widget.data?.invList !=
                                          //           null &&
                                          //       widget.data!.invList!
                                          //           .isNotEmpty)
                                          //     TextWidget.paraText(

                                          //         text:
                                          //             "${widget.data!.invList![0]["orderremarks"] ?? "No reason provided"}",
                                          //         color:colors.loss,
                                          //         textOverflow: TextOverflow.ellipsis,
                                          //         theme: theme.isDarkMode,
                                          //         maxLines: 3,
                                          //         fw: 3),
                                          // ],
                                        ],
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderSection(dynamic mfdata, dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.titleText(
          text: widget.data?.name ?? "Unknown Scheme",
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          maxLines: 2,
          fw: 1,
        ),
      ],
    );
  }

  Widget _buildTimelineList(dynamic mfdata) {
    if (widget.data?.invList == null || widget.data!.invList!.isEmpty) {
      return const Center(child: Text("No timeline data available"));
    }

    return ListView.builder(
      itemCount: widget.data!.invList!.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final isFirst = index == 0;
        final isLast = index == widget.data!.invList!.length - 1;

        return MFtimelineWidget(
          isfFrist: isFirst,
          isLast: isLast,
          orderHistoryData: widget.data?.invList?[index] ?? {},
        );
      },
    );
  }

  Widget _buildPauseButton(
      BuildContext context, dynamic mfdata, dynamic theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return MfSipCancelalert(
                  mfcancels: widget.data?.name ?? "",
                  mforderno: widget.data?.sIPRegnNo ?? "",
                  mfscode: widget.data?.schemeCode ?? "",
                  message: "pause",
                  mffreqtype: widget.data?.frequencyType ?? "",
                  mfnextsipdate: widget.data?.NextSIPDate ?? "");
            },
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          side: BorderSide(
            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
            width: 1,
          ),
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: TextWidget.subText(
            align: TextAlign.center,
            text: "Pause",
            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 2),
      ),
    );
  }

  Widget _buildCancelButton(
      BuildContext context, dynamic mfdata, dynamic theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return MfSipCancelalert(
                  mfcancels: widget.data?.name ?? "",
                  mforderno: widget.data?.sIPRegnNo ?? "",
                  mfscode: widget.data?.schemeCode ?? "",
                  message: "sip",
                  mffreqtype: widget.data?.frequencyType ?? "",
                  mfnextsipdate: widget.data?.NextSIPDate ?? "");
            },
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: TextWidget.subText(
            align: TextAlign.center,
            text: "Cancel SIP",
            color: colors.colorWhite,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 2),
      ),
    );
  }

  Widget rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title1,
                style: MyntWebTextStyles.bodyMedium(
                  context,
                  color: theme.isDarkMode
                      ? MyntColors.textSecondaryDark
                      : MyntColors.textSecondary,
                  fontWeight: MyntFonts.regular,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value1,
                textAlign: TextAlign.right,
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: theme.isDarkMode
                      ? MyntColors.textPrimaryDark
                      : MyntColors.textPrimary,
                  fontWeight: MyntFonts.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Determines whether to show pause and cancel buttons based on SIP status and pause flag
  bool _shouldShowButtons(String? status, String? pauseFlag) {
    // Debug print to see what values we're getting
    print("=== SIP BUTTON VISIBILITY DEBUG ===");
    print("SIP Status: '$status'");
    print("Pause Flag: '$pauseFlag'");
    print("Widget Data Status: '${widget.data?.status}'");
    print("Widget Data Name: '${widget.data?.name}'");
    print("Widget Data Scheme Code: '${widget.data?.schemeCode}'");
    print("===================================");

    // Show buttons only if:
    // 1. SIP is ACTIVE
    // 2. SIP can be paused (pauseFlag == "Y")
    // 3. SIP is not already paused, cancelled, or rejected

    if (status == null || pauseFlag == null) {
      print("Buttons hidden: status or pauseFlag is null");
      print("Status is null: ${status == null}");
      print("PauseFlag is null: ${pauseFlag == null}");
      return false;
    }

    // Don't show buttons for cancelled, rejected, or paused SIPs
    if (status == "CANCELLED" || status == "REJECTED" || status == "PAUSED") {
      print("Buttons hidden: SIP status is $status");
      return false;
    }

    // Show buttons for ACTIVE SIPs (regardless of pause flag)
    // Cancel button is always available for active SIPs
    bool shouldShow = status == "ACTIVE";
    print("Status == 'ACTIVE': ${status == 'ACTIVE'}");
    print("PauseFlag == 'Y': ${pauseFlag == 'Y'}");
    print("Should show buttons: $shouldShow");
    return shouldShow;
  }
}

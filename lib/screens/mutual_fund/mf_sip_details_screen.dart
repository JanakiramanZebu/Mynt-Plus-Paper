// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_cancel_sip_alert.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_timeline.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/loader_ui.dart';

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

      return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          maxChildSize: 0.88,
          builder: (context, scrollController) {
            return SafeArea(
              child: Scaffold(
                backgroundColor:
                    theme.isDarkMode ? colors.colorBlack : Colors.transparent,
                body: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
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
                  child: TransparentLoaderScreen(
                    isLoading: mfdata.bestmfloader ?? false,
                    child: widget.data == null
                        ? const Center(child: NoDataFound(
                          secondaryEnabled: false,
                        ))
                        : Column(
                          children: [
                            Expanded(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const CustomDragHandler(),
                                        _buildHeaderSection(mfdata, theme),
                                        const SizedBox(height: 20),
                                                
                                          Row(
                                            children: [
                                              // Show buttons based on status and pause flag
                                              if (_shouldShowButtons(widget.data?.status, mfdata.monthlyPauseFlag)) ...[
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
                                        controller: scrollController,
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
                                        rowOfInfoData("End Date",
                                            "${widget.data?.endDate ?? ""}", theme),
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
                                      ),)
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
    });
  }

  Widget _buildHeaderSection(dynamic mfdata, dynamic theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleText(
                          // align: TextAlign.right,
                          text: widget.data?.name ?? "Unknown Scheme",
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          maxLines: 2,
                          fw: 1),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.data?.status == "ACTIVE"
                        ?  theme.isDarkMode ? colors.profitDark.withOpacity(0.1) : colors.profitLight.withOpacity(0.1)
                        : theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TextWidget.paraText(
                    text: widget.data?.status == "ACTIVE"
                        ? "LIVE"
                        : widget.data?.status,
                    color: widget.data?.status == "ACTIVE"
                        ? theme.isDarkMode ? colors.profitDark : colors.profitLight
                        : theme.isDarkMode ? colors.lossDark : colors.lossLight,
                    theme: theme.isDarkMode,
                    fw: 0,
                  ),
                ),

                // const SizedBox(height: 8),
              ],
            ),
            // const SizedBox(height: 4),
          ])),
      // TextWidget.titleText(
      //     align: TextAlign.right,
      //     text: widget.data?.installmentAmount ?? "0.00",
      //     color: theme.isDarkMode
      //         ? colors.textSecondaryDark
      //         : colors.textSecondaryLight,
      //     textOverflow: TextOverflow.ellipsis,
      //     theme: theme.isDarkMode,
      //     fw: 3),
      // const SizedBox(width: 12),
    ]);
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
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: SizedBox(
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
                backgroundColor: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.6)
                    : colors.btnBg,
                // foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                side: theme.isDarkMode
                    ? null
                    : BorderSide(
                        color: colors.primaryLight,
                        width: 1,
                      ),
                minimumSize: Size(double.infinity, 45), // height: 48
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextWidget.subText(
                  align: TextAlign.right,
                  text: "Pause",
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.primaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 2),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildCancelButton(
      BuildContext context, dynamic mfdata, dynamic theme) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: SizedBox(
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
                backgroundColor: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.6)
                    : colors.btnBg,
                // foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                side: theme.isDarkMode
                    ? null
                    : BorderSide(
                        color: colors.primaryLight,
                        width: 1,
                      ),
                minimumSize: Size(double.infinity, 45), // height: 48
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: TextWidget.subText(
                  align: TextAlign.right,
                  text: "Cancel SIP",
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.primaryLight,
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 2),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Column rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextWidget.subText(
              // align: TextAlign.right,
              text: title1,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextWidget.subText(
                align: TextAlign.right,
                text: value1,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                // textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 0),
          ),
        ]),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
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
    if (status == "CANCELLED" || 
        status == "REJECTED" || 
        status == "PAUSED") {
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

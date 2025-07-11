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
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/loader_ui.dart';

class mfSipdetScren extends StatefulWidget {
  const mfSipdetScren({super.key});
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
      
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("SIP details",
              style: textStyles.appBarTitleTxt.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              )),
        ),
        body: Stack(children: [
          TransparentLoaderScreen(
            isLoading: mfdata.bestmfloader ?? false,
            child: mfdata.mfsinglepageres == null
                ? const Center(child: NoDataFound())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(mfdata, theme),
                          const SizedBox(height: 20), 
                          TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: "SIP Details",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                           SizedBox(height: 25),
                          // Safely handle potential null values
                          if (mfdata.mfsinglepageres?.invList != null && 
                              mfdata.mfsinglepageres!.invList!.isNotEmpty)
                            rowOfInfoData(
                              "SIP Register Date",
                              "${mfdata.mfsinglepageres!.invList![0]["sipregndate"] ?? ""}",
                              
                              theme),

                          const SizedBox(height: 10),
                            Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            thickness: 1.0,
                          ),
                          const SizedBox(height: 10),

                             rowOfInfoData(
                            
                              "Amount",
                              "${mfdata.mfsinglepageres!.installmentAmount ?? "0.00"}",
                              theme),
                          const SizedBox(height: 25),
                            TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:   "SIP Status",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                          

                                                    const SizedBox(height: 15),

                          // Safely build the timeline list
                          _buildTimelineList(mfdata),
                          
                          if ((mfdata.mfsinglepageres?.nextInstallmentDate ?? "").isEmpty) ...[
                            const SizedBox(height: 16),
                             TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:   "Rejected Reason",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                           
                            const SizedBox(height: 8),
                            if (mfdata.mfsinglepageres?.invList != null && 
                                mfdata.mfsinglepageres!.invList!.isNotEmpty)
                                  TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:    "${mfdata.mfsinglepageres!.invList![0]["orderremarks"] ?? "No reason provided"}",
                                                    color:  theme.isDarkMode
                                        ? colors.colorWhite
                                        : const Color(0xFFF33E4B),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 3,
                                                    fw: 3),
                              
                          ],
                          const SizedBox(height: 20),
                          if (mfdata.mfsinglepageres?.liveCancel == "LIVE") 
                            _buildCancelButton(context, mfdata),
                        ])))
        ]));
    });
  }

  Widget _buildHeaderSection(dynamic mfdata, dynamic theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:  mfdata.mfsinglepageres?.schemename ?? "Unknown Scheme",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                  maxLines: 2,

                                                    fw: 0),
                                
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 16,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if ((mfdata.mfsinglepageres?.nextInstallmentDate ?? "").isNotEmpty) ...[
                                  TextWidget.titleText(
                                                    align: TextAlign.right,
                                                    text:  "Next Due Date : ${mfdata.mfsinglepageres?.nextInstallmentDate ?? ""}",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                  maxLines: 2,

                                                    fw: 3),
                                  
                                ],
                                Container(
                                  decoration: BoxDecoration(
                                    color: mfdata.mfsinglepageres?.liveCancel == "LIVE"
                                        ? const Color(0xFFE5F5EA)
                                        : const Color(0xFFFFC7C7),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2),
                                  child: Text(
                                    mfdata.mfsinglepageres?.liveCancel ?? "Unknown",
                                    style: textStyle(
                                      mfdata.mfsinglepageres?.liveCancel == "LIVE"
                                          ? const Color(0xFF42A833)
                                          : const Color(0xFFF33E4B),
                                      10,
                                      FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ]
                            )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ]
            ),
          )
        ),
        TextWidget.titleText(
                                                    align: TextAlign.right,
                                                    text: mfdata.mfsinglepageres?.installmentAmount ?? "0.00",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark:
                                                         colors.textSecondaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
        
        const SizedBox(width: 12),
      ]
    );
  }

  Widget _buildTimelineList(dynamic mfdata) {
    if (mfdata.mfsinglepageres?.invList == null || 
        mfdata.mfsinglepageres!.invList!.isEmpty) {
      return const Center(child: Text("No timeline data available"));
    }
    
    return ListView.builder(
      itemCount: mfdata.mfsinglepageres!.invList!.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final isFirst = index == 0;
        final isLast = index == mfdata.mfsinglepageres!.invList!.length - 1;
        
        return MFtimelineWidget(
          isfFrist: isFirst,
          isLast: isLast,
          orderHistoryData: mfdata.mfsinglepageres?.invList?[index] ?? {},
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context, dynamic mfdata) {
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
                      mfcancels: mfdata.mfsinglepageres?.schemename ?? "",
                      mforderno: mfdata.mfsinglepageres?.sipregnno ?? "",
                      mfreferno: mfdata.mfsinglepageres?.internalrefernumber ?? "",
                      message: "sip",
                      mffreqtype: mfdata.mfsinglepageres?.frequency_type ?? "", 
                      mfnextsipdate: mfdata.mfsinglepageres?.nextInstallmentDate ?? ""
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                side: const BorderSide(
                    color: Color.fromARGB(255, 0, 0, 0),
                    width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Cancel SIP",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Row rowOfInfoData(String title1, String value1,  
      ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: title1,
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                    TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: value1,
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
      
 
    ]);
  }
}

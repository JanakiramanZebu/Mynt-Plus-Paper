// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/cust_text_formfield.dart';
// import 'package:mynt_plus/models/fund_model_testing_copy/fund_direct_payment_model.dart';
// import 'package:mynt_plus/models/mf_model/mf_order_det_model.dart';
// import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
// import '../../../models/ipo_model/ipo_place_order_model.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';

class MfSipCancelalert extends ConsumerWidget {
  final String mfcancels;
  final String message;
  final String mforderno; 
  final String mffreqtype;
  final String mfnextsipdate;
  final String mfscode;

  const MfSipCancelalert({
    super.key,
    required this.mfcancels,
    required this.mforderno, 
    required this.message,
    required this.mffreqtype,
    required this.mfnextsipdate,
    required this.mfscode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);
    final isDarkMode = theme.isDarkMode;

    // Safe access with defaults
    final schemeName = mfcancels.isNotEmpty ? mfcancels : "this mutual fund";
    final orderNo = mforderno.isNotEmpty ? mforderno : ""; 
    final freqType = mffreqtype.isNotEmpty ? mffreqtype : "";
    final nextSipDate = mfnextsipdate.isNotEmpty ? mfnextsipdate : "";
    final scode = mfscode.isNotEmpty ? mfscode : "";
    final isPause = message == 'pause';

    return AlertDialog(
      backgroundColor: colors.colorWhite,
      titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      actionsPadding:
          const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 150));
                    mfData.cleartext();
                    mfData.rejectsip.text = "";
                    mfData.pausesip.text = "";
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: TextWidget.subText(
                align: TextAlign.center,
                text:
                    "Are you sure you want to ${isPause ? "Pause" : "Cancel"} the ($schemeName) SIP order",
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        children: [
          // Conditional UI based on action type
          if (message == 'sip') ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextWidget.subText(
                  text: "Cancel Reason",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildReasonDropdown(mfData, theme),
            // const SizedBox(height: 5),
          ],

          if (isPause) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextWidget.subText(
                  text: "No of installments Passed *",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildPauseTextField(mfData, theme),
          ]
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // No button

            // Yes button - SIP Cancel
            if (message == 'sip')
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(0, 40), // width, height
                      side: BorderSide(
                          color:
                              colors.btnOutlinedBorder), // Outline border color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: colors.primaryDark,
                    ),
                    onPressed: () async {
                      try {
                        await mfData.cancelsiporder(context, orderNo,scode);
                      } catch (e) {
                        // Handle error silently
                      }
                    },
                    child: _buildButtonContent(mfData, isDarkMode)),
              ),

            // Yes button - SIP Pause
            if (isPause)
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isDarkMode
                            ? colors.colorbluegrey
                            : colors.colorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                    onPressed: () async {
                      try {
                        await mfData.pausesiporder(
                            context, orderNo, freqType, nextSipDate,scode);
                      } catch (e) {
                        // Handle error silently
                      }
                    },
                    child: _buildButtonContent(mfData, isDarkMode)),
              )
          ],
        ),
      ],
    );
  }

  // Button content (loading indicator or text)
  Widget _buildButtonContent(MFProvider mfData, bool isDarkMode) {
    return mfData.loading == true
        ? const SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color.fromARGB(99, 48, 48, 48)),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
          )
        : TextWidget.subText(
            text: "Yes",
            color: colors.colorWhite,
            theme: false,
            fw: 2,
          );
  }

  // SIP Cancel reason dropdown
  Widget _buildReasonDropdown(MFProvider mfData, ThemesProvider theme) {
    final isDarkMode = theme.isDarkMode;
    final hasReasonList =
        mfData.mfrejectsiplist != null && mfData.mfrejectsiplist!.isNotEmpty;

    return Column(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: hasReasonList &&
                    mfData.mfrejectsiplist!
                        .any((item) => item["id"] == mfData.droupreason)
                ? mfData.droupreason
                : null,
            menuItemStyleData: MenuItemStyleData(
              customHeights: hasReasonList
                  ? List.filled(mfData.mfrejectsiplist!.length, 50.0)
                  : [],
            ),
            buttonStyleData: const ButtonStyleData(
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xffF1F3F8),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              offset: const Offset(0, 8),
            ),
            style: TextWidget.textStyle(
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fontSize: 16,
              fw: 1,
            ),
            hint: TextWidget.subText(
              text: mfData.sipreason,
              theme: false,
              color: const Color(0xff666666),
            ),
            items: hasReasonList
                ? mfData.mfrejectsiplist!.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["id"] as String?,
                      child: Text(
                        item["reason_name"] as String? ?? "",
                        style: textStyle(
                            const Color(0XFF000000), 13, FontWeight.w500),
                      ),
                    );
                  }).toList()
                : [],
            onChanged: (value) {
              if (value != null) {
                mfData.orderrejectupdate(value);
              }
            },
          ),
        ),
        if (mfData.droupreason == "13") ...[
          const SizedBox(height: 10),
          Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 40,
              child: CustomTextFormField(
                textAlign: TextAlign.start,
                fillColor:
                    isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                hintText: 'Specify The Reason',
                hintStyle:
                    textStyle(const Color(0xff666666), 14, FontWeight.w400),
                style: textStyle(
                    isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
                textCtrl: mfData.rejectsip,
              )),
        ]
      ],
    );
  }

  // Pause SIP text field
  Widget _buildPauseTextField(MFProvider mfData, ThemesProvider theme) {
    final isDarkMode = theme.isDarkMode;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 44,
          child: CustomTextFormField(
            textAlign: TextAlign.start,
            fillColor: isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
            style: TextWidget.textStyle(
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fontSize: 16,
              fw: 1,
            ),

            hintText: 'No of installments Passed',
            hintStyle: textStyle(const Color(0xff666666), 14, FontWeight.w400),

            textCtrl: mfData.pausesip,
            keyboardType: TextInputType.number, // Show numeric keyboard
          ),
        ),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

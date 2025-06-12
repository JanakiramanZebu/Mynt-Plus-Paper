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
import '../../res/res.dart';

class MfSipCancelalert extends ConsumerWidget {
  final String mfcancels;
  final String message;
  final String mforderno;
  final String mfreferno;
  final String mffreqtype;
  final String mfnextsipdate;

  const MfSipCancelalert({
    super.key,
    required this.mfcancels,
    required this.mforderno,
    required this.mfreferno,
    required this.message,
    required this.mffreqtype,
    required this.mfnextsipdate,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);
    final isDarkMode = theme.isDarkMode;
    
    // Safe access with defaults
    final schemeName = mfcancels.isNotEmpty ? mfcancels : "this mutual fund";
    final orderNo = mforderno.isNotEmpty ? mforderno : "";
    final referNo = mfreferno.isNotEmpty ? mfreferno : "";
    final freqType = mffreqtype.isNotEmpty ? mffreqtype : "";
    final nextSipDate = mfnextsipdate.isNotEmpty ? mfnextsipdate : "";
    final isPause = message == 'pause';
    
    return AlertDialog(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
      ),
      content: Column(
        children: [
          Text(
            "Are you sure you want to ${isPause ? "Pause" : "Cancel"} the ($schemeName) SIP order",
            textAlign: TextAlign.center,
            style: textStyle(
              isDarkMode ? colors.colorWhite : colors.colorBlack,
              16,
              FontWeight.w600
            )
          ),
          const SizedBox(height: 18),
          
          // Conditional UI based on action type
          if (message == 'sip') ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Select The SIP Cancel Reason *",
                  style: textStyle(
                    isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            _buildReasonDropdown(mfData, theme),
            const SizedBox(height: 5),
          ],

          if (isPause) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "No of installments Passed *",
                  style: textStyle(
                    isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 0),
            _buildPauseTextField(mfData, theme),
            const SizedBox(height: 5),
          ]
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // No button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xffF1F3F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )
                ),
                onPressed: () {
                  // Clear fields on cancel
                  mfData.cleartext();
                  mfData.rejectsip.text = "";
                  mfData.pausesip.text = "";
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: textStyle(colors.colorGrey, 12, FontWeight.w600)
                )
              ),
            ),
            const SizedBox(width: 16),
            
            // Yes button - SIP Cancel
            if (message == 'sip')
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: isDarkMode
                      ? colors.colorbluegrey
                      : colors.colorBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )
                  ),
                  onPressed: () async {
                    try {
                      await mfData.cancelsiporder(context, orderNo, referNo);
                    } catch (e) {
                      // Handle error silently
                    }
                  },
                  child: _buildButtonContent(mfData, isDarkMode)
                ),
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
                    )
                  ),
                  onPressed: () async {
                    try {
                      await mfData.pausesiporder(context, orderNo, freqType, nextSipDate);
                    } catch (e) {
                      // Handle error silently
                    }
                  },
                  child: _buildButtonContent(mfData, isDarkMode)
                ),
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
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(99, 48, 48, 48)
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        )
      : Text(
          "Yes",
          style: textStyle(
            isDarkMode ? colors.colorBlack : colors.colorWhite,
            12,
            FontWeight.w600
          )
        );
  }

  // SIP Cancel reason dropdown
  Widget _buildReasonDropdown(MFProvider mfData, ThemesProvider theme) {
    final isDarkMode = theme.isDarkMode;
    final hasReasonList = mfData.mfrejectsiplist != null && mfData.mfrejectsiplist!.isNotEmpty;
    
    return Column(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: hasReasonList && mfData.mfrejectsiplist!.any((item) => item["id"] == mfData.droupreason)
                ? mfData.droupreason
                : null,
            menuItemStyleData: MenuItemStyleData(
              customHeights: hasReasonList
                ? List.filled(mfData.mfrejectsiplist!.length, 50.0)
                : [],
            ),
            buttonStyleData: const ButtonStyleData(
              height: 45,
              decoration: BoxDecoration(
                color: Color(0xffF1F3F8),
                borderRadius: BorderRadius.all(Radius.circular(32)),
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
            style: textStyle(const Color(0XFF000000), 13, FontWeight.w500),
            hint: Text(
              mfData.sipreason, // Use selected value or default hint
              style: textStyle(const Color(0XFF000000), 13, FontWeight.w500),
            ),
            items: hasReasonList 
              ? mfData.mfrejectsiplist!.map((item) {
                  return DropdownMenuItem<String>(
                    value: item["id"] as String?,
                    child: Text(
                      item["reason_name"] as String? ?? "",
                      style: textStyle(const Color(0XFF000000), 13, FontWeight.w500),
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
            height: 44,
            child: CustomTextFormField(
              textAlign: TextAlign.start,
              fillColor: isDarkMode
                ? colors.darkGrey
                : const Color(0xffF1F3F8),
              hintText: 'Specify The Reason',
              hintStyle: textStyle(const Color(0xff666666), 14, FontWeight.w400),
              style: textStyle(
                isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w600
              ),
              textCtrl: mfData.rejectsip,
            )
          ),
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
            hintText: 'No of installments Passed',
            hintStyle: textStyle(const Color(0xff666666), 14, FontWeight.w400),
            style: textStyle(
              isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
            textCtrl: mfData.pausesip,
            keyboardType: TextInputType.number, // Show numeric keyboard
          ),
        ),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontWeight: fWeight, 
        color: color, 
        fontSize: fontSize
      )
    );
  }
}

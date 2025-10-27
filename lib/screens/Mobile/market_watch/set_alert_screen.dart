import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/cust_text_formfield.dart';

class SetAlert extends StatefulWidget {
  final GetQuotes depthdata;
  final DepthInputArgs wlvalue;
  const SetAlert({super.key, required this.depthdata, required this.wlvalue});

  @override
  State<SetAlert> createState() => _SetAlertState();
}

class _SetAlertState extends State<SetAlert> {
  bool _handlesetalert = false;
  TextEditingController valueCtrl = TextEditingController();
  TextEditingController remark = TextEditingController();
  final List<String> alterItems = ['Above', 'Below'];
  final List<String> alertType = ["LTP"];
  String alertValue = "";
  String alertTypeVal = "";
  String validityTypeVal = "";
  String errorText = "";

  @override
  void initState() {
    alertValue = alterItems[0];
    alertTypeVal = alertType[0];
    super.initState();
  }

  validatesetalret(value) {
    try {
      if (value == null || value.isEmpty) {
        errorText = "* Value is required";
        return;
      }

      if (alertTypeVal == "LTP" && value.isNotEmpty) {
        double enteredValue = double.parse(value);
        double currentLtp = double.parse(widget.depthdata.lp ?? "0.0");

        // Format numbers to always show 2 decimal places
        String formattedLtp = currentLtp.toStringAsFixed(2);
        String formattedEnteredValue = enteredValue.toStringAsFixed(2);

        if (alertValue == "Above" && enteredValue <= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already above ₹$formattedEnteredValue";
        } else if (alertValue == "Below" && enteredValue >= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already below ₹$formattedEnteredValue";
        } else {
          errorText = "";
        }
      }
      //  else if (alertTypeVal == "Perc.Change") {
      //   errorText = "";
      // }
      else {
        errorText = "";
      }
    } catch (e) {
      errorText = "Please enter a valid number";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final scripInfo = ref.watch(marketWatchProvider);
      final theme = ref.read(themeProvider);

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.subText(
                                  text: 'Type',
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 45,
                                child: DropdownButtonHideUnderline(
                                                                     child: DropdownButton2(
                                     dropdownStyleData: DropdownStyleData(
                                         decoration: BoxDecoration(
                                             borderRadius:
                                                 BorderRadius.circular(10),
                                             color: theme.isDarkMode
                                                 ? colors.colorBlack
                                                 : colors.colorWhite,
                                             border: Border.all(
                                                 color: theme.isDarkMode
                                                     ? colors.darkColorDivider
                                                     : colors.colorDivider,
                                             ),
                                         )),
                                     buttonStyleData: ButtonStyleData(
                                        height: 44,
                                        decoration: BoxDecoration(
                                            color: theme.isDarkMode
                                                ? colors.darkGrey
                                                : const Color(0xffF1F3F8),
                                            border: Border.all(
                                                color: colors.primary),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)))),
                                    isExpanded: true,
                                    style: TextWidget.textStyle(
                                        fontSize: 14,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    hint: TextWidget.subText(
                                        text: alertTypeVal,
                                        
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    items: alertType
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: TextWidget.subText(
                                                    text: item,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors.textPrimaryLight,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ),
                                            ))
                                        .toList(),
                                    value: alertTypeVal,
                                    onChanged: (value) {
                                      setState(() {
                                        alertTypeVal = value!;
                                        valueCtrl.clear();
                                      });
                                      validatesetalret(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.subText(
                                  text: 'Alert me',
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 45,
                                child: DropdownButtonHideUnderline(
                                                                     child: DropdownButton2<String>(
                                     dropdownStyleData: DropdownStyleData(
                                         decoration: BoxDecoration(
                                             borderRadius:
                                                 BorderRadius.circular(10),
                                             color: theme.isDarkMode
                                                 ? colors.colorBlack
                                                 : colors.colorWhite,
                                             border: Border.all(
                                                 color: theme.isDarkMode
                                                     ? colors.darkColorDivider
                                                     : colors.colorDivider,
                                             ),
                                         )),
                                     buttonStyleData: ButtonStyleData(
                                        height: 45,
                                        decoration: BoxDecoration(
                                            color: theme.isDarkMode
                                                ? colors.darkGrey
                                                : const Color(0xffF1F3F8),
                                            border: Border.all(
                                                color: colors.primary),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)))),
                                    isExpanded: true,
                                    style: TextWidget.textStyle(
                                        fontSize: 14,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    hint: TextWidget.subText(
                                        text: alertValue,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                    items: alterItems
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: TextWidget.subText(
                                                    text: item,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ),
                                            ))
                                        .toList(),
                                    value: alertValue,
                                    onChanged: (value) {
                                      setState(() {
                                        alertValue = value!;
                                      });
                                      validatesetalret(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ENTER VALUE FIELD
                    TextWidget.subText(
                        text: 'Enter Value',
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                        fw: 0),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 45,
                      child: CustomTextFormField(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        onChanged: (value) {
                          Future.microtask(() {
                            if (mounted) {
                              setState(() {
                                validatesetalret(value);
                              });
                            }
                          });
                        },
                        hintText: "0",
                        hintStyle: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                        ),
                        keyboardType: TextInputType.number,
                        style: TextWidget.textStyle(
                            fontSize: 16,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
                        ),
                        textCtrl: valueCtrl,
                        textAlign: TextAlign.start,
                        prefixIcon: SvgPicture.asset(assets.ruppeIcon,
                            fit: BoxFit.scaleDown,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight),
                      ),
                    ),
                    if (errorText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      TextWidget.captionText(
                          text: errorText,
                          color: theme.isDarkMode ? colors.errorDark : colors.errorLight,
                          theme: theme.isDarkMode,
                          fw: 0),
                    ],
                    const SizedBox(height: 16),
                    // REMARK FIELD
                    TextWidget.subText(
                        text: 'Remark', theme: theme.isDarkMode, fw: 0),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 70,
                      child: CustomTextFormField(
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: "Remark",
                        hintStyle: TextWidget.textStyle(
                          fontSize: 14,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                        ),
                        style: TextWidget.textStyle(
                            fontSize: 16,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: theme.isDarkMode,
                        ),
                        textCtrl: remark,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // BOTTOM BUTTON - STAYS AT BOTTOM
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 10, 24, MediaQuery.of(context).viewInsets.bottom + 10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: errorText.isNotEmpty
                      ? theme.isDarkMode
                          ? colors.primaryDark.withOpacity(0.5)
                          : colors.primaryLight.withOpacity(0.5)
                      : (theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: _handlesetalert ||
                        valueCtrl.text.isEmpty ||
                        valueCtrl.text == "0" ||
                        errorText.isNotEmpty
                    ? () {}
                    : () async {
                        setState(() {
                          _handlesetalert = true;
                        });

                        if (valueCtrl.text.isEmpty) {
                          setState(() {
                            errorText = "Value cannot be empty";
                            _handlesetalert = false;
                          });
                          return;
                        }

                        if (valueCtrl.text == "0") {
                          setState(() {
                            errorText = "Value cannot be 0";
                            _handlesetalert = false;
                          });
                          return;
                        }

                        errorText = "";

                        try {
                          await ref.read(marketWatchProvider).fetchSetAlert(
                                widget.wlvalue.exch,
                                widget.wlvalue.tsym,
                                valueCtrl.text,
                                alertValue == "Above" && alertTypeVal == "LTP"
                                    ? "LTP_A"
                                    : alertValue == "Below" &&
                                            alertTypeVal == "LTP"
                                        ? "LTP_B"
                                        : "LTP_B", // fallback
                                context,
                                scripInfo.alertPendingModel!.length,
                                "${widget.depthdata.lp}",
                                remark.text,
                              );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _handlesetalert = false;
                            });
                          }
                        }
                      },
                child: _handlesetalert || scripInfo.loading
                    ? SizedBox(
                        width: 18,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.colorWhite),
                      )
                    : TextWidget.subText(
                        text: 'Set alert',
                        color: !theme.isDarkMode
                            ? errorText.isNotEmpty
                                ? colors.colorWhite.withOpacity(0.5)
                                : colors.colorWhite
                            : errorText.isNotEmpty
                                ? colors.colorWhite.withOpacity(0.5)
                                : colors.colorWhite,
                        theme: theme.isDarkMode,
                        fw: 2),
              ),
            ),
          ),
        ],
      );
    });
  }
}

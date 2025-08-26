import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/snack_bar.dart';

class CreateMandateDialogue extends ConsumerStatefulWidget {
  const CreateMandateDialogue({super.key});

  @override
  ConsumerState<CreateMandateDialogue> createState() =>
      _CreateMandateDialogueState();
}

class _CreateMandateDialogueState extends ConsumerState<CreateMandateDialogue> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).getCurrentDate();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);
    final mfOrder = ref.watch(mfProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
      
           
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget.titleText(
                      text: "Create Mandate",
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () async {
                          await Future.delayed(const Duration(milliseconds: 150));
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const ListDivider(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      TextWidget.subText(
                        text: "Amount",
                        color: theme.isDarkMode ? colors.textPrimaryDark   : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                        fw: 0,
                      ),
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 44,
                          child: CustomTextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.start,
                              fillColor: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              hintText: '0',
                              hintStyle: TextWidget.textStyle(
                                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                fontSize: 14,
                                theme: theme.isDarkMode,
                              ),
                              inputFormate: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: TextWidget.textStyle(
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fontSize: 16,
                                theme: theme.isDarkMode,
                              ),
                              textCtrl: mfOrder.installmentAmt,
                              onChanged: (value) {
                                setState(() {
                                  fund.isValidUpiId();
                                });
                              })),
                      // Error message below amount field
                      if (mfOrder.installmentAmt.text.trim().isEmpty)
                        TextWidget.paraText(
                          text: "Please enter an amount",
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                          fw: 0,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                          align: TextAlign.start,
                        ),
                      // else if (double.tryParse(mfOrder.installmentAmt.text) != null &&
                      //     double.parse(mfOrder.installmentAmt.text) < 100)
                      //   TextWidget.paraText(
                      //     text: "Amount must be at least 100",
                      //     theme: theme.isDarkMode,
                      //     color: colors.loss,
                      //   ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                  text: "Start Date",
                                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  height: 44,
                                  child: InkWell(
                                    onTap: () async {
                                      await mfOrder.datePickerStart(context);
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : const Color(0xffF1F3F8),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: colors.colorBlue,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextWidget.subText(
                                                text: mfOrder.startDate,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                  text: "End Date",
                                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                  fw: 0,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  height: 44,
                                  child: InkWell(
                                    onTap: () async {
                                      await mfOrder.datePickerEnd(context);
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : const Color(0xffF1F3F8),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: colors.colorBlue,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextWidget.subText(
                                                text: mfOrder.endDate,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (mfOrder.installmentAmt.text.trim().isEmpty) {
                            return; // Error is shown inline below the field
                          }
      
                          int installmentAmount =
                              double.parse(mfOrder.installmentAmt.text).toInt();
                          if (installmentAmount >= 100) {
                            await mfOrder.fetchCreateMandate(
                                context,
                                double.parse(mfOrder.installmentAmt.text)
                                    .toInt()
                                    .toString(),
                                mfOrder.startDate,
                                mfOrder.endDate);
                            Navigator.pop(context);
                          }
                          // Error for low amount is shown inline below the field
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size(0, 45), // width, height
      
                          backgroundColor: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        // padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: mfOrder.loading == true
                            ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(99, 48, 48, 48)),
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                ),
                              )
                            : TextWidget.subText(
                                text: "Submit",
                                color: colors.colorWhite,
                                theme: theme.isDarkMode,
                                fw: 2,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

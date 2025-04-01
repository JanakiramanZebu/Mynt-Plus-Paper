import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/snack_bar.dart';

class CreateMandateDialogue extends StatefulWidget {
  const CreateMandateDialogue({super.key});

  @override
  State<CreateMandateDialogue> createState() => _CreateMandateDialogueState();
}

class _CreateMandateDialogueState extends State<CreateMandateDialogue> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(mfProvider).getCurrentDate();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final fund = watch(fundProvider);
      final mfOrder = watch(mfProvider);
      return AlertDialog(
          backgroundColor: theme.isDarkMode
              ? const Color.fromARGB(255, 18, 18, 18)
              : colors.colorWhite,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          actionsPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          titlePadding: const EdgeInsets.only(left: 16, top: 16),
          title: Text("Create Mandate",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500)),
          content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ListDivider(),
                  const SizedBox(height: 10),
                  const SizedBox(height: 8),
                  Text("Amount",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w500)),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 44,
                      child: CustomTextFormField(
                          textAlign: TextAlign.start,
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          hintText: '0',
                          hintStyle: textStyle(
                              const Color(0xff666666), 15, FontWeight.w400),
                          inputFormate: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600),
                          // prefixIcon: InkWell(
                          //   onTap: () {},
                          //   child: SvgPicture.asset(
                          //       theme.isDarkMode
                          //           ? assets.darkCMinus
                          //           : assets.minusIcon,
                          //       fit: BoxFit.scaleDown),
                          // ),
                          // suffixIcon: InkWell(
                          //     onTap: () {},
                          //     child: SvgPicture.asset(
                          //         theme.isDarkMode
                          //             ? assets.darkAdd
                          //             : assets.addIcon,
                          //         fit: BoxFit.scaleDown)),
                          textCtrl: mfOrder.installmentAmt,
                          onChanged: (value) {
                            fund.isValidUpiId();
                          })),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            mfOrder.datePickerStart(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Start Date",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w500)),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                ),
                                child: Text(mfOrder.startDate,
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            mfOrder.datePickerEnd(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("End Date",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w500)),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : const Color(0xffF1F3F8),
                                ),
                                child: Text(mfOrder.endDate,
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    ],
                  ),
                ],
              )),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xffF1F3F8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child: Text("Cancel",
                    style: GoogleFonts.inter(
                        textStyle: textStyle(
                            colors.colorBlack, 14, FontWeight.w500)))),
            ElevatedButton(
                onPressed: () async {
                  int installmentAmount = double.parse(mfOrder.installmentAmt.text).toInt();
                  if (installmentAmount >= 100) {
                 await mfOrder.fetchCreateMandate(
                        context,
                        double.parse(mfOrder.installmentAmt.text)
                            .toInt()
                            .toString(),
                        mfOrder.startDate,
                        mfOrder.endDate);
                    Navigator.pop(context);
                  }else{
                     ScaffoldMessenger.of(context).showSnackBar(
        warningMessage(context,"Amount must be at least 100")
    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        theme.isDarkMode
                            ? colors.colorbluegrey
                            : const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child:  mfOrder.loading == true 
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
                            :  Text("Submit",
                    style: GoogleFonts.inter(
                        textStyle: textStyle(
                            theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            14,
                            FontWeight.w500))))
          ]);
    });
  }
}

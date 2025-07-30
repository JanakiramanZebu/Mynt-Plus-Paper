import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';

import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../models/portfolio_model/mf_holdings_model.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/snack_bar.dart';

class RedemptionBottomScreenNew extends StatefulWidget {
  const RedemptionBottomScreenNew({super.key});

  @override
  State<RedemptionBottomScreenNew> createState() =>
      _RedemptionBottomScreenNewState();
}

class _RedemptionBottomScreenNewState extends State<RedemptionBottomScreenNew> {
  var ischecked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mf = ref.watch(mfProvider);

      // Safe access to NAV value
      final navValue = mf.holssinglelist?.isNotEmpty == true
          ? (double.tryParse(mf.holssinglelist![0]?.avgNav ?? '0.0') ?? 0.0)
          : 0.0;

      // Calculate redemption value
      final redemptionQtyValue = double.tryParse(mf.redemptionQty.text) ?? 0.0;
      final redemptionValue = redemptionQtyValue * navValue;

      return SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(0.0, 0.0))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: TextWidget.titleText(
                              text: mf.holssinglelist?.isNotEmpty == true
                                  ? (mf.holssinglelist![0]?.name ??
                                      "Unknown Scheme")
                                  : "Unknown Scheme",
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              theme: theme.isDarkMode,
                              fw: 1,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
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
                                      ? const Color(0xffBDBDBD)
                                      : colors.colorGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget.subText(
                                  text: "Redemption Units",
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                  theme: theme.isDarkMode,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget.subText(
                                      text: "Total Units : ",
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      theme: theme.isDarkMode,
                                    ),
                                    const SizedBox(width: 8),
                                    TextWidget.subText(
                                      text: mf.holssinglelist?.isNotEmpty == true
                                          ? (mf.holssinglelist![0]?.avgQty ??
                                              "0.00")
                                          : "0.00",
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      theme: theme.isDarkMode,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                try {
                                  final minRedemptionQty =
                                      mf.holssinglelist?.isNotEmpty == true
                                          ? mf.holssinglelist![0]
                                              ?.minRedemptionQty
                                          : null;

                                  final netUnits =
                                      mf.holssinglelist?.isNotEmpty == true
                                          ? mf.holssinglelist![0]?.avgQty
                                          : null;

                                  final navStr =
                                      mf.holssinglelist?.isNotEmpty == true
                                          ? mf.holssinglelist![0]?.avgQty
                                          : null;

                                  mf.checkRedemption(value, minRedemptionQty,
                                      netUnits, navStr);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      successMessage(context,
                                          "Error validating redemption: ${e.toString()}"));
                                }
                              }
                            },
                            textAlign: TextAlign.start,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                            keyboardType: TextInputType.number,
                            controller: mf.redemptionQty,
                            decoration: InputDecoration(
                                fillColor: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                filled: true,
                                prefixIconColor: const Color(0xff586279),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: colors.colorBlue),
                                    borderRadius: BorderRadius.circular(5)),
                                disabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(5)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                          if (mf.redemptionError != null &&
                              mf.redemptionError!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  TextWidget.paraText(
                                    text: mf.redemptionError!,
                                    // align: TextAlign.start,
                                    color: colors.kColorRedText,
                                    theme: theme.isDarkMode,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextWidget.paraText(
                                  text:
                                      "Min. redemption units ${mf.holssinglelist?.isNotEmpty == true ? (mf.holssinglelist![0]?.minRedemptionQty ?? 'N/A') : 'N/A'}",
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  theme: theme.isDarkMode,
                                  
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 15),
                          if (mf.redemptionOrderError != null &&
                              mf.redemptionOrderError!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextWidget.paraText(
                              text: mf.redemptionOrderError!,
                              align: TextAlign.start,
                              color: colors.kColorRedText,
                              theme: theme.isDarkMode,
                              fw: 0,
                            ),
                            const SizedBox(height: 6)
                          ]
                        ]),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget.titleText(
                          text: redemptionValue.toStringAsFixed(2),
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          theme: theme.isDarkMode,
                          fw: 1,
                        ),
                        const SizedBox(height: 4),
                        TextWidget.subText(
                          text: "Redemption Value",
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          theme: theme.isDarkMode,
                          
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          final minRedemptionQty =
                              mf.holssinglelist?.isNotEmpty == true
                                  ? mf.holssinglelist![0]?.minRedemptionQty
                                  : null;

                          final netUnits = mf.holssinglelist?.isNotEmpty == true
                              ? mf.holssinglelist![0]?.avgQty
                              : null;

                          final navStr = mf.holssinglelist?.isNotEmpty == true
                              ? mf.holssinglelist![0]?.avgNav
                              : null;

                          if (mf.checkRedemption(mf.redemptionQty.text,
                              minRedemptionQty, netUnits, navStr)) {
                            final schemeCode =
                                mf.holssinglelist?.isNotEmpty == true
                                    ? (mf.holssinglelist![0]?.sCHEMECODE ??
                                        'DefaultScheme')
                                    : 'DefaultScheme';

                            mf.mfRedemption(
                                context, schemeCode, mf.redemptionQty.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                successMessage(context,
                                    "Please check the data you have provided"));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              successMessage(context,
                                  "Error processing redemption: ${e.toString()}"));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(0, 40), // width, height

                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: mf.loading == true
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
                              text: "Redeem",
                              theme: theme.isDarkMode,
                              color: colors.colorWhite,
                              fw: 2,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/provider/portfolio_provider.dart';

import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../models/portfolio_model/mf_holdings_model.dart';
import '../../sharedWidget/snack_bar.dart';

class RedemptionBottomScreenNew extends StatefulWidget {
  const RedemptionBottomScreenNew({super.key});

  @override
  State<RedemptionBottomScreenNew> createState() => _RedemptionBottomScreenNewState();
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
                offset: Offset(0.0, 0.0)
              )
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      color: Color(0xFFFCEFD4),
                    ),
                    child: Center(
                      child: Text(
                        "Redemption ",
                        style: textStyle(
                          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                          14,
                          FontWeight.w600
                        )
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mf.holssinglelist?.isNotEmpty == true 
                              ? (mf.holssinglelist![0]?.name ?? "Unknown Scheme") 
                              : 
                              "Unknown Scheme",
                          style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                            15,
                            FontWeight.w600
                          )
                        ),
                        const SizedBox(height: 5),
                      ],
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Redemption Units",
                              style: textStyle(
                                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                14,
                                FontWeight.w600
                              )
                            ),
                            Row(
                              children: [
                                Text(
                                  "Total Units: ",
                                  style: textStyle(
                                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                    14,
                                    FontWeight.w600
                                  )
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  mf.holssinglelist?.isNotEmpty == true 
                                      ? (mf.holssinglelist![0]?.avgQty ?? "0.00") 
                                      : 
                                      "0.00",
                                  style: textStyle(
                                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                    10,
                                    FontWeight.w600
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              try {
                                final minRedemptionQty = mf.holssinglelist?.isNotEmpty == true 
                                    ? mf.holssinglelist![0]?.minRedemptionQty 
                                    : null;
                                    
                                final netUnits = mf.holssinglelist?.isNotEmpty == true 
                                    ? mf.holssinglelist![0]?.avgQty 
                                    : null;
                                    
                                final navStr = mf.holssinglelist?.isNotEmpty == true 
                                    ? mf.holssinglelist![0]?.avgQty 
                                    : null;
                                
                                mf.checkRedemption(value, minRedemptionQty, netUnits, navStr);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  successMessage(context, "Error validating redemption: ${e.toString()}")
                                );
                              }
                            }
                          },
                          textAlign: TextAlign.start,
                          style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                            14,
                            FontWeight.w600
                          ),
                          keyboardType: TextInputType.number,
                          controller: mf.redemptionQty,
                          decoration: InputDecoration(
                            fillColor: theme.isDarkMode 
                                ? colors.darkGrey 
                                : const Color(0xffF1F3F8),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)
                            ),
                            disabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)
                            ),
                            contentPadding: const EdgeInsets.all(13),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)
                            ),
                          ),
                        ),
                        if (mf.redemptionError != null && mf.redemptionError!.isNotEmpty) ...[
                          Text(
                            mf.redemptionError!,
                            textAlign: TextAlign.start,
                            style: textStyle(colors.kColorRedText, 10, FontWeight.w500),
                          ),
                          const SizedBox(height: 6)
                        ],
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                              child: Text(
                                "Min. redemption units ${mf.holssinglelist?.isNotEmpty == true ? (mf.holssinglelist![0]?.minRedemptionQty ?? 'N/A') : 'N/A'}",
                                // "Min.  ",
                                style: textStyle(
                                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                  11,
                                  FontWeight.w600
                                )
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (mf.redemptionOrderError != null && mf.redemptionOrderError!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            mf.redemptionOrderError!,
                            textAlign: TextAlign.start,
                            style: textStyle(colors.kColorRedText, 12, FontWeight.w500)
                          ),
                          const SizedBox(height: 6)
                        ]
                      ]
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          redemptionValue.toStringAsFixed(2),
                          style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                            16,
                            FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          " Redemption Value",
                          style: textStyle(
                            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                            14,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          final minRedemptionQty = mf.holssinglelist?.isNotEmpty == true 
                              ? mf.holssinglelist![0]?.minRedemptionQty 
                              : null;
                              
                          final netUnits = mf.holssinglelist?.isNotEmpty == true 
                              ? mf.holssinglelist![0]?.avgQty 
                              : null;
                              
                          final navStr = mf.holssinglelist?.isNotEmpty == true 
                              ? mf.holssinglelist![0]?.avgNav 
                              : null;
                          
                          if (mf.checkRedemption(mf.redemptionQty.text, minRedemptionQty, netUnits, navStr)) {
                            final schemeCode = mf.holssinglelist?.isNotEmpty == true 
                                ? (mf.holssinglelist![0]?.sCHEMECODE ?? 'DefaultScheme')
                                : 'DefaultScheme';
                                
                            mf.mfRedemption(context, schemeCode, mf.redemptionQty.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              successMessage(context, "Please check the data you have provided")
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            successMessage(context, "Error processing redemption: ${e.toString()}")
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(145, 37),
                        backgroundColor: colors.colorBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: mf.loading == true
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
                            "Redeem",
                            style: textStyle(
                              const Color.fromARGB(255, 255, 255, 255),
                              14,
                              FontWeight.w500,
                            ),
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

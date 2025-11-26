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

class RedemptionBottomScreen extends ConsumerStatefulWidget {
  final MFHoldingsModel mfHoldingData;
// , required this.bondInfo
  const RedemptionBottomScreen({super.key, required this.mfHoldingData});

  @override
  ConsumerState<RedemptionBottomScreen> createState() => _RedemptionBottomScreenState();
}

class _RedemptionBottomScreenState extends ConsumerState<RedemptionBottomScreen> {
  // String upierrortext = "Please enter the UPI Id";
  // late BondDetails bondDetails;

  var ischecked = false;

  @override
  void initState() {
    try {
      final portfolioRef = ref.read(portfolioProvider);
      final mfRef = ref.read(mfProvider);
      
      if (portfolioRef.mfQuotes?.minRdQty != null) {
        mfRef.redemptionQty.text = portfolioRef.mfQuotes!.minRdQty!;
        
        final redemptionQty = double.tryParse(mfRef.redemptionQty.text) ?? 0.0;
        final navValue = double.tryParse(widget.mfHoldingData.exchTsym?.firstOrNull?.nav ?? "0.0") ?? 0.0;
        
        mfRef.redemptionAmount.text = (redemptionQty * navValue).toStringAsFixed(2);
      }
    } catch (e) {
      debugPrint("Error initializing redemption values: $e");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final theme = ref.watch(themeProvider);
    final mf = ref.watch(mfProvider);
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color:
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(0.0, 0.0))
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      color: Color(
                          0xFFFCEFD4), //theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                      // boxShadow: [
                      //   // BoxShadow(
                      //   //     color: Color(0xff999999),
                      //   //     blurRadius: 4.0,
                      //   //     offset: Offset(2.0, 0.0))
                      // ]
                    ),
                    // color: Color(0xFFFCEFD4),

                    child: Center(
                      child: Text(
                          "Redemption",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w600)),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.mfHoldingData.exchTsym?.firstOrNull?.cname ?? "Unknown Scheme",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  15,
                                  FontWeight.w600)),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text("Redemption Units",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600)),
                            
                            ],
                          ),
                          Row(
                            children: [
                              Text("Total Units: ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text(widget.mfHoldingData.holdqty ?? "0.0",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      10,
                                      FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value){
                          try {
                            if (value.isNotEmpty) {
                              mf.checkRedemption(value, portfolio.mfQuotes!.minRdQty, widget.mfHoldingData.holdqty!, widget.mfHoldingData.exchTsym?.firstOrNull?.nav);
                              
                              // Update redemption amount
                              final qty = double.tryParse(value) ?? 0.0;
                              final nav = double.tryParse(widget.mfHoldingData.exchTsym?.firstOrNull?.nav ?? "0.0") ?? 0.0;
                              mf.redemptionAmount.text = (qty * nav).toStringAsFixed(2);
                            }
                          } catch (e) {
                            debugPrint("Error validating redemption: $e");
                          }
                        },
                        // initialValue:portfolio.mfQuotes!.minRdQty,
                        // readOnly: bonds.loading ? true : false,
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
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          contentPadding: const EdgeInsets.all(13),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      if(mf.redemptionError != null && mf.redemptionError!.isNotEmpty)...[
                        Text("${mf.redemptionError}",
                        textAlign: TextAlign.start,
              style: textStyle(colors.kColorRedText, 10, FontWeight.w500)),
            const SizedBox(height: 6)
                      ],
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0,top: 5.0),
                            child: Text("Min. redemption units ${portfolio.mfQuotes!.minRdQty}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    11,
                                    FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 15),
              Row(
                        children: [
                          Text("Redemption amount",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600)),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        readOnly: true,
                        textAlign: TextAlign.start,
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
                        keyboardType: TextInputType.number,
                        controller: mf.redemptionAmount,
                        decoration: InputDecoration(
                          prefixIcon: InkWell(child: SvgPicture.asset(assets.rupee,
                //             theme.isDarkMode
                //                 ? assets.darkCMinus
                //                 : assets.minusIcon,
                            fit: BoxFit.scaleDown),
                          ),
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          contentPadding: const EdgeInsets.all(13),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                       Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0,top: 5.0),
                            child: Text("Max. redemption amount ${double.parse(widget.mfHoldingData.holdqty!) * double.parse(portfolio.mfQuotes!.nav!)}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    11,
                                    FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          
                        ],
                      ),
                      if(mf.redemptionOrderError != "")...[
                        const SizedBox(height: 8),
                        Text("${mf.redemptionOrderError}",
                        textAlign: TextAlign.start,
              style: textStyle(colors.kColorRedText, 12, FontWeight.w500)),
            const SizedBox(height: 6)
                      ]
                    ]),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                     
                    ListTile(
                       
                      trailing: ElevatedButton(
                        onPressed: () {
                          try {
                            final minRdQty = portfolio.mfQuotes?.minRdQty;
                            final holdQty = widget.mfHoldingData.holdqty;
                            final navValue = widget.mfHoldingData.exchTsym?.firstOrNull?.nav;
                            
                            if (minRdQty == null || holdQty == null || navValue == null) {
                                successMessage(context, "Missing fund information"
                              );
                              return;
                            }
                            
                            if (mf.checkRedemption(mf.redemptionQty.text, minRdQty, holdQty, navValue)) {
                              final tsym = widget.mfHoldingData.exchTsym?.firstOrNull?.tsym;
                              if (tsym != null) {
                                mf.mfRedemption(context, tsym, mf.redemptionQty.text);
                              } else {
                                  successMessage(context, "Missing scheme symbol"
                                );
                              }
                            } else {
                                successMessage(context, "Please check the data you have provided"
                              );
                            }
                          } catch (e) {
                              successMessage(context, "Error processing redemption: ${e.toString()}"
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(145, 37),
                          backgroundColor: 
                          // theme.isDarkMode
                      // ? 
                      colors.colorBlack,
                      // : colors.colorbluegrey,
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
                          : Text("Redeem",
                              style: textStyle(const Color.fromARGB(255, 255, 255, 255), 14,
                                  FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/ipo_error_widget.dart';

class RedemptionBottomScreen extends StatefulWidget {
  // final BondsList bondInfo;
// , required this.bondInfo
  const RedemptionBottomScreen({super.key});

  @override
  State<RedemptionBottomScreen> createState() => _RedemptionBottomScreenState();
}

class _RedemptionBottomScreenState extends State<RedemptionBottomScreen> {
  // String upierrortext = "Please enter the UPI Id";
  // late BondDetails bondDetails;

  var ischecked = false;

  @override
  void initState() {
    setState(() {
      // addNewItem();

      // maxValue = mininv(double.parse(widget.bondInfo.minPrice!).toDouble(),
      //         int.parse(widget.bondInfo.minBidQuantity!).toInt())
      //     .toInt();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      // final upiid = watch(transcationProvider);
      final theme = watch(themeProvider);

      return DraggableScrollableSheet(
          initialChildSize: 0.45,
          maxChildSize: .99,
          expand: false,
          builder: (context, scrollController) {
            return Container(
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
                              "Bond window is open from  till  on trading days.",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  10,
                                  FontWeight.w600)),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("name",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      15,
                                      FontWeight.w600)),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  // CustomExchBadge(
                                  //     exch: widget.bondInfo.symbol!),
                                  // CustomExchBadge(exch: widget.bondInfo.isin!)
                                ],
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("Units",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  Text("qty",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          10,
                                          FontWeight.w600)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Units",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  Text("qty",
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
                            // readOnly: bonds.loading ? true : false,
                            textAlign: TextAlign.start,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                            keyboardType: TextInputType.number,
                            // controller: bondDetails.quantityController,
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
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0,top: 5.0),
                                child: Text("Min. redemption uints NaN",
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
                            // readOnly: bonds.loading ? true : false,
                            textAlign: TextAlign.start,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                            keyboardType: TextInputType.number,
                            // controller: bondDetails.quantityController,
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
                           Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0,top: 5.0),
                                child: Text("Max. redemption amount 169.356",
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
                            onPressed: () {},
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
                            child: Text("Continue",
                                style: textStyle(const Color(0xff999999), 14,
                                    FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
    });
  }
}

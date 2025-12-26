import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/ipo_model/ipo_details_model.dart';
import 'package:mynt_plus/models/ipo_model/ipo_place_order_model.dart';
import 'package:mynt_plus/provider/iop_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../../../res/global_state_text.dart';

class OrderScreenbottomPage extends ConsumerStatefulWidget {
  final List<IpoDetails> addIpo;
  final mainstream;
  const OrderScreenbottomPage(
      {super.key, required this.addIpo, required this.mainstream});

  @override
  ConsumerState<OrderScreenbottomPage> createState() =>
      _OrderScreenbottomPage();
}

class _OrderScreenbottomPage extends ConsumerState<OrderScreenbottomPage> {
  String upierrortext = "Please enter the UPI Id";
  var ischecked = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final ipo = ref.watch(ipoProvide);
      final upiid = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 0,
            right: 0,
            top: 16,
            bottom: 16,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          onTap: () {
                            Navigator.pop(context);
                          },
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
                  Container(
                    child: TextWidget.titleText(
                      text: "UPI ID (Virtual payment address)",
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 45,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      readOnly: ipo.loading ? true : false,
                      controller: upiid.upiid,
                      style: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 0,
                      ),
                      decoration: InputDecoration(
                        fillColor: colors.btnBg,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: colors.btnOutlinedBorder),
                            borderRadius: BorderRadius.circular(5)),
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: colors.btnOutlinedBorder),
                            borderRadius: BorderRadius.circular(5)),
                        contentPadding: const EdgeInsets.all(13),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: colors.btnOutlinedBorder),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          upiid.upiid.text = value;
                          if (upiid.upiid.text.isEmpty) {
                            upierrortext = "UPI ID cannot be empty";
                            ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
                          } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                              .hasMatch(upiid.upiid.text = value)) {
                            upierrortext = 'Invalid UPI ID format';
                            ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
                          } else {
                            upierrortext = '';
                            ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
                          }
                        });
                      },
                    ),
                  ),
                  if (upiid.upiid.text.isEmpty ||
                      !RegExp(r'^[\w.-]+@[\w]+$').hasMatch(upiid.upiid.text)) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    TextWidget.captionText(
                      theme: false,
                      text: upierrortext,
                      color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                      fw: 3,
                    ),
                  ],
                  ipo.upivalid
                      ? TextWidget.captionText(
                          theme: false,
                          text: ipo.upierror,
                           color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                            fw: 3,
                        )
                      : Container(),
                  const SizedBox(height: 16),
        
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        // padding:const EdgeInsets.all(0) ,
                        splashRadius: 20,
                        onPressed: ipo.loading
                            ? null
                            : () {
                                setState(() {
                                  ischecked = !ischecked;
                                  if (ipo.checkForErrorsInSMEPlaceOrder(
                                      widget.addIpo)) {
                                    ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                        true;
                                  } else {
                                        warningMessage(context,
                                            "Can't able place Order with current selected combination of Bids");
                                    // ischecked = false;
                                    ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                        false;
                                    ischecked = false;
                                  }
                                });
                              },
                        icon: SvgPicture.asset(theme.isDarkMode
                            ? ischecked
                                ? assets.darkCheckedboxIcon
                                : assets.darkCheckboxIcon
                            : ischecked
                                ? assets.checkedbox
                                : assets.checkbox),
                      ),
                      // const SizedBox(width: 10),
                      Expanded(
                        child: TextWidget.subText(
                          text:
                              "I hereby undertake that I have read the Red Herring Prospectus and I am eligible bidder as per the applicable provisions of SEBI (Issue of Capital & Disclosure Agreement, 2009) regulations",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3,
                        ),
                      ),
                    ],
                  ),
        
                  const SizedBox(height: 16),
        
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        elevation: 0,
                        // side: BorderSide(
                        //     color: ischecked == false
                        //         ? colors.primaryLight
                        //         : colors.primaryDark),
                        backgroundColor: ischecked == false
                            ? colors.primaryLight.withOpacity(0.6)
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: ischecked == true
                          ? ipo.loading
                              ? null
                              : () {
                                  if (upiid.upiid.text.isEmpty) {
                                        warningMessage(
                                            context, '* UPI ID cannot be empty');
                                  } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                                      .hasMatch(upiid.upiid.text)) {
                                        warningMessage(
                                            context, 'Invalid UPI ID format');
                                  } else {
                                    ipoplaceorder(upiid, ipo);
                                  }
                                }
                          : () {},
                      child: ipo.loading
                          ? const SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xff666666)),
                            )
                          : TextWidget.titleText(
                              text: "Apply",
                              theme: false,
                              color: colors.colorWhite,
                              fw: 2,
                            ),
                    ),
                  ),
        
                  // /// Buttons
        
                  // /// Slider (Shows when OK button is clicked)
                  // if (_showSlider)
                  //   Column(
                  //     children: [
                  //       SizedBox(height: 10),
                  //       Text(
                  //           "Adjust Value: ${_sliderValue.toStringAsFixed(2)}"),
                  //       Slider(
                  //         value: _sliderValue,
                  //         min: 0,
                  //         max: 1,
                  //         divisions: 10,
                  //         label: _sliderValue.toStringAsFixed(2),
                  //         onChanged: (newValue) {
                  //           setState(() {
                  //             _sliderValue = newValue;
                  //           });
                  //         },
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: widget.mainstream.type.toString(),
      symbol: widget.mainstream.symbol.toString(),
      category:
          ipo.ipoCategoryvalue == "Individual" || ipo.ipoCategoryvalue == "HNI"
              ? "IND"
              : ipo.ipoCategoryvalue == "Employee"
                  ? "EMP"
                  : ipo.ipoCategoryvalue == "Shareholder"
                      ? "SHA"
                      : ipo.ipoCategoryvalue == "Policyholder"
                          ? "POL"
                          : "",
      name: widget.mainstream.name.toString(),
      applicationNumber: '',
      respBid: [BidReference(bidReferenceNumber: '')],
    );
    final String iposupiid = upiid.upiid.text;
    List<IposBid> iposbids = [];
    for (int i = 0; i < widget.addIpo.length; i++) {
      iposbids.add(IposBid(
          bitis: true,
          qty: int.parse(widget.addIpo[i].qualityController.text).toInt(),
          cutoff: widget.addIpo[i].isChecked,
          price:
              double.parse(widget.addIpo[i].bidpricecontroller.text).toDouble(),
          total: widget.addIpo[i].requriedprice.toDouble()));
    }

    // for (int i = 0; i < iposbids.length; i++) {
    //   print(
    //       "Text: ${iposbids[i].bitis} Checkbox: ${iposbids[i].qty}, requried:${iposbids[i].cutoff},bidprice:${iposbids[i].price} value Total: ${iposbids[i].total}");
    // }
    await ref.read(ipoProvide).fetchupiidvalidation(
        context, upiid.upiid.text, "343245", menudata, iposbids, iposupiid);
  }
}

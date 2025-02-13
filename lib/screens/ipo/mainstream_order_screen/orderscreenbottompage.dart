import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/ipo_model/ipo_details_model.dart';
import 'package:mynt_plus/models/ipo_model/ipo_mainstream_model.dart';
import 'package:mynt_plus/models/ipo_model/ipo_place_order_model.dart';
import 'package:mynt_plus/provider/iop_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/sharedWidget/ipo_error_widget.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

class OrderScreenbottomPage extends StatefulWidget {
  final List<IpoDetails> addIpo;
  final mainstream;
  const OrderScreenbottomPage(
      {super.key, required this.addIpo, required this.mainstream});

  @override
  State<OrderScreenbottomPage> createState() => _OrderScreenbottomPage();
}

class _OrderScreenbottomPage extends State<OrderScreenbottomPage> {
  String upierrortext = "Please enter the UPI Id";
  var ischecked = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer(builder: (context, watch, child) {
      final ipo = watch(ipoProvide);
      final upiid = watch(transcationProvider);
      final theme = watch(themeProvider);
      return Padding(
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                // padding: null,
                child: Text("UPI ID (Virtual payment adress)",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600)),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 44,
                child: TextFormField(
                  readOnly: ipo.loading ? true : false,
                  controller: upiid.upiid,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600),
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
                  onChanged: (value) {
                    setState(() {
                      upiid.upiid.text = value;
                      if (upiid.upiid.text.isEmpty) {
                        upierrortext = "* UPI ID cannot be empty";
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
                  height: 6,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IpoErrorBadge(
                    errorName: upierrortext,
                  ),
                ),
              ],
              ipo.upivalid
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: IpoErrorBadge(
                        errorName: ipo.upierror,
                      ))
                  : Container(),
              const SizedBox(height: 20),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                        splashRadius: 20,
                        onPressed: ipo.loading
                            ? null
                            : () {
                                setState(() {
                                  // ischecked = !ischecked;
                                  if (ipo.checkForErrorsInSMEPlaceOrder(
                                      widget.addIpo)) {
                                    ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                        true;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        warningMessage(context,
                                            "can't able place Order with current selected combination of Bids"));
                                    ischecked = false;
                                    ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                        false;
                                  }
                                });
                              },
                        icon: SvgPicture.asset(theme.isDarkMode
                            ? ipo.isMainIPOPlaceOrderBtnActive
                                ? assets.darkCheckedboxIcon
                                : assets.darkCheckboxIcon
                            : ipo.isMainIPOPlaceOrderBtnActive
                                ? assets.checkedbox
                                : assets.checkbox)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "I hereby undertake that I have read the Red Herring Prospectus and I am eligible bidder as per the applicable provisions of SEBI (Issue of Capital & Disclosure Agreement, 2009) regulations",
                        style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 35),
                    elevation: 0,
                    backgroundColor: !theme.isDarkMode
                        ? ipo.isMainIPOPlaceOrderBtnActive == false
                            ? const Color(0xfff5f5f5)
                            : colors.colorBlack
                        : ipo.isMainIPOPlaceOrderBtnActive == false
                            ? colors.darkGrey
                            : colors.colorbluegrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () {
                    if (upiid.upiid.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          warningMessage(context, '* UPI ID cannot be empty'));
                    } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                        .hasMatch(upiid.upiid.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          warningMessage(context, 'Invalid UPI ID format'));
                    } else {
                      ipoplaceorder(upiid, ipo);
                    }
                  },
                  child: ipo.loading
                      ? const SizedBox(
                          width: 18,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xff666666)),
                        )
                      : Text("Apply",
                          style: textStyle(
                              !theme.isDarkMode
                                  ? ipo.isMainIPOPlaceOrderBtnActive == false
                                      ? const Color(0xff999999)
                                      : colors.colorWhite
                                  : ipo.isMainIPOPlaceOrderBtnActive == false
                                      ? colors.darkGrey
                                      : colors.colorBlack,
                              14,
                              FontWeight.w500)),
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
      );
    });
  }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: widget.mainstream.type.toString(),
      symbol: widget.mainstream.symbol.toString(),
      category: ipo.ipoCategoryvalue == "Individual"
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
    await context.read(ipoProvide).fetchupiidvalidation(
        context, upiid.upiid.text, "343245", menudata, iposbids, iposupiid);
  }
}

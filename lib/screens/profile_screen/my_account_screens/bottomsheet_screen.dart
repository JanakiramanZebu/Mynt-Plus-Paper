import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/profile_all_details_provider.dart';

import 'package:mynt_plus/provider/thems.dart';
// import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
// import 'package:mynt_plus/sharedWidget/ipo_error_widget.dart';

class BottomSheetScreen extends StatefulWidget {
  // final BondsList bondInfo;

  const BottomSheetScreen({super.key, }); // required this.bondInfo

  @override
  State<BottomSheetScreen> createState() =>
      _BottomSheetScreenState();
}

class _BottomSheetScreenState extends State<BottomSheetScreen> {
  // String upierrortext = "Please enter the UPI Id";
  // late BondDetails bondDetails;

  var ischecked = false;

  @override
  void initState() {
    setState(() {
      // bondDetails = BondDetails(
      //     quantitytext:
      //         "${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!).toInt()).toInt()}",
      //     bidprice: "${double.parse(widget.bondInfo.cutoffPrice!).toInt()}",
      //     lotsize: (int.parse(widget.bondInfo.lotSize!) /
      //             double.parse(widget.bondInfo.faceValue!))
      //         .toInt(),
      //     faceValue: double.parse(widget.bondInfo.faceValue!).toInt(),
      //     // availableLedgerBalance: double.parse(context.read(bondsProvider).ledgerBalModel?.total?? "0.00"),
      //     minrequriedprice:
      //         (double.parse(widget.bondInfo.cutoffPrice!).toInt() *
      //                 (int.parse(widget.bondInfo.minBidQuantity!) /
      //                     double.parse(widget.bondInfo.faceValue!)))
      //             .toInt(),
      //     maxrequriedprice:
      //         (double.parse(widget.bondInfo.cutoffPrice!).toInt() *
      //                 (int.parse(widget.bondInfo.maxQuantity!) /
      //                     double.parse(widget.bondInfo.faceValue!)))
      //             .toInt());

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
      final profile = watch(profileAllDetailsProvider);
      // final upiid = watch(transcationProvider);
      final theme = watch(themeProvider);

      // if (profile.checkForErrorsInBondPlaceOrder(bondDetails)) {
      //   profile.setisBondPlaceOrderBtnActiveValue = true;
      // }
      return SingleChildScrollView(
          // initialChildSize: 0.50,
          // maxChildSize: .99,
          // expand: false,
          // builder: (context, scrollController) {
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
                              "hello",//"Bond window is open from ${widget.bondInfo.dailyStartTime} till ${widget.bondInfo.dailyEndTime} on trading days.",
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
                              Text("h1",
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
                                  CustomExchBadge(
                                      exch: "widget.bondInfo.symbol!"),
                                  CustomExchBadge(exch: "widget.bondInfo.isin!")
                                ],
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                     "h2 ",// "(${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()} - ${(int.parse(widget.bondInfo.maxQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()})",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          10,
                                          FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 44,
                                child: TextFormField(
                                  readOnly:true ? true : false,
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(),//bondDetails.quantityController,
                                  decoration: InputDecoration(
                                    fillColor: theme.isDarkMode
                                        ? colors.darkGrey
                                        : const Color(0xffF1F3F8),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    contentPadding: const EdgeInsets.all(13),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    suffixIcon: InkWell(
                                      onTap: profile.loading
                                          ? null
                                          : () {
                                              "profile";
                                              // setState(() {
                                              //   profile.setMainIPOPlaceOrderRequiredMaxPrice =
                                              //       bondDetails;

                                              // });
                                            },
                                      child: SvgPicture.asset(
                                          theme.isDarkMode
                                              ? assets.darkAdd
                                              : assets.addIcon,
                                          fit: BoxFit.scaleDown),
                                    ),
                                    prefixIcon: InkWell(
                                      onTap:
                                          // bondDetails.quantityController.text ==
                                          //         bondDetails.quantitytext
                                          //     ? null
                                          //     : profile.loading
                                          //         ? null
                                                  // :
                                                   () {
                                                      // profile.substractQuantity(
                                                      //     bondDetails);
                                                      // setState(() {
                                                      //   ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                      //       addIpo;
                                                      //   // maxValue = addIpo
                                                      //   //     .map((map) => map
                                                      //   //         .requriedprice)
                                                      //   //     .reduce((a,
                                                      //   //             b) =>
                                                      //   //         a > b
                                                      //   //             ? a
                                                      //   //             : b);
                                                      // });
                                                    },
                                      child: SvgPicture.asset(
                                          theme.isDarkMode
                                              ? assets.darkCMinus
                                              : assets.minusIcon,
                                          fit: BoxFit.scaleDown),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // profile.quantityOnchange(bondDetails, value);
                                    // setState(() {
                                    //   ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                    //       addIpo;
                                    // });
                                  },
                                ),
                              ),
                              // if (bondDetails.quantityerrortext.isNotEmpty) ...[
                              //   const SizedBox(
                              //     height: 6,
                              //   ),
                              //   IpoErrorBadge(
                              //     errorName: bondDetails.quantityerrortext,
                              //   )
                              // ],
                              // if (bondDetails.biderrortext.isNotEmpty) ...[
                              //   const SizedBox(
                              //     height: 6,
                              //   ),
                              //   IpoErrorBadge(
                              //     errorName: bondDetails.biderrortext,
                              //   )
                              // ],
                            ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // if (bondDetails.ledgerBalErrorText.isNotEmpty) ...[
                        //         const SizedBox(
                        //           height: 6,
                        //         ),
                        //         IpoErrorBadge(
                        //           errorName: bondDetails.ledgerBalErrorText,
                        //         )
                        //       ],
                        Text("Ledger Balance : total ",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                12,
                                FontWeight.w600)),
                        ListTile(
                          title: Text(
                              "₹ bondDetails.minrequriedprice.toString()",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w600)),
                          subtitle: Text("Total Investment",
                              style: textStyle(const Color(0xff666666), 13,
                                  FontWeight.w500)),
                          trailing: ElevatedButton(
                              onPressed:(){},
                              //  profile.isBondPlaceOrderBtnActive
                              //  profile.checkSufficientLedgerBal(bondDetails)
                              //     ? profile.isBondPlaceOrderBtnActive ? (){
                              //       // place order function
                              //       Map<String,dynamic>  bondOrderData={};
                              //       bondOrderData["symbol"]=widget.bondInfo.symbol;
                              //       bondOrderData["investmentValue"]=(bondDetails.faceValue * int.parse(bondDetails.quantitytext)).toInt();
                              //       bondOrderData["price"]=int.parse(bondDetails.bidprice);
                              //       profile.placeBondOrder(context,bondOrderData);

                              //     } : () {
                              //       // disable button on validation error

                              //     }
                              //     : () async {
                              //       // insufficeint fund redirect fund screen
                              //       TranctionProvider transaction;
                              //       transaction = context.read(transcationProvider);
                              //         await transaction
                              //                 .fetchValidateToken(context);
                              //             Future.delayed(
                              //                 const Duration(milliseconds: 100),
                              //                 () async {
                              //               await transaction.ip();
                              //               await transaction.fetchupiIdView(
                              //                   transaction.bankdetails!.dATA![
                              //                       transaction.indexss][1],
                              //                   transaction.bankdetails!.dATA![
                              //                       transaction.indexss][2]);

                              //               await transaction
                              //                   .fetchcwithdraw(context);
                              //             });
                              //             transaction.changebool(true);
                              //             Navigator.pushNamed(
                              //                 context, Routes.fundscreen,
                              //                 arguments: transaction);

                              //     },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(145, 37),
                                backgroundColor: !theme.isDarkMode
                                    ? true
                                        ? 
                                                true
                                            ? colors.colorBlack
                                            : const Color(0xfff5f5f5)
                                        : colors.colorBlack
                                    :true
                                        ? 
                                                true
                                            ? const Color(0xfff5f5f5)
                                            : colors.colorBlack
                                        : const Color(0xfff5f5f5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: true
                                  ? Text(
                                      "Continue",
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? 
                                                      true
                                                  ? colors.colorWhite
                                                  : const Color(0xff999999)
                                              :
                                                      true
                                                  ? colors.colorBlack
                                                  : colors.darkGrey,
                                          14,
                                          FontWeight.w500),
                                    )
                                  : Text(
                                      "Add Fund",
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500),
                                    )
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          // }
          );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/models/bonds_model/bonds_place_order_details_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/ipo_error_widget.dart';

import '../../../res/global_state_text.dart';

class BondOrderScreenbottomPage extends ConsumerStatefulWidget {
  final BondsList bondInfo;

  const BondOrderScreenbottomPage({super.key, required this.bondInfo});

  @override
  ConsumerState<BondOrderScreenbottomPage> createState() =>
      _BondOrderScreenbottomPageState();
}

class _BondOrderScreenbottomPageState
    extends ConsumerState<BondOrderScreenbottomPage> {
  // String upierrortext = "Please enter the UPI Id";
  late BondDetails bondDetails;

  var ischecked = false;

  String formatAmount(amount) {
    amount = double.parse(amount.toString());
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(1)}Cr"; // 1 Cr+
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(1)}L"; // 1 Lakh+
    } else {
      return amount.toString();
    }
  }

  @override
  void initState() {
    setState(() {
      bondDetails = BondDetails(
          quantitytext:
              "${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!).toInt()).toInt()}",
          bidprice: "${double.parse(widget.bondInfo.cutoffPrice!).toInt()}",
          lotsize: (int.parse(widget.bondInfo.lotSize!) /
                  double.parse(widget.bondInfo.faceValue!))
              .toInt(),
          faceValue: double.parse(widget.bondInfo.faceValue!).toInt(),
          // availableLedgerBalance: double.parse(ref.read(bondsProvider).ledgerBalModel?.total?? "0.00"),
          minrequriedprice:
              (double.parse(widget.bondInfo.cutoffPrice!).toInt() *
                      (int.parse(widget.bondInfo.minBidQuantity!) /
                          double.parse(widget.bondInfo.faceValue!)))
                  .toInt(),
          maxrequriedprice:
              (double.parse(widget.bondInfo.cutoffPrice!).toInt() *
                      (int.parse(widget.bondInfo.maxQuantity!) /
                          double.parse(widget.bondInfo.faceValue!)))
                  .toInt());

      // addNewItem();

      // maxValue = mininv(double.parse(widget.bondInfo.minPrice!).toDouble(),
      //         int.parse(widget.bondInfo.minBidQuantity!).toInt())
      //     .toInt();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final bonds = ref.watch(bondsProvider);
      // final upiid = ref.watch(transcationProvider);
      final theme = ref.watch(themeProvider);

      if (bonds.checkForErrorsInBondPlaceOrder(bondDetails)) {
        bonds.setisBondPlaceOrderBtnActiveValue = true;
      }
      return SafeArea(
        child: SingleChildScrollView(
            // initialChildSize: 0.50,
            // maxChildSize: .99,
            // expand: false,
            // builder: (context, scrollController) {
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
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              left: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              right: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.subText(
                            text: "${widget.bondInfo.name}",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              TextWidget.paraText(
                                fw: 3,
                                text: widget.bondInfo.symbol!,
                                textOverflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                theme: false,
                              ),
                              TextWidget.paraText(
                                fw: 3,
                                text: widget.bondInfo.isin!,
                                textOverflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                theme: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWidget.subText(
                            text: "₹ ${widget.bondInfo.cutoffPrice!}",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextWidget.paraText(
                            text: "Cut-off Price",
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                          ),
                        ],
                      )
                    ],
                  )),
              SizedBox(
                height: 16,
              ),
              // Container(
              //   height: 30,
              //   decoration: const BoxDecoration(
              //     color: Color(
              //         0xFFFCEFD4), //theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              //     // boxShadow: [
              //     //   // BoxShadow(
              //     //   //     color: Color(0xff999999),
              //     //   //     blurRadius: 4.0,
              //     //   //     offset: Offset(2.0, 0.0))
              //     // ]
              //   ),
              //   // color: Color(0xFFFCEFD4),

              //   child: Center(
              //     child: Text(
              //         "Bond window is open from ${widget.bondInfo.dailyStartTime} till ${widget.bondInfo.dailyEndTime} on trading days.",
              //         style: textStyle(colors.colorBlack, 10, FontWeight.w600)),
              //   ),
              // ),
              // SizedBox(
              //   height: 16,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextWidget.subText(
                            fw: 0,
                            text: "Units",
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            theme: false,
                          ),
                          const SizedBox(width: 4),

                          TextWidget.captionText(
                            fw: 3,
                            text:
                                "(${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()} - ${(int.parse(widget.bondInfo.maxQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()})",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            theme: false,
                          ),

                          // Text(
                          //     "(${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()} - ${(int.parse(widget.bondInfo.maxQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()})",
                          //     style: textStyle(
                          //         theme.isDarkMode
                          //             ? colors.colorWhite
                          //             : colors.colorBlack,
                          //         10,
                          //         FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: 44,
                        child: TextFormField(
                          // readOnly: true,
                          readOnly: bonds.loading ? true : false,
                          textAlign: TextAlign.start,
                           style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: bondDetails.quantityController,
                          decoration: InputDecoration(
                            fillColor: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colors.colorBlue),
                                borderRadius: BorderRadius.circular(5)),
                            disabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                               borderSide: BorderSide(color: colors.colorBlue),
                                borderRadius: BorderRadius.circular(5)),
                            border: OutlineInputBorder(
                               borderSide: BorderSide(color: colors.colorBlue),
                                borderRadius: BorderRadius.circular(5)),
                            suffixIcon: InkWell(
                              onTap: bonds.loading
                                  ? null
                                  : () {
                                      bonds.addQuantity(bondDetails);
                                      // setState(() {
                                      //   bonds.setMainIPOPlaceOrderRequiredMaxPrice =
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
                            onTap: bondDetails.quantityController.text ==
                                    bondDetails.quantitytext
                                ? null
                                : bonds.loading
                                    ? null
                                    : () {
                                        bonds.substractQuantity(bondDetails);
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
                          bonds.quantityOnchange(bondDetails, value);
                          // setState(() {
                          //   ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                          //       addIpo;
                          // });
                        },
                      ),
                    ),
                    if (bondDetails.quantityerrortext.isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      TextWidget.captionText(
                        theme: false,
                        text: bondDetails.quantityerrortext,
                        color: colors.error,
                        fw: 3,
                      )
                    ],
                    if (bondDetails.biderrortext.isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      TextWidget.captionText(
                        theme: false,
                        text: bondDetails.biderrortext,
                        color: colors.error,
                        fw: 3,
                      )
                    ],
                  ]),
            ),
            const SizedBox(
              height: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bondDetails.ledgerBalErrorText.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextWidget.captionText(
                      theme: false,
                      text: bondDetails.ledgerBalErrorText,
                      color: colors.error,
                      fw: 3,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
                //  Align(
                //    alignment: Alignment.center,
                //    child: Text("Ledger Balance : ${bonds.ledgerBalModel!.total}",
                //                                style: textStyle(
                //     theme.isDarkMode
                //         ? colors.colorWhite
                //         : colors.colorBlack,
                //     12,
                //     FontWeight.w600)),
                //  ),

                  ListTile(
                    title: 
                    
                     TextWidget.titleText(text:  "₹${formatAmount(bonds.ledgerBalModel!.total)} / ₹ ${formatAmount(bondDetails.minrequriedprice)}", 
                                                                          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                                          theme: theme.isDarkMode,
                                                                          fw: 1
                                                                          ),
                    
                    
                    
                    
                    
                    
                    //  Text(
                    //     // "₹ ${bonds.ledgerBalModel!.total} / ₹ ${bondDetails.minrequriedprice.toString()}",
                    //    ,
                    //     style: textStyle(
                    //         theme.isDarkMode
                    //             ? colors.colorWhite
                    //             : colors.colorBlack,
                    //         16,
                    //         FontWeight.w600)),
                    subtitle:  TextWidget.paraText(text: "Cash / Invesment",
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        theme: theme.isDarkMode,
                        fw: 3),
                    trailing: OutlinedButton(
                        onPressed:
                            //  bonds.isBondPlaceOrderBtnActive
                            bonds.checkSufficientLedgerBal(bondDetails)
                                ? bonds.isBondPlaceOrderBtnActive
                                    ? () {
                                        bonds.toggleOrderLoad(true);
                                        // place order function
                                        Map<String, dynamic> bondOrderData = {};
                                        bondOrderData["symbol"] =
                                            widget.bondInfo.symbol;
                                        bondOrderData["investmentValue"] =
                                            (bondDetails.faceValue *
                                                    int.parse(bondDetails
                                                        .quantityController
                                                        .text))
                                                .toInt();
                                        bondOrderData["price"] =
                                            int.parse(bondDetails.bidprice);
                                        bonds.placeBondOrder(
                                            context, bondOrderData);
                                        print(
                                            'bondOrderData ::::::::::::::; $bondOrderData');
                                        bonds.toggleOrderLoad(false);
                                      }
                                    : () {
                                        // disable button on validation error
                                      }
                                : () async {
                                    // insufficeint fund redirect fund screen
                                    bonds.toggleOrderLoad(true);
                                    TranctionProvider transaction;
                                    transaction = ref.read(transcationProvider);
                                    await transaction
                                        .fetchValidateToken(context);
                                    Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () async {
                                      await transaction.ip();
                                      await transaction.fetchupiIdView(
                                          transaction.bankdetails!
                                              .dATA![transaction.indexss][1],
                                          transaction.bankdetails!
                                              .dATA![transaction.indexss][2]);

                                      await transaction.fetchcwithdraw(context);
                                    });
                                    transaction.changebool(true);
                                    Navigator.pushNamed(
                                        context, Routes.fundscreen,
                                        arguments: transaction);
                                    bonds.toggleOrderLoad(false);
                                  },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(145, 45),
                          backgroundColor: !theme.isDarkMode
                              ? bonds.checkSufficientLedgerBal(bondDetails)
                                  ? bonds.isBondPlaceOrderBtnActive == true
                                      ? theme.isDarkMode ? colors.primaryDark : colors.primaryLight
                                      : const Color(0xfff5f5f5)
                                  : theme.isDarkMode ? colors.primaryDark : colors.primaryLight
                              : bonds.checkSufficientLedgerBal(bondDetails)
                                  ? bonds.isBondPlaceOrderBtnActive == true
                                      ? colors.colorBlue
                                      : colors.darkGrey
                                  : const Color(0xfff5f5f5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: BorderSide.none,
                        ),
                        child: bonds.orderLoad
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.colorWhite,
                                ))
                            : bonds.checkSufficientLedgerBal(bondDetails)
                                ? TextWidget.subText(
                                    text: "Continue",
                                    theme: theme.isDarkMode,
                                    color: !theme.isDarkMode
                                        ? bonds.isBondPlaceOrderBtnActive ==
                                                true
                                            ? colors.colorWhite
                                            : const Color(0xff999999)
                                        : bonds.isBondPlaceOrderBtnActive ==
                                                true
                                            ? colors.colorWhite
                                            : colors.darkGrey,
                                    fw: 2)
                                : TextWidget.subText(
                                    text: "Add Fund",
                                    theme: theme.isDarkMode,
                                    color: !theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    fw: 2)),
                  ),
                ],
              ),
            ],
          ),
        )
            // }
            ),
      );
    });
  }
}

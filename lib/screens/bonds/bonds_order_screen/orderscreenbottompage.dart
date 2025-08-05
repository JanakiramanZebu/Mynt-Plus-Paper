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
      return SingleChildScrollView(
          // initialChildSize: 0.50,
          // maxChildSize: .99,
          // expand: false,
          // builder: (context, scrollController) {
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
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${widget.bondInfo.name}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600)),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            CustomExchBadge(exch: widget.bondInfo.symbol!),
                            CustomExchBadge(exch: widget.bondInfo.isin!)
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹ ${widget.bondInfo.cutoffPrice!}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        const SizedBox(
                          height: 4,
                        ),
                        Text("Cut-off Price",
                            style: textStyle(
                                const Color(0xff666666), 10, FontWeight.w500)),
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
                        Text("Units",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(
                            "(${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()} - ${(int.parse(widget.bondInfo.maxQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()})",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                10,
                                FontWeight.w500)),
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
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
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
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
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
                      IpoErrorBadge(
                        errorName: bondDetails.quantityerrortext,
                      )
                    ],
                    if (bondDetails.biderrortext.isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      IpoErrorBadge(
                        errorName: bondDetails.biderrortext,
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
                    child: IpoErrorBadge(
                      errorName: bondDetails.ledgerBalErrorText,
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
                  title: Text(
                      // "₹ ${bonds.ledgerBalModel!.total} / ₹ ${bondDetails.minrequriedprice.toString()}",
                      "₹${formatAmount(bonds.ledgerBalModel!.total)} / ₹ ${formatAmount(bondDetails.minrequriedprice)}",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          FontWeight.w600)),
                  subtitle: Text("Cash / Invesment",
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w500)),
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
                                                      .quantityController.text))
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
                                  await transaction.fetchValidateToken(context);
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
                        minimumSize: const Size(145, 40),
                        backgroundColor: !theme.isDarkMode
                            ? bonds.checkSufficientLedgerBal(bondDetails)
                                ? bonds.isBondPlaceOrderBtnActive == true
                                    ? colors.primaryLight
                                    : const Color(0xfff5f5f5)
                                : colors.primaryLight
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
                                      ? bonds.isBondPlaceOrderBtnActive == true
                                          ? colors.colorWhite
                                          : const Color(0xff999999)
                                      : bonds.isBondPlaceOrderBtnActive == true
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
          );
    });
  }
}

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import '../../models/mf_model/mf_lumpsum_order.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/snack_bar.dart';
import '../mutual_fund_old/create_mandate_daialogue.dart';

class MFOrderScreen extends ConsumerStatefulWidget {
  final MutualFundList mfData;
  const MFOrderScreen({super.key, required this.mfData});

  @override
  ConsumerState<MFOrderScreen> createState() => _MFOrderScreenState();
}

class _MFOrderScreenState extends ConsumerState<MFOrderScreen> {
  // double invAmt = 0.00;
  @override
  void initState() {
    setState(() {
      ref.read(mfProvider).invAmt.text =
          "${widget.mfData.minimumPurchaseAmount}";
      // invAmt = double.parse("${widget.mfData.minimumPurchaseAmount ?? 0.00}");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    // final fund = ref.watch(fundProvider);
    final mfOrder = ref.watch(mfProvider);
    // print(mfOrder.orderseltab);
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 120,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 0,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                  // size: 18,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                // children: [
                //   CircleAvatar(
                //       backgroundImage: NetworkImage(
                //           "https://v3.mynt.in/mf/static/images/mf/${widget.mfData.aMCCode}.png")),
                //   const SizedBox(width: 8),
                //   Expanded(
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         Text("${widget.mfData.fSchemeName}",
                //             maxLines: 1,
                //             overflow: TextOverflow.ellipsis,
                //             style: textStyle(
                //                 theme.isDarkMode
                //                     ? colors.colorWhite
                //                     : colors.colorBlack,
                //                 16,
                //                 FontWeight.w500)),
                //         const SizedBox(height: 10),
                //         SizedBox(
                //           height: 18,
                //           child: ListView(
                //             shrinkWrap: true,
                //             scrollDirection: Axis.horizontal,
                //             children: [
                //               CustomExchBadge(
                //                   exch: widget.mfData.schemeName!
                //                           .contains("GROWTH")
                //                       ? "GROWTH"
                //                       : widget.mfData.schemeName!
                //                               .contains("IDCW PAYOUT")
                //                           ? "IDCW PAYOUT"
                //                           : widget.mfData.schemeName!
                //                                   .contains(
                //                                       "IDCW REINVESTMENT")
                //                               ? "IDCW REINVESTMENT"
                //                               : widget.mfData.schemeName!
                //                                       .contains("IDCW")
                //                                   ? "IDCW"
                //                                   : "NORMAL"),
                //         const SizedBox(width: 7),
                //               CustomExchBadge(
                //                   exch: "${widget.mfData.schemeType}"),
                //         const SizedBox(width: 7),
                //               CustomExchBadge(
                //                   exch: widget.mfData.sCHEMESUBCATEGORY!
                //                       .replaceAll("Fund", '')
                //                       .replaceAll("Hybrid", "")
                //                       .toUpperCase()),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ],
              ),
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : const Color.fromARGB(255, 250, 251, 255),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    "https://v3.mynt.in/mf/static/images/mf/${widget.mfData.aMCCode}.png",
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${(mfOrder.orderpagetitle == "SDS" && mfOrder.factSheetDataModel!.data?.name != null) ? mfOrder.factSheetDataModel!.data?.name!.replaceAll(RegExp(r'(Reg \(G\)|\(G\))$'), ' ') : '${widget.mfData.fSchemeName}'}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          17,
                                          FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 18,
                                        child: ListView(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            // CustomExchBadge(
                                            //   exch: widget.mfData.schemeName!.contains("GROWTH")
                                            //       ? "GROWTH"
                                            //       : widget.mfData.schemeName!.contains("IDCW PAYOUT")
                                            //           ? "IDCW PAYOUT"
                                            //           : widget.mfData.schemeName!.contains("IDCW REINVESTMENT")
                                            //               ? "IDCW REINVESTMENT"
                                            //               : widget.mfData.schemeName!.contains("IDCW")
                                            //                   ? "IDCW"
                                            //                   : "NORMAL",
                                            // ),
                                            const SizedBox(width: 5),
                                            if (widget.mfData.schemeType !=
                                                null) ...[
                                              CustomExchBadge(
                                                  exch:
                                                      "${widget.mfData.schemeType}"),
                                            ],
                                            const SizedBox(width: 5),
                                            if (widget.mfData.subtype !=
                                                null) ...[
                                              CustomExchBadge(
                                                exch:
                                                    "${widget.mfData.subtype}",
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 8),
                            // Row(
                            //   mainAxisAlignment:
                            //       MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         const SizedBox(height: 7),
                            //         Text(
                            //           "AUM (CR)",
                            //           style: textStyle(
                            //               const Color(0xff999999),
                            //               12,
                            //               FontWeight.w500),
                            //         ),
                            //         const SizedBox(height: 3),
                            //         Text(
                            //           (double.parse(widget.mfData.aUM!.isEmpty
                            //                   ? "0.00"
                            //                   : widget.mfData.aUM!))
                            //               .toStringAsFixed(2),
                            //           style: textStyle(colors.colorBlack, 14,
                            //               FontWeight.w600),
                            //         ),
                            //       ],
                            //     ),
                            //     Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         const SizedBox(height: 8),
                            //         Text(
                            //           "NAV",
                            //           style: textStyle(
                            //               const Color(0xff999999),
                            //               12,
                            //               FontWeight.w500),
                            //         ),
                            //         const SizedBox(height: 3),
                            //         Text(
                            //           widget.mfData.nETASSETVALUE!.isEmpty
                            //               ? "0.00"
                            //               : widget.mfData.nETASSETVALUE!,
                            //           style: textStyle(colors.colorBlack, 14,
                            //               FontWeight.w600),
                            //         ),
                            //       ],
                            //     ),
                            //     Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         const SizedBox(height: 8),
                            //         Text(
                            //           "MIN. INV",
                            //           style: textStyle(
                            //               const Color(0xff999999),
                            //               12,
                            //               FontWeight.w500),
                            //         ),
                            //         const SizedBox(height: 3),
                            //         Text(
                            //           widget.mfData.minimumPurchaseAmount!
                            //                   .isEmpty
                            //               ? "0.00"
                            //               : widget
                            //                   .mfData.minimumPurchaseAmount!,
                            //           style: textStyle(colors.colorBlack, 14,
                            //               FontWeight.w600),
                            //         ),
                            //       ],
                            //     ),
                            //     Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         const SizedBox(height: 8),
                            //         Text(
                            //           "5YR CAGR",
                            //           style: textStyle(
                            //               const Color(0xff999999),
                            //               12,
                            //               FontWeight.w500),
                            //         ),
                            //         const SizedBox(height: 3),
                            //         Text(
                            //           widget.mfData.fIVEYEARDATA?.isEmpty ??
                            //                   true
                            //               ? "0.00"
                            //               : "${widget.mfData.fIVEYEARDATA}%",
                            //           style: textStyle(colors.colorBlack, 14,
                            //               FontWeight.w600),
                            //         )
                            //       ],
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 46,
                      // decoration: BoxDecoration(
                      //     border: (Border(
                      //         top: BorderSide(
                      //             color: theme.isDarkMode
                      //                 ? colors.darkColorDivider
                      //                 : colors.colorDivider)))),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () {
                                  mfOrder.chngOrderType(
                                      mfOrder.mfOrderTpyes[index]);
                                  FocusScope.of(context).unfocus();
                                },
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    decoration: BoxDecoration(
                                        border: mfOrder.mfOrderTpye ==
                                                mfOrder.mfOrderTpyes[index]
                                            ? Border(
                                                bottom: BorderSide(
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    width: 2))
                                            : null),
                                    child: Text(mfOrder.mfOrderTpyes[index],
                                        style: textStyle(
                                            mfOrder.mfOrderTpye ==
                                                        mfOrder.mfOrderTpyes[
                                                            index] &&
                                                    theme.isDarkMode
                                                ? colors.colorWhite
                                                : mfOrder.mfOrderTpye ==
                                                        mfOrder.mfOrderTpyes[
                                                            index]
                                                    ? colors.colorBlack
                                                    : const Color(0xff666666),
                                            14,
                                            mfOrder.mfOrderTpye ==
                                                    mfOrder
                                                        .mfOrderTpyes[index]
                                                ? FontWeight.w600
                                                : FontWeight.w500))));
                          },
                          itemCount: widget.mfData.sIPFLAG == "Y"
                              ? mfOrder.mfOrderTpyes.length
                              : 1))
                ]))),
        body: TransparentLoaderScreen(
          isLoading: mfOrder.investloader,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            if (mfOrder.mfOrderTpye != "One-time") ...[
              Text("Mandates",
                  style: textStyle(
                      theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      16,
                      FontWeight.w600)),
              const SizedBox(height: 4),
              if (mfOrder.mandateData!.isNotEmpty) ...[
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    menuItemStyleData: MenuItemStyleData(
                      customHeights: mfOrder.mandateHeight(),
                    ),
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.only(top: 4, left: 16),
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.darkGrey
                            : Color(0xffF1F3F8),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4)),
                        offset: const Offset(0, 1)),
                    isExpanded: true,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : const Color(0XFF000000),
                        13,
                        FontWeight.w500),
                    hint: Text(
                      mfOrder.mandateId ?? "Select a Mandate",
                      style: textStyle(
                          const Color(0XFF000000), 13, FontWeight.w500),
                    ),
                    items: mfOrder.mandateDividers(),
                    value: mfOrder
                            .mandateDividers()
                            .any((item) => item.value == mfOrder.mandateId)
                        ? mfOrder.mandateId
                        : null,
                    onChanged: (value) async {
                      if (value != null) {
                        mfOrder.chngMandate("$value");
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),

              ElevatedButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateMandateDialogue();
                        });
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text("Create mandate",
                      style: GoogleFonts.inter(
                          textStyle: textStyle(
                              !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500)))),

              // Row(
              //   children: [
              //     IconButton(
              //         splashRadius: 20,
              //         onPressed: () {
              //           setState(() {
              //             mfOrder.setInitialPay(!mfOrder.isInitalPay);
              //             mfOrder.isValidUpiId(widget.mfData);
              //           });
              //         },
              //         icon: SvgPicture.asset(theme.isDarkMode
              //             ? mfOrder.isInitalPay
              //                 ? assets.darkCheckedboxIcon
              //                 : assets.darkCheckboxIcon
              //             : mfOrder.isInitalPay
              //                 ? assets.checkedbox
              //                 : assets.checkbox)),
              //     Text("Pay initial investment now",
              //         style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
              //   ],
              // ),
              // const SizedBox(height: 8),
              if (mfOrder.isInitalPay)
                SizedBox(
                    height: 44,
                    child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: '${widget.mfData.minimumPurchaseAmount}',
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
                        //   onTap: () {
                        //     setState(() {
                        //       if (fund.invAmt.text.isNotEmpty) {
                        //         if (double.parse(fund.invAmt.text) > invAmt) {
                        //           fund.invAmt.text =
                        //               (double.parse(fund.invAmt.text) - invAmt)
                        //                   .toString();
                        //         }
                        //       } else {
                        //         fund.invAmt.text = (invAmt).toString();
                        //       }
                        //     });
                        //   },
                        //   child: SvgPicture.asset(
                        //       theme.isDarkMode
                        //           ? assets.darkCMinus
                        //           : assets.minusIcon,
                        //       fit: BoxFit.scaleDown),
                        // ),
                        // suffixIcon: InkWell(
                        //     onTap: () {
                        //       if (fund.invAmt.text.isNotEmpty) {
                        //         fund.invAmt.text =
                        //             (double.parse(fund.invAmt.text) + invAmt)
                        //                 .toString();
                        //       } else {
                        //         fund.invAmt.text = (invAmt).toString();
                        //       }
                        //     },
                        //     child: SvgPicture.asset(
                        //         theme.isDarkMode
                        //             ? assets.darkAdd
                        //             : assets.addIcon,
                        //         fit: BoxFit.scaleDown)),

                        textCtrl: mfOrder.invAmt,
                        onChanged: (value) {
                          mfOrder.isValidUpiId(widget.mfData);
                        })),
              if (mfOrder.invAmtError != null) ...[
                const SizedBox(height: 6),
                Text("${mfOrder.invAmtError}",
                    style:
                        textStyle(colors.kColorRedText, 10, FontWeight.w500)),
              ],
              const SizedBox(height: 8)
            ],
            const SizedBox(height: 10),
            Text(
                mfOrder.mfOrderTpye == "One-time"
                    ? "Investment amount"
                    : "Installment amount",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600)),
            const SizedBox(height: 7),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 44,
                child: CustomTextFormField(
                    textAlign: TextAlign.start,
                    fillColor: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    hintText: mfOrder.mfOrderTpye == "One-time"
                        ? '${widget.mfData.minimumPurchaseAmount}'
                        : '${widget.mfData.faceValue}',
                    hintStyle: textStyle(
                        const Color(0xff666666), 15, FontWeight.w400),
                    inputFormate: [FilteringTextInputFormatter.digitsOnly],
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600),
                    //       prefixIcon: InkWell(
                    //         onTap: () {
                    //           setState(() {
                    //             if (mfOrder.mfOrderTpye == "One-time") {
                    //               if (fund.invAmt.text.isNotEmpty) {
                    //                 if (double.parse(fund.invAmt.text) > invAmt) {
                    //                   if((double.parse(fund.invAmt.text) - invAmt) < invAmt){
                    //                       ScaffoldMessenger.of(context).showSnackBar(successMessage(
                    // context, "Installment Amount should not be less than ${mfOrder.insAmt}"));
                    //                     }
                    //                     else{
                    //                   fund.invAmt.text =
                    //                       (double.parse(fund.invAmt.text) - invAmt)
                    //                           .toString();
                    //                     }
                    //                 }
                    //               } else {
                    //                 fund.invAmt.text = (invAmt).toString();
                    //               }
                    //             } else {
                    //               if (mfOrder.installmentAmt.text.isNotEmpty) {
                    //                 if (double.parse(mfOrder.installmentAmt.text) >
                    //                     double.parse(mfOrder.insAmt)) {
                    //                       if((double.parse(mfOrder.installmentAmt.text) -
                    //                     double.parse(mfOrder.insAmt)) < double.parse(mfOrder.insAmt)){
                    //                       ScaffoldMessenger.of(context).showSnackBar(successMessage(
                    // context, "Installment Amount should not be less than ${mfOrder.insAmt}"));
                    //                     }
                    //                     else{
                    //                   mfOrder.installmentAmt.text =
                    //                       (double.parse(mfOrder.installmentAmt.text) -
                    //                               double.parse(mfOrder.insAmt))
                    //                           .toString();
                    //                 }
                    //                     }
                    //               } else {
                    //                 mfOrder.installmentAmt.text = mfOrder.insAmt;
                    //               }
                    //             }
                    //           });
                    //         },
                    //         child: SvgPicture.asset(
                    //             theme.isDarkMode
                    //                 ? assets.darkCMinus
                    //                 : assets.minusIcon,
                    //             fit: BoxFit.scaleDown),
                    //       ),
                    //       // suffixIcon: InkWell(
                    //     onTap: () {
                    //       if (mfOrder.mfOrderTpye == "One-time") {
                    //         if (fund.invAmt.text.isNotEmpty) {
                    //           fund.invAmt.text =
                    //               (double.parse(fund.invAmt.text) + invAmt)
                    //                   .toString();
                    //         } else {
                    //           fund.invAmt.text = (invAmt).toString();
                    //         }
                    //       } else {
                    //         if (mfOrder.installmentAmt.text.isNotEmpty) {
                    //           mfOrder.installmentAmt.text =
                    //               (double.parse(mfOrder.installmentAmt.text) +
                    //                       double.parse(mfOrder.insAmt))
                    //                   .toString();
                    //         } else {
                    //           mfOrder.installmentAmt.text = mfOrder.insAmt;
                    //         }
                    //       }
                    //     },
                    //     child: SvgPicture.asset(
                    //         theme.isDarkMode ? assets.darkAdd : assets.addIcon,
                    //         fit: BoxFit.scaleDown)),

                    textCtrl: mfOrder.mfOrderTpye == "One-time"
                        ? mfOrder.invAmt
                        : mfOrder.installmentAmt,
                    onChanged: (value) {
                      mfOrder.isValidUpiId(widget.mfData);
                    })),
            if (mfOrder.mfOrderTpye == "One-time") ...[
              if (mfOrder.invAmtError != null) ...[
                Text("${mfOrder.invAmtError}",
                    style:
                        textStyle(colors.kColorRedText, 10, FontWeight.w500)),
                const SizedBox(height: 6)
              ],
            ] else ...[
              if (mfOrder.installmentAmtError != null) ...[
                Text("${mfOrder.installmentAmtError}",
                    style:
                        textStyle(colors.kColorRedText, 10, FontWeight.w500)),
                const SizedBox(height: 6)
              ],
            ],
            Text(
                "Min. ₹${widget.mfData.minimumPurchaseAmount} (multiple of ${widget.mfData.purchaseAmountMultiplier})",
                style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
            if (mfOrder.mfOrderTpye != "One-time") ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Frequency",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                16,
                                FontWeight.w600)),
                        const SizedBox(height: 13),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2(
                                menuItemStyleData: MenuItemStyleData(
                                    customHeights: mfOrder.frqCustHeight()),
                                buttonStyleData: ButtonStyleData(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(32)))),
                                dropdownStyleData: DropdownStyleData(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  offset: const Offset(0, 8),
                                ),
                                isExpanded: true,
                                style: textStyle(theme.isDarkMode ? colors.colorWhite :const Color(0XFF000000), 13,
                                    FontWeight.w500),
                                hint: Text(mfOrder.freqName,
                                    style: textStyle(theme.isDarkMode ? colors.colorWhite :const Color(0XFF000000),
                                        13, FontWeight.w500)),
                 
                                items: mfOrder.addFrqDividers(),
                                value: mfOrder.freqName,
                                onChanged: (value) async {
                                  mfOrder.chngFrequency("$value");
                                },
                                
                                
                                )),
                                  
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                16,
                                FontWeight.w600)),
                        const SizedBox(height: 13),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2(
                                menuItemStyleData: MenuItemStyleData(
                                    customHeights: mfOrder.dateCustHeight()),
                                buttonStyleData: ButtonStyleData(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : Color(0xffF1F3F8),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(32)))),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  offset: const Offset(0, 8),
                                ),
                                isExpanded: true,
                                style: textStyle(const Color(0XFF000000), 13,
                                    FontWeight.w500),
                                hint: Text("",
                                    style: textStyle(const Color(0XFF000000),
                                        13, FontWeight.w500)),
                                items: mfOrder.addDateDividers(),
                                value: mfOrder.dates,
                                onChanged: mfOrder.dates == "DAILY"
                                    ? null
                                    : (value) async {
                                        mfOrder.changeStartDate(value);
                                      })),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Investment duration",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          FontWeight.w600)),
                  Text(
                      "${mfOrder.invDuration.text} ${mfOrder.freqName == "DAILY" ? "Days" : mfOrder.freqName == "MONTHLY" ? "Months" : "Qtrs"}",
                      style: textStyle(
                          colors.kColorRedText, 16, FontWeight.w600)),
                ],
              ),
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
                      inputFormate: [FilteringTextInputFormatter.digitsOnly],
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          FontWeight.w600),
                      textCtrl: mfOrder.invDuration,
                      onChanged: (value) {
                        mfOrder.isValidUpiId(widget.mfData);
                      })),
              if (mfOrder.invDurationError != null) ...[
                Text("${mfOrder.invDurationError}",
                    style:
                        textStyle(colors.kColorRedText, 10, FontWeight.w500)),
                const SizedBox(height: 6)
              ]
            ],
            if (mfOrder.isInitalPay && mfOrder.mfOrderTpye != "One-time") ...[
              const SizedBox(height: 9),
              Text("Payment method",
                  style: textStyle(
                      theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      16,
                      FontWeight.w600)),
              const SizedBox(height: 14),
              DropdownButtonHideUnderline(
                  child: DropdownButton2(
                      menuItemStyleData: MenuItemStyleData(
                          customHeights: mfOrder.getCustItemsHeight()),
                      buttonStyleData: ButtonStyleData(
                          height: 36,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Color(0xffF1F3F8),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32)))),
                      dropdownStyleData: DropdownStyleData(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        offset: const Offset(0, 8),
                      ),
                      isExpanded: true,
                      style: textStyle(
                          const Color(0XFF000000), 13, FontWeight.w500),
                      hint: Text(mfOrder.paymentName,
                          style: textStyle(
                              const Color(0XFF000000), 13, FontWeight.w500)),
                      items: mfOrder.addDividers(),
                      value: mfOrder.paymentName,
                      onChanged: (value) async {
                        mfOrder.chngPayName("$value");
                      })),
              const SizedBox(height: 17),
              Text("Bank account",
                  style: textStyle(
                      theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      16,
                      FontWeight.w600)),
              const SizedBox(height: 14),
              DropdownButtonHideUnderline(
                  child: DropdownButton2(
                      menuItemStyleData: MenuItemStyleData(
                          customHeights: mfOrder.getBankCustItemsHeight()),
                      buttonStyleData: ButtonStyleData(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Color(0xffF1F3F8),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32)))),
                      dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4)),
                          offset: const Offset(0, 1)),
                      isExpanded: true,
                      style: textStyle(
                          const Color(0XFF000000), 13, FontWeight.w500),
                      hint: Text(mfOrder.accNum,
                          style: textStyle(
                              const Color(0XFF000000), 13, FontWeight.w500)),
                      items: mfOrder.addBankDividers(),
                      value: mfOrder.accNum,
                      onChanged: (value) async {
                        mfOrder.chngBankAcc("$value");
                      })),
              const SizedBox(height: 8),
              if (mfOrder.paymentName == "UPI") ...[
                const SizedBox(height: 12),
                Text("UPI ID (Virtual payment address)",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 44,
                    child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: 'exmaple@upi',
                        hintStyle: textStyle(
                            const Color(0xff666666), 14, FontWeight.w400),
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
                        textCtrl: mfOrder.upiId,
                        onChanged: (value) {
                          mfOrder.isValidUpiId(widget.mfData);
                        })),
                if (mfOrder.upiError != null) ...[
                  Text("${mfOrder.upiError}",
                      style: textStyle(
                          colors.kColorRedText, 10, FontWeight.w500)),
                  const SizedBox(height: 6)
                ]
              ],
            ] else if (mfOrder.mfOrderTpye == "One-time") ...[
              const SizedBox(height: 14),
              Text("Payment method",
                  style: textStyle(
                      theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      16,
                      FontWeight.w600)),
              const SizedBox(height: 14),
              DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                       dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : const Color.fromARGB(255, 255, 255, 255))),
                            buttonStyleData: ButtonStyleData(
                    decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xffB5C0CF).withOpacity(.15)
                            : const Color(0xffF1F3F8),
                        // border: Border.all(color: Colors.grey),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)))),
                      menuItemStyleData: MenuItemStyleData(
                          customHeights: mfOrder.getCustItemsHeight()),
                      isExpanded: true,
                      style: textStyle( 
                          const Color.fromARGB(255, 0, 0, 0), 13, FontWeight.w500),
                      hint: Text(mfOrder.paymentName,
                          style: textStyle(
                              const Color(0XFF000000), 13, FontWeight.w500)),
                      items: mfOrder.investloader == false
                          ? mfOrder.addDividers()
                          : [],
                      value: mfOrder.paymentName,
                      onChanged: (value) async {
                        mfOrder.chngPayName("$value");
                      }

                      )),
            
            
              const SizedBox(height: 18),
              Text("Bank account",
                  style: textStyle(
                      theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      16,
                      FontWeight.w600)),
              const SizedBox(height: 12),
             DropdownButtonHideUnderline(
child: DropdownButton2(
  menuItemStyleData: MenuItemStyleData(
    customHeights: mfOrder.getBankCustItemsHeight(),
  ),
  buttonStyleData: ButtonStyleData(
    padding: const EdgeInsets.only(top: 10, left: 16),
    height: 50,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
      borderRadius: const BorderRadius.all(Radius.circular(32)),
    ),
  ),
  dropdownStyleData: DropdownStyleData(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
    offset: const Offset(0, 1),
  ),
  isExpanded: true,
  style: textStyle(
    theme.isDarkMode ? colors.colorWhite : const Color(0XFF000000),
    13,
    FontWeight.w500,
  ),
  hint: Text(
    mfOrder.accNum,
    style: textStyle(
      theme.isDarkMode ? colors.colorWhite : const Color(0XFF000000),
      13,
      FontWeight.w500,
    ),
  ),
  items: mfOrder.addBankDividers(),
  value: mfOrder.accNum,
  onChanged: (value) async {
    mfOrder.chngBankAcc("$value");
  },
  
),
),

                        
              const SizedBox(height: 8),
              if (mfOrder.paymentName == "UPI") ...[
                const SizedBox(height: 12),
                Text("UPI ID (Virtual payment address)",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        15,
                        FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 44,
                    child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: 'exmaple@upi',
                        hintStyle: textStyle(
                            const Color(0xff666666), 14, FontWeight.w400),
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
                        textCtrl: mfOrder.upiId,
                        onChanged: (value) {
                          mfOrder.isValidUpiId(widget.mfData);
                        })),
                if (mfOrder.upiError != null) ...[
                  Text("${mfOrder.upiError}",
                      style: textStyle(
                          colors.kColorRedText, 10, FontWeight.w500)),
                  const SizedBox(height: 6)
                ]
              ]
            ],
            const SizedBox(height: 11),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
              Expanded(
                  child: Text(
                      " NAV will be allotted on the day funds are realised at the clearing corporation.",
                      style:
                          textStyle(colors.colorBlue, 13, FontWeight.w500)))
            ]),
            const SizedBox(
              height: 100,
            ),
          ]),
        ),
        bottomSheet: Container(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //     height: 36,
                //     decoration: BoxDecoration(
                //         color: theme.isDarkMode
                //             ? colors.darkGrey
                //             : const Color(0xfffafbff),
                //         border: Border(
                //             top: BorderSide(
                //                 color: theme.isDarkMode
                //                     ? colors.darkColorDivider
                //                     : colors.colorDivider),
                //             bottom: BorderSide(
                //                 color: theme.isDarkMode
                //                     ? colors.darkColorDivider
                //                     : colors.colorDivider))),
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     child:
                //      Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Row(children: [
                //             Text("AUM'': ",
                //                 style: textStyle(const Color.fromARGB(255, 0, 0, 0), 13,
                //                     FontWeight.w500)),
                //             Text(
                //                 "₹${(double.parse(widget.mfData.aUM!.isEmpty ? "0.00" : widget.mfData.aUM!) / 10000000).toStringAsFixed(2)}",
                //                 style: textStyle(
                //                     !theme.isDarkMode
                //                         ? colors.colorBlue
                //                         : colors.colorLightBlue,
                //                     12,
                //                     FontWeight.w600)),
                //             Text(" Cr.",
                //                 style: textStyle(const Color.fromARGB(255, 0, 0, 0), 13,
                //                     FontWeight.w500))
                //           ]),
                //           Row(children: [
                //             Text("NAV: ",
                //                 style: textStyle(const Color.fromARGB(255, 0, 0, 0), 13,
                //                     FontWeight.w500)),
                //             Text("₹${widget.mfData.nETASSETVALUE}",
                //                 style: textStyle(
                //                     !theme.isDarkMode
                //                         ? colors.colorBlue
                //                         : colors.colorLightBlue,
                //                     12,
                //                     FontWeight.w600))
                //           ]),
                //         ])),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (mfOrder.loading == false) {
                          print(mfOrder.invAmtError);
                          print(mfOrder.upiError);

                          print(mfOrder.installmentAmtError);
                          print(mfOrder.invDurationError);

                          if (mfOrder.invAmtError == "" &&
                              mfOrder.upiError == "" &&
                              mfOrder.installmentAmtError == "" &&
                              mfOrder.invDurationError == "") {
                            if (mfOrder.mfOrderTpye == "One-time") {
                              print(mfOrder.isValidUpiId(widget.mfData));
                              print(widget.mfData);
                              if (mfOrder.isValidUpiId(widget.mfData) ==
                                  true) {
                                mfPlaceorder(widget.mfData, mfOrder, context);
                              } else if (mfOrder.paymentName != "UPI") {
                                mfPlaceorder(widget.mfData, mfOrder, context);
                              }
                            } else {
                              if (mfOrder.mandateStatus != "APPROVED") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    successMessage(context,
                                        "Mandate is not Approved yet"));
                              } else {
                                mfOrder.fetchXsipPlaceOrder(
                                    context,
                                    "${double.parse(mfOrder.installmentAmt.text).toInt() >= 200000 ? "${widget.mfData.schemeCode}-L1" : widget.mfData.schemeCode}",
                                    mfOrder.freqName == "Daily"
                                        ? "0"
                                        : mfOrder.dates,
                                    mfOrder.freqName,
                                    mfOrder.installmentAmt.text,
                                    mfOrder.invDuration.text,
                                    mfOrder.freqName == "Daily"
                                        ? "0"
                                        : mfOrder.endDate,
                                    mfOrder.mandateId);
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                successMessage(context,
                                    "Please check if you have entered all Data Correctly"));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: mfOrder.invAmtError == null &&
                                  mfOrder.upiError == null
                              ? (theme.isDarkMode
                                  ? colors.colorbluegrey
                                  : colors.colorBlack)
                              : (theme.isDarkMode
                                  ? colors.colorbluegrey
                                  : colors.colorBlack),
                          shape: const StadiumBorder()),
                      child: mfOrder.loading == true 
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
                          : Text(
                              mfOrder.mfOrderTpye == "SIP"
                                  ? "SIP"
                                  : mfOrder.mfOrderTpye,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorBlack
                                      : const Color(0xffffffff),
                                  14,
                                  FontWeight.w600))),
                ),
                if (defaultTargetPlatform == TargetPlatform.iOS)
                  const SizedBox(height: 18)
              ],
            )));
  }
}

mfPlaceorder(
  MutualFundList mfData,
  MFProvider mfOrder,
  BuildContext context,
) {
  MfPlaceOrderInput input = MfPlaceOrderInput(
    transcode: "NEW", //NEW/CXL
    schemecode:
        "${double.parse(mfOrder.installmentAmt.text).toInt() >= 200000 ? "${mfData.schemeCode}-L1" : mfData.schemeCode}",
    buysell: "P",
    buyselltype: "FRESH",
    dptxn: "C",
    amount: double.parse(mfOrder.mfOrderTpye == "One-time"
            ? mfOrder.invAmt.text
            : mfOrder.installmentAmt.text)
        .toInt()
        .toString(),
    allredeem: "N",
    kycstatus: "Y",
    qty: "0",
    euinflag: "Y",
    minredeem: "N",
    dpc: "Y",
  );
  if (mfOrder.paymentName == "UPI") {
    mfOrder.fetchVerifyUpi(context, mfOrder.upiId.text, input);
  } else {
    print("netttttelse");
    mfOrder.fetchVerifyUpi(context, "", input);
  }

  print("object $input");
}

// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';

// import 'package:google_fonts/google_fonts.dart';
// import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
// import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
// import '../../provider/fund_provider.dart';
// import '../../provider/mf_provider.dart';
// import '../../provider/thems.dart';
// import '../../res/res.dart';
// import '../../sharedWidget/cust_text_formfield.dart';
// import '../../sharedWidget/custom_switch_btn.dart';
// import '../../sharedWidget/functions.dart';
// import '../../sharedWidget/list_divider.dart';

// class MFOrderScreen extends StatefulWidget {
//   final MutualFundList mfData;
//   const MFOrderScreen({super.key, required this.mfData});

//   @override
//   State<MFOrderScreen> createState() => _MFOrderScreenState();
// }

// class _MFOrderScreenState extends State<MFOrderScreen> {
//   bool islumpSum = true;

//   bool isInitalPay = false;
//   double invAmt = 0.00;
//   @override
//   void initState() {
//     setState(() {
//       context.read(fundProvider).invAmt.text =
//           "${widget.mfData.minimumPurchaseAmount}";

//       invAmt = double.parse("${widget.mfData.minimumPurchaseAmount ?? 0.00}");
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(builder: (context, ScopedReader watch, _) {
//       final theme = watch(themeProvider);
//       final fund = watch(fundProvider);
//       final mfOrder = watch(mfProvider);
//       return AlertDialog(
//           backgroundColor: theme.isDarkMode
//               ? const Color.fromARGB(255, 18, 18, 18)
//               : colors.colorWhite,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(16))),
//           actionsPadding:
//               const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 4),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//           insetPadding: const EdgeInsets.symmetric(horizontal: 16),
//           titlePadding: const EdgeInsets.only(left: 16, top: 16),
//           title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text("${widget.mfData.fSchemeName}",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         14,
//                         FontWeight.w500)),
//                 const SizedBox(height: 4),
//                 SizedBox(
//                     height: 18,
//                     child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(children: [
//                           CustomExchBadge(
//                               exch: widget.mfData.schemeName!.contains("GROWTH")
//                                   ? "GROWTH"
//                                   : widget.mfData.schemeName!
//                                           .contains("IDCW PAYOUT")
//                                       ? "IDCW PAYOUT"
//                                       : widget.mfData.schemeName!
//                                               .contains("IDCW REINVESTMENT")
//                                           ? "IDCW REINVESTMENT"
//                                           : widget.mfData.schemeName!
//                                                   .contains("IDCW")
//                                               ? "IDCW"
//                                               : "NORMAL"),
//                           CustomExchBadge(exch: "${widget.mfData.schemeType}"),
//                           CustomExchBadge(
//                               exch: widget.mfData.sCHEMESUBCATEGORY!
//                                   .replaceAll("Fund", '')
//                                   .replaceAll("Hybrid", "")
//                                   .toUpperCase())
//                         ])))
//               ]),
//           content: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: ListView(shrinkWrap: true, children: [
//                 const ListDivider(),
//                 const SizedBox(height: 10),
//                 Text("Choose tenure",
//                     style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         14,
//                         FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 Row(children: [
//                   Text("Lumpsum",
//                       style: textStyle(
//                           Color(islumpSum ? 0xff3E4763 : 0xff666666),
//                           14,
//                           FontWeight.w500)),
//                   const SizedBox(width: 8),
//                   CustomSwitch(
//                       onChanged: (bool value) {
//                         setState(() {
//                           if (widget.mfData.sIPFLAG == "Y") {
//                             islumpSum = value;
//                           } else {
//                             islumpSum = true;
//                           }
//                         });
//                       },
//                       value: islumpSum),
//                   const SizedBox(width: 8),
//                   if (widget.mfData.sIPFLAG == "Y")
//                     Text("Monthly SIP",
//                         style: textStyle(
//                             Color(!islumpSum ? 0xff3E4763 : 0xff666666),
//                             14,
//                             FontWeight.w500)),
//                 ]),
//                 if (!islumpSum) ...[
//                   const SizedBox(height: 8),
//                   Text("Mandates",
//                       style: textStyle(
//                           theme.isDarkMode
//                               ? colors.colorWhite
//                               : colors.colorBlack,
//                           14,
//                           FontWeight.w500)),
//                   const SizedBox(height: 4),
//                   ElevatedButton(
//                       onPressed: () async {
//                         if (fund.invAmtError == null &&
//                             fund.upiError == null) {}
//                       },
//                       style: ElevatedButton.styleFrom(
//                           elevation: 0,
//                           backgroundColor:
//                               fund.invAmtError == null && fund.upiError == null
//                                   ? colors.colorBlack
//                                   : const Color(0xffF1F3F8),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50))),
//                       child: Text("Create mandate",
//                           style: GoogleFonts.inter(
//                               textStyle: textStyle(
//                                   !theme.isDarkMode
//                                       ? colors.colorWhite
//                                       : colors.colorBlack,
//                                   14,
//                                   FontWeight.w500)))),
//                   Row(
//                     children: [
//                       IconButton(
//                           splashRadius: 20,
//                           onPressed: () {
//                             setState(() {
//                               isInitalPay = !isInitalPay;
//                             });
//                           },
//                           icon: SvgPicture.asset(theme.isDarkMode
//                               ? isInitalPay
//                                   ? assets.darkCheckedboxIcon
//                                   : assets.darkCheckboxIcon
//                               : isInitalPay
//                                   ? assets.checkedbox
//                                   : assets.checkbox)),
//                       Text("Pay initial investment now",
//                           style:
//                               textStyle(colors.colorGrey, 12, FontWeight.w500)),
//                     ],
//                   ),
//                   if (isInitalPay)
//                     SizedBox(
//                         height: 44,
//                         child: CustomTextFormField(
//                             textAlign: TextAlign.start,
//                             fillColor: theme.isDarkMode
//                                 ? colors.darkGrey
//                                 : const Color(0xffF1F3F8),
//                             hintText: '${widget.mfData.minimumPurchaseAmount}',
//                             hintStyle: textStyle(
//                                 const Color(0xff666666), 15, FontWeight.w400),
//                             inputFormate: [
//                               FilteringTextInputFormatter.digitsOnly
//                             ],
//                             style: textStyle(
//                                 theme.isDarkMode
//                                     ? colors.colorWhite
//                                     : colors.colorBlack,
//                                 16,
//                                 FontWeight.w600),
//                             prefixIcon: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   if (fund.invAmt.text.isNotEmpty) {
//                                     if (double.parse(fund.invAmt.text) >
//                                         invAmt) {
//                                       fund.invAmt.text =
//                                           (double.parse(fund.invAmt.text) -
//                                                   invAmt)
//                                               .toString();
//                                     }
//                                   } else {
//                                     fund.invAmt.text = (invAmt).toString();
//                                   }
//                                 });
//                               },
//                               child: SvgPicture.asset(
//                                   theme.isDarkMode
//                                       ? assets.darkCMinus
//                                       : assets.minusIcon,
//                                   fit: BoxFit.scaleDown),
//                             ),
//                             suffixIcon: InkWell(
//                                 onTap: () {
//                                   if (fund.invAmt.text.isNotEmpty) {
//                                     fund.invAmt.text =
//                                         (double.parse(fund.invAmt.text) +
//                                                 invAmt)
//                                             .toString();
//                                   } else {
//                                     fund.invAmt.text = (invAmt).toString();
//                                   }
//                                 },
//                                 child: SvgPicture.asset(
//                                     theme.isDarkMode
//                                         ? assets.darkAdd
//                                         : assets.addIcon,
//                                     fit: BoxFit.scaleDown)),
//                             textCtrl: fund.invAmt,
//                             onChanged: (value) {
//                               fund.isValidUpiId();
//                             })),
//                 ],
//                 const SizedBox(height: 8),
//                 Text(islumpSum ? "Investment amount" : "Instalment amount",
//                     style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         14,
//                         FontWeight.w500)),
//                 Container(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     height: 44,
//                     child: CustomTextFormField(
//                         textAlign: TextAlign.start,
//                         fillColor: theme.isDarkMode
//                             ? colors.darkGrey
//                             : const Color(0xffF1F3F8),
//                         hintText: islumpSum
//                             ? '${widget.mfData.minimumPurchaseAmount}'
//                             : '${widget.mfData.faceValue}',
//                         hintStyle: textStyle(
//                             const Color(0xff666666), 15, FontWeight.w400),
//                         inputFormate: [FilteringTextInputFormatter.digitsOnly],
//                         style: textStyle(
//                             theme.isDarkMode
//                                 ? colors.colorWhite
//                                 : colors.colorBlack,
//                             16,
//                             FontWeight.w600),
//                         prefixIcon: InkWell(
//                           onTap: () {
//                             setState(() {
//                               if (islumpSum) {
//                                 if (fund.invAmt.text.isNotEmpty) {
//                                   if (double.parse(fund.invAmt.text) > invAmt) {
//                                     fund.invAmt.text =
//                                         (double.parse(fund.invAmt.text) -
//                                                 invAmt)
//                                             .toString();
//                                   }
//                                 } else {
//                                   fund.invAmt.text = (invAmt).toString();
//                                 }
//                               } else {
//                                 if (mfOrder.instalmentAmt.text.isNotEmpty) {
//                                   if (double.parse(mfOrder.instalmentAmt.text) >
//                                       double.parse(mfOrder.insAmt)) {
//                                     mfOrder.instalmentAmt.text = (double.parse(
//                                                 mfOrder.instalmentAmt.text) -
//                                             double.parse(mfOrder.insAmt))
//                                         .toString();
//                                   }
//                                 } else {
//                                   mfOrder.instalmentAmt.text = mfOrder.insAmt;
//                                 }
//                               }
//                             });
//                           },
//                           child: SvgPicture.asset(
//                               theme.isDarkMode
//                                   ? assets.darkCMinus
//                                   : assets.minusIcon,
//                               fit: BoxFit.scaleDown),
//                         ),
//                         suffixIcon: InkWell(
//                             onTap: () {
//                               if (islumpSum) {
//                                 if (fund.invAmt.text.isNotEmpty) {
//                                   fund.invAmt.text =
//                                       (double.parse(fund.invAmt.text) + invAmt)
//                                           .toString();
//                                 } else {
//                                   fund.invAmt.text = (invAmt).toString();
//                                 }
//                               } else {
//                                 if (mfOrder.instalmentAmt.text.isNotEmpty) {
//                                   mfOrder.instalmentAmt.text = (double.parse(
//                                               mfOrder.instalmentAmt.text) +
//                                           double.parse(mfOrder.insAmt))
//                                       .toString();
//                                 } else {
//                                   mfOrder.instalmentAmt.text = mfOrder.insAmt;
//                                 }
//                               }
//                             },
//                             child: SvgPicture.asset(
//                                 theme.isDarkMode
//                                     ? assets.darkAdd
//                                     : assets.addIcon,
//                                 fit: BoxFit.scaleDown)),
//                         textCtrl:
//                             islumpSum ? fund.invAmt : mfOrder.instalmentAmt,
//                         onChanged: (value) {
//                           fund.isValidUpiId();
//                         })),
//                 if (fund.invAmtError != null) ...[
//                   Text("${fund.invAmtError}",
//                       style:
//                           textStyle(colors.kColorRedText, 10, FontWeight.w500)),
//                   const SizedBox(height: 6)
//                 ],
//                 Text(
//                     "Min. ₹${widget.mfData.minimumPurchaseAmount} (multiple of ${widget.mfData.purchaseAmountMultiplier})",
//                     style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
//                 if (!islumpSum) ...[
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Frequency",
//                                 style: textStyle(
//                                     theme.isDarkMode
//                                         ? colors.colorWhite
//                                         : colors.colorBlack,
//                                     14,
//                                     FontWeight.w500)),
//                             const SizedBox(height: 8),
//                             DropdownButtonHideUnderline(
//                                 child: DropdownButton2(
//                                     menuItemStyleData: MenuItemStyleData(
//                                         customHeights: mfOrder.frqCustHeight()),
//                                     buttonStyleData: const ButtonStyleData(
//                                         height: 36,
//                                         decoration: BoxDecoration(
//                                             color: Color(0xffF1F3F8),
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(32)))),
//                                     dropdownStyleData: DropdownStyleData(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 6),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       offset: const Offset(0, 8),
//                                     ),
//                                     isExpanded: true,
//                                     style: textStyle(const Color(0XFF000000),
//                                         13, FontWeight.w500),
//                                     hint: Text(mfOrder.freqName,
//                                         style: textStyle(
//                                             const Color(0XFF000000),
//                                             13,
//                                             FontWeight.w500)),
//                                     items: mfOrder.addFrqDividers(),
//                                     value: mfOrder.freqName,
//                                     onChanged: (value) async {
//                                       mfOrder.chngFrequency("$value");
//                                     })),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 20),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Date",
//                                 style: textStyle(
//                                     theme.isDarkMode
//                                         ? colors.colorWhite
//                                         : colors.colorBlack,
//                                     14,
//                                     FontWeight.w500)),
//                             const SizedBox(height: 8),
//                             DropdownButtonHideUnderline(
//                                 child: DropdownButton2(
//                                     menuItemStyleData: MenuItemStyleData(
//                                         customHeights:
//                                             mfOrder.dateCustHeight()),
//                                     buttonStyleData: const ButtonStyleData(
//                                         height: 36,
//                                         decoration: BoxDecoration(
//                                             color: Color(0xffF1F3F8),
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(32)))),
//                                     dropdownStyleData: DropdownStyleData(
//                                       maxHeight: 250,
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 6),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       offset: const Offset(0, 8),
//                                     ),
//                                     isExpanded: true,
//                                     style: textStyle(const Color(0XFF000000),
//                                         13, FontWeight.w500),
//                                     hint: Text("",
//                                         style: textStyle(
//                                             const Color(0XFF000000),
//                                             13,
//                                             FontWeight.w500)),
//                                     items: mfOrder.addDateDividers(),
//                                     value: mfOrder.dates,
//                                     onChanged: mfOrder.dates == "DAILY"
//                                         ? null
//                                         : (value) async {})),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("Investment duration",
//                           style: textStyle(
//                               theme.isDarkMode
//                                   ? colors.colorWhite
//                                   : colors.colorBlack,
//                               14,
//                               FontWeight.w500)),
//                       Text(
//                           "${mfOrder.invDuration.text} ${mfOrder.freqName == "DAILY" ? "Days" : mfOrder.freqName == "MONTHLY" ? "Months" : "Qtrs"}",
//                           style: textStyle(
//                               colors.kColorRedText, 14, FontWeight.w500)),
//                     ],
//                   ),
//                   Container(
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       height: 44,
//                       child: CustomTextFormField(
//                           textAlign: TextAlign.start,
//                           fillColor: theme.isDarkMode
//                               ? colors.darkGrey
//                               : const Color(0xffF1F3F8),
//                           hintText: '0',
//                           hintStyle: textStyle(
//                               const Color(0xff666666), 15, FontWeight.w400),
//                           inputFormate: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           style: textStyle(
//                               theme.isDarkMode
//                                   ? colors.colorWhite
//                                   : colors.colorBlack,
//                               16,
//                               FontWeight.w600),
//                           textCtrl: mfOrder.invDuration,
//                           onChanged: (value) {
//                             fund.isValidUpiId();
//                           })),
//                 ],
//                 const SizedBox(height: 8),
//                 Text("Payment method",
//                     style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         14,
//                         FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 DropdownButtonHideUnderline(
//                     child: DropdownButton2(
//                         menuItemStyleData: MenuItemStyleData(
//                             customHeights: fund.getCustItemsHeight()),
//                         buttonStyleData: ButtonStyleData(
//                             height: 36,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffF1F3F8),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(32)))),
//                         dropdownStyleData: DropdownStyleData(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           offset: const Offset(0, 8),
//                         ),
//                         isExpanded: true,
//                         style: textStyle(
//                             const Color(0XFF000000), 13, FontWeight.w500),
//                         hint: Text(fund.paymentName,
//                             style: textStyle(
//                                 const Color(0XFF000000), 13, FontWeight.w500)),
//                         items: fund.addDividers(),
//                         value: fund.paymentName,
//                         onChanged: (value) async {
//                           fund.chngPayName("$value");
//                         })),
//                 const SizedBox(height: 8),
//                 Text("Bank account",
//                     style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         14,
//                         FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 DropdownButtonHideUnderline(
//                     child: DropdownButton2(
//                         menuItemStyleData: MenuItemStyleData(
//                             customHeights: fund.getBankCustItemsHeight()),
//                         buttonStyleData: ButtonStyleData(
//                             padding: const EdgeInsets.only(top: 4, left: 16),
//                             height: 50,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: const BoxDecoration(
//                                 color: Color(0xffF1F3F8),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(32)))),
//                         dropdownStyleData: DropdownStyleData(
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(4)),
//                             offset: const Offset(0, 1)),
//                         isExpanded: true,
//                         style: textStyle(
//                             const Color(0XFF000000), 13, FontWeight.w500),
//                         hint: Text(fund.accNum,
//                             style: textStyle(
//                                 const Color(0XFF000000), 13, FontWeight.w500)),
//                         items: fund.addBankDividers(),
//                         // customItemsHeights: actionTrade.getCustomItemsHeight(),
//                         value: fund.accNum,
//                         onChanged: (value) async {
//                           fund.chngBankAcc("$value");
//                         })),
//                 const SizedBox(height: 8),
//                 if (fund.paymentName == "UPI") ...[
//                   Text("UPI ID (Virtual payment address)",
//                       style: textStyle(
//                           theme.isDarkMode
//                               ? colors.colorWhite
//                               : colors.colorBlack,
//                           14,
//                           FontWeight.w500)),
//                   Container(
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       height: 44,
//                       child: CustomTextFormField(
//                           textAlign: TextAlign.start,
//                           fillColor: theme.isDarkMode
//                               ? colors.darkGrey
//                               : const Color(0xffF1F3F8),
//                           hintText: 'exmaple@upi',
//                           hintStyle: textStyle(
//                               const Color(0xff666666), 14, FontWeight.w400),
//                           style: textStyle(
//                               theme.isDarkMode
//                                   ? colors.colorWhite
//                                   : colors.colorBlack,
//                               14,
//                               FontWeight.w600),
//                           textCtrl: fund.upiId,
//                           onChanged: (value) {
//                             fund.isValidUpiId();
//                           })),
//                   if (fund.upiError != null) ...[
//                     Text("${fund.upiError}",
//                         style: textStyle(
//                             colors.kColorRedText, 10, FontWeight.w500)),
//                     const SizedBox(height: 6)
//                   ]
//                 ],
//                 const SizedBox(height: 8),
//                 Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
//                   Expanded(
//                       child: Text(
//                           " NAV will be allotted on the day funds are realised at the clearing corporation.",
//                           style:
//                               textStyle(colors.colorBlue, 12, FontWeight.w500)))
//                 ])
//               ])),
//           actions: [
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(
//                   children: [
//                     Text("AUM ",
//                         style:
//                             textStyle(colors.colorGrey, 12, FontWeight.w500)),
//                     Text(
//                         (double.parse(widget.mfData.aUM!.isEmpty
//                                     ? "0.00"
//                                     : widget.mfData.aUM!) /
//                                 10000000)
//                             .toStringAsFixed(2),
//                         style:
//                             textStyle(colors.colorBlue, 12, FontWeight.w500)),
//                     Text(" Cr.",
//                         style:
//                             textStyle(colors.colorGrey, 12, FontWeight.w500)),
//                   ],
//                 ),
//                 const SizedBox(height: 3),
//                 Row(children: [
//                   Text("NAV ",
//                       style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
//                   Text("₹${widget.mfData.nETASSETVALUE}",
//                       style: textStyle(colors.colorBlue, 12, FontWeight.w500))
//                 ])
//               ]),
//               Row(children: [
//                 ElevatedButton(
//                     onPressed: () async {
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor: const Color(0xffF1F3F8),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(50))),
//                     child: Text("Cancel",
//                         style: GoogleFonts.inter(
//                             textStyle: textStyle(
//                                 colors.colorBlack, 14, FontWeight.w500)))),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                     onPressed: () async {
//                       if (fund.invAmtError == null && fund.upiError == null) {
//                         Navigator.pop(context);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor:
//                             fund.invAmtError == null && fund.upiError == null
//                                 ? colors.colorBlack
//                                 : const Color(0xffF1F3F8),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(50))),
//                     child: Text("Invest",
//                         style: GoogleFonts.inter(
//                             textStyle: textStyle(
//                                 !theme.isDarkMode
//                                     ? colors.colorWhite
//                                     : colors.colorBlack,
//                                 14,
//                                 FontWeight.w500))))
//               ])
//             ])
//           ]);
//     });
//   }
// }

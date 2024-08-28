import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/functions.dart';
import 'create_mandate_daialogue.dart';

class MFOrderScreen extends StatefulWidget {
  final MutualFundList mfData;
  const MFOrderScreen({super.key, required this.mfData});

  @override
  State<MFOrderScreen> createState() => _MFOrderScreenState();
}

class _MFOrderScreenState extends State<MFOrderScreen> {
  bool isInitalPay = false;
  double invAmt = 0.00;
  @override
  void initState() {
    setState(() {
      context.read(fundProvider).invAmt.text =
          "${widget.mfData.minimumPurchaseAmount}";
      invAmt = double.parse("${widget.mfData.minimumPurchaseAmount ?? 0.00}");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final fund = watch(fundProvider);
      final mfOrder = watch(mfProvider);
      return Scaffold(
          appBar: AppBar(
              leadingWidth: 41,
              centerTitle: false,
              titleSpacing: 0,
              elevation: .4,
              leading: const CustomBackBtn(),
              title: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://v3.mynt.in/mf/static/images/mf/${widget.mfData.aMCCode}.png")),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("${widget.mfData.fSchemeName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w500)),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 18,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: [
                                CustomExchBadge(
                                    exch: widget.mfData.schemeName!
                                            .contains("GROWTH")
                                        ? "GROWTH"
                                        : widget.mfData.schemeName!
                                                .contains("IDCW PAYOUT")
                                            ? "IDCW PAYOUT"
                                            : widget.mfData.schemeName!
                                                    .contains(
                                                        "IDCW REINVESTMENT")
                                                ? "IDCW REINVESTMENT"
                                                : widget.mfData.schemeName!
                                                        .contains("IDCW")
                                                    ? "IDCW"
                                                    : "NORMAL"),
                                CustomExchBadge(
                                    exch: "${widget.mfData.schemeType}"),
                                CustomExchBadge(
                                    exch: widget.mfData.sCHEMESUBCATEGORY!
                                        .replaceAll("Fund", '')
                                        .replaceAll("Hybrid", "")
                                        .toUpperCase()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Column(children: [
                    Container(
                        height: 46,
                        decoration: BoxDecoration(
                            border: (Border(
                                top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider)))),
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
          body: ListView(padding: const EdgeInsets.all(16), children: [
            if (mfOrder.mfOrderTpye != "Lumpsum") ...[
              Text("Mandates",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500)),
              const SizedBox(height: 4),
              if (mfOrder.mandateData!.isNotEmpty) ...[
                DropdownButtonHideUnderline(
                    child: DropdownButton2(
                        menuItemStyleData: MenuItemStyleData(
                            customHeights: mfOrder.mandateHeight()),
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
                        hint: Text(mfOrder.mandateId,
                            style: textStyle(
                                const Color(0XFF000000), 13, FontWeight.w500)),
                        items: mfOrder.mandateDividers(),
                        // customItemsHeights: actionTrade.getCustomItemsHeight(),
                        value: mfOrder.mandateId,
                        onChanged: (value) async {
                          mfOrder.chngMandate("$value");
                        })),
                 const SizedBox(height: 8),   ],
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
                      backgroundColor:
                          fund.invAmtError == null && fund.upiError == null
                              ? colors.colorBlack
                              : const Color(0xffF1F3F8),
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
              Row(
                children: [
                  IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        setState(() {
                          isInitalPay = !isInitalPay;
                        });
                      },
                      icon: SvgPicture.asset(theme.isDarkMode
                          ? isInitalPay
                              ? assets.darkCheckedboxIcon
                              : assets.darkCheckboxIcon
                          : isInitalPay
                              ? assets.checkedbox
                              : assets.checkbox)),
                  Text("Pay initial investment now",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
                ],
              ),
              if (isInitalPay)
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
                        inputFormate: [FilteringTextInputFormatter.digitsOnly],
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600),
                        prefixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              if (fund.invAmt.text.isNotEmpty) {
                                if (double.parse(fund.invAmt.text) > invAmt) {
                                  fund.invAmt.text =
                                      (double.parse(fund.invAmt.text) - invAmt)
                                          .toString();
                                }
                              } else {
                                fund.invAmt.text = (invAmt).toString();
                              }
                            });
                          },
                          child: SvgPicture.asset(
                              theme.isDarkMode
                                  ? assets.darkCMinus
                                  : assets.minusIcon,
                              fit: BoxFit.scaleDown),
                        ),
                        suffixIcon: InkWell(
                            onTap: () {
                              if (fund.invAmt.text.isNotEmpty) {
                                fund.invAmt.text =
                                    (double.parse(fund.invAmt.text) + invAmt)
                                        .toString();
                              } else {
                                fund.invAmt.text = (invAmt).toString();
                              }
                            },
                            child: SvgPicture.asset(
                                theme.isDarkMode
                                    ? assets.darkAdd
                                    : assets.addIcon,
                                fit: BoxFit.scaleDown)),
                        textCtrl: fund.invAmt,
                        onChanged: (value) {
                          fund.isValidUpiId();
                        })),
              const SizedBox(height: 8)
            ],
            Text(
                mfOrder.mfOrderTpye == "Lumpsum"
                    ? "Investment amount"
                    : "Instalment amount",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 44,
                child: CustomTextFormField(
                    textAlign: TextAlign.start,
                    fillColor: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    hintText: mfOrder.mfOrderTpye == "Lumpsum"
                        ? '${widget.mfData.minimumPurchaseAmount}'
                        : '${widget.mfData.faceValue}',
                    hintStyle:
                        textStyle(const Color(0xff666666), 15, FontWeight.w400),
                    inputFormate: [FilteringTextInputFormatter.digitsOnly],
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        16,
                        FontWeight.w600),
                    prefixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          if (mfOrder.mfOrderTpye == "Lumpsum") {
                            if (fund.invAmt.text.isNotEmpty) {
                              if (double.parse(fund.invAmt.text) > invAmt) {
                                fund.invAmt.text =
                                    (double.parse(fund.invAmt.text) - invAmt)
                                        .toString();
                              }
                            } else {
                              fund.invAmt.text = (invAmt).toString();
                            }
                          } else {
                            if (mfOrder.instalmentAmt.text.isNotEmpty) {
                              if (double.parse(mfOrder.instalmentAmt.text) >
                                  double.parse(mfOrder.insAmt)) {
                                mfOrder.instalmentAmt.text =
                                    (double.parse(mfOrder.instalmentAmt.text) -
                                            double.parse(mfOrder.insAmt))
                                        .toString();
                              }
                            } else {
                              mfOrder.instalmentAmt.text = mfOrder.insAmt;
                            }
                          }
                        });
                      },
                      child: SvgPicture.asset(
                          theme.isDarkMode
                              ? assets.darkCMinus
                              : assets.minusIcon,
                          fit: BoxFit.scaleDown),
                    ),
                    suffixIcon: InkWell(
                        onTap: () {
                          if (mfOrder.mfOrderTpye == "Lumpsum") {
                            if (fund.invAmt.text.isNotEmpty) {
                              fund.invAmt.text =
                                  (double.parse(fund.invAmt.text) + invAmt)
                                      .toString();
                            } else {
                              fund.invAmt.text = (invAmt).toString();
                            }
                          } else {
                            if (mfOrder.instalmentAmt.text.isNotEmpty) {
                              mfOrder.instalmentAmt.text =
                                  (double.parse(mfOrder.instalmentAmt.text) +
                                          double.parse(mfOrder.insAmt))
                                      .toString();
                            } else {
                              mfOrder.instalmentAmt.text = mfOrder.insAmt;
                            }
                          }
                        },
                        child: SvgPicture.asset(
                            theme.isDarkMode ? assets.darkAdd : assets.addIcon,
                            fit: BoxFit.scaleDown)),
                    textCtrl: mfOrder.mfOrderTpye == "Lumpsum"
                        ? fund.invAmt
                        : mfOrder.instalmentAmt,
                    onChanged: (value) {
                      fund.isValidUpiId();
                    })),
            if (fund.invAmtError != null) ...[
              Text("${fund.invAmtError}",
                  style: textStyle(colors.kColorRedText, 10, FontWeight.w500)),
              const SizedBox(height: 6)
            ],
            Text(
                "Min. ₹${widget.mfData.minimumPurchaseAmount} (multiple of ${widget.mfData.purchaseAmountMultiplier})",
                style: textStyle(colors.colorGrey, 12, FontWeight.w500)),
            if (mfOrder.mfOrderTpye != "Lumpsum") ...[
              const SizedBox(height: 8),
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
                                14,
                                FontWeight.w500)),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2(
                                menuItemStyleData: MenuItemStyleData(
                                    customHeights: mfOrder.frqCustHeight()),
                                buttonStyleData: const ButtonStyleData(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: Color(0xffF1F3F8),
                                        borderRadius: BorderRadius.all(
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
                                style: textStyle(const Color(0XFF000000), 13,
                                    FontWeight.w500),
                                hint: Text(mfOrder.freqName,
                                    style: textStyle(const Color(0XFF000000),
                                        13, FontWeight.w500)),
                                items: mfOrder.addFrqDividers(),
                                value: mfOrder.freqName,
                                onChanged: (value) async {
                                  mfOrder.chngFrequency("$value");
                                })),
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
                                14,
                                FontWeight.w500)),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2(
                                menuItemStyleData: MenuItemStyleData(
                                    customHeights: mfOrder.dateCustHeight()),
                                buttonStyleData: const ButtonStyleData(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: Color(0xffF1F3F8),
                                        borderRadius: BorderRadius.all(
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
                                    : (value) async {})),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Investment duration",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w500)),
                  Text(
                      "${mfOrder.invDuration.text} ${mfOrder.freqName == "DAILY" ? "Days" : mfOrder.freqName == "MONTHLY" ? "Months" : "Qtrs"}",
                      style:
                          textStyle(colors.kColorRedText, 14, FontWeight.w500)),
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
                        fund.isValidUpiId();
                      })),
            ],
            const SizedBox(height: 8),
            Text("Payment method",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
                child: DropdownButton2(
                    menuItemStyleData: MenuItemStyleData(
                        customHeights: fund.getCustItemsHeight()),
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
                    style:
                        textStyle(const Color(0XFF000000), 13, FontWeight.w500),
                    hint: Text(fund.paymentName,
                        style: textStyle(
                            const Color(0XFF000000), 13, FontWeight.w500)),
                    items: fund.addDividers(),
                    value: fund.paymentName,
                    onChanged: (value) async {
                      fund.chngPayName("$value");
                    })),
            const SizedBox(height: 8),
            Text("Bank account",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
                child: DropdownButton2(
                    menuItemStyleData: MenuItemStyleData(
                        customHeights: fund.getBankCustItemsHeight()),
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
                    style:
                        textStyle(const Color(0XFF000000), 13, FontWeight.w500),
                    hint: Text(fund.accNum,
                        style: textStyle(
                            const Color(0XFF000000), 13, FontWeight.w500)),
                    items: fund.addBankDividers(),
                    // customItemsHeights: actionTrade.getCustomItemsHeight(),
                    value: fund.accNum,
                    onChanged: (value) async {
                      fund.chngBankAcc("$value");
                    })),
            const SizedBox(height: 8),
            if (fund.paymentName == "UPI") ...[
              Text("UPI ID (Virtual payment address)",
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500)),
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
                      textCtrl: fund.upiId,
                      onChanged: (value) {
                        fund.isValidUpiId();
                      })),
              if (fund.upiError != null) ...[
                Text("${fund.upiError}",
                    style:
                        textStyle(colors.kColorRedText, 10, FontWeight.w500)),
                const SizedBox(height: 6)
              ]
            ],
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SvgPicture.asset(assets.dInfo, color: colors.colorBlue),
              Expanded(
                  child: Text(
                      " NAV will be allotted on the day funds are realised at the clearing corporation.",
                      style: textStyle(colors.colorBlue, 12, FontWeight.w500)))
            ])
          ]),
          bottomSheet: Container(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      height: 36,
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xfffafbff),
                          border: Border(
                              top: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider),
                              bottom: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.darkColorDivider
                                      : colors.colorDivider))),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Text("AUM: ",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              Text(
                                  "₹${(double.parse(widget.mfData.aUM!.isEmpty ? "0.00" : widget.mfData.aUM!) / 10000000).toStringAsFixed(2)}",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlue
                                          : colors.colorLightBlue,
                                      12,
                                      FontWeight.w600)),
                              Text(" Cr.",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500))
                            ]),
                            Row(children: [
                              Text("NAV: ",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                              Text("₹${widget.mfData.nETASSETVALUE}",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlue
                                          : colors.colorLightBlue,
                                      12,
                                      FontWeight.w600))
                            ]),
                          ])),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: fund.invAmtError == null && fund.upiError == null
                                ?  colors.ltpgreen:colors.ltpgreen.withOpacity(.7),
                            shape: const StadiumBorder()),
                        child: Text("Invest",
                            style: textStyle(
                                const Color(0xffffffff), 14, FontWeight.w600))),
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS)
                    const SizedBox(height: 18)
                ],
              )));
    });
  }
}

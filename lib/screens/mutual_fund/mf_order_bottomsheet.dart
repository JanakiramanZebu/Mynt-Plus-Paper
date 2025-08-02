import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/locator/constant.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/transcation_provider.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/fund_function.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/snack_bar.dart';
import '../mutual_fund_old/create_mandate_daialogue.dart';
import '../profile_screen/fund_screen/upi_id_screens/mf_payment_resp_alert.dart';
import '../profile_screen/fund_screen/upi_id_screens/upi_id_cancel_alert.dart';
import 'mandate_selection_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../res/assets.dart';
import 'mf_processing_screen.dart';

class MfOrderBottomsheet extends StatefulWidget {
  final dynamic data;
  const MfOrderBottomsheet({super.key, required this.data});

  @override
  State<MfOrderBottomsheet> createState() => _MfOrderBottomsheet();
}

class DropdownItem {
  final String value;
  final String label;
  final bool isEnabled;

  DropdownItem({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });
}

class _MfOrderBottomsheet extends State<MfOrderBottomsheet> {
  String _getSelectedMandateAmount(MFProvider mfOrder) {
    if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
      return "N/A";
    }
    final selectedMandate = mfOrder.mandateData!.firstWhere(
      (mandate) => mandate.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );
    return selectedMandate.amount ?? "N/A";
  }

  Widget _getSelectedMandateStatus(MFProvider mfOrder) {
    if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
      return SvgPicture.asset(assets.warningIcon, width: 15, height: 15);
    }
    final selectedMandate = mfOrder.mandateData!.firstWhere(
      (mandate) => mandate.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );
    final status = selectedMandate.status?.toUpperCase();

    if (status == 'APPROVED') {
      return SvgPicture.asset(
        assets.completedIcon,
        width: 15,
        height: 15,
      );
    } else if (status == 'REJECTED') {
      return SvgPicture.asset(assets.cancelledIcon, width: 15, height: 15);
    } else {
      return SvgPicture.asset(assets.warningIcon,
          width: 15, height: 15); // Fallback/other
    }
  }

  String _getSelectedMandateBankName(MFProvider mfOrder) {
    if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
      return "N/A";
    }
    final selectedMandate = mfOrder.mandateData!.firstWhere(
      (mandate) => mandate.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );
    return selectedMandate.bankName ?? "N/A";
  }

  String _getMandateErrorMessage(MFProvider mfOrder) {
    if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
      return "Please select a mandate to proceed with SIP setup.";
    }

    final selectedMandate = mfOrder.mandateData!.firstWhere(
      (mandate) => mandate.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );
    final status = selectedMandate.status?.toUpperCase();

    if (status == 'REJECTED') {
      return "Selected mandate is rejected. Please create a new mandate or select an approved mandate.";
    } else if (status == 'APPROVED') {
      return ""; // No error message for approved mandates
    } else {
      return "Selected mandate is not approved ($status)";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    double notional = 0.0;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final ledgerdata = ref.watch(ledgerProvider);
      final fund = ref.watch(transcationProvider);
      final mfOrder = ref.watch(mfProvider);

// Optional: remove duplicates if needed (based on value)

      return WillPopScope(
          onWillPop: () async {
            if (ledgerdata.listforpledge == []) {
              ledgerdata.changesegvaldummy('');
            }
            Navigator.pop(context);
            print(
                "objectobjectobjectobjectobjectobjectobjectobject ${screenheight * 0.00038}");
            return true;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 22.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Stack(
              children: [
                if (mfOrder.upiApiresponse != null &&
                    mfOrder.upiApiresponse?.stat == "Ok" &&
                    (mfOrder.paymentName == "UPI" ||
                        mfOrder.paymentName == "NET BANKING") &&
                    mfOrder.ispaymentcalled == true) ...[
                  SizedBox(
                    height: screenheight * 0.24,
                    child: MfUPIProcessingScreen(
                      data: mfOrder.mfPlaceOrderResponces!.orderId,
                    ),
                  ),
                ] else ...[
                  mfOrder.investloader
                      ? Positioned(
                          child: SizedBox(
                          height: screenheight * 0.5,
                          width: screenWidth,
                          child: Material(
                            color: Colors.white,
                            child: Theme(
                              data: Theme.of(context),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 650),
                                      transitionBuilder: (child, animation) =>
                                          ScaleTransition(
                                              scale: animation, child: child),
                                      child: mfOrder.loadingMessage ==
                                              "Order Initiated"
                                          ? const Icon(
                                              Icons.check_circle,
                                              key: ValueKey("verified"),
                                              size: 50,
                                              color: Colors.green,
                                            )
                                          : SizedBox(
                                              key: ValueKey("loading"),
                                              height: 25,
                                              width: 25,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  theme.isDarkMode
                                                      ? colors.primaryDark
                                                      : colors.primaryLight,
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextWidget.subText(
                                      text: mfOrder.loadingMessage ?? "",
                                      theme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (mfOrder.mfOrderTpye == "SIP") ...[
                              TextWidget.subText(
                                text: "Auto Pay (Mandate)",
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                              ),
                              const SizedBox(height: 16),
                              // Show mandate selection if mandates exist, otherwise show create mandate button
                              if (mfOrder.mandateData != null &&
                                  mfOrder.mandateData!.isNotEmpty) ...[
                                // Clickable mandate card
                                InkWell(
                                  onTap: () {
                                    // Navigate to mandate selection screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MandateSelectionScreen(
                                          currentMandateId: mfOrder.mandateId,
                                          onMandateSelected:
                                              (String mandateId) {
                                            mfOrder.chngMandate(mandateId);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: theme.isDarkMode
                                          ? colors.darkGrey
                                          : Color(0xffF1F3F8),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: theme.isDarkMode
                                            ? colors.primaryDark
                                            : colors.primaryLight,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                    text:
                                                        "${_getSelectedMandateAmount(mfOrder)}",
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 3,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  _getSelectedMandateStatus(
                                                      mfOrder),
                                                ],
                                              ),

                                              SizedBox(
                                                height: 4,
                                              ),

                                              TextWidget.subText(
                                                text:
                                                    "${_getSelectedMandateBankName(mfOrder)}",
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 3,
                                              ),
                                              // const SizedBox(height: 4),
                                              // TextWidget.paraText(
                                              //   text: mfOrder.mandateData?.first
                                              //           .bankName ??
                                              //       "Select a Mandate",
                                              //   theme: theme.isDarkMode,
                                              //   color: colors.colorGrey,
                                              // ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Error message below mandate selection
                                if (mfOrder.mandateStatus != "APPROVED" &&
                                    mfOrder.mandateId.isNotEmpty &&
                                    _getMandateErrorMessage(mfOrder).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextWidget.paraText(
                                            text: _getMandateErrorMessage(
                                                mfOrder),
                                            theme: theme.isDarkMode,
                                            color: colors.loss,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ] else ...[
                                // Create Mandate button when no mandates exist
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext context) {
                                          return const CreateMandateDialogue();
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: !theme.isDarkMode
                                          ? colors.primaryLight
                                          : colors.primaryDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: TextWidget.subText(
                                      text: "Create New Mandate",
                                      theme: !theme.isDarkMode,
                                      color: !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      fw: 0,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              // ElevatedButton(
                              //     onPressed: () async {
                              //       showDialog(
                              //           context: context,
                              //           builder: (BuildContext context) {
                              //             return const CreateMandateDialogue();
                              //           });
                              //     },
                              //     style: ElevatedButton.styleFrom(
                              //         elevation: 0,
                              //         backgroundColor: !theme.isDarkMode
                              //             ? colors.primaryLight
                              //             : colors.primaryDark,
                              //         shape: RoundedRectangleBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(5))),
                              //     child: Text("Create mandate",
                              //         style: textStyle(
                              //             !theme.isDarkMode
                              //                 ? colors.colorWhite
                              //                 : colors.colorBlack,
                              //             14,
                              //             FontWeight.w500))),
                            ],
                            if (mfOrder.mfOrderTpye != "SIP") ...[
                              const SizedBox(height: 14),

                              TextWidget.subText(
                                text: "Pay With",
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        const ListDivider(),
                                        InkWell(
                                          onTap: () async {
                                            await Future.delayed(const Duration(
                                                milliseconds: 150));
                                            showBottomSheetbank(fund, theme);
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            // minVerticalPadding: 16,
                                            title: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: TextWidget.subText(
                                                text: fund.bankname,
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: TextWidget.paraText(
                                                text: hideAccountNumber(
                                                    fund.accno),
                                                theme: theme.isDarkMode,
                                                color: colors.colorGrey,
                                              ),
                                            ),
                                            trailing: Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              clipBehavior: Clip.hardEdge,
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                splashColor: theme.isDarkMode
                                                    ? colors.splashColorDark
                                                    : colors.splashColorLight,
                                                highlightColor: theme.isDarkMode
                                                    ? colors.highlightDark
                                                    : colors.highlightLight,
                                                onTap: () async {
                                                  // Add delay for visual feedback
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 150));

                                                  await showBottomSheetbank(
                                                      fund, theme);
                                                },
                                                child: Container(
                                                  height: 32,
                                                  width: 32,
                                                  child: const Center(
                                                    child: Icon(Icons.more_vert,
                                                        size: 22,
                                                        color:
                                                            Color(0xFF888888)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const ListDivider(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              TextWidget.subText(
                                text: "Payment method",
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                              ),
                              const SizedBox(height: 16),
                              const ListDivider(),
                              ListView.separated(
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: mfOrder.paymentMethod.length,
                                separatorBuilder: (context, index) =>
                                    const ListDivider(),
                                itemBuilder: (context, index) {
                                  String paymentMethodName =
                                      mfOrder.paymentMethod[index];
                                  String paymentMethodImage =
                                      paymentMethodName == "UPI"
                                          ? 'assets/icon/paymentIcon/upi.svg'
                                          : 'assets/icon/netbanking_icon.svg';
                                  bool isSelected =
                                      mfOrder.paymentName == paymentMethodName;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 16),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            mfOrder
                                                .chngPayName(paymentMethodName);
                                          },
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                paymentMethodImage,
                                                width: 40,
                                                height: 40,
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    TextWidget.paraText(
                                                      text: paymentMethodName ==
                                                              "UPI"
                                                          ? "UPI ID"
                                                          : "Net Banking",
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                    ),
                                                    if (isSelected)
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: theme.isDarkMode
                                                            ? colors.primaryDark
                                                            : colors
                                                                .primaryLight,
                                                        size: 20,
                                                      )
                                                    else
                                                      const SizedBox()
                                                    // SvgPicture.asset(
                                                    //   assets.leftArrow,
                                                    //   width: 16,
                                                    //   height: 16,
                                                    //   color: colors.iconColor,
                                                    // )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (mfOrder.paymentName == "UPI" &&
                                            index == 0) ...[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: CustomTextFormField(
                                                  textAlign: TextAlign.start,
                                                  fillColor: colors.btnBg,
                                                  hintText: 'Enter UPI ID',
                                                  hintStyle: textStyle(
                                                    colors.textPrimaryLight,
                                                    14,
                                                    FontWeight.w400,
                                                  ),
                                                  style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w600,
                                                  ),
                                                  textCtrl: mfOrder.upiId,
                                                  onChanged: (value) {
                                                    mfOrder.isValidUpiId(
                                                        widget.data);
                                                  },
                                                ),
                                              ),
                                              // if (mfOrder.upiError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  "${mfOrder.upiError}",
                                                  style: textStyle(
                                                      colors.kColorRedText,
                                                      10,
                                                      FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              // Text(
                              //   "Bank account ",
                              //   style: textStyle(
                              //     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                              //     16,
                              //     FontWeight.w600,
                              //   ),
                              // ),
                              // const SizedBox(height: 12),
                              // DropdownButtonHideUnderline(
                              //   child: DropdownButton2(
                              //     menuItemStyleData: MenuItemStyleData(
                              //       customHeights: mfOrder.getBankCustItemsHeight(),
                              //     ),
                              //     buttonStyleData: ButtonStyleData(
                              //       padding: const EdgeInsets.only(top: 10, left: 16),
                              //       height: 50,
                              //       width: MediaQuery.of(context).size.width,
                              //       decoration: BoxDecoration(
                              //         color: theme.isDarkMode
                              //             ? colors.darkGrey
                              //             : const Color(0xffF1F3F8),
                              //         borderRadius: const BorderRadius.all(Radius.circular(32)),
                              //       ),
                              //     ),
                              //     dropdownStyleData: DropdownStyleData(
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(4),
                              //       ),
                              //       offset: const Offset(0, 1),
                              //     ),
                              //     isExpanded: true,
                              //     style: textStyle(
                              //       theme.isDarkMode
                              //           ? colors.colorWhite
                              //           : const Color(0XFF000000),
                              //       13,
                              //       FontWeight.w500,
                              //     ),
                              //     hint: Text(
                              //       mfOrder.accNum,
                              //       style: textStyle(
                              //         theme.isDarkMode
                              //             ? colors.colorWhite
                              //             : const Color(0XFF000000),
                              //         13,
                              //         FontWeight.w500,
                              //       ),
                              //     ),
                              //     items: mfOrder.addBankDividers(),
                              //     value: mfOrder.accNum,
                              //     onChanged: (value) async {
                              //       mfOrder.chngBankAcc("$value");
                              //     },
                              //   ),
                              // ),

                              // Conditional UPI section
                            ],
                            // Show Setup-SIP button only when mandates exist and are approved
                            if ((mfOrder.mfOrderTpye == "SIP" &&
                                    mfOrder.mandateData != null &&
                                    mfOrder.mandateData!.isNotEmpty) ||
                                (mfOrder.mfOrderTpye != "SIP")) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                width: MediaQuery.of(context).size.width,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    // mfOrder.chngPayName("UPI");
                                    if (mfOrder.mfOrderTpye != "SIP") {
                                      final isUpi =
                                          mfOrder.paymentName == 'UPI';
                                      final isNetBanking =
                                          mfOrder.paymentName == 'NET BANKING';
                                      final isUpiValid =
                                          isUpi ? mfOrder.upiError == '' : true;

                                      mfOrder.isValidUpiId(widget.data);

                                      if ((isUpiValid &&
                                              mfOrder.upiId.text.isNotEmpty) ||
                                          isNetBanking) {
                                        // Show loading
                                        mfOrder.setInvestLoader(true);
                                        mfOrder.setLoadingMessage(
                                            "Processing payment...");
                                        mfOrder.IsPaymentCalled(true);

                                        // Call UPI Payment trigger
                                        await mfOrder.upipaymenttrigger(
                                          context,
                                          mfOrder
                                              .mfPlaceOrderResponces!.orderId,
                                          mfOrder
                                              .mfPlaceOrderResponces!.orderVal,
                                          mfOrder.upiId.text,
                                          mfOrder.paymentName,
                                        );

                                        final upiResponse =
                                            mfOrder.upiApiresponse;

                                        if (upiResponse != null) {
                                          if (upiResponse.stat == "Ok") {
                                            // ✅ Success Case
                                            // if (isUpi) {
                                            //   // UPI Success – show processing bottom sheet
                                            //   showModalBottomSheet(
                                            //     context: context,
                                            //     isScrollControlled: true,
                                            //     isDismissible: false,
                                            //     enableDrag: false,
                                            //     shape:
                                            //         const RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.vertical(
                                            //               top: Radius.circular(
                                            //                   15)),
                                            //     ),
                                            //     builder: (context) =>
                                            //         WillPopScope(
                                            //       onWillPop: () async =>
                                            //           !mfOrder.ispaymentcalled,
                                            //       child: MfUPIProcessingScreen(
                                            //           data: ''),
                                            //     ),
                                            //   );
                                            // } else 
                                            if (isNetBanking) {
                                              // Net Banking Success – open WebView
                                              final url = Uri.parse(
                                                  'https://v3.mynt.in/mfapi${upiResponse.file!}');
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Scaffold(
                                                    appBar: AppBar(
                                                      title: const Text(
                                                          "Net Banking"),
                                                      leading: IconButton(
                                                        icon: const Icon(Icons
                                                            .arrow_back_ios_new),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          mfOrder
                                                              .threeSecondTimer
                                                              ?.cancel();
                                                          mfOrder.autoPopTimer
                                                              ?.cancel();
                                                        },
                                                      ),
                                                    ),
                                                    body: WillPopScope(
                                                      onWillPop: () async {
                                                        Navigator.pop(context);
                                                        mfOrder.threeSecondTimer
                                                            ?.cancel();
                                                        mfOrder.autoPopTimer
                                                            ?.cancel();
                                                        return true;
                                                      },
                                                      child: InAppWebView(
                                                        initialUrlRequest:
                                                            URLRequest(
                                                                url: WebUri(url
                                                                    .toString())),
                                                        initialOptions:
                                                            InAppWebViewGroupOptions(
                                                          crossPlatform:
                                                              InAppWebViewOptions(),
                                                        ),
                                                        onWebViewCreated:
                                                            (controller) {
                                                          ConstantName
                                                                  .webViewController =
                                                              controller;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            // ❌ Failure Case – show error bottom sheet
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: false,
                                              enableDrag: false,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            15)),
                                              ),
                                              builder: (context) =>
                                                  WillPopScope(
                                                onWillPop: () async =>
                                                    !mfOrder.ispaymentcalled,
                                                child: MfPaymentRespAlert(
                                                  upiData: upiResponse.data!
                                                      .toJson(),
                                                  conditionval:
                                                      'reinitiateerror',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    } else {
                                      if (mfOrder.mandateStatus == "APPROVED") {
                                        // Set loading state immediately when button is pressed
                                        // mfOrder.setLoadingMessage(
                                        //     "Processing SIP order...");
                                        await mfOrder.fetchXsipPlaceOrder(
                                            context,
                                            "${double.parse(mfOrder.installmentAmt.text).toInt() >= 200000 ? "${widget.data.schemeCode}-L1" : widget.data.schemeCode}",
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
                                        if (mfOrder.xsipOrderResponces?.stat ==
                                                "Ok" ||
                                            mfOrder.xsipOrderResponces?.stat ==
                                                "Not_Ok") {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            enableDrag: false,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(15),
                                              ),
                                            ),
                                            builder: (context) =>
                                                MfPaymentRespAlert(
                                                    upiData: mfOrder
                                                        .xsipOrderResponces
                                                        ?.toJson(),
                                                    conditionval: ''),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 45),
                                    side: BorderSide(
                                        color: colors.btnOutlinedBorder),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: colors.primaryDark,
                                    // mfOrder.mandateStatus == "APPROVED"
                                    //     ? (theme.isDarkMode
                                    //         ? colors.primaryDark
                                    //         : colors.primaryLight)
                                    //     : const Color(0xffE7EAF4),
                                    // mfOrder.invAmtError == null &&
                                    //         mfOrder.upiError == null
                                    //     ? (theme.isDarkMode
                                    //         ? colors.colorbluegrey
                                    //         : colors.colorBlack)
                                    //     :
                                  ),
                                  child: mfOrder.investloader == true
                                      ? const SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                Color.fromARGB(99, 48, 48, 48)),
                                            backgroundColor: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        )
                                      : TextWidget.subText(
                                          text: mfOrder.mfOrderTpye == "SIP"
                                              ? "Setup - SIP"
                                              : "Pay - One Time",
                                          fw: 2,
                                          theme: theme.isDarkMode,
                                          color: colors.colorWhite,
                                        ),
                                ),
                              ),
                            ]
                          ],
                        ),
                ],
              ],
            ),
          ));
    });
  }

  showBottomSheetbank(TranctionProvider fund, ThemesProvider theme) {
    showModalBottomSheet(
      enableDrag: false,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: const Color(0xffffffff),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 10),
                child: TextWidget.subText(
                  text: 'Choose an bank:',
                  theme: false,
                  color: colors.textPrimaryLight,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: fund.bankdetails!.dATA!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      fund.bankselection(index);
                      fund.setAccountslist(
                          fund.bankdetails!.dATA![index][2].toString());

                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      color: fund.bankdetails!.dATA![index][1] == fund.bankname
                          ? const Color(0xff999999).withOpacity(0.2)
                          : Colors.transparent,
                      child: TextWidget.titleText(
                        text:
                            '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}',
                        theme: theme.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }
}

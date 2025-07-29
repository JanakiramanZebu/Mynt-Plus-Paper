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
import '../../provider/mf_provider.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/snack_bar.dart';
import '../mutual_fund_old/create_mandate_daialogue.dart';
import '../profile_screen/fund_screen/upi_id_screens/upi_id_cancel_alert.dart';

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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    double notional = 0.0;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final ledgerdata = ref.watch(ledgerProvider);
      // final fund = ref.watch(fundProvider);
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mfOrder.mfOrderTpye == "SIP") ...[
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
                          backgroundColor: !theme.isDarkMode
                              ? colors.primaryLight
                              : colors.primaryDark,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: Text("Create mandate",
                          style: textStyle(
                              !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500))),
                ],
                if (mfOrder.mfOrderTpye != "SIP") ...[
                  const SizedBox(height: 14),

                  Text(
                    "Payment method",
                    style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      16,
                      FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      buttonStyleData: ButtonStyleData(
                        decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)),
                        ),
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        customHeights: mfOrder.getCustItemsHeight(),
                      ),
                      isExpanded: true,
                      style: textStyle(
                        const Color.fromARGB(255, 0, 0, 0),
                        13,
                        FontWeight.w500,
                      ),
                      hint: Text(
                        mfOrder.paymentName,
                        style: textStyle(
                          const Color(0XFF000000),
                          13,
                          FontWeight.w500,
                        ),
                      ),
                      items: mfOrder.investloader == false
                          ? mfOrder.addDividers()
                          : [],
                      value: mfOrder.paymentName,
                      onChanged: (value) async {
                        mfOrder.chngPayName("$value");
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
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
                  const SizedBox(height: 8),

                  // Conditional UPI section
                  if (mfOrder.paymentName == "UPI") ...[
                    const SizedBox(height: 12),
                    Text(
                      "UPI ID (Virtual payment address)",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        15,
                        FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 44,
                      child: CustomTextFormField(
                        textAlign: TextAlign.start,
                        fillColor: theme.isDarkMode
                            ? colors.darkGrey
                            : const Color(0xffF1F3F8),
                        hintText: 'example@upi',
                        hintStyle: textStyle(
                          const Color(0xff666666),
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
                          mfOrder.isValidUpiId(widget.data);
                        },
                      ),
                    ),
                    // if (mfOrder.upiError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "${mfOrder.upiError}",
                        style: textStyle(
                            colors.kColorRedText, 10, FontWeight.w500),
                      ),
                    ),
                  ],
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        // mfOrder.chngPayName("UPI");
                        if (mfOrder.mfOrderTpye != "SIP") {
                          final isUpi = mfOrder.paymentName == 'UPI';
                          final isNetBanking =
                              mfOrder.paymentName == 'NET BANKING';
                          final isUpiValid =
                              isUpi ? mfOrder.upiError == '' : true;

                          if (isUpiValid || isNetBanking) {
                            await mfOrder.upipaymenttrigger(
                              context,
                              mfOrder.mfPlaceOrderResponces!.orderId,
                              mfOrder.mfPlaceOrderResponces!.orderVal,
                              mfOrder.upiId.text,
                              mfOrder.paymentName,
                            );

                            if (mfOrder.upiApiresponse != null &&
                                mfOrder.upiApiresponse?.stat == "Ok") {
                              if (isUpi) {
                                showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  backgroundColor: const Color(0xffffffff),
                                  isDismissible: false,
                                  enableDrag: false,
                                  showDragHandle: false,
                                  useSafeArea: false,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PopScope(
                                      canPop: true,
                                      onPopInvokedWithResult: (didPop, result) {
                                        if (didPop) return;
                                      },
                                      child: UPIIDPaymentCancelAlert(
                                        data: mfOrder
                                            .mfPlaceOrderResponces!.orderId,
                                      ),
                                    );
                                  },
                                );
                              } else if (isNetBanking) {
                                final url = Uri.parse(
                                  'https://v3.mynt.in/mfapi${mfOrder.upiApiresponse!.file!}',
                                );

                                // Navigate to a new screen showing InAppWebView
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text("Net Banking"),
                                        leading: IconButton(
                                          icon: const Icon(
                                              Icons.arrow_back_ios_new),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            mfOrder.threeSecondTimer?.cancel();
                                            mfOrder.autoPopTimer?.cancel();
                                          },
                                        ),
                                      ),
                                      body: WillPopScope(
                                        onWillPop: () async {
                                          Navigator.pop(context);
                                          mfOrder.threeSecondTimer?.cancel();
                                          mfOrder.autoPopTimer?.cancel();
                                          // print("objectobjectobjectobjectobjectobjectobjectobject");
                                          return true;
                                        },
                                        child: InAppWebView(
                                          initialUrlRequest: URLRequest(
                                            url: WebUri(url.toString()),
                                          ),
                                          initialOptions:
                                              InAppWebViewGroupOptions(
                                            crossPlatform:
                                                InAppWebViewOptions(),
                                          ),
                                          onWebViewCreated:
                                              (InAppWebViewController
                                                  controller) {
                                            ConstantName.webViewController =
                                                controller;
                                          },
                                          onProgressChanged:
                                              (InAppWebViewController
                                                      controller,
                                                  int progress) {
                                            // Optional: add loading logic or progress indicator
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        } else {
                          if (mfOrder.mandateStatus == "APPROVED") {
                             
                          
                            mfOrder.fetchXsipPlaceOrder(
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
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16.0),
                        backgroundColor: mfOrder.mandateStatus == "APPROVED" ?  (theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight) : const Color(0xffE7EAF4),
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
                              style: textStyle(mfOrder.mandateStatus != "APPROVED" &&  mfOrder.mfOrderTpye == "SIP"
                                  ? colors.colorBlack
                                  : theme.isDarkMode
                                      ? colors.colorBlack
                                      : const Color(0xffffffff) ,
                                  14,
                                  FontWeight.w600))),
                ),
              ],
            ),
          ));
    });
  }
}

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
// import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/custom_switch_btn.dart';
import '../../../../sharedWidget/fund_function.dart';
import '../../../provider/fund_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/loader_ui.dart';
import '../../../sharedWidget/splash_loader.dart';
import '../../../utils/no_emoji_inputformatter.dart';
import '../../../models/fund_model_testing_copy/secured_bank_detalis_model.dart';
import '../../../models/fund_model_testing_copy/secured_client_data_model.dart';
import 'ios_fund_screen/ios_no_upi_apps_ui.dart';
import 'ios_fund_screen/ios_upi_apps_bottomsheet.dart';
import 'razorpay/razorpay_failed_ui.dart';
import 'razorpay/razorpay_success_ui.dart';
import 'upi_id_screens/upi_id_cancel_alert.dart';
import 'withdraw/withdraw_screen.dart';

class FundScreen extends ConsumerStatefulWidget {
  final TranctionProvider dd;
  const FundScreen({super.key, required this.dd});

  @override
  ConsumerState<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends ConsumerState<FundScreen> {
  @override
  void initState() {
    ref.read(transcationProvider).initialdata(context);
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      checkIosAvailableApps();
    }

    // Set default segment to Equity after a short delay to ensure data is loaded
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _setDefaultSegment(ref.read(transcationProvider));
    // });
  }

  bool _isDisposedIos = false;

  @override
  void dispose() {
    _isDisposedIos = true;
    super.dispose();
  }

  Future<void> _handleAndroidUpiPayment(
      BuildContext context, TranctionProvider fund) async {
    // Reset bottom sheet state when starting a new payment process
    fund.resetBottomSheetState();

    await fund.fetchValidateToken(context);
    fund.focusNode.unfocus();
    await fund.fetchUPIPaymet(
      context,
      "${fund.amount.text}.00",
      fund.multipleAccno,
      fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
      fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2],
    );

    await fund.fetchUpiPaymentstatus(
      context,
      "${fund.hdfcdirectpayment?.data?.orderNumber}",
      "${fund.hdfcdirectpayment?.data?.upiTransactionNo}",
    );
  }

  Future<void> _handleIosUpiPayment(BuildContext context,
      TranctionProvider fund, dynamic availableApps, dynamic theme) async {
    // Reset bottom sheet state when starting a new payment process
    fund.resetBottomSheetState();

    if (availableApps.isEmpty) {
      showModalBottomSheet(
          enableDrag: false,
          useSafeArea: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          backgroundColor: const Color(0xffffffff),
          context: context,
          builder: (context) {
            return IosNOUpiAppsSheet(theme: theme);
          });
    } else {
      fund.focusNode.unfocus();

      await fund.fetchUPIPaymet(
        context,
        "${fund.amount.text}.00",
        fund.multipleAccno,
        fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
        fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2],
      );

      await fund.fetchUpiPaymentstatus(
        context,
        "${fund.hdfcdirectpayment?.data?.orderNumber}",
        "${fund.hdfcdirectpayment?.data?.upiTransactionNo}",
      );

      showModalBottomSheet(
          enableDrag: false,
          useSafeArea: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          backgroundColor: const Color(0xffffffff),
          context: context,
          builder: (context) {
            return UpiAppsBottomSheet(upiapps: availableApps, theme: theme);
          });
    }
  }

  _showUpiIdForm(BuildContext context, TranctionProvider fund, dynamic theme,
      dynamic colors) {
    // Reset loading state and clear errors when opening the sheet
    fund.togglefundLoading(false);
    fund.clearerror();

    // This should show a dialog or navigate to a new screen with the UPI ID form
    showModalBottomSheet(
        enableDrag: false,
        useSafeArea: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        context: context,
        builder: (context) {
          return SafeArea(
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
              child: Consumer(
                builder: (context, ref, child) {
                  final fund = ref.watch(transcationProvider);
                  // Check if context is still mounted before building
                  if (!context.mounted) return const SizedBox.shrink();
                  return _buildUpiIdForm(fund, theme, colors, context, null);
                },
              ),
            ),
          );
        }).then((_) {
      // Reset loading state when sheet is dismissed
      fund.togglefundLoading(false);
    });
  }

  Widget _buildUpiIdForm(TranctionProvider fund, dynamic theme, dynamic colors,
      BuildContext context, StateSetter? setState) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 0,
        bottom: 16.0 +
            MediaQuery.of(context).viewInsets.bottom, // Add keyboard padding
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomDragHandler(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextWidget.titleText(
                      text: "UPI ID",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
              height: 0,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: fund.upiid,
              style: theme.isDarkMode
                  ? TextWidget.textStyle(
                      fontSize: 14, theme: false, color: colors.colorWhite)
                  : TextWidget.textStyle(
                      fontSize: 14, theme: false, color: colors.colorBlack),
              inputFormatters: [
                NoEmojiInputFormatter(),
                FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/,.]')),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: InputDecoration(
                hintText: "example: username@upi",
                hintStyle: TextWidget.textStyle(
                    fontSize: 14, theme: false, color: colors.colorGrey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.colorBlue),
                borderRadius: BorderRadius.circular(5)),
            disabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.colorBlue),
                borderRadius: BorderRadius.circular(5)),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5)),
                fillColor: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffF1F3F8),
                filled: true,
              ),
              onChanged: (value) {
                fund.upiidOnchange(value);
                fund.validateUPI(value);
              },
            ),
            if (fund.upiiderror != null && fund.upiiderror!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextWidget.captionText(
                    text: "${fund.upiiderror}",
                    theme: false,
                    color: theme.isDarkMode ? colors.errorDark : colors.errorLight,
                    fw: 0,
                    align: TextAlign.left),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    minimumSize: const Size(0, 45),
                    backgroundColor: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: () async {
                    // Validate and show errors if any
                    fund.upiidOnchange(fund.upiid.text);
                    fund.validateUPI(fund.upiid.text);

                    // Only proceed if validation passes
                    if (fund.upiiderror == null || fund.upiiderror!.isEmpty) {
                      await _handleUpiIdPayment(context, fund);
                    }
                  },
                  child: fund.fundLoading
                      ? SizedBox(
                          width: 18,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: colors.colorWhite),
                        )
                      : TextWidget.subText(
                          text: "Pay Via UPI ID",
                          theme: false,
                          color: colors.colorWhite,
                          fw: 2,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpiIdPayment(
      BuildContext context, TranctionProvider fund) async {
    // Reset bottom sheet state when starting a new payment process
    fund.resetBottomSheetState();

    try {
      await fund.fetcUPIIDPayment(
          context,
          fund.upiid.text,
          fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
          fund.bankdetails!.dATA![fund.indexss][2]);

      // Check if UPI ID validation was successful
      if (fund.upiiderror != null && fund.upiiderror!.isNotEmpty) {
        return; // Stop if there's an error
      }
      await fund.fetchHdfctranction(
        context,
        fund.upiid.text,
        int.parse(fund.amount.text),
        fund.accno,
        fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
      );

      if (fund.hdfcpaymentdata!.data!.verifiedVPAStatus1 == "Available" ||
          fund.hdfcpaymentdata!.data!.verifiedVPAStatus2 == "Available") {
        Navigator.pop(context);
        fund.focusNode.unfocus();

        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                  child: const UPIIDPaymentCancelAlert());
            });

        await fund.fetchHdfcpaymetstatus(
            context,
            '${fund.hdfctranction!.data!.orderNumber}',
            '${fund.hdfctranction!.data!.upiTransactionNo}');
      }
    } catch (e) {
      // Ensure loading state is reset on any error
      fund.togglefundLoading(false);
      rethrow;
    }
  }

  Future<void> _handleRazorpayPayment(
      BuildContext context, TranctionProvider fund) async {
    // Reset bottom sheet state when starting a new payment process
    fund.resetBottomSheetState();

    // Razorpay razorpay = Razorpay();
    Razorpay razorpay = Razorpay();

    await fund.fetchrazorpay(
      context,
      int.parse(fund.amount.text).toString(),
      fund.accno,
      fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][2],
      fund.ifsc,
      razorpay,
    );
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final fund = ref.watch(transcationProvider);
        final funds = ref.watch(fundProvider);
        return TransparentLoaderScreen(
          isLoading: fund.loading &&
              (fund.bankdetails == null || fund.decryptclientcheck == null),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              leadingWidth: 48,
              titleSpacing: 6,
              leading: CustomBackBtn(),
              elevation: .2,
              title: TextWidget.titleText(
                text: 'Add Money',
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                theme: theme.isDarkMode,
                fw: 1,
              ),
            ),
            body:
                // fund.loading
                //     ? SizedBox(child: CircularLoaderImage())
                //     // Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                //     //     const ProgressiveDotsLoader(),
                //     //     const SizedBox(height: 3),
                //     //     Text('This will take a few seconds.',
                //     //         style: textStyle(colors.colorGrey, 13, FontWeight.w500)),
                //     //   ])
                //     :
                SafeArea(
                  child: GestureDetector(
                                onTap: () {
                  fund.focusNode.unfocus();
                                },
                                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //     padding: const EdgeInsets.only(left: 16, top: 10),
                      //     child: TextWidget.subText(
                      //         text: "Choose type",
                      //         theme: !theme.isDarkMode,
                      //         fw: 1)),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 16, top: 10),
                      //   child: Row(
                      //     children: [
                      //       TextWidget.subText(
                      //         text: 'Deposit Money',
                      //         theme: false,
                      //         color: fund.enable
                      //             ? theme.isDarkMode
                      //                 ? colors.colorWhite
                      //                 : const Color(0xff000000)
                      //             : Colors.grey,
                      //         fw: 1,
                      //       ),
                      //       const SizedBox(
                      //         width: 16,
                      //       ),
                      //       CustomSwitch(
                      //         value: fund.enable,
                      //         onChanged: (bool val) async {
                      //           fund.withdrawamount.clear();
                      //           setState(() {
                      //             fund.changebool(val);
                      //           });
                      //         },
                      //       ),
                      //       const SizedBox(
                      //         width: 16,
                      //       ),
                      //       TextWidget.subText(
                      //         text: 'Withdraw Money',
                      //         theme: false,
                      //         color: fund.enable == false
                      //             ? theme.isDarkMode
                      //                 ? colors.colorWhite
                      //                 : colors.colorBlack
                      //             : colors.colorGrey,
                      //         fw: 1,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // fund.enable == true
                      //     ?
                  
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, top: 16, right: 16, bottom: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget.subText(
                                  text:
                                      "₹ ${formatIndianCurrency(funds.fundDetailModel?.cash ?? "0.00")} Available",
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  focusNode: fund.focusNode,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  style: TextWidget.textStyle(
                                    theme: theme.isDarkMode,
                                    fontSize: 25,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                  ),
                                  controller: fund.amount,
                                  onChanged: (value) {
                                    fund.textFiledonChange(value);
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: colors.colorBlue),
                                        borderRadius: BorderRadius.circular(5)),
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: colors.colorBlue),
                                        borderRadius: BorderRadius.circular(5)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(5)),
                                    fillColor: theme.isDarkMode
                                        ? colors.darkGrey
                                        : const Color(0xffF1F3F8),
                                    filled: true,
                                    hintText: "0",
                                    hintStyle: TextWidget.textStyle(
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fontSize: 25,
                                    ),
                                    labelStyle: TextWidget.textStyle(
                                      theme: theme.isDarkMode,
                                      fontSize: 25,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SvgPicture.asset(
                                        assets.ruppeIcon,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  
                          Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child:
                                  fund.amount.text.isEmpty || fund.intValue < 50
                                      ? TextWidget.captionText(
                                          text: fund.funderror,
                                          theme: false,
                                          color: theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight,
                                          fw: 0,
                                        )
                                      : fund.intValue > 5000000
                                          ? TextWidget.captionText(
                                              text: fund.maxfunderror,
                                              theme: false,
                                              color: theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight,
                                              fw: 0,
                                            )
                                          : const SizedBox.shrink()),
                          // Padding(
                          //     padding: const EdgeInsets.only(
                          //       left: 16,
                          //     ),
                          //     child: fund.amount.text.isEmpty
                          //         ? TextWidget.subText(
                          //             text: "Enter the amount",
                          //             theme: false,
                          //             color: colors.colorGrey,
                          //             fw: 0)
                          //         : fund.amount.text.isEmpty ||
                          //                 fund.intValue < 50
                          //             ? TextWidget.subText(
                          //                 text: fund.funderror,
                          //                 theme: false,
                          //                 color: colors.darkred,
                          //                 fw: 0)
                          //             : fund.intValue > 5000000
                          //                 ? TextWidget.subText(
                          //                     text: fund.maxfunderror,
                          //                     theme: false,
                          //                     color: colors.darkred,
                          //                     fw: 0)
                          //                 : TextWidget.subText(
                          //                     text:
                          //                         "${fund.textResult}only",
                          //                     theme: false,
                          //                     color: colors.colorGrey,
                          //                     fw: 0)),
                  
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //     left: 16,
                          //   ),
                          //   child: headerTitleText(
                          //     "Segment",
                          //   ),
                          // ),
                  
                          // type selection section
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 16),
                          //   height: 35,
                          //   child: Row(
                          //     children: [
                          //       Expanded(
                          //         child: fund.decryptclientcheck!.companyCode!.contains("NSE_CASH") ? _buildSegmentTab(
                          //           "Equity",
                          //           fund.textValue == "NSE_CASH",
                          // () => _selectSegment("NSE_CASH", fund),
                          //           theme,
                          //         ) : const SizedBox.shrink(),
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Expanded(
                          //         child: fund.decryptclientcheck!.companyCode!.contains("NSE_FNO") ? _buildSegmentTab(
                          //           "F&O",
                          //           fund.textValue == "NSE_FNO",
                          //           () => _selectSegment("NSE_FNO", fund),
                          //           theme,
                          //         ) : const SizedBox.shrink(),
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Expanded(
                          //         child: fund.decryptclientcheck!.companyCode!.contains("MCX") ? _buildSegmentTab(
                          //           "Commodity",
                          //           fund.textValue == "MCX",
                          //           () => _selectSegment("MCX", fund),
                          //           theme,
                          //         ) : const SizedBox.shrink(),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Old bank account UI (commented out)
                          // Padding(
                          //     padding: const EdgeInsets.only(
                          //       left: 16,
                          //     ),
                          //     child: TextWidget.subText(
                          //         text: "Bank account",
                          //         theme: false,
                          //         fw: 0,
                          //         color: colors.colorGrey)),
                          // GestureDetector(
                          //   onTap: () {
                          //     fund.focusNode.unfocus();
                          // showBottomSheetbank(fund, theme);
                          //   },
                          //   child: Container(
                          //       decoration: BoxDecoration(
                          //           color: theme.isDarkMode
                          //               ? colors.darkGrey
                          //               : const Color(0xffF1F3F8),
                          //           borderRadius:
                          //               BorderRadius.circular(30)),
                          //       width: MediaQuery.of(context).size.width,
                          //       height: 44,
                          //       margin: const EdgeInsets.symmetric(
                          //           horizontal: 16, vertical: 16),
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 16, vertical: 10),
                          //       child: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           Expanded(
                          //             child: TextWidget.titleText(
                          //                 text: fund.initbank,
                          //                 theme: theme.isDarkMode,
                          //                 fw: 1,
                          //                 textOverflow:
                          //                     TextOverflow.ellipsis),
                          //           ),
                          //           SvgPicture.asset(assets.downArrow)
                          //         ],
                          //       )),
                          // ),
                  
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    const ListDivider(),
                                    InkWell(
                                      onTap: () async {
                                        await Future.delayed(
                                            const Duration(milliseconds: 150));
                                        fund.focusNode.unfocus();
                                        showBottomSheetbank(fund, theme);
                                      },
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        // minVerticalPadding: 16,
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: TextWidget.subText(
                                            text: fund.bankname,
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: TextWidget.paraText(
                                            text: hideAccountNumber(fund.accno),
                                            theme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                : colors.textSecondaryLight,
                                          ),
                                        ),
                                        trailing: Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            splashColor: theme.isDarkMode
                                                ? colors.splashColorDark
                                                : colors.splashColorLight,
                                            highlightColor: theme.isDarkMode
                                                ? colors.highlightDark
                                                : colors.highlightLight,
                                            onTap: () async {
                                              // Add delay for visual feedback
                  
                                              await Future.delayed(const Duration(
                                                  milliseconds: 150));
                                              fund.focusNode.unfocus();
                                              showBottomSheetbank(fund, theme);
                                            },
                                            child: Container(
                                              height: 32,
                                              width: 32,
                                              child: Center(
                                                child: Icon(
                                                  Icons.more_vert,
                                                  size: 22,
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors.textSecondaryLight,
                                                ),
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
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                  
                            // Payment method
                  
                            child: TextWidget.subText(
                              text: "Payment method",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ListView.separated(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: fund.defaultUpiapps.length,
                            separatorBuilder: (context, index) =>
                                const ListDivider(),
                            itemBuilder: (context, index) {
                              bool isUpiPayment =
                                  index == 0 || index == 1; // UPI Apps and UPI ID
                              bool isAmountAbove1Lakh = fund.intValue > 100000;
                  
                              return Column(
                                children: [
                                  if (index == 0) const ListDivider(),
                                  InkWell(
                                    onTap: () {
                                      if (fund.amount.text.isEmpty ||
                                          fund.intValue < 50) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(warningMessage(
                                                context, "Min amount ₹50"));
                                        return;
                                      }
                  
                                      // Check for UPI payment restriction above 1 lakh
                                      if (isUpiPayment && isAmountAbove1Lakh) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(warningMessage(context,
                                                "UPI payments are not allowed for amounts above ₹1,00,000. Please use Net Banking."));
                                        return;
                                      }
                  
                                      // Proceed with payment based on method
                                      if (index == 0) {
                                        if (defaultTargetPlatform ==
                                            TargetPlatform.android) {
                                          _handleAndroidUpiPayment(context, fund);
                                        } else {
                                          _handleIosUpiPayment(context, fund,
                                              availableApps, theme);
                                        }
                                      } else if (index == 1) {
                                        _showUpiIdForm(
                                            context, fund, theme, colors);
                                      } else if (index == 2) {
                                        if (fund.intValue > 5000000) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(warningMessage(
                                                  context,
                                                  "Max amount ₹5,000,000"));
                                        } else {
                                          _handleRazorpayPayment(context, fund);
                                        }
                                      }
                                    },
                                    child: Opacity(
                                      opacity:
                                          (isUpiPayment && isAmountAbove1Lakh)
                                              ? 0.5
                                              : 1.0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 24),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              '${fund.addfundIcons[index]['image']}',
                                              width: index == 0 && index == 1
                                                  ? 40
                                                  : 40,
                                              color: index ==2 ? theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight : null,
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextWidget.paraText(
                                                        text:
                                                            '${fund.defaultUpiapps[index]['name']}',
                                                        theme: theme.isDarkMode,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textPrimaryDark
                                                            : colors
                                                                .textPrimaryLight,
                                                      ),
                                                      SvgPicture.asset(
                                                        assets.leftArrow,
                                                        width: 16,
                                                        height: 16,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                      )
                                                    ],
                                                  ),
                                                  if (isUpiPayment &&
                                                      isAmountAbove1Lakh)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child:
                                                          TextWidget.captionText(
                                                        text:
                                                            "Not available for amount above ₹1,00,000",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight,
                                                        fw: 0,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (index == fund.defaultUpiapps.length - 1)
                                    const ListDivider(),
                                ],
                              );
                            },
                          ),
                        ],
                      )
                      // : WithdrawScreen(
                      //     segment: fund.textValue,
                      //     withdarw: fund,
                      //     foucs: fund.focusNode,
                      //     theme: theme,
                      //   )
                    ],
                  ),
                                ),
                              ),
                ),
          ),
        );
      },
    );
  }

  String formatIndianCurrency(String amount) {
    final formatter = NumberFormat.currency(
      locale: "en_IN",
      symbol: '', // Or '₹'
      decimalDigits: 2, // Always show 2 decimals
    );
    return formatter.format(double.tryParse(amount) ?? 0.0);
  }

  // Old chip-style segment selection UI
  // Widget _buildSegmentChip(String label, bool isSelected, VoidCallback onTap, ThemesProvider theme) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 44,
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? (theme.isDarkMode ? colors.colorWhite : colors.colorBlack)
  //             : (theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8)),
  //         borderRadius: BorderRadius.circular(22),
  //         border: Border.all(
  //           color: isSelected
  //               ? (theme.isDarkMode ? colors.colorWhite : colors.colorBlack)
  //               : (theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8)),
  //           width: 1,
  //         ),
  //       ),
  //       child: Center(
  //         child: TextWidget.subText(
  //           text: label,
  //           theme: theme.isDarkMode,
  //           color: isSelected
  //               ? (theme.isDarkMode ? colors.colorBlack : colors.colorWhite)
  //               : (theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
  //           fw: isSelected ? 2 : 1,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSegmentTab(
      String label, bool isSelected, VoidCallback onTap, ThemesProvider theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffF1F3F8) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: TextWidget.paraText(
              text: label,
              theme: false,
              color: isSelected
                  ? (theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight)
                  : const Color(0XFF777777),
              fw: isSelected ? 0 : null,
            ),
          ),
        ),
      ),
    );
  }

  void _selectSegment(String segmentCode, TranctionProvider fund) {
    // Find the index of the segment in the companyCode array
    if (fund.decryptclientcheck?.companyCode != null) {
      final index = fund.decryptclientcheck!.companyCode!.indexOf(segmentCode);
      fund.segmentselection(index);
      print(" funddd index: $index");
      print(" codes: ${fund.decryptclientcheck!.companyCode![index]}");
    }
  }

  _showBottomSheet(TranctionProvider fund, ThemesProvider theme) {
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
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextWidget.subText(
                  text: 'Choose an Segment:',
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: fund.decryptclientcheck!.companyCode!.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      fund.segmentselection(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: fund.decryptclientcheck!.companyCode![index] ==
                              fund.textValue
                          ? const Color(0xff999999).withOpacity(0.2)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: Row(
                          children: [
                            TextWidget.titleText(
                              text:
                                  fund.decryptclientcheck!.companyCode![index],
                              theme: theme.isDarkMode,
                              fw: 1,
                            ),
                          ],
                        ),
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

  // Set default segment to Equity (NSE_CASH) when screen initializes
  // void _setDefaultSegment(TranctionProvider fund) {
  //   if (fund.textValue.isEmpty || fund.textValue != "NSE_CASH") {
  //     _selectSegment("NSE_CASH", fund);
  //   }
  // }

  Widget headerTitleText(String text) {
    return TextWidget.subText(
        text: text, theme: false, color: colors.colorGrey, fw: 0);
  }

  Widget contantTitleText(String text) {
    return TextWidget.titleText(
      text: text,
      theme: false,
      fw: 1,
    );
  }

  final List<Map<String, dynamic>> upiApptest = [
    {
      'icon': assets.biggpay,
      'name': 'Google Pay',
      'url': 'gpay://',
      'value': '0'
    },
    {
      'icon': assets.bigphnpay,
      'name': 'PhonePe',
      'url': 'phonepe://',
      'value': '1'
    },
    {'icon': assets.bigpaytm, 'name': 'Paytm', 'url': 'paytm://', 'value': '2'},
  ];

  List<Map<String, dynamic>> availableApps = [];

  Future<void> checkIosAvailableApps() async {
    List<Map<String, dynamic>> tempList = [];

    for (var app in upiApptest) {
      bool isInstalled = await canLaunch(app['url']!);
      if (isInstalled) {
        tempList.add(app);
      }
    }
    if (!_isDisposedIos) {
      setState(() {
        availableApps = tempList;
      });
    }

    setState(() {
      availableApps = tempList;
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
        return SafeArea(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomDragHandler(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 10),
                  child: TextWidget.titleText(
                    text: 'Choose an bank',
                    theme: false,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 1,
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
                            ? theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.2) : colors.textSecondaryLight.withOpacity(0.2)
                            : Colors.transparent,
                        child: TextWidget.titleText(
                          text:
                              '${fund.bankdetails!.dATA![index][1]}-${hideAccountNumber(fund.bankdetails!.dATA![index][2])}',
                          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
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
          ),
        );
      },
    );
  }

  handlePaymentErrorResponse(
    PaymentFailureResponse response,
  ) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        backgroundColor: const Color(0xffffffff),
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: false,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: RazorpayFailedUi(
                  acco: widget.dd.accno,
                  ifsc: widget.dd.ifsc,
                  amount: ref.read(transcationProvider).amount.text,
                  bankname: widget.dd.bankname));
        });
  }

  handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    ref.read(transcationProvider).fetchrazorpayStatus("${response.paymentId}");
    print("sent payment id razor pay: ${response.paymentId}");
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        backgroundColor: const Color(0xffffffff),
        isDismissible: true,
        enableDrag: true,
        showDragHandle: false,
        useSafeArea: false,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
              },
              child: RazorpaySuccessUi(
                amount: ref.read(transcationProvider).amount.text,
              ));
        });
    ref.read(transcationProvider).amount.clear();
  }
}

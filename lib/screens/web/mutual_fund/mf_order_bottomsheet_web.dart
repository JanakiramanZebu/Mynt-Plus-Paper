import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../sharedWidget/common_text_fields_web.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/transcation_provider.dart';
// import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/fund_function.dart';
import 'package:mynt_plus/screens/web/mutual_fund/create_mandate_dialogue_web.dart';
import '../../../screens/web/profile/fund_screen/upi_id_screens/mf_payment_resp_alert.dart';
import 'mandate_selection_screen_web.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'mf_processing_screen_web.dart';

class MfOrderBottomsheetWeb extends StatefulWidget {
  final dynamic data;
  final String? condval;
  const MfOrderBottomsheetWeb({super.key, required this.data, this.condval});

  @override
  State<MfOrderBottomsheetWeb> createState() => _MfOrderBottomsheetWeb();
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

class _MfOrderBottomsheetWeb extends State<MfOrderBottomsheetWeb> {
  String _getSelectedMandateAmount(MFProvider mfOrder) {
    if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
      return "N/A";
    }
    final selectedMandate = mfOrder.mandateData!.firstWhere(
      (mandate) => mandate.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );
    return double.parse(selectedMandate.amount ?? "0").toStringAsFixed(2) ?? "N/A";
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
            return true;
          },
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: resolveThemeColor(context,
                    dark: MyntColors.backgroundColorDark,
                    light: MyntColors.backgroundColor),
                border: Border.all(
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark, light: MyntColors.divider),
                ),
              ),
              child: mfOrder.investloader
                  ? SizedBox(
                      height: screenheight * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 650),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                      scale: animation, child: child),
                              child: mfOrder.loadingMessage == "Order Initiated"
                                  ? Icon(
                                      Icons.check_circle,
                                      key: const ValueKey("verified"),
                                      size: 50,
                                      color: theme.isDarkMode
                                          ? colors.profitDark
                                          : colors.profitLight,
                                    )
                                  : SizedBox(
                                      key: const ValueKey("loading"),
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          theme.isDarkMode
                                              ? MyntColors.primaryDark
                                              : MyntColors.primary,
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              mfOrder.loadingMessage ?? "",
                              style: MyntWebTextStyles.bodySmall(
                                context,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            border: Border(
                              bottom: BorderSide(
                                color: resolveThemeColor(context,
                                    dark: MyntColors.dividerDark,
                                    light: MyntColors.divider),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                mfOrder.mfOrderTpye == "SIP" && widget.condval != 'sipfirstorder' && widget.condval != 'reinitiatefromportfolio'
                                    ? "Setup SIP"
                                    : "Pay With",
                                style: MyntWebTextStyles.title(
                                  context,
                                  fontWeight: MyntFonts.semiBold,
                                  darkColor: MyntColors.textPrimaryDark,
                                  lightColor: MyntColors.textPrimary,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: resolveThemeColor(context,
                                      dark: MyntColors.iconSecondaryDark,
                                      light: MyntColors.iconSecondary),
                                ),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (mfOrder.mfOrderTpye == "SIP" && widget.condval != 'sipfirstorder' && widget.condval != 'reinitiatefromportfolio') ...[
                                  Text(
                                    "Auto Pay (Mandate)",
                                    style: MyntWebTextStyles.title(
                                      context,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Show mandate selection if mandates exist, otherwise show create mandate button
                                  if (mfOrder.mandateData != null &&
                                      mfOrder.mandateData!.isNotEmpty) ...[
                                    // Clickable mandate card
                                    InkWell(
                                      onTap: () {
                                        // Navigate to mandate selection screen
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => Dialog(
                                            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            child: SizedBox(
                                              width: MediaQuery.of(context).size.width >= 1100
                                                  ? MediaQuery.of(context).size.width * 0.30
                                                  : MediaQuery.of(context).size.width >= 800
                                                      ? MediaQuery.of(context).size.width * 0.50
                                                      : MediaQuery.of(context).size.width * 0.9,
                                              child: MandateSelectionScreenWeb(
                                                currentMandateId: mfOrder.mandateId,
                                                onMandateSelected: (String mandateId) {
                                                  mfOrder.chngMandate(mandateId);
                                                  Navigator.pop(context);
                                                },
                                              ),
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
                                              : const Color(0xffF1F3F8),
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
                                                      Text(
                                                        _getSelectedMandateAmount(mfOrder),
                                                        style: MyntWebTextStyles.bodySmall(
                                                          context,
                                                          color: theme.isDarkMode
                                                              ? colors.textPrimaryDark
                                                              : colors.textPrimaryLight,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 4,
                                                      ),
                                                      _getSelectedMandateStatus(
                                                          mfOrder),
                                                    ],
                                                  ),
              
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
              
                                                  Text(
                                                    _getSelectedMandateBankName(mfOrder),
                                                    style: MyntWebTextStyles.bodySmall(
                                                      context,
                                                      color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors.textPrimaryLight,
                                                    ),
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
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
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
                                              child: Text(
                                                _getMandateErrorMessage(mfOrder),
                                                style: MyntWebTextStyles.caption(
                                                  context,
                                                  color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                                                ),
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
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width >= 1100
                                                      ? MediaQuery.of(context).size.width * 0.30
                                                      : MediaQuery.of(context).size.width >= 800
                                                          ? MediaQuery.of(context).size.width * 0.50
                                                          : MediaQuery.of(context).size.width * 0.9,
                                                  child: const CreateMandateDialogue()
                                                ),
                                              );
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
                                        child: Text(
                                          "Create New Mandate",
                                          style: MyntWebTextStyles.bodySmall(
                                            context,
                                            color: !theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                          ),
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
                                if (mfOrder.mfOrderTpye != "SIP" || widget.condval == 'sipfirstorder' || widget.condval == 'reinitiatefromportfolio') ...[
                                  // Bank selection
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Bank Account",
                                      style: MyntWebTextStyles.body(
                                        context,
                                        fontWeight: MyntFonts.medium,
                                        color: resolveThemeColor(context,
                                            dark: MyntColors.textPrimaryDark,
                                            light: MyntColors.textPrimary),
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (btnContext) => GestureDetector(
                                      onTap: () => _showBankPopover(btnContext, fund, theme),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: resolveThemeColor(context,
                                              dark: MyntColors.transparent,
                                              light: const Color(0xffF1F3F8)),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: resolveThemeColor(context,
                                                dark: MyntColors.textSecondaryDark,
                                                light: MyntColors.outlinedBorder),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${fund.bankname}  -  ${hideAccountNumber(fund.accno)}",
                                                style: MyntWebTextStyles.body(
                                                  context,
                                                  fontWeight: MyntFonts.medium,
                                                  darkColor: MyntColors.textPrimaryDark,
                                                  lightColor: MyntColors.textPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              color: resolveThemeColor(context,
                                                  dark: MyntColors.textSecondaryDark,
                                                  light: MyntColors.textSecondary),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Payment method label
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                    child: Text(
                                      "Payment method",
                                      style: MyntWebTextStyles.bodyMedium(
                                        context,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fontWeight: MyntFonts.medium,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: mfOrder.paymentMethod.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final paymentMethodName =
                                          mfOrder.paymentMethod[index];
                                      final paymentMethodImage =
                                          paymentMethodName == "UPI"
                                              ? 'assets/icon/paymentIcon/upi.svg'
                                              : 'assets/icon/netbanking_icon.svg';
                                      final isSelected =
                                          mfOrder.paymentName == paymentMethodName;

                                      return GestureDetector(
                                        onTap: () {
                                          mfOrder.chngPayName(paymentMethodName);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: null,
                                            border: Border.all(
                                              color: isSelected
                                                  ? resolveThemeColor(context,
                                                      dark: MyntColors.primaryDark,
                                                      light: MyntColors.primary)
                                                  : resolveThemeColor(context,
                                                      dark: MyntColors.dividerDark,
                                                      light: MyntColors.divider),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    paymentMethodImage,
                                                    width: 24,
                                                    height: 24,
                                                    colorFilter: index == 1
                                                        ? ColorFilter.mode(
                                                            theme.isDarkMode
                                                                ? colors.textSecondaryDark
                                                                : colors.textSecondaryLight,
                                                            BlendMode.srcIn)
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      paymentMethodName == "UPI"
                                                          ? "UPI ID"
                                                          : "Net Banking",
                                                      style: MyntWebTextStyles.body(
                                                        context,
                                                        fontWeight: isSelected
                                                            ? MyntFonts.semiBold
                                                            : MyntFonts.medium,
                                                        color: isSelected
                                                            ? resolveThemeColor(
                                                                context,
                                                                dark: MyntColors
                                                                    .primaryDark,
                                                                light: MyntColors
                                                                    .primary)
                                                            : resolveThemeColor(
                                                                context,
                                                                dark: MyntColors
                                                                    .textPrimaryDark,
                                                                light: MyntColors
                                                                    .textPrimary),
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: resolveThemeColor(
                                                          context,
                                                          dark: MyntColors.primaryDark,
                                                          light: MyntColors.primary),
                                                      size: 18,
                                                    ),
                                                ],
                                              ),
                                              // UPI input field
                                              if (isSelected &&
                                                  paymentMethodName == "UPI") ...[
                                                const SizedBox(height: 10),
                                                MyntFormTextField(
                                                  controller: mfOrder.upiId,
                                                  placeholder: 'Enter UPI ID',
                                                  height: 40,
                                                  textStyle:
                                                      MyntWebTextStyles.body(
                                                    context,
                                                    fontWeight: MyntFonts.medium,
                                                    darkColor: MyntColors
                                                        .textPrimaryDark,
                                                    lightColor:
                                                        MyntColors.textPrimary,
                                                  ),
                                                  onChanged: (value) {
                                                    mfOrder.isValidUpiId(
                                                        mfOrder.upiId.text,
                                                        'reinitiatefromportfolio');
                                                  },
                                                ),
                                                if (mfOrder.upiError != null &&
                                                    mfOrder
                                                        .upiError!.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      "${mfOrder.upiError}",
                                                      style: MyntWebTextStyles
                                                          .para(
                                                        context,
                                                        color:
                                                            resolveThemeColor(
                                                                context,
                                                                dark: MyntColors
                                                                    .lossDark,
                                                                light:
                                                                    MyntColors
                                                                        .loss),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Footer
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: resolveThemeColor(context,
                                    dark: MyntColors.dividerDark,
                                    light: MyntColors.divider),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (mfOrder.mfOrderTpye != "SIP" || widget.condval == 'sipfirstorder' || widget.condval == 'reinitiatefromportfolio') {
                                  final isUpi = mfOrder.paymentName == 'UPI';
                                  final isNetBanking =
                                      mfOrder.paymentName == 'NET BANKING';
                                  final isUpiValid =
                                      isUpi ? mfOrder.upiError == '' : true;

                                  mfOrder.isValidUpiId(
                                      widget.data, widget.condval.toString());

                                  if ((isUpiValid &&
                                          mfOrder.upiId.text.isNotEmpty) ||
                                      isNetBanking) {
                                    mfOrder.setInvestLoader(true);
                                    mfOrder.setLoadingMessage(
                                        "Processing payment...");
                                    mfOrder.IsPaymentCalled(true);

                                    await mfOrder.upipaymenttrigger(
                                      context,
                                      widget.condval == 'reinitiatefromportfolio'
                                          ? widget.data.orderId
                                          : mfOrder.mfPlaceOrderResponces!.orderId,
                                      widget.condval == 'reinitiatefromportfolio'
                                          ? widget.data.orderVal
                                          : mfOrder.mfPlaceOrderResponces!.orderVal,
                                      mfOrder.upiId.text,
                                      mfOrder.paymentName,
                                    );

                                    final upiResponse = mfOrder.upiApiresponse;

                                    if (upiResponse != null) {
                                      if (upiResponse.stat == "Ok") {
                                        if (isUpi) {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) =>
                                                MfUPIProcessingScreenWeb(
                                              data: widget.condval ==
                                                      'reinitiatefromportfolio'
                                                  ? widget.data.orderId
                                                  : mfOrder
                                                      .mfPlaceOrderResponces!
                                                      .orderId,
                                            ),
                                          );
                                        } else if (isNetBanking) {
                                          final url = Uri.parse(
                                              'https://v3.mynt.in/mfapi${upiResponse.file!}');
                                          await launchUrl(url,
                                              mode: LaunchMode.platformDefault,
                                              webOnlyWindowName: '_blank');
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) =>
                                                MfUPIProcessingScreenWeb(
                                              data: widget.condval ==
                                                      'reinitiatefromportfolio'
                                                  ? widget.data.orderId
                                                  : mfOrder
                                                      .mfPlaceOrderResponces!
                                                      .orderId,
                                            ),
                                          );
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => MfPaymentRespAlert(
                                            upiData: upiResponse
                                                .data!
                                                .toJson(),
                                            conditionval:
                                                'reinitiateerror',
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } else {
                                  if (mfOrder.mandateStatus == "APPROVED") {
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
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => MfPaymentRespAlert(
                                          upiData: mfOrder
                                              .xsipOrderResponces
                                              ?.toJson(),
                                          conditionval: '',
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.isDarkMode
                                    ? MyntColors.secondary
                                    : MyntColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24),
                                elevation: 0,
                              ),
                              child: Text(
                                mfOrder.mfOrderTpye == "SIP" && widget.condval != 'sipfirstorder' && widget.condval != 'reinitiatefromportfolio'
                                    ? "Setup - SIP"
                                    : "Pay - One Time",
                                style: MyntWebTextStyles.bodySmall(
                                  context,
                                  fontWeight: MyntFonts.semiBold,
                                  color: MyntColors.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ));
    });
  }

  void _showBankPopover(
      BuildContext btnContext, TranctionProvider fund, ThemesProvider theme) {
    if (fund.clientBankList.isEmpty) {
      return;
    }

    final btnWidth = (btnContext.findRenderObject() as RenderBox).size.width;

    shadcn.showPopover(
      context: btnContext,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 4),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: shadcn.Theme.of(btnContext).borderRadiusLg,
      ),
      builder: (popoverContext) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: shadcn.Theme.of(popoverContext).borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: shadcn.ModalContainer(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: btnWidth - 8,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: fund.clientBankList.length,
                  itemBuilder: (context, index) {
                    final bank = fund.clientBankList[index];
                    final bankName = bank.bankName ?? '';
                    final accountNo = bank.accountNo ?? '';
                    final isSelected = bankName == fund.bankname &&
                        accountNo == fund.accno;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          shadcn.closeOverlay(popoverContext);
                          fund.selectClientBank(index);
                          setState(() {});
                        },
                        splashColor: resolveThemeColor(context,
                            dark: MyntColors.rippleDark,
                            light: MyntColors.rippleLight),
                        highlightColor: resolveThemeColor(context,
                            dark: MyntColors.highlightDark,
                            light: MyntColors.highlightLight),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? resolveThemeColor(context,
                                    dark: MyntColors.primary
                                        .withValues(alpha: 0.1),
                                    light: MyntColors.primary
                                        .withValues(alpha: 0.06))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bankName,
                                      style: MyntWebTextStyles.body(
                                        context,
                                        fontWeight: isSelected
                                            ? MyntFonts.semiBold
                                            : MyntFonts.medium,
                                        color: isSelected
                                            ? resolveThemeColor(context,
                                                dark: MyntColors.primaryDark,
                                                light: MyntColors.primary)
                                            : resolveThemeColor(context,
                                                dark: MyntColors
                                                    .textPrimaryDark,
                                                light:
                                                    MyntColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hideAccountNumber(accountNo),
                                      style: MyntWebTextStyles.para(
                                        context,
                                        darkColor:
                                            MyntColors.textSecondaryDark,
                                        lightColor:
                                            MyntColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

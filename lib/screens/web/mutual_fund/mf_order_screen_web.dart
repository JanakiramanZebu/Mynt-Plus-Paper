import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/models/mf_model/mutual_fundmodel.dart';
import '../../../models/mf_model/mf_lumpsum_order.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/transcation_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_color_styles.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../Mobile/mutual_fund_old/create_mandate_daialogue.dart';
import '../../Mobile/profile_screen/fund_screen/upi_id_screens/mf_payment_resp_alert.dart';
import 'mf_order_bottomsheet_web.dart';

// Utility function to get the appropriate suffix for date numbers
String getDateSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }

  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

class MFOrderScreenWeb extends ConsumerStatefulWidget {
  final MutualFundList mfData;
  const MFOrderScreenWeb({super.key, required this.mfData});

  @override
  ConsumerState<MFOrderScreenWeb> createState() => _MFOrderScreenState();
}

class _MFOrderScreenState extends ConsumerState<MFOrderScreenWeb> {
  bool _isMandateDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mfProv = ref.read(mfProvider);
      // Only set invAmt if it's not already set from NFO screen
      if (mfProv.invAmt.text.isEmpty) {
        mfProv.invAmt.text = widget.mfData.minimumPurchaseAmount ?? '500';
      }

      // Fetch SIP data, mandate details, and bank details
      final isin = widget.mfData.iSIN;
      final schemeCode = widget.mfData.schemeCode;
      if (isin != null && schemeCode != null) {
        await mfProv.fetchMFSipData(isin, schemeCode);
        await mfProv.fetchMFMandateDetail();
      }
      // Fetch UPI details for payment UI
      await mfProv.fetchUpiDetail('', context);
      // Fetch bank_check API and set default bank
      final fundProv = ref.read(transcationProvider);
      await fundProv.fetchfundbank(context);
      // Set default bank if data is available
      if (fundProv.bankdetails?.dATA != null && fundProv.bankdetails!.dATA!.isNotEmpty) {
        fundProv.bankselection(0);
      }
      // Clear any validation errors after data is loaded
      mfProv.resetmfordervalidation();
    });
  }

  String _formatDate(String input) {
    if (input.isEmpty) return "N/A";

    try {
      List<DateFormat> formats = [
        DateFormat('MMM d yyyy  h:mma'),
        DateFormat('MMM d yyyy h:mma'),
        DateFormat('MMM d yyyy H:mma'),
      ];

      DateTime? parsedDate;
      for (DateFormat format in formats) {
        try {
          parsedDate = format.parse(input);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate != null) {
        final outputFormat = DateFormat('MMM dd yyyy h:mma');
        return outputFormat.format(parsedDate);
      } else {
        return input;
      }
    } catch (e) {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mfOrder = ref.watch(mfProvider);
    final isDark = theme.isDarkMode;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_isMandateDropdownOpen) {
          setState(() => _isMandateDropdownOpen = false);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? MyntColors.overlayBgDark : MyntColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header with fund name and close button
              _buildHeader(isDark, mfOrder),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order type toggle (Lumpsum / Monthly SIP)
                      _buildOrderTypeToggle(isDark, mfOrder),

                      const SizedBox(height: 24),

                      // SIP specific fields
                      if (mfOrder.mfOrderTpye == "SIP") ...[
                        // Mandates section
                        _buildMandatesSection(isDark, mfOrder),
                        const SizedBox(height: 20),
                      ],

                      // Investment/Instalment amount field
                      _buildAmountField(isDark, mfOrder),

                      // SIP date selector (only for SIP orders)
                      if (mfOrder.mfOrderTpye == "SIP") ...[
                        const SizedBox(height: 20),
                        _buildSIPDateSelector(isDark, mfOrder),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom button
              _buildBottomButton(isDark, mfOrder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, MFProvider mfOrder) {
    final fundName = _getFundName(mfOrder);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? MyntColors.dialogDark : MyntColors.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? MyntColors.dividerDark : MyntColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fund info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fundName,
                  style: MyntWebTextStyles.title(
                    context,
                    fontWeight: MyntFonts.semiBold,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  mfOrder.mfOrderTpye == "One-time" ? "One-time" : "SIP",
                  style: MyntWebTextStyles.para(
                    context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeToggle(bool isDark, MFProvider mfOrder) {
    final isSIP = mfOrder.mfOrderTpye == "SIP";

    return Row(
      children: [
        Text(
          "One-Time",
          style: MyntWebTextStyles.bodyMedium(
            context,
            color: !isSIP
                ? (isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary)
                : (isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary),
            fontWeight: !isSIP ? MyntFonts.semiBold : MyntFonts.regular,
          ),
        ),
        const SizedBox(width: 12),
        // Toggle Switch
        GestureDetector(
          onTap: () {
            if (widget.mfData.sIPFLAG == "Y") {
              _switchOrderType(isSIP ? "One-time" : "SIP", mfOrder);
            }
          },
          child: Container(
            width: 50,
            height: 28,
            decoration: BoxDecoration(
              color: isSIP ? resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary) : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isSIP ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "Monthly SIP",
          style: MyntWebTextStyles.bodyMedium(
            context,
            color: isSIP
                ? (isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary)
                : (isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary),
            fontWeight: isSIP ? MyntFonts.semiBold : MyntFonts.regular,
          ),
        ),
      ],
    );
  }

  Widget _buildMandatesSection(bool isDark, MFProvider mfOrder) {
    final hasMandates = mfOrder.mandateData != null && mfOrder.mandateData!.isNotEmpty;
    final selectedAmount = _getSelectedMandateAmount(mfOrder);
    final hasError = !hasMandates || mfOrder.mandateStatus != "APPROVED";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mandates header with amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Mandates",
                  style: MyntWebTextStyles.bodyMedium(
                    context,
                    fontWeight: MyntFonts.medium,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              "Amt: $selectedAmount",
              style: MyntWebTextStyles.bodyMedium(
                context,
                fontWeight: MyntFonts.medium,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Mandate dropdown
        if (hasMandates) ...[
          _buildMandateDropdown(isDark, mfOrder),
        ] else ...[
          // No mandates - show create button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? colors.darkGrey.withOpacity(0.3) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? colors.darkColorDivider : colors.colorDivider,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No mandates available",
                  style: MyntWebTextStyles.para(
                    context,
                    darkColor: MyntColors.textSecondaryDark,
                    lightColor: MyntColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Create mandate link
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => _showCreateMandateDialog(),
            child: Text(
              "+ Create mandate",
              style: MyntWebTextStyles.bodyMedium(
                context,
                fontWeight: MyntFonts.medium,
                color: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary)
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMandateDropdown(bool isDark, MFProvider mfOrder) {
    final selectedMandate = mfOrder.mandateData?.firstWhere(
      (m) => m.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );

    return Column(
      children: [
        // Selected mandate display
        InkWell(
          onTap: () {
            setState(() => _isMandateDropdownOpen = !_isMandateDropdownOpen);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xffB5C0CF).withOpacity(.15)
                  : const Color(0xffF5F7FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? MyntColors.outlinedBorderDark
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMandate?.mandateId ?? "Select mandate",
                  style: MyntWebTextStyles.bodyMedium(
                    context,
                    fontWeight: MyntFonts.medium,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                ),
                Icon(
                  _isMandateDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        // Dropdown list
        if (_isMandateDropdownOpen) ...[
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 350),
            decoration: BoxDecoration(
              color: isDark ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: mfOrder.mandateData!.length,
                itemBuilder: (context, index) {
                  final mandate = mfOrder.mandateData![index];
                  final isSelected = mandate.mandateId == mfOrder.mandateId;
                  final status = mandate.status?.toUpperCase() ?? '';

                  return InkWell(
                    onTap: () {
                      mfOrder.chngMandate(mandate.mandateId ?? '');
                      setState(() => _isMandateDropdownOpen = false);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? MyntColors.primary.withOpacity(0.08) : const Color(0xFFF0F7FF))
                            : (isDark ? colors.darkGrey.withOpacity(0.3) : const Color(0xFFF5F7FA)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? isDark ? MyntColors.primaryDark : MyntColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mandate ID row with status icon and amount
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            "Mandate Id : ${mandate.mandateId}",
                                            style: MyntWebTextStyles.bodySmall(
                                              context,
                                              fontWeight: MyntFonts.semiBold,
                                              darkColor: MyntColors.textPrimaryDark,
                                              lightColor: MyntColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          _getMandateStatusIcon(status),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      double.parse(mandate.amount ?? '0').toStringAsFixed(2),
                                      style: MyntWebTextStyles.bodySmall(
                                        context,
                                        fontWeight: MyntFonts.semiBold,
                                        darkColor: MyntColors.textPrimaryDark,
                                        lightColor: MyntColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Bank name
                                Text(
                                  mandate.bankName ?? "Unknown Bank",
                                  style: MyntWebTextStyles.para(
                                    context,
                                    fontWeight: MyntFonts.medium,
                                    color:  isDark ? MyntColors.primaryDark : MyntColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Status
                                Text(
                                  status,
                                  style: MyntWebTextStyles.para(
                                    context,
                                    darkColor: MyntColors.textSecondaryDark,
                                    lightColor: MyntColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Date
                                Text(
                                  _formatDate(mandate.regnDate ?? ''),
                                  style: MyntWebTextStyles.para(
                                    context,
                                    darkColor: MyntColors.textSecondaryDark,
                                    lightColor: MyntColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check_circle,
                              color: isDark ? MyntColors.primaryDark : MyntColors.primary,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _getMandateStatusIcon(String status) {
    if (status == 'APPROVED') {
      return Icon(Icons.check_circle, size: 16, color: Colors.green.shade600);
    } else if (status == 'REJECTED') {
      return Icon(Icons.cancel, size: 16, color: Colors.red.shade600);
    } else {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz, size: 12, color: Colors.white),
      );
    }
  }

  Widget _buildAmountField(bool isDark, MFProvider mfOrder) {
    final isLumpsum = mfOrder.mfOrderTpye == "One-time";
    final errorText = isLumpsum ? mfOrder.invAmtError : mfOrder.installmentAmtError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLumpsum ? "Investment amount" : "Instalment amount",
          style: MyntWebTextStyles.bodyMedium(
            context,
            fontWeight: MyntFonts.medium,
            darkColor: MyntColors.textSecondaryDark,
            lightColor: MyntColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: TextField(
            controller: isLumpsum ? mfOrder.invAmt : mfOrder.installmentAmt,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
            ),
            onChanged: (value) {
              mfOrder.isValidUpiId(widget.mfData, '');
            },
            decoration: InputDecoration(
              hintText: widget.mfData.minimumPurchaseAmount ?? '500',
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? MyntColors.textSecondaryDark : MyntColors.textSecondary,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Text(
                  "₹",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? MyntColors.textPrimaryDark : MyntColors.textPrimary,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: isDark
                  ? const Color(0xffB5C0CF).withOpacity(.15)
                  : const Color(0xffF1F3F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errorText != null && errorText.isNotEmpty
                      ? (isDark ? MyntColors.lossDark : MyntColors.loss)
                      : (isDark ? MyntColors.outlinedBorderDark : MyntColors.outlinedBorder),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errorText != null && errorText.isNotEmpty
                      ? (isDark ? MyntColors.lossDark : MyntColors.loss)
                      : (isDark ? MyntColors.outlinedBorderDark : MyntColors.outlinedBorder),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),

        // Error message
        if (errorText != null && errorText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorText,
            style: MyntWebTextStyles.para(
              context,
              color: isDark ? MyntColors.lossDark : MyntColors.loss,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSIPDateSelector(bool isDark, MFProvider mfOrder) {
    return Center(
      child: InkWell(
        onTap: () => _showCalendarDialog(context, ref.read(themeProvider), mfOrder),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Monthly on ${mfOrder.dates}${getDateSuffix(int.tryParse(mfOrder.dates) ?? 1)}",
                  style: MyntWebTextStyles.bodyMedium(
                context,
                fontWeight: MyntFonts.medium,
                color: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
              ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: resolveThemeColor(context, dark: MyntColors.primaryDark, light: MyntColors.primary),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(bool isDark, MFProvider mfOrder) {
    final isSIP = mfOrder.mfOrderTpye == "SIP";
    final buttonText = isSIP ? "Place - SIP" : "Pay - One Time";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? MyntColors.overlayBgDark : MyntColors.backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? MyntColors.dividerDark : MyntColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: mfOrder.investloader ? null : () => _handlePayment(mfOrder),
            style: ElevatedButton.styleFrom(
              backgroundColor: resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
              disabledBackgroundColor: resolveThemeColor(context, dark:  MyntColors.secondary.withOpacity(0.5), light: MyntColors.primary.withOpacity(0.5)),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: mfOrder.investloader
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    buttonText,
                    style: MyntWebTextStyles.bodySmall(
                      context,
                      fontWeight: MyntFonts.semiBold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showCreateMandateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width >= 1100
                ? MediaQuery.of(context).size.width * 0.25
                : MediaQuery.of(context).size.width * 0.9,
            child: const CreateMandateDialogue(),
          ),
        );
      },
    );
  }

  void _switchOrderType(String orderType, MFProvider mfOrder) {
    // Pre-fill amount based on order type
    if (orderType == "One-time") {
      String amt = widget.mfData.minimumPurchaseAmount ?? "0";
      mfOrder.invAmt.text = amt.split('.').first;
    } else {
      String amt = widget.mfData.minimumPurchaseAmount ?? "0";
      mfOrder.installmentAmt.text = amt.split('.').first;
    }

    // Just switch the order type - data was already loaded in initState
    mfOrder.chngOrderType(orderType);
    mfOrder.orderchangetitle(orderType);

    if (mfOrder.orderpagetitle != "NFO") {
      mfOrder.orderpagetite("SDS");
    }
  }

  void _handlePayment(MFProvider mfOrder) async {
    if (mfOrder.investloader) return;

    final isLumpsum = mfOrder.mfOrderTpye == "One-time";

    if (isLumpsum && mfOrder.invAmtError == "") {
      Navigator.pop(context);

      final startTime = DateTime.now();

      showDialog(
        context: context,
        barrierDismissible: mfOrder.ispaymentcalled != true,
        builder: (context) => WillPopScope(
          onWillPop: () async => mfOrder.ispaymentcalled != true,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width >= 1100
                  ? MediaQuery.of(context).size.width * 0.30
                  : MediaQuery.of(context).size.width >= 800
                      ? MediaQuery.of(context).size.width * 0.50
                      : MediaQuery.of(context).size.width * 0.90,
              child: MfOrderBottomsheetWeb(
                data: widget.mfData,
                condval: 'reinit',
              ),
            ),
          ),
        ),
      );

      await mfPlaceorder(widget.mfData, mfOrder, context);

      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < const Duration(seconds: 2)) {
        final remaining = const Duration(seconds: 2) - elapsed;
        await Future.delayed(remaining);
      }

      if (!mfOrder.investloader) {
        if (mfOrder.mfPlaceOrderResponces == null &&
            mfOrder.mfPlaceOrderResponces?.stat != 'Ok') {
          warningMessage(context, "${mfOrder.mfPlaceOrderResponces?.remarks}");
        }
      }
    } else if (!isLumpsum && mfOrder.installmentAmtError == "") {
      // SIP order - validate mandate and place order directly
      if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
        warningMessage(context, "Please create a mandate to proceed with SIP.");
        return;
      }

      if (mfOrder.mandateStatus != "APPROVED") {
        warningMessage(context, "Please select an approved mandate to proceed with SIP.");
        return;
      }

      // Close the order dialog
      Navigator.pop(context);

      // Place SIP order directly
      final schemeCode = widget.mfData.schemeCode ?? '';
      await mfOrder.fetchXsipPlaceOrder(
        context,
        "${double.parse(mfOrder.installmentAmt.text).toInt() >= 200000 ? "$schemeCode-L1" : schemeCode}",
        mfOrder.freqName == "Daily" ? "0" : mfOrder.dates,
        mfOrder.freqName,
        mfOrder.installmentAmt.text,
        mfOrder.invDuration.text,
        mfOrder.freqName == "Daily" ? "0" : mfOrder.endDate,
        mfOrder.mandateId,
      );

      // Show response dialog
      if (mfOrder.xsipOrderResponces?.stat == "Ok" ||
          mfOrder.xsipOrderResponces?.stat == "Not_Ok") {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width >= 1100
                  ? MediaQuery.of(context).size.width * 0.30
                  : MediaQuery.of(context).size.width >= 800
                      ? MediaQuery.of(context).size.width * 0.50
                      : 420,
              child: MfPaymentRespAlert(
                upiData: mfOrder.xsipOrderResponces?.toJson(),
                conditionval: '',
              ),
            ),
          ),
        );
      }
    } else {
      if (isLumpsum) {
        warningMessage(context, "Enter a valid investment amount.");
      } else {
        warningMessage(context, "Enter a valid installment amount.");
      }
    }
  }

  String _getFundName(MFProvider mfOrder) {
    if (mfOrder.orderpagetitle == "SDS" && mfOrder.factSheetDataModel?.data?.name != null) {
      return mfOrder.factSheetDataModel!.data!.name!
          .replaceAll(RegExp(r'(Reg \(G\)|\(G\))$'), ' ');
    } else if (mfOrder.orderpagetitle == "NFO") {
      return widget.mfData.name ?? '';
    }
    return widget.mfData.fSchemeName ?? widget.mfData.schemeName ?? 'Unknown Fund';
  }

  String _getSelectedMandateAmount(MFProvider mfOrder) {
    if (mfOrder.mandateData == null || mfOrder.mandateData!.isEmpty) {
      return "0.00";
    }
    final selectedMandate = mfOrder.mandateData!.firstWhere(
      (mandate) => mandate.mandateId == mfOrder.mandateId,
      orElse: () => mfOrder.mandateData!.first,
    );
    return double.parse(selectedMandate.amount ?? "0").toStringAsFixed(2);
  }
}

mfPlaceorder(
  MutualFundList mfData,
  MFProvider mfOrder,
  BuildContext context,
) {
  final schemeCode = mfData.schemeCode ?? '';
  MfPlaceOrderInput input = MfPlaceOrderInput(
    transcode: "NEW",
    schemecode: (double.tryParse(mfOrder.installmentAmt.text.trim()) ?? 0) >= 200000
        ? "$schemeCode-L1"
        : schemeCode,
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

  mfOrder.placeordermftemp(
    context,
    mfOrder.upiId.text,
    input,
    (double.tryParse(mfOrder.invAmt.text.trim()) ?? 0) >= 200000
        ? "$schemeCode-L1"
        : schemeCode,
    double.parse(mfOrder.mfOrderTpye == "One-time"
        ? mfOrder.invAmt.text
        : mfOrder.installmentAmt.text),
  );

  print("object $input");
}

_showBottomSheet(BuildContext context, Widget bottomSheet) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width >= 1100
            ? MediaQuery.of(context).size.width * 0.25
            : MediaQuery.of(context).size.width * 0.90,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: bottomSheet,
      ),
    ),
  );
}

void _showCalendarDialog(
    BuildContext context, dynamic theme, MFProvider mfOrder) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;

      // Responsive width
      final double dialogWidth;
      if (screenWidth >= 1100) {
        dialogWidth = 380;
      } else if (screenWidth >= 600) {
        dialogWidth = 360;
      } else {
        dialogWidth = screenWidth * 0.85;
      }

      // Responsive calendar height
      final double calendarHeight = screenWidth < 400 ? 280 : 320;

      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: screenWidth < 400 ? 12 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
          ),
          width: dialogWidth,
          padding: EdgeInsets.all(screenWidth < 400 ? 12.0 : 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  TextWidget.titleText(
                    text: "Select SIP Installment Date",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: calendarHeight,
                child: _SIPCalendar(
                  theme: theme,
                  mfOrder: mfOrder,
                  onConfirm: (int selectedDay) {
                    mfOrder.changeStartDate(selectedDay.toString());
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SIPCalendar extends StatefulWidget {
  final dynamic theme;
  final MFProvider mfOrder;
  final ValueChanged<int> onConfirm;

  const _SIPCalendar({
    required this.theme,
    required this.mfOrder,
    required this.onConfirm,
  });

  @override
  State<_SIPCalendar> createState() => _SIPCalendarState();
}

class _SIPCalendarState extends State<_SIPCalendar> {
  int? selectedDate;

  @override
  void initState() {
    super.initState();
    int? initialDate = int.tryParse(widget.mfOrder.dates);

    if (initialDate != null &&
        widget.mfOrder.dateList.contains(initialDate.toString())) {
      selectedDate = initialDate;
    } else if (widget.mfOrder.dateList.isNotEmpty) {
      selectedDate = int.tryParse(widget.mfOrder.dateList.first);
    } else {
      selectedDate = 1;
    }
  }

  bool isDateAvailable(int day) {
    return widget.mfOrder.dateList.contains(day.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 4,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              return _buildDayBox(context, day);
            },
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xffF1F3F8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            TextWidget.captionText(
              text: "Available",
              theme: widget.theme.isDarkMode,
              color: widget.theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            TextWidget.captionText(
              text: "Unavailable",
              theme: widget.theme.isDarkMode,
              color: widget.theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedDate != null
                ? () {
                    widget.onConfirm(selectedDate!);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(0, 45),
              backgroundColor: resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: TextWidget.subText(
              text: "Confirm",
              theme: widget.theme.isDarkMode,
              color: colors.colorWhite,
              fw: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayBox(BuildContext context, int day) {
    final bool isAvailable = isDateAvailable(day);
    final bool isSelected = selectedDate == day;

    Color bgColor;
    Color textColor;

    if (!isAvailable) {
      bgColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFFBDBDBD);
    } else if (isSelected) {
      bgColor = resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary);
      textColor = colors.colorWhite;
    } else {
      bgColor = const Color(0xffF1F3F8);
      textColor = colors.colorBlack;
    }

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                selectedDate = day;
              });
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: TextWidget.paraText(
              text: day.toString(),
              color: textColor,
              theme: widget.theme.isDarkMode,
              fw: 0,
            ),
          ),
        ),
      ),
    );
  }
}

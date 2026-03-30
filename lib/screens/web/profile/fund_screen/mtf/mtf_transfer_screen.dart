import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../sharedWidget/common_buttons_web.dart';
import '../../../../../sharedWidget/common_text_fields_web.dart';
import '../../../../../sharedWidget/functions.dart';

class MtfTransferScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const MtfTransferScreen({super.key, this.onBack});

  @override
  ConsumerState<MtfTransferScreen> createState() => _MtfTransferScreenState();
}

class _MtfTransferScreenState extends ConsumerState<MtfTransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isInitialized = false;
  String _errorText = "";
  bool _disable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    final fund = ref.read(transcationProvider);
    await fund.fetchc(context);
    fund.checkMtfStatus();
    if (fund.mtfActive == true) {
      await fund.fetchMtfLimits();
    }
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fund = ref.watch(transcationProvider);

    if (!_isInitialized || fund.mtfLoading) {
      return Scaffold(
        backgroundColor: resolveThemeColor(
          context,
          dark: MyntColors.backgroundColorDark,
          light: MyntColors.backgroundColor,
        ),
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      appBar: _buildAppBar(context),
      body: fund.mtfActive == true
          ? _buildTransferBody(context, fund)
          : _buildMtfNotActive(context, fund),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      leadingWidth: 48,
      titleSpacing: 6,
      backgroundColor: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          size: 18,
          color: resolveThemeColor(
            context,
            dark: MyntColors.textSecondaryDark,
            light: MyntColors.textSecondary,
          ),
        ),
        onPressed: widget.onBack ?? () => Navigator.pop(context),
      ),
      title: Text(
        'Transfer to MTF',
        style: MyntWebTextStyles.title(
          context,
          color: resolveThemeColor(
            context,
            dark: MyntColors.textPrimaryDark,
            light: MyntColors.textPrimary,
          ),
          fontWeight: MyntFonts.semiBold,
        ),
      ),
    );
  }

  Widget _buildMtfNotActive(BuildContext context, TranctionProvider fund) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            dark: const Color(0xFF2D1111),
            light: const Color(0xFFFFEBEE),
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: resolveThemeColor(
              context,
              dark: MyntColors.errorDark,
              light: MyntColors.error,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: resolveThemeColor(
                context,
                dark: MyntColors.errorDark,
                light: MyntColors.error,
              ),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "MTF (Margin Trading Facility) is not active on your account. ",
                      style: MyntWebTextStyles.body(
                        context,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary,
                        ),
                        fontWeight: MyntFonts.regular,
                      ),
                    ),
                    TextSpan(
                      text: "Click here to activate",
                      style: MyntWebTextStyles.body(
                        context,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.primaryDark,
                          light: MyntColors.primary,
                        ),
                        fontWeight: MyntFonts.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferBody(BuildContext context, TranctionProvider fund) {
    final clientName =
        fund.decryptclientcheck?.clientCheck?.dATA?[fund.indexss][2] ?? '';
    final clientCode =
        fund.decryptclientcheck?.clientCheck?.dATA?[fund.indexss][0] ?? '';

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left col: Transfer form
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client info
                  Row(
                    children: [
                      Text(
                        "Fund Transfer to MTF ",
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary,
                          ),
                          fontWeight: MyntFonts.regular,
                        ),
                      ),
                      Text(
                        clientName,
                        style: MyntWebTextStyles.bodySmall(
                          context,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textPrimaryDark,
                            light: MyntColors.textPrimary,
                          ),
                          fontWeight: MyntFonts.medium,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.listItemBgDark,
                            light: MyntColors.listItemBg,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          clientCode,
                          style: MyntWebTextStyles.caption(
                            context,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.textPrimaryDark,
                              light: MyntColors.textPrimary,
                            ),
                            fontWeight: MyntFonts.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount input
                  MyntTextField(
                    controller: _amountController,
                    placeholder: "0",
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textStyle: MyntWebTextStyles.title(
                      context,
                      color: resolveThemeColor(
                        context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary,
                      ),
                      fontWeight: MyntFonts.medium,
                    ),
                    leadingWidget: SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          "₹",
                          style: MyntWebTextStyles.title(
                            context,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.textSecondaryDark,
                              light: MyntColors.textSecondary,
                            ),
                            fontWeight: MyntFonts.medium,
                          ),
                        ),
                      ),
                    ),
                    height: 46,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _disable = true;
                          _errorText = "";
                        } else {
                          final entered = int.tryParse(value) ?? 0;
                          final maxCash = double.tryParse(
                                  fund.mtfLimits?.cash ?? '0') ??
                              0;
                          if (entered <= 0) {
                            _disable = true;
                            _errorText = "Amount must be greater than 0";
                          } else if (entered > maxCash) {
                            _disable = true;
                            _errorText =
                                "Amount cannot exceed available cash ₹${maxCash.toStringAsFixed(2)}";
                          } else {
                            _disable = false;
                            _errorText = "";
                          }
                        }
                      });
                    },
                  ),
                  if (_errorText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _errorText,
                      style: MyntWebTextStyles.para(
                        context,
                        color: resolveThemeColor(
                          context,
                          dark: MyntColors.errorDark,
                          light: MyntColors.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Total Amount and MTF Amount row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Amount",
                            style: MyntWebTextStyles.para(
                              context,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary,
                              ),
                              fontWeight: MyntFonts.regular,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getFormatter(
                              value: fund.mtfTotalAmount,
                              v4d: false,
                              noDecimal: false,
                            ),
                            style: MyntWebTextStyles.body(
                              context,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary,
                              ),
                              fontWeight: MyntFonts.semiBold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "MTF Amount",
                            style: MyntWebTextStyles.para(
                              context,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.textSecondaryDark,
                                light: MyntColors.textSecondary,
                              ),
                              fontWeight: MyntFonts.regular,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getFormatter(
                              value: fund.mtfAmount,
                              v4d: false,
                              noDecimal: false,
                            ),
                            style: MyntWebTextStyles.body(
                              context,
                              color: resolveThemeColor(
                                context,
                                dark: MyntColors.textPrimaryDark,
                                light: MyntColors.textPrimary,
                              ),
                              fontWeight: MyntFonts.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Transfer button
                  MyntPrimaryButton(
                    label: "Transfer",
                    isFullWidth: true,
                    isLoading: fund.mtfTransferLoading,
                    onPressed: _disable
                        ? () {
                            if (_amountController.text.isEmpty) {
                              showResponsiveWarningMessage(
                                  context, "Please enter amount");
                            } else {
                              showResponsiveWarningMessage(
                                  context, _errorText.isNotEmpty ? _errorText : "Please enter a valid amount");
                            }
                          }
                        : () async {
                            final amount = _amountController.text;
                            final result =
                                await fund.submitMtfTransfer(amount);
                            if (!mounted) return;
                            if (result?.pymtStatus == 'OK') {
                              _amountController.clear();
                              setState(() {
                                _disable = true;
                                _errorText = "";
                              });
                              showResponsiveSuccess(
                                  context, "Fund Transfer Successful");
                            } else if (result?.pymtStatus == 'NOT_OK') {
                              showResponsiveWarningMessage(
                                  context, result?.emsg ?? "Transfer failed");
                            } else {
                              showResponsiveWarningMessage(
                                  context, "Transfer failed. Please try again.");
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right col: empty spacer to match withdraw layout
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

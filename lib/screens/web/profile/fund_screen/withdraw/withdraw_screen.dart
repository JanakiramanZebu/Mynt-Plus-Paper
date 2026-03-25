import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../../../res/mynt_web_color_styles.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../sharedWidget/common_buttons_web.dart';
import '../../../../../sharedWidget/common_text_fields_web.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  final TranctionProvider withdarw;
  final FocusNode foucs;
  final ThemesProvider theme;
  final String segment;
  final VoidCallback? onBack;
  const WithdrawScreen({
    super.key,
    required this.withdarw,
    required this.foucs,
    required this.theme,
    required this.segment,
    this.onBack,
  });

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  String withdarwerror = "";
  late bool _isVisible;
  bool disable = false;
  bool isBreakUpExpanded = false;
  bool _withdrawLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    widget.withdarw.withdrawamount.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreenData();
    });
  }

  void _initializeScreenData() {
    final fund = ref.read(transcationProvider);
    if (fund.bankdetails?.dATA != null &&
        fund.bankdetails!.dATA!.isNotEmpty &&
        fund.decryptclientcheck != null &&
        fund.payoutdetails != null) {
      fund.initialdata(context);
      _isVisible = fund.withdrawstatus != null &&
          fund.withdrawstatus!.isNotEmpty &&
          fund.withdrawstatus![0].msg != "no data found";
      disable = (widget.withdarw.withdrawamount.text.isEmpty ||
          widget.withdarw.payoutdetails?.withdrawAmount == "0.00");
      widget.foucs.requestFocus();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _initializeScreenData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fund = ref.watch(transcationProvider);

    // Loading state
    if (!_isInitialized ||
        fund.bankdetails == null ||
        fund.decryptclientcheck == null ||
        fund.payoutdetails == null) {
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
      body: GestureDetector(
        onTap: () => widget.foucs.unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left col: Withdraw form
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWithdrawableHeader(context),
                      const SizedBox(height: 15),
                      _buildAmountInput(context),
                      const SizedBox(height: 4),
                      if (withdarwerror.isNotEmpty)
                        Text(
                          withdarwerror,
                          style: MyntWebTextStyles.para(
                            context,
                            color: resolveThemeColor(
                              context,
                              dark: MyntColors.errorDark,
                              light: MyntColors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildWithdrawButton(context),
                      const SizedBox(height: 20),
                      if (_isVisible) _buildOpenRequest(context),
                      if (_isVisible) const SizedBox(height: 16),
                      _buildInfoAlert(context),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right col: Break up
                Expanded(
                  child: _buildBreakUpCard(context),
                ),
              ],
            ),
          ),
        ),
      ),
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
        'Withdraw Fund',
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

  Widget _buildWithdrawableHeader(BuildContext context) {
    final withdrawAmount =
        widget.withdarw.payoutdetails!.withdrawAmount ?? "0.00";
    final hasAmount = double.tryParse(withdrawAmount) != null &&
        double.parse(withdrawAmount) > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Withdrawable Amount",
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
              const SizedBox(height: 7),
              Text(
                "₹ $withdrawAmount",
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
            ],
          ),
        ),
        if (hasAmount)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              setState(() {
                widget.withdarw.withdrawamount.text = withdrawAmount;
                widget.withdarw.withdrawamount.selection =
                    TextSelection.fromPosition(
                  TextPosition(
                      offset: widget.withdarw.withdrawamount.text.length),
                );
                disable = false;
                withdarwerror = "";
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark.withOpacity(0.1),
                  light: MyntColors.primary.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Withdraw All",
                style: MyntWebTextStyles.bodySmall(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary,
                  ),
                  fontWeight: MyntFonts.semiBold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    return MyntTextField(
      controller: widget.withdarw.withdrawamount,
      focusNode: widget.foucs,
      placeholder: "Enter amount",
      enabled:
          widget.withdarw.payoutdetails!.withdrawAmount != '0.00',
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        FilteringTextInputFormatter.deny(RegExp(r'^0$')),
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
          if (value.isNotEmpty) {
            double enteredAmount = double.tryParse(value) ?? 0;
            double availableAmount = double.parse(
                widget.withdarw.payoutdetails!.withdrawAmount.toString());
            if (enteredAmount <= 0) {
              disable = true;
              withdarwerror = "Amount must be greater than 0";
            } else if (enteredAmount > availableAmount) {
              disable = true;
              withdarwerror = "Insufficient fund";
            } else {
              disable = false;
              withdarwerror = "";
            }
          } else {
            disable = true;
            withdarwerror = "";
          }
        });
      },
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    return MyntPrimaryButton(
      label: "Withdraw",
      isFullWidth: true,
      isLoading: _withdrawLoading,
      onPressed: disable
          ? () {
              if (widget.withdarw.payoutdetails!.withdrawAmount == "0.00") {
                showResponsiveWarningMessage(context, "Insufficient fund");
              } else if (widget.withdarw.withdrawamount.text.isEmpty) {
                showResponsiveWarningMessage(
                    context, "Please enter the amount");
              } else if (double.tryParse(
                          widget.withdarw.withdrawamount.text) !=
                      null &&
                  double.parse(widget.withdarw.withdrawamount.text) <= 0) {
                showResponsiveWarningMessage(
                    context, "Amount must be greater than 0");
              } else {
                showResponsiveWarningMessage(
                    context, "Please enter a valid amount");
              }
            }
          : () async {
              setState(() => _withdrawLoading = true);
              await widget.withdarw.fetchPaymentWithDraw(
                widget.withdarw.ipAddress,
                widget.withdarw.withdrawamount.text,
                widget.segment,
                context,
              );
              _isVisible = false;
              widget.withdarw.focusNode.unfocus();
              widget.withdarw.withdrawamount.clear();
              setState(() {
                disable = true;
                withdarwerror = "";
                _withdrawLoading = false;
              });
              showUIWithDelay();
            },
    );
  }

  Widget _buildBreakUpCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: resolveThemeColor(
            context,
            dark: MyntColors.cardBorderDark,
            light: MyntColors.cardBorder,
          ),
        ),
        color: resolveThemeColor(
          context,
          dark: MyntColors.cardDark,
          light: MyntColors.card,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              "Withdraw Summary",
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
          ),
          Divider(
            height: 1,
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
          _buildBreakUpContent(context),
        ],
      ),
    );
  }

  Widget _buildBreakUpContent(BuildContext context) {
    final payout = widget.withdarw.payoutdetails!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _dataRow(context, "Available Cash", payout.totalLedger ?? "0.00"),
          if (double.tryParse(payout.brkcollamt ?? '0') != null &&
              double.parse(payout.brkcollamt ?? '0') > 0)
            _dataRow(
                context, "Collateral Value", payout.brkcollamt ?? "0.00"),
          if (double.tryParse(payout.fD ?? '0') != null &&
              double.parse(payout.fD ?? '0') > 0)
            _dataRow(context, "Fixed Deposit", payout.fD ?? "0.00"),
          _dataRow(context, "Margin Used", payout.margin ?? "0.00"),
          _dataRow(
              context, "Withdrawable Amount", payout.withdrawAmount ?? "0.00",
              isLast: true),
        ],
      ),
    );
  }

  Widget _dataRow(BuildContext context, String label, String value,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: MyntWebTextStyles.body(
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
                "₹ $value",
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
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
      ],
    );
  }

  Widget _buildOpenRequest(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Open Request",
          style: MyntWebTextStyles.bodySmall(
            context,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textPrimaryDark,
              light: MyntColors.textPrimary,
            ),
            fontWeight: MyntFonts.semiBold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              dark: const Color(0xFF2D2200),
              light: const Color(0xFFFFF3E0),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.av_timer,
                color: Color(0xFFFB8C00),
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹ ${widget.withdarw.withdrawstatus?[0].dUEAMT}",
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
                    const SizedBox(height: 4),
                    Text(
                      "Request on : ${widget.withdarw.withdrawstatus?[0].eNTRYTIME}",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: resolveThemeColor(
          context,
          dark: const Color(0xFF2D2200),
          light: const Color(0xFFFFF3E0),
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: const Color(0xFFFB8C00),
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFFB8C00),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Payout requests submitted before 8:30 AM on any working day will be processed on the same day. Requests received after 8:30 AM will be processed on the next working day. Please note that in case of multiple payout requests, the latest request received will be considered for processing.",
              style: MyntWebTextStyles.para(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textSecondaryDark,
                  light: const Color(0xFF333333),
                ),
                fontWeight: MyntFonts.regular,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showUIWithDelay() {
    Future.delayed(Duration.zero, () {
      setState(() {
        _isVisible = true;
      });
    });
  }
}

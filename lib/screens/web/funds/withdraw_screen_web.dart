import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/res/global_font_web.dart';

import '../../../provider/thems.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart' hide WebTextStyles;
import '../../../sharedWidget/snack_bar.dart';
import '../../../sharedWidget/mynt_loader.dart';

class WithdrawScreenWeb extends ConsumerStatefulWidget {
  final TranctionProvider withdarw;
  final FocusNode foucs;
  final ThemesProvider theme;
  final String segment;

  const WithdrawScreenWeb({
    super.key,
    required this.withdarw,
    required this.foucs,
    required this.theme,
    required this.segment,
  });

  @override
  ConsumerState<WithdrawScreenWeb> createState() => _WithdrawScreenWebState();
}

class _WithdrawScreenWebState extends ConsumerState<WithdrawScreenWeb> {
  String withdarwerror = "";
  late bool _isVisible;
  bool disable = false;
  bool isBreakUpExpanded = false;
  bool _withdrawLoading = false;

  @override
  void initState() {
    super.initState();
    ref.read(transcationProvider).initialdata(context);
    ref.read(transcationProvider).withdrawstatus![0].msg == "no data found"
        ? _isVisible = false
        : _isVisible = true;

    // Clear the text field when screen is initialized
    widget.withdarw.withdrawamount.clear();

    disable = (widget.withdarw.withdrawamount.text.isEmpty ||
        widget.withdarw.payoutdetails!.withdrawAmount == "0.00");
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(transcationProvider);
    final funds = ref.watch(fundProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Withdrawable Amount
                    _buildWithdrawableAmountHeader(funds, theme),
                    const SizedBox(height: 16),

                    // Amount Input
                    _buildAmountInput(theme, fund),
                    const SizedBox(height: 8),

                    // Error Message
                    if (withdarwerror.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          withdarwerror,
                          style: WebTextStyles.caption(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.error
                                : WebColors.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Withdraw Button
                    _buildWithdrawButton(theme, fund),
                    const SizedBox(height: 16),

                    // Breakup Section
                    _buildBreakUpSection(theme, funds),

                    // Open Request Section
                    if (_isVisible == true) ...[
                      const SizedBox(height: 16),
                      _buildOpenRequestSection(theme, fund),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Withdraw Fund',
            style: WebTextStyles.dialogTitle(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(.15)
                  : Colors.black.withOpacity(.15),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(.08)
                  : Colors.black.withOpacity(.08),
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.isDarkMode
                      ? WebDarkColors.iconSecondary
                      : WebColors.iconSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawableAmountHeader(dynamic funds, ThemesProvider theme) {
    return Row(
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          color: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Withdrawable Amount",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹ ${widget.withdarw.payoutdetails!.withdrawAmount}",
                style: WebTextStyles.title(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                  fontWeight: WebFonts.semiBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(ThemesProvider theme, dynamic fund) {
    return TextFormField(
      enabled: widget.withdarw.payoutdetails!.withdrawAmount == '0.00'
          ? false
          : true,
      focusNode: widget.foucs,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        FilteringTextInputFormatter.deny(RegExp(r'^0$')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: WebTextStyles.custom(
        fontSize: 20,
        isDarkTheme: theme.isDarkMode,
        color: theme.isDarkMode
            ? WebDarkColors.textPrimary
            : WebColors.textPrimary,
      ),
      controller: widget.withdarw.withdrawamount,
      onChanged: (value) {
        setState(() {
          if (widget.withdarw.withdrawamount.text.isNotEmpty) {
            double enteredAmount =
                double.parse(widget.withdarw.withdrawamount.text);
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
          } else if (widget.withdarw.withdrawamount.text.isEmpty ||
              widget.withdarw.payoutdetails!.withdrawAmount == "0.00") {
            disable = true;
            withdarwerror = "";
          } else {
            disable = false;
            withdarwerror = "";
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
            ),
            borderRadius: BorderRadius.circular(5)),
        disabledBorder: InputBorder.none,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
            ),
            borderRadius: BorderRadius.circular(5)),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5)),
        fillColor: widget.theme.isDarkMode
            ? WebDarkColors.surfaceVariant
            : WebColors.backgroundTertiary,
        filled: true,
        hintText: "0",
        hintStyle: WebTextStyles.custom(
          fontSize: 20,
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            assets.ruppeIcon,
            color: widget.theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawButton(ThemesProvider theme, dynamic fund) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 48),
          backgroundColor: disable
              ? colors.darkGrey
              : widget.theme.isDarkMode
                  ? colors.primaryDark
                  : colors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: (disable)
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
                setState(() {
                  _withdrawLoading = true;
                });
                await widget.withdarw.fetchPaymentWithDraw(
                    widget.withdarw.ipAddress,
                    widget.withdarw.withdrawamount.text,
                    widget.segment,
                    context);
                _isVisible = false;
                widget.withdarw.focusNode.unfocus();
                widget.withdarw.withdrawamount.clear();
                setState(() {
                  disable = true;
                  withdarwerror = "";
                });

                showUIWithDelay();
                setState(() {
                  _withdrawLoading = false;
                });
              },
        child: _withdrawLoading
            ? MyntLoader.inline(
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                strokeWidth: 2.0,
              )
            : Text(
                'Withdraw',
                style: WebTextStyles.buttonMd(
                  isDarkTheme: theme.isDarkMode,
                  color: disable ? colors.colorGrey : colors.colorWhite,
                ),
              ),
      ),
    );
  }

  Widget _buildBreakUpSection(ThemesProvider theme, dynamic funds) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isBreakUpExpanded = !isBreakUpExpanded;
            });
          },
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(.15)
              : Colors.black.withOpacity(.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(.08)
              : Colors.black.withOpacity(.08),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? WebDarkColors.textSecondary.withOpacity(0.1)
                  : WebColors.backgroundTertiary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  assets.breakup,
                  width: 14,
                  height: 14,
                  color: theme.isDarkMode
                      ? WebDarkColors.primaryDark
                      : WebColors.primaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  "Break up",
                  style: WebTextStyles.sub(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                    fontWeight: WebFonts.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isBreakUpExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: theme.isDarkMode
                      ? WebDarkColors.primaryDark
                      : WebColors.primaryLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expandable break up content
        if (isBreakUpExpanded) ...[
          const SizedBox(height: 16),
          _buildBreakUpContent(theme, funds),
        ],
      ],
    );
  }

  Widget _buildBreakUpContent(ThemesProvider theme, dynamic funds) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreakUpInfoRow(
                    "Available Capital",
                    "${funds.fundDetailModel?.totCredit ?? "0.00"}",
                    theme,
                  ),
                  _buildBreakUpInfoRow(
                    "Margin Used",
                    "${funds.fundDetailModel?.utilizedMrgn ?? "0.00"}",
                    theme,
                  ),
                ],
              ),
            ),
            // Vertical divider
            Container(
              width: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color:
                  theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
            ),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreakUpInfoRow(
                    "Withdrawable Amount",
                    "${widget.withdarw.payoutdetails!.withdrawAmount}",
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakUpInfoRow(
      String title, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: WebTextStyles.dialogContent(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? WebDarkColors.textPrimary
                  : WebColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenRequestSection(ThemesProvider theme, dynamic fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Open Request",
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textPrimary
                : WebColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary.withOpacity(0.3)
                : WebColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            minLeadingWidth: 10,
            leading: Icon(
              Icons.timer_outlined,
              color:
                  theme.isDarkMode ? WebDarkColors.warning : WebColors.warning,
            ),
            title: Text(
              "₹ ${widget.withdarw.withdrawstatus?[0].dUEAMT}",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
                fontWeight: WebFonts.semiBold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Request on : ",
                    style: WebTextStyles.para(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.withdarw.withdrawstatus?[0].eNTRYTIME}",
                    style: WebTextStyles.para(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textSecondary
                          : WebColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  showUIWithDelay() {
    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        _isVisible = true;
      });
    });
  }
}

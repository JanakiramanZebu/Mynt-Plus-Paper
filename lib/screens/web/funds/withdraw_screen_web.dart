import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../provider/thems.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/snack_bar.dart';

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
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Withdrawable Amount
                    _buildWithdrawableAmountHeader(funds, theme),
                    const SizedBox(height: 24),
                    
                    // Amount Input
                    _buildAmountInput(theme, fund),
                    const SizedBox(height: 8),
                    
                    // Error Message
                    if (withdarwerror.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextWidget.captionText(
                          text: withdarwerror,
                          theme: false,
                          color: colors.error,
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Withdraw Button
                    _buildWithdrawButton(theme, fund),
                    const SizedBox(height: 24),
                    
                    // Breakup Section
                    _buildBreakUpSection(theme, funds),
                    
                    // Open Request Section
                    if (_isVisible == true) ...[
                      const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.titleText(
            text: 'Withdraw Fund',
            color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
            theme: theme.isDarkMode,
            fw: 1,
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawableAmountHeader(dynamic funds, ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode 
            ? colors.textSecondaryDark.withOpacity(0.1) 
            : colors.kColorLightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.captionText(
                  text: "Withdrawable Amount",
                  theme: false,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 0,
                ),
                const SizedBox(height: 4),
                TextWidget.titleText(
                  text: "₹ ${widget.withdarw.payoutdetails!.withdrawAmount}",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 2,
                ),
              ],
            ),
          ),
        ],
      ),
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
      style: TextWidget.textStyle(
        theme: widget.theme.isDarkMode,
        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
        fontSize: 25,
      ),
      controller: widget.withdarw.withdrawamount,
      onChanged: (value) {
        setState(() {
          if (widget.withdarw.withdrawamount.text.isNotEmpty) {
            double enteredAmount = double.parse(
                widget.withdarw.withdrawamount.text);
            double availableAmount = double.parse(widget
                .withdarw.payoutdetails!.withdrawAmount
                .toString());

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
          } else if (widget
                  .withdarw.withdrawamount.text.isEmpty ||
              widget.withdarw.payoutdetails!.withdrawAmount ==
                  "0.00") {
            disable = true;
            withdarwerror = "";
          } else {
            disable = false;
            withdarwerror = "";
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
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
        fillColor: widget.theme.isDarkMode
            ? colors.darkGrey
            : const Color(0xffF1F3F8),
        filled: true,
        hintText: "0",
        hintStyle: TextWidget.textStyle(
          theme: false,
          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          fontSize: 25,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            assets.ruppeIcon,
            color: widget.theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
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
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: (disable)
            ? () {
                if (widget.withdarw.payoutdetails!.withdrawAmount ==
                    "0.00") {
                  showResponsiveWarningMessage(context, "Insufficient fund");
                } else if (widget
                    .withdarw.withdrawamount.text.isEmpty) {
                  showResponsiveWarningMessage(context, "Please enter the amount");
                } else if (double.tryParse(
                            widget.withdarw.withdrawamount.text) !=
                        null &&
                    double.parse(
                            widget.withdarw.withdrawamount.text) <=
                        0) {
                  showResponsiveWarningMessage(context,
                      "Amount must be greater than 0");
                } else {
                  showResponsiveWarningMessage(context, "Please enter a valid amount");
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
            ? SizedBox(
                width: 18,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.colorWhite),
              )
            : TextWidget.titleText(
                text: 'Withdraw',
                theme: false,
                color: disable ? colors.colorGrey : colors.colorWhite,
                fw: disable ? 0 : 2),
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
              ? colors.splashColorDark
              : colors.splashColorLight,
          highlightColor: theme.isDarkMode
              ? colors.highlightDark
              : colors.highlightLight,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.1)
                  : colors.kColorLightGrey.withOpacity(0.5),
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
                  color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                ),
                const SizedBox(width: 6),
                TextWidget.subText(
                  text: "Break up",
                  theme: false,
                  color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  fw: 2,
                ),
                const SizedBox(width: 4),
                Icon(
                  isBreakUpExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.textSecondaryDark.withOpacity(0.1)
            : colors.kColorLightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: Column(
        children: [
          _buildBreakUpRow(
            "Available Capital",
            "${funds.fundDetailModel?.totCredit ?? "0.00"}",
            theme,
          ),
          _buildBreakUpRow(
            "Margin Used",
            "${funds.fundDetailModel?.utilizedMrgn ?? "0.00"}",
            theme,
          ),
          _buildBreakUpRow(
            "Withdrawable Amount",
            "${widget.withdarw.payoutdetails!.withdrawAmount}",
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakUpRow(String label, String value, ThemesProvider theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: label,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
            ),
            TextWidget.subText(
              text: value,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0.5,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }

  Widget _buildOpenRequestSection(ThemesProvider theme, dynamic fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: "Open Request",
          theme: false,
          color: widget.theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 0
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.3) : colors.searchBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            minLeadingWidth: 10,
            leading: const Icon(
              Icons.timer_outlined,
              color: Color(0xfffb8c00),
            ),
            title: TextWidget.titleText(
              text: "₹ ${widget.withdarw.withdrawstatus?[0].dUEAMT}",
              theme: false,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 1
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.paraText(
                    text: "Request on : ",
                    theme: false,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                  const SizedBox(height: 4),
                  TextWidget.paraText(
                    text: "${widget.withdarw.withdrawstatus?[0].eNTRYTIME}",
                    theme: false,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
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



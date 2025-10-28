import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/screens/Mobile/profile_screen/fund_screen/razorpay/razorpay_failed_ui.dart';
import 'package:mynt_plus/screens/Mobile/profile_screen/fund_screen/razorpay/razorpay_success_ui.dart';
import 'package:mynt_plus/screens/Mobile/profile_screen/fund_screen/upi_id_screens/upi_id_cancel_alert.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../provider/fund_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/fund_function.dart';
import '../../../utils/no_emoji_inputformatter.dart';


class FundScreenWeb extends ConsumerStatefulWidget {
  final TranctionProvider dd;
  
  const FundScreenWeb({super.key, required this.dd});

  @override
  ConsumerState<FundScreenWeb> createState() => _FundScreenWebState();
}

class _FundScreenWebState extends ConsumerState<FundScreenWeb> {
  List<Map<String, dynamic>> availableApps = [];
  bool _isDisposedIos = false;

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

  @override
  void initState() {
    super.initState();
    ref.read(transcationProvider).initialdata(context);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      checkIosAvailableApps();
    }
  }

  @override
  void dispose() {
    _isDisposedIos = true;
    super.dispose();
  }

  Future<void> checkIosAvailableApps() async {
    List<Map<String, dynamic>> tempList = [];

    for (var app in upiApptest) {
      bool isInstalled = await canLaunch(app['url']!);
      if (isInstalled) {
        tempList.add(app);
      }
    }
    
    if (!_isDisposedIos && mounted) {
      setState(() {
        availableApps = tempList;
      });
    }
  }

  Future<void> _handleAndroidUpiPayment(
      BuildContext context, TranctionProvider fund) async {
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
      TranctionProvider fund, dynamic theme) async {
    fund.resetBottomSheetState();
    if (availableApps.isEmpty) {
      // Show no UPI apps available message
      showResponsiveWarningMessage(context, "No UPI apps available");
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
      // Show UPI apps selection
      showResponsiveWarningMessage(context, "Please complete payment in UPI app");
    }
  }

  _showUpiIdForm(BuildContext context, TranctionProvider fund, dynamic theme,
      dynamic colors) {
    fund.togglefundLoading(false);
    fund.clearerror();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.titleText(
                        text: "UPI ID",
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
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
                  const SizedBox(height: 16),
                  Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    height: 0,
                  ),
                  const SizedBox(height: 16),
                  
                  // UPI ID Input
                  TextFormField(
                    controller: fund.upiid,
                    style: TextWidget.textStyle(
                      fontSize: 16,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                    ),
                    inputFormatters: [
                      NoEmojiInputFormatter(),
                      FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/,]')),
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    decoration: InputDecoration(
                      hintText: "Enter UPI ID",
                      hintStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colors.colorBlue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colors.colorBlue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        align: TextAlign.left,
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(0, 48),
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        fund.upiidOnchange(fund.upiid.text);
                        fund.validateUPI(fund.upiid.text);
                        if (fund.upiiderror == null || fund.upiiderror!.isEmpty) {
                          await _handleUpiIdPayment(context, fund);
                        }
                      },
                      child: fund.fundLoading
                          ? SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.colorWhite,
                              ),
                            )
                          : TextWidget.subText(
                              text: "Pay Via UPI ID",
                              theme: false,
                              color: colors.colorWhite,
                              fw: 2,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      fund.togglefundLoading(false);
    });
  }

  Future<void> _handleUpiIdPayment(
      BuildContext context, TranctionProvider fund) async {
    fund.resetBottomSheetState();

    try {
      await fund.fetcUPIIDPayment(
          context,
          fund.upiid.text,
          fund.decryptclientcheck!.clientCheck!.dATA![fund.indexss][0],
          fund.bankdetails!.dATA![fund.indexss][2]);

      if (fund.upiiderror != null && fund.upiiderror!.isNotEmpty) {
        return;
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

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
              },
              child: const UPIIDPaymentCancelAlert(),
            );
          },
        );

        await fund.fetchHdfcpaymetstatus(
            context,
            '${fund.hdfctranction!.data!.orderNumber}',
            '${fund.hdfctranction!.data!.upiTransactionNo}');
      }
    } catch (e) {
      fund.togglefundLoading(false);
      rethrow;
    }
  }

  Future<void> _handleRazorpayPayment(
      BuildContext context, TranctionProvider fund) async {
    fund.resetBottomSheetState();
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

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    final fund = ref.read(transcationProvider);
    showDialog(
      context: context,
      builder: (context) => RazorpayFailedUi(
        acco: widget.dd.accno,
        ifsc: widget.dd.ifsc,
        amount: fund.amount.text,
        bankname: widget.dd.bankname
      ),
    );
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    final fund = ref.read(transcationProvider);
    fund.fetchrazorpayStatus("${response.paymentId}");
    showDialog(
      context: context,
      builder: (context) => RazorpaySuccessUi(amount: fund.amount.text),
    );
    fund.amount.clear();
  }

  String formatIndianCurrency(String amount) {
    final formatter = NumberFormat.currency(
      locale: "en_IN",
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(double.tryParse(amount) ?? 0.0);
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
                    // Available Amount
                    _buildAvailableAmountSection(funds, theme),
                    const SizedBox(height: 24),
                    
                    // Amount Input
                    _buildAmountInput(fund, theme),
                    const SizedBox(height: 8),
                    
                    // Error Messages
                    _buildErrorMessage(fund, theme),
                    const SizedBox(height: 24),
                    
                    // Bank Selection
                    _buildBankSelection(fund, theme),
                    const SizedBox(height: 24),
                    
                    // Payment Method
                    _buildPaymentMethods(fund, theme),
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
            text: 'Add Money',
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

  Widget _buildAvailableAmountSection(dynamic funds, ThemesProvider theme) {
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
                  text: "Available",
                  theme: false,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 0,
                ),
                const SizedBox(height: 4),
                TextWidget.titleText(
                  text: "₹ ${formatIndianCurrency(funds.fundDetailModel?.cash ?? "0.00")}",
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

  Widget _buildAmountInput(TranctionProvider fund, ThemesProvider theme) {
    return TextFormField(
      focusNode: fund.focusNode,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      style: TextWidget.textStyle(
        theme: theme.isDarkMode,
        fontSize: 25,
        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
      ),
      controller: fund.amount,
      onChanged: (value) {
        fund.textFiledonChange(value);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.colorBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBorder: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.colorBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
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
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(TranctionProvider fund, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: fund.amount.text.isEmpty || fund.intValue < 50
          ? TextWidget.captionText(
              text: fund.funderror,
              theme: false,
              color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
              fw: 0,
            )
          : fund.intValue > 5000000
              ? TextWidget.captionText(
                  text: fund.maxfunderror,
                  theme: false,
                  color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                  fw: 0,
                )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildBankSelection(TranctionProvider fund, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListDivider(),
        InkWell(
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            fund.focusNode.unfocus();
            showBottomSheetbank(fund, theme);
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: TextWidget.subText(
                text: fund.bankname,
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextWidget.paraText(
                text: hideAccountNumber(fund.accno),
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
              ),
            ),
            trailing: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
                highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 150));
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
                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const ListDivider(),
      ],
    );
  }

  Widget _buildPaymentMethods(TranctionProvider fund, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: "Payment method",
          theme: false,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 2,
        ),
        const SizedBox(height: 16),
        ListView.separated(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fund.defaultUpiapps.length,
          separatorBuilder: (context, index) => const ListDivider(),
          itemBuilder: (context, index) {
            bool isUpiPayment = index == 0 || index == 1;
            bool isAmountAbove1Lakh = fund.intValue > 100000;

            return InkWell(
              onTap: () {
                if (fund.amount.text.isEmpty || fund.intValue < 50) {
                  showResponsiveWarningMessage(context, "Min amount ₹50");
                  return;
                }
                if (isUpiPayment && isAmountAbove1Lakh) {
                  showResponsiveWarningMessage(context,
                      "UPI payments are not allowed for amounts above ₹1,00,000. Please use Net Banking.");
                  return;
                }
                if (index == 0) {
                  if (defaultTargetPlatform == TargetPlatform.android) {
                    _handleAndroidUpiPayment(context, fund);
                  } else {
                    _handleIosUpiPayment(context, fund, theme);
                  }
                } else if (index == 1) {
                   _showUpiIdForm(context, fund, theme, colors);
                 } else if (index == 2) {
                  if (fund.intValue > 5000000) {
                    showResponsiveWarningMessage(context, "Max amount ₹5,000,000");
                  } else {
                    _handleRazorpayPayment(context, fund);
                  }
                }
              },
              child: Opacity(
                opacity: (isUpiPayment && isAmountAbove1Lakh) ? 0.5 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        '${fund.addfundIcons[index]['image']}',
                        width: 40,
                        color: index == 2 ? (theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight) : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget.paraText(
                                  text: '${fund.defaultUpiapps[index]['name']}',
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textPrimaryDark
                                      : colors.textPrimaryLight,
                                ),
                                SvgPicture.asset(
                                  assets.leftArrow,
                                  width: 16,
                                  height: 16,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                )
                              ],
                            ),
                            if (isUpiPayment && isAmountAbove1Lakh)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextWidget.captionText(
                                  text: "Not available for amount above ₹1,00,000",
                                  theme: false,
                                  color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
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
            );
          },
        ),
      ],
    );
  }

  showBottomSheetbank(TranctionProvider fund, ThemesProvider theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        text: 'Choose a bank',
                        theme: false,
                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
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
                ),
                
                // Bank List
                Flexible(
                  child: ListView.builder(
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
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: fund.bankdetails!.dATA![index][1] == fund.bankname
                                ? theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.2) : colors.textSecondaryLight.withOpacity(0.2)
                                : Colors.transparent,
                            border: index < fund.bankdetails!.dATA!.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                                      width: 0.5,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget.titleText(
                                    text: '${fund.bankdetails!.dATA![index][1]}',
                                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  TextWidget.paraText(
                                    text: hideAccountNumber(fund.bankdetails!.dATA![index][2]),
                                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                                ],
                              ),
                              if (fund.bankdetails!.dATA![index][1] == fund.bankname)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
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
}


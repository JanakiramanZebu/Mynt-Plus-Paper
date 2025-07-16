import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/snack_bar.dart';
import 'withdraw_break_up.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  final TranctionProvider withdarw;
  final FocusNode foucs;
  final ThemesProvider theme;
  final String segment;
  const WithdrawScreen({
    super.key,
    required this.withdarw,
    required this.foucs,
    required this.theme,
    required this.segment,
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
  @override
  void initState() {
    ref.read(transcationProvider).initialdata(context);
    ref.read(transcationProvider).withdrawstatus![0].msg == "no data found"
        ? _isVisible = false
        : _isVisible = true;

    // Clear the text field when screen is initialized
    widget.withdarw.withdrawamount.clear();
    
    disable = (widget.withdarw.withdrawamount.text.isEmpty ||
        widget.withdarw.payoutdetails!.withdrawAmount == "0.00");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(transcationProvider);
    final funds = ref.watch(fundProvider);
    return Scaffold(
      backgroundColor:
          widget.theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        centerTitle: false,
        leadingWidth: 48,
        titleSpacing: 6,
        leading: CustomBackBtn(),
        elevation: .2,
        title: TextWidget.titleText(
          text: 'Withdraw Fund',
          theme: theme.isDarkMode,
          fw: 1,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          widget.foucs.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text:
                          "Withdrawable amount (Bal: ${widget.withdarw.payoutdetails!.withdrawAmount} )",
                      theme: widget.theme.isDarkMode,
                      color: colors.textPrimaryLight,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      enabled: widget.withdarw.payoutdetails!.withdrawAmount ==
                              '0.00'
                          ? false
                          : true,
                      focusNode: widget.foucs,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                        // Prevent entering just "0"
                        FilteringTextInputFormatter.deny(RegExp(r'^0$')),
                      ],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextWidget.textStyle(
                          theme: widget.theme.isDarkMode, fontSize: 25, fw: 1),
                      controller: widget.withdarw.withdrawamount,
                      onChanged: (value) {
                        // widget.withdarw.withdrawamount.text = value;
                        setState(() {
                          if (widget.withdarw.withdrawamount.text.isNotEmpty) {
                            double enteredAmount = double.parse(widget.withdarw.withdrawamount.text);
                            double availableAmount = double.parse(widget.withdarw.payoutdetails!.withdrawAmount.toString());                           
                           
                            if (enteredAmount <= 0) {
                              disable = true;
                              withdarwerror = "Amount must be greater than 0";
                            }                            
                            else if (enteredAmount > availableAmount) {
                              disable = true;
                              withdarwerror = "Insufficient fund";
                            }                           
                            else {
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
                            borderSide: BorderSide.none,
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
                            color: colors.colorGrey,
                            fontSize: 25,
                            fw: 1),
                        labelStyle: TextWidget.textStyle(
                            theme: widget.theme.isDarkMode,
                            fontSize: 25,
                            fw: 1),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            assets.ruppeIcon,
                            color: widget.theme.isDarkMode
                                ? colors.colorWhite
                                : colors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: withdarwerror == ""
                    ? Container()
                    : TextWidget.captionText(
                        text: withdarwerror,
                        theme: false,
                        color: colors.error,
                      ),
              ),
              const SizedBox(height: 16),
             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 40),
                    backgroundColor: disable
                        ? colors.darkGrey
                        : widget.theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide.none,
                  ),
                  onPressed: (disable)
                      ? () {
                          if (widget.withdarw.payoutdetails!.withdrawAmount ==
                              "0.00") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(context, "Insufficient fund"));
                          } else if (widget.withdarw.withdrawamount.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(
                                    context, "Please enter the amount"));
                          } else if (double.tryParse(widget.withdarw.withdrawamount.text) != null && 
                                     double.parse(widget.withdarw.withdrawamount.text) <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(
                                    context, "Amount must be greater than 0"));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(
                                    context, "Please enter a valid amount"));
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
                      ?  SizedBox(
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
              ),
              const SizedBox(height: 16),
               Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          isBreakUpExpanded = !isBreakUpExpanded;
                        });
                      },
                      // onTap: () async {
                      //   showModalBottomSheet(
                      //       enableDrag: false,
                      //       useSafeArea: true,
                      //       isScrollControlled: true,
                      //       shape: const RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.vertical(
                      //               top: Radius.circular(16))),
                      //       backgroundColor: const Color(0xffffffff),
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return BreakUpDetails(
                      //             withdraw: widget.withdarw);
                      //       });
                      // },
                      splashColor: theme.isDarkMode
                          ? colors.splashColorDark
                          : colors.splashColorLight,
                      highlightColor: theme.isDarkMode
                          ? colors.highlightDark
                          : colors.highlightLight,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(assets.breakup,
                                width: 14, height: 14),
                            const SizedBox(width: 6),
                            TextWidget.subText(
                              text: "Break up",
                              theme: false,
                              color: colors.colorBlue,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isBreakUpExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: colors.colorBlue,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Expandable break up content
                    if (isBreakUpExpanded) ...[
                      const SizedBox(height: 16),
                      _buildBreakUpContent(),
                    ],
                    
                  ],
                ),
              ),
              if (_isVisible == true) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                          text: "Open Request",
                          theme: false,
                          color: widget.theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffFFF3E0).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          minLeadingWidth: 10,
                          leading: const Icon(
                            Icons.timer_outlined,
                            color: Color(0xfffb8c00),
                          ),
                          title: Row(
                            children: [
                              TextWidget.paraText(
                                  text: "Request on : ",
                                  theme: false,
                                  color: colors.colorBlack,
                                 ),
                              TextWidget.paraText(
                                  text:
                                      "${widget.withdarw.withdrawstatus?[0].eNTRYTIME}",
                                  theme: false,
                                  color: colors.secondaryLight,
                                 ),
                            ],
                          ),
                          trailing: TextWidget.subText(
                              text:
                                  "₹ ${widget.withdarw.withdrawstatus?[0].dUEAMT}",
                              theme: false,
                              color: colors.textPrimaryLight,
                              ),
                        ),
                      ),
                    ],
                  ),
                )

                //  Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         contantTitleText(
                //           "₹${widget.withdarw.payoutdetails!.withdrawAmount}",
                //           widget.theme,
                //         ),
                //         if (double.parse(widget
                //                 .withdarw.payoutdetails!.withdrawAmount
                //                 .toString()) >
                //             0) ...[
                //           InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   widget.withdarw.withdrawamount.text = widget
                //                       .withdarw.payoutdetails!.withdrawAmount
                //                       .toString();
                //                       withdarwerror = "";
                //                   disable = false;
                //                 });
                //               },
                //               child: Container(
                //                 padding: const EdgeInsets.symmetric(
                //                     horizontal: 12, vertical: 6),
                //                 decoration: BoxDecoration(
                //                   color: widget.theme.isDarkMode
                //                       ? colors.colorLightBlue.withOpacity(0.1)
                //                       : colors.colorBlue.withOpacity(0.1),
                //                   borderRadius: BorderRadius.circular(16),
                //                 ),
                //                 child: Text("Withdraw All",
                //                     style: textStyles.resendOtpstyle.copyWith(
                //                         color: widget.theme.isDarkMode
                //                             ? colors.colorLightBlue
                //                             : colors.colorBlue)),
                //               )),
                //         ]
                //       ],
                //     ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  showUIWithDelay() {
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  Widget data(String name, String value, ThemesProvider theme) {
     return Column(
       children: [
         const SizedBox(height: 12),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             TextWidget.subText(
                 text: name,
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
           thickness: 0,
           color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
         )
       ],
     );
   }

   Widget _buildBreakUpContent() {
     final funds = ref.watch(fundProvider);
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16),
       child: Column(
         children: [
           // Available cash
           data(
             "Available cash",
             "₹${funds.fundDetailModel?.totCredit ?? "0.00"}",
             widget.theme,
           ),
           // Margin used
           data(
             "Margin used",
             "₹${funds.fundDetailModel?.utilizedMrgn ?? "0.00"}",
             widget.theme,
           ),
           // Withdrawable amount
           data(
             "Withdrawable amount",
             "₹${widget.withdarw.payoutdetails!.withdrawAmount}",
             widget.theme,
           ),
         ],
       ),
     );
   }
}

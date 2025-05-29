import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
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
  @override
  void initState() {
    ref.read(transcationProvider).withdrawstatus![0].msg == "no data found"
        ? _isVisible = false
        : _isVisible = true;

    disable = (widget.withdarw.withdrawamount.text.isEmpty ||
        widget.withdarw.payoutdetails!.withdrawAmount == "0.00");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.foucs.unfocus();
      },
      child: Column(
        children: [
          TextFormField(
            enabled: widget.withdarw.payoutdetails!.withdrawAmount == '0.00'
                ? false
                : true,
            focusNode: widget.foucs,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: textStyle(
                widget.theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                35,
                FontWeight.w600),
            controller: widget.withdarw.withdrawamount,
            onChanged: (value) {
              widget.withdarw.withdrawamount.text = value;
              setState(() {
                if (widget.withdarw.withdrawamount.text.isNotEmpty) {
                  disable = !(double.parse(widget
                          .withdarw.payoutdetails!.withdrawAmount
                          .toString()) >=
                      double.parse(widget.withdarw.withdrawamount.text));
                } else if (widget.withdarw.withdrawamount.text.isEmpty ||
                    widget.withdarw.payoutdetails!.withdrawAmount == "0.00") {
                  disable = true;
                } else {
                  disable = false;
                }
                withdarwerror = disable ? "Insufficient fund" : "";
              });
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30)),
              disabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30)),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30)),
              fillColor: Colors.transparent,
              filled: true,
              hintText: "0",
              hintStyle: textStyle(
                  widget.theme.isDarkMode
                      ? colors.colorGrey
                      : widget.withdarw.payoutdetails!.withdrawAmount == '0.00'
                          ? colors.colorGrey
                          : colors.colorBlack,
                  40,
                  FontWeight.w600),
              labelStyle: textStyle(
                  widget.theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                  40,
                  FontWeight.w600),
              prefixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    assets.ruppeIcon,
                    fit: BoxFit.contain,
                    color: widget.theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorGrey,
                    width: 10,
                    height: 8,
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                withdarwerror == ""
                    ? Container()
                    : Text(
                        withdarwerror,
                        style: textStyle(
                            colors.kColorRedText, 14, FontWeight.w500),
                      ),
                SizedBox(
                  height: withdarwerror == "" ? 0 : 6,
                ),
                Row(
                  children: [
                    headerTitleText(
                      "Withdrawable amount ",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 7),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              enableDrag: false,
                              useSafeArea: true,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16))),
                              backgroundColor: const Color(0xffffffff),
                              context: context,
                              builder: (BuildContext context) {
                                return BreakUpDetails(
                                    withdraw: widget.withdarw);
                              });
                        },
                        child: Text(
                          "break up",
                          style:
                              textStyle(colors.colorBlue, 12, FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    contantTitleText(
                      "₹${widget.withdarw.payoutdetails!.withdrawAmount}",
                      widget.theme,
                    ),
                    if (double.parse(widget
                            .withdarw.payoutdetails!.withdrawAmount
                            .toString()) >
                        0) ...[
                      InkWell(
                          onTap: () {
                            setState(() {
                              widget.withdarw.withdrawamount.text = widget
                                  .withdarw.payoutdetails!.withdrawAmount
                                  .toString();
                                  withdarwerror = "";
                              disable = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.theme.isDarkMode
                                  ? colors.colorLightBlue.withOpacity(0.1)
                                  : colors.colorBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text("Withdraw All",
                                style: textStyles.resendOtpstyle.copyWith(
                                    color: widget.theme.isDarkMode
                                        ? colors.colorLightBlue
                                        : colors.colorBlue)),
                          )),
                    ]
                  ],
                ),
                const SizedBox(height: 5),
                Divider(color: colors.colorDivider),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: disable
                      ? colors.darkGrey
                      : widget.theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: (disable)
                    ? () {
                        if (widget.withdarw.payoutdetails!.withdrawAmount ==
                            "0.00") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              warningMessage(context, "Insufficient fund"));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              warningMessage(
                                  context, "Please enter the amount"));
                        }
                      }
                    : () async {
                        await widget.withdarw.fetchPaymentWithDraw(
                            widget.withdarw.ipAddress,
                            widget.withdarw.withdrawamount.text,
                            widget.segment,
                            context);
                        _isVisible = false;
                        widget.withdarw.focusNode.unfocus();
                        showUIWithDelay();
                      },
                child: widget.withdarw.fundisLoad
                    ? const SizedBox(
                        width: 18,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xff666666)),
                      )
                    : Text(
                        'Withdraw',
                        style: textStyle(
                            disable
                                ? colors.colorGrey
                                : widget.theme.isDarkMode
                                    ? colors.colorBlack
                                    : colors.colorWhite,
                            16,
                            FontWeight.w400),
                      )),
          ),
          const SizedBox(
            height: 15,
          ),
          const ListDivider(),
          const SizedBox(
            height: 15,
          ),
          if (_isVisible == true) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Open Request",
                    style: textStyle(
                        widget.theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        15,
                        FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffFFF3E0),
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      minLeadingWidth: 10,
                      leading: const Icon(
                        Icons.timer_outlined,
                        color: Color(0xfffb8c00),
                      ),
                      title: Row(
                        children: [
                          Text(
                            "Request on : ",
                            style: textStyle(
                                colors.colorBlack, 12, FontWeight.w500),
                          ),
                          Text(
                            "${widget.withdarw.withdrawstatus?[0].eNTRYTIME}",
                            style: textStyle(
                                colors.colorBlue, 12, FontWeight.w500),
                          )
                        ],
                      ),
                      trailing: Text(
                        "₹ ${widget.withdarw.withdrawstatus?[0].dUEAMT}",
                        style:
                            textStyle(colors.colorBlack, 13, FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  showUIWithDelay() {
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  Text headerTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorGrey, 13, FontWeight.w500),
    );
  }

  Text contantTitleText(String text, ThemesProvider theme) {
    return Text(
      text,
      style: textStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          15, FontWeight.w600),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
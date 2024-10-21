import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';

class WithdrawScreen extends StatefulWidget {
  final TranctionProvider withdarw;
  final FocusNode foucs;
  const WithdrawScreen(
      {super.key, required this.withdarw, required this.foucs});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String withdarwerror = "";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.foucs.unfocus();
      },
      child: Column(
        children: [
          TextFormField(
            enabled: widget.withdarw.payoutdetails!.withdrawAmount == '0.0'
                ? false
                : true,
            focusNode: widget.foucs,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.datetime,
            style: textStyle(colors.colorBlack, 35, FontWeight.w600),
            controller: widget.withdarw.withdrawamount,
            onChanged: (value) {
              widget.withdarw.withdrawamount.text = value;
              setState(() {
                if (widget.withdarw.withdrawamount.text.isNotEmpty) {
                  double.parse(widget.withdarw.payoutdetails!.withdrawAmount
                                  .toString())
                              .toInt() >
                          int.parse(widget.withdarw.withdrawamount.text).toInt()
                      ? withdarwerror = ""
                      : withdarwerror = "Insufficient fund";
                } else {
                  withdarwerror = "";
                }
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
              labelStyle:
                  textStyle(const Color(0xff000000), 40, FontWeight.w600),
              prefixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffffffff)),
                  child: SvgPicture.asset(
                    assets.ruppeIcon,
                    // fit: BoxFit.cover,
                    color:
                        widget.withdarw.payoutdetails!.withdrawAmount == '0.0'
                            ? colors.colorGrey
                            : colors.colorBlack,
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
                headerTitleText(
                  "WITHDRAWABLE AMOUNT",
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerTitleText(
                            "CASH",
                          ),
                          const SizedBox(height: 2),
                          contantTitleText(
                            "${widget.withdarw.payoutdetails!.totalLedger}",
                          ),
                          const SizedBox(height: 2),
                          Divider(color: colors.colorDivider),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerTitleText(
                            "MARGIN",
                          ),
                          const SizedBox(height: 2),
                          contantTitleText(
                            "${widget.withdarw.payoutdetails!.margin}",
                          ),
                          const SizedBox(height: 2),
                          Divider(color: colors.colorDivider),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                headerTitleText(
                  "WITHDRAWABLE FUND",
                ),
                const SizedBox(height: 2),
                contantTitleText(
                  "${widget.withdarw.payoutdetails!.withdrawAmount}",
                ),
                const SizedBox(height: 2),
                Divider(color: colors.colorDivider),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Text headerTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorGrey, 13, FontWeight.w500),
    );
  }

  Text contantTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorBlack, 15, FontWeight.w600),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

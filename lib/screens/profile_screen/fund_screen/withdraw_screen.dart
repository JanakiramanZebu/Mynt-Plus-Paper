import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';

class WithdrawScreen extends StatefulWidget {
  final TranctionProvider withdarw;
  const WithdrawScreen({super.key, required this.withdarw});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  TextEditingController withdrawamount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          headerTitleText(
            "WITHDRAWABLE AMOUNT",
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 44,
            child: TextFormField(
              style: textStyles.textFieldLabelStyle,
              controller: withdrawamount,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                fillColor: const Color(0xffF1F3F8),
                filled: true,
                hintText: "0.00",
                labelStyle:
                    textStyle(const Color(0xff000000), 16, FontWeight.w600),
                prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffffffff)),
                    child: SvgPicture.asset(assets.ruppeIcon,
                        fit: BoxFit.scaleDown)),
              ),
            ),
          )
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

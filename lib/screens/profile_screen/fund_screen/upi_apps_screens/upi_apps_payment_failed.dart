import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';

class AtomTranscationFailed extends StatefulWidget {
  final TranctionProvider fund;
  const AtomTranscationFailed({super.key, required this.fund});

  @override
  State<AtomTranscationFailed> createState() => _AtomTranscationFailedState();
}

class _AtomTranscationFailedState extends State<AtomTranscationFailed> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Zebu Mobile UPI",
            style: textStyle(colors.colorBlack, 16, FontWeight.w600),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "UPI Address: ${widget.fund.hdfcUPIStatus!.data!.clientVPA}",
            style: textStyle(colors.colorGrey, 14, FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.only(top: 35),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  widget.fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  //
                  color: widget.fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                      ? colors.kColorGreenButton
                      : colors.kColorRedButton,
                  size: 70,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${widget.fund.hdfcUPIStatus!.data!.status}",
                  style: textStyle(colors.colorBlack, 16, FontWeight.w600),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.fund.hdfcUPIStatus!.data!.status == "SUCCESS"
                      ? "Transaction Success"
                      : "Transaction fail",
                  style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "₹${widget.fund.hdfcUPIStatus!.data!.amount}",
                  style: textStyle(colors.colorBlack, 40, FontWeight.w600),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  formatDateTimepaymet(
                      value:
                          "${widget.fund.hdfcUPIStatus!.data!.transactionAuthDate}"),
                  style: textStyle(colors.colorGrey, 13, FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Divider(
            color: colors.colorGrey,
          ),
          const SizedBox(
            height: 10,
          ),
          headerTitleText("UPI ID"),
          contantTitleText("${widget.fund.hdfcUPIStatus!.data!.clientVPA}"),
          const SizedBox(
            height: 15,
          ),
          headerTitleText("Order ID"),
          contantTitleText("${widget.fund.hdfcUPIStatus!.data!.orderNumber}"),
          const SizedBox(
            height: 15,
          ),
          headerTitleText("UPI Transaction ID"),
          contantTitleText(
              "${widget.fund.hdfcUPIStatus!.data!.upiTransactionNo}"),
          const SizedBox(
            height: 15,
          ),
          headerTitleText("Ref ID"),
          contantTitleText(
              "${widget.fund.hdfcUPIStatus!.data!.nPCIclientRefNo}"),
          const SizedBox(
            height: 25,
          ),
          Center(
            child: TextButton(
                onPressed: () {},
                child: Text(
                  'Done',
                  style: textStyle(colors.colorBlack, 16, FontWeight.w400),
                )),
          )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  Text headerTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorGrey, 14, FontWeight.w500),
    );
  }

  Text contantTitleText(String text) {
    return Text(
      text,
      style: textStyle(colors.colorBlack, 15, FontWeight.w600),
    );
  }
}

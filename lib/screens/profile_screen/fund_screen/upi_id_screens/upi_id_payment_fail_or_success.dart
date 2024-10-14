import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';


class UpiIdSucessorFaliureScreen extends StatefulWidget {
  final TranctionProvider fund;
  const UpiIdSucessorFaliureScreen({super.key, required this.fund});

  @override
  State<UpiIdSucessorFaliureScreen> createState() => _UpiIdSucessorFaliureScreenState();
}

class _UpiIdSucessorFaliureScreenState extends State<UpiIdSucessorFaliureScreen> {
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
            "UPI Address: ${widget.fund.hdfcpaymentstatus!.data!.clientVPA}",
            style: textStyle(colors.colorGrey, 14, FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.only(top: 35),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  widget.fund.hdfcpaymentstatus!.data!.status == "SUCCESS"
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  //
                  color:
                      widget.fund.hdfcpaymentstatus!.data!.status == "SUCCESS"
                          ? colors.kColorGreenButton
                          : colors.kColorRedButton,
                  size: 70,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${widget.fund.hdfcpaymentstatus!.data!.status}",
                  style: textStyle(colors.colorBlack, 16, FontWeight.w600),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.fund.hdfcpaymentstatus!.data!.status == "SUCCESS"
                      ? "Transaction Success"
                      : "Transaction fail",
                  style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "₹${widget.fund.hdfcpaymentstatus!.data!.amount}",
                  style: textStyle(colors.colorBlack, 40, FontWeight.w600),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  formatDateTimepaymet(
                      value:
                          "${widget.fund.hdfcpaymentstatus!.data!.transactionAuthDate}"),
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
          contantTitleText("${widget.fund.hdfcpaymentstatus!.data!.clientVPA}"),
          const SizedBox(
            height: 15,
          ),
          headerTitleText("Order ID"),
          contantTitleText(
              "${widget.fund.hdfcpaymentstatus!.data!.orderNumber}"),
          const SizedBox(
            height: 15,
          ),
          headerTitleText("UPI Transaction ID"),
          contantTitleText(
              "${widget.fund.hdfcpaymentstatus!.data!.upiTransactionNo}"),
          const SizedBox(
            height: 15,
          ),
          headerTitleText("Ref ID"),
          contantTitleText(
              "${widget.fund.hdfcpaymentstatus!.data!.nPCIclientRefNo}"),
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
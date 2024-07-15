import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../models/order_book_model/sip_order_book.dart';
import '../../provider/sip_order_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart'; 

class SipOrderDetails extends StatefulWidget {
  final SipDetails sipdetails;
  const SipOrderDetails({super.key, required this.sipdetails});

  @override
  State<SipOrderDetails> createState() => _SipOrderDetailsState();
}

class _SipOrderDetailsState extends State<SipOrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.sipdetails.sipName}",
                    // textScaleFactor: sizes.commontextScaleFactor,
                    style: textStyle(
                        const Color(0XFF000000), 15, FontWeight.w600)),
                Text(sipformatDateTime(value: "${widget.sipdetails.regDate}"),
                    style: textStyle(
                        const Color(0xff666666), 12, FontWeight.w500)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sip Id",
                              // textScaleFactor: sizes.commontextScaleFactor,
                              style: textStyle(const Color(0xff666666), 12,
                                  FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            "${widget.sipdetails.internal!.sipId}",
                            // textScaleFactor: sizes.commontextScaleFactor,
                            style: textStyle(
                                const Color(0xff000000), 14, FontWeight.w500),
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
                          Text("Frequncy",
                              // textScaleFactor: sizes.commontextScaleFactor,
                              style: textStyle(const Color(0xff666666), 12,
                                  FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            widget.sipdetails.frequency == "0"
                                ? "Daily"
                                : widget.sipdetails.frequency == "1"
                                    ? "Weekly"
                                    : "Monthly",
                            style: textStyle(
                                const Color(0xff000000), 14, FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Divider(color: colors.colorDivider),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xff000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      onPressed: () async {},
                      child: Text("Modify",
                          style: textStyle(
                              const Color(0XFFFFFFFF), 14, FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: const Color(0xffDF2525),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                    onPressed: () async {
                      Navigator.pop(context);
                      context.read(siprovider).fetchSipOrderCancel(
                          "${widget.sipdetails.internal!.sipId}", context);
                    },
                    child: Text("Cancle",
                        style: textStyle(
                            const Color(0XFFFFFFFF), 14, FontWeight.w600)),
                  ))
                ])
              ]));
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

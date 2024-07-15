import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffDDDDDD)),
          borderRadius: BorderRadius.circular(4)),
      child: ListTile(
          title: Text(
            "TRENDING IN",
            style: GoogleFonts.inter(
                textStyle:
                    textStyle(const Color(0xff0037B7), 11, FontWeight.w600)),
          ),
          subtitle: Column(
            children: [
              const SizedBox(height: 3),
              Text(
                "Most traded & top market capital companies which is growing fast",
                style: GoogleFonts.inter(
                    textStyle: textStyle(
                        const Color(0xff000000), 14, FontWeight.w600)),
              ),
            ],
          ),
          trailing: Image.asset(
            "assets/img/trade_img.png",
            fit: BoxFit.cover,
            width: 120,
          )),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}

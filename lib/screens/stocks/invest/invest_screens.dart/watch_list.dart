import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../res/res.dart';

class WatchList extends StatelessWidget {
  const WatchList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xffF1F3F8),
          borderRadius: BorderRadius.all(Radius.circular(6))),
      padding: const EdgeInsets.symmetric(vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: ListTile(
        onTap: () async {},
        title: Row(
          children: [
            Text(
              "Create Watchlist",
              style: GoogleFonts.inter(
                  textStyle:
                      textStyle(const Color(0xff000000), 16, FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(assets.rightArrowIcon)
          ],
        ),
        subtitle: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Now track your favorite stocks by adding them to your watchlist.',
              style: GoogleFonts.inter(
                  textStyle:
                      textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            ),
          ],
        ),
        trailing: SvgPicture.asset("assets/icon/watchlistIcon/Binocular.svg"),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}

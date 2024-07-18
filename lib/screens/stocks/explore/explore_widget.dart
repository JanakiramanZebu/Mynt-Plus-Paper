import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/stocks_provider.dart'; 

class ExploreWidget extends ConsumerWidget {
  const ExploreWidget({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final explore = watch(stocksProvide);
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: explore.exploreNames.length,
        itemBuilder: (BuildContext context, int index) {
          return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side:   BorderSide(
                        width: 1,
                        color:
                         explore.exploreNames[index] == explore.exploreName
                            ? const Color(0xff000000)
                            : 
                            const Color(0xff666666),
                      ),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                    onPressed: () async {
                    explore. chngExpName(explore.exploreNames[index],index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        explore.exploreNames[index],
                        style: textStyle(
                               explore.exploreNames[index] == explore.exploreName
                                ? const Color(0xff000000)
                                :
                                 const Color(0xff666666),
                            14,
                            FontWeight.w600),
                      ),
                    ),
                  );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

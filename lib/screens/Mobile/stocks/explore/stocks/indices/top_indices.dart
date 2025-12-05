import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../provider/index_list_provider.dart';
import '../../../../../../provider/stocks_provider.dart';
import '../../../../../../provider/thems.dart';
import '../../../../../../res/global_state_text.dart';
import '../../../../../../res/res.dart';
import '../../../../../../routes/route_names.dart';
import '../../../../market_watch/index/index_screen.dart';
// import 'top_indices_list_card.dart';

class TopIndices extends StatefulWidget {
  const TopIndices({super.key});

  @override
  State<TopIndices> createState() => _TopIndicesState();
}

class _TopIndicesState extends State<TopIndices> {
  final ScrollController _scrollController = ScrollController();
  int _currentDotIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateDotIndex);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateDotIndex);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateDotIndex() {
    // Calculate the currently visible item index
    double itemHeight = 100.0; // Update this to match your item height
    int newIndex = (_scrollController.offset / itemHeight).floor();

    if (newIndex != _currentDotIndex) {
      setState(() {
        _currentDotIndex = newIndex;
      });
    }
  }

  @override
  Widget build(context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      // final indices = ref.watch(indexListProvider);
      return const Padding(
        padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   TextWidget.titleText(
            //     text: "Indices",
            //     theme: false,
            //     color: theme.isDarkMode
            //         ? colors.textPrimaryDark
            //         : colors.textPrimaryLight,
            //     fw: 1,
            //   ),
            //   // TextButton(
            //   //     onPressed: () async {
            //   //       await ref.read(indexListProvider).fetchAllIndex();
            //   //       await ref.read(stocksProvide).getGlobalIndices();
            //   //       Navigator.pushNamed(context, Routes.allIndex);
            //   //     },
            //   //     child: Text('See all',
            //   //         style: GoogleFonts.inter(
            //   //             color: const Color(0xff0037B7),
            //   //             fontSize: 14,
            //   //             fontWeight: FontWeight.w600)))
            // ]),
            DefaultIndexList(src: false)
            // SizedBox(
            //   height: 90,
            //   child: ListView.separated(
            //     separatorBuilder: (BuildContext context, int index) {
            //       return const SizedBox(width: 9);
            //     },
            //     controller: _scrollController,
            //     shrinkWrap: true,
            //     scrollDirection: Axis.horizontal,
            //     physics: const BouncingScrollPhysics(),
            //     itemCount: indices.defTopIndex!.indValues!.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return InkWell(
            //         onTap: () async {
            //           // Handle item tap
            //         },
            //         child: TopIndicesListCard(
            //           indicesData: indices.defTopIndex!.indValues![index],
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}

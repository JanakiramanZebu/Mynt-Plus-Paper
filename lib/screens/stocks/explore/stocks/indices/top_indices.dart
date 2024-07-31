import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../../../provider/index_list_provider.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../routes/route_names.dart';
import 'top_indices_list_card.dart';

class TopIndices extends ConsumerWidget {
  const TopIndices({super.key});

  @override
  Widget build(context, ScopedReader watch) {
    final indices = watch(indexListProvider);
    return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Top Index",
                style: GoogleFonts.inter(
                    textStyle: textStyle(
                        const Color(0xff000000), 16, FontWeight.w600))),
            TextButton(
                onPressed: () async {
                  await context.read(indexListProvider).fetchAllIndex();
                  await context.read(stocksProvide).getGlobalIndices();
                  Navigator.pushNamed(context, Routes.allIndex);
                },
                child: Text('See all',
                    style: GoogleFonts.inter(
                        color: const Color(0xff0037B7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)))
          ]),
          SizedBox(
              height: 86,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: indices.defTopIndex!.indValues!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () async {
                          // await context.read(stocksProvide).getIndicesData(
                          //     indices.topIndicesModel![index].idxname);
                          // Navigator.pushNamed(context, Routes.topIndiciesIndex,
                          //     arguments: indices.topIndicesModel![index]);
                        },
                        child: TopIndicesListCard(
                            indicesData:
                                indices.defTopIndex!.indValues![index]));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 12);
                  }))
        ]));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
